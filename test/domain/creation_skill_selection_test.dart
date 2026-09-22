import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiency_grant.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

SkillProficiencyGrant grant(
  Skill skill,
  SkillGrantSource source,
  String label, {
  bool automatic = false,
}) {
  return SkillProficiencyGrant(
    skill: skill,
    source: source,
    sourceId: source.name,
    sourceLabel: label,
    automatic: automatic,
  );
}

void main() {
  test('preserva a origem de cada proficiência', () {
    final selection = CreationSkillSelection([
      grant(Skill.athletics, SkillGrantSource.characterClass, 'classe'),
      grant(
        Skill.perception,
        SkillGrantSource.raceAutomatic,
        'raça',
        automatic: true,
      ),
    ]);

    expect(selection.acquiredFrom(Skill.athletics)!.sourceLabel, 'classe');
    expect(selection.acquiredFrom(Skill.perception)!.automatic, isTrue);
    expect(selection.validationError, isNull);
  });

  test('detecta a mesma perícia em duas fontes', () {
    final selection = CreationSkillSelection([
      grant(Skill.perception, SkillGrantSource.characterClass, 'classe'),
      grant(
        Skill.perception,
        SkillGrantSource.backgroundAutomatic,
        'antecedente',
        automatic: true,
      ),
    ]);

    expect(selection.validationError, contains('Percepção'));
    expect(selection.validationError, contains('classe e antecedente'));
    expect(() => selection.toProficiencies(), throwsArgumentError);
  });

  test('desmarcar em uma fonte torna a perícia disponível novamente', () {
    final selected = CreationSkillSelection([
      grant(Skill.stealth, SkillGrantSource.characterClass, 'classe'),
    ]);
    expect(
      selected.acquiredFrom(
        Skill.stealth,
        excluding: SkillGrantSource.raceChoice,
      ),
      isNotNull,
    );

    final unselected = CreationSkillSelection(const []);
    expect(unselected.acquiredFrom(Skill.stealth), isNull);
  });

  test('fontes diferentes sem repetição viram proficiências uma única vez', () {
    final selection = CreationSkillSelection([
      grant(Skill.arcana, SkillGrantSource.characterClass, 'classe'),
      grant(
        Skill.insight,
        SkillGrantSource.backgroundAutomatic,
        'antecedente',
        automatic: true,
      ),
    ]);

    final proficiencies = selection.toProficiencies();
    expect(proficiencies.isProficient(Skill.arcana), isTrue);
    expect(proficiencies.isProficient(Skill.insight), isTrue);
    expect(proficiencies.activeLevels, hasLength(2));
  });
}
