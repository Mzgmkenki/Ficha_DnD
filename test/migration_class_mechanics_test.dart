import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_json_codec.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_mapper.dart';
import 'package:dnd_ficha_app/features/character/data/repositories/character_repository_impl.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart'
    as domain;
// A tabela nova gera uma linha com o mesmo nome da entidade de domínio.
import 'package:dnd_ficha_app/features/character/domain/entities/character_class_mechanic.dart'
    as domain_mechanics;
import 'package:dnd_ficha_app/features/character/domain/entities/character_feature_state.dart'
    as domain_feature_states;
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_mechanic_entry.dart';
// O drift também exporta `isNull`/`isNotNull` para montar SQL; aqui valem os
// matchers do teste.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v23 → v24: mecânicas internas de classe e subclasse.
void main() {
  /// Cria um banco no schema atual e o rebaixa para a v23.
  ///
  /// Mesma receita dos outros testes de migração: o projeto não guarda dumps
  /// por versão, então o estado antigo é reconstruído apagando o que a v24
  /// acrescentou.
  Future<File> databaseAtVersion23(String prefix) async {
    final directory = await Directory.systemTemp.createTemp(prefix);
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/dnd.sqlite');

    final now = DateTime(2026, 10, 16);
    final old = AppDatabase.forTesting(NativeDatabase(file));

    await old
        .into(old.characters)
        .insert(
          CharactersCompanion.insert(
            id: 'velho',
            name: 'Dagna',
            speciesId: const Value('dwarf'),
            backgroundId: const Value('soldier'),
            strength: const Value(16),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await old
        .into(old.characterClassLevels)
        .insert(
          CharacterClassLevelsCompanion.insert(
            characterId: 'velho',
            classId: 'fighter',
            level: 7,
            subclassId: const Value('fighter_battle_master'),
          ),
        );

    // Estado de característica ANTIGO, com chave `subclass.*`. Ele precisa
    // sobreviver: é o que prova que a migração não encosta no que já existia.
    await old
        .into(old.characterFeatureStates)
        .insert(
          CharacterFeatureStatesCompanion.insert(
            characterId: 'velho',
            featureId: 'subclass.fighter_battle_master.3.estudante_da_guerra',
            usesSpent: const Value(1),
          ),
        );

    await old.customStatement('DROP TABLE character_class_mechanics');
    await old.customStatement('PRAGMA user_version = 23');
    await old.close();

    return file;
  }

  group('migração de personagem antigo', () {
    test('o Guerreiro da v23 continua abrindo depois da migração', () async {
      final file = await databaseAtVersion23('dnd_migracao_v24_abre');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final row = await db.select(db.characters).getSingle();
      final levels = await db.select(db.characterClassLevels).get();

      final character = CharacterMapper.fromDatabase(
        character: row,
        classLevels: levels,
      );

      expect(character.name, 'Dagna');
      expect(character.classLevels.single.classId, 'fighter');
      expect(character.classLevels.single.level, 7);
      expect(character.classLevels.single.subclassId, 'fighter_battle_master');
    });

    test('a tabela nasce vazia, sem inventar escolha', () async {
      // Até a v23 o app nunca gravou mecânica: "Aprende três manobras" existia
      // só como texto do compêndio, sem lista, sem limite e sem efeito. Não há
      // seleção antiga para preservar, e deduzir quais das 23 manobras o
      // jogador teria pego mudaria a ficha de quem não pediu nada.
      final file = await databaseAtVersion23('dnd_migracao_v24_vazio');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      expect(await db.select(db.characterClassMechanics).get(), isEmpty);
    });

    test('o estado de característica antigo sobrevive intacto', () async {
      // A migração não mexe em `character_feature_states`: as chaves de
      // mecânica usam o prefixo `mechanic.` e nunca foram gravadas, então não
      // há nada para converter — e converter teria exigido ler o banco dentro
      // da transação de migração.
      final file = await databaseAtVersion23('dnd_migracao_v24_preserva');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final states = await db.select(db.characterFeatureStates).get();

      expect(states, hasLength(1));
      expect(
        states.single.featureId,
        'subclass.fighter_battle_master.3.estudante_da_guerra',
      );
      expect(states.single.usesSpent, 1);
      expect(
        states.where((item) => item.featureId.startsWith('mechanic.')),
        isEmpty,
      );
    });

    test('o Guerreiro antigo chega ao domínio com a lista vazia', () async {
      final file = await databaseAtVersion23('dnd_migracao_v24_dominio');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final repository = CharacterRepositoryImpl(db);
      final character = await repository.findById('velho');

      expect(character, isNotNull);
      expect(character!.classMechanics, isEmpty);
    });

    test('depois de migrar, a tabela aceita INSERT', () async {
      // É como o bug do portrait_path aparecia: a leitura passava e só o
      // INSERT quebrava.
      final file = await databaseAtVersion23('dnd_migracao_v24_insert');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      await db
          .into(db.characterClassMechanics)
          .insert(
            CharacterClassMechanicsCompanion.insert(
              characterId: 'velho',
              mechanicId: 'fighter_battle_master.maneuvers',
              optionId: const Value('riposte'),
              chosenAtLevel: const Value(3),
              replacedOptionId: const Value('parry'),
              replacedAtLevel: const Value(7),
            ),
          );

      final row = await db.select(db.characterClassMechanics).getSingle();

      expect(row.mechanicId, 'fighter_battle_master.maneuvers');
      expect(row.optionId, 'riposte');
      expect(row.isSelected, isTrue);
      expect(row.chosenAtLevel, 3);
      expect(row.replacedOptionId, 'parry');
      expect(row.replacedAtLevel, 7);
    });

    test('migrar duas vezes não duplica nem falha', () async {
      final file = await databaseAtVersion23('dnd_migracao_v24_idempotente');

      final first = AppDatabase.forTesting(NativeDatabase(file));
      await first.select(first.characters).get();
      await first.close();

      final second = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(second.close);

      expect(await second.select(second.characters).get(), hasLength(1));
      expect(
        await second.select(second.characterClassMechanics).get(),
        isEmpty,
      );
      expect(
        await second.select(second.characterFeatureStates).get(),
        hasLength(1),
      );
    });

    test('nível negativo na base é lido como zero', () async {
      // Base editada à mão: histórico sem sentido não pode virar número
      // estranho na ficha.
      final file = await databaseAtVersion23('dnd_migracao_v24_clamp');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      await db
          .into(db.characterClassMechanics)
          .insert(
            CharacterClassMechanicsCompanion.insert(
              characterId: 'velho',
              mechanicId: 'fighter_battle_master.maneuvers',
              optionId: const Value('parry'),
              chosenAtLevel: const Value(-4),
            ),
          );

      final repository = CharacterRepositoryImpl(db);
      final character = await repository.findById('velho');

      expect(character!.classMechanics.single.chosenAtLevel, 0);
    });

    test('opção vazia na base é lida como registro de mecânica', () async {
      final file = await databaseAtVersion23('dnd_migracao_v24_opcao_vazia');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      await db
          .into(db.characterClassMechanics)
          .insert(
            CharacterClassMechanicsCompanion.insert(
              characterId: 'velho',
              mechanicId: 'sorcerer_wild_magic.wild_magic_surge',
              optionId: const Value(''),
              isSelected: const Value(true),
              rollResult: const Value('07_08'),
            ),
          );

      final repository = CharacterRepositoryImpl(db);
      final character = await repository.findById('velho');

      final record = character!.classMechanics.single;
      expect(record.optionId, isNull);
      expect(record.hasOption, isFalse);
      // Sem opção não há escolha: o resultado da tabela não gasta vaga.
      expect(record.countsAsPick, isFalse);
      expect(record.rollResult, '07_08');
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

    domain.Character build({
      List<domain_mechanics.CharacterClassMechanic> mechanics = const [],
      List<domain_feature_states.CharacterFeatureState> states = const [],
    }) {
      final now = DateTime(2026, 1, 1);

      return domain.Character(
        id: 'p1',
        name: 'Dagna',
        abilityScores: const AbilityScores(
          strength: 16,
          dexterity: 12,
          constitution: 14,
          intelligence: 10,
          wisdom: 10,
          charisma: 8,
        ),
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            level: 7,
            subclassId: 'fighter_battle_master',
          ),
        ],
        hitPoints: const HitPoints(current: 50, maximum: 50),
        combatStats: const CombatStats(
          armorClass: 16,
          initiativeBonus: 1,
          speedInMeters: 7.5,
        ),
        classMechanics: mechanics,
        featureStates: states,
        createdAt: now,
        updatedAt: now,
      );
    }

    final maneuvers = <domain_mechanics.CharacterClassMechanic>[
      const domain_mechanics.CharacterClassMechanic(
        mechanicId: 'fighter_battle_master.maneuvers',
        optionId: 'riposte',
        chosenAtLevel: 3,
      ),
      const domain_mechanics.CharacterClassMechanic(
        mechanicId: 'fighter_battle_master.maneuvers',
        optionId: 'parry',
        chosenAtLevel: 3,
        replacedOptionId: 'rally',
        replacedAtLevel: 7,
      ),
      const domain_mechanics.CharacterClassMechanic(
        mechanicId: 'sorcerer_wild_magic.wild_magic_surge',
        isSelected: false,
        rollResult: '07_08',
      ),
    ];

    test('as escolhas voltam iguais depois de gravar e ler', () async {
      await repository.create(build(mechanics: maneuvers));

      final loaded = await repository.findById('p1');
      final records = loaded!.classMechanics;

      expect(records, hasLength(3));

      final riposte = records.firstWhere((item) => item.optionId == 'riposte');
      expect(riposte.mechanicId, 'fighter_battle_master.maneuvers');
      expect(riposte.chosenAtLevel, 3);
      expect(riposte.countsAsPick, isTrue);

      final parry = records.firstWhere((item) => item.optionId == 'parry');
      expect(parry.replacedOptionId, 'rally');
      expect(parry.replacedAtLevel, 7);

      final surge = records.firstWhere((item) => item.hasRollResult);
      expect(surge.rollResult, '07_08');
      expect(surge.countsAsPick, isFalse);
    });

    test('os usos de mecânica viajam em featureStates', () async {
      final featureId = ClassMechanicEntry.mechanicFeatureId(
        'fighter_battle_master.maneuvers',
      );

      await repository.create(
        build(
          mechanics: maneuvers,
          states: [
            domain_feature_states.CharacterFeatureState(
              featureId: featureId,
              usesSpent: 2,
            ),
          ],
        ),
      );

      final loaded = await repository.findById('p1');

      expect(loaded!.featureStateFor(featureId)?.usesSpent, 2);
    });

    test('gravar o mesmo personagem várias vezes não duplica nada', () async {
      // É o requisito de idempotência: abrir e salvar não pode multiplicar
      // escolha, resultado de tabela nem contador.
      await repository.create(build(mechanics: maneuvers));

      for (var round = 0; round < 3; round++) {
        final loaded = await repository.findById('p1');
        await repository.update(loaded!);
      }

      final loaded = await repository.findById('p1');

      expect(loaded!.classMechanics, hasLength(3));
      expect(
        loaded.classMechanics
            .where((item) => item.optionId == 'riposte')
            .length,
        1,
      );
      expect(
        loaded.classMechanics.where((item) => item.hasRollResult).length,
        1,
      );
    });

    test('registro repetido no agregado grava uma vez só', () async {
      await repository.create(
        build(
          mechanics: [
            ...maneuvers,
            // Duplicata de opção e duplicata de registro de mecânica.
            const domain_mechanics.CharacterClassMechanic(
              mechanicId: 'fighter_battle_master.maneuvers',
              optionId: 'riposte',
              chosenAtLevel: 7,
            ),
            const domain_mechanics.CharacterClassMechanic(
              mechanicId: 'sorcerer_wild_magic.wild_magic_surge',
              isSelected: false,
              rollResult: '99_00',
            ),
          ],
        ),
      );

      final loaded = await repository.findById('p1');

      expect(loaded!.classMechanics, hasLength(3));
      // A primeira ocorrência vence, e com ela o nível original.
      expect(
        loaded.classMechanics
            .firstWhere((item) => item.optionId == 'riposte')
            .chosenAtLevel,
        3,
      );
      expect(
        loaded.classMechanics
            .firstWhere((item) => item.hasRollResult)
            .rollResult,
        '07_08',
      );
    });

    test('registro sem informação nenhuma não é gravado', () async {
      await repository.create(
        build(
          mechanics: const [
            domain_mechanics.CharacterClassMechanic(
              mechanicId: 'fighter_battle_master.maneuvers',
              isSelected: false,
            ),
          ],
        ),
      );

      final loaded = await repository.findById('p1');

      expect(loaded!.classMechanics, isEmpty);
    });

    test('apagar o personagem apaga as mecânicas dele', () async {
      await repository.create(build(mechanics: maneuvers));
      await repository.delete('p1');

      expect(
        await database.select(database.characterClassMechanics).get(),
        isEmpty,
      );
    });
  });

  group('exportação e importação', () {
    domain.Character build(
      List<domain_mechanics.CharacterClassMechanic> mechanics,
    ) {
      final now = DateTime(2026, 1, 1);

      return domain.Character(
        id: 'p1',
        name: 'Dagna',
        abilityScores: const AbilityScores(
          strength: 16,
          dexterity: 12,
          constitution: 14,
          intelligence: 10,
          wisdom: 10,
          charisma: 8,
        ),
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            level: 7,
            subclassId: 'fighter_battle_master',
          ),
        ],
        hitPoints: const HitPoints(current: 50, maximum: 50),
        combatStats: const CombatStats(
          armorClass: 16,
          initiativeBonus: 1,
          speedInMeters: 7.5,
        ),
        classMechanics: mechanics,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('a ficha exportada e reimportada mantém as escolhas', () {
      final original = build(const [
        domain_mechanics.CharacterClassMechanic(
          mechanicId: 'fighter_battle_master.maneuvers',
          optionId: 'riposte',
          chosenAtLevel: 3,
          replacedOptionId: 'parry',
          replacedAtLevel: 7,
        ),
        domain_mechanics.CharacterClassMechanic(
          mechanicId: 'sorcerer_wild_magic.wild_magic_surge',
          isSelected: false,
          rollResult: '07_08',
          note: 'bola de fogo no próprio pé',
        ),
      ]);

      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(original),
      );

      expect(restored.classMechanics, hasLength(2));

      final riposte = restored.classMechanics.first;
      expect(riposte.optionId, 'riposte');
      expect(riposte.chosenAtLevel, 3);
      expect(riposte.replacedOptionId, 'parry');
      expect(riposte.replacedAtLevel, 7);

      final surge = restored.classMechanics.last;
      expect(surge.optionId, isNull);
      expect(surge.rollResult, '07_08');
      expect(surge.note, 'bola de fogo no próprio pé');
      expect(surge.countsAsPick, isFalse);
    });

    test('importar o mesmo arquivo duas vezes não duplica escolha', () {
      final original = build(const [
        domain_mechanics.CharacterClassMechanic(
          mechanicId: 'fighter_battle_master.maneuvers',
          optionId: 'riposte',
          chosenAtLevel: 3,
        ),
        domain_mechanics.CharacterClassMechanic(
          mechanicId: 'fighter_battle_master.maneuvers',
          optionId: 'riposte',
          chosenAtLevel: 7,
        ),
      ]);

      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(original),
      );

      expect(restored.classMechanics, hasLength(1));
      expect(restored.classMechanics.single.chosenAtLevel, 3);
    });

    /// Reescreve o bloco do personagem no payload exportado, para simular
    /// arquivo de versão antiga ou editado à mão.
    String rewrite(
      String source,
      void Function(Map<String, dynamic> character) change,
    ) {
      final payload = Map<String, dynamic>.from(jsonDecode(source) as Map);
      final character = Map<String, dynamic>.from(payload['character'] as Map);

      change(character);
      payload['character'] = character;

      return jsonEncode(payload);
    }

    test('ficha de versão anterior importa sem a chave e sem erro', () {
      final encoded = rewrite(
        CharacterJsonCodec.encode(build(const [])),
        (payload) => payload.remove('classMechanics'),
      );

      final restored = CharacterJsonCodec.decode(encoded);

      expect(restored.classMechanics, isEmpty);
      expect(restored.name, 'Dagna');
    });

    test('registro sem id de mecânica é descartado na importação', () {
      final encoded = rewrite(
        CharacterJsonCodec.encode(build(const [])),
        (payload) =>
            payload['classMechanics'] = [
              <String, dynamic>{'optionId': 'riposte'},
              <String, dynamic>{'mechanicId': '  ', 'optionId': 'parry'},
            ],
      );

      final restored = CharacterJsonCodec.decode(encoded);

      expect(restored.classMechanics, isEmpty);
    });
  });
}
