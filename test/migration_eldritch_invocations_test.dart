import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_json_codec.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_mapper.dart';
import 'package:dnd_ficha_app/features/character/data/repositories/character_repository_impl.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart'
    as domain;
// A tabela nova gera uma linha com o mesmo nome da entidade de domínio.
import 'package:dnd_ficha_app/features/character/domain/entities/character_eldritch_invocation.dart'
    as domain_invocations;
import 'package:dnd_ficha_app/features/character/domain/entities/character_feature_state.dart'
    as domain_feature_states;
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/pact_boon.dart';
// O drift também exporta `isNull`/`isNotNull` para montar SQL; aqui valem os
// matchers do teste.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v22 → v23: Invocações Místicas do Bruxo.
void main() {
  /// Cria um banco no schema atual e o rebaixa para a v22.
  ///
  /// Mesma receita dos outros testes de migração: o projeto não guarda dumps
  /// por versão, então o estado antigo é reconstruído apagando o que a v23
  /// acrescentou.
  Future<File> databaseAtVersion22(String prefix) async {
    final directory = await Directory.systemTemp.createTemp(prefix);
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/dnd.sqlite');

    final now = DateTime(2026, 10, 15);
    final old = AppDatabase.forTesting(NativeDatabase(file));

    await old.into(old.characters).insert(
          CharactersCompanion.insert(
            id: 'velho',
            name: 'Zariel',
            speciesId: const Value('tiefling'),
            backgroundId: const Value('charlatan'),
            charisma: const Value(16),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await old.into(old.characterClassLevels).insert(
          CharacterClassLevelsCompanion.insert(
            characterId: 'velho',
            classId: 'warlock',
            level: 5,
            subclassId: const Value('warlock_fiend'),
          ),
        );

    await old.customStatement('DROP TABLE character_eldritch_invocations');
    await old.customStatement('PRAGMA user_version = 22');
    await old.close();

    return file;
  }

  group('migração de personagem antigo', () {
    test('Bruxo da v22 continua abrindo depois da migração', () async {
      final file = await databaseAtVersion22('dnd_migracao_v23_abre');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final row = await db.select(db.characters).getSingle();
      final levels = await db.select(db.characterClassLevels).get();

      final character = CharacterMapper.fromDatabase(
        character: row,
        classLevels: levels,
      );

      expect(character.name, 'Zariel');
      expect(character.classLevels.single.classId, 'warlock');
      expect(character.classLevels.single.level, 5);
      expect(character.classLevels.single.subclassId, 'warlock_fiend');
    });

    test('a tabela nasce vazia, sem inventar invocação', () async {
      // Até a v22 o app nunca gravou invocação: "Invocações Místicas" existia
      // só como texto do compêndio, sem escolha nem limite. Não há seleção
      // antiga para preservar, e deduzir quais o jogador teria pego entre 54
      // opções mudaria a ficha de quem não pediu nada.
      final file = await databaseAtVersion22('dnd_migracao_v23_vazio');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      expect(
        await db.select(db.characterEldritchInvocations).get(),
        isEmpty,
      );
    });

    test('o Bruxo antigo chega ao domínio com a lista vazia', () async {
      final file = await databaseAtVersion22('dnd_migracao_v23_dominio');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final repository = CharacterRepositoryImpl(db);
      final character = await repository.findById('velho');

      expect(character, isNotNull);
      expect(character!.eldritchInvocations, isEmpty);
      // E nenhuma Dádiva do Pacto escolhida: ela também é decisão do jogador.
      expect(character.featureStateFor(PactBoon.featureId), isNull);
    });

    test('depois de migrar, a tabela aceita INSERT', () async {
      // É como o bug do portrait_path aparecia: leitura passava e só o INSERT
      // quebrava.
      final file = await databaseAtVersion22('dnd_migracao_v23_insert');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      await db.into(db.characterEldritchInvocations).insert(
            CharacterEldritchInvocationsCompanion.insert(
              characterId: 'velho',
              invocationId: 'agonizing_blast',
              chosenAtLevel: const Value(2),
              replacedInvocationId: const Value('beast_speech'),
              replacedAtLevel: const Value(5),
            ),
          );

      final row = await db
          .select(db.characterEldritchInvocations)
          .getSingle();

      expect(row.invocationId, 'agonizing_blast');
      expect(row.chosenAtLevel, 2);
      expect(row.replacedInvocationId, 'beast_speech');
      expect(row.replacedAtLevel, 5);
    });

    test('migrar duas vezes não duplica nem falha', () async {
      final file = await databaseAtVersion22('dnd_migracao_v23_idempotente');

      final first = AppDatabase.forTesting(NativeDatabase(file));
      await first.select(first.characters).get();
      await first.close();

      final second = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(second.close);

      expect(await second.select(second.characters).get(), hasLength(1));
      expect(
        await second.select(second.characterEldritchInvocations).get(),
        isEmpty,
      );
    });

    test('nível negativo na base é lido como zero', () async {
      // Base editada à mão: histórico sem sentido não pode virar número
      // estranho na ficha.
      final file = await databaseAtVersion22('dnd_migracao_v23_clamp');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      await db.into(db.characterEldritchInvocations).insert(
            CharacterEldritchInvocationsCompanion.insert(
              characterId: 'velho',
              invocationId: 'devils_sight',
              chosenAtLevel: const Value(-4),
            ),
          );

      final repository = CharacterRepositoryImpl(db);
      final character = await repository.findById('velho');

      expect(character!.eldritchInvocations.single.chosenAtLevel, 0);
    });
  });

  group('persistência após reiniciar o aplicativo', () {
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
        name: 'Zariel',
        speciesId: 'tiefling',
        abilityScores: const AbilityScores(
          strength: 8,
          dexterity: 14,
          constitution: 12,
          intelligence: 10,
          wisdom: 12,
          charisma: 16,
        ),
        classLevels: const [ClassLevel(classId: 'warlock', level: 5)],
        hitPoints: const HitPoints(current: 32, maximum: 32),
        combatStats: const CombatStats(
          armorClass: 12,
          initiativeBonus: 2,
          speedInMeters: 9,
        ),
        featureStates: const [
          domain_feature_states.CharacterFeatureState(
            featureId: PactBoon.featureId,
            choiceOptionId: 'pact_of_the_blade',
          ),
        ],
        eldritchInvocations: const [
          domain_invocations.CharacterEldritchInvocation(
            invocationId: 'agonizing_blast',
            chosenAtLevel: 2,
          ),
          domain_invocations.CharacterEldritchInvocation(
            invocationId: 'thirsting_blade',
            chosenAtLevel: 5,
            replacedInvocationId: 'beast_speech',
            replacedAtLevel: 5,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );
    }

    test('fecha e abre mantendo invocação, nível e histórico', () async {
      await repository.create(build());

      final loaded = await repository.findById('c1');

      expect(loaded, isNotNull);
      expect(loaded!.eldritchInvocations, hasLength(2));

      final first = loaded.eldritchInvocations.firstWhere(
        (item) => item.invocationId == 'agonizing_blast',
      );
      expect(first.chosenAtLevel, 2);
      expect(first.replacedSomething, isFalse);

      final replaced = loaded.eldritchInvocations.firstWhere(
        (item) => item.invocationId == 'thirsting_blade',
      );
      expect(replaced.chosenAtLevel, 5);
      expect(replaced.replacedInvocationId, 'beast_speech');
      expect(replaced.replacedAtLevel, 5);

      // A Dádiva do Pacto também sobrevive, pelo id.
      expect(
        loaded.featureStateFor(PactBoon.featureId)?.choiceOptionId,
        'pact_of_the_blade',
      );
    });

    test('gravar duas vezes não duplica linha', () async {
      await repository.create(build());

      final first = await repository.findById('c1');
      await repository.update(first!);
      await repository.update((await repository.findById('c1'))!);

      final loaded = await repository.findById('c1');

      expect(
        loaded!.eldritchInvocations,
        hasLength(2),
        reason: 'o `update` apaga e reinsere; duplicar gastaria duas vagas',
      );
      expect(
        loaded.eldritchInvocations.map((item) => item.invocationId).toSet(),
        {'agonizing_blast', 'thirsting_blade'},
      );
    });

    test('id repetido no agregado entra uma vez só', () async {
      await repository.create(build());

      final loaded = await repository.findById('c1');
      await repository.update(
        loaded!.copyWith(
          eldritchInvocations: [
            ...loaded.eldritchInvocations,
            ...loaded.eldritchInvocations,
          ],
        ),
      );

      final after = await repository.findById('c1');
      expect(after!.eldritchInvocations, hasLength(2));
    });

    test('remover a invocação apaga a linha e mantém o resto', () async {
      await repository.create(build());

      final loaded = await repository.findById('c1');
      await repository.update(
        loaded!.copyWith(
          eldritchInvocations: [
            for (final item in loaded.eldritchInvocations)
              if (item.invocationId != 'agonizing_blast') item,
          ],
        ),
      );

      final after = await repository.findById('c1');
      expect(after!.eldritchInvocations, hasLength(1));
      expect(after.eldritchInvocations.single.invocationId, 'thirsting_blade');
    });

    test('limpar todas as invocações é passar lista vazia', () async {
      await repository.create(build());

      final loaded = await repository.findById('c1');
      await repository.update(
        loaded!.copyWith(eldritchInvocations: const []),
      );

      final after = await repository.findById('c1');
      expect(after!.eldritchInvocations, isEmpty);
      expect(
        await database.select(database.characterEldritchInvocations).get(),
        isEmpty,
      );
    });

    test('apagar o personagem limpa a tabela de invocações', () async {
      await repository.create(build());
      await repository.delete('c1');

      expect(
        await database.select(database.characterEldritchInvocations).get(),
        isEmpty,
      );
    });

    test('exportar e importar preserva invocação e histórico', () async {
      final json = CharacterJsonCodec.encode(build());
      final imported = CharacterJsonCodec.decode(json, newId: 'c2');

      expect(imported.eldritchInvocations, hasLength(2));

      final replaced = imported.eldritchInvocations.firstWhere(
        (item) => item.invocationId == 'thirsting_blade',
      );
      expect(replaced.chosenAtLevel, 5);
      expect(replaced.replacedInvocationId, 'beast_speech');
      expect(replaced.replacedAtLevel, 5);

      expect(
        imported.featureStateFor(PactBoon.featureId)?.choiceOptionId,
        'pact_of_the_blade',
      );
    });

    test('importar o mesmo arquivo duas vezes não duplica invocação', () async {
      final map = CharacterJsonCodec.toMap(build());

      // Duplica a entrada no arquivo, como um merge manual mal feito faria.
      final list = List<dynamic>.from(
        map['eldritchInvocations'] as List<dynamic>,
      );
      map['eldritchInvocations'] = [...list, ...list];

      final imported = CharacterJsonCodec.fromMap(map, newId: 'c3');

      expect(
        imported.eldritchInvocations,
        hasLength(2),
        reason: 'o parser descarta id repetido',
      );
    });

    test('registro sem id de invocação é descartado na importação', () async {
      final map = CharacterJsonCodec.toMap(build());
      map['eldritchInvocations'] = [
        <String, dynamic>{'chosenAtLevel': 2},
        <String, dynamic>{'invocationId': '  ', 'chosenAtLevel': 2},
        <String, dynamic>{'invocationId': 'devils_sight'},
      ];

      final imported = CharacterJsonCodec.fromMap(map, newId: 'c4');

      expect(imported.eldritchInvocations, hasLength(1));
      expect(imported.eldritchInvocations.single.invocationId, 'devils_sight');
    });

    test('ficha sem o campo abre com a lista vazia', () async {
      // É o arquivo exportado por uma versão anterior a esta.
      final map = CharacterJsonCodec.toMap(build());
      map.remove('eldritchInvocations');

      final imported = CharacterJsonCodec.fromMap(map, newId: 'c5');

      expect(imported.eldritchInvocations, isEmpty);
      expect(imported.name, 'Zariel');
    });
  });
}
