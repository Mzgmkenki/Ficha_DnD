import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_creation_page.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/weapon_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCharacterRepository implements CharacterRepository {
  Character? created;

  @override
  Future<void> create(Character character) async => created = character;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

const _fighter = ClassEntry(
  id: 'fighter',
  name: 'Guerreiro',
  hitDie: 'd10',
  source: 'phb',
  skillOptions: ['athletics'],
  savingThrows: ['strength', 'constitution'],
  primaryAbility: 'strength',
  skillChoices: 0,
);

const _monk = ClassEntry(
  id: 'monk',
  name: 'Monge',
  hitDie: 'd8',
  source: 'phb',
  skillOptions: ['acrobatics'],
  savingThrows: ['strength', 'dexterity'],
  primaryAbility: 'dexterity',
  skillChoices: 0,
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

const _catalog = <WeaponEntry>[
  WeaponEntry(
    id: 'longsword',
    name: 'Espada Longa',
    category: WeaponCategory.martial,
    rangeType: WeaponRangeType.melee,
    damageType: WeaponDamageType.slashing,
  ),
  WeaponEntry(
    id: 'club',
    name: 'Clava',
    category: WeaponCategory.simple,
    rangeType: WeaponRangeType.melee,
    damageType: WeaponDamageType.bludgeoning,
  ),
];

const _fighterEquipment = ClassStartingEquipment(
  classId: 'fighter',
  className: 'Guerreiro',
  groups: [
    ClassEquipmentGroup(
      id: 'armor',
      label: 'Armadura inicial',
      options: [
        ClassEquipmentOption(
          id: 'chain_mail',
          label: 'Cota de malha',
          items: [
            ClassEquipmentItem(
              id: 'chain_mail',
              name: 'Cota de malha',
              armorId: 'chain_mail',
              category: ItemCategory.armor,
            ),
          ],
        ),
        ClassEquipmentOption(
          id: 'leather',
          label: 'Armadura de couro',
          items: [
            ClassEquipmentItem(
              id: 'leather',
              name: 'Armadura de couro',
              armorId: 'leather',
              category: ItemCategory.armor,
            ),
          ],
        ),
      ],
    ),
    ClassEquipmentGroup(
      id: 'martial',
      label: 'Armas marciais',
      options: [
        ClassEquipmentOption(
          id: 'single',
          label: 'Uma arma marcial',
          picks: [
            ClassEquipmentPick(
              id: 'martial',
              label: 'Escolha uma arma marcial',
              weaponCategory: WeaponCategory.martial,
            ),
          ],
        ),
        ClassEquipmentOption(
          id: 'club',
          label: 'Uma clava',
          items: [
            ClassEquipmentItem(
              id: 'club',
              name: 'Clava',
              weaponId: 'club',
              category: ItemCategory.weapon,
            ),
          ],
        ),
      ],
    ),
  ],
);

const _monkEquipment = ClassStartingEquipment(
  classId: 'monk',
  className: 'Monge',
  fixedItems: [
    ClassEquipmentItem(
      id: 'explorers_pack',
      name: 'Pacote de explorador',
    ),
  ],
);

Future<_FakeCharacterRepository> _pump(
  WidgetTester tester, {
  List<ClassEntry> classes = const [_fighter, _monk],
}) async {
  final repository = _FakeCharacterRepository();

  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterRepositoryProvider.overrideWithValue(repository),
        classEntriesProvider.overrideWith((ref) => classes),
        raceEntriesProvider.overrideWith((ref) => const [_human]),
        backgroundEntriesProvider.overrideWith((ref) => const [_acolyte]),
        subclassEntriesProvider.overrideWith((ref) => const []),
        spellEntriesProvider.overrideWith((ref) => const []),
        weaponEntriesProvider.overrideWith((ref) => _catalog),
        classEquipmentProvider.overrideWith(
          (ref) => const [_fighterEquipment, _monkEquipment],
        ),
      ],
      child: MaterialApp(
        home: const CharacterCreationPage(),
        onGenerateRoute:
            (_) => MaterialPageRoute<void>(builder: (_) => const Text('FICHA')),
      ),
    ),
  );
  await tester.pump();
  // Um pump a mais: a concessão da classe auto-selecionada acontece no
  // post-frame do primeiro build.
  await tester.pump();

  return repository;
}

/// Preenche o que a criação exige fora do equipamento.
Future<void> _fillRequiredFields(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).first, 'Bruenor');
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

  final background = tester.widget<DropdownButtonFormField<String>>(
    find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == 'Antecedente',
    ),
  );
  background.onChanged!('acolyte');
  await tester.pump();
}

Future<void> _tapOption(
  WidgetTester tester,
  String groupId,
  String optionId,
) async {
  final finder = find.byKey(ValueKey('class-equipment-option-$groupId-$optionId'));
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
}

void _choosePick(WidgetTester tester, String key, String itemId) {
  final field = tester.widget<DropdownButtonFormField<String>>(
    find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.key.toString().contains('class-equipment-pick-$key'),
    ),
  );
  field.onChanged!(itemId);
}

