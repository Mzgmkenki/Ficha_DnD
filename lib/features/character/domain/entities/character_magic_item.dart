import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart';

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
    this.weaponAttackBonus = 0,
    this.weaponDamageBonus = 0,
    this.spellAttackBonus = 0,
    this.spellSaveDcBonus = 0,
  });

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
  /// conjurador existe [spellSaveDcBonus].
  final int? saveDc;

  /// Bônus de ataque fixo do item. Absoluto, como [saveDc].
  final int? attackBonus;

  /// Soma nas jogadas de ataque com arma.
  ///
  /// Este e os três seguintes são bônus, não valores absolutos: dizem quanto o
  /// item acrescenta ao que o personagem já tem. Cada efeito tem campo próprio
  /// de propósito — uma arma `+1` afeta ataque e dano dela, e só afeta ataque
  /// mágico ou CD se a descrição do item disser isso. Com um único campo
  /// "bônus" não haveria como distinguir os dois casos, e um Escudo +1 acabaria
  /// aumentando a CD das magias.
  final int weaponAttackBonus;

  /// Soma nas jogadas de dano com arma.
  final int weaponDamageBonus;

  /// Soma no bônus de ataque com magia.
  final int spellAttackBonus;

  /// Soma na CD de resistência das magias do personagem.
  final int spellSaveDcBonus;

  final List<CharacterMagicItemSpell> spells;

  /// Se o item declara algum bônus estruturado.
  bool get hasBonuses =>
      weaponAttackBonus != 0 ||
      weaponDamageBonus != 0 ||
      spellAttackBonus != 0 ||
      spellSaveDcBonus != 0;

  /// Se o item afeta a conjuração do personagem.
  bool get affectsSpellcasting => spellAttackBonus != 0 || spellSaveDcBonus != 0;

  /// Se o item afeta ataque com arma.
  bool get affectsWeapons => weaponAttackBonus != 0 || weaponDamageBonus != 0;

  CharacterMagicItem copyWith({
    int? localId,
    String? name,
    String? description,
    List<CharacterMagicItemSpell>? spells,
    int? charges,
    int? maxCharges,
    String? rechargeRule,
    String? castingAbility,
    int? saveDc,
    int? attackBonus,
    int? weaponAttackBonus,
    int? weaponDamageBonus,
    int? spellAttackBonus,
    int? spellSaveDcBonus,
  }) {
    return CharacterMagicItem(
      localId: localId ?? this.localId,
      name: name ?? this.name,
      description: description ?? this.description,
      spells: spells ?? this.spells,
      charges: charges ?? this.charges,
      maxCharges: maxCharges ?? this.maxCharges,
      rechargeRule: rechargeRule ?? this.rechargeRule,
      castingAbility: castingAbility ?? this.castingAbility,
      saveDc: saveDc ?? this.saveDc,
      attackBonus: attackBonus ?? this.attackBonus,
      weaponAttackBonus: weaponAttackBonus ?? this.weaponAttackBonus,
      weaponDamageBonus: weaponDamageBonus ?? this.weaponDamageBonus,
      spellAttackBonus: spellAttackBonus ?? this.spellAttackBonus,
      spellSaveDcBonus: spellSaveDcBonus ?? this.spellSaveDcBonus,
    );
  }
}
