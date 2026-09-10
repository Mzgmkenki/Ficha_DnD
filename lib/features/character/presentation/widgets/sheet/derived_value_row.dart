import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:flutter/material.dart';

class DerivedValueRow extends StatelessWidget {
  const DerivedValueRow({
    required this.label,
    required this.value,
    this.proficient = false,
    this.level,
    this.onRoll,
    super.key,
  });

  final String label;
  final int value;
  final bool proficient;

  /// Quando informado, o ícone e a etiqueta refletem o nível exato
  /// (metade, proficiente ou especialista) em vez de apenas sim/não.
  final ProficiencyLevel? level;

  /// Quando informado, a linha inteira vira um botão que rola o teste.
  final VoidCallback? onRoll;

  @override
  Widget build(BuildContext context) {
    final display = value >= 0 ? '+$value' : '$value';
    final effective = level ??
        (proficient ? ProficiencyLevel.proficient : ProficiencyLevel.none);

    final row = Row(
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
        if (onRoll != null) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.casino_outlined,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ],
    );

    if (onRoll == null) return row;

    return Semantics(
      button: true,
      label: 'Rolar $label',
      child: InkWell(
        onTap: onRoll,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: row,
        ),
      ),
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
