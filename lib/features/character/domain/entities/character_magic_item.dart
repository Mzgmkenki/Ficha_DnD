import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/magic_item_bonus.dart';

/// Marcador para o [CharacterMagicItem.copyWith] distinguir "não informado" de
/// "informado como null".
///
/// Sem ele não havia como limpar os campos anuláveis: o `x ?? this.x` antigo
/// tratava null como omissão, então tirar as cargas de um item era impossível.
const Object _sentinel = Object();

/// Um item mágico do personagem.
///
/// O bônus é declarado num degrau fechado ([bonus]) mais a lista de
/// estatísticas afetadas ([bonusTargets]). Isso é o que impede um `+1` genérico
/// de vazar para tudo: uma arma `+1` marca ataque e dano com arma, um foco
/// mágico marca ataque mágico e CD, e nenhum dos dois afeta o do outro.
///
/// O bônus só vale quando o item está de fato em uso — ver [isActive].
class CharacterMagicItem {
  const CharacterMagicItem({
    required this.localId,
    required this.name,
    required this.description,
    required this.spells,
    this.charges,
    this.maxCharges,
    this.rechargeRule,
    this.castingAbility,
    this.saveDc,
    this.attackBonus,
    this.bonus = MagicItemBonus.none,
    this.bonusTargets = const {},
    this.isEquipped = true,
    this.requiresAttunement = false,
    this.isAttuned = false,
    this.legacyBonuses,
  });

  /// Item vindo do formato antigo, com os quatro bônus em campo livre.
  ///
  /// Converte o que é representável e guarda o resto para revisão, sem perder
  /// efeito. É por aqui que o repositório e o importador de JSON leem uma ficha
  /// gravada antes do bônus controlado.
  factory CharacterMagicItem.fromLegacyBonuses({
    required int localId,
    required String name,
    required String description,
    required List<CharacterMagicItemSpell> spells,
    int? charges,
    int? maxCharges,
    String? rechargeRule,
    String? castingAbility,
    int? saveDc,
    int? attackBonus,
    int weaponAttackBonus = 0,
    int weaponDamageBonus = 0,
    int spellAttackBonus = 0,
    int spellSaveDcBonus = 0,
    bool isEquipped = true,
    bool requiresAttunement = false,
    bool isAttuned = false,
  }) {
    final conversion = convertLegacyMagicItemBonuses(
      weaponAttack: weaponAttackBonus,
      weaponDamage: weaponDamageBonus,
      spellAttack: spellAttackBonus,
      spellSaveDc: spellSaveDcBonus,
    );

    return CharacterMagicItem(
      localId: localId,
      name: name,
      description: description,
      spells: spells,
      charges: charges,
      maxCharges: maxCharges,
      rechargeRule: rechargeRule,
      castingAbility: castingAbility,
      saveDc: saveDc,
      attackBonus: attackBonus,
      bonus: conversion.bonus,
      bonusTargets: conversion.targets,
      legacyBonuses: conversion.legacy,
      isEquipped: isEquipped,
      requiresAttunement: requiresAttunement,
      isAttuned: isAttuned,
    );
  }

  final int localId;
  final String name;
  final String description;
  final int? charges;
  final int? maxCharges;
  final String? rechargeRule;
  final String? castingAbility;

  /// CD fixa do item, quando ele define a própria.
  ///
  /// Valor ABSOLUTO: é o "CD 15" impresso na descrição de varinhas e cajados,
  /// que não depende dos atributos de quem usa. Para o item que SOMA à CD do
  /// conjurador existe [bonus] com [MagicItemBonusTarget.spellSaveDc].
  final int? saveDc;

  /// Bônus de ataque fixo do item. Absoluto, como [saveDc].
  final int? attackBonus;

  /// O degrau de bônus que o item concede: nenhum, `+1`, `+2` ou `+3`.
  final MagicItemBonus bonus;

  /// Em que estatísticas o [bonus] entra.
  ///
  /// Vazio com [bonus] preenchido significa item que declara um `+1` sem dizer
  /// onde ele vale — nesse caso nada é somado, porque somar em tudo é
  /// justamente o erro que este par de campos existe para evitar.
  final Set<MagicItemBonusTarget> bonusTargets;

  /// Se o item está equipado ou em uso.
  ///
  /// Item guardado na mochila não soma nada. O padrão é `true` para a ficha que
  /// já existia não mudar de número ao migrar.
  final bool isEquipped;

  /// Se a descrição do item exige sintonia.
  final bool requiresAttunement;

  /// Se o personagem está sintonizado com o item.
  ///
  /// Só importa quando [requiresAttunement] é `true`: item que exige sintonia e
  /// não está sintonizado não concede nada além do que qualquer item mundano
  /// daria.
  final bool isAttuned;

  /// Os valores livres antigos, quando não couberam no formato controlado.
  ///
  /// Não-nulo é o sinal de "revise este item": o número original continua
  /// valendo, e a ficha mostra o aviso em vez de arredondar ou descartar.
  final LegacyMagicItemBonuses? legacyBonuses;

  final List<CharacterMagicItemSpell> spells;

  /// Se os bônus deste item precisam de revisão do jogador.
  bool get needsBonusReview => legacyBonuses != null;

