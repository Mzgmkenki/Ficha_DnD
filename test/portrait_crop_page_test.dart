import 'dart:typed_data';

import 'package:dnd_ficha_app/core/theme/app_theme.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/portrait_crop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Uint8List _imageBytes() {
  final image = img.Image(width: 400, height: 300);
  return Uint8List.fromList(img.encodeJpg(image));
}

void main() {
  testWidgets('oferece mover, redefinir, cancelar e confirmar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: PortraitCropPage(imageBytes: _imageBytes()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enquadrar imagem'), findsOneWidget);
    expect(find.textContaining('Arraste'), findsOneWidget);
    expect(find.text('Redefinir'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);

    // Um arrasto representa a movimentação real do enquadramento.
    await tester.drag(find.byType(PortraitCropPage), const Offset(20, 10));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelar fecha sem devolver novo retrato', (tester) async {
    Uint8List? result = _imageBytes();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder:
              (context) => FilledButton(
                onPressed: () async {
                  result = await PortraitCropPage.open(
                    context,
                    imageBytes: _imageBytes(),
                  );
                },
                child: const Text('Abrir'),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cancelar recorte'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
