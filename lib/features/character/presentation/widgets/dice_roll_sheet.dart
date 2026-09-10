import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/theme/app_typography.dart';
import 'package:dnd_ficha_app/core/utils/dice_roller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abre a folha de rolagem para um teste de d20 com [modifier].
///
/// Já rola uma vez no modo normal ao abrir: o caso comum é um toque só.
/// Vantagem e desvantagem ficam a um toque de distância.
Future<void> showDiceRollSheet(
  BuildContext context, {
  required String label,
  required int modifier,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => DiceRollSheet(label: label, modifier: modifier),
  );
}

class DiceRollSheet extends ConsumerStatefulWidget {
  const DiceRollSheet({
    required this.label,
    required this.modifier,
    super.key,
  });

  final String label;
  final int modifier;

  @override
  ConsumerState<DiceRollSheet> createState() => _DiceRollSheetState();
}

class _DiceRollSheetState extends ConsumerState<DiceRollSheet> {
  DiceRollResult? _result;

  @override
  void initState() {
    super.initState();
    // Roda depois do primeiro frame para o resultado já aparecer preenchido
    // sem o usuário ter de tocar em nada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _roll(RollMode.normal);
    });
  }

  void _roll(RollMode mode) {
    final roller = ref.read(diceRollerProvider);
    final result = roller.rollD20(
      modifier: widget.modifier,
      mode: mode,
      label: widget.label,
    );
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _result;
    final modifierText = widget.modifier >= 0
        ? '+${widget.modifier}'
        : '${widget.modifier}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.label, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Teste de d20 $modifierText',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (result == null)
              const Center(child: CircularProgressIndicator())
            else
              _ResultCard(result: result),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final mode in RollMode.values)
                  _ModeButton(
                    mode: mode,
                    selected: result?.mode == mode,
                    onPressed: () => _roll(mode),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.mode,
    required this.selected,
    required this.onPressed,
  });

  final RollMode mode;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = switch (mode) {
      RollMode.normal => Icons.casino_outlined,
      RollMode.advantage => Icons.keyboard_double_arrow_up,
      RollMode.disadvantage => Icons.keyboard_double_arrow_down,
    };

    if (selected) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(mode.label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(mode.label),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final DiceRollResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // O 20 natural vai em ouro, e não no vermelho da marca: com a paleta
    // preta e vermelha, destaque e erro ficariam quase da mesma cor.
    final highlight = result.isNaturalTwenty
        ? scheme.tertiary
        : result.isNaturalOne
            ? scheme.error
            : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: highlight == null
            ? null
            : Border.all(color: highlight, width: 2),
      ),
      child: Column(
        children: [
          Text(
            '${result.total}',
            style: AppTypography.numeric(fontSize: 44, color: highlight),
          ),
          const SizedBox(height: 8),
          Text(result.formula, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(result.detail, style: theme.textTheme.bodyMedium),
          if (result.isNaturalTwenty) ...[
            const SizedBox(height: 8),
            Text(
              '20 natural!',
              style: theme.textTheme.labelLarge?.copyWith(color: highlight),
            ),
          ],
          if (result.isNaturalOne) ...[
            const SizedBox(height: 8),
            Text(
              '1 natural.',
              style: theme.textTheme.labelLarge?.copyWith(color: highlight),
            ),
          ],
        ],
      ),
    );
  }
}
