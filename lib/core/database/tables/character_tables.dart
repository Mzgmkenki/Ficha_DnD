import 'package:drift/drift.dart';

class Characters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get playerName => text().nullable()();
  TextColumn get speciesId => text().nullable()();
  TextColumn get backgroundId => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();

  IntColumn get strength => integer().withDefault(const Constant(10))();
  IntColumn get dexterity => integer().withDefault(const Constant(10))();
  IntColumn get constitution => integer().withDefault(const Constant(10))();
  IntColumn get intelligence => integer().withDefault(const Constant(10))();
  IntColumn get wisdom => integer().withDefault(const Constant(10))();
  IntColumn get charisma => integer().withDefault(const Constant(10))();

  IntColumn get armorClass => integer().withDefault(const Constant(10))();
  IntColumn get initiativeBonus => integer().withDefault(const Constant(0))();
  IntColumn get speed => integer().withDefault(const Constant(9))();

  IntColumn get maxHitPoints => integer().withDefault(const Constant(1))();
  IntColumn get currentHitPoints => integer().withDefault(const Constant(1))();
  IntColumn get temporaryHitPoints => integer().withDefault(const Constant(0))();

  BoolColumn get saveStrength => boolean().withDefault(const Constant(false))();
  BoolColumn get saveDexterity => boolean().withDefault(const Constant(false))();
  BoolColumn get saveConstitution => boolean().withDefault(const Constant(false))();
  BoolColumn get saveIntelligence => boolean().withDefault(const Constant(false))();
  BoolColumn get saveWisdom => boolean().withDefault(const Constant(false))();
  BoolColumn get saveCharisma => boolean().withDefault(const Constant(false))();

  BoolColumn get skillAcrobatics => boolean().withDefault(const Constant(false))();
  BoolColumn get skillAnimalHandling => boolean().withDefault(const Constant(false))();
  BoolColumn get skillArcana => boolean().withDefault(const Constant(false))();
  BoolColumn get skillAthletics => boolean().withDefault(const Constant(false))();
  BoolColumn get skillDeception => boolean().withDefault(const Constant(false))();
  BoolColumn get skillHistory => boolean().withDefault(const Constant(false))();
  BoolColumn get skillInsight => boolean().withDefault(const Constant(false))();
  BoolColumn get skillIntimidation => boolean().withDefault(const Constant(false))();
  BoolColumn get skillInvestigation => boolean().withDefault(const Constant(false))();
  BoolColumn get skillMedicine => boolean().withDefault(const Constant(false))();
  BoolColumn get skillNature => boolean().withDefault(const Constant(false))();
  BoolColumn get skillPerception => boolean().withDefault(const Constant(false))();
  BoolColumn get skillPerformance => boolean().withDefault(const Constant(false))();
  BoolColumn get skillPersuasion => boolean().withDefault(const Constant(false))();
  BoolColumn get skillReligion => boolean().withDefault(const Constant(false))();
  BoolColumn get skillSleightOfHand => boolean().withDefault(const Constant(false))();
  BoolColumn get skillStealth => boolean().withDefault(const Constant(false))();
  BoolColumn get skillSurvival => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CharacterClassLevels extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();
  TextColumn get classId => text()();
  TextColumn get subclassId => text().nullable()();
  IntColumn get level => integer()();
  TextColumn get spellcastingAbility => text().nullable()();
  TextColumn get spellcastingType => text().nullable()();
}

class CharacterSpells extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();
  IntColumn get spellId => integer()();
  TextColumn get sourceType => text()(); // class, item, custom, race, feat...
  TextColumn get sourceId => text()();
  TextColumn get sourceName => text()();
  BoolColumn get isPrepared => boolean().withDefault(const Constant(false))();
  BoolColumn get isKnown => boolean().withDefault(const Constant(true))();
  BoolColumn get isAlwaysAvailable => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

class CharacterMagicItems extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get charges => integer().nullable()();
  IntColumn get maxCharges => integer().nullable()();
  TextColumn get rechargeRule => text().nullable()();
  TextColumn get castingAbility => text().nullable()();
  IntColumn get saveDc => integer().nullable()();
  IntColumn get attackBonus => integer().nullable()();
}

class CharacterMagicItemSpells extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get magicItemId => integer().references(CharacterMagicItems, #localId)();
  IntColumn get spellId => integer()();
  BoolColumn get usesCharges => boolean().withDefault(const Constant(false))();
  IntColumn get chargeCost => integer().withDefault(const Constant(1))();
  BoolColumn get isAtWill => boolean().withDefault(const Constant(false))();
  BoolColumn get isAlwaysAvailable => boolean().withDefault(const Constant(true))();
}