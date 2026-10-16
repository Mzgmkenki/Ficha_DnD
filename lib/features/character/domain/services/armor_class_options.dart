import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';

/// Id da fórmula que vem do equipamento, e não de característica.
///
/// Existe para a escolha do jogador poder ser gravada mesmo quando ele prefere
/// a armadura: sem um id, "usar a armadura" seria indistinguível de "nunca
/// escolhi".
const String armorClassEquipmentFormulaId = 'equipment';

/// Uma fórmula de CA-base que o personagem pode usar.
///
/// Reúne o que a tela precisa para oferecer a escolha: o número, a conta, se
/// aceita escudo e — quando não está valendo — o motivo.
class ArmorClassFormulaOption {
  const ArmorClassFormulaOption({
    required this.id,
    required this.label,
    required this.composition,
    required this.allowsShield,
    required this.isAvailable,
    this.value,
    this.sourceLabel,
    this.unavailableReason,
    this.note,
  });

  /// Id estável: o do efeito, ou [armorClassEquipmentFormulaId].
  final String id;

  final String label;

  /// A conta, como a ficha mostra.
  final String composition;

  /// O total da fórmula base. Nulo quando a fórmula não pôde ser avaliada.
  final int? value;

  final bool allowsShield;

  /// Se as condições estão cumpridas agora.
  final bool isAvailable;

  /// Origem e nível: `Bárbaro, nível 1`. Nulo na fórmula do equipamento.
  final String? sourceLabel;

  /// Por que não está valendo, quando não está.
  final String? unavailableReason;

  /// Observação de regra declarada no compêndio.
  final String? note;

  bool get isEquipment => id == armorClassEquipmentFormulaId;

  bool get isUsable => isAvailable && value != null;

  /// A base pronta para o cálculo, ou nulo na fórmula do equipamento.
  ArmorClassBase? get base {
    final total = value;
    if (isEquipment || total == null) return null;

    return ArmorClassBase(
      id: id,
      label: label,
      value: total,
      composition: composition,
      allowsShield: allowsShield,
    );
  }
}

/// A CA resolvida, junto com as fórmulas que estavam disponíveis.
class ArmorClassSelection {
  const ArmorClassSelection({
    required this.result,
    required this.options,
    required this.selectedId,
    this.fellBackFrom,
  });

  final ArmorClassResult result;

  /// Todas as fórmulas, inclusive as indisponíveis — a ficha precisa mostrar
  /// que existem e por que não podem ser usadas.
  final List<ArmorClassFormulaOption> options;

  /// Id da fórmula efetivamente usada.
  final String selectedId;

  /// Id da fórmula que o jogador havia escolhido e que não pôde ser usada.
  ///
  /// Preenchido quando a armadura equipada invalidou a escolha. A
  /// característica não é apagada e a preferência não é reescrita: o app só
  /// cai numa fórmula válida e avisa.
  final String? fellBackFrom;

  bool get usedFallback => fellBackFrom != null;

  List<ArmorClassFormulaOption> get usable =>
      options.where((item) => item.isUsable).toList(growable: false);

  /// Se há mais de uma fórmula válida, e portanto uma escolha a fazer.
  bool get hasChoice => usable.length > 1;

  ArmorClassFormulaOption? get selected {
    for (final option in options) {
      if (option.id == selectedId) return option;
    }
    return null;
  }

  /// Aviso para o jogador quando a escolha dele teve de ser trocada.
  String? get fallbackNotice {
    final from = fellBackFrom;
    if (from == null) return null;

    final original = options
        .where((item) => item.id == from)
        .cast<ArmorClassFormulaOption?>()
        .firstWhere((item) => item != null, orElse: () => null);

    final name = original?.label ?? 'a fórmula escolhida';
    final reason = original?.unavailableReason;
    final used = selected?.label ?? 'a CA do equipamento';

    return reason == null
        ? '$name não está valendo agora, então a CA usa $used.'
        : '$name não está valendo agora ($reason), então a CA usa $used.';
  }
}

