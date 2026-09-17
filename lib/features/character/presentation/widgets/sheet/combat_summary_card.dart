import 'package:dnd_ficha_app/core/theme/app_typography.dart';
import 'package:dnd_ficha_app/core/utils/distance_format.dart';
import 'package:dnd_ficha_app/features/character/application/providers/initiative_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/initiative_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CombatSummaryCard extends ConsumerWidget {
  const CombatSummaryCard({
    required this.character,
    super.key,
  });

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initiative = ref.watch(initiativeProvider(character));

    // Enquanto o compêndio carrega, mostra Destreza mais o campo "outros" —
    // que é o resultado de todo personagem sem característica especial, e o
    // que a ficha já mostrava antes. Um indicador de progresso no meio de
    // quatro números piscaria em cada abertura da ficha.
    final result = initiative.value ?? _withoutCompendium();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CombatValue(
                  label: 'CA',
                  value: '${character.combatStats.armorClass}',
                ),
                _CombatValue(
                  label: 'Iniciativa',
                  value: result.formattedTotal,
                  badge: result.hasAdvantage ? 'vantagem' : null,
                ),
                _CombatValue(
                  label: 'Desloc.',
                  value: formatMeters(character.combatStats.speedInMeters),
                ),
                _CombatValue(
                  label: 'HP',
                  value:
                      '${character.hitPoints.current}/${character.hitPoints.maximum}'
                      '${character.hitPoints.temporary > 0 ? ' (+${character.hitPoints.temporary})' : ''}',
                ),
              ],
            ),
            // A composição só aparece quando há algo além da Destreza: para a
            // maioria dos personagens ela repetiria o número que já está logo
            // acima.
            if (result.modifiers.length > 1 || result.hasAdvantage) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _InitiativeBreakdown(result: result),
            ],
          ],
        ),
      ),
    );
  }

  /// A iniciativa sem as regras do compêndio: Destreza mais ajuste manual.
  InitiativeResult _withoutCompendium() {
    return InitiativeCalculator.calculate(character: character);
  }
}

/// A conta da iniciativa em texto, para o jogador conferir de onde saiu.
class _InitiativeBreakdown extends StatelessWidget {
  const _InitiativeBreakdown({required this.result});

  final InitiativeResult result;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Iniciativa ${result.explanation}',
          style: style,
        ),
        if (result.hasAdvantage) ...[
          const SizedBox(height: 4),
          Text(
            'Vantagem na jogada: ${result.advantageSources.join(', ')}.',
            style: style,
          ),
        ],
      ],
    );
  }
}

class _CombatValue extends StatelessWidget {
  const _CombatValue({
    required this.label,
    required this.value,
    this.badge,
  });

  final String label;
  final String value;

  /// Etiqueta curta abaixo do número, como a vantagem na iniciativa.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.numeric(fontSize: 21)),
        if (badge != null)
          Text(
            badge!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }
}
