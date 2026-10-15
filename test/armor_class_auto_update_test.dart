import 'dart:io';

// O drift gera classes de linha com os mesmos nomes de duas entidades de
// domínio usadas aqui. Nenhuma delas é necessária neste teste, então o `hide`
// resolve sem espalhar prefixo pelo arquivo.
import 'package:dnd_ficha_app/core/database/app_database.dart'
    hide Character, ClassEntry;
import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/data/repositories/character_repository_impl.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/combat_summary_card.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// A CA da ficha é DERIVADA, não lida do inteiro gravado.
///
/// O defeito que estes testes travam: subir a Destreza de um Monge não mudava
/// a CA na ficha. O número só era reescrito ao salvar a tela de CA, então era
/// preciso abrir e gravar aquela tela para a ficha acompanhar.
class _FakeCharacterRepository implements CharacterRepository {
  _FakeCharacterRepository(this.stored);

  Character stored;

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Future<void> update(Character character) async => stored = character;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

const _monk = ClassEntry(
  id: 'monk',
  name: 'Monge',
  hitDie: 'd8',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
);

/// Defesa sem Armadura do Monge: 10 + DES + SAB, sem armadura e sem escudo.
const _unarmoredDefense = ClassFeatureEntry(
  classId: 'monk',
  level: 1,
  source: 'phb',
  features: [
    ClassFeature(
      name: 'Defesa sem Armadura',
      description: 'Sem armadura, sua CA é 10 + DES + SAB.',
      effects: [
        FeatureEffect(
          id: 'monk.unarmored_defense',
          path: FeatureEffectPaths.armorClassBase,
          operation: FeatureEffectOperation.grant,
          formula: '10 + mod.dexterity + mod.wisdom',
          conditions: FeatureEffectConditions(
            armor: FeatureArmorCondition.none,
            shield: FeatureShieldCondition.forbidden,
          ),
          stacking: FeatureEffectStacking.exclusive,
          group: 'ac.base',
          unique: 'unarmored_defense',
          label: 'Defesa sem Armadura',
        ),
      ],
    ),
  ],
);

/// Monge com a CA gravada DESATUALIZADA de propósito.
///
/// `combatStats.armorClass: 10` é o número velho que a ficha mostrava antes
/// de alguém abrir a tela de CA. O derivado tem de ignorá-lo.
Character monk({
  int dexterity = 14,
  int wisdom = 16,
  int staleArmorClass = 10,
  int otherBonus = 0,
}) {
  return characterFixture(
    classLevels: const [ClassLevel(classId: 'monk', level: 1)],
    abilityScores: scoresWith(dexterity: dexterity, wisdom: wisdom),
    combatStats: CombatStats(
      armorClass: staleArmorClass,
      initiativeBonus: 0,
      speedInMeters: 9,
    ),
  ).copyWith(armorClassOtherBonus: otherBonus);
}

Future<void> pumpCard(WidgetTester tester, Character character) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterRepositoryProvider.overrideWithValue(
          _FakeCharacterRepository(character),
        ),
        classEntriesProvider.overrideWith((ref) => <ClassEntry>[_monk]),
        classFeaturesProvider.overrideWith(
          (ref) => <ClassFeatureEntry>[_unarmoredDefense],
        ),
        subclassEntriesProvider.overrideWith((ref) => <SubclassEntry>[]),
        featEntriesProvider.overrideWith((ref) => <FeatEntry>[]),
        raceEntriesProvider.overrideWith((ref) => <RaceEntry>[]),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CombatSummaryCard(character: character),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

/// O valor exibido embaixo do rótulo "CA".
String displayedArmorClass(WidgetTester tester) {
  final text = tester.widget<Text>(
    find.byKey(const ValueKey('combat-armor-class')),
  );
  return text.data ?? '';
}

void main() {
  group('a CA da ficha é derivada', () {
    testWidgets('ignora o inteiro gravado e usa a fórmula da classe', (
      tester,
    ) async {
      // DES 14 (+2), SAB 16 (+3) → 10 + 2 + 3 = 15. O gravado é 10.
      await pumpCard(tester, monk());

      expect(displayedArmorClass(tester), '15');
    });

    testWidgets('subir a Destreza muda a CA sem salvar nada', (tester) async {
      await pumpCard(tester, monk());
      expect(displayedArmorClass(tester), '15');

      // DES 14 → 18 (+4): 10 + 4 + 3 = 17. Nenhuma gravação no meio, e o
      // inteiro gravado continua 10.
      await pumpCard(tester, monk(dexterity: 18));

      expect(
        displayedArmorClass(tester),
        '17',
        reason: 'era este o defeito: a ficha ficava no número velho até '
            'alguém abrir e salvar a tela de CA',
      );
    });

    testWidgets('subir a Sabedoria também conta, no Monge', (tester) async {
      await pumpCard(tester, monk(wisdom: 20));

      // SAB 20 (+5): 10 + 2 + 5 = 17.
      expect(displayedArmorClass(tester), '17');
    });

    testWidgets('o bônus manual gravado entra na conta', (tester) async {
      await pumpCard(tester, monk(otherBonus: 2));

      // 10 + 2 + 3 + 2 de anel = 17.
      expect(displayedArmorClass(tester), '17');
    });

    testWidgets('bônus manual negativo também', (tester) async {
      await pumpCard(tester, monk(otherBonus: -1));
      expect(displayedArmorClass(tester), '14');
    });

    testWidgets('sem a característica, vale a CA do equipamento', (
      tester,
    ) async {
      // Guerreiro sem armadura: 10 + DES. A fórmula do Monge não vaza.
      final fighter = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        abilityScores: scoresWith(dexterity: 14, wisdom: 16),
        combatStats: const CombatStats(
          armorClass: 99,
          initiativeBonus: 0,
          speedInMeters: 9,
        ),
      );

      await pumpCard(tester, fighter);

      expect(displayedArmorClass(tester), '12');
    });
  });

