import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/dice_roll_sheet.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/derived_value_row.dart';
import 'package:flutter/material.dart';

class SavingThrowsPanel extends StatelessWidget {
  const SavingThrowsPanel({
    required this.character,
    super.key,
  });

  final Character character;

  bool _isProficient(Ability ability) {
    final saves = character.savingThrowProficiencies;

    return switch (ability) {
      Ability.strength => saves.strength,
      Ability.dexterity => saves.dexterity,
      Ability.constitution => saves.constitution,
      Ability.intelligence => saves.intelligence,
      Ability.wisdom => saves.wisdom,
      Ability.charisma => saves.charisma,
    };
  }

  @override
  Widget build(BuildContext context) {
    final proficiency = character.proficiencyBonus;

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
            for (var i = 0; i < Ability.values.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _SavingThrowRow(
                ability: Ability.values[i],
                bonus: character.abilityScores
                        .valueFor(Ability.values[i])
                        .abilityModifier +
                    (_isProficient(Ability.values[i]) ? proficiency : 0),
                proficient: _isProficient(Ability.values[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SavingThrowRow extends StatelessWidget {
  const _SavingThrowRow({
    required this.ability,
    required this.bonus,
    required this.proficient,
  });

  final Ability ability;
  final int bonus;
  final bool proficient;

  @override
  Widget build(BuildContext context) {
    final label = 'Salvaguarda de ${ability.label}';

    return DerivedValueRow(
      label: ability.label,
      value: bonus,
      proficient: proficient,
      onRoll: () => showDiceRollSheet(
        context,
        label: label,
        modifier: bonus,
      ),
    );
  }
}
