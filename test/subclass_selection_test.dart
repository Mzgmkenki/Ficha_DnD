import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_creation_page.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCharacterRepository implements CharacterRepository {
  Character? created;
  final List<CharacterSpell> addedSpells = [];

  @override
  Future<void> create(Character character) async {
    created = character;
  }

  // A criação sincroniza as magias da subclasse logo depois de salvar, então o
  // fake precisa responder a esse caminho também.
  @override
  Future<Character?> findById(String id) async => created;

  @override
  Future<void> addCharacterSpell({
    required String characterId,
    required CharacterSpell spell,
  }) async {
    addedSpells.add(spell);
  }

  @override
  Future<void> removeCharacterSpell({
    required String characterId,
    required int spellId,
    required String sourceType,
    required String sourceId,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

/// Escolhe o domínio já no 1º nível.
const _cleric = ClassEntry(
  id: 'cleric',
  name: 'Clérigo',
  hitDie: 'd8',
  source: 'phb',
  skillOptions: ['insight', 'religion'],
  savingThrows: ['wisdom', 'charisma'],
  primaryAbility: 'wisdom',
  spellcastingType: 'full',
  spellcastingAbility: 'wisdom',
  subclassLevel: 1,
  subclassLabel: 'Domínio Divino',
);

/// Só escolhe o arquétipo no 3º nível.
const _fighter = ClassEntry(
  id: 'fighter',
  name: 'Guerreiro',
  hitDie: 'd10',
  source: 'phb',
  skillOptions: ['athletics'],
  savingThrows: ['strength', 'constitution'],
  primaryAbility: 'strength',
  subclassLevel: 3,
  subclassLabel: 'Arquétipo Marcial',
);

/// Compêndio de magias mínimo, só para a sincronização ter o que resolver.
const _blessEntry = SpellEntry(
  id: 42,
  namePt: 'Bênção',
  nameOriginal: 'Bless',
  level: 1,
  school: 'Encantamento',
  castingTime: 'Uma ação',
  range: '9 m',
  components: 'V S M',
  hasCostlyMaterials: false,
  duration: '1 minuto',
  concentration: true,
  ritual: false,
  classes: ['cleric'],
  subclasses: [],
  description: '',
  source: 'phb',
  page: '1',
  isSrd: true,
);

const _lifeDomain = SubclassEntry(
  id: 'cleric_life_domain',
  classId: 'cleric',
  name: 'Domínio da Vida',
  source: 'phb',
  description: 'Cura e vitalidade.',
  spells: [
    SubclassSpellGrant(level: 1, spellNames: ['Bless']),
  ],
  features: [
    SubclassFeature(
      level: 1,
      name: 'Discípulo da Vida',
      description: 'Cura extra ao conjurar magias de cura.',
    ),
    SubclassFeature(
      level: 17,
      name: 'Cura Suprema',
      description: 'Os dados de cura contam como valor máximo.',
    ),
  ],
);

const _champion = SubclassEntry(
  id: 'fighter_champion',
  classId: 'fighter',
  name: 'Campeão',
  source: 'phb',
  features: [
    SubclassFeature(
      level: 3,
      name: 'Crítico Aprimorado',
      description: 'Crítico com 19 ou 20.',
    ),
  ],
);

const _human = RaceEntry(
  id: 'human',
  name: 'Humano',
  source: 'phb',
  size: 'medium',
  speed: 9,
  creatureType: 'humanoid',
  fixedAbilityBonuses: {'strength': 1},
  traits: ['Versatilidade.'],
);

const _acolyte = BackgroundEntry(
  id: 'acolyte',
  name: 'Acólito',
  skillIds: ['insight', 'religion'],
);

Future<_FakeCharacterRepository> _pumpCreationPage(
  WidgetTester tester,
  List<ClassEntry> classes,
) async {
  final repository = _FakeCharacterRepository();

  tester.view.physicalSize = const Size(1200, 4200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterRepositoryProvider.overrideWithValue(repository),
        classEntriesProvider.overrideWith((ref) => classes),
        raceEntriesProvider.overrideWith((ref) => const [_human]),
        backgroundEntriesProvider.overrideWith((ref) => const [_acolyte]),
        subclassEntriesProvider.overrideWith(
          (ref) => const [_lifeDomain, _champion],
        ),
        // Sem isso o teste tentaria carregar os três arquivos de magia do
        // bundle e o pumpAndSettle nunca assentava.
        spellEntriesProvider.overrideWith((ref) => const [_blessEntry]),
      ],
      child: MaterialApp(
        home: const CharacterCreationPage(),
        onGenerateRoute:
            (_) => MaterialPageRoute<void>(builder: (_) => const Text('FICHA')),
      ),
    ),
  );
  await tester.pump();

  const valuesByAbility = {
    'strength': 15,
    'dexterity': 14,
    'constitution': 13,
    'intelligence': 12,
    'wisdom': 10,
    'charisma': 8,
  };
  for (final entry in valuesByAbility.entries) {
    final field = tester.widget<DropdownButtonFormField<int>>(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<int> &&
            widget.key.toString().contains('standard-${entry.key}-'),
      ),
    );
    field.onChanged!(entry.value);
    await tester.pump();
  }

  return repository;
}

