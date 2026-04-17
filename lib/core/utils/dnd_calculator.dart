import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

class DndCalculator {
  static int modifierForAbility(Ability ability, AbilityScores scores) {
    return scores.valueFor(ability).abilityModifier;
  }

  static int passiveScore({required int skillBonus}) => 10 + skillBonus;
}
