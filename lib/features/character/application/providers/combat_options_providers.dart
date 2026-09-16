import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/combat_options_resolver.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opções de combate do personagem, recalculadas quando a build muda.
///
/// A família recebe o [Character] inteiro de propósito: subir de nível, trocar
/// subclasse, pegar talento, preparar magia ou marcar condição produzem um
/// personagem novo, e o provider refaz a conta sozinho. Um id como chave
/// devolveria a lista velha depois de qualquer uma dessas mudanças.
final combatOptionsProvider =
    FutureProvider.family.autoDispose<CombatOptions, Character>(
  (ref, character) async {
    final classes = await ref.watch(classEntriesProvider.future);
    final classFeatures = await ref.watch(classFeaturesProvider.future);
    final subclasses = await ref.watch(subclassEntriesProvider.future);
    final spells = await ref.watch(spellEntriesProvider.future);

    return CombatOptionsResolver.resolve(
      character: character,
      classes: classes,
      classFeatures: classFeatures,
      subclasses: subclasses,
      spells: spells,
    );
  },
);
