import 'package:flutter_test/flutter_test.dart';
import 'package:omus/services/models/category.dart';

void main() {
  group('Category', () {
    test('fromJson creates Category with all fields', () {
      final json = {
        'id': 1,
        'parentId': null,
        'categoryName': 'Accidentes',
        'hasVictim': true,
        'hasDateTime': true,
      };

      final category = Category.fromJson(json);

      expect(category.id, equals(1));
      expect(category.parentId, isNull);
      expect(category.categoryName, equals('Accidentes'));
      expect(category.hasVictim, isTrue);
      expect(category.hasDateTime, isTrue);
    });

    test('fromJson creates subcategory with parentId', () {
      final json = {
        'id': 10,
        'parentId': 1,
        'categoryName': 'Accidente de tránsito',
        'hasVictim': true,
        'hasDateTime': true,
      };

      final category = Category.fromJson(json);

      expect(category.id, equals(10));
      expect(category.parentId, equals(1));
      expect(category.categoryName, equals('Accidente de tránsito'));
    });

    test('constructor generates random color', () {
      final category1 = Category(
        id: 1,
        categoryName: 'Test',
        hasVictim: false,
        hasDateTime: false,
      );

      final category2 = Category(
        id: 2,
        categoryName: 'Test 2',
        hasVictim: false,
        hasDateTime: false,
      );

      // Colors should be generated (not null)
      expect(category1.color, isNotNull);
      expect(category2.color, isNotNull);
      // Colors are likely different (random)
      // Note: There's a small chance they could be the same
    });

    test('subcategories list is initially empty', () {
      final category = Category(
        id: 1,
        categoryName: 'Parent',
        hasVictim: true,
        hasDateTime: true,
      );

      expect(category.subcategories, isEmpty);
    });

    test('subcategories can be added', () {
      final parent = Category(
        id: 1,
        categoryName: 'Parent',
        hasVictim: true,
        hasDateTime: true,
      );

      final child = Category(
        id: 2,
        parentId: 1,
        categoryName: 'Child',
        hasVictim: true,
        hasDateTime: true,
      );

      parent.subcategories.add(child);

      expect(parent.subcategories.length, equals(1));
      expect(parent.subcategories.first.categoryName, equals('Child'));
    });
  });
}
