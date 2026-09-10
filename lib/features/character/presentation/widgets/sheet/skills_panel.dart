import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/skill_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
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
    final skills = Skill.sortedByLabel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perícias',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _PassiveScores(character: character),
            const SizedBox(height: 16),
            for (var i = 0; i < skills.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              DerivedValueRow(
                label: '${skills[i].label} (${skills[i].abbreviation})',
                value: SkillCalculator.skillBonus(character, skills[i]),
                level: character.skillProficiencies.levelFor(skills[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Valores passivos, obrigatórios numa ficha 5e e antes ausentes.
class _PassiveScores extends StatelessWidget {
  const _PassiveScores({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final hasExhaustion = character.exhaustion >= 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valores passivos',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _PassiveChip(
                label: 'Percepção',
                value: SkillCalculator.passivePerception(character),
              ),
              _PassiveChip(
                label: 'Investigação',
                value: SkillCalculator.passiveInvestigation(character),
              ),
              _PassiveChip(
                label: 'Intuição',
                value: SkillCalculator.passiveInsight(character),
              ),
            ],
          ),
          if (hasExhaustion) ...[
            const SizedBox(height: 8),
            Text(
              'Exaustão ${character.exhaustion}: desvantagem em testes '
              'reduz os valores passivos em 5.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _PassiveChip extends StatelessWidget {
  const _PassiveChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text('$value', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
