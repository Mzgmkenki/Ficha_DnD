import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
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

  static int pactUsageKey(int slotLevel) => 100 + slotLevel;

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
                final result =
                    _buildSpellcastingSummary(classLevels, classes, rows);

                return usedSlotsAsync.when(
                  data: (usedSlots) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Slots de Magia',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
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

  _SpellcastingSummary _buildSpellcastingSummary(
    List<ClassLevel> classLevels,
    List<ClassEntry> classes,
    List<SpellSlotProgressionEntry> rows,
  ) {
    ClassEntry? classForId(String id) {
      for (final item in classes) {
        if (item.id == id) return item;
      }
      return null;
    }

    SpellSlotProgressionEntry? findRow(String tableId, int level) {
      for (final row in rows) {
        if (row.tableId == tableId && row.level == level) {
          return row;
        }
      }
      return null;
    }

    int fullCasterLevels = 0;
    int halfCasterLevels = 0;
    int thirdCasterLevels = 0;
    int pactLevels = 0;
    int spellcastingClassCount = 0;

    for (final classLevel in classLevels) {
      final classEntry = classForId(classLevel.classId);
      final type = classEntry?.spellcastingType;

      switch (type) {
        case 'full':
          fullCasterLevels += classLevel.level;
          spellcastingClassCount++;
          break;
        case 'half':
          halfCasterLevels += classLevel.level;
          spellcastingClassCount++;
          break;
        case 'third':
          thirdCasterLevels += classLevel.level;
          spellcastingClassCount++;
          break;
        case 'pact':
          pactLevels += classLevel.level;
          spellcastingClassCount++;
          break;
      }
    }

    final hasAnyCasting = spellcastingClassCount > 0;
    if (!hasAnyCasting) {
      return const _SpellcastingSummary(
        hasAnyCasting: false,
        standardSlots: null,
        pactSlots: null,
        modeLabel: null,
        explanation: null,
      );
    }

    SpellSlotProgressionEntry? standardSlots;
    SpellSlotProgressionEntry? pactSlots;
    String? modeLabel;
    String? explanation;

    final nonPactCastingPresent =
        fullCasterLevels > 0 || halfCasterLevels > 0 || thirdCasterLevels > 0;

    if (classLevels.length == 1) {
      final classEntry = classForId(classLevels.first.classId);
      final type = classEntry?.spellcastingType;

      if (type == 'full' || type == 'half' || type == 'third') {
        standardSlots = findRow(type!, classLevels.first.level);
        modeLabel =
            'Progressão de ${classEntry?.name ?? classLevels.first.classId}';
        explanation =
            'Tabela usada: ${_tableLabel(type)} • nível de conjuração: ${classLevels.first.level}';
      } else if (type == 'pact') {
        pactSlots = findRow('pact', classLevels.first.level);
        modeLabel = 'Magia de Pacto';
        explanation = 'Bruxo usa progressão própria de slots de pacto.';
      }
    } else {
      if (nonPactCastingPresent) {
        final effectiveCasterLevel =
            fullCasterLevels +
            (halfCasterLevels ~/ 2) +
            (thirdCasterLevels ~/ 3);

        if (effectiveCasterLevel > 0) {
          standardSlots = findRow(
            'multiclass',
            effectiveCasterLevel > 20 ? 20 : effectiveCasterLevel,
          );
          modeLabel = 'Progressão multiclasses de conjuração';
          explanation =
              'Nível efetivo de conjuração: $effectiveCasterLevel '
              '(inteiros = $fullCasterLevels, meio = ${halfCasterLevels ~/ 2}, um-terço = ${thirdCasterLevels ~/ 3}).';
        }
      }

      if (pactLevels > 0) {
        pactSlots = findRow('pact', pactLevels > 20 ? 20 : pactLevels);
      }

      if (pactLevels > 0 && nonPactCastingPresent) {
        explanation =
            '${explanation ?? ''} Magia de Pacto permanece separada dos slots normais.';
      } else if (pactLevels > 0 && !nonPactCastingPresent) {
        modeLabel = 'Magia de Pacto';
        explanation = 'Bruxo usa progressão própria de slots de pacto.';
      }
    }

    return _SpellcastingSummary(
      hasAnyCasting: true,
      standardSlots: standardSlots,
      pactSlots: pactSlots,
      modeLabel: modeLabel,
      explanation: explanation,
    );
  }

  String _tableLabel(String type) {
    switch (type) {
      case 'full':
        return 'conjurador completo';
      case 'half':
        return 'meio conjurador';
      case 'third':
        return 'um-terço conjurador';
      case 'pact':
        return 'magia de pacto';
      default:
        return type;
    }
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
    final entries = <int, int>{
      1: row.first,
      2: row.second,
      3: row.third,
      4: row.fourth,
      5: row.fifth,
      6: row.sixth,
      7: row.seventh,
      8: row.eighth,
      9: row.ninth,
    };

    final visibleEntries =
        entries.entries.where((entry) => entry.value > 0).toList();

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
          final used = usedSlots[level] ?? 0;
          final remaining = max - used;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text('${level}º círculo: $remaining/$max'),
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
                          ref.invalidate(
                            characterUsedSpellSlotsProvider(characterId),
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
                          ref.invalidate(
                            characterUsedSpellSlotsProvider(characterId),
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

                    ref.invalidate(characterUsedSpellSlotsProvider(characterId));
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

  static int pactUsageKey(int slotLevel) => 100 + slotLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotLevel = row.pactSlotLevel ?? 1;
    final pactSlots = row.first > 0
        ? row.first
        : row.second > 0
            ? row.second
            : row.third > 0
                ? row.third
                : row.fourth > 0
                    ? row.fourth
                    : row.fifth;

    final usageKey = pactUsageKey(slotLevel);
    final used = usedSlots[usageKey] ?? 0;
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
                'Slots: $remaining/$pactSlots • Nível do slot: ${slotLevel}º',
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
                      ref.invalidate(
                        characterUsedSpellSlotsProvider(characterId),
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
                      ref.invalidate(
                        characterUsedSpellSlotsProvider(characterId),
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

class _SpellcastingSummary {
  const _SpellcastingSummary({
    required this.hasAnyCasting,
    required this.standardSlots,
    required this.pactSlots,
    required this.modeLabel,
    required this.explanation,
  });

  final bool hasAnyCasting;
  final SpellSlotProgressionEntry? standardSlots;
  final SpellSlotProgressionEntry? pactSlots;
  final String? modeLabel;
  final String? explanation;
}