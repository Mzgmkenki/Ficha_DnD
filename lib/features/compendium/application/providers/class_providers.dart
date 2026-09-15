import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final classEntriesProvider = FutureProvider<List<ClassEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadClasses();
});

final raceEntriesProvider = FutureProvider<List<RaceEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadRaces();
});

final backgroundEntriesProvider =
    FutureProvider<List<BackgroundEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadBackgrounds();
});

final featEntriesProvider = FutureProvider<List<FeatEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadFeats();
});

final featByIdProvider =
    FutureProvider.family<FeatEntry?, String>((ref, id) async {
  final feats = await ref.watch(featEntriesProvider.future);
  for (final item in feats) {
    if (item.id == id) return item;
  }
  return null;
});

final backgroundByIdProvider =
    FutureProvider.family<BackgroundEntry?, String>((ref, id) async {
  final backgrounds = await ref.watch(backgroundEntriesProvider.future);
  for (final item in backgrounds) {
    if (item.id == id) return item;
  }
  return null;
});

final raceByIdProvider =
    FutureProvider.family<RaceEntry?, String>((ref, id) async {
  final races = await ref.watch(raceEntriesProvider.future);
  for (final race in races) {
    if (race.id == id) {
      return race;
    }
  }
  return null;
});

final classByIdProvider =
    FutureProvider.family<ClassEntry?, String>((ref, id) async {
  final classes = await ref.watch(classEntriesProvider.future);
  for (final item in classes) {
    if (item.id == id) {
      return item;
    }
  }
  return null;
});

final classFeaturesProvider =
    FutureProvider<List<ClassFeatureEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadClassFeatures();
});

final classFeaturesByClassAndLevelProvider = FutureProvider.family
    .autoDispose<List<ClassFeatureEntry>, ({String classId, int level})>(
  (ref, params) async {
    final allFeatures = await ref.watch(classFeaturesProvider.future);

    return allFeatures
        .where(
          (entry) =>
              entry.classId == params.classId && entry.level <= params.level,
        )
        .toList(growable: false);
  },
);

final subclassEntriesProvider =
    FutureProvider<List<SubclassEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadSubclasses();
});

/// Subclasses de uma classe, na ordem do compêndio.
final subclassesByClassProvider =
    FutureProvider.family<List<SubclassEntry>, String>((ref, classId) async {
  final all = await ref.watch(subclassEntriesProvider.future);

  return all
      .where((item) => item.classId == classId)
      .toList(growable: false);
});

final subclassByIdProvider =
    FutureProvider.family<SubclassEntry?, String>((ref, id) async {
  final all = await ref.watch(subclassEntriesProvider.future);
  for (final item in all) {
    if (item.id == id) return item;
  }
  return null;
});

final spellSlotProgressionsProvider =
    FutureProvider<List<SpellSlotProgressionEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadSpellSlotProgressions();
});

final spellSlotProgressionByTableAndLevelProvider = FutureProvider.family
    .autoDispose<SpellSlotProgressionEntry?, ({String tableId, int level})>(
  (ref, params) async {
    final allRows = await ref.watch(spellSlotProgressionsProvider.future);

    for (final row in allRows) {
      if (row.tableId == params.tableId && row.level == params.level) {
        return row;
      }
    }
    return null;
  },
);