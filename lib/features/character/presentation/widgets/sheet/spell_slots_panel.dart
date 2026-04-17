import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpellSlotsPanel extends ConsumerWidget {
  const SpellSlotsPanel({
    required this.classLevels,
    super.key,
  });

  final List<ClassLevel> classLevels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classEntriesProvider);
    final progressionsAsync = ref.watch(spellSlotProgressionsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: classesAsync.when(
          data: (classes) {
            return progressionsAsync.when(
              data: (rows) {
                final result = _buildSpellcastingSummary(classLevels, classes, rows);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Slots de Magia',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (!result.hasAnyCasting)
                      const Text('Este personagem não possui progressão de magia cadastrada.')
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
                        _SlotsTable(
                          title: 'Slots principais',
                          row: result.standardSlots!,
                        ),
                      if (result.pactSlots != null) ...[
                        if (result.standardSlots != null) const SizedBox(height: 16),
                        _PactSlotsBlock(row: result.pactSlots!),
                      ],
                    ],
                  ],
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
        modeLabel = 'Progressão de ${classEntry?.name ?? classLevels.first.classId}';
        explanation = 'Tabela usada: ${_tableLabel(type)} • nível de conjuração: ${classLevels.first.level}';
      } else if (type == 'pact') {
        pactSlots = findRow('pact', classLevels.first.level);
        modeLabel = 'Magia de Pacto';
        explanation = 'Bruxo usa progressão própria de slots de pacto.';
      }
    } else {
      if (nonPactCastingPresent) {
        final effectiveCasterLevel =
            fullCasterLevels + (halfCasterLevels ~/ 2) + (thirdCasterLevels ~/ 3);

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
        explanation = '${explanation ?? ''} '
            'Magia de Pacto permanece separada dos slots normais.';
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

class _SlotsTable extends StatelessWidget {
  const _SlotsTable({
    required this.title,
    required this.row,
  });

  final String title;
  final SpellSlotProgressionEntry row;

  @override
  Widget build(BuildContext context) {
    final entries = <String, int>{
      '1º': row.first,
      '2º': row.second,
      '3º': row.third,
      '4º': row.fourth,
      '5º': row.fifth,
      '6º': row.sixth,
      '7º': row.seventh,
      '8º': row.eighth,
      '9º': row.ninth,
    };

    final visibleEntries = entries.entries.where((e) => e.value > 0).toList();

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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: visibleEntries
              .map((entry) => Chip(label: Text('${entry.key}: ${entry.value}')))
              .toList(),
        ),
      ],
    );
  }
}

class _PactSlotsBlock extends StatelessWidget {
  const _PactSlotsBlock({
    required this.row,
  });

  final SpellSlotProgressionEntry row;

  @override
  Widget build(BuildContext context) {
    final pactSlots = row.first > 0
        ? row.first
        : row.second > 0
            ? row.second
            : row.third > 0
                ? row.third
                : row.fourth > 0
                    ? row.fourth
                    : row.fifth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Magia de Pacto',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Slots: $pactSlots • Nível do slot: ${row.pactSlotLevel ?? 1}º',
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