  group('o bônus manual é persistido', () {
    late AppDatabase database;
    late CharacterRepositoryImpl repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = CharacterRepositoryImpl(database);
    });

    tearDown(() => database.close());

    test('sobrevive a fechar e abrir', () async {
      // Antes o campo "Outros bônus" era somado no total e esquecido: reabrir
      // a tela de CA zerava o campo e gravar de novo apagava o bônus.
      await repository.create(monk(otherBonus: 3));

      final loaded = await repository.findById('c1');
      expect(loaded!.armorClassOtherBonus, 3);
    });

    test('zerar é passar zero, e fica gravado', () async {
      await repository.create(monk(otherBonus: 3));

      final loaded = await repository.findById('c1');
      await repository.update(loaded!.copyWith(armorClassOtherBonus: 0));

      final cleared = await repository.findById('c1');
      expect(cleared!.armorClassOtherBonus, 0);
    });

    test('valor absurdo na base é limitado na leitura', () async {
      await repository.create(monk());

      await (database.update(database.characters)
            ..where((tbl) => tbl.id.equals('c1')))
          .write(const CharactersCompanion(armorClassOtherBonus: Value(999)));

      final loaded = await repository.findById('c1');
      expect(loaded!.armorClassOtherBonus, 20);
    });
  });

  group('migração v21 → v22', () {
    Future<File> databaseAtVersion21(String prefix) async {
      final directory = await Directory.systemTemp.createTemp(prefix);
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/dnd.sqlite');

      final now = DateTime(2026, 10, 15);
      final old = AppDatabase.forTesting(NativeDatabase(file));

      await old.into(old.characters).insert(
            CharactersCompanion.insert(
              id: 'velho',
              name: 'Kuno',
              dexterity: const Value(14),
              wisdom: const Value(16),
              // A CA que o jogador tinha gravado.
              armorClass: const Value(15),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await old.customStatement(
        'ALTER TABLE characters DROP COLUMN armor_class_other_bonus',
      );
      await old.customStatement('PRAGMA user_version = 21');
      await old.close();

      return file;
    }

    test('personagem da v21 continua abrindo, com bônus zero', () async {
      final file = await databaseAtVersion21('dnd_migracao_v22_abre');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final repository = CharacterRepositoryImpl(db);
      final character = await repository.findById('velho');

      expect(character, isNotNull);
      expect(character!.name, 'Kuno');
      expect(
        character.armorClassOtherBonus,
        0,
        reason: 'não há como decompor o total gravado em fórmula e bônus',
      );
      expect(
        character.combatStats.armorClass,
        15,
        reason: 'o total que o jogador tinha não é tocado pela migração',
      );
    });

    test('depois de migrar, a coluna aceita gravação', () async {
      final file = await databaseAtVersion21('dnd_migracao_v22_insert');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      await (db.update(db.characters)..where((tbl) => tbl.id.equals('velho')))
          .write(const CharactersCompanion(armorClassOtherBonus: Value(2)));

      final row = await db.select(db.characters).getSingle();
      expect(row.armorClassOtherBonus, 2);
    });

    test('migrar duas vezes não falha', () async {
      final file = await databaseAtVersion21('dnd_migracao_v22_idempotente');

      final first = AppDatabase.forTesting(NativeDatabase(file));
      await first.select(first.characters).get();
      await first.close();

      final second = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(second.close);

      expect(await second.select(second.characters).get(), hasLength(1));
    });
  });
}
