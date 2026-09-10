import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
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
  Future<void> call({
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
      final newCurrent = delta > 0
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
