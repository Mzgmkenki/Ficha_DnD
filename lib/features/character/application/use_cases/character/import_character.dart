import 'package:dnd_ficha_app/features/character/data/mappers/character_json_codec.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';

/// Lê uma ficha exportada e grava como personagem novo.
///
/// Sempre cria em vez de sobrescrever: um id repetido no arquivo não pode
/// apagar o personagem que já está no aparelho.
class ImportCharacter {
  ImportCharacter(this._repository);

  final CharacterRepository _repository;

  Future<Character> call(String json) async {
    final character = CharacterJsonCodec.decode(
      json,
      newId: DateTime.now().microsecondsSinceEpoch.toString(),
    );

    await _repository.create(character);
    return character;
  }
}
