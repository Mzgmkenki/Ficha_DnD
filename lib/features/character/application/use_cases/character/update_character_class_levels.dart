import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_ability_bonuses.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/level_progression_reversal.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// O que as características concedem de aumento e de teto de atributo para um
/// personagem com os níveis já atualizados.
///
/// Função, e não mapa pronto, porque a resposta depende dos níveis NOVOS: quem
/// chama precisa resolver o compêndio contra o personagem hipotético, e só a
/// camada de aplicação tem acesso ao compêndio.
typedef AbilityBonusResolver =
    ({Map<Ability, int> granted, Map<Ability, int> maximums}) Function(
      Character character,
    );

/// Os ids das vagas de progressão que o personagem com os níveis NOVOS ainda
/// concede.
///
/// Função pelo mesmo motivo de [AbilityBonusResolver]: quais níveis dão a
/// escolha é dado de compêndio, e este caso de uso não o alcança.
typedef ProgressionSlotResolver = Set<String> Function(Character character);

class UpdateCharacterClassLevels {
  UpdateCharacterClassLevels(this._repository);

  final CharacterRepository _repository;

  /// Atualiza os níveis de classe e, quando [dieSizeForClass] é informado,
  /// recalcula o PV máximo.
  ///
  /// Antes o PV ficava congelado no valor do nível 1: subir de nível não
  /// aumentava a vida do personagem.
  ///
  /// [abilityBonuses] reconcilia os aumentos permanentes de atributo que as
  /// características concedem — o Campeão Primal do 20º nível de Bárbaro. Fica
  /// opcional para quem só quer mexer no nível não precisar carregar o
  /// compêndio, e a reconciliação ao abrir a ficha cobre esse caso.
  ///
  /// [progressionSlots] desfaz o Incremento no Valor de Atributo de uma vaga
  /// que a mudança de nível apagou. Opcional pelo mesmo motivo, e a ficha
  /// continua coerente sem ele — só com um incremento órfão a mais.
  ///
  /// A ordem importa: o atributo é reconciliado ANTES do PV, porque o PV
  /// depende de Constituição. Chegar ao 20º nível de Bárbaro sobe a
  /// Constituição em 4, e isso vale 2 pontos de vida por nível. Pelo mesmo
  /// motivo a devolução dos incrementos órfãos vem antes de tudo: ela pode
  /// DERRUBAR a Constituição, e o PV novo tem de considerar isso.
  Future<void> call({
    required String characterId,
    required List<ClassLevel> classLevels,
    int Function(String classId)? dieSizeForClass,
    AbilityBonusResolver? abilityBonuses,
    ProgressionSlotResolver? progressionSlots,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    var updatedCharacter = character.copyWith(
      classLevels: classLevels,
      updatedAt: DateTime.now(),
    );

    if (progressionSlots != null) {
      updatedCharacter = LevelProgressionReversal.revokeOrphans(
        character: updatedCharacter,
        validProgressionIds: progressionSlots(updatedCharacter),
      );
    }

    if (abilityBonuses != null) {
      final resolved = abilityBonuses(updatedCharacter);
      updatedCharacter = FeatureAbilityBonuses.reconcile(
        character: updatedCharacter,
        granted: resolved.granted,
        maximums: resolved.maximums,
      );
    }

    if (dieSizeForClass != null) {
      final newMax = HitPointsCalculator.maxHitPoints(
        classLevels: classLevels,
        abilityScores: updatedCharacter.abilityScores,
        dieSizeForClass: dieSizeForClass,
      );

      final delta = newMax - character.hitPoints.maximum;

      // Ao ganhar nível o PV atual sobe junto; ao perder nível apenas
      // limitamos ao novo máximo.
      final newCurrent =
          delta > 0
              ? character.hitPoints.current + delta
              : character.hitPoints.current;

      updatedCharacter = updatedCharacter.copyWith(
        hitPoints: character.hitPoints.copyWith(
          maximum: newMax,
          current: newCurrent.clamp(0, newMax),
        ),
      );
    }

    await _repository.update(updatedCharacter);
  }
}
