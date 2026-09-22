import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_mapper.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/death_saves.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/alignment.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v14 → v15: alinhamento e testes contra a morte.
///
/// Segue a receita dos outros testes de migração: cria no schema atual, derruba
/// as colunas à mão e volta o `user_version`, porque o projeto não guarda dumps
/// de schema por versão.
void main() {
  /// Cria o arquivo com um personagem, derruba as três colunas novas e rebaixa
  /// o `user_version` para 14.
  Future<File> bancoNaVersao14(String pastaPrefixo) async {
    final pasta = await Directory.systemTemp.createTemp(pastaPrefixo);
    addTearDown(() => pasta.delete(recursive: true));
    final arquivo = File('${pasta.path}/dnd.sqlite');

    final agora = DateTime.now();
    final antigo = AppDatabase.forTesting(NativeDatabase(arquivo));

    await antigo
        .into(antigo.characters)
        .insert(
          CharactersCompanion.insert(
            id: 'velho',
            name: 'Bruenor',
            exhaustion: const Value(1),
            currentHitPoints: const Value(0),
            maxHitPoints: const Value(24),
            createdAt: agora,
            updatedAt: agora,
          ),
        );

    // A classe é obrigatória para o mapper montar o personagem.
    await antigo
        .into(antigo.characterClassLevels)
        .insert(
          CharacterClassLevelsCompanion.insert(
            characterId: 'velho',
            classId: 'fighter',
            level: 3,
          ),
        );

    for (final coluna in const [
      'alignment',
      'death_save_successes',
      'death_save_failures',
    ]) {
      await antigo.customStatement(
        'ALTER TABLE characters DROP COLUMN $coluna',
      );
    }

    await antigo.customStatement('PRAGMA user_version = 14');
    await antigo.close();

    return arquivo;
  }

  test('banco em v14 ganha as colunas sem perder o personagem', () async {
    final arquivo = await bancoNaVersao14('dnd_migracao_align');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final salvo = await db.select(db.characters).getSingle();

    // Alinhamento entra nulo: "não definido". Escolher um por conta própria
    // inventaria uma decisão do jogador — e neutro NÃO é o padrão.
    expect(salvo.alignment, isNull);

    // Ninguém estava no meio de uma sequência de testes.
    expect(salvo.deathSaveSuccesses, 0);
    expect(salvo.deathSaveFailures, 0);

    // E o resto do personagem sobreviveu.
    expect(salvo.name, 'Bruenor');
    expect(salvo.exhaustion, 1);
    expect(salvo.maxHitPoints, 24);
  });

  test('personagem antigo abre com alinhamento indefinido', () async {
    final arquivo = await bancoNaVersao14('dnd_migracao_align_leitura');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final row = await db.select(db.characters).getSingle();
    final classLevels = await db.select(db.characterClassLevels).get();

    final character = CharacterMapper.fromDatabase(
      character: row,
      classLevels: classLevels,
    );

    expect(character.alignment, isNull);
    expect(character.deathSaves, const DeathSaves());
    expect(character.name, 'Bruenor');
  });

  test('depois de migrar, as colunas aceitam gravação e leitura', () async {
    final arquivo = await bancoNaVersao14('dnd_migracao_align_escrita');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    await (db.update(db.characters)..where((t) => t.id.equals('velho'))).write(
      CharactersCompanion(
        alignment: Value(CharacterAlignment.chaoticGood.id),
        deathSaveSuccesses: const Value(2),
        deathSaveFailures: const Value(1),
      ),
    );

    final atualizado = await db.select(db.characters).getSingle();

    expect(
      CharacterAlignment.fromId(atualizado.alignment),
      CharacterAlignment.chaoticGood,
    );
    expect(atualizado.deathSaveSuccesses, 2);
    expect(atualizado.deathSaveFailures, 1);
  });

  test('INSERT novo funciona com as colunas recém-criadas', () async {
    // O modo como o bug do portrait_path aparecia: leitura passava e só o
    // INSERT quebrava. Vale repetir a checagem aqui.
    final arquivo = await bancoNaVersao14('dnd_migracao_align_insert');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final agora = DateTime.now();
    await db
        .into(db.characters)
        .insert(
          CharactersCompanion.insert(
            id: 'novo',
            name: 'Drizzt',
            alignment: Value(CharacterAlignment.chaoticNeutral.id),
            deathSaveSuccesses: const Value(3),
            createdAt: agora,
            updatedAt: agora,
          ),
        );

    final novo =
        await (db.select(db.characters)
          ..where((t) => t.id.equals('novo'))).getSingle();

    expect(
      CharacterAlignment.fromId(novo.alignment),
      CharacterAlignment.chaoticNeutral,
    );
    expect(novo.deathSaveSuccesses, 3);
    expect(novo.deathSaveFailures, 0);
  });

  test('id de alinhamento inválido no banco não derruba a leitura', () async {
    final arquivo = await bancoNaVersao14('dnd_migracao_align_invalido');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    // Simula uma base editada à mão ou vinda de outra versão do app.
    await (db.update(db.characters)..where((t) => t.id.equals('velho'))).write(
      const CharactersCompanion(
        alignment: Value('alinhamento_que_nao_existe'),
        deathSaveSuccesses: Value(9),
        deathSaveFailures: Value(-2),
      ),
    );

    final row = await db.select(db.characters).getSingle();
    final classLevels = await db.select(db.characterClassLevels).get();

    final character = CharacterMapper.fromDatabase(
      character: row,
      classLevels: classLevels,
    );

    // Alinhamento desconhecido vira nulo em vez de exceção, e os marcadores são
    // presos em 0..3: nada disso pode tornar o personagem inacessível.
    expect(character.alignment, isNull);
    expect(character.deathSaves.successes, DeathSaves.maxMarks);
    expect(character.deathSaves.failures, 0);
  });
}
