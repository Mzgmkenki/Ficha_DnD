import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/combat_panel_summary.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

/// O resumo que o botão da ficha e os indicadores das abas compartilham.
///
/// Existe um único objeto de propósito: se a ficha contasse de um jeito e a aba
/// de outro, o jogador veria "2 ativas" no botão e três chips marcados dentro.
void main() {
  group('condições', () {
    test('ficha limpa não tem nada a avisar', () {
      final summary = CombatPanelSummary.of(characterFixture());

      expect(summary.hasActiveConditions, isFalse);
      expect(summary.conditionsLabel, isNull);
      expect(summary.badgeLabel, isNull);
      expect(summary.needsAttention, isFalse);
    });

    test('conta as condições marcadas', () {
      final summary = CombatPanelSummary.of(
        characterFixture(
          conditions: const {Condition.poisoned, Condition.prone},
        ),
      );

      expect(summary.activeConditions, 2);
      expect(summary.conditionsLabel, '2 condições ativas');
      expect(summary.conditionBadgeCount, 2);
      expect(summary.badgeLabel, '2 ativas');
    });

    test('uma condição fica no singular', () {
      final summary = CombatPanelSummary.of(
        characterFixture(conditions: const {Condition.poisoned}),
      );

      expect(summary.conditionsLabel, '1 condição ativa');
      expect(summary.badgeLabel, '1 ativa');
    });

    test('não conta a condição implicada pelas regras', () {
      // Paralisado arrasta Incapacitado na leitura, mas o jogador marcou uma.
      // Contar duas inflaria o indicador sem o jogador ter feito nada.
      final summary = CombatPanelSummary.of(
        characterFixture(conditions: const {Condition.paralyzed}),
      );

      expect(summary.activeConditions, 1);
      expect(summary.conditionBadgeCount, 1);
    });

    test('exaustão conta como uma marca, mesmo sem condição marcada', () {
      final summary = CombatPanelSummary.of(characterFixture(exhaustion: 2));

      expect(summary.activeConditions, 0);
      expect(summary.hasActiveConditions, isTrue);
      expect(summary.conditionsLabel, 'exaustão nível 2');
      expect(summary.conditionBadgeCount, 1);
    });

    test('condição e exaustão aparecem juntas', () {
      final summary = CombatPanelSummary.of(
        characterFixture(
          conditions: const {Condition.blinded},
          exhaustion: 1,
        ),
      );

      expect(summary.conditionsLabel, '1 condição ativa • exaustão nível 1');
      expect(summary.conditionBadgeCount, 2);
    });
  });

  group('recursos', () {
    test('nada gasto não avisa', () {
      final summary = CombatPanelSummary.of(characterFixture());

      expect(summary.hasSpentResources, isFalse);
      expect(summary.resourcesLabel, isNull);
    });

    test('dado de vida gasto entra na contagem', () {
      final summary = CombatPanelSummary.of(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
          hitDiceUsed: 2,
        ),
      );

      expect(summary.hitDiceTotal, 3);
      expect(summary.hitDiceUsed, 2);
      expect(summary.hitDiceAvailable, 1);
      expect(summary.resourcesLabel, '2 dados de vida gastos');
      expect(summary.badgeLabel, 'Gasto');
    });

    test('um dado gasto fica no singular', () {
      final summary = CombatPanelSummary.of(
        characterFixture(hitDiceUsed: 1),
      );

      expect(summary.resourcesLabel, '1 dado de vida gasto');
    });

    test('condição ativa tem prioridade sobre recurso gasto no indicador', () {
      // Os dois cabem na linha de resumo, mas o indicador é um só: condição
      // muda o que o personagem consegue fazer, dado de vida não.
      final summary = CombatPanelSummary.of(
        characterFixture(
          conditions: const {Condition.stunned},
          hitDiceUsed: 1,
        ),
      );

      expect(summary.badgeLabel, '1 ativa');
    });
  });

  group('linha compacta da ficha', () {
    test('sem nada notável, diz isso em vez de ficar vazia', () {
      final summary = CombatPanelSummary.of(characterFixture());

      expect(summary.compactLine, 'Sem condições ativas • recursos completos');
    });

    test('junta condições e recursos', () {
      final summary = CombatPanelSummary.of(
        characterFixture(
          conditions: const {Condition.poisoned, Condition.prone},
          hitDiceUsed: 1,
        ),
      );

      expect(
        summary.compactLine,
        '2 condições ativas • 1 dado de vida gasto',
      );
    });

    test('inspiração entra na linha', () {
      final summary = CombatPanelSummary.of(
        characterFixture().copyWith(inspiration: true),
      );

      expect(summary.compactLine, 'com inspiração');
      expect(summary.inspiration, isTrue);
    });
  });
}
