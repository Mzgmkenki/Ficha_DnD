import 'package:dnd_ficha_app/features/character/data/mappers/character_json_codec.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';

/// Gera o JSON da ficha para o jogador levar para outro aparelho.
class ExportCharacter {
  ExportCharacter(this._repository);

  final CharacterRepository _repository;

  Future<String> call(String characterId) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    return CharacterJsonCodec.encode(character);
  }
}
