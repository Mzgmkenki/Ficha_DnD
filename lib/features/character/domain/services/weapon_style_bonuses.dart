import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_condition_state.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/weapon_attack_calculator.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';

/// Os bônus de ataque e de dano que uma arma recebe das características e das
/// mecânicas do personagem.
///
/// Existe por causa dos Estilos de Combate, que são quase todos condicionais à
/// arma: a Arquearia dá +2 no ataque mas só à distância, o Duelo dá +2 no dano
/// mas só com arma corpo a corpo em uma mão, e o Combate com Armas de Arremesso
/// dá +2 no dano mas só com arma de arremesso.
///
/// Por que fica aqui e não no cálculo de ataque: o cálculo não conhece
/// característica nem mecânica, e não deve conhecer. Ele recebe parcelas
/// prontas, do mesmo jeito que já recebe o bônus de item mágico. E por que não
/// fica na tela: a decisão é de regra, e a tela de armas, o painel de combate e
/// o PDF precisam chegar ao mesmo número.
class WeaponStyleBonuses {
  const WeaponStyleBonuses._();

  /// Filtra [effects] pela arma e devolve as parcelas de ataque e de dano.
  ///
  /// [effects] vem de `ResolvedFeatures.weaponBonusEffects` e de
  /// `ResolvedClassMechanics.weaponBonusEffects`, que já aplicaram o que
  /// depende do equipamento vestido e, no caso das mecânicas, já descartaram
  /// opção não escolhida, opção inválida e modo desligado.
  ///
  /// Deduplica por id de efeito: a mesma declaração não pode contar duas vezes
  /// se aparecer nas duas listas.
  static ({List<WeaponModifier> attack, List<WeaponModifier> damage}) resolve({
    required List<FeatureEffect> effects,
    required CharacterWeapon weapon,
    required WeaponEntry entry,
    required FeatureFormulaContext context,
  }) {
    final attack = <WeaponModifier>[];
    final damage = <WeaponModifier>[];
    final seen = <String>{};

    for (final effect in effects) {
      if (!seen.add(effect.id)) continue;

      if (!FeatureConditionState.allowsWeapon(
        effect.conditions,
        weapon: weapon,
        entry: entry,
      )) {
        continue;
      }

      final value = FeatureFormula.valueOf(effect.formula, context);
      if (value == null || value == 0) continue;

      // O rótulo é o do efeito, para a composição do ataque dizer de onde o
      // número saiu: `+7 = +3 do atributo +2 de proficiência +2 da Arquearia`.
      final label = 'de ${effect.label ?? 'característica'}';
      final modifier = WeaponModifier(label: label, value: value);

      if (effect.path == FeatureEffectPaths.attackWeaponBonus) {
        attack.add(modifier);
      } else if (effect.path == FeatureEffectPaths.damageWeaponBonus) {
        damage.add(modifier);
      }
    }

    return (
      attack: List<WeaponModifier>.unmodifiable(attack),
      damage: List<WeaponModifier>.unmodifiable(damage),
    );
  }
}
