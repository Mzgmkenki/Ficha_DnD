import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feature_state.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';

/// Um recurso limitado de característica, já resolvido para este personagem.
///
/// O máximo é DERIVADO (nível, atributo, proficiência) e o gasto é
/// PERSISTIDO. É o que mantém a conta certa quando o personagem evolui: um
/// Monge que sobe de nível passa a ter mais pontos sem que ninguém mexa no
/// que ele já gastou.
class FeatureResource {
  const FeatureResource({
    required this.featureId,
    required this.label,
    required this.sourceLabel,
    required this.maximum,
    required this.spent,
    this.recharge,
    this.cost,
  });

  final String featureId;
  final String label;

  /// Origem e nível: `Bárbaro, nível 1`.
  final String sourceLabel;

  final int maximum;
  final int spent;

  /// Quando volta. Nulo quando a característica não declara.
  final ActionRecharge? recharge;

  /// Custo declarado além do tipo de ação, em texto.
  final String? cost;

  int get remaining {
    final left = maximum - spent;
    if (left < 0) return 0;
    return left > maximum ? maximum : left;
  }

  bool get isExhausted => remaining <= 0;

  bool get canSpend => remaining > 0;

  bool get canRestore => spent > 0;

  /// Como a ficha mostra: `2 de 3`.
  String get usesLabel => '$remaining de $maximum';

  /// Quando volta, em texto. Nulo quando não foi declarado.
  String? get rechargeLabel => recharge?.label;
}

/// Lê e escreve os usos dos recursos de característica.
///
/// Reaproveita o bloco `action` que o compêndio já declara — `uses`,
/// `uses_formula` e `recharge` —, em vez de criar um segundo lugar para dizer
/// a mesma coisa. Era o requisito de "uma só fonte de dados": a seção de Ações
/// em combate e a de Recursos e descanso leem a MESMA declaração.
class FeatureResources {
  const FeatureResources._();

  /// Recargas que um descanso curto devolve.
  ///
  /// `shortRest` no asset significa "descanso curto ou longo", que é como o
  /// livro escreve na maioria dos casos. `turn` e `round` entram porque
  /// qualquer pausa já passou por eles.
  static const Set<ActionRecharge> shortRestRecharges = {
    ActionRecharge.shortRest,
    ActionRecharge.turn,
    ActionRecharge.round,
  };

  /// Recargas que um descanso longo devolve.
  ///
  /// Inclui as do curto: quem recupera no curto está cheio depois de um longo.
  /// `dawn` entra porque o descanso longo atravessa a noite — é a mesma
  /// leitura que `RestService.rechargesOnLongRest` já faz para item mágico.
  ///
  /// O que NÃO entra, de propósito: recarga condicional declarada em outro
  /// vocabulário. O levantamento é explícito em não unificar "amanhecer" com
  /// "1d4 descansos longos", e uma recarga que o app não conhece fica para o
  /// jogador devolver à mão em vez de ser zerada por conta própria.
  static const Set<ActionRecharge> longRestRecharges = {
    ActionRecharge.shortRest,
    ActionRecharge.longRest,
    ActionRecharge.dawn,
    ActionRecharge.turn,
    ActionRecharge.round,
  };

  /// Os recursos limitados que o personagem tem agora.
  static List<FeatureResource> from({
    required Character character,
    required ResolvedFeatures features,
    required FeatureFormulaContext context,
  }) {
    final result = <FeatureResource>[];

    for (final feature in features.features) {
      final action = feature.action;
      if (action == null || !action.hasLimitedUses) continue;
      // Característica superada não tem recurso: ela não está valendo.
      if (feature.isSuperseded) continue;

      final maximum = maximumFor(action, context);
      if (maximum == null || maximum <= 0) continue;

      final spent = character.featureStateFor(feature.id)?.usesSpent ?? 0;

      result.add(
        FeatureResource(
          featureId: feature.id,
          label: action.label ?? feature.name,
          sourceLabel: feature.sourceLabel,
          maximum: maximum,
          spent: spent > maximum ? maximum : spent,
          recharge: action.recharge,
          cost: action.cost,
        ),
      );
    }

    return List<FeatureResource>.unmodifiable(result);
  }

