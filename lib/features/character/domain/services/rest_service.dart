import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';

/// Resultado de um descanso, pronto para ser persistido.
class RestOutcome {
  const RestOutcome({
    required this.character,
    required this.clearedSpellSlotLevels,
    required this.summary,
  });

  /// Personagem já com PV, exaustão e dados de vida atualizados.
  final Character character;

  /// Níveis de slot cujo uso deve ser zerado no banco.
  /// Vazio significa "nenhum"; `null` significa "todos".
  final List<int>? clearedSpellSlotLevels;

  /// Texto curto para mostrar ao usuário.
  final String summary;
}

/// Aplica as regras de descanso de D&D 5e.
class RestService {
  const RestService._();

  /// Descanso longo (PHB):
  /// - recupera todos os PV;
  /// - recupera metade dos dados de vida totais (mínimo 1);
  /// - recupera todos os espaços de magia (incluindo os de pacto);
  /// - reduz a exaustão em 1 nível;
  /// - PV temporários não sobrevivem ao descanso.
  static RestOutcome longRest({
    required Character character,
    required int totalHitDice,
  }) {
    final recovered =
        HitPointsCalculator.hitDiceRecoveredOnLongRest(totalHitDice);
    final remainingUsed = (character.hitDiceUsed - recovered).clamp(0, totalHitDice);

    final updated = character.copyWith(
      hitPoints: character.hitPoints.copyWith(
        current: character.hitPoints.maximum,
        temporary: 0,
      ),
      hitDiceUsed: remainingUsed,
      exhaustion: (character.exhaustion - 1).clamp(0, 6),
      updatedAt: DateTime.now(),
    );

    return RestOutcome(
      character: updated,
      clearedSpellSlotLevels: null, // todos
      summary: 'Descanso longo: PV restaurados, espaços de magia renovados '
          'e $recovered dado(s) de vida recuperado(s).',
    );
  }

  /// Descanso curto (PHB): não recupera PV automaticamente (o jogador gasta
  /// dados de vida) nem espaços normais. O Bruxo recupera os espaços de pacto.
  static RestOutcome shortRest({
    required Character character,
    required List<int> pactSlotUsageKeys,
  }) {
    final hasPact = pactSlotUsageKeys.isNotEmpty;

    return RestOutcome(
      character: character.copyWith(updatedAt: DateTime.now()),
      clearedSpellSlotLevels: pactSlotUsageKeys,
      summary: hasPact
          ? 'Descanso curto: espaços de Magia de Pacto renovados. '
              'Gaste dados de vida para recuperar PV.'
          : 'Descanso curto: gaste dados de vida para recuperar PV.',
    );
  }

  /// Gasta um dado de vida, curando o valor rolado + modificador de CON.
  /// O valor da rolagem vem de fora para permitir rolagem manual ou aleatória.
  static Character spendHitDie({
    required Character character,
    required int rolled,
    required int constitutionModifier,
    required int totalHitDice,
  }) {
    if (character.hitDiceUsed >= totalHitDice) return character;

    final healed = rolled + constitutionModifier;
    final safeHeal = healed < 1 ? 1 : healed;

    return character.copyWith(
      hitPoints: character.hitPoints.heal(safeHeal),
      hitDiceUsed: character.hitDiceUsed + 1,
      updatedAt: DateTime.now(),
    );
  }
}
