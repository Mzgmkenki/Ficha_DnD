import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_json_codec.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_mapper.dart';
import 'package:dnd_ficha_app/features/character/data/repositories/character_repository_impl.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart'
    as domain;
// A tabela nova gera uma linha com o mesmo nome da entidade de domínio.
import 'package:dnd_ficha_app/features/character/domain/entities/character_language.dart'
    as domain_languages;
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
// O drift também exporta `isNull`/`isNotNull` para montar SQL; aqui valem os
// matchers do teste.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v20 → v21: idiomas do personagem.
void main() {
  /// Cria um banco no schema atual e o rebaixa para a v20.
  ///
  /// Mesma receita dos outros testes de migração: o projeto não guarda dumps
  /// por versão, então o estado antigo é reconstruído apagando o que a v21
  /// acrescentou.
  Future<File> databaseAtVersion20(String prefix) async {
    final directory = await Directory.systemTemp.createTemp(prefix);
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/dnd.sqlite');

    final now = DateTime(2026, 10, 15);
    final old = AppDatabase.forTesting(NativeDatabase(file));

    await old.into(old.characters).insert(
          CharactersCompanion.insert(
            id: 'velho',
            name: 'Tasha',
            speciesId: const Value('high_elf'),
            backgroundId: const Value('acolyte'),
            intelligence: const Value(16),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await old.into(old.characterClassLevels).insert(
          CharacterClassLevelsCompanion.insert(
            characterId: 'velho',
            classId: 'wizard',
            level: 3,
          ),
        );

    await old.customStatement('DROP TABLE character_languages');
    await old.customStatement('PRAGMA user_version = 20');
    await old.close();

    return file;
  }

  group('17. migração de personagem antigo', () {
    test('personagem da v20 continua abrindo depois da migração', () async {
      final file = await databaseAtVersion20('dnd_migracao_v21_abre');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final row = await db.select(db.characters).getSingle();
      final levels = await db.select(db.characterClassLevels).get();

      final character = CharacterMapper.fromDatabase(
        character: row,
        classLevels: levels,
      );

      expect(character.name, 'Tasha');
      expect(character.speciesId, 'high_elf');
      expect(character.backgroundId, 'acolyte');
      expect(character.classLevels.single.classId, 'wizard');
    });

    test('a tabela nasce vazia, sem inventar escolha', () async {
      // Até a v20 o app nunca gravou idioma: raça e antecedente só exibiam
      // texto do compêndio. Não há idioma antigo para preservar, e deduzir
      // qual o jogador teria escolhido mudaria a ficha de quem não pediu nada.
      final file = await databaseAtVersion20('dnd_migracao_v21_vazio');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      expect(await db.select(db.characterLanguages).get(), isEmpty);
    });

    test('o personagem antigo chega ao domínio com a lista vazia', () async {
      final file = await databaseAtVersion20('dnd_migracao_v21_dominio');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final repository = CharacterRepositoryImpl(db);
      final character = await repository.findById('velho');

      expect(character, isNotNull);
      expect(
        character!.languages,
        isEmpty,
        reason: 'os automáticos são derivados na leitura, não gravados',
      );
    });

    test('depois de migrar, a tabela aceita INSERT', () async {
      // É como o bug do portrait_path aparecia: leitura passava e só o INSERT
      // quebrava.
      final file = await databaseAtVersion20('dnd_migracao_v21_insert');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      await db.into(db.characterLanguages).insert(
            CharacterLanguagesCompanion.insert(
              characterId: 'velho',
              languageId: 'draconic',
              kind: const Value('choice'),
              slotId: const Value('background.acolyte.choice#1'),
              sourceId: const Value('acolyte'),
              sourceLabel: const Value('antecedente Acólito'),
            ),
          );

      final row = await db.select(db.characterLanguages).getSingle();
      expect(row.languageId, 'draconic');
      expect(row.kind, 'choice');
      expect(row.slotId, 'background.acolyte.choice#1');
      expect(row.sourceLabel, 'antecedente Acólito');
    });

    test('migrar duas vezes não duplica nem falha', () async {
      final file = await databaseAtVersion20('dnd_migracao_v21_idempotente');

      final first = AppDatabase.forTesting(NativeDatabase(file));
      await first.select(first.characters).get();
      await first.close();

      final second = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(second.close);

      expect(await second.select(second.characters).get(), hasLength(1));
      expect(await second.select(second.characterLanguages).get(), isEmpty);
    });

    test('id de origem desconhecido na base é lido como legado', () async {
      // Base editada à mão ou gravada por uma build futura: promover a
      // "escolha" afirmaria uma vaga que pode não existir.
      final file = await databaseAtVersion20('dnd_migracao_v21_legado');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      await db.into(db.characterLanguages).insert(
            CharacterLanguagesCompanion.insert(
              characterId: 'velho',
              languageId: 'elvish',
              kind: const Value('tipo_que_nao_existe'),
            ),
          );

      final repository = CharacterRepositoryImpl(db);
      final character = await repository.findById('velho');

      expect(
        character!.languages.single.kind,
        domain_languages.LanguageOriginKind.legacy,
      );
    });
  });

  group('18. persistência após reiniciar o aplicativo', () {
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
        name: 'Tasha',
        speciesId: 'high_elf',
        backgroundId: 'acolyte',
        abilityScores: const AbilityScores(
          strength: 8,
          dexterity: 14,
          constitution: 12,
          intelligence: 16,
          wisdom: 12,
          charisma: 10,
        ),
        classLevels: const [ClassLevel(classId: 'wizard', level: 3)],
        hitPoints: const HitPoints(current: 20, maximum: 20),
        combatStats: const CombatStats(
          armorClass: 12,
          initiativeBonus: 2,
          speedInMeters: 9,
        ),
        languages: const [
          domain_languages.CharacterLanguage(
            languageId: 'draconic',
            slotId: 'background.acolyte.choice#1',
            sourceId: 'acolyte',
            sourceLabel: 'antecedente Acólito',
          ),
          domain_languages.CharacterLanguage(
            languageId: 'giant',
            kind: domain_languages.LanguageOriginKind.manual,
            sourceLabel: 'acrescentado à mão',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );
    }

    test('fecha e abre mantendo idioma, vaga e origem', () async {
      await repository.create(build());

      final loaded = await repository.findById('c1');

      expect(loaded, isNotNull);
      expect(loaded!.languages, hasLength(2));

      final chosen = loaded.languages.firstWhere(
        (item) => item.languageId == 'draconic',
      );
      expect(chosen.kind, domain_languages.LanguageOriginKind.choice);
      expect(chosen.slotId, 'background.acolyte.choice#1');
      expect(chosen.sourceId, 'acolyte');
      expect(
        chosen.sourceLabel,
        'antecedente Acólito',
        reason: 'o rótulo é persistido para a ficha continuar dizendo a origem '
            'mesmo se o compêndio mudar de nome',
      );

      final manual = loaded.languages.firstWhere(
        (item) => item.languageId == 'giant',
      );
      expect(manual.kind, domain_languages.LanguageOriginKind.manual);
      expect(manual.slotId, isNull);
    });

    test('gravar duas vezes não duplica linha', () async {
      await repository.create(build());

      final first = await repository.findById('c1');
      await repository.update(first!);
      await repository.update((await repository.findById('c1'))!);

      final loaded = await repository.findById('c1');

      expect(
        loaded!.languages,
        hasLength(2),
        reason: 'o `update` apaga e reinsere; duplicar daria idioma repetido',
      );
      expect(
        loaded.languages.map((item) => item.languageId).toSet(),
        {'draconic', 'giant'},
      );
    });

    test('liberar a vaga remove a linha e mantém o resto', () async {
      await repository.create(build());

      final loaded = await repository.findById('c1');
      await repository.update(
        loaded!.copyWith(
          languages: [
            for (final item in loaded.languages)
              if (item.languageId != 'draconic') item,
          ],
        ),
      );

      final after = await repository.findById('c1');
      expect(after!.languages, hasLength(1));
      expect(after.languages.single.languageId, 'giant');
    });

    test('limpar todos os idiomas é passar lista vazia', () async {
      await repository.create(build());

      final loaded = await repository.findById('c1');
      await repository.update(loaded!.copyWith(languages: const []));

      final after = await repository.findById('c1');
      expect(after!.languages, isEmpty);
      expect(await database.select(database.characterLanguages).get(), isEmpty);
    });

    test('apagar o personagem limpa a tabela de idiomas', () async {
      await repository.create(build());
      await repository.delete('c1');

      expect(
        await database.select(database.characterLanguages).get(),
        isEmpty,
      );
    });

    test('exportar e importar preserva idioma, vaga e origem', () async {
      final json = CharacterJsonCodec.encode(build());
      final imported = CharacterJsonCodec.decode(json, newId: 'c2');

      expect(imported.languages, hasLength(2));

      final chosen = imported.languages.firstWhere(
        (item) => item.languageId == 'draconic',
      );
      expect(chosen.slotId, 'background.acolyte.choice#1');
      expect(chosen.kind, domain_languages.LanguageOriginKind.choice);

      final manual = imported.languages.firstWhere(
        (item) => item.languageId == 'giant',
      );
      expect(manual.kind, domain_languages.LanguageOriginKind.manual);
    });

    test('importar o mesmo arquivo duas vezes não duplica idioma', () async {
      final map = CharacterJsonCodec.toMap(build());

      // Duplica a entrada no arquivo, como um merge manual mal feito faria.
      final languages = List<dynamic>.from(map['languages'] as List<dynamic>);
      map['languages'] = [...languages, ...languages];

      final imported = CharacterJsonCodec.fromMap(map, newId: 'c3');

      expect(
        imported.languages,
        hasLength(2),
        reason: 'o parser descarta id repetido',
      );
    });

    test('registro sem id de idioma é descartado na importação', () async {
      final map = CharacterJsonCodec.toMap(build());
      map['languages'] = [
        <String, dynamic>{'kind': 'choice', 'slotId': 'x#1'},
        <String, dynamic>{'languageId': '  ', 'kind': 'manual'},
        <String, dynamic>{'languageId': 'elvish', 'kind': 'manual'},
      ];

      final imported = CharacterJsonCodec.fromMap(map, newId: 'c4');

      expect(imported.languages, hasLength(1));
      expect(imported.languages.single.languageId, 'elvish');
    });

    test('escolha sem vaga gravada é importada como legado', () async {
      final map = CharacterJsonCodec.toMap(build());
      map['languages'] = [
        <String, dynamic>{'languageId': 'elvish', 'kind': 'choice'},
      ];

      final imported = CharacterJsonCodec.fromMap(map, newId: 'c5');

      expect(
        imported.languages.single.kind,
        domain_languages.LanguageOriginKind.legacy,
        reason: 'sem vaga não há como validar contra origem nenhuma',
      );
    });
  });
}
