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
  /// A exaustão não entra na conta. Antes descontava 5 aqui, tratando o nível 1
  /// como desvantagem permanente em testes de atributo; a regra de exaustão em
  /// uso não impõe essa penalidade aos valores passivos. Os efeitos da exaustão
  /// ficam descritos na seção Condições da ficha, sem mexer nos números.
  static int passiveScore(Character character, Skill skill) {
    return 10 + skillBonus(character, skill);
  }

  static int passivePerception(Character character) =>
      passiveScore(character, Skill.perception);

  static int passiveInvestigation(Character character) =>
      passiveScore(character, Skill.investigation);

  static int passiveInsight(Character character) =>
      passiveScore(character, Skill.insight);
}
