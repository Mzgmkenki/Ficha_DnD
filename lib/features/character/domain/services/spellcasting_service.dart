import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Números de conjuração de 5e.
///
/// Estático como os outros serviços de domínio. Antes era instanciável e não
/// tinha nenhum chamador: a UI reimplementava as duas contas.
class SpellcastingService {
  const SpellcastingService._();

  /// CD de resistência: 8 + bônus de proficiência + modificador do atributo.
  static int spellSaveDc({
    required int proficiencyBonus,
    required Ability castingAbility,
    required AbilityScores scores,
  }) {
    return 8 + proficiencyBonus + _modifier(castingAbility, scores);
  }

  /// Bônus de ataque com magia: proficiência + modificador do atributo.
  static int spellAttackBonus({
    required int proficiencyBonus,
    required Ability castingAbility,
    required AbilityScores scores,
  }) {
    return proficiencyBonus + _modifier(castingAbility, scores);
  }

  static int _modifier(Ability ability, AbilityScores scores) {
    return scores.valueFor(ability).abilityModifier;
  }
}
