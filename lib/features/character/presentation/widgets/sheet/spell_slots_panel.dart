import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/spell_slot_calculator.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpellSlotsPanel extends ConsumerWidget {
  const SpellSlotsPanel({
    required this.classLevels,
    required this.characterId,
    super.key,
  });

  final List<ClassLevel> classLevels;
  final String characterId;

  /// Mantido como atalho para quem já chamava por aqui; a conta vive no
  /// [SpellSlotCalculator].
  static int pactUsageKey(int slotLevel) =>
      SpellSlotCalculator.pactUsageKey(slotLevel);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classEntriesProvider);
    final progressionsAsync = ref.watch(spellSlotProgressionsProvider);
    final usedSlotsAsync = ref.watch(characterUsedSpellSlotsProvider(characterId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: classesAsync.when(
          data: (classes) {
            return progressionsAsync.when(
              data: (rows) {
                final result = SpellSlotCalculator.summarize(
                  classLevels: classLevels,
                  classes: classes,
                  progressions: rows,
                );

                return usedSlotsAsync.when(
                  data: (usedSlots) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título fica no cabeçalho da seção, na ficha.
                        if (!result.hasAnyCasting)
                          const Text(
                            'Este personagem não possui progressão de magia cadastrada.',
                          )
                        else ...[
                          if (result.modeLabel != null) ...[
                            Text(
                              result.modeLabel!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                          ],
                          if (result.explanation != null) ...[
                            Text(
                              result.explanation!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (result.standardSlots != null)
                            _SlotsManager(
                              title: 'Slots principais',
                              row: result.standardSlots!,
                              usedSlots: usedSlots,
                              characterId: characterId,
                            ),
                          if (result.pactSlots != null) ...[
                            if (result.standardSlots != null)
                              const SizedBox(height: 16),
                            _PactSlotsManager(
                              row: result.pactSlots!,
                              characterId: characterId,
                              usedSlots: usedSlots,
                            ),
                          ],
                        ],
                      ],
                    );
                  },
                  error: (error, stackTrace) {
                    return Text('Erro ao carregar uso de slots: $error');
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                );
              },
              error: (error, stackTrace) {
                return Text('Erro ao carregar slots de magia: $error');
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            );
          },
          error: (error, stackTrace) {
            return Text('Erro ao carregar classes: $error');
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

}

class _SlotsManager extends ConsumerWidget {
  const _SlotsManager({
    required this.title,
    required this.row,
    required this.usedSlots,
    required this.characterId,
  });

  final String title;
  final SpellSlotProgressionEntry row;
  final Map<int, int> usedSlots;
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleEntries = SpellSlotCalculator.slotsByLevel(row).entries
        .toList();

    if (visibleEntries.isEmpty) {
      return Text('$title: sem slots disponíveis.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...visibleEntries.map((entry) {
          final level = entry.key;
          final max = entry.value;
          // Clamp: slots gastos podem exceder o máximo depois de perder
          // níveis/classes, e o painel mostrava valores negativos.
          final used = (usedSlots[level] ?? 0).clamp(0, max);
          final remaining = max - used;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text('$levelº círculo: $remaining/$max'),
                ),
                IconButton(
                  tooltip: 'Gastar 1 slot',
                  onPressed: remaining > 0
                      ? () async {
                          await ref
                              .read(characterRepositoryProvider)
                              .updateUsedSpellSlot(
                                characterId: characterId,
                                slotLevel: level,
                                used: used + 1,
                              );
                        }
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                IconButton(
                  tooltip: 'Recuperar 1 slot',
                  onPressed: used > 0
                      ? () async {
                          await ref
                              .read(characterRepositoryProvider)
                              .updateUsedSpellSlot(
                                characterId: characterId,
                                slotLevel: level,
                                used: used - 1,
                              );
                        }
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'zero') {
                      await ref
                          .read(characterRepositoryProvider)
                          .updateUsedSpellSlot(
                            characterId: characterId,
                            slotLevel: level,
                            used: 0,
                          );
                    } else if (value == 'full') {
                      await ref
                          .read(characterRepositoryProvider)
                          .updateUsedSpellSlot(
                            characterId: characterId,
                            slotLevel: level,
                            used: max,
                          );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'zero',
                      child: Text('Restaurar tudo'),
                    ),
                    PopupMenuItem(
                      value: 'full',
                      child: Text('Gastar tudo'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _PactSlotsManager extends ConsumerWidget {
  const _PactSlotsManager({
    required this.row,
    required this.characterId,
    required this.usedSlots,
  });

  final SpellSlotProgressionEntry row;
  final String characterId;
  final Map<int, int> usedSlots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotLevel = SpellSlotCalculator.pactSlotLevel(row);
    final pactSlots = SpellSlotCalculator.pactSlotCount(row);
    final usageKey = SpellSlotCalculator.pactUsageKey(slotLevel);
    final used = (usedSlots[usageKey] ?? 0).clamp(0, pactSlots);
    final remaining = pactSlots - used;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Magia de Pacto',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Slots: $remaining/$pactSlots • Nível do slot: $slotLevelº',
              ),
            ),
            IconButton(
              tooltip: 'Gastar 1 slot de pacto',
              onPressed: remaining > 0
                  ? () async {
                      await ref
                          .read(characterRepositoryProvider)
                          .updateUsedSpellSlot(
                            characterId: characterId,
                            slotLevel: usageKey,
                            used: used + 1,
                          );
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            IconButton(
              tooltip: 'Recuperar 1 slot de pacto',
              onPressed: used > 0
                  ? () async {
                      await ref
                          .read(characterRepositoryProvider)
                          .updateUsedSpellSlot(
                            characterId: characterId,
                            slotLevel: usageKey,
                            used: used - 1,
                          );
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}

