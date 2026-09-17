import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/core/theme/app_typography.dart';
import 'package:dnd_ficha_app/features/character/application/providers/initiative_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/initiative_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ajuste manual da iniciativa, sem abrir mão do cálculo automático.
///
/// A iniciativa continua sendo calculada pelas regras: Destreza, característica
/// de classe e subclasse, talento e raça. O que esta tela edita é uma parcela
/// que SOMA ao cálculo, e não um número que o substitui:
///
///     iniciativa total = iniciativa calculada + ajuste manual
///
/// A composição aparece inteira para o jogador conferir de onde saiu cada
/// pedaço. Um campo que sobrescrevesse o total esconderia o cálculo e deixaria
/// a ficha desatualizada depois de subir de nível ou trocar de atributo.
class EditInitiativePage extends ConsumerStatefulWidget {
  const EditInitiativePage({required this.character, super.key});

  final Character character;

  @override
  ConsumerState<EditInitiativePage> createState() => _EditInitiativePageState();
}

class _EditInitiativePageState extends ConsumerState<EditInitiativePage> {
  late int _adjustment;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _adjustment = widget.character.combatStats.initiativeBonus;
  }

  @override
  Widget build(BuildContext context) {
    final asyncResult = ref.watch(initiativeProvider(widget.character));

    // Mesmo recurso do cartão de combate: enquanto o compêndio carrega, mostra
    // Destreza mais o ajuste em vez de um indicador de progresso no lugar do
    // número.
    final saved = asyncResult.value ??
        InitiativeCalculator.calculate(character: widget.character);

    // O ajuste em edição ainda não está salvo, então o total da tela é o
    // calculado mais o que está no controle agora.
    final calculated = saved.calculatedTotal;
    final total = calculated + _adjustment;
    final changed = _adjustment != widget.character.combatStats.initiativeBonus;

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciativa')),
      body: ListView(
        padding: context.scrollContentPadding(),
        children: [
          _TotalCard(
            calculated: calculated,
            adjustment: _adjustment,
            total: total,
            hasAdvantage: saved.hasAdvantage,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajuste manual',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Soma ao cálculo automático. Aceita valor positivo, '
                    'negativo ou zero, e serve para o que a ficha ainda não '
                    'conhece — bênção do mestre, item caseiro, regra da mesa.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Diminuir ajuste',
                        onPressed: () => setState(() => _adjustment--),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            InitiativeResult.formatSigned(_adjustment),
                            style: AppTypography.numeric(fontSize: 26),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Aumentar ajuste',
                        onPressed: () => setState(() => _adjustment++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      // Sempre habilitado quando há ajuste: é a saída para
                      // voltar ao cálculo puro sem ter que clicar no menos até
                      // acertar o zero.
                      onPressed: _adjustment == 0
                          ? null
                          : () => setState(() => _adjustment = 0),
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('Remover ajuste'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _BreakdownCard(result: saved, adjustment: _adjustment),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving || !changed ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              _saving
                  ? 'Salvando...'
                  : 'Salvar iniciativa ${InitiativeResult.formatSigned(total)}',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      await ref.read(characterRepositoryProvider).update(
            widget.character.copyWith(
              combatStats: widget.character.combatStats.copyWith(
                initiativeBonus: _adjustment,
              ),
              updatedAt: DateTime.now(),
            ),
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar a iniciativa: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// Calculada, ajuste e total, na ordem da fórmula.
class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.calculated,
    required this.adjustment,
    required this.total,
    required this.hasAdvantage,
  });

  final int calculated;
  final int adjustment;
  final int total;
  final bool hasAdvantage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Value(label: 'Calculada', value: calculated),
                const _Operator('+'),
                _Value(label: 'Ajuste', value: adjustment),
                const _Operator('='),
                _Value(label: 'Total', value: total, highlight: true),
              ],
            ),
            if (hasAdvantage) ...[
              const SizedBox(height: 8),
              Text(
                'Com vantagem na jogada.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.red,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final int value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Text(
          InitiativeResult.formatSigned(value),
          style: AppTypography.numeric(
            fontSize: highlight ? 30 : 22,
            color: highlight ? AppColors.red : null,
          ),
        ),
      ],
    );
  }
}

class _Operator extends StatelessWidget {
  const _Operator(this.symbol);

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        symbol,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onDarkVariant,
            ),
      ),
    );
  }
}

/// A composição parcela por parcela, incluindo o ajuste em edição.
class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.result, required this.adjustment});

  final InitiativeResult result;
  final int adjustment;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rules = result.calculatedModifiers;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('De onde vem o número', style: text.titleMedium),
            const SizedBox(height: 8),
            for (final modifier in rules)
              _Line(
                label: modifier.origin == null
                    ? modifier.label
                    : '${modifier.label} (${modifier.origin})',
                value: modifier.value,
              ),
            // O ajuste entra na lista mesmo em zero enquanto a tela está
            // aberta: é o campo que o jogador está mexendo, e sumir dali daria
            // a impressão de que ele não conta.
            _Line(
              label: InitiativeCalculator.manualAdjustmentLabel,
              value: adjustment,
              muted: adjustment == 0,
            ),
            const Divider(height: 20),
            _Line(
              label: 'Total',
              value: result.calculatedTotal + adjustment,
              bold: true,
            ),
            if (result.hasAdvantage) ...[
              const SizedBox(height: 8),
              Text(
                'Vantagem na jogada: '
                '${result.advantageSources.join(', ')}.',
                style: text.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.bold = false,
    this.muted = false,
  });

  final String label;
  final int value;
  final bool bold;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium;
    final style = base?.copyWith(
      fontWeight: bold ? FontWeight.w700 : null,
      color: muted ? AppColors.onDarkVariant : null,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(InitiativeResult.formatSigned(value), style: style),
        ],
      ),
    );
  }
}
