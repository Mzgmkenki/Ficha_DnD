import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/active_effects.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Condições ativas, exaustão e a lista de tudo que isso causa.
///
/// As três coisas moram no mesmo painel de propósito: em combate a pergunta é
/// "o que eu consigo fazer agora", e respondê-la olhando as condições num
/// lugar e a exaustão em outro obrigava a somar as regras de cabeça.
class ConditionsPanel extends ConsumerWidget {
  const ConditionsPanel({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = character.conditions;
    final exhaustion = character.exhaustion.clamp(
      0,
      ActiveEffects.maxExhaustion,
    );

    final effects = ActiveEffects.from(
      conditions: selected,
      exhaustion: exhaustion,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final condition in Condition.sortedByLabel)
                  FilterChip(
                    label: Text(condition.label),
                    selected: selected.contains(condition),
                    // Multi-seleção: cada chip é independente, marcar uma não
                    // desmarca as outras.
                    onSelected: (_) async {
                      await ref.read(toggleConditionProvider)(
                        character,
                        condition,
                      );
                    },
                  ),
              ],
            ),
            if (selected.isNotEmpty) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await ref.read(clearConditionsProvider)(character);
                  },
                  icon: const Icon(Icons.layers_clear_outlined, size: 18),
                  label: const Text('Limpar condições'),
                ),
              ),
            ],
            const Divider(),
            _ExhaustionControl(character: character),
            const Divider(),
            _EffectsList(effects: effects),
          ],
        ),
      ),
    );
  }
}

/// Controle de nível de exaustão.
///
/// Veio do painel de descanso: a exaustão é uma condição como as outras, só
/// que com níveis, e os efeitos dela precisam sair na mesma lista.
class _ExhaustionControl extends ConsumerWidget {
  const _ExhaustionControl({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = character.exhaustion.clamp(0, ActiveEffects.maxExhaustion);
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exaustão', style: text.labelLarge),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              tooltip: 'Reduzir exaustão',
              onPressed: level > 0
                  ? () => ref.read(setExhaustionProvider)(character, level - 1)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '$level / ${ActiveEffects.maxExhaustion}',
              style: text.titleMedium,
            ),
            IconButton(
              tooltip: 'Aumentar exaustão',
              onPressed: level < ActiveEffects.maxExhaustion
                  ? () => ref.read(setExhaustionProvider)(character, level + 1)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
            const SizedBox(width: 8),
            if (level == 0)
              Expanded(
                child: Text(
                  'Sem exaustão.',
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
              ),
          ],
        ),
        // Cada degrau some ao anterior, então mostramos a escada inteira: o
        // nível 3 diz o que o 3 acrescenta e o que o 2 e o 1 já impunham.
        if (level > 0)
          for (var step = 1; step <= level; step++)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '$step. ${ActiveEffects.exhaustionEffectAt(step)}',
                style: text.bodySmall,
              ),
            ),
      ],
    );
  }
}

/// Tudo que está pegando no personagem agora, numa lista só.
class _EffectsList extends StatelessWidget {
  const _EffectsList({required this.effects});

  final List<ActiveEffect> effects;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (effects.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Efeitos ativos', style: text.labelLarge),
          const SizedBox(height: 4),
          Text(
            'Nenhum efeito ativo.',
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Efeitos ativos (${effects.length})', style: text.labelLarge),
        const SizedBox(height: 8),
        for (final effect in effects)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        effect.source,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                    // Sem esta etiqueta o jogador veria "Incapacitado" na
                    // lista sem ter marcado a caixa e pensaria em bug.
                    if (effect.isImplied)
                      Text(
                        'por ${effect.impliedBy}',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.onDarkVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                for (final line in effect.effects)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('• $line', style: text.bodySmall),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
