import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';

class UpdateCharacterAbilityScores {
  UpdateCharacterAbilityScores(this._repository);

  final CharacterRepository _repository;

  Future<void> call({
    required String characterId,
    required AbilityScores abilityScores,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final updatedCharacter = character.copyWith(
      abilityScores: abilityScores,
      updatedAt: DateTime.now(),
    );

    await _repository.update(updatedCharacter);
  }
}