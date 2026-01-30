import 'package:flutter_test/flutter_test.dart';
import 'package:omus/services/models/vial_actor.dart';

void main() {
  group('VialActor', () {
    test('fromJson creates VialActor with all fields', () {
      final json = {
        'id': 1,
        'name': 'Peatón',
      };

      final actor = VialActor.fromJson(json);

      expect(actor.id, equals(1));
      expect(actor.name, equals('Peatón'));
    });

    test('fromJson handles null name', () {
      final json = {
        'id': 2,
        'name': null,
      };

      final actor = VialActor.fromJson(json);

      expect(actor.id, equals(2));
      expect(actor.name, isNull);
    });

    test('constructor creates VialActor correctly', () {
      final actor = VialActor(
        id: 3,
        name: 'Ciclista',
      );

      expect(actor.id, equals(3));
      expect(actor.name, equals('Ciclista'));
    });

    test('constructor allows null name', () {
      final actor = VialActor(id: 4);

      expect(actor.id, equals(4));
      expect(actor.name, isNull);
    });
  });
}
