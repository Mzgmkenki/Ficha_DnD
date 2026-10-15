import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_character_languages.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_sources.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// As fontes de idioma do personagem, já montadas do compêndio.
///
/// Indexado pelo personagem inteiro, como `resolvedFeaturesProvider`: o
/// resultado depende de raça, sub-raça, classe, subclasse, antecedente,
/// talentos e nível, e o `Character` é a única chave que carrega tudo isso.
/// Qualquer mudança numa dessas coisas produz uma lista nova — é daí que vem o
/// recálculo automático pedido no levantamento, sem ninguém chamar nada.
final languageSourcesProvider = FutureProvider.family
    .autoDispose<LanguageSourceBundle, Character>((ref, character) async {
  final catalog = await ref.watch(languageCatalogProvider.future);
  final races = await ref.watch(raceEntriesProvider.future);
  final backgrounds = await ref.watch(backgroundEntriesProvider.future);
  final classes = await ref.watch(classEntriesProvider.future);
  final classFeatures = await ref.watch(classFeaturesProvider.future);
  final subclasses = await ref.watch(subclassEntriesProvider.future);
  final feats = await ref.watch(featEntriesProvider.future);

  RaceEntry? findRace(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final race in races) {
      if (race.id == id) return race;
    }
    return null;
  }

  // `speciesId` guarda a sub-raça quando ela existe, então a raça base é
  // alcançada pelo pai. As duas entram como fontes separadas, e é assim que a
  // sub-raça acrescenta sem apagar o que a base concede.
  final selected = findRace(character.speciesId);
  final isSubrace = selected != null &&
      (selected.isSubrace ||
          (selected.parentRaceId?.trim().isNotEmpty ?? false));
  final baseRace = isSubrace ? findRace(selected.parentRaceId) : selected;
  final subrace = isSubrace ? selected : null;

  final classSources = <LanguageClassSource>[];
  for (final level in character.classLevels) {
    for (final entry in classes) {
      if (entry.id != level.classId) continue;

      SubclassEntry? subclass;
      final subclassId = level.subclassId;
      if (subclassId != null && subclassId.isNotEmpty) {
        for (final item in subclasses) {
          if (item.id == subclassId) {
            subclass = item;
            break;
          }
        }
      }

      classSources.add(
        LanguageClassSource(
          entry: entry,
          level: level.level,
          subclass: subclass,
        ),
      );
      break;
    }
  }

  final takenFeats = <FeatEntry>[];
  for (final taken in character.feats) {
    for (final entry in feats) {
      if (entry.id == taken.featId) {
        takenFeats.add(entry);
        break;
      }
    }
  }

  return LanguageSourceBuilder.build(
    catalog: catalog,
    race: baseRace,
    subrace: subrace,
    background: _findBackground(backgrounds, character.backgroundId),
    classes: classSources,
    classFeatures: classFeatures,
    feats: takenFeats,
  );
});

/// Os idiomas do personagem: automáticos, escolhidos, vagas e pendências.
///
/// Único ponto de verdade. A seção da ficha, a tela de edição e a validação
/// leem daqui, e por isso não podem divergir.
final resolvedLanguagesProvider = FutureProvider.family
    .autoDispose<ResolvedLanguages, Character>((ref, character) async {
  final catalog = await ref.watch(languageCatalogProvider.future);
  final bundle = await ref.watch(languageSourcesProvider(character).future);

  return LanguageResolver.resolve(
    catalog: catalog,
    sources: bundle.sources,
    selections: character.languages,
  );
});

final manageCharacterLanguagesProvider =
    Provider<ManageCharacterLanguages>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return ManageCharacterLanguages(repository);
});

BackgroundEntry? _findBackground(List<BackgroundEntry> list, String? id) {
  if (id == null || id.isEmpty) return null;
  for (final item in list) {
    if (item.id == id) return item;
  }
  return null;
}
