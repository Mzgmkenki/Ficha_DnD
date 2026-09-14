import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reproduz o banco real que travou a criação de personagem: marcado como
/// versão 7, mas sem a coluna `portrait_path`.
///
/// Esse estado nasceu de a coluna ter entrado na tabela sem bump de
/// `schemaVersion`: o drift só chama `onUpgrade` quando a versão difere, então
/// a coluna nunca era criada. A leitura passava (drift faz `SELECT *` e coluna
/// ausente vira null) e só o INSERT quebrava, com
/// `table characters has no column named portrait_path`.
void main() {
  test('banco em v7 sem portrait_path se cura ao abrir e aceita INSERT', () async {
    final pasta = await Directory.systemTemp.createTemp('dnd_migracao');
    addTearDown(() => pasta.delete(recursive: true));
    final arquivo = File('${pasta.path}/dnd.sqlite');

    // Cria com o schema atual e rebaixa para o estado quebrado.
    final antigo = AppDatabase.forTesting(NativeDatabase(arquivo));
    await antigo.customStatement('SELECT 1');
    await antigo.customStatement(
      'ALTER TABLE characters DROP COLUMN portrait_path',
    );
    await antigo.customStatement('PRAGMA user_version = 7');
    await antigo.close();

    // Reabrir tem que devolver a coluna pela migração 7 -> 8.
    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final agora = DateTime.now();
    await db
        .into(db.characters)
        .insert(
          CharactersCompanion.insert(
            id: 'personagem-teste',
            name: 'Aragorn',
            portraitPath: const Value('/retratos/aragorn.jpg'),
            createdAt: agora,
            updatedAt: agora,
          ),
        );

    final salvo = await db.select(db.characters).getSingle();
    expect(salvo.portraitPath, '/retratos/aragorn.jpg');
  });

  test('banco em v8 ganha speed_meters e mantém o deslocamento antigo', () async {
    final pasta = await Directory.systemTemp.createTemp('dnd_migracao_speed');
    addTearDown(() => pasta.delete(recursive: true));
    final arquivo = File('${pasta.path}/dnd.sqlite');

    final agora = DateTime.now();

    // Estado anterior: sem a coluna decimal e com o deslocamento no inteiro.
    final antigo = AppDatabase.forTesting(NativeDatabase(arquivo));
    await antigo.into(antigo.characters).insert(
      CharactersCompanion.insert(
        id: 'anao',
        name: 'Thorin',
        speed: const Value(7),
        createdAt: agora,
        updatedAt: agora,
      ),
    );
    await antigo.customStatement(
      'ALTER TABLE characters DROP COLUMN speed_meters',
    );
    await antigo.customStatement('PRAGMA user_version = 8');
    await antigo.close();

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final salvo = await db.select(db.characters).getSingle();
    // O backfill copia o valor que existia, em vez de deixar nulo.
    expect(salvo.speedMeters, 7);

    // E a coluna aceita fração de agora em diante.
    await (db.update(db.characters)..where((t) => t.id.equals('anao'))).write(
      const CharactersCompanion(speedMeters: Value(7.5)),
    );
    final atualizado = await db.select(db.characters).getSingle();
    expect(atualizado.speedMeters, 7.5);
  });
}
