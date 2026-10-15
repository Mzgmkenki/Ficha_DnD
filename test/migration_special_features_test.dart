import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_mapper.dart';
import 'package:dnd_ficha_app/features/character/data/repositories/character_repository_impl.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_score_improvement.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart'
    as domain;
// A tabela nova gera uma classe de linha com o mesmo nome da entidade de
// domínio. O prefixo mantém as duas acessíveis sem ambiguidade.
import 'package:dnd_ficha_app/features/character/domain/entities/character_feature_state.dart'
    as domain_states;
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
// O drift também exporta `isNull` e `isNotNull`, para montar condição de SQL.
// Aqui o que vale é o matcher do teste.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v19 → v20: características especiais e Incremento no Valor de
/// Atributo.
///
/// O que estes testes protegem: personagem antigo continua abrindo, as tabelas
/// novas nascem vazias (nada é inventado a partir dos atributos gravados), e
/// carregar o mesmo personagem várias vezes não duplica nada.
void main() {
  /// Cria um banco no schema atual e o rebaixa para a v19.
  ///
  /// Mesma receita dos outros testes de migração: o projeto não guarda dumps
  /// por versão, então o estado antigo é reconstruído apagando o que a v20
  /// acrescentou.
  Future<File> databaseAtVersion19(String prefix) async {
    final directory = await Directory.systemTemp.createTemp(prefix);
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/dnd.sqlite');

    final now = DateTime(2026, 9, 22);
    final old = AppDatabase.forTesting(NativeDatabase(file));

    await old.into(old.characters).insert(
          CharactersCompanion.insert(
            id: 'velho',
            name: 'Grog',
            strength: const Value(17),
            constitution: const Value(16),
            dexterity: const Value(14),
            armorClass: const Value(15),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await old.into(old.characterClassLevels).insert(
          CharacterClassLevelsCompanion.insert(
            characterId: 'velho',
            classId: 'barbarian',
            level: 4,
          ),
        );

    await old.customStatement('DROP TABLE character_ability_improvements');
    await old.customStatement('DROP TABLE character_feature_states');
    await old.customStatement(
      'ALTER TABLE characters DROP COLUMN armor_class_formula_id',
    );
    await old.customStatement('PRAGMA user_version = 19');
    await old.close();

    return file;
  }

  test('personagem da v19 continua abrindo depois da migração', () async {
    final file = await databaseAtVersion19('dnd_migracao_v20_abre');

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final row = await db.select(db.characters).getSingle();
    final levels = await db.select(db.characterClassLevels).get();

    final character = CharacterMapper.fromDatabase(
      character: row,
      classLevels: levels,
    );

    expect(character.name, 'Grog');
    expect(character.abilityScores.strength, 17);
    expect(character.abilityScores.constitution, 16);
    expect(character.classLevels.single.classId, 'barbarian');
    expect(character.classLevels.single.level, 4);
  });

  test('as tabelas novas nascem vazias, sem inventar nada', () async {
    // Reconstruir incrementos a partir dos atributos gravados é impossível sem
    // adivinhar: o total não diz quanto veio da origem, de talento ou de
    // distribuição manual.
    final file = await databaseAtVersion19('dnd_migracao_v20_vazio');

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    expect(await db.select(db.characterAbilityImprovements).get(), isEmpty);
    expect(await db.select(db.characterFeatureStates).get(), isEmpty);

    final row = await db.select(db.characters).getSingle();
    expect(
      row.armorClassFormulaId,
      isNull,
      reason: 'nulo é "nunca escolheu"; gravar `equipment` afirmaria uma '
          'preferência que o jogador não declarou',
    );
  });

  test('depois de migrar, as tabelas novas aceitam INSERT', () async {
    // É como o bug do portrait_path aparecia: leitura passava e só o INSERT
    // quebrava.
    final file = await databaseAtVersion19('dnd_migracao_v20_insert');

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    await db.into(db.characterAbilityImprovements).insert(
          CharacterAbilityImprovementsCompanion.insert(
            characterId: 'velho',
            classId: 'barbarian',
            classLevel: 4,
            progressionId: 'asi.barbarian.4',
            appliedIncreases: const Value('strength:2'),
          ),
        );

    await db.into(db.characterFeatureStates).insert(
          CharacterFeatureStatesCompanion.insert(
            characterId: 'velho',
            featureId: 'class.barbarian.1.furia',
            usesSpent: const Value(1),
            isActive: const Value(true),
            choiceOptionId: const Value('bear'),
          ),
        );

    await (db.update(db.characters)
          ..where((tbl) => tbl.id.equals('velho')))
        .write(
      const CharactersCompanion(
        armorClassFormulaId: Value('barbarian.unarmored_defense'),
      ),
    );

    final improvement =
        await db.select(db.characterAbilityImprovements).getSingle();
    expect(improvement.classId, 'barbarian');
    expect(improvement.classLevel, 4);
    expect(improvement.appliedIncreases, 'strength:2');

    final state = await db.select(db.characterFeatureStates).getSingle();
    expect(state.featureId, 'class.barbarian.1.furia');
    expect(state.usesSpent, 1);
    expect(state.isActive, isTrue);
    expect(state.choiceOptionId, 'bear');

    final row = await db.select(db.characters).getSingle();
    expect(row.armorClassFormulaId, 'barbarian.unarmored_defense');
  });

  test('migrar duas vezes não duplica nem falha', () async {
    // Idempotência: abrir o mesmo banco de novo passa pelo `onUpgrade` só se a
    // versão for menor, mas o teste confere que reabrir não estraga nada.
    final file = await databaseAtVersion19('dnd_migracao_v20_idempotente');

    final first = AppDatabase.forTesting(NativeDatabase(file));
    await first.select(first.characters).get();
    await first.close();

    final second = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(second.close);

    expect(await second.select(second.characters).get(), hasLength(1));
    expect(await second.select(second.characterAbilityImprovements).get(),
        isEmpty);
  });

  group('persistência do agregado', () {
    late AppDatabase database;
    late CharacterRepositoryImpl repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = CharacterRepositoryImpl(database);
    });

    tearDown(() => database.close());

    domain.Character build() {
      final now = DateTime(2026, 1, 1);

      return domain.Character(
        id: 'c1',
        name: 'Grog',
        abilityScores: const AbilityScores(
          strength: 17,
          dexterity: 16,
          constitution: 16,
          intelligence: 8,
          wisdom: 10,
          charisma: 12,
        ),
        classLevels: const [ClassLevel(classId: 'barbarian', level: 4)],
        hitPoints: const HitPoints(current: 40, maximum: 40),
        combatStats: const CombatStats(
          armorClass: 16,
          initiativeBonus: 3,
          speedInMeters: 12,
        ),
        abilityImprovements: const [
          AbilityScoreImprovement(
            classId: 'barbarian',
            classLevel: 4,
            appliedIncreases: {'strength': 2},
          ),
        ],
        featureStates: const [
          domain_states.CharacterFeatureState(
            featureId: 'class.barbarian.1.furia',
            usesSpent: 2,
          ),
        ],
        armorClassFormulaId: 'barbarian.unarmored_defense',
        createdAt: now,
        updatedAt: now,
      );
    }

    test('fecha e abre mantendo incremento, estado e fórmula', () async {
      await repository.create(build());

      final loaded = await repository.findById('c1');

      expect(loaded, isNotNull);
      expect(loaded!.abilityImprovements, hasLength(1));
      expect(loaded.abilityImprovements.single.classId, 'barbarian');
      expect(loaded.abilityImprovements.single.classLevel, 4);
      expect(loaded.abilityImprovements.single.progressionId, 'asi.barbarian.4');
      expect(loaded.abilityImprovements.single.appliedIncreases, {
        'strength': 2,
      });

      expect(loaded.featureStates, hasLength(1));
      expect(loaded.featureStates.single.featureId, 'class.barbarian.1.furia');
      expect(loaded.featureStates.single.usesSpent, 2);

      expect(loaded.armorClassFormulaId, 'barbarian.unarmored_defense');
      expect(loaded.abilityScores.strength, 17);
    });

    test('gravar duas vezes não duplica linha', () async {
      await repository.create(build());

      final first = await repository.findById('c1');
      await repository.update(first!);
      await repository.update((await repository.findById('c1'))!);

      final loaded = await repository.findById('c1');

      expect(
        loaded!.abilityImprovements,
        hasLength(1),
        reason: 'o `update` apaga e reinsere; duplicar daria pontos de graça',
      );
      expect(loaded.featureStates, hasLength(1));
      expect(
        loaded.otherPermanentAbilityBonuses[Ability.strength],
        2,
        reason: 'o bônus permanente não pode somar duas vezes',
      );
      expect(
        loaded.abilityScores.strength,
        17,
        reason: 'o valor gravado não muda ao reler',
      );
    });

    test('estado sem nada guardado não gera linha', () async {
      // Um personagem com 200 características não precisa de 200 linhas
      // dizendo "zero usos, nada escolhido".
      await repository.create(build());

      final loaded = await repository.findById('c1');
      await repository.update(
        loaded!.copyWith(
          featureStates: const [
            domain_states.CharacterFeatureState(
              featureId: 'class.barbarian.1.furia',
            ),
            domain_states.CharacterFeatureState(
              featureId: 'class.barbarian.5.movimento',
            ),
          ],
        ),
      );

      final rows = await database.select(database.characterFeatureStates).get();
      expect(rows, isEmpty);
    });

    test('apagar o personagem limpa as tabelas novas', () async {
      await repository.create(build());
      await repository.delete('c1');

      expect(
        await database.select(database.characterAbilityImprovements).get(),
        isEmpty,
      );
      expect(
        await database.select(database.characterFeatureStates).get(),
        isEmpty,
      );
    });

    test('a fórmula de CA pode voltar para "nunca escolheu"', () async {
      await repository.create(build());

      final loaded = await repository.findById('c1');
      await repository.update(loaded!.copyWith(armorClassFormulaId: null));

      final cleared = await repository.findById('c1');
      expect(cleared!.armorClassFormulaId, isNull);
    });
  });
}
