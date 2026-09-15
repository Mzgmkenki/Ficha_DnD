import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
// O drift também exporta `isNull`, para montar condição de SQL. Aqui o que
// vale é o matcher do teste.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v10 → v11, que traz a tabela `character_feats`.
///
/// Mesma receita dos outros testes de migração: cria no schema atual, derruba a
/// tabela à mão e volta o `user_version`, porque o projeto não guarda dumps de
/// schema por versão.
void main() {
  Future<File> bancoNaVersao10(String pastaPrefixo) async {
    final pasta = await Directory.systemTemp.createTemp(pastaPrefixo);
    addTearDown(() => pasta.delete(recursive: true));
    final arquivo = File('${pasta.path}/dnd.sqlite');

    final agora = DateTime.now();
    final antigo = AppDatabase.forTesting(NativeDatabase(arquivo));

    await antigo.into(antigo.characters).insert(
      CharactersCompanion.insert(
        id: 'velho',
        name: 'Bruenor',
        lvlPerception: const Value(2),
        createdAt: agora,
        updatedAt: agora,
      ),
    );

    await antigo.customStatement('DROP TABLE character_feats');
    await antigo.customStatement('PRAGMA user_version = 10');
    await antigo.close();

    return arquivo;
  }

  test('banco em v10 ganha a tabela de talentos sem perder o personagem',
      () async {
    final arquivo = await bancoNaVersao10('dnd_migracao_feats');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    expect(await db.select(db.characterFeats).get(), isEmpty);

    final salvo = await db.select(db.characters).getSingle();
    expect(salvo.name, 'Bruenor');
    expect(salvo.lvlPerception, 2);
  });

  test('depois de migrar, a tabela aceita INSERT e leitura', () async {
    // É como o bug do portrait_path aparecia: leitura passava e só o INSERT
    // quebrava. Vale repetir a checagem numa tabela nova.
    final arquivo = await bancoNaVersao10('dnd_migracao_feats_insert');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    await db.into(db.characterFeats).insert(
      CharacterFeatsCompanion.insert(
        characterId: 'velho',
        featId: 'observant',
        classId: const Value('fighter'),
        level: const Value(4),
        chosenSkills: const Value('nature,medicine'),
        grantedSkills: const Value('perception'),
      ),
    );

    final salvo = await db.select(db.characterFeats).getSingle();
    expect(salvo.featId, 'observant');
    expect(salvo.classId, 'fighter');
    expect(salvo.level, 4);
    expect(salvo.chosenSkills, 'nature,medicine');
    expect(salvo.grantedSkills, 'perception');
  });

  test('os CSV de perícia entram vazios por padrão', () async {
    // A coluna é não-nulável com default '': sem isso, `parseSkillIdsCsv`
    // receberia null numa base migrada.
    final arquivo = await bancoNaVersao10('dnd_migracao_feats_default');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    await db.into(db.characterFeats).insert(
      CharacterFeatsCompanion.insert(
        characterId: 'velho',
        featId: 'tough',
      ),
    );

    final salvo = await db.select(db.characterFeats).getSingle();
    expect(salvo.chosenSkills, '');
    expect(salvo.grantedSkills, '');
    expect(salvo.classId, isNull);
    expect(salvo.level, isNull);
  });
}
