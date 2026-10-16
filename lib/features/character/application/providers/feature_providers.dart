import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/class_mechanic_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/invocation_providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_class_levels.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_options.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_ability_bonuses.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_condition_state.dart';
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
final armorClassSelectionProvider = FutureProvider.family.autoDispose<
  ArmorClassSelection,
  Character
>((ref, character) async {
  final features = await ref.watch(resolvedFeaturesProvider(character).future);
  final mechanics = await ref.watch(
    resolvedClassMechanicsProvider(character).future,
  );

  final context = FeatureFormulaContext.fromCharacter(character);

  // O que está vestido agora. É contra isto que a condição declarada no
  // compêndio é medida: o +1 do estilo Defesa vale só com armadura, e sem este
  // estado ele entraria na CA de um personagem desarmado.
  final equipment = FeatureConditionState.from(
    inventory: character.inventory,
    abilityScores: character.abilityScores,
  );

  // Os bônus de CA das mecânicas entram pelo bônus avulso, e não como fórmula
  // base: eles SOMAM por cima da fórmula escolhida, como o anel de proteção.
  //
  // Só modo LIGADO conta — quem decide isso é
  // `ResolvedClassMechanics.armorClassBonus`. É o que impede o +2 do Eu Astral
  // Desperto de ficar na CA depois de o modo ser desligado, que é exatamente o
  // "não aplique permanentemente um bônus de modo temporário".
  final mechanicBonus = mechanics.armorClassBonus(
    context,
    equipment: equipment,
  );
  final featureBonus = features.armorClassBonus(context, equipment: equipment);

  return ArmorClassOptions.resolve(
    features: features,
    abilityScores: character.abilityScores,
    inventory: character.inventory,
    context: context,
    preferredFormulaId: character.armorClassFormulaId,
    // O bônus manual entra aqui para o número derivado ser o número final: a
    // ficha mostra este resultado direto, sem somar nada por cima.
    otherBonus: character.armorClassOtherBonus + mechanicBonus + featureBonus,
  );
});

/// Os recursos limitados que as características concedem.
///
/// Inclui as Invocações Místicas e as mecânicas de classe com usos limitados:
/// as três declaram o mesmo bloco `action` e gravam o gasto no mesmo
/// `featureStates`, e o jogador não tem motivo para procurar "Tumba de
/// Levistus" ou "Dados de Superioridade" numa segunda lista de recursos.
///
/// É também o que faz os botões de gastar e devolver funcionarem para os três
/// sem código novo: eles escrevem por `FeatureResources`, que só conhece a
/// chave do recurso.
final featureResourcesProvider = FutureProvider.family
    .autoDispose<List<FeatureResource>, Character>((ref, character) async {
      final features = await ref.watch(
        resolvedFeaturesProvider(character).future,
      );

      final fromFeatures = FeatureResources.from(
        character: character,
        features: features,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      final fromInvocations = await ref.watch(
        invocationResourcesProvider(character).future,
      );

      final fromMechanics = await ref.watch(
        classMechanicResourcesProvider(character).future,
      );

      if (fromInvocations.isEmpty && fromMechanics.isEmpty) return fromFeatures;

      return List<FeatureResource>.unmodifiable([
        ...fromFeatures,
        ...fromInvocations,
        ...fromMechanics,
      ]);
    });

/// O teto de cada atributo, já com as exceções declaradas por característica.
///
/// Existe como provider para a distribuição de incremento não precisar
/// conhecer o Campeão Primal: ela pergunta o teto e obedece.
final abilityMaximumsProvider = FutureProvider.family
    .autoDispose<Map<Ability, int>, Character>((ref, character) async {
      final features = await ref.watch(
        resolvedFeaturesProvider(character).future,
      );

      return features.abilityMaximums(
        FeatureFormulaContext.fromCharacter(character),
      );
    });

/// Resolve, para um personagem hipotético, os aumentos e os tetos de atributo
/// que as características concedem.
///
/// Carrega o compêndio uma vez e devolve uma função síncrona, porque quem
/// precisa disto está no meio de uma gravação de níveis: a tela monta o
/// personagem com os níveis NOVOS, e é contra ele que a conta tem de ser feita.
final featureAbilityBonusResolverProvider =
    FutureProvider<AbilityBonusResolver>((ref) async {
      final classes = await ref.watch(classEntriesProvider.future);
      final classFeatures = await ref.watch(classFeaturesProvider.future);
      final subclasses = await ref.watch(subclassEntriesProvider.future);

      return (Character character) {
        final features = SpecialFeatureResolver.resolve(
          character: character,
          classes: classes,
          classFeatures: classFeatures,
          subclasses: subclasses,
        );

        final context = FeatureFormulaContext.fromCharacter(character);

        return (
          granted: features.abilityBonuses(context),
          maximums: features.abilityMaximums(context),
        );
      };
    });

/// Acerta os aumentos de atributo concedidos por característica e grava só se
/// algo mudou.
///
/// Existe para o personagem que já estava salvo antes desta versão: um Bárbaro
/// de 20º nível criado antes do Campeão Primal ser automatizado recebe o +4 na
/// primeira vez que a ficha abre, e nunca mais. A migração do banco não pode
/// fazer isso porque decidir quem recebe exige ler o compêndio.
///
/// Devolve se houve mudança, para quem chama poder avisar o jogador de que os
/// atributos subiram sem ele ter mexido em nada.
final reconcileFeatureAbilityBonusesProvider =
    Provider<Future<bool> Function(String characterId)>((ref) {
      final repository = ref.watch(characterRepositoryProvider);

      return (String characterId) async {
        final character = await repository.findById(characterId);
        if (character == null) return false;

        final resolve = await ref.read(
          featureAbilityBonusResolverProvider.future,
        );
        final resolved = resolve(character);

        final updated = FeatureAbilityBonuses.reconcile(
          character: character,
          granted: resolved.granted,
          maximums: resolved.maximums,
        );

        // Identidade é o sinal de "nada a fazer". Sem esta saída, abrir a ficha
        // gravaria o personagem toda vez e remontaria o agregado à toa.
        if (identical(updated, character)) return false;

        await repository.update(updated.copyWith(updatedAt: DateTime.now()));
        return true;
      };
    });

/// Escolhas de característica obrigatórias ainda em aberto.
final pendingFeatureChoicesProvider = FutureProvider.family
    .autoDispose<List<PendingFeatureChoice>, Character>((ref, character) async {
      final features = await ref.watch(
        resolvedFeaturesProvider(character).future,
      );

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
  })
>((ref) {
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
  })
>((ref) {
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
  })
>((ref) {
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
  })
>((ref) {
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
