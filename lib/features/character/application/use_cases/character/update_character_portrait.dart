import 'dart:typed_data';

import 'package:dnd_ficha_app/core/storage/portrait_storage.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';

/// Define ou remove a imagem de aparência do personagem.
class UpdateCharacterPortrait {
  UpdateCharacterPortrait(this._repository, this._storage);

  final CharacterRepository _repository;
  final PortraitStorage _storage;

  /// Persiste o recorte confirmado e troca o caminho no personagem.
  ///
  /// A escolha e o editor ficam na apresentação porque podem ser cancelados.
  /// Este caso de uso recebe apenas o resultado confirmado; se salvar ou
  /// atualizar o banco falhar, o retrato anterior continua intacto.
  Future<void> replace({
    required String characterId,
    required Uint8List croppedBytes,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final optimized = await _storage.optimizeCropped(croppedBytes);
    final newPath = await _storage.saveCropped(
      characterId: characterId,
      bytes: optimized,
    );

    final previousPath = character.portraitPath;

    try {
      await _repository.update(
        character.copyWith(portraitPath: newPath, updatedAt: DateTime.now()),
      );
    } catch (_) {
      await _storage.delete(newPath);
      rethrow;
    }

    // Só apaga o antigo depois do banco já apontar para o novo: se o update
    // falhar, a ficha continua com um retrato que existe.
    if (previousPath != null && previousPath != newPath) {
      await _storage.delete(previousPath);
    }
  }

  Future<void> remove({required String characterId}) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final previousPath = character.portraitPath;
    if (previousPath == null) return;

    await _repository.update(
      character.copyWith(portraitPath: null, updatedAt: DateTime.now()),
    );

    await _storage.delete(previousPath);
  }
}
