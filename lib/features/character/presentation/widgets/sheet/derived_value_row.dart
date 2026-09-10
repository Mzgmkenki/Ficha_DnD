import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:flutter/material.dart';

class DerivedValueRow extends StatelessWidget {
  const DerivedValueRow({
    required this.label,
    required this.value,
    this.proficient = false,
    this.level,
    super.key,
  });

  final String label;
  final int value;
  final bool proficient;

  /// Quando informado, o ícone e a etiqueta refletem o nível exato
  /// (metade, proficiente ou especialista) em vez de apenas sim/não.
  final ProficiencyLevel? level;

  @override
  Widget build(BuildContext context) {
    final display = value >= 0 ? '+$value' : '$value';
    final effective = level ??
        (proficient ? ProficiencyLevel.proficient : ProficiencyLevel.none);

    return Row(
      children: [
        Icon(_iconFor(effective), size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        if (effective == ProficiencyLevel.expertise ||
            effective == ProficiencyLevel.half) ...[
          Tooltip(
            message: effective.label,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                effective.shortTag ?? '',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          display,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  IconData _iconFor(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.none:
        return Icons.circle_outlined;
      case ProficiencyLevel.half:
        return Icons.contrast;
      case ProficiencyLevel.proficient:
        return Icons.check_circle;
      case ProficiencyLevel.expertise:
        return Icons.stars;
    }
  }
}
