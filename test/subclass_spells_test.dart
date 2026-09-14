import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/sync_subclass_spells.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/character_spells_panel.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Repositório que guarda as chamadas, para o teste olhar o que foi aplicado
/// sem precisar de banco.
class _FakeRepository implements CharacterRepository {
  _FakeRepository(this._character);

  Character _character;

  final List<CharacterSpell> added = [];
  final List<({int spellId, String sourceId})> removed = [];

  @override
  Future<Character?> findById(String id) async => _character;

  @override
  Future<void> addCharacterSpell({
    required String characterId,
    required CharacterSpell spell,
  }) async {
    added.add(spell);
    _character = _character.copyWith(spells: [..._character.spells, spell]);
  }

  @override
  Future<void> removeCharacterSpell({
    required String characterId,
    required int spellId,
    required String sourceType,
    required String sourceId,
  }) async {
    removed.add((spellId: spellId, sourceId: sourceId));
    _character = _character.copyWith(
      spells: _character.spells
          .where(
            (item) => !(item.spellId == spellId &&
                item.sourceType == sourceType &&
                item.sourceId == sourceId),
          )
          .toList(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

SpellEntry _spell(int id, String pt, String original, {int level = 1}) {
  return SpellEntry(
    id: id,
    namePt: pt,
    nameOriginal: original,
    level: level,
    school: 'Evocação',
    castingTime: 'Uma ação',
    range: '18 m',
    components: 'V S',
    hasCostlyMaterials: false,
    duration: 'Instantânea',
    concentration: false,
    ritual: false,
    classes: const ['cleric'],
    subclasses: const [],
    description: '',
    source: 'phb',
    page: '1',
    isSrd: true,
  );
}

final _compendium = [
  _spell(1, 'Bênção', 'Bless'),
  _spell(2, 'Curar Ferimentos', 'Cure Wounds'),
  _spell(3, 'Restauração Menor', 'Lesser Restoration', level: 2),
  _spell(4, 'Arma Espiritual', 'Spiritual Weapon', level: 2),
  _spell(5, 'Flecha Ácida', 'Acid Arrow', level: 2),
  _spell(6, 'Lâmina Verde Flamejante', 'Green-flame Blade'),
  _spell(7, 'Riso Histérico de Tasha', "Tasha's Hideous Laughter"),
];

const _lifeDomain = SubclassEntry(
  id: 'cleric_life_domain',
  classId: 'cleric',
  name: 'Domínio da Vida',
  source: 'phb',
  spells: [
    SubclassSpellGrant(level: 1, spellNames: ['Bless', 'Cure Wounds']),
    SubclassSpellGrant(
      level: 3,
      spellNames: ['Lesser Restoration', 'Spiritual Weapon'],
    ),
  ],
);

const _knowledgeDomain = SubclassEntry(
  id: 'cleric_knowledge_domain',
  classId: 'cleric',
  name: 'Domínio do Conhecimento',
  source: 'phb',
  spells: [
    SubclassSpellGrant(level: 1, spellNames: ['Bless']),
  ],
);

void main() {
  group('CharacterSpellsPanel', _panelTests);

  group('SpellNameIndex', () {
    final index = SpellNameIndex(_compendium);

    test('acha pelo nome em inglês e pelo nome em português', () {
      expect(index.find('Cure Wounds')?.id, 2);
      expect(index.find('Curar Ferimentos')?.id, 2);
    });

    test('ignora caixa, acento e espaços sobrando', () {
      expect(index.find('  restauracao MENOR ')?.id, 3);
    });

    test('ignora hífen', () {
      expect(index.find('Green Flame Blade')?.id, 6);
    });

    test('casa nome com autor contra nome sem autor', () {
      // O documento escreve "Melf's Acid Arrow"; o compêndio tem "Acid Arrow".
      expect(index.find("Melf's Acid Arrow")?.id, 5);
      // E o inverso: compêndio com autor, documento sem.
      expect(index.find('Hideous Laughter')?.id, 7);
    });

    test('devolve nulo para magia que não existe', () {
      expect(index.find('Magia Inventada'), isNull);
    });
  });

  group('SyncSubclassSpells', () {
    final index = SpellNameIndex(_compendium);

    test('põe no livro as magias liberadas até o nível atual', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'cleric',
              subclassId: 'cleric_life_domain',
              level: 1,
            ),
          ],
        ),
      );

      final result = await SyncSubclassSpells(repository)(
        characterId: 'c1',
        subclasses: const [_lifeDomain],
        spellIndex: index,
      );

      expect(result.added, 2);
      expect(result.removed, 0);
      expect(result.unknownSpellNames, isEmpty);

      // As de 3º nível ficam de fora enquanto o clérigo está no 1º.
      expect(repository.added.map((spell) => spell.spellId), {1, 2});

      // Magia de domínio é sempre preparada e não conta no limite.
      for (final spell in repository.added) {
        expect(spell.sourceType, subclassSpellSource);
        expect(spell.sourceId, 'cleric_life_domain');
        expect(spell.sourceName, 'Domínio da Vida');
        expect(spell.isPrepared, isTrue);
        expect(spell.isAlwaysAvailable, isTrue);
      }
    });

    test('nível maior libera as magias seguintes', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'cleric',
              subclassId: 'cleric_life_domain',
              level: 3,
            ),
          ],
        ),
      );

      await SyncSubclassSpells(repository)(
        characterId: 'c1',
        subclasses: const [_lifeDomain],
        spellIndex: index,
      );

      expect(repository.added.map((spell) => spell.spellId), {1, 2, 3, 4});
    });

    test('rodar de novo não duplica nada', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'cleric',
              subclassId: 'cleric_life_domain',
              level: 1,
            ),
          ],
          spells: const [
            CharacterSpell(
              spellId: 1,
              sourceType: subclassSpellSource,
              sourceId: 'cleric_life_domain',
              sourceName: 'Domínio da Vida',
              isPrepared: true,
              isKnown: true,
              isAlwaysAvailable: true,
            ),
          ],
        ),
      );

      final result = await SyncSubclassSpells(repository)(
        characterId: 'c1',
        subclasses: const [_lifeDomain],
        spellIndex: index,
      );

      // Só a que faltava.
      expect(result.added, 1);
      expect(result.removed, 0);
      expect(repository.added.single.spellId, 2);
    });

    test('trocar de subclasse tira as magias da anterior', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'cleric',
              subclassId: 'cleric_knowledge_domain',
              level: 1,
            ),
          ],
          spells: const [
            CharacterSpell(
              spellId: 2,
              sourceType: subclassSpellSource,
              sourceId: 'cleric_life_domain',
              sourceName: 'Domínio da Vida',
              isPrepared: true,
              isKnown: true,
              isAlwaysAvailable: true,
            ),
          ],
        ),
      );

      final result = await SyncSubclassSpells(repository)(
        characterId: 'c1',
        subclasses: const [_lifeDomain, _knowledgeDomain],
        spellIndex: index,
      );

      expect(result.removed, 1);
      expect(repository.removed.single.sourceId, 'cleric_life_domain');
      expect(repository.added.single.sourceId, 'cleric_knowledge_domain');
    });

    test('não mexe nas magias que o jogador adicionou por outra origem', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'cleric',
              subclassId: 'cleric_life_domain',
              level: 1,
            ),
          ],
          spells: const [
            CharacterSpell(
              spellId: 5,
              sourceType: 'class',
              sourceId: 'cleric',
              sourceName: 'Clérigo',
              isPrepared: false,
              isKnown: true,
              isAlwaysAvailable: false,
            ),
          ],
        ),
      );

      await SyncSubclassSpells(repository)(
        characterId: 'c1',
        subclasses: const [_lifeDomain],
        spellIndex: index,
      );

      expect(repository.removed, isEmpty);
    });

    test('nome fora do compêndio é reportado em vez de falhar em silêncio', () async {
      const broken = SubclassEntry(
        id: 'cleric_broken',
        classId: 'cleric',
        name: 'Domínio Quebrado',
        source: 'phb',
        spells: [
          SubclassSpellGrant(level: 1, spellNames: ['Magia Que Nao Existe']),
        ],
      );

      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'cleric',
              subclassId: 'cleric_broken',
              level: 1,
            ),
          ],
        ),
      );

      final result = await SyncSubclassSpells(repository)(
        characterId: 'c1',
        subclasses: const [broken],
        spellIndex: index,
      );

      expect(result.added, 0);
      expect(result.unknownSpellNames, ['Magia Que Nao Existe']);
    });
  });
}

