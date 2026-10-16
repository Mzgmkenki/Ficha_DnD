import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/core/utils/dice_roller.dart';
import 'package:dnd_ficha_app/features/character/application/providers/class_mechanic_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/feature_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/invocation_providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/choose_subclass.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/create_character.dart';
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
import 'package:dnd_ficha_app/features/character/domain/entities/death_saves.dart';
import 'package:dnd_ficha_app/features/character/domain/services/active_effects.dart';
import 'package:dnd_ficha_app/features/character/domain/services/death_save_service.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_resources.dart';
import 'package:dnd_ficha_app/features/character/domain/services/level_progression_reversal.dart';
import 'package:dnd_ficha_app/features/character/domain/services/rest_service.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/weapon_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final charactersProvider = StreamProvider<List<Character>>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.watchAll();
});

final createCharacterProvider = Provider<CreateCharacter>((ref) {
  return CreateCharacter(ref.watch(characterRepositoryProvider));
});

/// Stream reativo: qualquer escrita no banco reflete na ficha sozinha.
/// `autoDispose` evita manter em cache todo personagem já visitado.
final characterByIdProvider = StreamProvider.autoDispose
    .family<Character?, String>((ref, id) {
      final repository = ref.watch(characterRepositoryProvider);
      return repository.watchById(id);
    });

final updateCharacterAbilityScoresProvider =
    Provider<UpdateCharacterAbilityScores>((ref) {
      final repository = ref.watch(characterRepositoryProvider);
      return UpdateCharacterAbilityScores(repository);
    });

final updateCharacterHitPointsProvider = Provider<UpdateCharacterHitPoints>((
  ref,
) {
  final repository = ref.watch(characterRepositoryProvider);
  return UpdateCharacterHitPoints(repository);
});

final updateCharacterProficienciesProvider =
    Provider<UpdateCharacterProficiencies>((ref) {
      final repository = ref.watch(characterRepositoryProvider);
      return UpdateCharacterProficiencies(repository);
    });

final updateCharacterIdentityProvider = Provider<UpdateCharacterIdentity>((
  ref,
) {
  final repository = ref.watch(characterRepositoryProvider);
  return UpdateCharacterIdentity(repository);
});

final manageCharacterFeatsProvider = Provider<ManageCharacterFeats>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return ManageCharacterFeats(repository);
});

final updateCharacterPortraitProvider = Provider<UpdateCharacterPortrait>((
  ref,
) {
  final repository = ref.watch(characterRepositoryProvider);
  final storage = ref.watch(portraitStorageProvider);
  return UpdateCharacterPortrait(repository, storage);
});

/// Gera o PDF da ficha, já com o compêndio carregado.
///
/// Devolve uma função em vez do caso de uso porque a tela não deveria precisar
/// saber quais listas do compêndio o PDF consome.
final exportCharacterPdfProvider = Provider<
  Future<CharacterPdf> Function(String)
>((ref) {
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

final updateCharacterClassLevelsProvider = Provider<UpdateCharacterClassLevels>(
  (ref) {
    final repository = ref.watch(characterRepositoryProvider);
    return UpdateCharacterClassLevels(repository);
  },
);

/// Diz quais vagas de progressão um personagem hipotético ainda concede.
///
/// Carrega o compêndio uma vez e devolve função síncrona, igual ao resolvedor
/// de aumentos de atributo: quem precisa disto está no meio de uma gravação de
/// níveis e tem de conferir contra os níveis NOVOS.
final progressionSlotResolverProvider = FutureProvider<ProgressionSlotResolver>(
  (ref) async {
    final classes = await ref.watch(classEntriesProvider.future);

    return (Character character) =>
        LevelProgressionReversal.validIdsFor(character, classes);
  },
);

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
  })
>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required String characterId, required CharacterSpell spell}) {
    return repository.addCharacterSpell(characterId: characterId, spell: spell);
  };
});

final removeCharacterSpellProvider = Provider<
  Future<void> Function({
    required String characterId,
    required int spellId,
    required String sourceType,
    required String sourceId,
  })
