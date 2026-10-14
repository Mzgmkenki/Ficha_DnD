import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';

/// Categorias de armadura de 5e, que determinam como a Destreza entra na CA.
enum ArmorCategory {
  none('Sem armadura'),
  light('Leve'),
  medium('Média'),
  heavy('Pesada');

  const ArmorCategory(this.label);
  final String label;

  /// Teto que a categoria impõe ao bônus de Destreza.
  ///
  /// `null` é "sem teto" (armadura leve e sem armadura) e zero é "não entra"
  /// (pesada). É teto, não piso: Destreza negativa penaliza em qualquer
  /// categoria, menos na pesada, onde a Destreza simplesmente não participa.
  ///
  /// Exposto como dado porque a tela de CA precisa EXIBIR o limite, e com a
  /// regra só dentro do cálculo a tela teria que repeti-la — duas verdades
  /// para a mesma coisa.
  int? get maxDexBonus {
    switch (this) {
      case ArmorCategory.none:
      case ArmorCategory.light:
        return null;
      case ArmorCategory.medium:
        return 2;
      case ArmorCategory.heavy:
        return 0;
    }
  }

  /// O limite em texto, como a ficha mostra.
  String get dexLimitLabel {
    switch (this) {
      case ArmorCategory.none:
      case ArmorCategory.light:
        return 'Destreza sem limite';
      case ArmorCategory.medium:
        return 'Destreza limitada a +2';
      case ArmorCategory.heavy:
        return 'Destreza não se aplica';
    }
  }
}

/// Uma armadura do compêndio básico.
///
/// O requisito de Força e a desvantagem em Furtividade são dados da armadura,
/// não regra deduzida do nome: a comparação é sempre por [id] e pelos campos
/// abaixo. Renomear "Brunea" para "Brunea do vovô" não pode mudar penalidade
/// nenhuma.
class ArmorOption {
  const ArmorOption({
    required this.id,
    required this.name,
    required this.category,
    required this.baseArmorClass,
    this.strengthRequirement,
    this.stealthDisadvantage = false,
  });

  final String id;
  final String name;
  final ArmorCategory category;
  final int baseArmorClass;

  /// Força mínima exigida pela armadura, ou `null` quando ela não exige nada.
  ///
  /// Anulável em vez de zero porque "não exige" e "exige 0" são afirmações
  /// diferentes, e zero obrigava todo consumidor a conhecer a convenção. As
  /// três armaduras com requisito no PHB 2014 são cota de malha (13), talas
  /// (15) e placas (15).
  final int? strengthRequirement;

  /// `true` quando a armadura impõe desvantagem em testes de Destreza
  /// (Furtividade).
  ///
  /// A penalidade é da armadura e vale mesmo para quem tem proficiência com
  /// ela: proficiência evita a penalidade de conjuração, não esta.
  final bool stealthDisadvantage;

  /// `true` quando há um requisito de Força a conferir.
  bool get requiresStrength => (strengthRequirement ?? 0) > 0;

  /// O perfil desta armadura sem exceção nenhuma.
  ArmorProfile get profile => ArmorProfile(option: this);