Future<void> _tapCreate(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Criar personagem');
  await tester.ensureVisible(button);
  await tester.tap(button, warnIfMissed: false);
  await tester.pump();
}

void main() {
  testWidgets('a seção aparece com os grupos da classe selecionada',
      (tester) async {
    await _pump(tester);

    expect(find.byKey(const ValueKey('class-equipment-section')), findsOneWidget);
    expect(find.text('Equipamentos iniciais da classe'), findsOneWidget);
    expect(find.text('Armadura inicial'), findsOneWidget);
    expect(find.text('Armas marciais'), findsOneWidget);
    expect(find.text('Escolha 1 de 2 opções'), findsNWidgets(2));
  });

  testWidgets('nenhuma alternativa vem pré-selecionada', (tester) async {
    await _pump(tester);

    // Duas escolhas pendentes, e o aviso de pendência visível.
    expect(find.byKey(const ValueKey('class-equipment-error')), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked), findsNothing);
    expect(find.text('Obrigatória'), findsNWidgets(2));
  });

  testWidgets('item fixo aparece como recebido automaticamente',
      (tester) async {
    await _pump(tester, classes: const [_monk]);

    expect(find.byKey(const ValueKey('class-equipment-fixed')), findsOneWidget);
    expect(find.text('Recebido automaticamente'), findsOneWidget);
    expect(find.text('Pacote de explorador'), findsWidgets);
    // Classe só com item fixo não tem pendência.
    expect(find.byKey(const ValueKey('class-equipment-error')), findsNothing);
  });

  testWidgets('escolher uma alternativa alimenta o resumo', (tester) async {
    await _pump(tester);

    await _tapOption(tester, 'armor', 'chain_mail');

    final summary = find.byKey(const ValueKey('class-equipment-summary'));
    expect(summary, findsOneWidget);
    expect(
      find.descendant(of: summary, matching: find.text('Classe de Armadura')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summary, matching: find.text('Cota de malha')),
      findsOneWidget,
    );
  });

  testWidgets('a escolha por categoria abre o seletor da alternativa',
      (tester) async {
    await _pump(tester);

    expect(find.text('Escolha uma arma marcial'), findsNothing);

    await _tapOption(tester, 'martial', 'single');

    // O seletor só existe depois de escolher a alternativa que o pede.
    expect(find.text('Escolha uma arma marcial'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.key.toString().contains('class-equipment-pick'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('não cria o personagem com escolha pendente', (tester) async {
    final repository = await _pump(tester);
    await _fillRequiredFields(tester);

    // Só a armadura escolhida: falta o grupo das armas marciais.
    await _tapOption(tester, 'armor', 'chain_mail');

    await _tapCreate(tester);
    await tester.pump();

    expect(repository.created, isNull);
    expect(find.textContaining('Falta escolher'), findsWidgets);
  });

  testWidgets('cria o personagem com as escolhas completas, e cada item vai '
      'para a sua área', (tester) async {
    final repository = await _pump(tester);
    await _fillRequiredFields(tester);

    await _tapOption(tester, 'armor', 'chain_mail');
    await _tapOption(tester, 'martial', 'single');
    _choosePick(tester, 'martial|single|martial', 'longsword');
    await tester.pump();

    await _tapCreate(tester);
    await tester.pumpAndSettle();

    final created = repository.created;
    expect(created, isNotNull);

    // Arma na seção de Armas, com a origem registrada.
    expect(created!.weapons, hasLength(1));
    expect(created.weapons.single.weaponId, 'longsword');
    expect(created.weapons.single.source, GrantSource.characterClass);
    expect(created.weapons.single.sourceId, 'fighter');

    // Armadura no inventário, reconhecida e equipada pelo gerenciamento de CA.
    final armor = OwnedArmor.equippedWearable(created.inventory);
    expect(armor?.armor?.id, 'chain_mail');

    // E a CA do personagem já sai da armadura vestida.
    expect(created.combatStats.armorClass, 16);
  });

  testWidgets('trocar de classe troca os grupos e devolve o equipamento',
      (tester) async {
    final repository = await _pump(tester);
    await _fillRequiredFields(tester);

    await _tapOption(tester, 'armor', 'chain_mail');
    await _tapOption(tester, 'martial', 'club');

    final classField = tester.widget<DropdownButtonFormField<String>>(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.labelText == 'Classe',
      ),
    );
    classField.onChanged!('monk');
    await tester.pump();
    await tester.pump();

    // Os grupos do Guerreiro saíram, o fixo do Monge entrou.
    expect(find.text('Armadura inicial'), findsNothing);
    expect(find.text('Recebido automaticamente'), findsOneWidget);
    expect(find.byKey(const ValueKey('class-equipment-error')), findsNothing);

    await _tapCreate(tester);
    await tester.pumpAndSettle();

    final created = repository.created;
    expect(created, isNotNull);

    // Nada do Guerreiro sobrou.
    expect(created!.weapons, isEmpty);
    expect(
      created.inventory.map((item) => item.itemId),
      ['explorers_pack'],
    );
  });
}
