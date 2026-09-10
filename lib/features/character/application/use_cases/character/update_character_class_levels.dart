import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';

class UpdateCharacterClassLevels {
  UpdateCharacterClassLevels(this._repository);

  final CharacterRepository _repository;

  /// Atualiza os níveis de classe e, quando [dieSizeForClass] é informado,
  /// recalcula o PV máximo.
  ///
  /// Antes o PV ficava congelado no valor do nível 1: subir de nível não
  /// aumentava a vida do personagem.
  Future<void> call({
    required String characterId,
    required List<ClassLevel> classLevels,
    int Function(String classId)? dieSizeForClass,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    var updatedCharacter = character.copyWith(
      classLevels: classLevels,
      updatedAt: DateTime.now(),
    );

    if (dieSizeForClass != null) {
      final newMax = HitPointsCalculator.maxHitPoints(
        classLevels: classLevels,
        abilityScores: character.abilityScores,
        dieSizeForClass: dieSizeForClass,
      );

      final delta = newMax - character.hitPoints.maximum;

      // Ao ganhar nível o PV atual sobe junto; ao perder nível apenas
      // limitamos ao novo máximo.
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
