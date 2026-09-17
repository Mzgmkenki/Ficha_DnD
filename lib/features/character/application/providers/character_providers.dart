import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/choose_subclass.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/export_character.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/export_character_pdf.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/import_character.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/level_up_character_class.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_character_feats.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/sync_subclass_spells.dart';
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
import 'package:dnd_ficha_app/features/character/domain/services/active_effects.dart';
import 'package:dnd_ficha_app/features/character/domain/services/rest_service.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/weapon_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';
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

final manageCharacterFeatsProvider =
    Provider<ManageCharacterFeats>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return ManageCharacterFeats(repository);
});

final updateCharacterPortraitProvider =
    Provider<UpdateCharacterPortrait>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  final storage = ref.watch(portraitStorageProvider);
  return UpdateCharacterPortrait(repository, storage);
});

/// Gera o PDF da ficha, já com o compêndio carregado.
///
/// Devolve uma função em vez do caso de uso porque a tela não deveria precisar
/// saber quais listas do compêndio o PDF consome.
final exportCharacterPdfProvider =
    Provider<Future<CharacterPdf> Function(String)>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return (String characterId) async {
    final useCase = ExportCharacterPdf(repository);

    return useCase(
      characterId: characterId,
      classes: await ref.read(classEntriesProvider.future),
      subclasses: await ref.read(subclassEntriesProvider.future),
      races: await ref.read(raceEntriesProvider.future),
      backgrounds: await ref.read(backgroundEntriesProvider.future),
      classFeatures: await ref.read(classFeaturesProvider.future),
      feats: await ref.read(featEntriesProvider.future),
      spells: await ref.read(spellEntriesProvider.future),
      spellSlots: await ref.read(spellSlotProgressionsProvider.future),
      // Sem esta lista a seção de ataques sai vazia: `CharacterWeapon` guarda
      // só o id, e dado de dano e propriedades vivem no compêndio.
      weapons: await ref.read(weaponEntriesProvider.future),
    );
  };
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

final chooseSubclassProvider = Provider<ChooseSubclass>((ref) {
  return ChooseSubclass(
    ref.watch(characterRepositoryProvider),
    ref.watch(syncSubclassSpellsProvider),
  );
});

final syncSubclassSpellsProvider = Provider<SyncSubclassSpells>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return SyncSubclassSpells(repository);
});

/// Atalho de subir de nível da ficha.
///
/// Reaproveita os dois casos de uso que já existem em vez de repetir o cálculo
/// de PV e a reconciliação de magias.
final levelUpCharacterClassProvider = Provider<LevelUpCharacterClass>((ref) {
  return LevelUpCharacterClass(
    ref.watch(characterRepositoryProvider),
    ref.watch(updateCharacterClassLevelsProvider),
    ref.watch(syncSubclassSpellsProvider),
  );
});

/// Índice de nomes de magia do compêndio, para resolver as listas das
/// subclasses.
final spellNameIndexProvider = FutureProvider<SpellNameIndex>((ref) async {
  final spells = await ref.watch(spellEntriesProvider.future);
  return SpellNameIndex(spells);
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

/// Atualiza o item mágico inteiro: nome, descrição, cargas, bônus e uso.
///
/// Separado do provider de cargas de propósito. Gastar uma carga em mesa é o
/// caminho rápido e não pode arrastar o resto do item; editar a configuração do
/// item é o caminho completo e precisa gravar tudo.
final updateCharacterMagicItemProvider = Provider<
    Future<void> Function({
      required CharacterMagicItem item,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required CharacterMagicItem item}) {
    return repository.updateMagicItem(item: item);
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
        exhaustion: level.clamp(0, ActiveEffects.maxExhaustion),
        updatedAt: DateTime.now(),
      ),
    );
  };
});

/// Marca ou desmarca uma condição.
///
/// Grava só o que o jogador escolheu. As condições implicadas pelas regras
/// (Paralisado arrasta Incapacitado) não são gravadas: a ficha as deriva na
/// leitura, senão desmarcar Paralisado deixaria Incapacitado para trás.
final toggleConditionProvider =
    Provider<Future<void> Function(Character, Condition)>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return (Character character, Condition condition) {
    final updated = {...character.conditions};

    if (!updated.remove(condition)) {
      updated.add(condition);
    }

    return repository.update(
      character.copyWith(
        conditions: updated,
        updatedAt: DateTime.now(),
      ),
    );
  };
});

/// Desmarca todas as condições de uma vez.
///
/// Existe porque no fim de um combate o jogador costuma sair de várias ao
/// mesmo tempo, e desmarcar uma a uma seriam vários toques e várias gravações.
final clearConditionsProvider =
    Provider<Future<void> Function(Character)>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return (Character character) {
    return repository.update(
      character.copyWith(
        conditions: const {},
        updatedAt: DateTime.now(),
      ),
    );
  };
});
