import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';

class UpdateCharacterClassLevels {
  UpdateCharacterClassLevels(this._repository);

  final CharacterRepository _repository;

  Future<void> call({
    required String characterId,
    required List<ClassLevel> classLevels,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final updatedCharacter = character.copyWith(
      classLevels: classLevels,
      updatedAt: DateTime.now(),
    );

    await _repository.update(updatedCharacter);
  }
}