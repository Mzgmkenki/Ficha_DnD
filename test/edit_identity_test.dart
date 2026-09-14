import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_identity_page.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _acolyte = BackgroundEntry(
  id: 'acolyte',
  name: 'Acólito',
  skillIds: ['insight', 'religion'],
  description: 'Serviu um templo.',
);

const _backgrounds = [_acolyte, BackgroundEntry.customOption];

/// Repositório em memória: `findById` alimenta o use case e `update` guarda o
/// resultado para as asserções.
class _FakeCharacterRepository implements CharacterRepository {
  _FakeCharacterRepository(this.stored);

  Character stored;
  Character? updated;

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Future<void> update(Character character) async {
    updated = character;
    stored = character;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

Character _character({
  String name = 'Vex',
  String? playerName,
  String? backgroundId,
  CustomBackground customBackground = const CustomBackground(),
  String notes = '',
  SkillProficiencies skills = const SkillProficiencies(),
}) {
  final now = DateTime(2026, 1, 1);

  return Character(
    id: 'c1',
    name: name,
    playerName: playerName,
    backgroundId: backgroundId,
    customBackground: customBackground,
    notes: notes,
    skillProficiencies: skills,
    abilityScores: const AbilityScores(
      strength: 10,
      dexterity: 10,
      constitution: 10,
      intelligence: 10,
      wisdom: 10,
      charisma: 10,
    ),
    classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
    hitPoints: const HitPoints(current: 10, maximum: 10),
    combatStats: const CombatStats(
      armorClass: 10,
      initiativeBonus: 0,
      speedInMeters: 9,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

Future<_FakeCharacterRepository> _pumpEditor(
  WidgetTester tester,
  Character character,
) async {
  final repository = _FakeCharacterRepository(character);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterRepositoryProvider.overrideWithValue(repository),
        backgroundEntriesProvider.overrideWith((ref) => _backgrounds),
      ],
      child: MaterialApp(
        home: EditIdentityPage(
          characterId: character.id,
          initialName: character.name,
          initialNotes: character.notes,
          initialPlayerName: character.playerName,
          initialBackgroundId: character.backgroundId,
          initialCustomBackground: character.customBackground,
        ),
      ),
    ),
  );
  await tester.pump();

  return repository;
}

Finder _dropdownWithLabel(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(DropdownButtonFormField<String>),
  );
}

Future<void> _selectInDropdown(
  WidgetTester tester,
  String label,
  String value,
) async {
  final dropdown = tester.widget<DropdownButtonFormField<String>>(
    _dropdownWithLabel(label),
  );
  dropdown.onChanged!(value);
  await tester.pumpAndSettle();
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

Future<void> _tapSave(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Salvar identidade');
  await _reveal(tester, button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('carrega os dados atuais do personagem no formulário',
      (tester) async {
    await _pumpEditor(
      tester,
      _character(
        name: 'Vex',
        playerName: 'Marcos',
        backgroundId: 'acolyte',
        notes: 'Devo um favor ao templo.',
      ),
    );

    expect(find.widgetWithText(TextFormField, 'Vex'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Marcos'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Devo um favor ao templo.'),
      findsOneWidget,
    );
    // Antecedente do compêndio não abre o formulário do customizável.
    expect(find.text('Monte o seu antecedente'), findsNothing);
    expect(find.text('Perícias concedidas: Intuição, Religião'), findsOneWidget);
  });

  testWidgets('salva nome, jogador e anotações', (tester) async {
    final repository = await _pumpEditor(
      tester,
      _character(name: 'Vex', backgroundId: 'acolyte'),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Vex'),
      'Vex Vessar',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Jogador (opcional)'),
      'Marcos',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Anotações da ficha'),
      'Caçada em andamento.',
    );
    await tester.pumpAndSettle();

    await _tapSave(tester);

    final saved = repository.updated;
    expect(saved, isNotNull);
    expect(saved!.name, 'Vex Vessar');
    expect(saved.playerName, 'Marcos');
    expect(saved.notes, 'Caçada em andamento.');
    expect(saved.backgroundId, 'acolyte');
  });

  testWidgets('limpar o campo do jogador volta o valor para null',
      (tester) async {
    final repository = await _pumpEditor(
      tester,
      _character(playerName: 'Marcos', backgroundId: 'acolyte'),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Marcos'),
      '   ',
    );
    await tester.pumpAndSettle();

    await _tapSave(tester);

    expect(repository.updated!.playerName, isNull);
  });

  testWidgets('trocar para o antecedente customizável salva perícias e '
      'características, e concede proficiência', (tester) async {
    final repository = await _pumpEditor(
      tester,
      _character(backgroundId: 'acolyte'),
    );

    await _selectInDropdown(
      tester,
      'Antecedente',
      BackgroundEntry.customId,
    );

    expect(find.text('Monte o seu antecedente'), findsOneWidget);

    await _selectInDropdown(tester, 'Primeira perícia', Skill.stealth.id);
    await _selectInDropdown(tester, 'Segunda perícia', Skill.survival.id);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do antecedente (opcional)'),
      'Caçador de Recompensas',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Características do antecedente'),
      'Mandado sempre em aberto.',
    );
    await tester.pumpAndSettle();

    await _tapSave(tester);

    final saved = repository.updated!;
    expect(saved.backgroundId, BackgroundEntry.customId);
    expect(saved.customBackground.name, 'Caçador de Recompensas');
    expect(
      saved.customBackground.skillIds,
      [Skill.stealth.id, Skill.survival.id],
    );
    expect(saved.customBackground.features, 'Mandado sempre em aberto.');
    expect(
      saved.skillProficiencies.levelFor(Skill.stealth),
      ProficiencyLevel.proficient,
    );
    expect(
      saved.skillProficiencies.levelFor(Skill.survival),
      ProficiencyLevel.proficient,
    );
  });

  testWidgets('voltar para um antecedente do compêndio descarta o customizado',
      (tester) async {
    final repository = await _pumpEditor(
      tester,
      _character(
        backgroundId: BackgroundEntry.customId,
        customBackground: const CustomBackground(
          name: 'Caçador de Recompensas',
          skillIds: ['stealth', 'survival'],
          features: 'Mandado em aberto.',
        ),
      ),
    );

    // O formulário do customizável já vem aberto e preenchido.
    expect(find.text('Monte o seu antecedente'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Caçador de Recompensas'),
      findsOneWidget,
    );

    await _selectInDropdown(tester, 'Antecedente', 'acolyte');
    await _tapSave(tester);

    final saved = repository.updated!;
    expect(saved.backgroundId, 'acolyte');
    expect(saved.customBackground.isEmpty, isTrue);
    // As perícias do novo antecedente entram...
    expect(
      saved.skillProficiencies.levelFor(Skill.insight),
      ProficiencyLevel.proficient,
    );
    // ...e as do antigo não são removidas, porque não há como saber se vieram
    // do antecedente ou de outra fonte.
    expect(
      saved.skillProficiencies.levelFor(Skill.stealth),
      ProficiencyLevel.none,
    );
  });

  testWidgets('não rebaixa uma proficiência que já era especialista',
      (tester) async {
    final repository = await _pumpEditor(
      tester,
      _character(
        backgroundId: BackgroundEntry.customId,
        skills: const SkillProficiencies(
          levels: {Skill.insight: ProficiencyLevel.expertise},
        ),
      ),
    );

    await _selectInDropdown(tester, 'Antecedente', 'acolyte');
    await _tapSave(tester);

    expect(
      repository.updated!.skillProficiencies.levelFor(Skill.insight),
      ProficiencyLevel.expertise,
    );
  });

  testWidgets('não salva sem nome', (tester) async {
    final repository = await _pumpEditor(
      tester,
      _character(name: 'Vex', backgroundId: 'acolyte'),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Vex'), '  ');
    await tester.pumpAndSettle();

    await _tapSave(tester);

    expect(repository.updated, isNull);
  });

  testWidgets('não salva o customizável sem as duas perícias', (tester) async {
    final repository = await _pumpEditor(
      tester,
      _character(backgroundId: 'acolyte'),
    );

    await _selectInDropdown(
      tester,
      'Antecedente',
      BackgroundEntry.customId,
    );
    await _selectInDropdown(tester, 'Primeira perícia', Skill.stealth.id);
    await _tapSave(tester);

    expect(repository.updated, isNull);
    // Aqui a página é curta: o dropdown continua montado, então o aviso vem
    // do validator inline. Na criação, que rola muito, a mesma regra é pega
    // pela checagem de estado no _save.
    expect(find.text('Escolha a segunda perícia.'), findsOneWidget);
  });
}
