import 'package:dnd_ficha_app/core/theme/app_theme.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/portrait_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('sem imagem mostra o convite com a legenda', (tester) async {
    await _pump(tester, const PortraitAvatar(path: null, emptyLabel: 'imagem'));

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.text('imagem'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('em miniatura fica só o ícone, sem texto', (tester) async {
    // É o caso da lista de personagens: 56 px não caberia texto legível.
    await _pump(tester, const PortraitAvatar(path: null, size: 56));

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('caminho vazio conta como sem imagem', (tester) async {
    await _pump(tester, const PortraitAvatar(path: '', size: 56));

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets(
    'arquivo que não abre cai no placeholder em vez de estourar',
    (tester) async {
      // Cenário real: o jogador limpou os dados do app ou restaurou um backup
      // sem a pasta de imagens. Sem o errorBuilder isso derrubaria a lista
      // inteira com exceção de render.
      await _pump(
        tester,
        const PortraitAvatar(
          path: '/caminho/que/nao/existe/retrato.png',
          emptyLabel: 'imagem',
        ),
      );

      // Ler o arquivo é I/O de verdade, e o relógio do teste é falso: sem
      // `runAsync` a falha nunca chega e o errorBuilder não roda.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(find.text('sem arquivo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('com caminho preenchido tenta desenhar a imagem', (tester) async {
    await _pump(
      tester,
      const PortraitAvatar(path: '/caminho/qualquer/x.png', size: 56),
    );

    // Antes de falhar existe um Image na árvore: é o caminho normal, com
    // arquivo presente, que a lista usa.
    expect(find.byType(Image), findsOneWidget);
  });
}