  /// Armaduras do PHB. Mantido em código porque é uma tabela pequena e
  /// estável, e evita mais um asset para carregar.
  static const List<ArmorOption> all = [
    ArmorOption(
      id: 'none',
      name: 'Sem armadura',
      category: ArmorCategory.none,
      baseArmorClass: 10,
    ),
    // Leves
    ArmorOption(
      id: 'padded',
      name: 'Acolchoada',
      category: ArmorCategory.light,
      baseArmorClass: 11,
      stealthDisadvantage: true,
    ),
    ArmorOption(
      id: 'leather',
      name: 'Couro',
      category: ArmorCategory.light,
      baseArmorClass: 11,
    ),
    ArmorOption(
      id: 'studded_leather',
      name: 'Couro batido',
      category: ArmorCategory.light,
      baseArmorClass: 12,
    ),
    // Médias
    ArmorOption(
      id: 'hide',
      name: 'Peles',
      category: ArmorCategory.medium,
      baseArmorClass: 12,
    ),
    ArmorOption(
      id: 'chain_shirt',
      name: 'Camisão de malha',
      category: ArmorCategory.medium,
      baseArmorClass: 13,
    ),
    ArmorOption(
      id: 'scale_mail',
      name: 'Brunea',
      category: ArmorCategory.medium,
      baseArmorClass: 14,
      stealthDisadvantage: true,
    ),
    ArmorOption(
      id: 'breastplate',
      name: 'Peitoral',
      category: ArmorCategory.medium,
      baseArmorClass: 14,
    ),
    ArmorOption(
      id: 'half_plate',
      name: 'Meia armadura',
      category: ArmorCategory.medium,
      baseArmorClass: 15,
      stealthDisadvantage: true,
    ),
    // Pesadas
    ArmorOption(
      id: 'ring_mail',
      name: 'Cota de anéis',
      category: ArmorCategory.heavy,
      baseArmorClass: 14,
      stealthDisadvantage: true,
    ),
    ArmorOption(
      id: 'chain_mail',
      name: 'Cota de malha',
      category: ArmorCategory.heavy,
      baseArmorClass: 16,
      strengthRequirement: 13,
      stealthDisadvantage: true,
    ),
    ArmorOption(
      id: 'splint',
      name: 'Talas',
      category: ArmorCategory.heavy,
      baseArmorClass: 17,
      strengthRequirement: 15,
      stealthDisadvantage: true,
    ),
    ArmorOption(
      id: 'plate',
      name: 'Placas',
      category: ArmorCategory.heavy,
      baseArmorClass: 18,
      strengthRequirement: 15,
      stealthDisadvantage: true,
    ),
  ];

  static ArmorOption? fromId(String? id) {
    if (id == null) return null;
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}

/// Uma armadura concreta, com as exceções daquela peça já resolvidas.
///
/// Existe para a armadura mágica e a peça especial poderem divergir da tabela
/// SEM alterar a tabela: umas Placas Adamantinas que não exijam Força, ou uma
/// Brunea Élfica sem desvantagem em Furtividade, são overrides desta peça, e a
/// armadura básica continua valendo para todas as outras fichas.
///
/// A resolução mora aqui, e não espalhada em cada tela, para a lista de
/// seleção, o cálculo da CA e o aviso na ficha responderem sempre a mesma
/// coisa.
class ArmorProfile {
  const ArmorProfile({
    required this.option,
    this.strengthRequirementOverride,
    this.stealthDisadvantageOverride,
    this.magicBonus = 0,
  });

  final ArmorOption option;

  /// Requisito próprio desta peça. `null` usa o da armadura básica.
  ///
  /// Zero é significativo: é como uma peça mágica declara "não exige Força".
  final int? strengthRequirementOverride;

  /// Penalidade própria desta peça. `null` usa a da armadura básica.
  final bool? stealthDisadvantageOverride;

  /// O `+1`, `+2` ou `+3` da armadura mágica, somado à CA base.
  final int magicBonus;

  String get id => option.id;
  String get name => option.name;
  ArmorCategory get category => option.category;

  /// CA base já com o bônus mágico da peça.
  int get baseArmorClass => option.baseArmorClass + magicBonus;

  int? get strengthRequirement =>
      strengthRequirementOverride ?? option.strengthRequirement;

  bool get stealthDisadvantage =>
      stealthDisadvantageOverride ?? option.stealthDisadvantage;

  bool get requiresStrength => (strengthRequirement ?? 0) > 0;

  bool get isMagical => magicBonus != 0;

  /// `true` quando o personagem cumpre o requisito de Força.
  ///
  /// Sem requisito, cumpre sempre.
  bool meetsStrengthRequirement(AbilityScores abilityScores) {
    final required = strengthRequirement ?? 0;
    if (required <= 0) return true;
    return abilityScores.strength >= required;
  }

  /// Explicação de por que a armadura não pode ser usada, ou `null` quando
  /// pode.
  ///
  /// O texto é montado aqui para a lista de seleção, o diálogo de bloqueio e o
  /// aviso de desequipar automático dizerem exatamente a mesma frase.
  String? blockReason(AbilityScores abilityScores) {
    if (meetsStrengthRequirement(abilityScores)) return null;
    return 'Requer Força $strengthRequirement. '
        'Força atual: ${abilityScores.strength}.';
  }

