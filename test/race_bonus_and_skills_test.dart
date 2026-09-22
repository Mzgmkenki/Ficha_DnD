import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_creation_page.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/ability_bonus_mode.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_skill_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCharacterRepository implements CharacterRepository {
  Character? created;

  @override
  Future<void> create(Character character) async {
    created = character;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

const _fighter = ClassEntry(
  id: 'fighter',
  name: 'Guerreiro',
  hitDie: 'd10',
  source: 'srd',
  skillOptions: ['athletics'],
  savingThrows: ['strength', 'constitution'],
  primaryAbility: 'strength',
);

const _acolyte = BackgroundEntry(
  id: 'acolyte',
  name: 'Acólito',
  skillIds: ['insight', 'religion'],
);

/// Bônus definidos pela raça e deslocamento com fração, como o anão.
const _dwarf = RaceEntry(
  id: 'dwarf',
  name: 'Anão',
  source: 'phb',
  size: 'medium',
  speed: 7.5,
  creatureType: 'humanoid',
  fixedAbilityBonuses: {'constitution': 2},
  traits: ['Resiliência Anã.'],
);

/// Padrão flexível de Mordenkainen, com perícia concedida direto.
const _bugbear = RaceEntry(
  id: 'bugbear',
  name: 'Bugbear',
  source: 'motm',
  size: 'medium',
  speed: 9,
  creatureType: 'humanoid',
  abilityBonusMode: AbilityBonusMode.flexible,
  allowsCustomOrigin: false,
  grantedSkills: ['stealth'],
  traits: ['Furtivo.'],
);

/// Padrão flexível com perícia à escolha, como o centauro.
const _centaur = RaceEntry(
  id: 'centaur',
  name: 'Centauro',
  source: 'motm',
  size: 'medium',
  speed: 12,
  creatureType: 'fey',
  abilityBonusMode: AbilityBonusMode.flexible,
  allowsCustomOrigin: false,
  skillChoice: RaceSkillChoice(
    choose: 1,
    options: ['animalHandling', 'medicine', 'nature', 'survival'],
  ),
  traits: ['Investida.'],
);

const _overlappingSkillsRace = RaceEntry(
  id: 'overlap',
  name: 'Raça de teste',
  source: 'test',
  abilityBonusMode: AbilityBonusMode.flexible,
  allowsCustomOrigin: false,
  skillChoice: RaceSkillChoice(choose: 1, options: ['athletics', 'survival']),
);

Future<_FakeCharacterRepository> _pumpCreationPage(
  WidgetTester tester,
  List<RaceEntry> races, {
  Size surfaceSize = const Size(1200, 4200),
  bool fillAbilityScores = true,
}) async {
  final repository = _FakeCharacterRepository();

  // Tela alta o bastante para o formulário inteiro caber: o ListView constrói
  // sob demanda e, com a tela padrão, rolar até cada checkbox deixava o teste
  // brigando com o scroll em vez de testar a regra.
  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterRepositoryProvider.overrideWithValue(repository),
        classEntriesProvider.overrideWith((ref) => const [_fighter]),
        raceEntriesProvider.overrideWith((ref) => races),
        backgroundEntriesProvider.overrideWith((ref) => const [_acolyte]),
      ],
      child: MaterialApp(
        home: const CharacterCreationPage(),
        onGenerateRoute:
            (_) => MaterialPageRoute<void>(builder: (_) => const Text('FICHA')),
      ),
    ),
  );

  await tester.pump();

  if (fillAbilityScores) {
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
  }

  return repository;
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _fillName(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).first, 'Testino');
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.widgetWithText(FilledButton, 'Criar personagem');
  await _reveal(tester, saveButton);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

