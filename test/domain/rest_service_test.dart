import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/services/rest_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

void main() {
  group('descanso longo', () {
    test('restaura todos os PV e zera os temporários', () {
      final character = characterFixture(
        hitPoints: const HitPoints(current: 12, maximum: 40, temporary: 7),
      );

      final outcome = RestService.longRest(
        character: character,
        totalHitDice: 8,
      );

      expect(outcome.character.hitPoints.current, 40);
      expect(outcome.character.hitPoints.maximum, 40);
      expect(outcome.character.hitPoints.temporary, 0);
    });

    test('devolve metade dos dados de vida', () {
      final character = characterFixture(hitDiceUsed: 8);

      final outcome = RestService.longRest(
        character: character,
        totalHitDice: 8,
      );

      // Metade de 8 = 4 recuperados, sobram 4 gastos.
      expect(outcome.character.hitDiceUsed, 4);
      expect(outcome.summary, contains('4 dado(s)'));
    });

    test('não deixa os dados gastos ficarem negativos', () {
      final character = characterFixture(hitDiceUsed: 1);

      final outcome = RestService.longRest(
        character: character,
        totalHitDice: 8,
      );

      expect(outcome.character.hitDiceUsed, 0);
    });

    test('reduz a exaustão em um nível', () {
      final outcome = RestService.longRest(
        character: characterFixture(exhaustion: 3),
        totalHitDice: 4,
      );

      expect(outcome.character.exhaustion, 2);
    });

    test('exaustão zero não vira negativa', () {
      final outcome = RestService.longRest(
        character: characterFixture(),
        totalHitDice: 4,
      );

      expect(outcome.character.exhaustion, 0);
    });

    test('marca todos os espaços de magia para renovar', () {
      final outcome = RestService.longRest(
        character: characterFixture(),
        totalHitDice: 4,
      );

      // null significa "todos os níveis".
      expect(outcome.clearedSpellSlotLevels, isNull);
    });
  });

  group('descanso curto', () {
    test('não mexe em PV nem em dados de vida', () {
      final character = characterFixture(
        hitPoints: const HitPoints(current: 5, maximum: 30),
        hitDiceUsed: 2,
      );

      final outcome = RestService.shortRest(
        character: character,
        pactSlotUsageKeys: const [],
      );

      expect(outcome.character.hitPoints.current, 5);
      expect(outcome.character.hitDiceUsed, 2);
      expect(outcome.clearedSpellSlotLevels, isEmpty);
      expect(outcome.summary, contains('gaste dados de vida'));
    });

    test('renova os espaços de pacto do Bruxo quando informados', () {
      final outcome = RestService.shortRest(
        character: characterFixture(),
        pactSlotUsageKeys: const [101, 102],
      );

      expect(outcome.clearedSpellSlotLevels, [101, 102]);
      expect(outcome.summary, contains('Magia de Pacto'));
    });

    test('não reduz exaustão', () {
      final outcome = RestService.shortRest(
        character: characterFixture(exhaustion: 2),
        pactSlotUsageKeys: const [],
      );

      expect(outcome.character.exhaustion, 2);
    });
  });

  group('gastar dado de vida', () {
    test('cura o rolado mais o modificador de CON', () {
      final character = characterFixture(
        hitPoints: const HitPoints(current: 10, maximum: 40),
      );

      final updated = RestService.spendHitDie(
        character: character,
        rolled: 6,
        constitutionModifier: 2,
        totalHitDice: 5,
      );

      expect(updated.hitPoints.current, 18);
      expect(updated.hitDiceUsed, 1);
    });

    test('cura no mínimo 1 PV mesmo com CON muito negativa', () {
      final character = characterFixture(
        hitPoints: const HitPoints(current: 10, maximum: 40),
      );

      final updated = RestService.spendHitDie(
        character: character,
        rolled: 1,
        constitutionModifier: -5,
        totalHitDice: 5,
      );

      expect(updated.hitPoints.current, 11);
    });

    test('não passa do PV máximo', () {
      final character = characterFixture(
        hitPoints: const HitPoints(current: 38, maximum: 40),
      );

      final updated = RestService.spendHitDie(
        character: character,
        rolled: 10,
        constitutionModifier: 3,
        totalHitDice: 5,
      );

      expect(updated.hitPoints.current, 40);
    });

    test('sem dados de vida sobrando, nada acontece', () {
      final character = characterFixture(
        hitPoints: const HitPoints(current: 10, maximum: 40),
        hitDiceUsed: 5,
      );

      final updated = RestService.spendHitDie(
        character: character,
        rolled: 8,
        constitutionModifier: 2,
        totalHitDice: 5,
      );

      expect(updated.hitPoints.current, 10);
      expect(updated.hitDiceUsed, 5);
    });
  });
}
