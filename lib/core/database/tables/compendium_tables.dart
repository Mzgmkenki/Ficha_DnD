import 'package:drift/drift.dart';

class ClassEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get hitDie => text()();
  TextColumn get primaryAbility => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('srd'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
