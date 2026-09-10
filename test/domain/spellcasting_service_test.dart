import 'package:dnd_ficha_app/features/character/domain/services/spellcasting_service.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

void main() {
  group('CD de resistência', () {
    test('é 8 + proficiência + modificador do atributo', () {
      // Mago nível 5 (proficiência +3) com INT 18 (+4): 8 + 3 + 4.
      expect(
        SpellcastingService.spellSaveDc(
          proficiencyBonus: 3,
          castingAbility: Ability.intelligence,
          scores: scoresWith(intelligence: 18),
        ),
        15,
      );
    });

    test('modificador negativo derruba a CD', () {
      expect(
        SpellcastingService.spellSaveDc(
          proficiencyBonus: 2,
          castingAbility: Ability.charisma,
          scores: scoresWith(charisma: 8),
        ),
        9,
      );
    });

    test('usa o atributo de conjuração informado, não outro', () {
      // Patrulheiro conjura com Sabedoria, mesmo tendo Destreza alta.
      final scores = scoresWith(dexterity: 20, wisdom: 14);

      expect(
        SpellcastingService.spellSaveDc(
          proficiencyBonus: 2,
          castingAbility: Ability.wisdom,
          scores: scores,
        ),
        12,
      );
      expect(
        SpellcastingService.spellSaveDc(
          proficiencyBonus: 2,
          castingAbility: Ability.dexterity,
          scores: scores,
        ),
        15,
      );
    });
  });

  group('bônus de ataque com magia', () {
    test('é proficiência + modificador do atributo', () {
      expect(
        SpellcastingService.spellAttackBonus(
          proficiencyBonus: 3,
          castingAbility: Ability.intelligence,
          scores: scoresWith(intelligence: 18),
        ),
        7,
      );
    });

    test('é sempre 8 menos que a CD do mesmo atributo', () {
      for (final proficiency in [2, 3, 4, 5, 6]) {
        final scores = scoresWith(charisma: 16);

        final dc = SpellcastingService.spellSaveDc(
          proficiencyBonus: proficiency,
          castingAbility: Ability.charisma,
          scores: scores,
        );
        final attack = SpellcastingService.spellAttackBonus(
          proficiencyBonus: proficiency,
          castingAbility: Ability.charisma,
          scores: scores,
        );

        expect(dc - attack, 8);
      }
    });
  });
}
