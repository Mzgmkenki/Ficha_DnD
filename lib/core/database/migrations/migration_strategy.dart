import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:drift/drift.dart';

MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // ✅ SALVAGUARDAS
        await m.addColumn(db.characters, db.characters.saveStrength);
        await m.addColumn(db.characters, db.characters.saveDexterity);
        await m.addColumn(db.characters, db.characters.saveConstitution);
        await m.addColumn(db.characters, db.characters.saveIntelligence);
        await m.addColumn(db.characters, db.characters.saveWisdom);
        await m.addColumn(db.characters, db.characters.saveCharisma);

        // ✅ PERÍCIAS
        await m.addColumn(db.characters, db.characters.skillAcrobatics);
        await m.addColumn(db.characters, db.characters.skillAnimalHandling);
        await m.addColumn(db.characters, db.characters.skillArcana);
        await m.addColumn(db.characters, db.characters.skillAthletics);
        await m.addColumn(db.characters, db.characters.skillDeception);
        await m.addColumn(db.characters, db.characters.skillHistory);
        await m.addColumn(db.characters, db.characters.skillInsight);
        await m.addColumn(db.characters, db.characters.skillIntimidation);
        await m.addColumn(db.characters, db.characters.skillInvestigation);
        await m.addColumn(db.characters, db.characters.skillMedicine);
        await m.addColumn(db.characters, db.characters.skillNature);
        await m.addColumn(db.characters, db.characters.skillPerception);
        await m.addColumn(db.characters, db.characters.skillPerformance);
        await m.addColumn(db.characters, db.characters.skillPersuasion);
        await m.addColumn(db.characters, db.characters.skillReligion);
        await m.addColumn(db.characters, db.characters.skillSleightOfHand);
        await m.addColumn(db.characters, db.characters.skillStealth);
        await m.addColumn(db.characters, db.characters.skillSurvival);
      }
    },
  );
}