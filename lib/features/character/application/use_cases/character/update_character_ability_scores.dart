import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_requirements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';

class UpdateCharacterAbilityScores {
  UpdateCharacterAbilityScores(this._repository);

  final CharacterRepository _repository;

  /// Atualiza os atributos e, quando [dieSizeForClass] é informado,
  /// recalcula o PV máximo.
  ///
  /// Em 5e o modificador de Constituição entra em CADA nível, então mudar a
  /// Constituição altera o PV máximo retroativamente. Antes o PV ficava
  /// congelado no valor antigo.
  ///
  /// Devolve o que precisa ser avisado ao jogador: quando a Força cai abaixo do
  /// requisito da armadura equipada, ela é desequipada e a CA recalculada na
  /// MESMA gravação — duas gravações separadas deixariam a ficha mostrando a CA
  /// da armadura que já não está sendo usada.
  Future<AbilityScoreUpdateOutcome> call({
    required String characterId,
    required AbilityScores abilityScores,
    int Function(String classId)? dieSizeForClass,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    var updatedCharacter = character.copyWith(
      abilityScores: abilityScores,
      // Uma edição livre dos totais não permite reconstruir com segurança
      // a distribuição original. Remover os metadados evita persistir uma
      // decomposição base/origem que já não corresponde aos valores atuais.
      abilityScoreAllocation: null,
      updatedAt: DateTime.now(),
    );

    if (dieSizeForClass != null) {
      final newMax = HitPointsCalculator.maxHitPoints(
        classLevels: character.classLevels,
        abilityScores: abilityScores,
        dieSizeForClass: dieSizeForClass,
      );

      final delta = newMax - character.hitPoints.maximum;

      // Ganhar Constituição aumenta o PV atual junto; perder apenas limita
      // ao novo máximo, sem "curar" o personagem.
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

    // Requisito de armadura: a Destreza também importa aqui, porque a CA
    // precisa ser recalculada quando ela muda, não só quando a Força muda.
    final armor = ArmorRequirements.apply(updatedCharacter);
    updatedCharacter = armor.character;

    await _repository.update(updatedCharacter);

    return AbilityScoreUpdateOutcome(
      unequippedArmorNotice: armor.notice,
      armorClass: updatedCharacter.combatStats.armorClass,
    );
  }
}

/// O que a tela precisa contar ao jogador depois de mudar os atributos.
class AbilityScoreUpdateOutcome {
  const AbilityScoreUpdateOutcome({
    this.unequippedArmorNotice,
    required this.armorClass,
  });

  /// Aviso pronto quando alguma armadura foi desequipada por falta de Força.
  /// Nulo quando nada mudou.
  final String? unequippedArmorNotice;

  /// A CA depois do recálculo.
  final int armorClass;

  bool get needsPlayerAttention => unequippedArmorNotice != null;
}
