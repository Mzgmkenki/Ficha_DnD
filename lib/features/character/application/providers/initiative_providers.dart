import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/initiative_calculator.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Iniciativa do personagem, recalculada quando a build muda.
///
/// A família recebe o [Character] inteiro, como o provider de opções de
/// combate: subir de nível, escolher subclasse, pegar talento ou mudar Destreza
/// produzem um personagem novo, e a conta se refaz sozinha. Um id como chave
/// devolveria o valor velho.
final initiativeProvider =
    FutureProvider.family.autoDispose<InitiativeResult, Character>(
  (ref, character) async {
    return InitiativeCalculator.calculate(
      character: character,
      classFeatures: await ref.watch(classFeaturesProvider.future),
      subclasses: await ref.watch(subclassEntriesProvider.future),
      feats: await ref.watch(featEntriesProvider.future),
      races: await ref.watch(raceEntriesProvider.future),
    );
  },
);
