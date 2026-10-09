import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/racial_traits_panel.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_choice_group.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// O painel de características raciais da ficha.
///
/// O que estes testes protegem é o `choice_groups`: ele existia no asset e era
/// lido pelo repositório, mas o painel só mostrava `traits`. O resultado era um
/// traço que terminava em "escolha uma das formas abaixo" sem nada abaixo —
/// era assim que o aasimar aparecia na ficha.
void main() {
  const aasimar = RaceEntry(
    id: 'aasimar_motm',
    name: 'Aasimar',
    source: 'motm',
    size: 'medium',
    speed: 9,
    darkvision: 18,
    creatureType: 'humanoid',
    languages: ['Comum'],
    traits: [
      'Resistência Celestial: resistência a dano necrótico e radiante.',
      'Revelação Celestial: no 3º nível, escolha uma das formas abaixo. '
          'Essa escolha determina suas transformações futuras.',
    ],
    choiceGroups: [
      RaceChoiceGroup(
        id: 'aasimar_revelation_choice',
        name: 'Revelação Celestial (3º nível)',
        options: [
          'Mortalha Necrótica: seus olhos escurecem.',
          'Consumo Radiante: seus olhos e boca emitem luz plena.',
          'Alma Radiante: duas asas espectrais luminosas.',
        ],
        choose: 1,
      ),
    ],
  );

  Future<void> pumpPanel(
    WidgetTester tester,
    List<RaceEntry> races, {
    String? speciesId = 'aasimar_motm',
  }) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          raceEntriesProvider.overrideWith((ref) => races),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RacialTraitsPanel(speciesId: speciesId),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mostra as características da raça', (tester) async {
    await pumpPanel(tester, const [aasimar]);

    expect(find.text('Aasimar'), findsOneWidget);
    expect(
      find.text('Resistência Celestial: resistência a dano necrótico e radiante.'),
      findsOneWidget,
    );
  });

  testWidgets('mostra as opções do grupo de escolha, não só o traço que as cita',
      (tester) async {
    await pumpPanel(tester, const [aasimar]);

    expect(find.text('Revelação Celestial (3º nível)'), findsOneWidget);
    expect(find.text('Escolha uma opção.'), findsOneWidget);

    expect(
      find.text('Mortalha Necrótica: seus olhos escurecem.'),
      findsOneWidget,
    );
    expect(
      find.text('Consumo Radiante: seus olhos e boca emitem luz plena.'),
      findsOneWidget,
    );
    expect(
      find.text('Alma Radiante: duas asas espectrais luminosas.'),
      findsOneWidget,
    );
  });

  testWidgets('o grupo que escolhe mais de uma diz quantas', (tester) async {
    const race = RaceEntry(
      id: 'teste',
      name: 'Teste',
      source: 'srd',
      size: 'medium',
      speed: 9,
      creatureType: 'humanoid',
      traits: ['Um traço qualquer.'],
      choiceGroups: [
        RaceChoiceGroup(
          id: 'g',
          name: 'Dois de três',
          options: ['Primeira.', 'Segunda.', 'Terceira.'],
          choose: 2,
        ),
      ],
    );

    await pumpPanel(tester, const [race], speciesId: 'teste');

    expect(find.text('Escolha 2 opções.'), findsOneWidget);
  });

  testWidgets('raça sem grupo de escolha não ganha seção vazia',
      (tester) async {
    const race = RaceEntry(
      id: 'simples',
      name: 'Simples',
      source: 'srd',
      size: 'medium',
      speed: 9,
      creatureType: 'humanoid',
      traits: ['Um traço qualquer.'],
    );

    await pumpPanel(tester, const [race], speciesId: 'simples');

    expect(find.text('Um traço qualquer.'), findsOneWidget);
    expect(find.textContaining('Escolha'), findsNothing);
  });

  testWidgets('sub-raça junta o grupo dela com o da raça base', (tester) async {
    // É o caso do eladrin, cujas estações estão na sub-raça, e do draconato,
    // cuja ancestralidade está na base.
    const base = RaceEntry(
      id: 'base',
      name: 'Base',
      source: 'srd',
      size: 'medium',
      speed: 9,
      creatureType: 'humanoid',
      traits: ['Traço da base.'],
      choiceGroups: [
        RaceChoiceGroup(
          id: 'g_base',
          name: 'Grupo da base',
          options: ['Opção da base.'],
          choose: 1,
        ),
      ],
    );

    const sub = RaceEntry(
      id: 'sub',
      name: 'Sub',
      source: 'srd',
      isSubrace: true,
      parentRaceId: 'base',
      traits: ['Traço da sub-raça.'],
      choiceGroups: [
        RaceChoiceGroup(
          id: 'g_sub',
          name: 'Grupo da sub-raça',
          options: ['Opção da sub-raça.'],
          choose: 1,
        ),
      ],
    );

    await pumpPanel(tester, const [base, sub], speciesId: 'sub');

    expect(find.text('Base — Sub'), findsOneWidget);
    expect(find.text('Grupo da base'), findsOneWidget);
    expect(find.text('Opção da base.'), findsOneWidget);
    expect(find.text('Grupo da sub-raça'), findsOneWidget);
    expect(find.text('Opção da sub-raça.'), findsOneWidget);
  });

  testWidgets('sem raça vinculada, avisa em vez de ficar em branco',
      (tester) async {
    await pumpPanel(tester, const [aasimar], speciesId: null);

    expect(find.text('Nenhuma raça vinculada ao personagem.'), findsOneWidget);
  });
}
