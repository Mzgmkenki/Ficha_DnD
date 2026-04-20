import 'package:dnd_ficha_app/core/database/tables/character_tables.dart';
import 'package:dnd_ficha_app/core/database/tables/compendium_tables.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Characters,
    CharacterClassLevels,
    CharacterSpells,
    CharacterMagicItems,
    CharacterMagicItemSpells,
    CharacterSpellSlotsUsage,
    ClassEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'dnd_ficha_app');
}