/// Decide qual fórmula de CA vale e calcula a CA com ela.
///
/// Esta é a regra central do levantamento sobre CA: escolhe-se UMA fórmula
/// base e só depois entram os bônus independentes. Centralizar aqui é o que
/// impede a tela de CA, o resumo de combate e o PDF de chegarem a três números
/// diferentes para o mesmo personagem.
class ArmorClassOptions {
  const ArmorClassOptions._();

  /// As fórmulas base disponíveis, na ordem em que a ficha oferece.
  ///
  /// A do equipamento vem primeiro porque é a que todo personagem tem; as de
  /// característica entram depois, na ordem em que foram adquiridas.
  static List<ArmorClassFormulaOption> formulasFor({
    required ResolvedFeatures features,
    required AbilityScores abilityScores,
    required List<InventoryItem> inventory,
    required FeatureFormulaContext context,
  }) {
    final equipped = OwnedArmor.equippedWearable(
      inventory,
      abilityScores: abilityScores,
    );
    final hasShield = OwnedArmor.hasEquippedShield(inventory);
    final armor = OwnedArmor.effectiveArmor(
      inventory,
      abilityScores: abilityScores,
    );

    final equipmentResult = ArmorClassCalculator.calculate(
      armor: armor.option,
      abilityScores: abilityScores,
      armorMagicBonus: armor.magicBonus,
      stealthDisadvantage: armor.stealthDisadvantage,
    );

    final result = <ArmorClassFormulaOption>[
      ArmorClassFormulaOption(
        id: armorClassEquipmentFormulaId,
        label: equipped == null ? 'Sem armadura' : armor.name,
        composition: equipmentResult.explanation,
        value: equipmentResult.total,
        // A armadura sempre conviveu com escudo; é a fórmula de característica
        // que pode proibir.
        allowsShield: true,
        isAvailable: true,
      ),
    ];

    for (final feature in features.features) {
      for (final effect in feature.effects) {
        if (effect.path != FeatureEffectPaths.armorClassBase) continue;

        final blocked = _blockReason(
          effect: effect,
          feature: feature,
          inventory: inventory,
          abilityScores: abilityScores,
          hasShield: hasShield,
        );

        final evaluated = FeatureFormula.evaluate(effect.formula, context);

        result.add(
          ArmorClassFormulaOption(
            id: effect.id,
            label: effect.label ?? feature.name,
            composition: evaluated?.composition ?? (effect.formula ?? '—'),
            value: evaluated?.value,
            allowsShield:
                effect.conditions.shield != FeatureShieldCondition.forbidden,
            isAvailable: blocked == null && evaluated != null,
            sourceLabel: feature.sourceLabel,
            unavailableReason:
                blocked ??
                (evaluated == null
                    ? 'A fórmula declarada no compêndio não pôde ser lida.'
                    : null),
            note: effect.note,
          ),
        );
      }
    }

    return List<ArmorClassFormulaOption>.unmodifiable(result);
  }

