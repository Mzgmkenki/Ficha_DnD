import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/combat_panel_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// O acesso ao Painel de combate, na ficha.
///
/// O que ele mostra é o único resto das três seções que saíram da ficha: o
/// jogador precisa saber que há condição ativa ou recurso gasto sem abrir o
/// painel, senão recolher as seções esconderia informação em vez de organizá-la.
void main() {
  /// Conta os toques recebidos, para o teste do callback não precisar de uma
  /// variável fora do escopo.
  final taps = <int>[];

  setUp(taps.clear);

  Future<void> pumpButton(WidgetTester tester, Character character) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CombatPanelButton(
              character: character,
              onPressed: () => taps.add(1),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mostra o nome do destino e as três abas que há lá',
      (tester) async {
    await pumpButton(tester, characterFixture());

    expect(find.text('Painel de combate'), findsOneWidget);
    expect(find.text('Ações • Condições • Recursos'), findsOneWidget);
  });

  testWidgets('não é um botão flutuante', (tester) async {
    // Requisito explícito: um botão flutuante cobriria o conteúdo da ficha.
    await pumpButton(tester, characterFixture());

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('sem nada notável, o resumo diz isso e não há indicador',
      (tester) async {
    await pumpButton(tester, characterFixture());

    expect(
      find.text('Sem condições ativas • recursos completos'),
      findsOneWidget,
    );
    expect(find.text('2 ativas'), findsNothing);
    expect(find.text('Gasto'), findsNothing);
  });

  testWidgets('resume condições e recursos numa linha', (tester) async {
    // É o formato pedido no requisito: as duas contas na mesma linha curta.
    await pumpButton(
      tester,
      characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
        conditions: const {Condition.poisoned, Condition.prone},
        hitDiceUsed: 1,
      ),
    );

    expect(
      find.text('2 condições ativas • 1 dado de vida gasto'),
      findsOneWidget,
    );
  });

  testWidgets('o indicador é texto, não só cor', (tester) async {
    await pumpButton(
      tester,
      characterFixture(
        conditions: const {Condition.poisoned, Condition.prone},
      ),
    );

    expect(find.text('2 ativas'), findsOneWidget);
  });

  testWidgets('recurso gasto sem condição também acende o indicador',
      (tester) async {
    await pumpButton(tester, characterFixture(hitDiceUsed: 1));

    expect(find.text('Gasto'), findsOneWidget);
  });

  testWidgets('o leitor de tela ouve destino e estado num nó ativável',
      (tester) async {
    // Um nó só, com o rótulo inteiro, e com a ação de toque: `excludeSemantics`
    // derruba a ação do InkWell, então o botão tem que declarar a dela — senão
    // o leitor de tela anuncia algo que não abre.
    final handle = tester.ensureSemantics();

    await pumpButton(
      tester,
      characterFixture(conditions: const {Condition.stunned}),
    );

    expect(
      tester.getSemantics(find.byType(InkWell)),
      matchesSemantics(
        label: 'Painel de combate. 1 condição ativa',
        hint: 'Abrir',
        isButton: true,
        hasTapAction: true,
      ),
    );

    handle.dispose();
  });

  testWidgets('o toque chama quem abre o painel', (tester) async {
    await pumpButton(tester, characterFixture());

    await tester.tap(find.byType(CombatPanelButton));
    await tester.pumpAndSettle();

    expect(taps, hasLength(1));
  });

  testWidgets('a área de toque passa o mínimo de 48 px', (tester) async {
    await pumpButton(tester, characterFixture());

    final size = tester.getSize(find.byType(CombatPanelButton));
    expect(size.height, greaterThanOrEqualTo(48));
  });
}
