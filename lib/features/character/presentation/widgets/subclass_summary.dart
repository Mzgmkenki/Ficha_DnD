import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter/material.dart';

/// Mostra a descrição da subclasse e as características já liberadas.
///
/// Fica fora das páginas porque aparece em dois lugares: na escolha (criação e
/// níveis de classe) e na ficha. O corte por [level] é o que evita entregar de
/// bandeja uma característica de 15º nível para quem está no 3º.
class SubclassSummary extends StatelessWidget {
  const SubclassSummary({
    required this.subclass,
    required this.level,
    this.showDescription = true,
    super.key,
  });

  final SubclassEntry subclass;

  /// Nível do personagem nessa classe.
  final int level;

  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final available = subclass.featuresUpTo(level);
    final upcoming = subclass.features.length - available.length;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subclass.name, style: text.titleSmall),
            if (showDescription &&
                subclass.description != null &&
                subclass.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(subclass.description!),
            ],
            const SizedBox(height: 10),
            if (available.isEmpty)
              Text(
                'Nenhuma característica liberada no $levelº nível.',
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              )
            else
              ...available.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${feature.level}º nível — ${feature.name}',
                        style: text.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(feature.description, style: text.bodySmall),
                    ],
                  ),
                ),
              ),
            if (upcoming > 0)
              Text(
                upcoming == 1
                    ? 'Mais 1 característica em níveis seguintes.'
                    : 'Mais $upcoming características em níveis seguintes.',
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