  /// Quantos usos a característica concede.
  ///
  /// Fórmula desconhecida devolve `null`, e o recurso não aparece com número:
  /// melhor não mostrar contador nenhum que mostrar um errado. A descrição da
  /// característica continua dizendo a conta.
  static int? maximumFor(FeatureAction action, FeatureFormulaContext context) {
    final fixed = action.uses;
    if (fixed != null) return fixed;

    final formula = action.usesFormula?.trim().toLowerCase();
    if (formula == null || formula.isEmpty) return null;

    // `proficiency` é o vocabulário que o asset já usa; o resto passa pelo
    // avaliador, que entende `mod.wisdom`, `level.monk` e constantes.
    if (formula == 'proficiency') return context.proficiencyBonus;

    return FeatureFormula.valueOf(formula, context);
  }

  /// Gasta um uso, sem nunca passar do máximo.
  static Character spend({
    required Character character,
    required FeatureResource resource,
    int amount = 1,
  }) {
    if (amount <= 0 || !resource.canSpend) return character;

    final next = resource.spent + amount;
    return _write(
      character: character,
      featureId: resource.featureId,
      usesSpent: next > resource.maximum ? resource.maximum : next,
    );
  }

  /// Devolve um uso, sem nunca ficar negativo.
  static Character restore({
    required Character character,
    required FeatureResource resource,
    int amount = 1,
  }) {
    if (amount <= 0 || !resource.canRestore) return character;

    final next = resource.spent - amount;
    return _write(
      character: character,
      featureId: resource.featureId,
      usesSpent: next < 0 ? 0 : next,
    );
  }

  /// Liga ou desliga o estado ativável de uma característica.
  static Character setActive({
    required Character character,
    required String featureId,
    required bool isActive,
  }) {
    return _write(
      character: character,
      featureId: featureId,
      isActive: isActive,
    );
  }

  /// Grava a opção escolhida dentro de uma característica.
  static Character chooseOption({
    required Character character,
    required String featureId,
    required String optionId,
  }) {
    return _write(
      character: character,
      featureId: featureId,
      choiceOptionId: optionId,
    );
  }

  /// Os ids das características cujos usos voltam com [recharges].
  ///
  /// Devolve ids, e não o personagem já alterado, para `RestService` continuar
  /// sem depender do compêndio: quem conhece as características é a camada que
  /// as carregou.
  static Set<String> featureIdsRestoredBy({
    required ResolvedFeatures features,
    required Set<ActionRecharge> recharges,
  }) {
    final result = <String>{};

    for (final feature in features.features) {
      final recharge = feature.action?.recharge;
      if (recharge == null) continue;
      if (!recharges.contains(recharge)) continue;

      result.add(feature.id);
    }

    return result;
  }

  /// Zera o gasto das características informadas.
  static Character restoreAll({
    required Character character,
    required Set<String> featureIds,
  }) {
    if (featureIds.isEmpty) return character;

    final next = [
      for (final state in character.featureStates)
        if (featureIds.contains(state.featureId))
          state.copyWith(usesSpent: 0)
        else
          state,
    ];

    return character.copyWith(featureStates: next);
  }

  static Character _write({
    required Character character,
    required String featureId,
    int? usesSpent,
    bool? isActive,
    String? choiceOptionId,
  }) {
    final existing = character.featureStateFor(featureId);

    if (existing == null) {
      return character.copyWith(
        featureStates: [
          ...character.featureStates,
          CharacterFeatureState(
            featureId: featureId,
            usesSpent: usesSpent ?? 0,
            isActive: isActive ?? false,
            choiceOptionId: choiceOptionId,
          ),
        ],
      );
    }

    return character.copyWith(
      featureStates: [
        for (final state in character.featureStates)
          if (state.featureId == featureId)
            state.copyWith(
              usesSpent: usesSpent,
              isActive: isActive,
              choiceOptionId: choiceOptionId,
            )
          else
            state,
      ],
    );
  }
}
