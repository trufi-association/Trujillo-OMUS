import 'package:flutter_test/flutter_test.dart';
import 'package:omus/services/models/report.dart';

void main() {
  group('Report', () {
    test('fromJson creates Report with all fields', () {
      final json = {
        'id': 1,
        'userId': 'user123',
        'categoryId': 5,
        'createDate': '2024-01-15T10:30:00',
        'reportDate': '2024-01-14T15:00:00',
        'latitude': -8.1234,
        'longitude': -79.0567,
        'images': ['image1.jpg', 'image2.jpg'],
        'description': 'Test description',
        'involvedActorId': 2,
        'victimActorId': 3,
      };

      final report = Report.fromJson(json);

      expect(report.id, equals(1));
      expect(report.userId, equals('user123'));
      expect(report.categoryId, equals(5));
      expect(report.createDate, isNotNull);
      expect(report.reportDate, isNotNull);
      expect(report.latitude, equals(-8.1234));
      expect(report.longitude, equals(-79.0567));
      expect(report.images, equals(['image1.jpg', 'image2.jpg']));
      expect(report.description, equals('Test description'));
      expect(report.involvedActorId, equals(2));
      expect(report.victimActorId, equals(3));
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 1,
        'categoryId': 5,
      };

      final report = Report.fromJson(json);

      expect(report.id, equals(1));
      expect(report.categoryId, equals(5));
      expect(report.userId, isNull);
      expect(report.createDate, isNull);
      expect(report.reportDate, isNull);
      expect(report.latitude, isNull);
      expect(report.longitude, isNull);
      expect(report.images, isNull);
      expect(report.description, isNull);
      expect(report.involvedActorId, isNull);
      expect(report.victimActorId, isNull);
    });

    test('fromJson handles invalid date strings', () {
      final json = {
        'id': 1,
        'categoryId': 5,
        'createDate': 'invalid-date',
        'reportDate': '',
      };

      final report = Report.fromJson(json);

      expect(report.createDate, isNull);
      expect(report.reportDate, isNull);
    });

    test('fromJson converts integer latitude/longitude', () {
      final json = {
        'id': 1,
        'categoryId': 5,
        'latitude': -8,
        'longitude': -79,
      };

      final report = Report.fromJson(json);

      expect(report.latitude, equals(-8.0));
      expect(report.longitude, equals(-79.0));
    });

    test('constructor creates Report correctly', () {
      final report = Report(
        id: 10,
        categoryId: 3,
        userId: 'testUser',
        latitude: -8.5,
        longitude: -79.5,
        description: 'Manual report',
      );

      expect(report.id, equals(10));
      expect(report.categoryId, equals(3));
      expect(report.userId, equals('testUser'));
      expect(report.latitude, equals(-8.5));
      expect(report.longitude, equals(-79.5));
      expect(report.description, equals('Manual report'));
    });
  });
}
