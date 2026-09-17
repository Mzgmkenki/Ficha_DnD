import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';

/// Uma parcela do ataque ou do dano, com de onde saiu.
class WeaponModifier {
  const WeaponModifier({required this.label, required this.value});

  /// Como a parcela aparece na composição. Ex.: `do atributo`.
  final String label;

  final int value;

  String get signed => value >= 0 ? '+$value' : '$value';

  /// `+3 do atributo`.
  String get description => '$signed $label';
}

/// O ataque de uma arma, já somado e explicado.
class WeaponAttack {
  const WeaponAttack({
    required this.weapon,
    required this.entry,
    required this.ability,
    required this.isProficient,
    required this.attackBonus,
    required this.attackParts,
    required this.damageBonus,
    required this.damageParts,
    required this.damageDice,
    required this.damageTypeLabel,
  });

  final CharacterWeapon weapon;
  final WeaponEntry entry;

  /// Atributo usado no ataque e no dano.
  final Ability ability;

  final bool isProficient;

  final int attackBonus;
  final List<WeaponModifier> attackParts;

  final int damageBonus;
  final List<WeaponModifier> damageParts;

  /// Dado de dano já considerando Versátil com as duas mãos.
  final String? damageDice;

  final String damageTypeLabel;

  /// Nome exibido: o apelido do jogador, ou o do compêndio.
  String get name {
    final custom = weapon.name?.trim();
    if (custom == null || custom.isEmpty) return entry.name;
    return custom;
  }

  String get formattedAttack => attackBonus >= 0 ? '+$attackBonus' : '$attackBonus';

  /// `+7 = +3 do atributo +3 de proficiência +1 da arma mágica`.
  String get attackExplanation {
    if (attackParts.isEmpty) return formattedAttack;

    final parts = attackParts.map((item) => item.description).join(' ');
    return '$formattedAttack = $parts';
  }

  /// `1d8 + 4 de dano cortante`, ou `1d8 - 1 de dano cortante`.
  ///
  /// Sem dado de dano (a Rede) devolve nulo: escrever "0 de dano" seria pior
  /// que não escrever nada.
  String? get damageExplanation {
    final dice = damageDice;
    if (dice == null) return null;

    if (damageBonus == 0) return '$dice de dano $damageTypeLabel';

    final sign = damageBonus > 0 ? '+' : '-';
    return '$dice $sign ${damageBonus.abs()} de dano $damageTypeLabel';
  }
}

/// Calcula ataque e dano de uma arma.
///
/// O atributo sai da ARMA, não da classe: corpo a corpo usa Força, à distância
/// usa Destreza, e Acuidade deixa escolher o melhor dos dois. Um ladino com
/// maça bate com Força, e um guerreiro com arco usa Destreza — é por isso que a
/// classe não decide isso aqui.
///
/// O que a classe decide é a proficiência, por
/// [ClassEntry.weaponProficiencies]. Raça, antecedente e talento também
/// concedem proficiência com arma, mas nenhum dos três está cadastrado de forma
/// estruturada no compêndio; para esses casos existe
/// [CharacterWeapon.proficiencyOverride], marcado à mão na ficha.
///
/// O bônus mágico da arma entra no ataque e no dano. Não entra em ataque de
/// magia nem em CD: aquilo é efeito de item mágico, e só quando a descrição do
/// item diz.
class WeaponAttackCalculator {
  const WeaponAttackCalculator._();

  static WeaponAttack calculate({
    required Character character,
    required CharacterWeapon weapon,
    required WeaponEntry entry,
    List<ClassEntry> classes = const [],
    int magicItemAttackBonus = 0,
    int magicItemDamageBonus = 0,
  }) {
    final ability = resolveAbility(
      character: character,
      weapon: weapon,
      entry: entry,
    );

    final proficient = isProficient(
      character: character,
      weapon: weapon,
      entry: entry,
      classes: classes,
    );

    final abilityModifier =
        character.abilityScores.valueFor(ability).abilityModifier;

    final attackParts = <WeaponModifier>[
      WeaponModifier(label: 'do atributo', value: abilityModifier),
      if (proficient)
        WeaponModifier(
          label: 'de proficiência',
          value: character.proficiencyBonus,
        ),
      if (weapon.magicBonus != 0)
        WeaponModifier(label: 'da arma mágica', value: weapon.magicBonus),
      if (magicItemAttackBonus != 0)
        WeaponModifier(label: 'de item mágico', value: magicItemAttackBonus),
    ];

    // O dano NÃO leva o bônus de proficiência: proficiência é acerto, não
    // força do golpe.
    final damageParts = <WeaponModifier>[
      WeaponModifier(label: 'do atributo', value: abilityModifier),
      if (weapon.magicBonus != 0)
        WeaponModifier(label: 'da arma mágica', value: weapon.magicBonus),
      if (magicItemDamageBonus != 0)
        WeaponModifier(label: 'de item mágico', value: magicItemDamageBonus),
    ];

    return WeaponAttack(
      weapon: weapon,
      entry: entry,
      ability: ability,
      isProficient: proficient,
      attackBonus: attackParts.fold(0, (sum, item) => sum + item.value),
      attackParts: List.unmodifiable(attackParts),
      damageBonus: damageParts.fold(0, (sum, item) => sum + item.value),
      damageParts: List.unmodifiable(damageParts),
      damageDice: damageDiceFor(weapon: weapon, entry: entry),
      damageTypeLabel: entry.damageType.label,
    );
  }

  /// Atributo do ataque, decidido pela arma.
  ///
  /// Sem Acuidade não há escolha: corpo a corpo é Força e à distância é
  /// Destreza. Com Acuidade vale o que o jogador escolheu, e sem escolha vale o
  /// melhor dos dois — que é o que qualquer jogador faria.
  static Ability resolveAbility({
    required Character character,
    required CharacterWeapon weapon,
    required WeaponEntry entry,
  }) {
    final required = entry.requiredAbility;
    if (required != null) return required;

    final chosen = weapon.chosenAbility;
    if (chosen != null && entry.allowedAbilities.contains(chosen)) {
      return chosen;
    }

    return _bestOf(character, entry.allowedAbilities);
  }

  static Ability _bestOf(Character character, List<Ability> options) {
    var best = options.first;
    var bestValue = character.abilityScores.valueFor(best);

    for (final option in options.skip(1)) {
      final value = character.abilityScores.valueFor(option);
      if (value > bestValue) {
        best = option;
        bestValue = value;
      }
    }

    return best;
  }

  /// Se o personagem tem proficiência com a arma.
  ///
  /// O override da ficha vence, porque existe justamente para cobrir o que o
  /// compêndio não sabe. Sem override, vale o que qualquer uma das classes do
  /// personagem concede — em multiclasse as proficiências se somam.
  static bool isProficient({
    required Character character,
    required CharacterWeapon weapon,
    required WeaponEntry entry,
    List<ClassEntry> classes = const [],
  }) {
    final override = weapon.proficiencyOverride;
    if (override != null) return override;

    for (final classLevel in character.classLevels) {
      for (final item in classes) {
        if (item.id != classLevel.classId) continue;
        if (item.weaponProficiencies.covers(entry)) return true;
      }
    }

    return false;
  }

  /// Dado de dano, já considerando Versátil com as duas mãos.
  static String? damageDiceFor({
    required CharacterWeapon weapon,
    required WeaponEntry entry,
  }) {
    if (!entry.dealsDamage) return null;

    if (weapon.twoHanded && entry.isVersatile) {
      return entry.versatileDamage ?? entry.damage;
    }

    return entry.damage;
  }
}
