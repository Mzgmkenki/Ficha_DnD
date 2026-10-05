import 'package:dnd_ficha_app/core/routing/app_navigator.dart';
import 'package:dnd_ficha_app/core/theme/app_typography.dart';
import 'package:dnd_ficha_app/core/utils/distance_format.dart';
import 'package:dnd_ficha_app/features/character/application/providers/initiative_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/initiative_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CombatSummaryCard extends ConsumerStatefulWidget {
  const CombatSummaryCard({required this.character, super.key});

  final Character character;

  @override
  ConsumerState<CombatSummaryCard> createState() => _CombatSummaryCardState();
}

class _CombatSummaryCardState extends ConsumerState<CombatSummaryCard> {
  bool _updatingHitPoints = false;

  @override
  Widget build(BuildContext context) {
    final character = widget.character;
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
                  // Duas etiquetas possíveis, e a de ajuste tem prioridade:
                  // saber que o número tem parcela manual importa mais na hora
                  // de conferir a conta do que a vantagem, que a composição
                  // logo abaixo repete.
                  badge:
                      result.hasManualAdjustment
                          ? 'ajustada'
                          : (result.hasAdvantage ? 'vantagem' : null),
                  onTap:
                      () => AppNavigator.toEditInitiative(
                        context,
                        character: character,
                      ),
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
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _HitPointControls(
              character: character,
              busy: _updatingHitPoints,
              onDamage: () => _changeHitPoints(damage: true),
              onHeal: () => _changeHitPoints(damage: false),
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
    return InitiativeCalculator.calculate(character: widget.character);
  }

  Future<void> _changeHitPoints({required bool damage}) async {
    if (_updatingHitPoints) return;
    setState(() => _updatingHitPoints = true);

    try {
      final update = ref.read(updateCharacterHitPointsProvider);
      if (damage) {
        await update.applyDamage(characterId: widget.character.id);
      } else {
        await update.heal(characterId: widget.character.id);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível atualizar os PV: $error')),
      );
    } finally {
      if (mounted) setState(() => _updatingHitPoints = false);
    }
  }
}

class _HitPointControls extends StatelessWidget {
  const _HitPointControls({
    required this.character,
    required this.busy,
    required this.onDamage,
    required this.onHeal,
  });

  final Character character;
  final bool busy;
  final VoidCallback onDamage;
  final VoidCallback onHeal;

  @override
  Widget build(BuildContext context) {
    final hitPoints = character.hitPoints;
    final canDamage = hitPoints.current > 0 || hitPoints.temporary > 0;
    final canHeal = hitPoints.current < hitPoints.maximum;

    return Row(
      children: [
        _HpButton(
          icon: Icons.remove,
          label: 'Diminuir pontos de vida',
          onPressed: !busy && canDamage ? onDamage : null,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PV: ${hitPoints.current}/${hitPoints.maximum}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                'PV temporários: ${hitPoints.temporary}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        _HpButton(
          icon: Icons.add,
          label: 'Aumentar pontos de vida',
          onPressed: !busy && canHeal ? onHeal : null,
        ),
      ],
    );
  }
}

class _HpButton extends StatelessWidget {
  const _HpButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      excludeSemantics: true,
      child: IconButton.filledTonal(
        tooltip: label,
        onPressed: onPressed,
        icon: Icon(icon),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
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
        Text('Iniciativa ${result.explanation}', style: style),
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
    this.onTap,
  });

  final String label;
  final String value;

  /// Etiqueta curta abaixo do número, como a vantagem na iniciativa.
  final String? badge;

  /// Abre a tela que edita este valor, quando existe uma.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Column(
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

    if (onTap == null) return content;

    // `InkWell` com rótulo de acessibilidade: quem usa leitor de tela precisa
    // saber que este número abre uma tela, e o valor sozinho não diz isso.
    return Semantics(
      button: true,
      label: 'Ajustar $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: content,
        ),
      ),
    );
  }
}
