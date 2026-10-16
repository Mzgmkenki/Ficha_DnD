import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';

/// O estado do equipamento contra o qual as condições de efeito são medidas.
///
/// Existe para a condição declarada no compêndio ser conferida num lugar só.
/// Antes desta classe, `ac.bonus` era somado sem olhar condição nenhuma — o que
/// funcionava enquanto nenhum efeito tinha condição, e passaria a dar +1 de CA
/// a um personagem desarmado no instante em que o estilo Defesa entrasse.
///
/// Não decide nada sobre regra: só responde o que está vestido e empunhado.
/// Quem decide se o efeito vale é [allows].
class FeatureConditionState {
  const FeatureConditionState({
    this.wearsArmor = false,
    this.wearsHeavyArmor = false,
    this.hasShield = false,
  });

  /// Estado neutro: nada vestido, nada empunhado.
  ///
  /// É o padrão de quem chama sem informar equipamento, e o efeito condicional
  /// simplesmente não vale — o que é melhor que valer por omissão.
  static const FeatureConditionState none = FeatureConditionState();

  final bool wearsArmor;
  final bool wearsHeavyArmor;
  final bool hasShield;

  /// Lê o inventário.
  ///
  /// [abilityScores] entra porque `OwnedArmor` desconsidera armadura cuja
  /// exigência de Força o personagem não cumpre: para a regra, ele não está
  /// usando aquilo, e portanto o bônus condicionado a armadura também não vale.
  static FeatureConditionState from({
    required List<InventoryItem> inventory,
    AbilityScores? abilityScores,
  }) {
    final equipped = OwnedArmor.equippedWearable(
      inventory,
      abilityScores: abilityScores,
    );

    return FeatureConditionState(
      wearsArmor: equipped != null,
      wearsHeavyArmor: equipped?.armor?.category == ArmorCategory.heavy,
      hasShield: OwnedArmor.hasEquippedShield(inventory),
    );
  }

  /// Se as condições de armadura e de escudo estão cumpridas agora.
  ///
  /// NÃO confere a condição de arma: aquela depende de QUAL arma está sendo
  /// usada no ataque, e portanto é respondida por [allowsWeapon], arma por
  /// arma. Misturar as duas aqui faria um bônus de arma à distância valer na
  /// CA.
  bool allows(FeatureEffectConditions conditions) {
    switch (conditions.armor) {
      case FeatureArmorCondition.any:
        break;
      case FeatureArmorCondition.none:
        if (wearsArmor) return false;
      case FeatureArmorCondition.notHeavy:
        if (wearsHeavyArmor) return false;
      case FeatureArmorCondition.armored:
        if (!wearsArmor) return false;
    }

    if (conditions.shield == FeatureShieldCondition.forbidden && hasShield) {
      return false;
    }

    return true;
  }

  /// Se a condição de arma do efeito é cumprida por esta arma.
  ///
  /// [weapon] é o registro da ficha, de onde sai a marcação de duas mãos que o
  /// jogador fez; [entry] é a arma do compêndio, de onde saem as propriedades.
  static bool allowsWeapon(
    FeatureEffectConditions conditions, {
    required CharacterWeapon weapon,
    required WeaponEntry entry,
  }) {
    return switch (conditions.weapon) {
      FeatureWeaponCondition.any => true,
      FeatureWeaponCondition.melee => entry.isMelee,
      // Versátil empunhada com as duas mãos deixa de ser "em uma mão", e é
      // por isso que a marcação da ficha importa aqui.
      FeatureWeaponCondition.meleeOneHanded =>
        entry.isMelee && !entry.isTwoHanded && !weapon.twoHanded,
      FeatureWeaponCondition.ranged => entry.isRanged,
      FeatureWeaponCondition.thrown => entry.isThrown,
    };
  }
}
