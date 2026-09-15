import 'package:dnd_ficha_app/features/character/application/use_cases/character/level_up_character_class.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/sync_subclass_spells.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_class_levels.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/level_up_class_dialog.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

class _FakeRepository implements CharacterRepository {
  _FakeRepository(this.stored);

  Character stored;
  Character? updated;

  final List<CharacterSpell> addedSpells = [];

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
    addedSpells.add(spell);
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

/// Repositório que quebra na gravação das magias, para provar que o nível
/// gravado não é perdido por causa disso.
class _BrokenSpellRepository extends _FakeRepository {
  _BrokenSpellRepository(super.stored);

  @override
  Future<void> addCharacterSpell({
    required String characterId,
    required CharacterSpell spell,
  }) async {
    throw Exception('banco fora do ar');
  }
}

const _fighter = ClassEntry(
  id: 'fighter',
  name: 'Guerreiro',
  hitDie: 'd10',
  source: 'srd',
  skillOptions: [],
  savingThrows: ['strength', 'constitution'],
  subclassLevel: 3,
  subclassLabel: 'Arquétipo Marcial',
);

const _cleric = ClassEntry(
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

const _classes = [_fighter, _cleric];

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

/// Domínio que só concede a magia no 3º nível, para separar o que a subida
/// libera do que já estava liberado.
const _lifeDomain = SubclassEntry(
  id: 'cleric_life_domain',
  classId: 'cleric',
  name: 'Domínio da Vida',
  source: 'phb',
  spells: [
    SubclassSpellGrant(level: 3, spellNames: ['Bless']),
  ],
);

LevelUpCharacterClass _useCase(_FakeRepository repository) {
  return LevelUpCharacterClass(
    repository,
    UpdateCharacterClassLevels(repository),
    SyncSubclassSpells(repository),
  );
}

Future<LevelUpOutcome> _levelUp(
  _FakeRepository repository,
  String classId, {
  List<SubclassEntry> subclasses = const [],
}) {
  return _useCase(repository)(
    characterId: 'c1',
    classId: classId,
    classes: _classes,
    subclasses: subclasses,
    spellIndex: SpellNameIndex(const [_bless]),
  );
}

void main() {
  group('LevelUpCharacterClass', () {
    test('classe única sobe um nível e o PV máximo acompanha', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
          hitPoints: const HitPoints(current: 10, maximum: 10),
        ),
      );

      final outcome = await _levelUp(repository, 'fighter');

      expect(outcome.className, 'Guerreiro');
      expect(outcome.newLevel, 2);
      expect(outcome.totalLevel, 2);

      expect(repository.updated!.classLevels.single.level, 2);

      // d10: 10 no 1º nível, mais 6 (metade do dado + 1) no 2º, CON 10 não soma.
      expect(repository.updated!.hitPoints.maximum, 16);
      // Ganhar nível sobe o PV atual junto, na mesma medida.
      expect(repository.updated!.hitPoints.current, 16);
    });

    test('no multiclasse sobe só a classe escolhida', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(classId: 'fighter', level: 3),
            ClassLevel(classId: 'cleric', level: 2),
          ],
        ),
      );

      final outcome = await _levelUp(repository, 'cleric');

      expect(outcome.className, 'Clérigo');
      expect(outcome.newLevel, 3);
      expect(outcome.totalLevel, 6);

      final levels = repository.updated!.classLevels;
      expect(levels[0].level, 3, reason: 'guerreiro nao deveria mudar');
      expect(levels[1].level, 3);
    });

    test('mantém a ordem das classes, que define o PV do 1º nível', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(classId: 'fighter', level: 1),
            ClassLevel(classId: 'cleric', level: 1),
          ],
        ),
      );

      await _levelUp(repository, 'cleric');

      expect(
        repository.updated!.classLevels.map((e) => e.classId),
        ['fighter', 'cleric'],
      );
    });

    test('preserva a subclasse já escolhida', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'cleric',
              subclassId: 'cleric_life_domain',
              level: 2,
            ),
          ],
        ),
      );

      final outcome = await _levelUp(repository, 'cleric');

      expect(
        repository.updated!.classLevels.single.subclassId,
        'cleric_life_domain',
      );
      // Já tem subclasse, então não há escolha pendente.
      expect(outcome.needsSubclassChoice, isFalse);
    });

    test('avisa quando o novo nível abre a escolha de subclasse', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 2)],
        ),
      );

      final outcome = await _levelUp(repository, 'fighter');

      expect(outcome.pendingSubclassLabel, 'Arquétipo Marcial');
      // E não escolhe no lugar do jogador.
      expect(repository.updated!.classLevels.single.subclassId, isNull);
    });

    test('segue pedindo a subclasse acima do nível de escolha', () async {
      // Comportamento trocado de propósito: antes o aviso só saía na transição
      // exata, então quem passasse do 3º nível sem escolher o arquétipo nunca
      // era perguntado de novo e ficava com as características travadas para
      // sempre. Agora a decisão em aberto volta a ser oferecida, e quem já
      // escolheu não é incomodado (o teste seguinte cobre isso).
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 5)],
        ),
      );

      final outcome = await _levelUp(repository, 'fighter');

      expect(outcome.needsSubclassChoice, isTrue);
      expect(outcome.pendingSubclassLabel, 'Arquétipo Marcial');
    });

    test('não pede a subclasse de quem já escolheu', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'fighter',
              level: 5,
              subclassId: 'fighter_champion',
            ),
          ],
        ),
      );

      final outcome = await _levelUp(repository, 'fighter');

      expect(outcome.needsSubclassChoice, isFalse);
    });

    test('põe no livro a magia que o novo nível libera', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'cleric',
              subclassId: 'cleric_life_domain',
              level: 2,
            ),
          ],
        ),
      );

      final outcome = await _levelUp(
        repository,
        'cleric',
        subclasses: const [_lifeDomain],
      );

      expect(outcome.spellSyncError, isNull);
      expect(repository.addedSpells.single.spellId, 42);
      expect(repository.addedSpells.single.sourceType, subclassSpellSource);
    });

    test('falha nas magias não desfaz o nível, só é reportada', () async {
      final repository = _BrokenSpellRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'cleric',
              subclassId: 'cleric_life_domain',
              level: 2,
            ),
          ],
        ),
      );

      final outcome = await _levelUp(
        repository,
        'cleric',
        subclasses: const [_lifeDomain],
      );

      expect(outcome.newLevel, 3);
      expect(repository.updated!.classLevels.single.level, 3);
      expect(outcome.spellSyncError, isNotNull);
    });

    test('recusa passar do nível total 20', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 20)],
        ),
      );

      expect(
        () => _levelUp(repository, 'fighter'),
        throwsA(isA<Exception>()),
      );
    });

    test('recusa classe que o personagem não tem', () async {
      final repository = _FakeRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
      );

      expect(
        () => _levelUp(repository, 'cleric'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('showLevelUpClassDialog', () {
    Future<String?> pumpAndPick(
      WidgetTester tester, {
      required List<LevelUpClassOption> options,
      required int totalLevel,
      required String tapOn,
    }) async {
      String? picked;
      var returned = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  picked = await showLevelUpClassDialog(
                    context: context,
                    options: options,
                    totalLevel: totalLevel,
                  );
                  returned = true;
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(tapOn));
      await tester.pumpAndSettle();

      expect(returned, isTrue, reason: 'o dialogo nao devolveu');
      return picked;
    }

    testWidgets('devolve o classId da classe tocada', (tester) async {
      final picked = await pumpAndPick(
        tester,
        totalLevel: 5,
        options: const [
          LevelUpClassOption(
            classId: 'fighter',
            className: 'Guerreiro',
            level: 3,
          ),
          LevelUpClassOption(
            classId: 'cleric',
            className: 'Clérigo',
            level: 2,
          ),
        ],
        tapOn: 'Clérigo',
      );

      expect(picked, 'cleric');
    });

    testWidgets('mostra o nível atual e o que ele vira', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showLevelUpClassDialog(
                  context: context,
                  totalLevel: 5,
                  options: const [
                    LevelUpClassOption(
                      classId: 'fighter',
                      className: 'Guerreiro',
                      level: 3,
                    ),
                  ],
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Nível 3 → 4'), findsOneWidget);
      expect(find.textContaining('Faltam 15'), findsOneWidget);
    });

    testWidgets('cancelar devolve nulo', (tester) async {
      final picked = await pumpAndPick(
        tester,
        totalLevel: 5,
        options: const [
          LevelUpClassOption(
            classId: 'fighter',
            className: 'Guerreiro',
            level: 3,
          ),
        ],
        tapOn: 'Cancelar',
      );

      expect(picked, isNull);
    });

    testWidgets('classe no teto de 20 não é selecionável', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showLevelUpClassDialog(
                  context: context,
                  totalLevel: 20,
                  options: const [
                    LevelUpClassOption(
                      classId: 'fighter',
                      className: 'Guerreiro',
                      level: 20,
                    ),
                  ],
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Nível 20 (no teto)'), findsOneWidget);

      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.enabled, isFalse);
      expect(tile.onTap, isNull);
    });
  });
}
