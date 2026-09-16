import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';

/// Uma coisa que o personagem pode fazer no turno.
///
/// É o formato único da seção "Ações em combate": ação universal do PHB,
/// característica de classe, magia, talento ou item mágico chegam todos aqui,
/// para o painel não precisar saber de onde cada linha veio.
///
/// Deliberadamente sem lógica de regra: quem decide disponibilidade é o
/// resolvedor, e o que fica guardado aqui é a conclusão já tomada, com o motivo
/// junto. Assim a tela nunca recalcula regra.
class CombatOption {
  const CombatOption({
    required this.id,
    required this.name,
    required this.actionType,
    required this.source,
    this.summary,
    this.sourceLabel,
    this.requirement,
    this.cost,
    this.resourceLabel,
    this.maxUses,
    this.remainingUses,
    this.recharge,
    this.trigger,
    this.isAvailable = true,
    this.unavailableReason,
    this.priority = 100,
    this.ruleReference,
    this.origins = const [],
  });

  /// Identificador estável dentro da lista montada, usado para deduplicar e
  /// como chave de widget.
  final String id;

  final String name;

  /// Descrição curta e prática, do tamanho de uma linha de mesa.
  final String? summary;

  final CombatActionType actionType;
  final CombatOptionSource source;

  /// Nome da fonte concreta: "Guerreiro 2", "Caçador", "Humano Variante".
  final String? sourceLabel;

  /// Condição necessária para usar, em texto.
  final String? requirement;

  /// O que custa além do tipo de ação: um espaço de 1º círculo, 2 pontos de ki.
  final String? cost;

  /// Nome do recurso consumido, quando existe um.
  final String? resourceLabel;

  final int? maxUses;

  /// Usos restantes, quando o app realmente rastreia esse recurso.
  ///
  /// Nulo quando não há rastreamento: hoje só espaços de magia e cargas de item
  /// são persistidos. Nulo com [maxUses] preenchido significa "a regra dá N
  /// usos, mas quem conta é a mesa" — melhor que mostrar um contador falso.
  final int? remainingUses;

  final ActionRecharge? recharge;

  /// O que dispara a reação.
  final String? trigger;

  final bool isAvailable;

  /// Por que não está disponível. Só faz sentido com [isAvailable] falso.
  final String? unavailableReason;

  /// Ordem dentro do grupo: menor aparece antes.
  ///
  /// Serve para as ações que o jogador usa toda hora ficarem no topo, e as
  /// universais raras no fim.
  final int priority;

  /// De onde a regra vem, para conferência: "PHB, cap. 9", "Guerreiro, 2º".
  final String? ruleReference;

  /// Todas as fontes que concedem esta mesma opção.
  ///
  /// Um multiclasse Guerreiro/Patrulheiro tem Ataque Extra pelas duas classes,
  /// e Segundo Sopro por uma só. A opção aparece uma vez, e aqui fica registrado
  /// que veio de mais de um lugar.
  final List<String> origins;

  bool get hasLimitedUses => maxUses != null;

  /// Se o recurso acabou. Falso quando não há rastreamento, porque aí não se
  /// sabe — e afirmar que acabou seria pior que não afirmar nada.
  bool get isExhausted {
    final left = remainingUses;
    return left != null && left <= 0;
  }

  /// Texto pronto de usos, ou nulo quando não há nada a dizer.
  ///
  /// Fica na entidade, e não no widget, porque a mesma frase aparece no painel
  /// e no detalhe — e porque a diferença entre "sem rastreamento" e "esgotado"
  /// é sutil o bastante para não ser reescrita em dois lugares.
  String? get usesLabel {
    final max = maxUses;
    if (max == null) return null;

    final left = remainingUses;
    final recharges = recharge;
    final suffix = recharges == null || recharges == ActionRecharge.none
        ? ''
        : ', recarrega em ${recharges.label}';

    if (left == null) {
      return max == 1 ? '1 uso$suffix' : '$max usos$suffix';
    }

    return '$left de $max$suffix';
  }

  CombatOption copyWith({
    String? id,
    String? name,
    String? summary,
    CombatActionType? actionType,
    CombatOptionSource? source,
    String? sourceLabel,
    String? requirement,
    String? cost,
    String? resourceLabel,
    int? maxUses,
    int? remainingUses,
    ActionRecharge? recharge,
    String? trigger,
    bool? isAvailable,
    String? unavailableReason,
    int? priority,
    String? ruleReference,
    List<String>? origins,
  }) {
    return CombatOption(
      id: id ?? this.id,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      actionType: actionType ?? this.actionType,
      source: source ?? this.source,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      requirement: requirement ?? this.requirement,
      cost: cost ?? this.cost,
      resourceLabel: resourceLabel ?? this.resourceLabel,
      maxUses: maxUses ?? this.maxUses,
      remainingUses: remainingUses ?? this.remainingUses,
      recharge: recharge ?? this.recharge,
      trigger: trigger ?? this.trigger,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailableReason: unavailableReason ?? this.unavailableReason,
      priority: priority ?? this.priority,
      ruleReference: ruleReference ?? this.ruleReference,
      origins: origins ?? this.origins,
    );
  }

  /// Marca como indisponível com o motivo.
  ///
  /// Existe porque bloquear é sempre "manter tudo e trocar duas coisas", e
  /// espalhar esse `copyWith` pelo resolvedor deixaria fácil esquecer o motivo.
  CombatOption blocked(String reason) {
    return copyWith(isAvailable: false, unavailableReason: reason);
  }
}