  ArmorProfile copyWith({
    ArmorOption? option,
    int? strengthRequirementOverride,
    bool? stealthDisadvantageOverride,
    int? magicBonus,
  }) {
    return ArmorProfile(
      option: option ?? this.option,
      strengthRequirementOverride:
          strengthRequirementOverride ?? this.strengthRequirementOverride,
      stealthDisadvantageOverride:
          stealthDisadvantageOverride ?? this.stealthDisadvantageOverride,
      magicBonus: magicBonus ?? this.magicBonus,
    );
  }

  @override
  String toString() =>
      'ArmorProfile($id, FOR $strengthRequirement, '
      'furtividade ${stealthDisadvantage ? 'desvantagem' : 'ok'})';
}

/// Resultado do cálculo, com a explicação de como chegou no número.
class ArmorClassResult {
  const ArmorClassResult({
    required this.total,
    required this.explanation,
    this.stealthDisadvantage = false,
  });

  final int total;
  final String explanation;
  final bool stealthDisadvantage;
}

/// Calcula a CA a partir da armadura, escudo e bônus diversos.
class ArmorClassCalculator {
  const ArmorClassCalculator._();

  /// Calcula a CA.
  ///
  /// [armorMagicBonus] é o `+1`/`+2`/`+3` da peça mágica e entra somando na CA
  /// base. [stealthDisadvantage] permite a peça sobrescrever a penalidade da
  /// armadura básica; nulo usa a da tabela.
  static ArmorClassResult calculate({
    required ArmorOption armor,
    required AbilityScores abilityScores,
    bool hasShield = false,
    int otherBonus = 0,
    int armorMagicBonus = 0,
    bool? stealthDisadvantage,
  }) {
    final dexModifier = abilityScores.dexterity.abilityModifier;

    // A Destreza entra inteira em armadura leve/nenhuma, limitada a +2 em
    // média e não entra em pesada. O teto vem de `ArmorCategory.maxDexBonus`
    // para a tela poder exibir o mesmo limite que o cálculo aplica.
    final limit = armor.category.maxDexBonus;
    final int appliedDex;
    if (limit == null) {
      appliedDex = dexModifier;
    } else if (limit == 0) {
      // Pesada: a Destreza NÃO participa, e isso não é o mesmo que um teto de
      // zero — Destreza ruim também não penaliza quem está de placas.
      appliedDex = 0;
    } else {
      appliedDex = dexModifier > limit ? limit : dexModifier;
    }

    final String dexNote;
    switch (armor.category) {
      case ArmorCategory.none:
      case ArmorCategory.light:
        dexNote = 'DES ${_signed(dexModifier)}';
        break;
      case ArmorCategory.medium:
        dexNote = 'DES ${_signed(appliedDex)} (limite +2)';
        break;
      case ArmorCategory.heavy:
        dexNote = 'DES não se aplica';
        break;
    }

    final shieldBonus = hasShield ? 2 : 0;
    final armorBase = armor.baseArmorClass + armorMagicBonus;
    final total = armorBase + appliedDex + shieldBonus + otherBonus;

    final parts = <String>[
      // O bônus mágico aparece no nome, e não como parcela solta: o jogador
      // confere "Cota de malha +1 17", que é como o item se chama na mesa.
      armorMagicBonus != 0
          ? '${armor.name} ${_signed(armorMagicBonus)} $armorBase'
          : '${armor.name} $armorBase',
      dexNote,
      if (hasShield) 'escudo +2',
      if (otherBonus != 0) 'outros ${_signed(otherBonus)}',
    ];

    return ArmorClassResult(
      total: total,
      explanation: parts.join(' • '),
      stealthDisadvantage: stealthDisadvantage ?? armor.stealthDisadvantage,
    );
  }

  /// Indica se o personagem não cumpre o requisito de Força da armadura.
  ///
  /// Pela regra oficial de 2014 isso reduziria o deslocamento em 3 m; no
  /// DragonSheet a decisão de produto é mais restritiva e o requisito impede
  /// equipar (ver `OwnedArmor`). Esta função responde só a comparação.
  ///
  /// [strengthRequirement] sobrescreve o da tabela, para a peça mágica que
  /// dispensa o requisito.
  static bool failsStrengthRequirement({
    required ArmorOption armor,
    required AbilityScores abilityScores,
    int? strengthRequirement,
  }) {
    final required = strengthRequirement ?? armor.strengthRequirement ?? 0;
    if (required <= 0) return false;
    return abilityScores.strength < required;
  }

  static String _signed(int value) => value >= 0 ? '+$value' : '$value';
}
