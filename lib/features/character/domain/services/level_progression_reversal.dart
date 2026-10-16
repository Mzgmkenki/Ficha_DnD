import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/level_progression_choices.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';

/// Desfaz os Incrementos no Valor de Atributo cujas vagas deixaram de existir.
///
/// Por que é necessário: perder nível é o único caminho que APAGA uma vaga de
/// progressão. Um Guerreiro 4 que volta para o 3º nível não tem mais a vaga do
/// 4º, e o incremento gravado nela ficava órfão — fora da ficha, porque não há
/// vaga para exibi-lo, mas com os pontos ainda somados nos atributos. Força
/// inflada em silêncio contamina CA, PV, ataque e testes.
///
/// Devolve os pontos pelo registro, e não por recálculo: cada incremento
/// guarda exatamente o que aplicou, então a devolução é a operação inversa
/// mesmo quando o atributo bateu no teto e o incremento rendeu menos do que
/// pediu.
///
/// Talento não entra aqui de propósito. Removê-lo levaria embora proficiências
/// que o jogador pode ter conquistado em mesa, e perder nível costuma ser
/// correção de digitação — destruir dado para consertar um toque errado é pior
/// que mostrar o talento numa vaga mais antiga, que é o que
/// [LevelProgressionChoices] já faz.
class LevelProgressionReversal {
  const LevelProgressionReversal._();

  /// Os ids das vagas de progressão que [character] ainda concede.
  ///
  /// Vem do compêndio, via `ClassEntry.featLevels`: nenhuma lista fixa de
  /// níveis mora aqui, então mudar os níveis de uma classe no asset muda isto
  /// junto.
  static Set<String> validIdsFor(
    Character character,
    List<ClassEntry> classes,
  ) {
    return {
      for (final slot in LevelProgressionChoices.forCharacter(
        character,
        classes,
      ))
        if (!slot.fromRace) slot.progressionId,
    };
  }

  /// Tira os incrementos fora de [validProgressionIds] e devolve os pontos.
  ///
  /// Idempotente: chamar duas vezes com o mesmo conjunto não muda nada na
  /// segunda. Devolve o MESMO objeto quando não há órfão, e quem chama usa
  /// `identical` para não gravar à toa — igual à reconciliação dos aumentos de
  /// característica.
  static Character revokeOrphans({
    required Character character,
    required Set<String> validProgressionIds,
  }) {
    final orphans = character.abilityImprovements
        .where((item) => !validProgressionIds.contains(item.progressionId))
        .toList(growable: false);

    if (orphans.isEmpty) return character;

    var scores = character.abilityScores;
    for (final orphan in orphans) {
      scores = AbilityScoreImprovements.revoke(scores, orphan.appliedIncreases);
    }

    return character.copyWith(
      abilityImprovements: character.abilityImprovements
          .where((item) => validProgressionIds.contains(item.progressionId))
          .toList(growable: false),
      abilityScores: scores,
    );
  }
}
