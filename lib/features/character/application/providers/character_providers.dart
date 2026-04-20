import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_ability_scores.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_class_levels.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/combat/update_character_hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final charactersProvider = StreamProvider<List<Character>>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.watchAll();
});

final characterByIdProvider =
    FutureProvider.family<Character?, String>((ref, id) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.findById(id);
});

final updateCharacterAbilityScoresProvider =
    Provider<UpdateCharacterAbilityScores>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return UpdateCharacterAbilityScores(repository);
});

final updateCharacterHitPointsProvider =
    Provider<UpdateCharacterHitPoints>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return UpdateCharacterHitPoints(repository);
});

final updateCharacterProficienciesProvider =
    Provider<UpdateCharacterProficiencies>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return UpdateCharacterProficiencies(repository);
});

final deleteCharacterProvider = Provider<Future<void> Function(String)>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return (String id) => repository.delete(id);
});

final updateCharacterClassLevelsProvider =
    Provider<UpdateCharacterClassLevels>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return UpdateCharacterClassLevels(repository);
});

final addCharacterSpellProvider = Provider<
    Future<void> Function({
      required String characterId,
      required CharacterSpell spell,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required String characterId,
    required CharacterSpell spell,
  }) {
    return repository.addCharacterSpell(
      characterId: characterId,
      spell: spell,
    );
  };
});

final removeCharacterSpellProvider = Provider<
    Future<void> Function({
      required String characterId,
      required int spellId,
      required String sourceType,
      required String sourceId,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required String characterId,
    required int spellId,
    required String sourceType,
    required String sourceId,
  }) {
    return repository.removeCharacterSpell(
      characterId: characterId,
      spellId: spellId,
      sourceType: sourceType,
      sourceId: sourceId,
    );
  };
});

final addCharacterMagicItemProvider = Provider<
    Future<void> Function({
      required String characterId,
      required CharacterMagicItem item,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required String characterId,
    required CharacterMagicItem item,
  }) {
    return repository.addMagicItem(
      characterId: characterId,
      item: item,
    );
  };
});

final updateCharacterMagicItemChargesProvider = Provider<
    Future<void> Function({
      required int magicItemId,
      required int? charges,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required int magicItemId,
    required int? charges,
  }) {
    return repository.updateMagicItemCharges(
      magicItemId: magicItemId,
      charges: charges,
    );
  };
});

final deleteCharacterMagicItemProvider = Provider<
    Future<void> Function({
      required int magicItemId,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required int magicItemId,
  }) {
    return repository.deleteMagicItem(
      magicItemId: magicItemId,
    );
  };
});

final characterUsedSpellSlotsProvider =
    FutureProvider.family<Map<int, int>, String>((ref, characterId) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.getUsedSpellSlots(characterId);
});