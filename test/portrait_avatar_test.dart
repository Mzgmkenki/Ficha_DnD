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
    // Sem legenda: em 56 px o texto não sairia legível.
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
    // arquivo presente.
    expect(find.byType(Image), findsOneWidget);
  });

  group('PortraitBanner', () {
    testWidgets('preenche a largura do pai na proporção pedida', (tester) async {
      await _pump(
        tester,
        const SizedBox(width: 300, child: PortraitBanner(path: null)),
      );

      final size = tester.getSize(find.byType(PortraitBanner));
      expect(size.width, 300);
      // 4:3 é o padrão, então a altura sai de 300 / (4/3).
      expect(size.height, closeTo(225, 0.5));
    });

    testWidgets('aceita outra proporção', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 320,
          child: PortraitBanner(path: null, aspectRatio: 16 / 9),
        ),
      );

      expect(tester.getSize(find.byType(PortraitBanner)).height, closeTo(180, 0.5));
    });

    testWidgets('sem imagem mostra ícone e legenda', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 300,
          child: PortraitBanner(path: null, emptyLabel: 'sem imagem'),
        ),
      );

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.text('sem imagem'), findsOneWidget);
    });

    testWidgets('sem imagem encurta para emptyHeight', (tester) async {
      // Na lista, manter a proporção cheia deixaria um retângulo vazio de
      // 200+ px por personagem sem foto.
      await _pump(
        tester,
        const SizedBox(
          width: 300,
          child: PortraitBanner(path: null, emptyHeight: 96),
        ),
      );

      expect(tester.getSize(find.byType(PortraitBanner)).height, 96);
    });

    testWidgets('com imagem o emptyHeight não vale', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 300,
          child: PortraitBanner(path: '/x/y.png', emptyHeight: 96),
        ),
      );

      expect(
        tester.getSize(find.byType(PortraitBanner)).height,
        closeTo(225, 0.5),
      );
    });

    testWidgets('largura infinita não derruba o layout', (tester) async {
      // Acontece se alguém puser o banner numa Row sem Expanded.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: Row(children: [PortraitBanner(path: null)]),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(PortraitBanner)).width, 240);
    });
  });
}
