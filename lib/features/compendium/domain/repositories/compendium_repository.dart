import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';

abstract class CompendiumRepository {
  Future<List<ClassEntry>> loadClasses();
  Future<List<RaceEntry>> loadRaces();
  Future<List<BackgroundEntry>> loadBackgrounds();
  Future<List<ClassFeatureEntry>> loadClassFeatures();
  Future<List<SubclassEntry>> loadSubclasses();
  Future<List<SpellSlotProgressionEntry>> loadSpellSlotProgressions();
  Future<List<SpellEntry>> loadSpells();
}