Future<void> _selectBackground(WidgetTester tester) async {
  final dropdown = tester.widget<DropdownButtonFormField<String>>(
    find.ancestor(
      of: find.text('Antecedente'),
      matching: find.byType(DropdownButtonFormField<String>),
    ),
  );
  dropdown.onChanged!('acolyte');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('fluxo permanece rolável sem overflow em tela pequena', (
    tester,
  ) async {
    await _pumpCreationPage(
      tester,
      const [_dwarf],
      surfaceSize: const Size(360, 640),
      fillAbilityScores: false,
    );

    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -520));
    await tester.pumpAndSettle();
    await tester.drag(scrollable, const Offset(0, -520));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(CharacterCreationPage), findsOneWidget);
  });

  testWidgets('conjunto padrão mostra e devolve um valor removido', (
    tester,
  ) async {
    final repository = await _pumpCreationPage(tester, const [
      _dwarf,
    ], fillAbilityScores: false);

    expect(
      find.text('Valores disponíveis: 15, 14, 13, 12, 10 e 8'),
      findsOneWidget,
    );

    final strength = tester.widget<DropdownButtonFormField<int>>(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<int> &&
            widget.key.toString().contains('standard-strength'),
      ),
    );
    expect(strength.initialValue, isNull);

    strength.onChanged!(15);
    await tester.pumpAndSettle();

    expect(
      find.text('Valores disponíveis: 14, 13, 12, 10 e 8'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Remover valor de Força'));
    await tester.pumpAndSettle();

    expect(
      find.text('Valores disponíveis: 15, 14, 13, 12, 10 e 8'),
      findsOneWidget,
    );
    await _fillName(tester);
    await _selectBackground(tester);
    await _tapSave(tester);
    expect(repository.created, isNull);
    expect(find.textContaining('seis atributos'), findsWidgets);
  });

  testWidgets('troca diretamente valores do conjunto padrão entre atributos', (
    tester,
  ) async {
    await _pumpCreationPage(tester, const [_dwarf]);

    final strengthFinder = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<int> &&
          widget.key.toString().contains('standard-strength'),
    );
    final strength = tester.widget<DropdownButtonFormField<int>>(
      strengthFinder,
    );

    strength.onChanged!(14);
    await tester.pumpAndSettle();

    final dexterity = tester.widget<DropdownButtonFormField<int>>(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<int> &&
            widget.key.toString().contains('standard-dexterity'),
      ),
    );

    expect(
      tester
          .widget<DropdownButtonFormField<int>>(strengthFinder)
          .initialValue,
      14,
    );
    expect(dexterity.initialValue, 15);
    expect(find.text('Valores disponíveis: nenhum'), findsOneWidget);
  });

  testWidgets(
    'raça com bônus fixo aplica o bônus e o deslocamento com fração',
    (tester) async {
      final repository = await _pumpCreationPage(tester, const [_dwarf]);

      await _fillName(tester);
      await _selectBackground(tester);
      await _tapSave(tester);

      final created = repository.created;
      expect(created, isNotNull);
      expect(created!.abilityScores.constitution, 15);
      expect(created.abilityScores.strength, 15);
      expect(created.abilityScoreAllocation!.baseScores.constitution, 13);
      // 7,5 m não caberia no campo inteiro que existia antes.
      expect(created.combatStats.speedInMeters, 7.5);
    },
  );

  testWidgets('padrão flexível distribui +2 e +1 sem repetir atributo', (
    tester,
  ) async {
    final repository = await _pumpCreationPage(tester, const [_bugbear]);

    await _fillName(tester);
    await _selectBackground(tester);
    await _tapSave(tester);

    final bonuses =
        repository.created!.abilityScoreAllocation!.originBonuses.values
            .toList();

    expect(bonuses.where((value) => value == 2).length, 1);
    expect(bonuses.where((value) => value == 1).length, 1);
    expect(bonuses.fold<int>(0, (sum, value) => sum + value), 3);
  });

  testWidgets('variante do padrão flexível dá +1 em três atributos', (
    tester,
  ) async {
    final repository = await _pumpCreationPage(tester, const [_bugbear]);

    await _fillName(tester);
    await _selectBackground(tester);

    final tripleOption = find.text('+1, +1 e +1');
    await _reveal(tester, tripleOption);
    await tester.tap(tripleOption);
    await tester.pumpAndSettle();

    await _tapSave(tester);

    final bonuses =
        repository.created!.abilityScoreAllocation!.originBonuses.values
            .toList();

    expect(bonuses.where((value) => value == 1).length, 3);
    expect(bonuses.where((value) => value == 2), isEmpty);
  });

  testWidgets('perícia concedida pela raça entra sem o jogador marcar', (
    tester,
  ) async {
    final repository = await _pumpCreationPage(tester, const [_bugbear]);

    await _fillName(tester);
    await _selectBackground(tester);
    await _tapSave(tester);

    final skills = repository.created!.skillProficiencies;
    expect(skills.levelFor(Skill.stealth), ProficiencyLevel.proficient);
    // O antecedente continua concedendo as dele.
    expect(skills.levelFor(Skill.insight), ProficiencyLevel.proficient);
  });

  testWidgets('não salva sem escolher a perícia que a raça oferece', (
    tester,
  ) async {
    final repository = await _pumpCreationPage(tester, const [_centaur]);

    await _fillName(tester);
    await _selectBackground(tester);
    await _tapSave(tester);

    expect(repository.created, isNull);
    expect(find.textContaining('a perícia da raça'), findsOneWidget);
  });

  testWidgets('perícia escolhida na raça entra na ficha', (tester) async {
    final repository = await _pumpCreationPage(tester, const [_centaur]);

    await _fillName(tester);
    await _selectBackground(tester);

    final natureTile = find.byKey(const ValueKey('race-skill-nature'));
    await _reveal(tester, natureTile);
    await tester.tap(natureTile);
    await tester.pumpAndSettle();

    await _tapSave(tester);

    final skills = repository.created!.skillProficiencies;
    expect(skills.levelFor(Skill.nature), ProficiencyLevel.proficient);
  });

  testWidgets('marcar além do limite não acumula perícias da raça', (
    tester,
  ) async {
    final repository = await _pumpCreationPage(tester, const [_centaur]);

    await _fillName(tester);
    await _selectBackground(tester);

    for (final id in ['nature', 'medicine', 'survival']) {
      final tile = find.byKey(ValueKey('race-skill-$id'));
      await _reveal(tester, tile);
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }

    await _tapSave(tester);

    final skills = repository.created!.skillProficiencies;
    final fromRace = ['nature', 'medicine', 'survival']
        .map(Skill.fromId)
        .whereType<Skill>()
        .where((skill) => skills.isProficient(skill));

    // O centauro escolhe uma: as outras duas não podem entrar de carona.
    expect(fromRace.length, 1);
  });

  testWidgets('perícia da classe fica bloqueada na raça e volta ao desmarcar', (
    tester,
  ) async {
    await _pumpCreationPage(tester, const [_overlappingSkillsRace]);

    final classTile = find.byKey(const ValueKey('class-skill-athletics'));
    await _reveal(tester, classTile);
    await tester.tap(classTile);
    await tester.pumpAndSettle();

    var raceTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('race-skill-athletics')),
    );
    expect(raceTile.onChanged, isNull);
    expect(
      find.textContaining('Já adquirida por classe Guerreiro'),
      findsWidgets,
    );

    await tester.tap(classTile);
    await tester.pumpAndSettle();

    raceTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('race-skill-athletics')),
    );
    expect(raceTile.onChanged, isNotNull);
  });

  testWidgets('perícia automática da raça bloqueia escolha adicional', (
    tester,
  ) async {
    await _pumpCreationPage(tester, const [_bugbear]);

    final extra = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('extra-skill-stealth')),
    );
    expect(extra.onChanged, isNull);
    expect(find.textContaining('Já adquirida por raça Bugbear'), findsWidgets);
  });
}