  /// Se o item está em condição de conceder o que declara.
  ///
  /// Equipado, e sintonizado quando a descrição exige. É o único portão dos
  /// bônus: sem isso um item na mochila continuaria somando na ficha.
  bool get isActive => isEquipped && (!requiresAttunement || isAttuned);

  /// Quanto o item DECLARA para a estatística, esteja em uso ou não.
  ///
  /// Serve para a ficha mostrar o que o item concede mesmo com ele guardado ou
  /// sem sintonia, sem dar a entender que o bônus está valendo.
  int declaredBonusFor(MagicItemBonusTarget target) {
    final legacy = legacyBonuses;
    if (legacy != null) return legacy.valueFor(target);

    return bonusTargets.contains(target) ? bonus.value : 0;
  }

  /// Quanto o item SOMA de fato para a estatística.
  ///
  /// Zero quando o item não está em uso. É o que os cálculos consomem.
  int effectiveBonusFor(MagicItemBonusTarget target) {
    return isActive ? declaredBonusFor(target) : 0;
  }

  /// Estatísticas que o item declara afetar.
  Set<MagicItemBonusTarget> get declaredTargets {
    return {
      for (final target in MagicItemBonusTarget.values)
        if (declaredBonusFor(target) != 0) target,
    };
  }

  /// Soma nas jogadas de ataque com arma, já considerando uso e sintonia.
  int get weaponAttackBonus =>
      effectiveBonusFor(MagicItemBonusTarget.weaponAttack);

  /// Soma nas jogadas de dano com arma.
  int get weaponDamageBonus =>
      effectiveBonusFor(MagicItemBonusTarget.weaponDamage);

  /// Soma no bônus de ataque com magia.
  int get spellAttackBonus =>
      effectiveBonusFor(MagicItemBonusTarget.spellAttack);

  /// Soma na CD de resistência das magias do personagem.
  int get spellSaveDcBonus =>
      effectiveBonusFor(MagicItemBonusTarget.spellSaveDc);

  /// Se o item declara algum bônus, mesmo que ele não esteja valendo agora.
  bool get declaresBonuses => declaredTargets.isNotEmpty;

  /// Se o item está somando algo neste momento.
  bool get hasBonuses =>
      weaponAttackBonus != 0 ||
      weaponDamageBonus != 0 ||
      spellAttackBonus != 0 ||
      spellSaveDcBonus != 0;

  /// Se o item está afetando a conjuração do personagem.
  bool get affectsSpellcasting => spellAttackBonus != 0 || spellSaveDcBonus != 0;

  /// Se o item está afetando ataque com arma.
  bool get affectsWeapons => weaponAttackBonus != 0 || weaponDamageBonus != 0;

  /// `+1 no ataque com arma, +1 no dano com arma`, para ficha e PDF.
  ///
  /// Descreve o que o item DECLARA. Quem quer saber se está valendo olha
  /// [isActive], que a ficha mostra ao lado como etiqueta.
  String describeDeclaredBonuses() {
    final legacy = legacyBonuses;
    if (legacy != null) return legacy.describe();

    if (bonus.isNone || bonusTargets.isEmpty) return '';

    final parts = <String>[
      for (final target in MagicItemBonusTarget.values)
        if (bonusTargets.contains(target)) '${bonus.label} ${target.phrase}',
    ];

    return parts.join(', ');
  }

  CharacterMagicItem copyWith({
    int? localId,
    String? name,
    String? description,
    List<CharacterMagicItemSpell>? spells,
    Object? charges = _sentinel,
    Object? maxCharges = _sentinel,
    Object? rechargeRule = _sentinel,
    Object? castingAbility = _sentinel,
    Object? saveDc = _sentinel,
    Object? attackBonus = _sentinel,
    MagicItemBonus? bonus,
    Set<MagicItemBonusTarget>? bonusTargets,
    bool? isEquipped,
    bool? requiresAttunement,
    bool? isAttuned,
    Object? legacyBonuses = _sentinel,
  }) {
    return CharacterMagicItem(
      localId: localId ?? this.localId,
      name: name ?? this.name,
      description: description ?? this.description,
      spells: spells ?? this.spells,
      // Sentinela nos anuláveis: zerar as cargas de um item é passar null, e
      // com `?? this.charges` isso era impossível.
      charges: charges == _sentinel ? this.charges : charges as int?,
      maxCharges:
          maxCharges == _sentinel ? this.maxCharges : maxCharges as int?,
      rechargeRule: rechargeRule == _sentinel
          ? this.rechargeRule
          : rechargeRule as String?,
      castingAbility: castingAbility == _sentinel
          ? this.castingAbility
          : castingAbility as String?,
      saveDc: saveDc == _sentinel ? this.saveDc : saveDc as int?,
      attackBonus:
          attackBonus == _sentinel ? this.attackBonus : attackBonus as int?,
      bonus: bonus ?? this.bonus,
      bonusTargets: bonusTargets ?? this.bonusTargets,
      isEquipped: isEquipped ?? this.isEquipped,
      requiresAttunement: requiresAttunement ?? this.requiresAttunement,
      isAttuned: isAttuned ?? this.isAttuned,
      // Também sentinela: revisar o item é justamente limpar os valores
      // legados, e isso precisa ser possível.
      legacyBonuses: legacyBonuses == _sentinel
          ? this.legacyBonuses
          : legacyBonuses as LegacyMagicItemBonuses?,
    );
  }
}
