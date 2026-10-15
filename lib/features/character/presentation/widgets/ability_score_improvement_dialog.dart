import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/services/ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_ability_increases.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:flutter/material.dart';

/// Distribui os pontos de um Incremento no Valor de Atributo.
///
/// Devolve o rascunho confirmado, ou `null` se o jogador desistir. Sair sem
/// confirmar não gasta a escolha: ela continua pendente e volta a ser
/// oferecida.
Future<AbilityScoreImprovementDraft?> showAbilityScoreImprovementDialog({
  required BuildContext context,
  required AbilityScores current,
  required String slotLabel,
  Map<Ability, int> maximums = const {},
  AbilityScoreImprovementDraft initial = const AbilityScoreImprovementDraft(),
}) {
  return showDialog<AbilityScoreImprovementDraft>(
    context: context,
    builder: (dialogContext) => _AbilityScoreImprovementDialog(
      current: current,
      slotLabel: slotLabel,
      maximums: maximums,
      initial: initial,
    ),
  );
}

class _AbilityScoreImprovementDialog extends StatefulWidget {
  const _AbilityScoreImprovementDialog({
    required this.current,
    required this.slotLabel,
    required this.maximums,
    required this.initial,
  });

  final AbilityScores current;
  final String slotLabel;
  final Map<Ability, int> maximums;
  final AbilityScoreImprovementDraft initial;

  @override
  State<_AbilityScoreImprovementDialog> createState() =>
      _AbilityScoreImprovementDialogState();
}

class _AbilityScoreImprovementDialogState
    extends State<_AbilityScoreImprovementDialog> {
  late AbilityScoreImprovementDraft _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Incremento no Valor de Atributo'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.slotLabel, style: text.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Aumente um atributo em +2, ou dois atributos em +1 cada.',
              style: text.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final ability in Ability.values)
              _AbilityRow(
                ability: ability,
                currentValue: widget.current.valueFor(ability),
                previewValue: _draft.previewFor(ability, widget.current),
                amount: _draft.amountFor(ability),
                maximum: widget.maximums[ability] ??
                    GrantedAbilityIncreases.maximum,
                canIncrement: _draft.canIncrement(
                  ability,
                  current: widget.current,
                  maximums: widget.maximums,
                ),
                blockReason: _draft.incrementBlockReason(
                  ability,
                  current: widget.current,
                  maximums: widget.maximums,
                ),
                onIncrement: () => setState(() {
                  _draft = _draft.increment(
                    ability,
                    current: widget.current,
                    maximums: widget.maximums,
                  );
                }),
                onDecrement: () => setState(() {
                  _draft = _draft.decrement(ability);
                }),
              ),
            const SizedBox(height: 8),
            Text(
              _draft.progressLabel,
              key: const ValueKey('asi-progress'),
              style: text.bodyMedium?.copyWith(
                color: _draft.isComplete
                    ? AppColors.onDarkVariant
                    : AppColors.error,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const ValueKey('asi-confirm'),
          // Travado até a distribuição fechar: confirmar com ponto sobrando
          // perderia o ponto em silêncio, e ele não volta.
          onPressed: _draft.isComplete
              ? () => Navigator.of(context).pop(_draft)
              : null,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

/// Uma linha de atributo: valor atual, prévia e os dois botões.
class _AbilityRow extends StatelessWidget {
  const _AbilityRow({
    required this.ability,
    required this.currentValue,
    required this.previewValue,
    required this.amount,
    required this.maximum,
    required this.canIncrement,
    required this.blockReason,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Ability ability;
  final int currentValue;
  final int previewValue;
  final int amount;
  final int maximum;
  final bool canIncrement;
  final String? blockReason;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final atMaximum = previewValue >= maximum;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ability.label, style: text.bodyLarge),
                Text(
                  // A prévia é explícita porque o jogador precisa ver o
                  // resultado ANTES de confirmar: "16 → 18" responde a
                  // pergunta que ele tem na cabeça.
                  amount > 0
                      ? '$currentValue → $previewValue (máx. $maximum)'
                      : '$currentValue (máx. $maximum)',
                  style: text.bodySmall?.copyWith(
                    color: atMaximum
                        ? AppColors.error
                        : AppColors.onDarkVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: ValueKey('asi-minus-${ability.name}'),
            tooltip: 'Remover 1 de ${ability.label}',
            onPressed: amount > 0 ? onDecrement : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 28,
            child: Text(
              amount > 0 ? '+$amount' : '—',
              textAlign: TextAlign.center,
              style: text.titleMedium,
            ),
          ),
          IconButton(
            key: ValueKey('asi-plus-${ability.name}'),
            // O motivo do bloqueio vai no tooltip: botão apagado sem
            // explicação manda o jogador procurar o erro na própria cabeça.
            tooltip: canIncrement
                ? 'Somar 1 em ${ability.label}'
                : (blockReason ?? 'Indisponível'),
            onPressed: canIncrement ? onIncrement : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