/// A ficha agrupa as magias por origem. Sem uma seção própria, as da subclasse
/// caíam no balde de "Outras Origens", que existe para origens desconhecidas.
void _panelTests() {
  const clericEntry = ClassEntry(
    id: 'cleric',
    name: 'Clérigo',
    hitDie: 'd8',
    source: 'srd',
    skillOptions: [],
    savingThrows: ['wisdom', 'charisma'],
    spellcastingType: 'full',
    spellcastingAbility: 'wisdom',
    subclassLevel: 1,
    subclassLabel: 'Domínio Divino',
  );

  Future<void> pumpPanel(WidgetTester tester, Character character) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          spellEntriesProvider.overrideWith((ref) => _compendium),
          classEntriesProvider.overrideWith((ref) => const [clericEntry]),
          spellSlotProgressionsProvider.overrideWith(
            (ref) => const <SpellSlotProgressionEntry>[],
          ),
          characterUsedSpellSlotsProvider.overrideWith(
            (ref, characterId) => Stream.value(const <int, int>{}),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CharacterSpellsPanel(character: character),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('magia de subclasse ganha seção própria, e não "Outras Origens"', (
    tester,
  ) async {
    final character = characterFixture(
      classLevels: const [
        ClassLevel(classId: 'cleric', subclassId: 'cleric_life_domain', level: 1),
      ],
      spells: const [
        CharacterSpell(
          spellId: 1,
          sourceType: subclassSpellSource,
          sourceId: 'cleric_life_domain',
          sourceName: 'Domínio da Vida',
          isPrepared: true,
          isKnown: true,
          isAlwaysAvailable: true,
        ),
        CharacterSpell(
          spellId: 2,
          sourceType: 'class',
          sourceId: 'cleric',
          sourceName: 'Clérigo',
          isPrepared: true,
          isKnown: true,
          isAlwaysAvailable: false,
        ),
      ],
    );

    await pumpPanel(tester, character);

    expect(find.text('Magias de Subclasse (1)'), findsOneWidget);
    expect(find.text('Magias de Classe (1)'), findsOneWidget);
    expect(find.textContaining('Outras Origens'), findsNothing);

    // O grupo dentro da seção leva o nome da subclasse.
    expect(find.text('Domínio da Vida (1)'), findsOneWidget);

    // E a magia aparece marcada como sempre disponível.
    expect(find.textContaining('Sempre disponível'), findsOneWidget);
  });

  testWidgets('sem magia de subclasse, a seção não aparece', (tester) async {
    final character = characterFixture(
      classLevels: const [
        ClassLevel(classId: 'cleric', subclassId: 'cleric_life_domain', level: 1),
      ],
      spells: const [
        CharacterSpell(
          spellId: 2,
          sourceType: 'class',
          sourceId: 'cleric',
          sourceName: 'Clérigo',
          isPrepared: true,
          isKnown: true,
          isAlwaysAvailable: false,
        ),
      ],
    );

    await pumpPanel(tester, character);

    expect(find.textContaining('Magias de Subclasse'), findsNothing);
  });
}
