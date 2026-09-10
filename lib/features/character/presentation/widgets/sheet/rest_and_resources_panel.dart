import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Inspiração, exaustão, dados de vida e descansos — o "loop de mesa"
/// que faltava na ficha.
class RestAndResourcesPanel extends ConsumerWidget {
  const RestAndResourcesPanel({
    required this.character,
    required this.classes,
    super.key,
  });

  final Character character;
  final List<ClassEntry> classes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pool = HitPointsCalculator.hitDicePool(
      classLevels: character.classLevels,
      classes: classes,
    );
    final totalHitDice = character.classLevels.fold<int>(
      0,
      (sum, item) => sum + item.level,
    );
    final available = totalHitDice - character.hitDiceUsed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recursos e descanso',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              value: character.inspiration,
              onChanged: (_) async {
                await ref.read(toggleInspirationProvider)(character);
              },
              title: const Text('Inspiração'),
              subtitle: const Text(
                'Gaste para rolar com vantagem em um teste.',
              ),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),
            _ExhaustionControl(character: character),

            const Divider(),
            Text(
              'Dados de vida',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Disponíveis: $available de $totalHitDice'
              '${pool.isEmpty ? '' : ' (${pool.map((g) => g.label).join(' + ')})'}',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final group in pool)
                  OutlinedButton(
                    onPressed: available > 0
                        ? () => _spendHitDie(
                              context,
                              ref,
                              group.dieSize,
                              totalHitDice,
                            )
                        : null,
                    child: Text('Gastar 1d${group.dieSize}'),
                  ),
              ],
            ),

            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shortRest(context, ref),
                    icon: const Icon(Icons.local_cafe_outlined),
                    label: const Text('Descanso curto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _longRest(context, ref, totalHitDice),
                    icon: const Icon(Icons.bedtime_outlined),
                    label: const Text('Descanso longo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _spendHitDie(
    BuildContext context,
    WidgetRef ref,
    int dieSize,
    int totalHitDice,
  ) async {
    final rolled = ref.read(diceRollerProvider).rollDie(dieSize);
    final conModifier = character.abilityScores.constitution.abilityModifier;

    await ref.read(spendHitDieProvider)(
      character: character,
      rolled: rolled,
      totalHitDice: totalHitDice,
    );

    if (!context.mounted) return;

    final healed = rolled + conModifier;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Rolou $rolled em 1d$dieSize + ${_signed(conModifier)} de CON: '
          'recuperou ${healed < 1 ? 1 : healed} PV.',
        ),
      ),
    );
  }

  Future<void> _shortRest(BuildContext context, WidgetRef ref) async {
    // Chaves de uso dos slots de pacto (ver SpellSlotsPanel: 100 + nível).
    final pactKeys = <int>[for (var level = 1; level <= 5; level++) 100 + level];

    final summary = await ref.read(shortRestProvider)(
      character: character,
      pactSlotUsageKeys: _hasPactCaster ? pactKeys : const [],
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(summary)));
  }

  Future<void> _longRest(
    BuildContext context,
    WidgetRef ref,
    int totalHitDice,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Descanso longo'),
        content: const Text(
          'Restaura todos os PV, renova os espaços de magia, recupera metade '
          'dos dados de vida e reduz a exaustão em 1 nível. Confirmar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Descansar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final summary = await ref.read(longRestProvider)(
      character: character,
      totalHitDice: totalHitDice,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(summary)));
  }

  bool get _hasPactCaster {
    for (final classLevel in character.classLevels) {
      for (final entry in classes) {
        if (entry.id == classLevel.classId &&
            entry.spellcastingType?.toLowerCase() == 'pact') {
          return true;
        }
      }
    }
    return false;
  }

  String _signed(int value) => value >= 0 ? '+$value' : '$value';
}

class _ExhaustionControl extends ConsumerWidget {
  const _ExhaustionControl({required this.character});

  final Character character;

  /// Efeitos cumulativos por nível (PHB, Apêndice A).
  static const List<String> _effects = [
    'Sem exaustão.',
    'Desvantagem em testes de atributo.',
    'Deslocamento reduzido à metade.',
    'Desvantagem em ataques e salvaguardas.',
    'Pontos de vida máximos reduzidos à metade.',
    'Deslocamento reduzido a zero.',
    'Morte.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = character.exhaustion.clamp(0, 6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exaustão', style: Theme.of(context).textTheme.labelLarge),
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
            Text('$level / 6',
                style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              tooltip: 'Aumentar exaustão',
              onPressed: level < 6
                  ? () => ref.read(setExhaustionProvider)(character, level + 1)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        Text(
          _effects[level],
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
