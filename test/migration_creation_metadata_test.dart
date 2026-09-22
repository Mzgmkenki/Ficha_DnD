import 'dart:io';

import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_mapper.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'banco v15 ganha metadados sem inventar valores para personagem antigo',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'dnd_migracao_v16',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/dnd.sqlite');
      final now = DateTime(2026, 9, 22);

      final old = AppDatabase.forTesting(NativeDatabase(file));
      await old
          .into(old.characters)
          .insert(
            CharactersCompanion.insert(
              id: 'old-character',
              name: 'Personagem antigo',
              strength: const Value(17),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await old
          .into(old.characterClassLevels)
          .insert(
            CharacterClassLevelsCompanion.insert(
              characterId: 'old-character',
              classId: 'fighter',
              level: 1,
            ),
          );

      for (final column in const [
        'base_ability_scores',
        'origin_ability_bonuses',
        'skill_proficiency_grants',
      ]) {
        await old.customStatement('ALTER TABLE characters DROP COLUMN $column');
      }
      await old.customStatement('PRAGMA user_version = 15');
      await old.close();

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);
      final row = await db.select(db.characters).getSingle();
      final levels = await db.select(db.characterClassLevels).get();
      final character = CharacterMapper.fromDatabase(
        character: row,
        classLevels: levels,
      );

      expect(character.abilityScores.strength, 17);
      expect(character.abilityScoreAllocation, isNull);
      expect(character.skillProficiencyGrants, isEmpty);
    },
  );
}
