import 'dart:math';

import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/utils/dice_roller.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/dice_roll_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedRandom implements Random {
  _ScriptedRandom(this.results);

  final List<int> results;
  int _index = 0;

  @override
  int nextInt(int max) {
    final value = results[_index % results.length];
    _index++;
    return value - 1;
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required List<int> rolls,
  String label = 'Furtividade (DES)',
  int modifier = 5,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        diceRollerProvider.overrideWithValue(
          DiceRoller(random: _ScriptedRandom(rolls)),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: DiceRollSheet(label: label, modifier: modifier),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('já rola no modo normal ao abrir', (tester) async {
    await _pumpSheet(tester, rolls: [13]);

    expect(find.text('Furtividade (DES)'), findsOneWidget);
    expect(find.text('Teste de d20 +5'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('1d20 +5'), findsOneWidget);
    expect(find.text('13 +5'), findsOneWidget);
  });

  testWidgets('rolar com vantagem mostra os dois dados e o mantido',
      (tester) async {
    await _pumpSheet(tester, rolls: [4, 19]);

    // A primeira rolagem (normal) consumiu o 4.
    expect(find.text('9'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Vantagem'));
    await tester.pumpAndSettle();

    // Vantagem rola 19 e 4 (a fila reinicia), mantém 19.
    expect(find.text('2d20 (maior) +5'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
  });

  testWidgets('desvantagem mantém o menor', (tester) async {
    await _pumpSheet(tester, rolls: [10, 2], modifier: 0);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Desvantagem'));
    await tester.pumpAndSettle();

    expect(find.text('2d20 (menor)'), findsOneWidget);
  });

  testWidgets('20 natural é destacado', (tester) async {
    await _pumpSheet(tester, rolls: [20], modifier: 0);

    expect(find.text('20 natural!'), findsOneWidget);
    expect(find.text('1 natural.'), findsNothing);
  });

  testWidgets('1 natural é destacado', (tester) async {
    await _pumpSheet(tester, rolls: [1], modifier: 3);

    expect(find.text('1 natural.'), findsOneWidget);
    // Total continua somando o modificador.
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('modificador negativo aparece no cabeçalho', (tester) async {
    await _pumpSheet(tester, rolls: [10], modifier: -2, label: 'Atletismo');

    expect(find.text('Atletismo'), findsOneWidget);
    expect(find.text('Teste de d20 -2'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('o modo escolhido fica marcado', (tester) async {
    await _pumpSheet(tester, rolls: [10, 15]);

    // Normal começa selecionado (FilledButton), os outros não.
    expect(find.widgetWithText(FilledButton, 'Normal'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Vantagem'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Vantagem'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Vantagem'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Normal'), findsOneWidget);
  });
}
