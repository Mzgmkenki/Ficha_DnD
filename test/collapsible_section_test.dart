import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/collapsible_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Seções recolhíveis da ficha e a folga da barra de navegação.
///
/// O que estes testes protegem: o estado inicial fechado, a independência entre
/// seções e o estado exposto à acessibilidade. Errar qualquer um deles é o tipo
/// de coisa que passa desapercebida olhando a tela de relance.
void main() {
  Widget host(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  group('CollapsibleSection não controlada', () {
    testWidgets('começa fechada e não constrói o conteúdo', (tester) async {
      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(find.text('Condições'), findsOneWidget);
      expect(find.text('conteúdo'), findsNothing);
      expect(find.text('Expandir'), findsOneWidget);
    });

    testWidgets('tocar no cabeçalho abre, e tocar de novo fecha',
        (tester) async {
      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            child: Text('conteúdo'),
          ),
        ),
      );

      await tester.tap(find.text('Condições'));
      await tester.pumpAndSettle();

      expect(find.text('conteúdo'), findsOneWidget);
      expect(find.text('Recolher'), findsOneWidget);

      await tester.tap(find.text('Condições'));
      await tester.pumpAndSettle();

      expect(find.text('conteúdo'), findsNothing);
      expect(find.text('Expandir'), findsOneWidget);
    });

    testWidgets('o toque funciona em qualquer ponto do cabeçalho', (tester) async {
      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            summary: 'Nenhuma condição',
            child: Text('conteúdo'),
          ),
        ),
      );

      // Pelo resumo, que fica na outra ponta do texto do título.
      await tester.tap(find.text('Nenhuma condição'));
      await tester.pumpAndSettle();

      expect(find.text('conteúdo'), findsOneWidget);
    });

    testWidgets('respeita initiallyExpanded', (tester) async {
      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            initiallyExpanded: true,
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(find.text('conteúdo'), findsOneWidget);
      expect(find.text('Recolher'), findsOneWidget);
    });
  });

  group('cabeçalho', () {
    testWidgets('mostra o resumo com a seção fechada', (tester) async {
      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Recursos e descanso',
            summary: 'Dados de vida 2 de 3',
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(find.text('Dados de vida 2 de 3'), findsOneWidget);
      expect(find.text('conteúdo'), findsNothing);
    });

    testWidgets('mostra o indicador com a seção fechada', (tester) async {
      // É o requisito de condição ativa não ficar invisível.
      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            summary: '1 condição ativa',
            badge: 'Ativa',
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(find.text('Ativa'), findsOneWidget);
    });

    testWidgets('sem indicador nada é desenhado no lugar', (tester) async {
      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(find.text('Ativa'), findsNothing);
    });

    testWidgets('resumo vazio não vira linha em branco', (tester) async {
      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            summary: '   ',
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(find.text('   '), findsNothing);
    });

    testWidgets('a área de toque tem pelo menos 48 de altura', (tester) async {
      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            child: Text('conteúdo'),
          ),
        ),
      );

      final header = tester.getSize(
        find.ancestor(
          of: find.text('Condições'),
          matching: find.byType(InkWell),
        ),
      );

      expect(header.height, greaterThanOrEqualTo(48));
    });
  });

  group('acessibilidade', () {
    testWidgets('expõe cabeçalho, botão e o estado expandido', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(InkWell)),
        matchesSemantics(
          label: 'Condições',
          hint: 'Expandir',
          isHeader: true,
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('o rótulo acessível junta título, resumo e indicador',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            summary: '1 condição ativa',
            badge: 'Ativa',
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(InkWell)),
        matchesSemantics(
          label: 'Condições. 1 condição ativa. Ativa',
          hint: 'Expandir',
          isHeader: true,
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('o estado expandido é anunciado ao abrir', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            initiallyExpanded: true,
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(InkWell)),
        matchesSemantics(
          label: 'Condições',
          hint: 'Recolher',
          isHeader: true,
          isButton: true,
          hasExpandedState: true,
          isExpanded: true,
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });
  });

  group('seções independentes', () {
    testWidgets('abrir uma não abre a outra', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              CollapsibleSection(
                id: 'a',
                title: 'Condições',
                child: Text('conteúdo A'),
              ),
              CollapsibleSection(
                id: 'b',
                title: 'Recursos e descanso',
                child: Text('conteúdo B'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Condições'));
      await tester.pumpAndSettle();

      expect(find.text('conteúdo A'), findsOneWidget);
      expect(find.text('conteúdo B'), findsNothing);
    });

    testWidgets('as duas podem ficar abertas ao mesmo tempo', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              CollapsibleSection(
                id: 'a',
                title: 'Condições',
                child: Text('conteúdo A'),
              ),
              CollapsibleSection(
                id: 'b',
                title: 'Recursos e descanso',
                child: Text('conteúdo B'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Condições'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recursos e descanso'));
      await tester.pumpAndSettle();

      expect(find.text('conteúdo A'), findsOneWidget);
      expect(find.text('conteúdo B'), findsOneWidget);
    });
  });

  group('CollapsibleSection controlada', () {
    testWidgets('obedece o pai e avisa a mudança sem se abrir sozinha',
        (tester) async {
      final changed = <bool>[];

      await tester.pumpWidget(
        host(
          CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            isExpanded: false,
            onExpansionChanged: changed.add,
            child: const Text('conteúdo'),
          ),
        ),
      );

      await tester.tap(find.text('Condições'));
      await tester.pumpAndSettle();

      // O pai não mudou o valor, então a seção continua fechada — é o que
      // caracteriza um componente controlado.
      expect(find.text('conteúdo'), findsNothing);
      expect(changed, [true]);
    });

    testWidgets('abre quando o pai muda o valor', (tester) async {
      await tester.pumpWidget(
        host(
          const CollapsibleSection(
            id: 'teste',
            title: 'Condições',
            isExpanded: true,
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(find.text('conteúdo'), findsOneWidget);
    });
  });

  group('folga da barra de navegação', () {
    testWidgets('soma o inset do sistema ao espaçamento do design',
        (tester) async {
      late EdgeInsets padding;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(bottom: 24),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                padding = context.scrollContentPadding();
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(padding.bottom, kContentPadding + 24);
      expect(padding.top, kContentPadding);
      expect(padding.left, kContentPadding);
      expect(padding.right, kContentPadding);
    });

    testWidgets('sem inset inferior fica só o espaçamento do design',
        (tester) async {
      // É o caso do aparelho sem barra de navegação sobreposta: nada de folga
      // extra, para o botão não flutuar longe da borda.
      late EdgeInsets padding;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                padding = context.scrollContentPadding();
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(padding.bottom, kContentPadding);
    });
  });
}
