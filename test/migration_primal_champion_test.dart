import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_mapper.dart';
import 'package:dnd_ficha_app/features/character/data/repositories/character_repository_impl.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_ability_bonuses.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v24 → v25: a coluna que registra os aumentos de atributo que as
/// características de classe aplicaram.
///
/// O que a migração faz é só acrescentar a coluna. Quem decide o valor é a
/// reconciliação, ao abrir a ficha, porque isso exige ler o compêndio e
/// resolver as características pelo nível DA CLASSE — coisas indisponíveis
/// dentro da transação de migração.
void main() {
  /// Cria um banco no schema atual e o rebaixa para a v24.
  ///
  /// Mesma receita dos outros testes de migração: o projeto não guarda dumps
  /// por versão, então o estado antigo é reconstruído apagando o que a v25
  /// acrescentou. O SQLite não tem `DROP COLUMN` em versões antigas, então a
  /// coluna é zerada e a versão rebaixada — o que basta, porque `_tryAddColumn`
  /// é idempotente e o teste mede o efeito sobre o DADO.
  Future<File> databaseAtVersion24(String prefix) async {
    final directory = await Directory.systemTemp.createTemp(prefix);
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/dnd.sqlite');

    final now = DateTime(2026, 10, 16);
    final old = AppDatabase.forTesting(NativeDatabase(file));

    // Bárbaro de 20º nível criado ANTES de o Campeão Primal ser automatizado:
    // os atributos são o que o jogador distribuiu, sem o +4.
    await old
        .into(old.characters)
        .insert(
          CharactersCompanion.insert(
            id: 'velho',
            name: 'Dagna',
            speciesId: const Value('dwarf'),
            strength: const Value(18),
            constitution: const Value(16),
            maxHitPoints: const Value(180),
            currentHitPoints: const Value(180),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await old
        .into(old.characterClassLevels)
        .insert(
          CharacterClassLevelsCompanion.insert(
            characterId: 'velho',
            classId: 'barbarian',
            level: 20,
            subclassId: const Value('barbarian_totem_warrior'),
          ),
        );

    await old.customStatement(
      'UPDATE characters SET feature_ability_bonuses = NULL',
    );
    await old.customStatement('PRAGMA user_version = 24');
    await old.close();

    return file;
  }

  group('migração v24 → v25', () {
    test('o Bárbaro da v24 continua abrindo depois da migração', () async {
      final file = await databaseAtVersion24('dnd_migracao_v25_abre');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final row = await db.select(db.characters).getSingle();
      final levels = await db.select(db.characterClassLevels).get();

      final character = CharacterMapper.fromDatabase(
        character: row,
        classLevels: levels,
      );

      expect(character.name, 'Dagna');
      expect(character.classLevels.single.classId, 'barbarian');
      expect(character.classLevels.single.level, 20);
    });

    test('a coluna nasce nula e o atributo não é mexido na migração', () async {
      // A migração NÃO adivinha. Mexer no total aqui exigiria decidir, sem o
      // compêndio, qual parte do 18 de Força veio de qual lugar.
      final file = await databaseAtVersion24('dnd_migracao_v25_nula');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final row = await db.select(db.characters).getSingle();

      expect(row.featureAbilityBonuses, isNull);
      expect(row.strength, 18);
      expect(row.constitution, 16);
    });

    test('o personagem antigo chega ao domínio com o registro vazio', () async {
      final file = await databaseAtVersion24('dnd_migracao_v25_dominio');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final repository = CharacterRepositoryImpl(db);
      final character = await repository.findById('velho');

      expect(character, isNotNull);
      expect(character!.featureAbilityBonuses, isEmpty);
      expect(character.abilityScores.strength, 18);
      expect(character.abilityScores.constitution, 16);
    });

    test('a reconciliação grava, e reabrir não soma de novo', () async {
      final file = await databaseAtVersion24('dnd_migracao_v25_reconcilia');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final repository = CharacterRepositoryImpl(db);
      final character = (await repository.findById('velho'))!;

      // O que a reconciliação faria com os bônus do Campeão Primal.
      final reconciled = FeatureAbilityBonuses.reconcile(
        character: character,
        granted: const {Ability.strength: 4, Ability.constitution: 4},
        maximums: const {Ability.strength: 24, Ability.constitution: 24},
      );

      await repository.update(reconciled);

      final saved = (await repository.findById('velho'))!;

      expect(saved.abilityScores.strength, 22);
      expect(saved.abilityScores.constitution, 20);
      expect(saved.featureAbilityBonuses, {
        Ability.strength: 4,
        Ability.constitution: 4,
      });

      // Reabrir e reconciliar de novo não muda nada: é a idempotência que
      // substitui uma marcação de migração.
      final again = FeatureAbilityBonuses.reconcile(
        character: saved,
        granted: const {Ability.strength: 4, Ability.constitution: 4},
        maximums: const {Ability.strength: 24, Ability.constitution: 24},
      );

      expect(identical(again, saved), isTrue);
      expect(again.abilityScores.strength, 22);
    });

    test('o registro gravado volta do banco pelo CSV', () async {
      final file = await databaseAtVersion24('dnd_migracao_v25_csv');

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      await db.customStatement(
        'UPDATE characters SET '
        "feature_ability_bonuses = 'strength:4,constitution:4', "
        'strength = 22, constitution = 20',
      );

      final repository = CharacterRepositoryImpl(db);
      final character = (await repository.findById('velho'))!;

      expect(character.featureAbilityBonuses, {
        Ability.strength: 4,
        Ability.constitution: 4,
      });

      // E a remoção devolve exatamente o que estava registrado.
      final demoted = FeatureAbilityBonuses.reconcile(
        character: character,
        granted: const {},
      );

      expect(demoted.abilityScores.strength, 18);
      expect(demoted.abilityScores.constitution, 16);
      expect(demoted.featureAbilityBonuses, isEmpty);
    });

    test('migrar duas vezes não duplica nem derruba a abertura', () async {
      // `_tryAddColumn` engole o "duplicate column name", então reabrir o
      // banco já migrado é inofensivo.
      final file = await databaseAtVersion24('dnd_migracao_v25_duas_vezes');

      final first = AppDatabase.forTesting(NativeDatabase(file));
      await first.select(first.characters).get();
      await first.close();

      final second = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(second.close);

      final row = await second.select(second.characters).getSingle();

      expect(row.strength, 18);
      expect(row.featureAbilityBonuses, isNull);
    });
  });
}
