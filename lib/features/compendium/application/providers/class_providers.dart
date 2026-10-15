import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/eldritch_invocation_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/eldritch_invocation_catalog.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_catalog.dart';
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

final languageEntriesProvider =
    FutureProvider<List<LanguageEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadLanguages();
});

/// O catálogo de idiomas já montado, sem duplicatas.
///
/// Único ponto de verdade para "qual idioma é este texto" e "o que esta vaga
/// oferece". A tela de criação, a ficha e a edição leem daqui, e é por isso
/// que não podem divergir na normalização de nome.
final languageCatalogProvider = FutureProvider<LanguageCatalog>((ref) async {
  final entries = await ref.watch(languageEntriesProvider.future);
  return LanguageCatalog.from(entries);
});

final eldritchInvocationEntriesProvider =
    FutureProvider<List<EldritchInvocationEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadEldritchInvocations();
});

/// O catálogo de Invocações Místicas já montado, sem duplicatas.
///
/// Mesmo papel do catálogo de idiomas: a tela de seleção, a ficha e o
/// validador de pré-requisitos leem daqui, então não há como divergirem na
/// resolução de id nem na normalização de nome para busca.
final eldritchInvocationCatalogProvider =
    FutureProvider<EldritchInvocationCatalog>((ref) async {
  final entries = await ref.watch(eldritchInvocationEntriesProvider.future);
  return EldritchInvocationCatalog.from(entries);
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

/// Equipamento inicial declarado por cada classe.
final classEquipmentProvider =
    FutureProvider<List<ClassStartingEquipment>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadClassEquipment();
});

/// O equipamento inicial de uma classe, ou `null` quando a classe não declara
/// nenhum.
///
/// Classe sem dado não é erro: a criação segue sem a seção de equipamentos, e
/// é isso que mantém o fluxo funcionando para conteúdo que ainda não foi
/// cadastrado.
final classEquipmentByIdProvider =
    FutureProvider.family<ClassStartingEquipment?, String>((ref, id) async {
  final all = await ref.watch(classEquipmentProvider.future);
  for (final item in all) {
    if (item.classId == id) return item;
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