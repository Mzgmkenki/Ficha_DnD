import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:drift/drift.dart';

/// Estratégia de migração do banco local.
///
/// As migrações aqui são **idempotentes**: antes de adicionar uma coluna
/// verificamos se ela já existe. Isso evita o erro `duplicate column name`
/// em bases que ficaram em estados intermediários (o override `migration`
/// só passou a ser ligado ao [AppDatabase] depois de um tempo, então há
/// bases com `user_version` desatualizado mas colunas já presentes).
MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Salvaguardas
        await _addColumnIfMissing(db, m, db.characters, db.characters.saveStrength);
        await _addColumnIfMissing(db, m, db.characters, db.characters.saveDexterity);
        await _addColumnIfMissing(db, m, db.characters, db.characters.saveConstitution);
        await _addColumnIfMissing(db, m, db.characters, db.characters.saveIntelligence);
        await _addColumnIfMissing(db, m, db.characters, db.characters.saveWisdom);
        await _addColumnIfMissing(db, m, db.characters, db.characters.saveCharisma);

        // Perícias
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillAcrobatics);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillAnimalHandling);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillArcana);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillAthletics);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillDeception);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillHistory);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillInsight);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillIntimidation);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillInvestigation);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillMedicine);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillNature);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillPerception);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillPerformance);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillPersuasion);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillReligion);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillSleightOfHand);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillStealth);
        await _addColumnIfMissing(db, m, db.characters, db.characters.skillSurvival);
      }

      if (from < 3) {
        // Identidade do personagem e anotações.
        await _addColumnIfMissing(db, m, db.characters, db.characters.playerName);
        await _addColumnIfMissing(db, m, db.characters, db.characters.backgroundId);
        await _addColumnIfMissing(db, m, db.characters, db.characters.notes);

        // Tabelas que passaram a existir depois da v1.
        await _createTableIfMissing(db, m, db.characterMagicItems);
        await _createTableIfMissing(db, m, db.characterMagicItemSpells);
        await _createTableIfMissing(db, m, db.characterSpellSlotsUsage);
        await _createTableIfMissing(db, m, db.classEntries);
      }
    },
    beforeOpen: (details) async {
      // Remove duplicatas antes de criar o índice único, senão a criação
      // falharia em bases que já registraram o mesmo slot duas vezes.
      await db.customStatement(
        'DELETE FROM character_spell_slots_usage WHERE local_id NOT IN ('
        '  SELECT MIN(local_id) FROM character_spell_slots_usage'
        '  GROUP BY character_id, slot_level'
        ')',
      );

      // Sem este índice, dois toques rápidos no botão de gastar slot criam
      // duas linhas e todo acesso posterior passa a lançar erro.
      await db.customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_slot_usage_unique '
        'ON character_spell_slots_usage (character_id, slot_level)',
      );
    },
  );
}

Future<void> _addColumnIfMissing(
  AppDatabase db,
  Migrator m,
  TableInfo<Table, dynamic> table,
  GeneratedColumn<Object> column,
) async {
  final existing = await _columnNames(db, table.actualTableName);
  if (existing.contains(column.name.toLowerCase())) return;
  await m.addColumn(table, column);
}

Future<void> _createTableIfMissing(
  AppDatabase db,
  Migrator m,
  TableInfo<Table, dynamic> table,
) async {
  final rows = await db
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
        variables: [Variable<String>(table.actualTableName)],
      )
      .get();

  if (rows.isNotEmpty) return;
  await m.createTable(table);
}

Future<Set<String>> _columnNames(AppDatabase db, String tableName) async {
  final rows =
      await db.customSelect('PRAGMA table_info($tableName)').get();
  return rows
      .map((row) => (row.data['name'] as String? ?? '').toLowerCase())
      .toSet();
}
