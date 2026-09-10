import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/skill_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

void main() {
  group('modificador de atributo', () {
    test('segue a tabela do PHB', () {
      final character = characterFixture(
        abilityScores: scoresWith(
          strength: 1,
          dexterity: 8,
          constitution: 10,
          intelligence: 11,
          wisdom: 15,
          charisma: 20,
        ),
      );

      expect(SkillCalculator.abilityModifier(character, Ability.strength), -5);
      expect(SkillCalculator.abilityModifier(character, Ability.dexterity), -1);
      expect(
        SkillCalculator.abilityModifier(character, Ability.constitution),
        0,
      );
      // Ímpar arredonda para baixo: 11 e 15 dão o mesmo que 10 e 14.
      expect(
        SkillCalculator.abilityModifier(character, Ability.intelligence),
        0,
      );
      expect(SkillCalculator.abilityModifier(character, Ability.wisdom), 2);
      expect(SkillCalculator.abilityModifier(character, Ability.charisma), 5);
    });
  });

  group('bônus de perícia', () {
    test('sem proficiência é só o modificador do atributo', () {
      final character = characterFixture(
        abilityScores: scoresWith(dexterity: 16),
      );

      expect(SkillCalculator.skillBonus(character, Skill.stealth), 3);
    });

    test('proficiente soma o bônus de proficiência cheio', () {
      final character = characterFixture(
        abilityScores: scoresWith(dexterity: 16),
        skillProficiencies: skillsWith(
          {Skill.stealth: ProficiencyLevel.proficient},
        ),
      );

      // Nível 1: proficiência +2.
      expect(SkillCalculator.skillBonus(character, Skill.stealth), 5);
    });

    test('especialista dobra o bônus de proficiência', () {
      final character = characterFixture(
        abilityScores: scoresWith(dexterity: 16),
        classLevels: const [ClassLevel(classId: 'rogue', level: 5)],
        skillProficiencies: skillsWith(
          {Skill.stealth: ProficiencyLevel.expertise},
        ),
      );

      // Nível 5: proficiência +3, dobrada +6, mais DES +3.
      expect(SkillCalculator.skillBonus(character, Skill.stealth), 9);
    });

    test('meia proficiência arredonda para baixo', () {
      final character = characterFixture(
        abilityScores: scoresWith(dexterity: 16),
        classLevels: const [ClassLevel(classId: 'bard', level: 5)],
        skillProficiencies: skillsWith(
          {Skill.stealth: ProficiencyLevel.half},
        ),
      );

      // Nível 5: proficiência +3, metade = 1 (para baixo), mais DES +3.
      expect(SkillCalculator.skillBonus(character, Skill.stealth), 4);
    });

    test('usa o atributo correto de cada perícia', () {
      final character = characterFixture(
        abilityScores: scoresWith(strength: 18, charisma: 6),
      );

      // Atletismo é Força, Persuasão é Carisma.
      expect(SkillCalculator.skillBonus(character, Skill.athletics), 4);
      expect(SkillCalculator.skillBonus(character, Skill.persuasion), -2);
    });
  });

  group('valores passivos', () {
    test('passivo é 10 mais o bônus da perícia', () {
      final character = characterFixture(
        abilityScores: scoresWith(wisdom: 16),
        skillProficiencies: skillsWith(
          {Skill.perception: ProficiencyLevel.proficient},
        ),
      );

      // 10 + SAB +3 + proficiência +2.
      expect(SkillCalculator.passivePerception(character), 15);
    });

    test('sem proficiência, o passivo cai junto', () {
      final character = characterFixture(
        abilityScores: scoresWith(wisdom: 16),
      );

      expect(SkillCalculator.passivePerception(character), 13);
    });

    test('exaustão dá desvantagem e reduz os passivos em 5', () {
      final rested = characterFixture(
        abilityScores: scoresWith(wisdom: 16),
        skillProficiencies: skillsWith(
          {Skill.perception: ProficiencyLevel.proficient},
        ),
      );
      final tired = characterFixture(
        abilityScores: scoresWith(wisdom: 16),
        skillProficiencies: skillsWith(
          {Skill.perception: ProficiencyLevel.proficient},
        ),
        exhaustion: 1,
      );

      expect(SkillCalculator.passivePerception(rested), 15);
      expect(SkillCalculator.passivePerception(tired), 10);
    });

    test('a penalidade não se acumula com níveis maiores de exaustão', () {
      // Desvantagem é desvantagem: -5 uma vez só.
      final character = characterFixture(
        abilityScores: scoresWith(wisdom: 16),
        exhaustion: 4,
      );

      expect(SkillCalculator.passivePerception(character), 8);
    });

    test('investigação usa Inteligência e intuição usa Sabedoria', () {
      final character = characterFixture(
        abilityScores: scoresWith(intelligence: 20, wisdom: 8),
      );

      expect(SkillCalculator.passiveInvestigation(character), 15);
      expect(SkillCalculator.passiveInsight(character), 9);
    });
  });
}
