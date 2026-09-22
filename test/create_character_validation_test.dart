import 'package:dnd_ficha_app/features/character/application/use_cases/character/create_character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiency_grant.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/standard_array.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

class _Repository implements CharacterRepository {
  Character? created;

  @override
  Future<void> create(Character character) async => created = character;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

const _base = AbilityScores(
  strength: 15,
  dexterity: 14,
  constitution: 13,
  intelligence: 12,
  wisdom: 10,
  charisma: 8,
);

Character validCharacter() {
  const allocation = AbilityScoreAllocation(
    baseScores: _base,
    originBonuses: {Ability.strength: 2},
  );
  return characterFixture(
    abilityScores: allocation.totals(),
    skillProficiencies: const SkillProficiencies(
      levels: {Skill.athletics: ProficiencyLevel.proficient},
    ),
  ).copyWith(
    abilityScoreAllocation: allocation,
    skillProficiencyGrants: const [
      SkillProficiencyGrant(
        skill: Skill.athletics,
        source: SkillGrantSource.characterClass,
        sourceId: 'fighter',
        sourceLabel: 'classe Guerreiro',
        automatic: false,
      ),
    ],
  );
}

void main() {
  test('aceita criação com conjunto e origens consistentes', () async {
    final repository = _Repository();
    final character = validCharacter();

    await CreateCharacter(repository)(character);

    expect(repository.created, same(character));
  });

  test(
    'bloqueia conjunto duplicado mesmo que a interface seja contornada',
    () async {
      final repository = _Repository();
      final character = validCharacter().copyWith(
        abilityScoreAllocation: const AbilityScoreAllocation(
          baseScores: AbilityScores(
            strength: 15,
            dexterity: 15,
            constitution: 13,
            intelligence: 12,
            wisdom: 10,
            charisma: 8,
          ),
        ),
      );

      await expectLater(
        CreateCharacter(repository)(character),
        throwsArgumentError,
      );
      expect(repository.created, isNull);
    },
  );

  test('bloqueia a mesma perícia registrada em duas origens', () async {
    final repository = _Repository();
    final original = validCharacter();
    final character = original.copyWith(
      skillProficiencyGrants: [
        ...original.skillProficiencyGrants,
        const SkillProficiencyGrant(
          skill: Skill.athletics,
          source: SkillGrantSource.backgroundAutomatic,
          sourceId: 'soldier',
          sourceLabel: 'antecedente Soldado',
          automatic: true,
        ),
      ],
    );

    await expectLater(
      CreateCharacter(repository)(character),
      throwsArgumentError,
    );
    expect(repository.created, isNull);
  });
}
