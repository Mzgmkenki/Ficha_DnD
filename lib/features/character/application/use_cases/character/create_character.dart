import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiency_grant.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

class CreateCharacter {
  CreateCharacter(this._repository);

  final CharacterRepository _repository;

  Future<void> call(Character character) async {
    final allocation = character.abilityScoreAllocation;
    if (allocation == null) {
      throw ArgumentError(
        'A criação exige a distribuição completa do conjunto padrão.',
      );
    }

    final otherBonuses = character.otherPermanentAbilityBonuses;
    allocation.validate(otherBonuses: otherBonuses);
    final expectedTotals = allocation.totals(otherBonuses: otherBonuses);
    for (final ability in Ability.values) {
      if (expectedTotals.valueFor(ability) !=
          character.abilityScores.valueFor(ability)) {
        throw ArgumentError(
          'O total de ${ability.label} não corresponde à base e aos bônus.',
        );
      }
    }

    final skills = CreationSkillSelection(character.skillProficiencyGrants);
    skills.validate();
    for (final grant in character.skillProficiencyGrants) {
      if (!character.skillProficiencies.isProficient(grant.skill)) {
        throw ArgumentError(
          '${grant.skill.label} tem uma origem registrada, mas não está '
          'proficiente na ficha.',
        );
      }
    }
    for (final entry in character.skillProficiencies.activeLevels.entries) {
      if (!entry.value.isProficientOrBetter) continue;
      if (skills.grantsFor(entry.key).isEmpty) {
        throw ArgumentError(
          '${entry.key.label} está proficiente, mas não tem uma origem '
          'registrada na criação.',
        );
      }
    }

    await _repository.create(character);
  }
}
