import 'package:dnd_ficha_app/features/character/application/use_cases/character/choose_subclass.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/sync_subclass_spells.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Repositório em memória: `findById` alimenta o caso de uso, `update` guarda o
/// resultado e as magias entram na lista para o teste conferir a sincronização.
class _FakeCharacterRepository implements CharacterRepository {
  _FakeCharacterRepository(this.stored);

  Character stored;
  Character? updated;
  final List<CharacterSpell> added = [];

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Future<void> update(Character character) async {
    updated = character;
    stored = character;
  }

  @override
  Future<void> addCharacterSpell({
    required String characterId,
    required CharacterSpell spell,
  }) async {
    added.add(spell);
    stored = stored.copyWith(spells: [...stored.spells, spell]);
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

/// Repositório que falha ao mexer nas magias, para provar que a subclasse
/// gravada sobrevive à falha da sincronização.
class _BrokenSpellRepository extends _FakeCharacterRepository {
  _BrokenSpellRepository(super.stored);

  @override
  Future<void> addCharacterSpell({
    required String characterId,
    required CharacterSpell spell,
  }) async {
    throw Exception('banco indisponível');
  }
}

const _lifeDomain = SubclassEntry(
  id: 'cleric_life_domain',
  classId: 'cleric',
  name: 'Domínio da Vida',
  source: 'phb',
  spells: [
    SubclassSpellGrant(level: 1, spellNames: ['Bênção']),
  ],
);

const _champion = SubclassEntry(
  id: 'fighter_champion',
  classId: 'fighter',
  name: 'Campeão',
  source: 'phb',
);

const _subclasses = [_lifeDomain, _champion];

const _bless = SpellEntry(
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

final _spellIndex = SpellNameIndex(const [_bless]);

Character _cleric({int level = 1, String? subclassId}) {
  return characterFixture(
    classLevels: [
      ClassLevel(classId: 'cleric', level: level, subclassId: subclassId),
    ],
  );
}

void main() {
  group('gravar a escolha', () {
    test('define a subclasse na classe certa', () async {
      final repository = _FakeCharacterRepository(_cleric());

      final error = await ChooseSubclass(
        repository,
        SyncSubclassSpells(repository),
      )(
        characterId: 'c1',
        classId: 'cleric',
        subclassId: 'cleric_life_domain',
        subclasses: _subclasses,
        spellIndex: _spellIndex,
      );

      expect(error, isNull);
      expect(
        repository.updated!.classLevels.single.subclassId,
        'cleric_life_domain',
      );
    });

    test('não mexe no nível nem na ordem das classes', () async {
      // A ordem importa: o cálculo de PV trata a primeira classe como inicial.
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(classId: 'fighter', level: 5),
            ClassLevel(classId: 'cleric', level: 1),
          ],
        ),
      );

      await ChooseSubclass(repository, SyncSubclassSpells(repository))(
        characterId: 'c1',
        classId: 'cleric',
        subclassId: 'cleric_life_domain',
        subclasses: _subclasses,
        spellIndex: _spellIndex,
      );

      final levels = repository.updated!.classLevels;
      expect(levels.map((item) => item.classId), ['fighter', 'cleric']);
      expect(levels.first.level, 5);
      expect(levels.last.level, 1);
      expect(levels.first.subclassId, isNull);
    });

    test('as magias da subclasse entram no livro', () async {
      final repository = _FakeCharacterRepository(_cleric());

      await ChooseSubclass(repository, SyncSubclassSpells(repository))(
        characterId: 'c1',
        classId: 'cleric',
        subclassId: 'cleric_life_domain',
        subclasses: _subclasses,
        spellIndex: _spellIndex,
      );

      expect(repository.added, hasLength(1));
      expect(repository.added.single.spellId, 42);
      expect(repository.added.single.sourceType, 'subclass');
    });
  });

  group('recusas', () {
    test('recusa subclasse de outra classe', () async {
      // Um id de outra classe deixaria a ficha com um arquétipo que nunca
      // libera característica nenhuma.
      final repository = _FakeCharacterRepository(_cleric());

      await expectLater(
        ChooseSubclass(repository, SyncSubclassSpells(repository))(
          characterId: 'c1',
          classId: 'cleric',
          subclassId: 'fighter_champion',
          subclasses: _subclasses,
          spellIndex: _spellIndex,
        ),
        throwsA(isA<Exception>()),
      );

      expect(repository.updated, isNull);
    });

    test('recusa subclasse que não existe', () async {
      final repository = _FakeCharacterRepository(_cleric());

      await expectLater(
        ChooseSubclass(repository, SyncSubclassSpells(repository))(
          characterId: 'c1',
          classId: 'cleric',
          subclassId: 'inventada',
          subclasses: _subclasses,
          spellIndex: _spellIndex,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('recusa classe que o personagem não tem', () async {
      final repository = _FakeCharacterRepository(_cleric());

      await expectLater(
        ChooseSubclass(repository, SyncSubclassSpells(repository))(
          characterId: 'c1',
          classId: 'fighter',
          subclassId: 'fighter_champion',
          subclasses: _subclasses,
          spellIndex: _spellIndex,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('falha nas magias', () {
    test('a subclasse fica gravada e o erro é devolvido, não lançado', () async {
      // Desfazer a escolha por causa das magias seria pior que avisar.
      final repository = _BrokenSpellRepository(_cleric());

      final error = await ChooseSubclass(
        repository,
        SyncSubclassSpells(repository),
      )(
        characterId: 'c1',
        classId: 'cleric',
        subclassId: 'cleric_life_domain',
        subclasses: _subclasses,
        spellIndex: _spellIndex,
      );

      expect(error, isNotNull);
      expect(
        repository.updated!.classLevels.single.subclassId,
        'cleric_life_domain',
      );
    });
  });
}
