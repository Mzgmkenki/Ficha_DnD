import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:flutter/material.dart';

class AbilityScoreBlock extends StatelessWidget {
  const AbilityScoreBlock({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final modifier = value.abilityModifier;
    final modifierText = modifier >= 0 ? '+$modifier' : '$modifier';

    return SizedBox(
      width: 108,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text('$value', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(modifierText),
            ],
          ),
        ),
      ),
    );
  }
}
