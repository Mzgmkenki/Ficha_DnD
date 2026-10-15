import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Caminhos de efeito que o motor conhece.
///
/// São os identificadores que o asset usa no campo `path`. Ficam como
/// constantes, e não como enum, porque o conjunto cresce com o conteúdo: um
/// caminho que o código ainda não resolve continua sendo dado válido, aparece
/// na ficha como texto de referência e não derruba a leitura das outras
/// características.
class FeatureEffectPaths {
  const FeatureEffectPaths._();

  /// Fórmula alternativa de CA-base, como Defesa sem Armadura.
  ///
  /// É FÓRMULA BASE, não bônus: nunca soma com a CA da armadura nem com outra
  /// fórmula base. Ver `ArmorClassOptions`.
  static const String armorClassBase = 'ac.base';

  /// Bônus que soma por cima da CA-base escolhida.
  static const String armorClassBonus = 'ac.bonus';

  /// Teto de crescimento de um atributo, quando a característica declara um
  /// diferente do 20 padrão (Campeão Primal passa Força e Constituição a 24).
  static const String abilityMaximum = 'ability.maximum';

  /// Caminhos que o resolvedor transforma em número na ficha.
  ///
  /// O que não está aqui é tratado como informativo: fica estruturado, com
  /// origem e nível, mas quem aplica é o jogador. É o inverso de adivinhar um
  /// valor errado a partir de dado que o código não entende.
  static const List<String> calculated = [
    armorClassBase,
    armorClassBonus,
    abilityMaximum,
  ];

  static bool isCalculated(String path) => calculated.contains(path);
}

/// O que o efeito faz com o valor que encontra no caminho.
enum FeatureEffectOperation {
  /// Acrescenta uma OPÇÃO, sem mexer em valor nenhum. É como uma fórmula
  /// alternativa de CA entra: ela passa a estar disponível para escolha.
  grant('grant'),

  /// Soma ao valor atual.
  add('add'),

  /// Substitui o valor atual.
  set('set'),

  /// Vale se for maior que o atual. É o que impede duas fontes do mesmo
  /// benefício de se somarem.
  max('max'),

  /// Vale se for menor que o atual.
  min('min');

  const FeatureEffectOperation(this.id);

  final String id;

