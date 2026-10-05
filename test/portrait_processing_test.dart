import 'dart:io';
import 'dart:typed_data';

import 'package:dnd_ficha_app/core/storage/portrait_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  const storage = PortraitStorage();

  test('prepara imagem válida e limita dimensão do editor', () async {
    final directory = await Directory.systemTemp.createTemp('portrait-test-');
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}/large.jpg');
    final image = img.Image(width: 2600, height: 1000);
    await source.writeAsBytes(img.encodeJpg(image));

    final prepared = await storage.prepareForCropping(
      PickedImage(path: source.path, extension: 'jpg'),
    );
    final decoded = img.decodeImage(prepared)!;

    expect(decoded.width, PortraitStorage.editorMaxDimension);
    expect(decoded.height, lessThan(decoded.width));
  });

  test('recorte salvo fica limitado a 1600 por 1200', () async {
    final source = img.Image(width: 2000, height: 1500);
    final optimized = await storage.optimizeCropped(
      Uint8List.fromList(img.encodeJpg(source)),
    );
    final decoded = img.decodeImage(optimized)!;

    expect(decoded.width, PortraitStorage.savedWidth);
    expect(decoded.height, PortraitStorage.savedHeight);
  });

  test('arquivo inválido falha com mensagem amigável', () async {
    final directory = await Directory.systemTemp.createTemp('portrait-test-');
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}/broken.jpg');
    await source.writeAsString('isto não é uma imagem');

    expect(
      () => storage.prepareForCropping(
        PickedImage(path: source.path, extension: 'jpg'),
      ),
      throwsA(isA<PortraitException>()),
    );
  });

  test('formato não permitido é recusado antes do processamento', () async {
    final directory = await Directory.systemTemp.createTemp('portrait-test-');
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}/portrait.txt');
    await source.writeAsString('arquivo');

    expect(
      () => storage.prepareForCropping(
        PickedImage(path: source.path, extension: 'txt'),
      ),
      throwsA(isA<PortraitException>()),
    );
  });
}
