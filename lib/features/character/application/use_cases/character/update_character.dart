import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';

class UpdateCharacter {
  UpdateCharacter(this._repository);

  final CharacterRepository _repository;

  Future<void> call(Character character) => _repository.update(character);
}
