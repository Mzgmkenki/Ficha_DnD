import 'package:dnd_ficha_app/core/database/migrations/migration_strategy.dart';
import 'package:dnd_ficha_app/core/database/tables/character_tables.dart';
import 'package:dnd_ficha_app/core/database/tables/compendium_tables.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Characters,
    CharacterClassLevels,
    CharacterSpells,
    CharacterWeapons,
    CharacterMagicItems,
    CharacterMagicItemSpells,
    CharacterSpellSlotsUsage,
    CharacterFeats,
    ClassEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Abre o banco num executor escolhido pelo teste.
  ///
  /// O construtor normal usa `driftDatabase`, que depende do path_provider e
  /// só funciona rodando dentro do app. Sem isso não há como testar migração.
  @visibleForTesting
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 14;

  /// Sem este override o drift usa a estratégia padrão, cujo `onUpgrade`
  /// lança exceção — qualquer base criada numa versão anterior deixaria o
  /// app inutilizável ao abrir.
  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'dnd_ficha_app');
}