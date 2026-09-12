import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/export_character.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/import_character.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_ability_scores.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_class_levels.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_identity.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_portrait.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/combat/update_character_hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/services/rest_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final charactersProvider = StreamProvider<List<Character>>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.watchAll();
});

/// Stream reativo: qualquer escrita no banco reflete na ficha sozinha.
/// `autoDispose` evita manter em cache todo personagem já visitado.
final characterByIdProvider =
    StreamProvider.autoDispose.family<Character?, String>((ref, id) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.watchById(id);
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

final updateCharacterIdentityProvider =
    Provider<UpdateCharacterIdentity>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return UpdateCharacterIdentity(repository);
});

final updateCharacterPortraitProvider =
    Provider<UpdateCharacterPortrait>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  final storage = ref.watch(portraitStorageProvider);
  return UpdateCharacterPortrait(repository, storage);
});

final exportCharacterProvider = Provider<ExportCharacter>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return ExportCharacter(repository);
});

final importCharacterProvider = Provider<ImportCharacter>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return ImportCharacter(repository);
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

final addMagicItemSpellProvider = Provider<
    Future<void> Function({
      required int magicItemId,
      required CharacterMagicItemSpell spell,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required int magicItemId,
    required CharacterMagicItemSpell spell,
  }) {
    return repository.addMagicItemSpell(
      magicItemId: magicItemId,
      spell: spell,
    );
  };
});

final removeMagicItemSpellProvider = Provider<
    Future<void> Function({
      required int magicItemId,
      required int spellId,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required int magicItemId,
    required int spellId,
  }) {
    return repository.removeMagicItemSpell(
      magicItemId: magicItemId,
      spellId: spellId,
    );
  };
});

final characterUsedSpellSlotsProvider =
    StreamProvider.autoDispose.family<Map<int, int>, String>((ref, characterId) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.watchUsedSpellSlots(characterId);
});

/// Aplica um descanso longo: PV cheios, espaços de magia renovados, cargas
/// dos itens mágicos recarregadas, metade dos dados de vida recuperados e 1
/// nível de exaustão removido.
final longRestProvider = Provider<
    Future<String> Function({
      required Character character,
      required int totalHitDice,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required Character character, required int totalHitDice}) async {
    final outcome = RestService.longRest(
      character: character,
      totalHitDice: totalHitDice,
    );

    await repository.update(outcome.character);
    await repository.resetUsedSpellSlots(
      characterId: character.id,
      slotLevels: outcome.clearedSpellSlotLevels,
    );

    // Itens mágicos moram em tabela própria: o `update` acima não os alcança.
    for (final recharge in outcome.magicItemRecharges) {
      await repository.updateMagicItemCharges(
        magicItemId: recharge.magicItemId,
        charges: recharge.charges,
      );
    }

    return outcome.summary;
  };
});

/// Aplica um descanso curto: apenas os espaços de Magia de Pacto voltam.
final shortRestProvider = Provider<
    Future<String> Function({
      required Character character,
      required List<int> pactSlotUsageKeys,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required Character character,
    required List<int> pactSlotUsageKeys,
  }) async {
    final outcome = RestService.shortRest(
      character: character,
      pactSlotUsageKeys: pactSlotUsageKeys,
    );

    await repository.update(outcome.character);

    if (pactSlotUsageKeys.isNotEmpty) {
      await repository.resetUsedSpellSlots(
        characterId: character.id,
        slotLevels: pactSlotUsageKeys,
      );
    }

    return outcome.summary;
  };
});

/// Gasta um dado de vida e cura o valor rolado + modificador de Constituição.
final spendHitDieProvider = Provider<
    Future<void> Function({
      required Character character,
      required int rolled,
      required int totalHitDice,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required Character character,
    required int rolled,
    required int totalHitDice,
  }) async {
    final updated = RestService.spendHitDie(
      character: character,
      rolled: rolled,
      constitutionModifier:
          character.abilityScores.constitution.abilityModifier,
      totalHitDice: totalHitDice,
    );

    await repository.update(updated);
  };
});

/// Alterna a inspiração heroica.
final toggleInspirationProvider =
    Provider<Future<void> Function(Character)>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return (Character character) {
    return repository.update(
      character.copyWith(
        inspiration: !character.inspiration,
        updatedAt: DateTime.now(),
      ),
    );
  };
});

/// Define o nível de exaustão (0 a 6).
final setExhaustionProvider =
    Provider<Future<void> Function(Character, int)>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return (Character character, int level) {
    return repository.update(
      character.copyWith(
        exhaustion: level.clamp(0, 6),
        updatedAt: DateTime.now(),
      ),
    );
  };
});
