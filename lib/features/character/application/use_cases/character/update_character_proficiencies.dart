import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';

class UpdateCharacterProficiencies {
  UpdateCharacterProficiencies(this._repository);

  final CharacterRepository _repository;

  Future<void> call({
    required String characterId,
    required SavingThrowProficiencies savingThrowProficiencies,
    required SkillProficiencies skillProficiencies,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final updatedCharacter = character.copyWith(
      savingThrowProficiencies: savingThrowProficiencies,
      skillProficiencies: skillProficiencies,
      updatedAt: DateTime.now(),
    );

    await _repository.update(updatedCharacter);
  }
}