>((ref) {
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
  })
>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required String characterId, required CharacterMagicItem item}) {
    return repository.addMagicItem(characterId: characterId, item: item);
  };
});

/// Atualiza o item mágico inteiro: nome, descrição, cargas, bônus e uso.
///
/// Separado do provider de cargas de propósito. Gastar uma carga em mesa é o
/// caminho rápido e não pode arrastar o resto do item; editar a configuração do
/// item é o caminho completo e precisa gravar tudo.
final updateCharacterMagicItemProvider =
    Provider<Future<void> Function({required CharacterMagicItem item})>((ref) {
      final repository = ref.watch(characterRepositoryProvider);

      return ({required CharacterMagicItem item}) {
        return repository.updateMagicItem(item: item);
      };
    });

final updateCharacterMagicItemChargesProvider = Provider<
  Future<void> Function({required int magicItemId, required int? charges})
>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required int magicItemId, required int? charges}) {
    return repository.updateMagicItemCharges(
      magicItemId: magicItemId,
      charges: charges,
    );
  };
});

final deleteCharacterMagicItemProvider =
    Provider<Future<void> Function({required int magicItemId})>((ref) {
      final repository = ref.watch(characterRepositoryProvider);

      return ({required int magicItemId}) {
        return repository.deleteMagicItem(magicItemId: magicItemId);
      };
    });

final addMagicItemSpellProvider = Provider<
  Future<void> Function({
    required int magicItemId,
    required CharacterMagicItemSpell spell,
  })
>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required int magicItemId, required CharacterMagicItemSpell spell}) {
    return repository.addMagicItemSpell(magicItemId: magicItemId, spell: spell);
  };
});

final removeMagicItemSpellProvider = Provider<
  Future<void> Function({required int magicItemId, required int spellId})
>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required int magicItemId, required int spellId}) {
    return repository.removeMagicItemSpell(
      magicItemId: magicItemId,
      spellId: spellId,
    );
  };
});

final characterUsedSpellSlotsProvider = StreamProvider.autoDispose
    .family<Map<int, int>, String>((ref, characterId) {
      final repository = ref.watch(characterRepositoryProvider);
      return repository.watchUsedSpellSlots(characterId);
    });

/// As características cujos usos voltam com estas recargas.
///
/// Best-effort de propósito: se o compêndio não carregar, o descanso acontece
/// sem renovar usos de característica em vez de falhar. Perder PV e espaços de
/// magia por causa de uma falha de leitura de asset seria pior que a renovação
/// que o jogador pode devolver à mão.
Future<Set<String>> _featureIdsRestoredBy(
  Ref ref,
  Character character,
  Set<ActionRecharge> recharges,
) async {
  // Sem estado gravado não há gasto para zerar, e resolver o compêndio seria
  // leitura de asset para nada. Vale para a maioria dos descansos.
  if (character.featureStates.isEmpty) return const {};

  try {
    final features = await ref.read(resolvedFeaturesProvider(character).future);

    final result = <String>{
      ...FeatureResources.featureIdsRestoredBy(
        features: features,
        recharges: recharges,
      ),
    };

    // As invocações com usos limitados entram pela mesma porta: elas declaram
    // o mesmo bloco `action`, e um descanso curto tem de devolver Tumba de
    // Levistus junto com o resto.
    final invocations = await ref.read(
      resolvedInvocationsProvider(character).future,
    );

    result.addAll(
      FeatureResources.featureIdsRestoredBy(
        features: invocations.asFeatures,
        recharges: recharges,
      ),
    );

    // As mecânicas de classe entram pela terceira porta, com o mesmo
    // vocabulário: os Dados de Superioridade e as invocações de runa declaram
    // `recharge`, e um descanso curto tem de devolver os dois junto com o
    // resto. O resolvedor devolve as chaves de `featureStates`, que é onde os
    // usos de mecânica moram.
    final mechanics = await ref.read(
      resolvedClassMechanicsProvider(character).future,
    );

    result.addAll(mechanics.featureIdsRestoredBy(recharges));

    return result;
  } catch (error) {
    // Só a mensagem: `SrdAssetSource` já imprime arquivo e stack quando a
    // leitura falha, e repetir aqui enterra o resto do log.
    debugPrint('Falha ao resolver características no descanso: $error');
    return const {};
  }
}

