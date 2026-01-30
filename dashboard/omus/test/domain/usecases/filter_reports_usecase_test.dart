import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omus/domain/usecases/filter_reports_usecase.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';

void main() {
  late FilterReportsUsecase usecase;
  late List<Report> testReports;
  late List<Category> testCategories;
  late List<VialActor> testActors;

  setUp(() {
    usecase = FilterReportsUsecase();

    testCategories = [
      Category(id: 1, categoryName: 'Accidentes', hasVictim: true, hasDateTime: true),
      Category(id: 2, categoryName: 'Robos', hasVictim: true, hasDateTime: true),
      Category(id: 3, categoryName: 'Infraestructura', hasVictim: false, hasDateTime: false),
    ];

    testActors = [
      VialActor(id: 1, name: 'Peatón'),
      VialActor(id: 2, name: 'Ciclista'),
      VialActor(id: 3, name: 'Conductor'),
    ];

    testReports = [
      Report(
        id: 1,
        categoryId: 1,
        reportDate: DateTime(2024, 1, 15),
        latitude: -8.1,
        longitude: -79.0,
      ),
      Report(
        id: 2,
        categoryId: 2,
        reportDate: DateTime(2024, 2, 20),
        latitude: -8.2,
        longitude: -79.1,
      ),
      Report(
        id: 3,
        categoryId: 1,
        reportDate: DateTime(2024, 3, 10),
        latitude: -8.3,
        longitude: -79.2,
      ),
      Report(
        id: 4,
        categoryId: 3,
        reportDate: DateTime(2024, 4, 5),
        latitude: -8.4,
        longitude: -79.3,
      ),
      Report(
        id: 5,
        categoryId: 2,
        reportDate: null, // Report without date
        latitude: -8.5,
        longitude: -79.4,
      ),
    ];
  });

  group('FilterReportsUsecase', () {
    test('returns all reports when no filters are applied', () {
      final result = usecase(
        reports: testReports,
        allCategories: testCategories,
        actors: testActors,
      );

      expect(result.length, equals(5));
    });

    test('filters by single category', () {
      final result = usecase(
        reports: testReports,
        allCategories: testCategories,
        actors: testActors,
        selectedCategories: ['1'],
      );

      expect(result.length, equals(2));
      expect(result.every((r) => r.categoryId == 1), isTrue);
    });

    test('filters by multiple categories', () {
      final result = usecase(
        reports: testReports,
        allCategories: testCategories,
        actors: testActors,
        selectedCategories: ['1', '2'],
      );

      expect(result.length, equals(4));
      expect(result.every((r) => r.categoryId == 1 || r.categoryId == 2), isTrue);
    });

    test('filters by date range', () {
      final result = usecase(
        reports: testReports,
        allCategories: testCategories,
        actors: testActors,
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 2, 28),
        ),
      );

      // Should include reports from Jan 15 and Feb 20, exclude Mar 10, Apr 5, and null date
      expect(result.length, equals(2));
      expect(result.map((r) => r.id).toList(), containsAll([1, 2]));
    });

    test('excludes reports without date when date range is specified', () {
      final result = usecase(
        reports: testReports,
        allCategories: testCategories,
        actors: testActors,
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 12, 31),
        ),
      );

      // Report 5 has null date, should be excluded
      expect(result.any((r) => r.id == 5), isFalse);
    });

    test('combines category and date range filters', () {
      final result = usecase(
        reports: testReports,
        allCategories: testCategories,
        actors: testActors,
        selectedCategories: ['1'],
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 2, 28),
        ),
      );

      // Only report 1 (category 1, Jan 15)
      expect(result.length, equals(1));
      expect(result.first.id, equals(1));
    });

    test('returns empty list when no reports match filters', () {
      final result = usecase(
        reports: testReports,
        allCategories: testCategories,
        actors: testActors,
        selectedCategories: ['99'], // Non-existent category
      );

      expect(result.isEmpty, isTrue);
    });

    test('includes subcategories in filter', () {
      final result = usecase(
        reports: testReports,
        allCategories: testCategories,
        actors: testActors,
        selectedCategories: ['1'],
        selectedSubCategories: ['2'],
      );

      // Should include category 1 and 2
      expect(result.length, equals(4));
    });

    test('uses all categories when empty list provided', () {
      final result = usecase(
        reports: testReports,
        allCategories: testCategories,
        actors: testActors,
        selectedCategories: [],
        selectedSubCategories: [],
      );

      expect(result.length, equals(5));
    });
  });
}
