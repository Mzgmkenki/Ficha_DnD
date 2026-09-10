import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:flutter/material.dart';

class CombatSummaryCard extends StatelessWidget {
  const CombatSummaryCard({
    required this.character,
    super.key,
  });

  final Character character;

  @override
  Widget build(BuildContext context) {
    final dexModifier = character.abilityScores.dexterity.abilityModifier;
    final initiative = dexModifier + character.combatStats.initiativeBonus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _CombatValue(
              label: 'CA',
              value: '${character.combatStats.armorClass}',
            ),
            _CombatValue(
              label: 'Iniciativa',
              value: initiative >= 0 ? '+$initiative' : '$initiative',
            ),
            _CombatValue(
              label: 'Desloc.',
              value: '${character.combatStats.speedInSquares}m',
            ),
            _CombatValue(
              label: 'HP',
              value:
                  '${character.hitPoints.current}/${character.hitPoints.maximum}'
                  '${character.hitPoints.temporary > 0 ? ' (+${character.hitPoints.temporary})' : ''}',
            ),
          ],
        ),
      ),
    );
  }
}

class _CombatValue extends StatelessWidget {
  const _CombatValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}