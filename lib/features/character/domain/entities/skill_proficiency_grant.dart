import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_skills.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

enum SkillGrantSource {
  characterClass,
  raceAutomatic,
  raceChoice,
  backgroundAutomatic,
  backgroundChoice,
  additionalChoice,
}

/// Registra não apenas a proficiência, mas também de onde ela veio.
class SkillProficiencyGrant {
  const SkillProficiencyGrant({
    required this.skill,
    required this.source,
    required this.sourceId,
    required this.sourceLabel,
    required this.automatic,
  });

  final Skill skill;
  final SkillGrantSource source;
  final String sourceId;
  final String sourceLabel;
  final bool automatic;
}

/// Visão central das perícias adquiridas durante a criação.
class CreationSkillSelection {
  CreationSkillSelection(Iterable<SkillProficiencyGrant> grants)
    : grants = List.unmodifiable(grants);

  final List<SkillProficiencyGrant> grants;

  List<SkillProficiencyGrant> grantsFor(Skill skill) =>
      grants.where((grant) => grant.skill == skill).toList(growable: false);

  SkillProficiencyGrant? acquiredFrom(
    Skill skill, {
    SkillGrantSource? excluding,
  }) {
    for (final grant in grants) {
      if (grant.skill == skill && grant.source != excluding) return grant;
    }
    return null;
  }

  Map<Skill, List<SkillProficiencyGrant>> get conflicts {
    final result = <Skill, List<SkillProficiencyGrant>>{};
    for (final skill in Skill.values) {
      final matches = grantsFor(skill);
      if (matches.length > 1) result[skill] = matches;
    }
    return result;
  }

  String? get validationError {
    for (final duplicate in conflicts.entries) {
      final origins = duplicate.value
          .map((grant) => grant.sourceLabel)
          .join(' e ');
      return '${duplicate.key.label} foi adquirida por $origins. '
          'Escolha outra perícia em uma dessas fontes.';
    }
    return null;
  }

  void validate() {
    final error = validationError;
    if (error != null) throw ArgumentError(error);
  }

  SkillProficiencies toProficiencies() {
    validate();
    return GrantedSkills.apply(
      const SkillProficiencies(),
      grants.map((grant) => grant.skill),
    );
  }
}