Future<void> _fillNameAndBackground(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).first, 'Testino');
  await tester.pumpAndSettle();

  final dropdown = tester.widget<DropdownButtonFormField<String>>(
    find.ancestor(
      of: find.text('Antecedente'),
      matching: find.byType(DropdownButtonFormField<String>),
    ),
  );
  dropdown.onChanged!('acolyte');
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.widgetWithText(FilledButton, 'Criar personagem');
  await tester.ensureVisible(saveButton);
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('classe que escolhe no 1º nível mostra o seletor', (
    tester,
  ) async {
    await _pumpCreationPage(tester, const [_cleric]);

    // Usa o rótulo da própria classe, não um genérico.
    expect(find.text('Domínio Divino'), findsWidgets);
    expect(find.text('Domínio da Vida'), findsWidgets);
  });

  testWidgets(
    'classe que escolhe depois avisa o nível em vez de mostrar o seletor',
    (tester) async {
      await _pumpCreationPage(tester, const [_fighter]);

      expect(
        find.text('Arquétipo Marcial: você escolhe no 3º nível.'),
        findsOneWidget,
      );
      expect(find.text('Campeão'), findsNothing);
    },
  );

  testWidgets('subclasse escolhida no 1º nível é gravada no personagem', (
    tester,
  ) async {
    final repository = await _pumpCreationPage(tester, const [_cleric]);

    await _fillNameAndBackground(tester);
    await _tapSave(tester);

    final created = repository.created;
    expect(created, isNotNull);
    expect(created!.classLevels.single.subclassId, 'cleric_life_domain');

    // E a magia do domínio vai para o livro já preparada.
    expect(repository.addedSpells, hasLength(1));
    final spell = repository.addedSpells.single;
    expect(spell.spellId, 42);
    expect(spell.sourceName, 'Domínio da Vida');
    expect(spell.isPrepared, isTrue);
    expect(spell.isAlwaysAvailable, isTrue);
  });

  testWidgets('classe que escolhe depois não grava subclasse', (tester) async {
    final repository = await _pumpCreationPage(tester, const [_fighter]);

    await _fillNameAndBackground(tester);
    await _tapSave(tester);

    expect(repository.created!.classLevels.single.subclassId, isNull);
  });

  testWidgets('o resumo esconde característica de nível acima do atual', (
    tester,
  ) async {
    await _pumpCreationPage(tester, const [_cleric]);

    // Nível 1: a característica de 1º aparece, a de 17º não.
    expect(find.textContaining('Discípulo da Vida'), findsOneWidget);
    expect(find.textContaining('Cura Suprema'), findsNothing);
    expect(
      find.text('Mais 1 característica em níveis seguintes.'),
      findsOneWidget,
    );
  });
}
