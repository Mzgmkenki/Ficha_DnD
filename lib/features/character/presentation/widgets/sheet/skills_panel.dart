import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/derived_value_row.dart';
import 'package:flutter/material.dart';

class SkillsPanel extends StatelessWidget {
  const SkillsPanel({
    required this.character,
    super.key,
  });

  final Character character;

  @override
  Widget build(BuildContext context) {
    final proficiency = character.proficiencyBonus;
    final skills = character.skillProficiencies;

    final strengthMod = character.abilityScores.strength.abilityModifier;
    final dexterityMod = character.abilityScores.dexterity.abilityModifier;
    final intelligenceMod = character.abilityScores.intelligence.abilityModifier;
    final wisdomMod = character.abilityScores.wisdom.abilityModifier;
    final charismaMod = character.abilityScores.charisma.abilityModifier;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Perícias',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            DerivedValueRow(
              label: 'Acrobacia (DES)',
              value: dexterityMod + (skills.acrobatics ? proficiency : 0),
              proficient: skills.acrobatics,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Adestrar Animais (SAB)',
              value: wisdomMod + (skills.animalHandling ? proficiency : 0),
              proficient: skills.animalHandling,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Arcanismo (INT)',
              value: intelligenceMod + (skills.arcana ? proficiency : 0),
              proficient: skills.arcana,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Atletismo (FOR)',
              value: strengthMod + (skills.athletics ? proficiency : 0),
              proficient: skills.athletics,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Atuação (CAR)',
              value: charismaMod + (skills.performance ? proficiency : 0),
              proficient: skills.performance,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Enganação (CAR)',
              value: charismaMod + (skills.deception ? proficiency : 0),
              proficient: skills.deception,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Furtividade (DES)',
              value: dexterityMod + (skills.stealth ? proficiency : 0),
              proficient: skills.stealth,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'História (INT)',
              value: intelligenceMod + (skills.history ? proficiency : 0),
              proficient: skills.history,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Intimidação (CAR)',
              value: charismaMod + (skills.intimidation ? proficiency : 0),
              proficient: skills.intimidation,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Intuição (SAB)',
              value: wisdomMod + (skills.insight ? proficiency : 0),
              proficient: skills.insight,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Investigação (INT)',
              value: intelligenceMod + (skills.investigation ? proficiency : 0),
              proficient: skills.investigation,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Medicina (SAB)',
              value: wisdomMod + (skills.medicine ? proficiency : 0),
              proficient: skills.medicine,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Natureza (INT)',
              value: intelligenceMod + (skills.nature ? proficiency : 0),
              proficient: skills.nature,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Percepção (SAB)',
              value: wisdomMod + (skills.perception ? proficiency : 0),
              proficient: skills.perception,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Persuasão (CAR)',
              value: charismaMod + (skills.persuasion ? proficiency : 0),
              proficient: skills.persuasion,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Prestidigitação (DES)',
              value: dexterityMod + (skills.sleightOfHand ? proficiency : 0),
              proficient: skills.sleightOfHand,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Religião (INT)',
              value: intelligenceMod + (skills.religion ? proficiency : 0),
              proficient: skills.religion,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Sobrevivência (SAB)',
              value: wisdomMod + (skills.survival ? proficiency : 0),
              proficient: skills.survival,
            ),
          ],
        ),
      ),
    );
  }
}