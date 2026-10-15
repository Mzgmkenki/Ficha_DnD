import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_options.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_resources.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// As características especiais que o personagem realmente tem.
///
/// Fica indexado pelo personagem inteiro, como `combatOptionsProvider`, porque
/// o resultado depende de classe, subclasse e nível: qualquer mudança nessas
/// três coisas tem que produzir uma lista nova, e o `Character` é a única
/// chave que carrega as três.
final resolvedFeaturesProvider = FutureProvider.family
    .autoDispose<ResolvedFeatures, Character>((ref, character) async {
  final classes = await ref.watch(classEntriesProvider.future);
  final classFeatures = await ref.watch(classFeaturesProvider.future);
  final subclasses = await ref.watch(subclassEntriesProvider.future);

  return SpecialFeatureResolver.resolve(
    character: character,
    classes: classes,
    classFeatures: classFeatures,
    subclasses: subclasses,
  );
});

/// A CA do personagem, já com a fórmula escolhida resolvida.
///
/// Único ponto de verdade da CA derivada: a tela de cálculo, o resumo de
/// combate e o painel de características leem daqui, e por isso não podem
/// divergir.
final armorClassSelectionProvider = FutureProvider.family
    .autoDispose<ArmorClassSelection, Character>((ref, character) async {
  final features = await ref.watch(resolvedFeaturesProvider(character).future);

  return ArmorClassOptions.resolve(
    features: features,
    abilityScores: character.abilityScores,
    inventory: character.inventory,
    context: FeatureFormulaContext.fromCharacter(character),
    preferredFormulaId: character.armorClassFormulaId,
  );
});

/// Os recursos limitados que as características concedem.
final featureResourcesProvider = FutureProvider.family
    .autoDispose<List<FeatureResource>, Character>((ref, character) async {
  final features = await ref.watch(resolvedFeaturesProvider(character).future);

  return FeatureResources.from(
    character: character,
    features: features,
    context: FeatureFormulaContext.fromCharacter(character),
  );
});

/// O teto de cada atributo, já com as exceções declaradas por característica.
///
/// Existe como provider para a distribuição de incremento não precisar
/// conhecer o Campeão Primal: ela pergunta o teto e obedece.
final abilityMaximumsProvider = FutureProvider.family
    .autoDispose<Map<Ability, int>, Character>((ref, character) async {
  final features = await ref.watch(resolvedFeaturesProvider(character).future);

  return features.abilityMaximums(
    FeatureFormulaContext.fromCharacter(character),
  );
});

/// Escolhas de característica obrigatórias ainda em aberto.
final pendingFeatureChoicesProvider = FutureProvider.family
    .autoDispose<List<PendingFeatureChoice>, Character>((ref, character) async {
  final features = await ref.watch(resolvedFeaturesProvider(character).future);

  return features.pendingChoices(character.featureChoiceSelections);
});

final manageAbilityScoreImprovementsProvider =
    Provider<ManageAbilityScoreImprovements>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return ManageAbilityScoreImprovements(repository);
});

/// Gasta um uso de um recurso de característica.
final spendFeatureUseProvider = Provider<
    Future<void> Function({
      required Character character,
      required FeatureResource resource,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required Character character,
    required FeatureResource resource,
  }) async {
    final updated = FeatureResources.spend(
      character: character,
      resource: resource,
    );

    // Sem mudança não grava: o botão no limite não pode gerar escrita inútil
    // nem disparar a remontagem do agregado.
    if (identical(updated, character)) return;

    await repository.update(updated.copyWith(updatedAt: DateTime.now()));
  };
});

/// Devolve um uso de um recurso de característica.
final restoreFeatureUseProvider = Provider<
    Future<void> Function({
      required Character character,
      required FeatureResource resource,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required Character character,
    required FeatureResource resource,
  }) async {
    final updated = FeatureResources.restore(
      character: character,
      resource: resource,
    );

    if (identical(updated, character)) return;

    await repository.update(updated.copyWith(updatedAt: DateTime.now()));
  };
});

/// Grava a opção escolhida dentro de uma característica.
final chooseFeatureOptionProvider = Provider<
    Future<void> Function({
      required Character character,
      required String featureId,
      required String optionId,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required Character character,
    required String featureId,
    required String optionId,
  }) async {
    final updated = FeatureResources.chooseOption(
      character: character,
      featureId: featureId,
      optionId: optionId,
    );

    await repository.update(updated.copyWith(updatedAt: DateTime.now()));
  };
});

/// Grava a fórmula de CA que o jogador escolheu e a CA que ela produz.
///
/// As duas coisas numa gravação só: a CA é um inteiro persistido, e deixar a
/// fórmula salva com o número antigo faria a ficha mostrar uma coisa e o
/// gerenciamento de CA outra.
final chooseArmorClassFormulaProvider = Provider<
    Future<void> Function({
      required Character character,
      required String formulaId,
      required int armorClass,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required Character character,
    required String formulaId,
    required int armorClass,
  }) async {
    await repository.update(
      character.copyWith(
        armorClassFormulaId: formulaId,
        combatStats: character.combatStats.copyWith(armorClass: armorClass),
        updatedAt: DateTime.now(),
      ),
    );
  };
});