  static FeatureEffectOperation? fromId(String? id) {
    if (id == null) return null;
    final normalized = id.trim().toLowerCase();
    for (final item in FeatureEffectOperation.values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}

/// Como o efeito conversa com outros iguais.
enum FeatureEffectStacking {
  /// Só um do grupo vale por vez, e quem escolhe é o jogador. É o caso das
  /// fórmulas de CA-base.
  exclusive('exclusive'),

  /// Todos valem, mas só o maior tem efeito.
  highest('highest'),

  /// Somam.
  sum('sum');

  const FeatureEffectStacking(this.id);

  final String id;

  static FeatureEffectStacking? fromId(String? id) {
    if (id == null) return null;
    final normalized = id.trim().toLowerCase();
    for (final item in FeatureEffectStacking.values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}

/// O que o efeito exige da armadura vestida.
enum FeatureArmorCondition {
  /// Não exige nada.
  any('any'),

  /// Só sem armadura nenhuma.
  none('none'),

  /// Qualquer armadura, menos pesada.
  notHeavy('not_heavy');

  const FeatureArmorCondition(this.id);

  final String id;

  static FeatureArmorCondition? fromId(String? id) {
    if (id == null) return null;
    final normalized = id.trim().toLowerCase();
    for (final item in FeatureArmorCondition.values) {
      if (item.id == normalized) return item;
    }
    // Sinônimos que aparecem em dado escrito à mão.
    switch (normalized) {
      case 'unarmored':
      case 'sem_armadura':
        return FeatureArmorCondition.none;
      case 'not_heavy_armor':
      case 'sem_armadura_pesada':
        return FeatureArmorCondition.notHeavy;
      default:
        return null;
    }
  }
}

/// O que o efeito exige do escudo.
///
/// Existe separado da armadura porque a diferença entre a Defesa sem Armadura
/// do Bárbaro e a do Monge é exatamente esta: as duas pedem "sem armadura", e
/// só uma proíbe escudo. Deduzir isso do texto daria errado em metade dos
/// casos.
enum FeatureShieldCondition {
  /// Escudo permitido.
  allowed('allowed'),

  /// Escudo impede o efeito.
  forbidden('forbidden');

  const FeatureShieldCondition(this.id);

  final String id;

  static FeatureShieldCondition? fromId(String? id) {
    if (id == null) return null;
    final normalized = id.trim().toLowerCase();
    for (final item in FeatureShieldCondition.values) {
      if (item.id == normalized) return item;
    }
    switch (normalized) {
      case 'any':
      case 'permitido':
        return FeatureShieldCondition.allowed;
      case 'proibido':
        return FeatureShieldCondition.forbidden;
      default:
        return null;
    }
  }
}

/// Onde a ficha mostra o efeito.
///
/// Decidido no dado, e não na tela, para a mesma característica não aparecer
/// em dois lugares por descuido — e para uma característica nova entrar na
/// área certa sem mexer em widget nenhum.
enum FeatureDisplaySlot {
  /// Gerenciamento de CA.
  armorClass('armor_class'),

  /// Ações em combate.
  combatActions('combat_actions'),

  /// Recursos e descanso.
  resources('resources'),

  /// Características de classe ou de subclasse.
  features('features'),

  /// Junto às perícias afetadas.
  skills('skills'),

  /// Junto às armas e aos ataques.
  attacks('attacks'),

  /// Área de conjuração.
  spellcasting('spellcasting'),

  /// Resistências, imunidades e sentidos.
  defenses('defenses'),

  /// Atributos.
  abilities('abilities');

  const FeatureDisplaySlot(this.id);

  final String id;

  static FeatureDisplaySlot? fromId(String? id) {
    if (id == null) return null;
    final normalized = id.trim().toLowerCase();
    for (final item in FeatureDisplaySlot.values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}

/// Condições para o efeito estar valendo.
///
/// Só o que o app consegue conferir sozinho. Condição de combate ("enquanto em
/// Fúria") não entra aqui: ela depende de estado que o jogador declara, e
/// adivinhar produziria número errado na ficha.
class FeatureEffectConditions {
  const FeatureEffectConditions({
    this.armor = FeatureArmorCondition.any,
    this.shield = FeatureShieldCondition.allowed,
  });

  final FeatureArmorCondition armor;
  final FeatureShieldCondition shield;

  bool get isEmpty =>
      armor == FeatureArmorCondition.any &&
      shield == FeatureShieldCondition.allowed;

  /// Exigências em texto, para a ficha explicar por que o efeito não está
  /// valendo. Vazia quando não há nenhuma.
  List<String> get descriptions {
    return [
      switch (armor) {
        FeatureArmorCondition.any => null,
        FeatureArmorCondition.none => 'sem armadura',
        FeatureArmorCondition.notHeavy => 'sem armadura pesada',
      },
      if (shield == FeatureShieldCondition.forbidden) 'sem escudo',
    ].whereType<String>().toList(growable: false);
  }

  static FeatureEffectConditions tryParse(Object? raw) {
    if (raw is! Map) return const FeatureEffectConditions();

    return FeatureEffectConditions(
      armor:
          FeatureArmorCondition.fromId(raw['armor']?.toString()) ??
          FeatureArmorCondition.any,
      shield:
          FeatureShieldCondition.fromId(raw['shield']?.toString()) ??
          FeatureShieldCondition.allowed,
    );
  }
}

/// Um efeito declarado de uma característica de classe ou subclasse.
///
/// É o registro normalizado do levantamento: identificador estável, caminho
/// afetado, operação, fórmula, condições e regra de acúmulo. A interface lê o
/// resultado já resolvido (ver `SpecialFeatureResolver`) e não repete nenhuma
/// dessas decisões.
///
/// Por que identificador e não nome: o nome é traduzido, aparece repetido em
/// classes diferentes com efeito diferente (Defesa sem Armadura do Bárbaro e
/// do Monge) e muda quando o compêndio é revisado. Comparar texto de interface
/// seria a forma mais frágil possível de ligar dado a regra.
class FeatureEffect {
  const FeatureEffect({
    required this.id,
    required this.path,
    required this.operation,
    this.formula,
    this.abilities = const [],
    this.conditions = const FeatureEffectConditions(),
    this.stacking = FeatureEffectStacking.sum,
    this.group,
    this.unique,
    this.priority = 100,
    this.label,
    this.note,
    this.display,
  });

  /// Identificador estável, único no compêndio.
  final String id;

  /// Campo afetado. Ver [FeatureEffectPaths].
  final String path;

  final FeatureEffectOperation operation;

  /// Expressão sobre atributos, proficiência e nível. Ver `FeatureFormula`.
  ///
  /// Nula nos efeitos informativos, que não produzem número.
  final String? formula;

  /// Atributos que o efeito atinge, quando o caminho é por atributo.
  final List<Ability> abilities;

  final FeatureEffectConditions conditions;

  final FeatureEffectStacking stacking;

  /// Chave que junta efeitos que disputam o mesmo espaço.
  ///
  /// Duas fórmulas de CA-base ficam no mesmo grupo e por isso nunca somam.
  final String? group;

  /// Identidade da característica entre classes, para a regra de multiclasse.
  ///
  /// O levantamento é explícito: quem já tem Defesa sem Armadura não ganha uma
  /// segunda versão ao entrar em outra classe. Sem uma chave compartilhada, o
  /// código teria que comparar nomes — e o nome é justamente o que coincide
  /// entre duas versões mecanicamente diferentes.
  final String? unique;

  /// Ordem de resolução. Menor resolve primeiro.
  final int priority;

  /// Nome curto para a ficha, quando o da característica é longo demais.
  final String? label;

  /// Observação de regra que o app não arbitra.
  final String? note;

  /// Onde mostrar. Nulo deixa a decisão para o consumidor.
  final FeatureDisplaySlot? display;

  /// Se o resolvedor transforma este efeito em número.
  bool get isCalculated => FeatureEffectPaths.isCalculated(path);

  /// Lê um item do array `effects` do asset.
  ///
  /// Tolerante como o resto do compêndio: entrada sem id, sem caminho ou com
  /// operação desconhecida é descartada em vez de derrubar a leitura das
  /// outras. Em um arquivo com centenas de características, uma linha errada
  /// não pode apagar o resto.
  static FeatureEffect? tryParse(Object? raw) {
    if (raw is! Map) return null;

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    final id = text('id');
    final path = text('path');
    if (id == null || path == null) return null;

    final operation = FeatureEffectOperation.fromId(raw['operation']?.toString());
    if (operation == null) return null;

    final abilities = <Ability>[];
    final rawAbilities = raw['abilities'];
    if (rawAbilities is List) {
      for (final item in rawAbilities) {
        final ability = Ability.fromName(item?.toString().trim());
        if (ability != null) abilities.add(ability);
      }
    }

    final priority = raw['priority'];

    return FeatureEffect(
      id: id,
      path: path,
      operation: operation,
      formula: text('formula'),
      abilities: abilities,
      conditions: FeatureEffectConditions.tryParse(raw['conditions']),
      stacking:
          FeatureEffectStacking.fromId(raw['stacking']?.toString()) ??
          FeatureEffectStacking.sum,
      group: text('group'),
      unique: text('unique'),
      priority: priority is int
          ? priority
          : priority is num
              ? priority.toInt()
              : int.tryParse(priority?.toString().trim() ?? '') ?? 100,
      label: text('label'),
      note: text('note'),
      display: FeatureDisplaySlot.fromId(raw['display']?.toString()),
    );
  }

  /// Lê o array `effects` inteiro, descartando o que não dá para usar.
  static List<FeatureEffect> parseList(Object? raw) {
    if (raw is! List) return const [];

    final result = <FeatureEffect>[];
    for (final item in raw) {
      final effect = tryParse(item);
      if (effect != null) result.add(effect);
    }

    return result.isEmpty ? const [] : List<FeatureEffect>.unmodifiable(result);
  }
}

/// Uma opção dentro de uma escolha de característica.
class FeatureChoiceOption {
  const FeatureChoiceOption({
    required this.id,
    required this.label,
    this.description,
    this.effects = const [],
  });

  /// Identificador estável. É o que fica persistido na ficha, e não o rótulo:
  /// corrigir o texto do compêndio não pode invalidar a escolha do jogador.
  final String id;

  final String label;
  final String? description;

  /// Efeitos que esta opção acrescenta, no mesmo formato de [FeatureEffect].
  final List<FeatureEffect> effects;

  static FeatureChoiceOption? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final id = raw['id']?.toString().trim();
    final label = raw['label']?.toString().trim();
    if (id == null || id.isEmpty || label == null || label.isEmpty) return null;

    final description = raw['description']?.toString().trim();

    return FeatureChoiceOption(
      id: id,
      label: label,
      description: description == null || description.isEmpty
          ? null
          : description,
      effects: FeatureEffect.parseList(raw['effects']),
    );
  }
}

/// Uma decisão que a característica exige do jogador.
///
/// Fica declarada no compêndio para a ficha saber que falta escolher algo sem
/// precisar conhecer a característica: é o que permite bloquear a conclusão da
/// evolução com uma escolha pendente (ver `PendingFeatureChoices`).
class FeatureChoice {
  const FeatureChoice({
    required this.id,
    required this.prompt,
    required this.options,
    this.isRequired = true,
  });

  /// Identificador estável da escolha.
  final String id;

  /// Pergunta que a ficha mostra.
  final String prompt;

  final List<FeatureChoiceOption> options;

  /// Se a evolução fica bloqueada enquanto a escolha não for feita.
  final bool isRequired;

  FeatureChoiceOption? optionById(String? id) {
    if (id == null) return null;
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  /// Lê o bloco `choice` do asset.
  ///
  /// Escolha sem pelo menos duas opções é descartada: uma opção só não é
  /// escolha, é dado mal preenchido, e mostrá-la como pendência travaria a
  /// evolução do personagem sem motivo.
  static FeatureChoice? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final id = raw['id']?.toString().trim();
    final prompt = raw['prompt']?.toString().trim();
    if (id == null || id.isEmpty || prompt == null || prompt.isEmpty) {
      return null;
    }

    final options = <FeatureChoiceOption>[];
    final rawOptions = raw['options'];
    if (rawOptions is List) {
      for (final item in rawOptions) {
        final option = FeatureChoiceOption.tryParse(item);
        if (option != null) options.add(option);
      }
    }

    if (options.length < 2) return null;

    return FeatureChoice(
      id: id,
      prompt: prompt,
      options: List<FeatureChoiceOption>.unmodifiable(options),
      isRequired: raw['required'] != false,
    );
  }
}
