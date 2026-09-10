import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

void main() {
  group('bônus de proficiência por nível', () {
    test('segue os degraus do PHB', () {
      const expected = {
        1: 2,
        4: 2,
        5: 3,
        8: 3,
        9: 4,
        12: 4,
        13: 5,
        16: 5,
        17: 6,
        20: 6,
      };

      expected.forEach((level, bonus) {
        final character = characterFixture(
          classLevels: [ClassLevel(classId: 'fighter', level: level)],
        );
        expect(
          character.proficiencyBonus,
          bonus,
          reason: 'nível $level deveria dar +$bonus',
        );
      });
    });

    test('em multiclasse vale o nível somado, não o da classe', () {
      // 3 + 2 = nível 5, que dá +3 mesmo nenhuma classe passando de 3.
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'fighter', level: 3),
          ClassLevel(classId: 'rogue', level: 2),
        ],
      );

      expect(character.totalLevel, 5);
      expect(character.proficiencyBonus, 3);
    });
  });

  group('ProficiencyLevel.bonus', () {
    test('nenhuma proficiência não soma nada', () {
      expect(ProficiencyLevel.none.bonus(6), 0);
    });

    test('proficiente soma o bônus cheio', () {
      expect(ProficiencyLevel.proficient.bonus(2), 2);
      expect(ProficiencyLevel.proficient.bonus(6), 6);
    });

    test('especialista dobra', () {
      expect(ProficiencyLevel.expertise.bonus(2), 4);
      expect(ProficiencyLevel.expertise.bonus(6), 12);
    });

    test('meia proficiência arredonda para baixo', () {
      expect(ProficiencyLevel.half.bonus(2), 1);
      expect(ProficiencyLevel.half.bonus(3), 1);
      expect(ProficiencyLevel.half.bonus(5), 2);
      expect(ProficiencyLevel.half.bonus(6), 3);
    });
  });

  group('isProficientOrBetter', () {
    test('vale para proficiente e especialista', () {
      expect(ProficiencyLevel.proficient.isProficientOrBetter, isTrue);
      expect(ProficiencyLevel.expertise.isProficientOrBetter, isTrue);
    });

    test('meia proficiência não conta como proficiência', () {
      // Importante: meia proficiência não habilita, por exemplo, dobrar em
      // Especialista nem contar como "tem a perícia".
      expect(ProficiencyLevel.half.isProficientOrBetter, isFalse);
      expect(ProficiencyLevel.none.isProficientOrBetter, isFalse);
    });
  });

  group('persistência do nível', () {
    test('dbValue mantém a ordem semântica', () {
      expect(ProficiencyLevel.none.dbValue, 0);
      expect(ProficiencyLevel.half.dbValue, 1);
      expect(ProficiencyLevel.proficient.dbValue, 2);
      expect(ProficiencyLevel.expertise.dbValue, 3);
    });

    test('fromDb inverte dbValue para todos os níveis', () {
      for (final level in ProficiencyLevel.values) {
        expect(ProficiencyLevel.fromDb(level.dbValue), level);
      }
    });

    test('valor inválido ou nulo cai em none, sem lançar', () {
      expect(ProficiencyLevel.fromDb(null), ProficiencyLevel.none);
      expect(ProficiencyLevel.fromDb(99), ProficiencyLevel.none);
      expect(ProficiencyLevel.fromDb(-1), ProficiencyLevel.none);
    });
  });

  group('SkillProficiencies', () {
    test('perícia sem registro é none', () {
      const skills = SkillProficiencies();

      expect(skills.levelFor(Skill.arcana), ProficiencyLevel.none);
      expect(skills.isProficient(Skill.arcana), isFalse);
    });

    test('withLevel não altera o objeto original', () {
      const original = SkillProficiencies();
      final updated = original.withLevel(
        Skill.arcana,
        ProficiencyLevel.expertise,
      );

      expect(original.levelFor(Skill.arcana), ProficiencyLevel.none);
      expect(updated.levelFor(Skill.arcana), ProficiencyLevel.expertise);
    });

    test('definir none remove a perícia dos níveis ativos', () {
      final skills = skillsWith({
        Skill.arcana: ProficiencyLevel.proficient,
        Skill.stealth: ProficiencyLevel.half,
      }).withLevel(Skill.arcana, ProficiencyLevel.none);

      expect(skills.activeLevels.keys, [Skill.stealth]);
    });

    test('activeLevels ignora quem está em none', () {
      final skills = skillsWith({
        Skill.arcana: ProficiencyLevel.none,
        Skill.stealth: ProficiencyLevel.proficient,
      });

      expect(skills.activeLevels, {Skill.stealth: ProficiencyLevel.proficient});
    });

    test('fromBooleans converte os dados legados em proficiente', () {
      final skills = SkillProficiencies.fromBooleans(
        stealth: true,
        arcana: false,
      );

      expect(skills.levelFor(Skill.stealth), ProficiencyLevel.proficient);
      expect(skills.levelFor(Skill.arcana), ProficiencyLevel.none);
    });
  });

  group('Skill', () {
    test('fromId encontra a perícia e ignora id inválido', () {
      expect(Skill.fromId('stealth'), Skill.stealth);
      expect(Skill.fromId('sleightOfHand'), Skill.sleightOfHand);
      expect(Skill.fromId('nao_existe'), isNull);
      expect(Skill.fromId(null), isNull);
    });

    test('são 18 perícias e todas com id único', () {
      expect(Skill.values.length, 18);
      expect(Skill.values.map((s) => s.id).toSet().length, 18);
    });

    test('a abreviação vem do atributo que governa a perícia', () {
      expect(Skill.athletics.abbreviation, 'FOR');
      expect(Skill.stealth.abbreviation, 'DES');
      expect(Skill.arcana.abbreviation, 'INT');
      expect(Skill.perception.abbreviation, 'SAB');
      expect(Skill.persuasion.abbreviation, 'CAR');
    });

    test('sortedByLabel ordena pelo rótulo em português', () {
      final labels = Skill.sortedByLabel.map((s) => s.label).toList();
      final sorted = [...labels]..sort();

      expect(labels, sorted);
      expect(labels.first, 'Acrobacia');
    });
  });
}
