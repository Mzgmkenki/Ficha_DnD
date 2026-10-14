import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/entities/background_personality_choice.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/background_personality_form.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_personality.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda quantos campos narrativos a criação mostra.
///
/// O caso que motivou o teste: a tela pedia dois traços de personalidade. Uma
/// escolha por categoria é decisão de produto deste app — o Livro do Jogador
/// pede dois traços — e o número vem do asset, não do widget.
void main() {
  PersonalityTable table(PersonalityCategory category, int rows) {
    return PersonalityTable(
      category: category,
      die: 'd$rows',
      options: [
        for (var roll = 1; roll <= rows; roll++)
          PersonalityOption(
            id: 'teste.${category.id}.$roll',
            category: category,
            roll: roll,
            text: '${category.label} número $roll',
          ),
      ],
    );
  }

  BackgroundPersonality personality({int traitChoices = 1}) {
    return BackgroundPersonality(
      sourceId: 'teste',
      traits: table(PersonalityCategory.trait, 8),
      ideals: table(PersonalityCategory.ideal, 6),
      bonds: table(PersonalityCategory.bond, 6),
      flaws: table(PersonalityCategory.flaw, 6),
      traitChoiceCount: traitChoices,
      idealChoiceCount: 1,
      bondChoiceCount: 1,
      flawChoiceCount: 1,
    );
  }

  Future<void> pump(
    WidgetTester tester,
    BackgroundPersonality item, {
    BackgroundPersonalitySelection? selection,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BackgroundPersonalityForm(
              personality: item,
              selection: selection ?? BackgroundPersonalitySelection.empty,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('mostra um único campo de traço de personalidade', (
    tester,
  ) async {
    await pump(tester, personality());

    expect(find.byKey(const ValueKey('personality-trait-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('personality-trait-1')), findsNothing);
  });

  testWidgets('mostra um campo de cada categoria, sem numeração', (
    tester,
  ) async {
    await pump(tester, personality());

    for (final category in PersonalityCategory.values) {
      expect(
        find.byKey(ValueKey('personality-${category.id}-0')),
        findsOneWidget,
        reason: category.id,
      );
    }

    // Com uma escolha só, o rótulo é o nome da categoria. A numeração
    // ("Traço de personalidade 1") só aparece quando há mais de um campo.
    expect(find.text('Traço de personalidade'), findsOneWidget);
    expect(find.text('Traço de personalidade 1'), findsNothing);
  });

  testWidgets('escolher o traço resolve a pendência da categoria', (
    tester,
  ) async {
    final item = personality();

    await pump(tester, item);
    expect(
      item.requiredCategories,
      PersonalityCategory.values,
      reason: 'as quatro categorias continuam obrigatórias',
    );

    final selection = BackgroundPersonalitySelection([
      BackgroundPersonalityChoice.fromOption(item.traits.options.first),
    ]);

    expect(selection.countFor(PersonalityCategory.trait), 1);
    expect(
      selection.validationError(item),
      isNot(contains('traço')),
      reason: 'com um traço escolhido, a categoria está completa',
    );
  });

  testWidgets('o widget ainda renderiza duas posições se o dado pedir', (
    tester,
  ) async {
    // O mecanismo continua suportando mais de uma escolha por categoria: a
    // mudança foi no asset, não aqui. Isto também cobre a ficha antiga, criada
    // quando o traço pedia duas.
    await pump(tester, personality(traitChoices: 2));

    expect(find.byKey(const ValueKey('personality-trait-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('personality-trait-1')), findsOneWidget);
    expect(find.text('Traço de personalidade 1'), findsOneWidget);
    expect(find.text('Traço de personalidade 2'), findsOneWidget);
  });

  test('todo antecedente do asset pede uma escolha por categoria', () {
    final raw =
        jsonDecode(File('assets/data/srd/backgrounds.json').readAsStringSync())
            as List<dynamic>;

    final declared = <String>[];

    for (final row in raw) {
      final item = Map<String, dynamic>.from(row as Map);
      final count = item['personality_trait_choices'];
      if (count == null) continue;
      if (count != 1) declared.add('${item['id']}: $count');
    }

    expect(
      declared,
      isEmpty,
      reason: 'antecedentes pedindo mais de um traço: $declared',
    );
  });
}
