import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

/// Cálculos derivados de perícias e valores passivos.
class SkillCalculator {
  const SkillCalculator._();

  static int abilityModifier(Character character, Ability ability) {
    return character.abilityScores.valueFor(ability).abilityModifier;
  }

  /// Bônus total de uma perícia: modificador do atributo + bônus de
  /// proficiência conforme o nível (metade, cheio ou dobrado).
  static int skillBonus(Character character, Skill skill) {
    final level = character.skillProficiencies.levelFor(skill);
    return abilityModifier(character, skill.ability) +
        level.bonus(character.proficiencyBonus);
  }

  /// Valor passivo de uma perícia = 10 + bônus da perícia.
  ///
  /// A exaustão a partir do nível 1 dá desvantagem em testes de perícia, e
  /// desvantagem reduz valores passivos em 5 (PHB).
  static int passiveScore(Character character, Skill skill) {
    final base = 10 + skillBonus(character, skill);
    final hasDisadvantage = character.exhaustion >= 1;
    return hasDisadvantage ? base - 5 : base;
  }

  static int passivePerception(Character character) =>
      passiveScore(character, Skill.perception);

  static int passiveInvestigation(Character character) =>
      passiveScore(character, Skill.investigation);

  static int passiveInsight(Character character) =>
      passiveScore(character, Skill.insight);
}
