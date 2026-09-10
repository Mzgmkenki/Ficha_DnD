import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/derived_value_row.dart';
import 'package:flutter/material.dart';

class SavingThrowsPanel extends StatelessWidget {
  const SavingThrowsPanel({
    required this.character,
    super.key,
  });

  final Character character;

  @override
  Widget build(BuildContext context) {
    final proficiency = character.proficiencyBonus;

    final strengthMod = character.abilityScores.strength.abilityModifier;
    final dexterityMod = character.abilityScores.dexterity.abilityModifier;
    final constitutionMod = character.abilityScores.constitution.abilityModifier;
    final intelligenceMod = character.abilityScores.intelligence.abilityModifier;
    final wisdomMod = character.abilityScores.wisdom.abilityModifier;
    final charismaMod = character.abilityScores.charisma.abilityModifier;

    final saves = character.savingThrowProficiencies;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Salvaguardas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            DerivedValueRow(
              label: 'Força',
              value: strengthMod + (saves.strength ? proficiency : 0),
              proficient: saves.strength,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Destreza',
              value: dexterityMod + (saves.dexterity ? proficiency : 0),
              proficient: saves.dexterity,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Constituição',
              value: constitutionMod + (saves.constitution ? proficiency : 0),
              proficient: saves.constitution,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Inteligência',
              value: intelligenceMod + (saves.intelligence ? proficiency : 0),
              proficient: saves.intelligence,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Sabedoria',
              value: wisdomMod + (saves.wisdom ? proficiency : 0),
              proficient: saves.wisdom,
            ),
            const SizedBox(height: 8),
            DerivedValueRow(
              label: 'Carisma',
              value: charismaMod + (saves.charisma ? proficiency : 0),
              proficient: saves.charisma,
            ),
          ],
        ),
      ),
    );
  }
}