  /// Calcula a CA respeitando a fórmula que o jogador escolheu.
  ///
  /// [preferredFormulaId] é a preferência gravada na ficha. Quando ela não
  /// pode ser usada — armadura vestida invalidando a Defesa sem Armadura, por
  /// exemplo — o cálculo cai na melhor fórmula válida e devolve o aviso em
  /// [ArmorClassSelection.fellBackFrom]. A preferência NÃO é apagada: tirar a
  /// armadura volta a valer a escolha original.
  static ArmorClassSelection resolve({
    required ResolvedFeatures features,
    required AbilityScores abilityScores,
    required List<InventoryItem> inventory,
    required FeatureFormulaContext context,
    String? preferredFormulaId,
    int otherBonus = 0,
  }) {
    final options = formulasFor(
      features: features,
      abilityScores: abilityScores,
      inventory: inventory,
      context: context,
    );

    final hasShield = OwnedArmor.hasEquippedShield(inventory);
    final armor = OwnedArmor.effectiveArmor(
      inventory,
      abilityScores: abilityScores,
    );

    final preferred = _find(options, preferredFormulaId);
    final chosen =
        preferred != null && preferred.isUsable ? preferred : _best(options);

    final fellBackFrom =
        preferred != null && !preferred.isUsable ? preferred.id : null;

    // O escudo mágico acompanha o escudo: se a fórmula escolhida não aceita
    // escudo, o `+1` dele também não entra. Somá-lo mesmo assim daria o bônus
    // do item sem o item estar valendo.
    final shieldMagicBonus =
        chosen.allowsShield
            ? (OwnedArmor.equippedShield(inventory)?.magicBonus ?? 0)
            : 0;

    final result = ArmorClassCalculator.calculate(
      armor: armor.option,
      abilityScores: abilityScores,
      hasShield: hasShield,
      otherBonus: otherBonus + shieldMagicBonus,
      armorMagicBonus: armor.magicBonus,
      stealthDisadvantage: armor.stealthDisadvantage,
      alternateBase: chosen.base,
    );

    return ArmorClassSelection(
      result: result,
      options: options,
      selectedId: chosen.id,
      fellBackFrom: fellBackFrom,
    );
  }

  /// A melhor fórmula válida.
  ///
  /// Serve de padrão para quem nunca escolheu e de rede de segurança quando a
  /// escolha salva deixou de valer. "Melhor" é a de maior CA, com a do
  /// equipamento desempatando a favor — ela é a que não impõe condição.
  static ArmorClassFormulaOption _best(List<ArmorClassFormulaOption> options) {
    final usable = options.where((item) => item.isUsable).toList();
    if (usable.isEmpty) return options.first;

    usable.sort((a, b) {
      final byValue = (b.value ?? 0).compareTo(a.value ?? 0);
      if (byValue != 0) return byValue;
      if (a.isEquipment != b.isEquipment) return a.isEquipment ? -1 : 1;
      return a.id.compareTo(b.id);
    });

    return usable.first;
  }

  static ArmorClassFormulaOption? _find(
    List<ArmorClassFormulaOption> options,
    String? id,
  ) {
    if (id == null || id.isEmpty) return null;
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  /// Por que a fórmula não pode ser usada agora, ou `null` quando pode.
  ///
  /// As frases são montadas aqui para a lista de seleção, o aviso de queda e o
  /// resumo de combate dizerem exatamente a mesma coisa.
  static String? _blockReason({
    required FeatureEffect effect,
    required ResolvedFeature feature,
    required List<InventoryItem> inventory,
    required AbilityScores abilityScores,
    required bool hasShield,
  }) {
    if (feature.isSuperseded) {
      return 'Você já tem esta característica por outra classe, e a regra de '
          'multiclasse não concede a segunda versão.';
    }

    final equipped = OwnedArmor.equippedWearable(
      inventory,
      abilityScores: abilityScores,
    );

    switch (effect.conditions.armor) {
      case FeatureArmorCondition.any:
        break;
      case FeatureArmorCondition.none:
        if (equipped != null) {
          return '${equipped.name} está equipada, e esta fórmula exige estar '
              'sem armadura';
        }
      case FeatureArmorCondition.notHeavy:
        if (equipped != null &&
            equipped.armor?.category == ArmorCategory.heavy) {
          return '${equipped.name} é armadura pesada, e esta fórmula não '
              'permite armadura pesada';
        }
      case FeatureArmorCondition.armored:
        if (equipped == null) {
          return 'esta fórmula exige estar usando armadura';
        }
    }

    if (effect.conditions.shield == FeatureShieldCondition.forbidden &&
        hasShield) {
      return 'o escudo está equipado, e esta fórmula exige estar sem escudo';
    }

    return null;
  }
}
