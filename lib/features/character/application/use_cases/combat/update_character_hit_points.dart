import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';

class UpdateCharacterHitPoints {
  UpdateCharacterHitPoints(this._repository);

  final CharacterRepository _repository;

  Future<void> call({
    required String characterId,
    required HitPoints hitPoints,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final updatedCharacter = character.copyWith(
      hitPoints: hitPoints,
      updatedAt: DateTime.now(),
    );

    await _repository.update(updatedCharacter);
  }
}