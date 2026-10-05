import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Arquivo escolhido pelo jogador, antes de ser copiado para o app.
class PickedImage {
  const PickedImage({required this.path, this.extension});

  /// Caminho de origem. É temporário: no Android o SAF entrega uma cópia no
  /// cache, que o sistema pode apagar.
  final String path;

  final String? extension;
}

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

  /// Limites equilibrados para zoom fluido e impressão nítida. O recorte
  /// final de 1600 x 1200 ainda passa de 300 dpi na moldura usada no PDF.
  static const int maxSourceBytes = 25 * 1024 * 1024;
  static const int editorMaxDimension = 2400;
  static const int savedWidth = 1600;
  static const int savedHeight = 1200;

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

  /// Abre o gerenciador de arquivos e devolve a cópia já guardada pelo app.
  /// Retorna `null` se o jogador cancelar.
  Future<String?> pickAndSave({required String characterId}) async {
    final picked = await pick();
    if (picked == null) return null;

    return save(
      characterId: characterId,
      sourcePath: picked.path,
      extension: picked.extension,
    );
  }

  /// Só escolhe o arquivo, sem copiar.
  ///
  /// Existe separado por causa da criação de personagem: lá o jogador escolhe
  /// a imagem antes do personagem ter id, e a cópia só pode ser feita na hora
  /// de salvar.
  Future<PickedImage?> pick() async {
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

    return PickedImage(path: sourcePath, extension: picked.extension);
  }

  /// Lê, valida e normaliza uma imagem antes de abrir o editor.
  ///
  /// A orientação EXIF é incorporada aos pixels e imagens enormes são
  /// reduzidas fora da isolate da interface. Assim o enquadramento visto no
  /// editor é exatamente o que será salvo e usado no PDF.
  Future<Uint8List> prepareForCropping(PickedImage picked) async {
    final source = File(picked.path);
    if (!await source.exists()) {
      throw const PortraitException('A imagem escolhida não foi encontrada.');
    }

    final resolved = _resolveExtension(picked.extension, picked.path);
    if (!allowedExtensions.contains(resolved)) {
      final formats = allowedExtensions.join(', ');
      throw PortraitException(
        resolved.isEmpty
            ? 'Não foi possível identificar o formato da imagem. Use $formats.'
            : 'Formato não suportado (.$resolved). Use $formats.',
      );
    }

    if (await source.length() > maxSourceBytes) {
      throw const PortraitException(
        'A imagem é muito grande. Escolha um arquivo de até 25 MB.',
      );
    }

    final bytes = await source.readAsBytes();
    try {
      return await compute(_preparePortraitBytes, bytes);
    } on PortraitException {
      rethrow;
    } catch (_) {
      throw const PortraitException(
        'Não foi possível ler a imagem. Escolha outro arquivo.',
      );
    }
  }

  /// Comprime o recorte confirmado para uma resolução suficiente para o
  /// PDF sem guardar fotos de vários megapixels no diretório do app.
  Future<Uint8List> optimizeCropped(Uint8List bytes) async {
    try {
      return await compute(_optimizeCroppedBytes, bytes);
    } catch (_) {
      throw const PortraitException(
        'Não foi possível processar o recorte da imagem.',
      );
    }
  }

  /// Salva bytes já recortados. O arquivo anterior só será apagado pelo
  /// caso de uso depois que o banco apontar com sucesso para este novo caminho.
  Future<String> saveCropped({
    required String characterId,
    required Uint8List bytes,
  }) async {
    final directory = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, folderName),
    );
    await directory.create(recursive: true);

    final fileName =
        '${_sanitize(characterId)}_'
        '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final target = File(p.join(directory.path, fileName));
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
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
    final fileName =
        '${_sanitize(characterId)}_'
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

Uint8List _preparePortraitBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const PortraitException(
      'O arquivo escolhido não é uma imagem válida.',
    );
  }

  var prepared = img.bakeOrientation(decoded);
  final longest =
      prepared.width > prepared.height ? prepared.width : prepared.height;
  if (longest > PortraitStorage.editorMaxDimension) {
    final scale = PortraitStorage.editorMaxDimension / longest;
    prepared = img.copyResize(
      prepared,
      width: (prepared.width * scale).round(),
      height: (prepared.height * scale).round(),
      interpolation: img.Interpolation.average,
    );
  }

  return img.encodeJpg(prepared, quality: 92);
}

Uint8List _optimizeCroppedBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const PortraitException('O recorte gerado não é uma imagem válida.');
  }

  var result = decoded;
  if (result.width > PortraitStorage.savedWidth ||
      result.height > PortraitStorage.savedHeight) {
    result = img.copyResize(
      result,
      width: PortraitStorage.savedWidth,
      height: PortraitStorage.savedHeight,
      interpolation: img.Interpolation.average,
    );
  }

  return img.encodeJpg(result, quality: 90);
}
