import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
// O drift também exporta `isNull`, para montar condição de SQL. Aqui o que
// vale é o matcher do teste.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v11 → v12, que traz as colunas de aumento de atributo do talento.
///
/// Mesma receita do teste da v10 → v11: cria no schema atual, recria a tabela
/// no formato antigo e volta o `user_version`, porque o projeto não guarda
/// dumps de schema por versão.
void main() {
  /// SQL da `character_feats` como ela era na v11, sem as duas colunas novas.
  const criarTabelaV11 = '''
    CREATE TABLE character_feats (
      local_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      character_id TEXT NOT NULL REFERENCES characters (id),
      feat_id TEXT NOT NULL,
      class_id TEXT NULL,
      level INTEGER NULL,
      chosen_skills TEXT NOT NULL DEFAULT '',
      granted_skills TEXT NOT NULL DEFAULT ''
    )
  ''';

  Future<File> bancoNaVersao11(String pastaPrefixo) async {
    final pasta = await Directory.systemTemp.createTemp(pastaPrefixo);
    addTearDown(() => pasta.delete(recursive: true));
    final arquivo = File('${pasta.path}/dnd.sqlite');

    final agora = DateTime.now();
    final antigo = AppDatabase.forTesting(NativeDatabase(arquivo));

    await antigo.into(antigo.characters).insert(
      CharactersCompanion.insert(
        id: 'velho',
        name: 'Bruenor',
        constitution: const Value(14),
        createdAt: agora,
        updatedAt: agora,
      ),
    );

    await antigo.customStatement('DROP TABLE character_feats');
    await antigo.customStatement(criarTabelaV11);

    // Talento pego antes da versão nova: existe, e não somou atributo nenhum.
    await antigo.customStatement(
      'INSERT INTO character_feats '
      '(character_id, feat_id, class_id, level, chosen_skills, granted_skills) '
      "VALUES ('velho', 'resilient', 'fighter', 4, '', 'perception')",
    );

    await antigo.customStatement('PRAGMA user_version = 11');
    await antigo.close();

    return arquivo;
  }

  test('banco em v11 ganha as colunas novas sem perder o talento antigo',
      () async {
    final arquivo = await bancoNaVersao11('dnd_migracao_feat_atributo');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final salvo = await db.select(db.characterFeats).getSingle();
    expect(salvo.featId, 'resilient');
    expect(salvo.grantedSkills, 'perception');

    // O talento antigo não tem aumento registrado, então removê-lo depois não
    // vai tirar ponto de atributo de ninguém.
    expect(salvo.chosenAbility, isNull);
    expect(salvo.appliedAbilityIncreases, '');

    final personagem = await db.select(db.characters).getSingle();
    expect(personagem.name, 'Bruenor');
    expect(personagem.constitution, 14);
  });

  test('depois de migrar, a tabela aceita INSERT com os campos novos',
      () async {
    // É como o bug do portrait_path aparecia: leitura passava e só o INSERT
    // quebrava.
    final arquivo = await bancoNaVersao11('dnd_migracao_feat_atributo_insert');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    await db.into(db.characterFeats).insert(
      CharacterFeatsCompanion.insert(
        characterId: 'velho',
        featId: 'tough',
        chosenAbility: const Value('constitution'),
        appliedAbilityIncreases: const Value('constitution:1'),
      ),
    );

    final salvo = await (db.select(db.characterFeats)
          ..where((tbl) => tbl.featId.equals('tough')))
        .getSingle();

    expect(salvo.chosenAbility, 'constitution');
    expect(salvo.appliedAbilityIncreases, 'constitution:1');
  });

  test('o CSV de aumento entra vazio por padrão', () async {
    // A coluna é não-nulável com default '': sem isso, `parseCsv` receberia
    // null numa base migrada.
    final arquivo = await bancoNaVersao11('dnd_migracao_feat_atributo_default');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    await db.into(db.characterFeats).insert(
      CharacterFeatsCompanion.insert(
        characterId: 'velho',
        featId: 'observant',
      ),
    );

    final salvo = await (db.select(db.characterFeats)
          ..where((tbl) => tbl.featId.equals('observant')))
        .getSingle();

    expect(salvo.appliedAbilityIncreases, '');
    expect(salvo.chosenAbility, isNull);
  });
}
