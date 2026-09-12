import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Erro previsível na escolha do retrato, com mensagem já pronta para o
/// jogador. Falhas inesperadas continuam subindo como exceção normal.
class PortraitException implements Exception {
  const PortraitException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Guarda a imagem de aparência do personagem no diretório do app.
///
/// O arquivo é copiado em vez de referenciado: o caminho que o gerenciador de
/// arquivos devolve aponta para o cache do sistema (no Android, uma cópia
/// temporária feita pelo SAF), que pode ser apagado a qualquer momento e
/// deixaria a ficha com um retrato quebrado.
class PortraitStorage {
  const PortraitStorage();

  /// Subpasta dentro do diretório de documentos do app.
  static const String folderName = 'portraits';

  /// Extensões que o Flutter consegue decodificar. O picker já filtra por
  /// imagem, mas um arquivo renomeado passaria pelo filtro e só falharia na
  /// hora de desenhar — melhor recusar aqui, com mensagem clara.
  static const List<String> allowedExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'bmp',
  ];

  /// Abre o gerenciador de arquivos e devolve o caminho da cópia guardada
  /// pelo app. Retorna `null` se o jogador cancelar.
  Future<String?> pickAndSave({required String characterId}) async {
    final FilePickerResult? result;

    try {
      // A partir do file_picker 11 a classe é `abstract final` com métodos
      // estáticos: o antigo `FilePicker.platform.pickFiles` não existe mais.
      result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        // Sem `withData`: carregar os bytes na memória não serve para nada
        // aqui, já que a cópia é feita direto de arquivo para arquivo.
        withData: false,
      );
    } on PlatformException catch (error) {
      throw PortraitException(
        'Não foi possível abrir o gerenciador de arquivos: ${error.message}',
      );
    }

    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.single;
    final sourcePath = picked.path;

    if (sourcePath == null) {
      throw const PortraitException(
        'O gerenciador de arquivos não devolveu um caminho para a imagem.',
      );
    }

    return save(
      characterId: characterId,
      sourcePath: sourcePath,
      extension: picked.extension,
    );
  }

  /// Copia [sourcePath] para o diretório do app e devolve o novo caminho.
  Future<String> save({
    required String characterId,
    required String sourcePath,
    String? extension,
  }) async {
    final source = File(sourcePath);

    if (!await source.exists()) {
      throw const PortraitException('A imagem escolhida não foi encontrada.');
    }

    final resolved = _resolveExtension(extension, sourcePath);

    if (!allowedExtensions.contains(resolved)) {
      final formats = allowedExtensions.join(', ');
      throw PortraitException(
        resolved.isEmpty
            ? 'Não foi possível identificar o formato da imagem. '
                'Use um arquivo $formats.'
            : 'Formato não suportado (.$resolved). Use $formats.',
      );
    }

    final directory = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, folderName),
    );
    await directory.create(recursive: true);

    // O timestamp no nome não é enfeite: o Flutter guarda imagens em cache
    // pelo caminho do arquivo, então reaproveitar o mesmo nome faria a ficha
    // continuar mostrando o retrato antigo depois da troca.
    final fileName = '${_sanitize(characterId)}_'
        '${DateTime.now().millisecondsSinceEpoch}.$resolved';

    final target = await source.copy(p.join(directory.path, fileName));
    return target.path;
  }

  /// Apaga o arquivo do retrato. Só age dentro da pasta do app, para um
  /// caminho vindo do banco nunca conseguir apagar um arquivo do jogador.
  Future<void> delete(String? portraitPath) async {
    if (portraitPath == null || portraitPath.isEmpty) return;

    if (p.basename(p.dirname(portraitPath)) != folderName) return;

    try {
      final file = File(portraitPath);
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (error) {
      // Não vale derrubar o fluxo por causa de um arquivo órfão: o retrato
      // novo já foi salvo e o banco já aponta para ele.
      debugPrint('Falha ao apagar o retrato antigo: $error');
    }
  }

  /// O caminho tem prioridade sobre o `extension` do picker porque lá o
  /// getter é só `name.split('.').last`: num arquivo sem ponto ele devolve o
  /// nome inteiro, o que viraria uma extensão absurda.
  String _resolveExtension(String? extension, String sourcePath) {
    // `p.extension` devolve com ponto ('.png'), daí o replaceFirst.
    final fromPath =
        p.extension(sourcePath).replaceFirst('.', '').toLowerCase();
    if (fromPath.isNotEmpty) return fromPath;

    final fromPicker = extension?.trim().toLowerCase() ?? '';
    return allowedExtensions.contains(fromPicker) ? fromPicker : '';
  }

  /// Ids são UUIDs, mas um id inesperado com barra ou '..' viraria caminho.
  String _sanitize(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
    return cleaned.isEmpty ? 'portrait' : cleaned;
  }
}
