import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dano', () {
    test('desconta do PV atual', () {
      const hp = HitPoints(current: 20, maximum: 20);

      expect(hp.applyDamage(7).current, 13);
    });

    test('não deixa o PV ficar negativo', () {
      const hp = HitPoints(current: 5, maximum: 20);

      final damaged = hp.applyDamage(50);

      expect(damaged.current, 0);
      expect(damaged.maximum, 20);
    });

    test('PV temporário absorve primeiro', () {
      const hp = HitPoints(current: 20, maximum: 20, temporary: 8);

      final damaged = hp.applyDamage(5);

      expect(damaged.temporary, 3);
      expect(damaged.current, 20);
    });

    test('dano maior que o temporário transborda para o PV atual', () {
      const hp = HitPoints(current: 20, maximum: 20, temporary: 8);

      final damaged = hp.applyDamage(12);

      expect(damaged.temporary, 0);
      expect(damaged.current, 16);
    });

    test('dano igual ao temporário consome exatamente o temporário', () {
      const hp = HitPoints(current: 20, maximum: 20, temporary: 8);

      final damaged = hp.applyDamage(8);

      expect(damaged.temporary, 0);
      expect(damaged.current, 20);
    });

    test('dano negativo é tratado como zero', () {
      const hp = HitPoints(current: 10, maximum: 20, temporary: 3);

      final damaged = hp.applyDamage(-5);

      expect(damaged.current, 10);
      expect(damaged.temporary, 3);
    });
  });

  group('cura', () {
    test('soma ao PV atual', () {
      const hp = HitPoints(current: 10, maximum: 20);

      expect(hp.heal(5).current, 15);
    });

    test('não passa do máximo', () {
      const hp = HitPoints(current: 18, maximum: 20);

      expect(hp.heal(10).current, 20);
    });

    test('não mexe no PV temporário', () {
      const hp = HitPoints(current: 10, maximum: 20, temporary: 4);

      expect(hp.heal(5).temporary, 4);
    });

    test('cura negativa é tratada como zero', () {
      const hp = HitPoints(current: 10, maximum: 20);

      expect(hp.heal(-5).current, 10);
    });

    test('curar a partir de 0 funciona', () {
      const hp = HitPoints(current: 0, maximum: 20);

      expect(hp.heal(3).current, 3);
    });
  });
}
