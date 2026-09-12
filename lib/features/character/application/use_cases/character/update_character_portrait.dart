import 'package:dnd_ficha_app/core/storage/portrait_storage.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';

/// Define ou remove a imagem de aparência do personagem.
class UpdateCharacterPortrait {
  UpdateCharacterPortrait(this._repository, this._storage);

  final CharacterRepository _repository;
  final PortraitStorage _storage;

  /// Abre o gerenciador de arquivos, guarda a cópia e salva o caminho.
  ///
  /// Retorna `false` se o jogador cancelar a escolha, para a UI não mostrar
  /// mensagem de sucesso sem nada ter mudado.
  Future<bool> pick({required String characterId}) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final newPath = await _storage.pickAndSave(characterId: characterId);
    if (newPath == null) return false;

    final previousPath = character.portraitPath;

    await _repository.update(
      character.copyWith(
        portraitPath: newPath,
        updatedAt: DateTime.now(),
      ),
    );

    // Só apaga o antigo depois do banco já apontar para o novo: se o update
    // falhar, a ficha continua com um retrato que existe.
    if (previousPath != null && previousPath != newPath) {
      await _storage.delete(previousPath);
    }

    return true;
  }

  Future<void> remove({required String characterId}) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final previousPath = character.portraitPath;
    if (previousPath == null) return;

    await _repository.update(
      character.copyWith(
        portraitPath: null,
        updatedAt: DateTime.now(),
      ),
    );

    await _storage.delete(previousPath);
  }
}
