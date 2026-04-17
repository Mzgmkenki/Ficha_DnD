import 'package:dnd_ficha_app/core/utils/dnd_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

class SpellcastingService {
  const SpellcastingService();

  int spellSaveDc({
    required int proficiencyBonus,
    required Ability castingAbility,
    required AbilityScores scores,
  }) {
    return 8 + proficiencyBonus + DndCalculator.modifierForAbility(castingAbility, scores);
  }

  int spellAttackBonus({
    required int proficiencyBonus,
    required Ability castingAbility,
    required AbilityScores scores,
  }) {
    return proficiencyBonus + DndCalculator.modifierForAbility(castingAbility, scores);
  }
}
