import 'package:dnd_ficha_app/core/utils/dice_roller.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/death_saves.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/services/death_save_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda as regras do teste contra a morte (5e, Livro do Jogador 2014).
///
/// O que não pode escapar: `1` natural vale duas falhas, `20` natural devolve 1
/// PV, o teste nunca leva modificador, e recuperar PV encerra a sequência.
void main() {
  /// Um d20 já rolado, para o serviço não depender de sorte.
  DiceRollResult d20(int value) {
    return DiceRollResult(
      rolls: [value],
      keptValue: value,
      sides: 20,
      modifier: 0,
      mode: RollMode.normal,
      label: 'Teste contra a morte',
    );
  }

  group('marcadores', () {
    test('começam zerados', () {
      const saves = DeathSaves();

      expect(saves.successes, 0);
      expect(saves.failures, 0);
      expect(saves.isEmpty, isTrue);
      expect(saves.isStable, isFalse);
      expect(saves.isDead, isFalse);
    });

    test('marcar e desmarcar sucesso', () {
      var saves = const DeathSaves();

      saves = saves.withSuccess();
      expect(saves.successes, 1);

      saves = saves.withSuccess();
      expect(saves.successes, 2);

      saves = saves.withoutSuccess();
      expect(saves.successes, 1);
    });

    test('marcar e desmarcar falha', () {
      var saves = const DeathSaves();

      saves = saves.withFailure();
      expect(saves.failures, 1);

      saves = saves.withFailure();
      expect(saves.failures, 2);

      saves = saves.withoutFailure();
      expect(saves.failures, 1);
    });

    test('não passam de três de cada lado', () {
      var saves = const DeathSaves();

      for (var i = 0; i < 6; i++) {
        saves = saves.withSuccess().withFailure();
      }

      expect(saves.successes, DeathSaves.maxMarks);
      expect(saves.failures, DeathSaves.maxMarks);
    });

    test('não descem abaixo de zero', () {
      const saves = DeathSaves();

      expect(saves.withoutSuccess().successes, 0);
      expect(saves.withoutFailure().failures, 0);
    });

    test('três sucessos estabilizam', () {
      const saves = DeathSaves(successes: 3);

      expect(saves.isStable, isTrue);
      expect(saves.isDead, isFalse);
      expect(saves.isResolved, isTrue);
    });

    test('três falhas matam', () {
      const saves = DeathSaves(failures: 3);

      expect(saves.isDead, isTrue);
      expect(saves.isStable, isFalse);
      expect(saves.isResolved, isTrue);
    });

    test('os dois lados convivem sem se cancelar', () {
      // A regra não anula sucesso com falha: as duas contagens correm juntas.
      const saves = DeathSaves(successes: 2, failures: 2);

      expect(saves.successes, 2);
      expect(saves.failures, 2);
      expect(saves.isResolved, isFalse);
    });

    test('limpar zera os dois lados', () {
      const saves = DeathSaves(successes: 2, failures: 1);

      expect(saves.cleared(), const DeathSaves());
    });

    test('descreve a contagem em português', () {
      expect(const DeathSaves().describe(), 'Nenhum teste registrado');
      expect(const DeathSaves(successes: 1).describe(), '1 sucesso');
      expect(const DeathSaves(successes: 2).describe(), '2 sucessos');
      expect(const DeathSaves(failures: 1).describe(), '1 falha');
      expect(
        const DeathSaves(successes: 2, failures: 1).describe(),
        '2 sucessos e 1 falha',
      );
    });
  });

  group('faixas do dado', () {
    test('1 natural conta como duas falhas', () {
      final outcome = DeathSaveService.applyRoll(
        current: const DeathSaves(),
        roll: d20(1),
      );

      expect(outcome.saves.failures, 2);
      expect(outcome.saves.successes, 0);
      expect(outcome.regainsHitPoint, isFalse);
      expect(outcome.summary, contains('duas falhas'));
    });

    test('1 natural com uma falha já registrada mata', () {
      final outcome = DeathSaveService.applyRoll(
        current: const DeathSaves(failures: 1),
        roll: d20(1),
      );

      expect(outcome.saves.failures, 3);
      expect(outcome.saves.isDead, isTrue);
      expect(outcome.summary, contains('morreu'));
    });

    test('de 2 a 9 é uma falha', () {
      for (var value = 2; value <= 9; value++) {
        final outcome = DeathSaveService.applyRoll(
          current: const DeathSaves(),
          roll: d20(value),
        );

        expect(outcome.saves.failures, 1, reason: 'dado $value');
        expect(outcome.saves.successes, 0, reason: 'dado $value');
      }
    });

    test('de 10 a 19 é um sucesso', () {
      for (var value = 10; value <= 19; value++) {
        final outcome = DeathSaveService.applyRoll(
          current: const DeathSaves(),
          roll: d20(value),
        );

        expect(outcome.saves.successes, 1, reason: 'dado $value');
        expect(outcome.saves.failures, 0, reason: 'dado $value');
      }
    });

    test('20 natural devolve 1 PV e zera os marcadores', () {
      final outcome = DeathSaveService.applyRoll(
        current: const DeathSaves(successes: 1, failures: 2),
        roll: d20(20),
      );

      expect(outcome.regainsHitPoint, isTrue);
      expect(outcome.saves, const DeathSaves());
      expect(outcome.summary, contains('1 ponto de vida'));
    });

    test('terceiro sucesso avisa que estabilizou', () {
      final outcome = DeathSaveService.applyRoll(
        current: const DeathSaves(successes: 2),
        roll: d20(15),
      );

      expect(outcome.saves.isStable, isTrue);
      expect(outcome.summary, contains('estável'));
    });

    test('o limiar de sucesso é 10', () {
      expect(DeathSaveService.successThreshold, 10);

      final falha = DeathSaveService.applyRoll(
        current: const DeathSaves(),
        roll: d20(9),
      );
      final sucesso = DeathSaveService.applyRoll(
        current: const DeathSaves(),
        roll: d20(10),
      );

      expect(falha.saves.failures, 1);
      expect(sucesso.saves.successes, 1);
    });

    test('o modificador do dado não é somado ao teste', () {
      // Um resultado 9 com +5 de modificador continua sendo falha: o teste
      // contra a morte olha o dado, não o total.
      const roll = DiceRollResult(
        rolls: [9],
        keptValue: 9,
        sides: 20,
        modifier: 5,
        mode: RollMode.normal,
      );

      final outcome = DeathSaveService.applyRoll(
        current: const DeathSaves(),
        roll: roll,
      );

      expect(outcome.saves.failures, 1);
      expect(outcome.saves.successes, 0);
    });
  });

  group('mudança de pontos de vida', () {
    test('recuperar PV encerra a sequência', () {
      final cleared = DeathSaveService.onHitPointsChanged(
        current: const DeathSaves(successes: 1, failures: 2),
        before: const HitPoints(current: 0, maximum: 20),
        after: const HitPoints(current: 4, maximum: 20),
      );

      expect(cleared, const DeathSaves());
    });

    test('cair a zero NÃO apaga o que já estava marcado', () {
      // Quem cai a 0 PV começa a rolar; zerar aqui apagaria os marcadores de um
      // desmaio anterior no mesmo combate sem regra nenhuma mandando.
      final result = DeathSaveService.onHitPointsChanged(
        current: const DeathSaves(failures: 1),
        before: const HitPoints(current: 5, maximum: 20),
        after: const HitPoints(current: 0, maximum: 20),
      );

      expect(result, isNull);
    });

    test('continuar a zero não muda nada', () {
      final result = DeathSaveService.onHitPointsChanged(
        current: const DeathSaves(failures: 2),
        before: const HitPoints(current: 0, maximum: 20),
        after: const HitPoints(current: 0, maximum: 20),
      );

      expect(result, isNull);
    });

    test('sem marcadores não há o que limpar', () {
      // Devolve nulo para quem chama não gravar o personagem sem motivo.
      final result = DeathSaveService.onHitPointsChanged(
        current: const DeathSaves(),
        before: const HitPoints(current: 0, maximum: 20),
        after: const HitPoints(current: 8, maximum: 20),
      );

      expect(result, isNull);
    });
  });
}