/// Aplica um descanso longo: PV cheios, espaços de magia renovados, cargas
/// dos itens mágicos recarregadas, metade dos dados de vida recuperados e 1
/// nível de exaustão removido.
final longRestProvider = Provider<
  Future<String> Function({
    required Character character,
    required int totalHitDice,
  })
>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required Character character, required int totalHitDice}) async {
    final outcome = RestService.longRest(
      character: character,
      totalHitDice: totalHitDice,
      restoredFeatureIds: await _featureIdsRestoredBy(
        ref,
        character,
        FeatureResources.longRestRecharges,
      ),
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
  })
>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required Character character,
    required List<int> pactSlotUsageKeys,
  }) async {
    final outcome = RestService.shortRest(
      character: character,
      pactSlotUsageKeys: pactSlotUsageKeys,
      restoredFeatureIds: await _featureIdsRestoredBy(
        ref,
        character,
        FeatureResources.shortRestRecharges,
      ),
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
  })
>((ref) {
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
final toggleInspirationProvider = Provider<Future<void> Function(Character)>((
  ref,
) {
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
final setExhaustionProvider = Provider<Future<void> Function(Character, int)>((
  ref,
) {
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

/// Grava os marcadores dos testes contra a morte.
///
/// Mesmo caminho da exaustão: recebe o personagem inteiro, troca um campo e
/// grava. O clamp de 0 a 3 mora no próprio `DeathSaves`.
final setDeathSavesProvider =
    Provider<Future<void> Function(Character, DeathSaves)>((ref) {
      final repository = ref.watch(characterRepositoryProvider);

      return (Character character, DeathSaves saves) {
        return repository.update(
          character.copyWith(
            deathSaves: DeathSaves(
              successes: saves.successes.clamp(0, DeathSaves.maxMarks),
              failures: saves.failures.clamp(0, DeathSaves.maxMarks),
            ),
            updatedAt: DateTime.now(),
          ),
        );
      };
    });

/// Aplica um d20 já rolado às regras do teste contra a morte.
///
/// Recebe o resultado em vez de rolar aqui para o teste automatizado poder fixar
/// o dado, e para o `20` natural conseguir devolver 1 ponto de vida na mesma
/// gravação — dois `update` seguidos fariam a ficha piscar entre dois estados.
final rollDeathSaveProvider = Provider<
  Future<DeathSaveOutcome> Function({
    required Character character,
    required DiceRollResult roll,
  })
>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required Character character, required DiceRollResult roll}) async {
    final outcome = DeathSaveService.applyRoll(
      current: character.deathSaves,
      roll: roll,
    );

    final hitPoints =
        outcome.regainsHitPoint && character.hitPoints.current <= 0
            ? character.hitPoints.copyWith(current: 1)
            : character.hitPoints;

    await repository.update(
      character.copyWith(
        deathSaves: outcome.saves,
        hitPoints: hitPoints,
        updatedAt: DateTime.now(),
      ),
    );

    return outcome;
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
          character.copyWith(conditions: updated, updatedAt: DateTime.now()),
        );
      };
    });

/// Desmarca todas as condições de uma vez.
///
/// Existe porque no fim de um combate o jogador costuma sair de várias ao
/// mesmo tempo, e desmarcar uma a uma seriam vários toques e várias gravações.
final clearConditionsProvider = Provider<Future<void> Function(Character)>((
  ref,
) {
  final repository = ref.watch(characterRepositoryProvider);

  return (Character character) {
    return repository.update(
      character.copyWith(conditions: const {}, updatedAt: DateTime.now()),
    );
  };
});
