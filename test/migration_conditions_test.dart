import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v9 → v10, que traz a coluna `conditions`.
///
/// Segue a receita dos outros testes de migração: cria no schema atual,
/// rebaixa o arquivo à mão e reabre, porque o projeto não guarda dumps de
/// schema por versão.
void main() {
  /// Cria o arquivo já com um personagem, derruba a coluna e volta o
  /// `user_version` para 9.
  Future<File> bancoNaVersao9(String pastaPrefixo) async {
    final pasta = await Directory.systemTemp.createTemp(pastaPrefixo);
    addTearDown(() => pasta.delete(recursive: true));
    final arquivo = File('${pasta.path}/dnd.sqlite');

    final agora = DateTime.now();
    final antigo = AppDatabase.forTesting(NativeDatabase(arquivo));

    await antigo.into(antigo.characters).insert(
      CharactersCompanion.insert(
        id: 'velho',
        name: 'Bruenor',
        exhaustion: const Value(2),
        createdAt: agora,
        updatedAt: agora,
      ),
    );

    await antigo.customStatement(
      'ALTER TABLE characters DROP COLUMN conditions',
    );
    await antigo.customStatement('PRAGMA user_version = 9');
    await antigo.close();

    return arquivo;
  }

  test('banco em v9 ganha a coluna conditions e mantém o personagem', () async {
    final arquivo = await bancoNaVersao9('dnd_migracao_cond');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final salvo = await db.select(db.characters).getSingle();

    // Quem já existia entra sem condição nenhuma, não com null: `parseCsv`
    // aceita null, mas a coluna é declarada não-nulável.
    expect(salvo.conditions, '');
    expect(Condition.parseCsv(salvo.conditions), isEmpty);

    // E o resto do personagem sobreviveu à migração.
    expect(salvo.name, 'Bruenor');
    expect(salvo.exhaustion, 2);
  });

  test('depois de migrar, a coluna aceita gravação e leitura', () async {
    final arquivo = await bancoNaVersao9('dnd_migracao_cond_escrita');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    await (db.update(db.characters)..where((t) => t.id.equals('velho'))).write(
      CharactersCompanion(
        conditions: Value(
          Condition.toCsv(const {Condition.paralyzed, Condition.poisoned}),
        ),
      ),
    );

    final atualizado = await db.select(db.characters).getSingle();
    expect(Condition.parseCsv(atualizado.conditions), {
      Condition.paralyzed,
      Condition.poisoned,
    });
  });

  test('INSERT novo funciona com a coluna recém-criada', () async {
    // O modo como o bug do portrait_path aparecia: leitura passava e só o
    // INSERT quebrava. Vale repetir a checagem aqui.
    final arquivo = await bancoNaVersao9('dnd_migracao_cond_insert');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final agora = DateTime.now();
    await db.into(db.characters).insert(
      CharactersCompanion.insert(
        id: 'novo',
        name: 'Drizzt',
        conditions: Value(Condition.toCsv(const {Condition.invisible})),
        createdAt: agora,
        updatedAt: agora,
      ),
    );

    final novo = await (db.select(db.characters)
          ..where((t) => t.id.equals('novo')))
        .getSingle();

    expect(Condition.parseCsv(novo.conditions), {Condition.invisible});
  });
}
