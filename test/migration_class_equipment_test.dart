import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/weapon_mapper.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v17 → v18, que traz quantidade e rastro de origem para as armas e
/// a referência de concessão para o inventário.
///
/// Segue a receita dos outros testes de migração: cria no schema atual,
/// rebaixa o arquivo à mão e reabre, porque o projeto não guarda dumps de
/// schema por versão.
void main() {
  /// Cria o arquivo com um personagem, uma arma e um item, derruba as colunas
  /// novas e volta o `user_version` para 17.
  Future<File> bancoNaVersao17(String pastaPrefixo) async {
    final pasta = await Directory.systemTemp.createTemp(pastaPrefixo);
    addTearDown(() => pasta.delete(recursive: true));
    final arquivo = File('${pasta.path}/dnd.sqlite');

    final agora = DateTime.now();
    final antigo = AppDatabase.forTesting(NativeDatabase(arquivo));

    await antigo.into(antigo.characters).insert(
          CharactersCompanion.insert(
            id: 'velho',
            name: 'Bruenor',
            createdAt: agora,
            updatedAt: agora,
          ),
        );

    await antigo.into(antigo.characterWeapons).insert(
          CharacterWeaponsCompanion.insert(
            characterId: 'velho',
            weaponId: 'battleaxe',
            magicBonus: const Value(1),
            notes: const Value('presente do clã'),
          ),
        );

    await antigo.into(antigo.characterInventoryItems).insert(
          CharacterInventoryItemsCompanion.insert(
            characterId: 'velho',
            name: 'Pé de cabra',
            itemId: const Value('crowbar'),
            source: const Value('background'),
            sourceId: const Value('criminal'),
          ),
        );

    for (final coluna in const [
      'quantity',
      'source',
      'source_id',
      'source_label',
      'granted_at_creation',
      'granted_quantity',
      'manually_edited',
      'grant_ref',
    ]) {
      await antigo.customStatement(
        'ALTER TABLE character_weapons DROP COLUMN $coluna',
      );
    }

    await antigo.customStatement(
      'ALTER TABLE character_inventory_items DROP COLUMN grant_ref',
    );

    await antigo.customStatement('PRAGMA user_version = 17');
    await antigo.close();

    return arquivo;
  }

  test('banco em v17 ganha as colunas e preserva a arma', () async {
    final arquivo = await bancoNaVersao17('dnd_migracao_equip');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final arma = await db.select(db.characterWeapons).getSingle();

    // A arma que já existia é do jogador, e nada é inferido sobre ela:
    // quantidade 1, origem manual, sem referência de concessão. Deduzir
    // "classe" faria a troca de classe apagar arma escolhida à mão.
    expect(arma.quantity, 1);
    expect(arma.source, GrantSource.manual.id);
    expect(arma.sourceId, isNull);
    expect(arma.grantedAtCreation, isFalse);
    expect(arma.grantedQuantity, isNull);
    expect(arma.manuallyEdited, isFalse);
    expect(arma.grantRef, isNull);

    // E o que ela já guardava sobreviveu.
    expect(arma.weaponId, 'battleaxe');
    expect(arma.magicBonus, 1);
    expect(arma.notes, 'presente do clã');
  });

  test('a arma antiga nunca é removida por recálculo de classe', () async {
    final arquivo = await bancoNaVersao17('dnd_migracao_equip_manual');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final arma = WeaponMapper.fromDatabase(
      await db.select(db.characterWeapons).getSingle(),
    );

    expect(arma.isGranted, isFalse);
    expect(arma.grantKey, isNull);
    expect(arma.divergedFromGrant, isFalse);
  });

  test('o item de inventário antigo mantém a origem e fica sem grant_ref',
      () async {
    final arquivo = await bancoNaVersao17('dnd_migracao_equip_inv');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    final item = await db.select(db.characterInventoryItems).getSingle();

    expect(item.name, 'Pé de cabra');
    expect(item.source, 'background');
    expect(item.sourceId, 'criminal');
    // Antecedente não tem grupos de escolha: nulo é a leitura correta.
    expect(item.grantRef, isNull);
  });

  test('depois de migrar, as colunas aceitam gravação e leitura', () async {
    final arquivo = await bancoNaVersao17('dnd_migracao_equip_escrita');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    await db.into(db.characterWeapons).insert(
          CharacterWeaponsCompanion.insert(
            characterId: 'velho',
            weaponId: 'longsword',
            quantity: const Value(2),
            source: Value(GrantSource.characterClass.id),
            sourceId: const Value('fighter'),
            sourceLabel: const Value(
              'Equipamento inicial da classe: Guerreiro',
            ),
            grantedAtCreation: const Value(true),
            grantedQuantity: const Value(2),
            grantRef: const Value('martial|two_martial'),
          ),
        );

    final armas = await db.select(db.characterWeapons).get();
    final concedida = armas.firstWhere((item) => item.weaponId == 'longsword');

    final mapeada = WeaponMapper.fromDatabase(concedida);
    expect(mapeada.quantity, 2);
    expect(mapeada.source, GrantSource.characterClass);
    expect(mapeada.sourceId, 'fighter');
    expect(mapeada.grantRef, 'martial|two_martial');
    expect(mapeada.grantKey, 'class|fighter|longsword');
    expect(mapeada.divergedFromGrant, isFalse);
  });

  test('quantidade inválida no banco é corrigida na leitura', () async {
    final arquivo = await bancoNaVersao17('dnd_migracao_equip_clamp');

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);

    // Base editada à mão: zero unidades de uma arma que o personagem tem.
    await db.customStatement(
      'UPDATE character_weapons SET quantity = 0 WHERE weapon_id = ?',
      ['battleaxe'],
    );

    final arma = WeaponMapper.fromDatabase(
      await db.select(db.characterWeapons).getSingle(),
    );

    expect(arma.quantity, 1);
  });
}
