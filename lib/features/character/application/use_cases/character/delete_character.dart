import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';

class DeleteCharacter {
  DeleteCharacter(this._repository);

  final CharacterRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
