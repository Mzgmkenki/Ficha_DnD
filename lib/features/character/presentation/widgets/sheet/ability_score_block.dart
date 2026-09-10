import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/dice_roll_sheet.dart';
import 'package:flutter/material.dart';

class AbilityScoreBlock extends StatelessWidget {
  const AbilityScoreBlock({
    required this.ability,
    required this.value,
    super.key,
  });

  final Ability ability;
  final int value;

  @override
  Widget build(BuildContext context) {
    final modifier = value.abilityModifier;
    final modifierText = modifier >= 0 ? '+$modifier' : '$modifier';

    return SizedBox(
      width: 108,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          button: true,
          label: 'Rolar teste de ${ability.label}',
          child: InkWell(
            onTap: () => showDiceRollSheet(
              context,
              label: 'Teste de ${ability.label}',
              modifier: modifier,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    ability.abbreviation,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(modifierText),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.casino_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
