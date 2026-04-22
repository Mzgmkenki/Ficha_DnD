import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterSpellsPanel extends ConsumerWidget {
  const CharacterSpellsPanel({
    required this.character,
    super.key,
  });

  final Character character;

  static int pactUsageKey(int slotLevel) => 100 + slotLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spellsAsync = ref.watch(spellEntriesProvider);
    final classesAsync = ref.watch(classEntriesProvider);
    final progressionsAsync = ref.watch(spellSlotProgressionsProvider);
    final usedSlotsAsync =
        ref.watch(characterUsedSpellSlotsProvider(character.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: spellsAsync.when(
          data: (spellEntries) {
            return classesAsync.when(
              data: (classes) {
                return progressionsAsync.when(
                  data: (progressions) {
                    return usedSlotsAsync.when(
                      data: (usedSlots) {
                        if (character.spells.isEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Magias do Personagem',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              const Text('Nenhuma magia vinculada ainda.'),
                            ],
                          );
                        }

                        final slotSummary = _buildSpellcastingSummary(
                          character.classLevels,
                          classes,
                          progressions,
                        );

                        final classSpells = <CharacterSpell>[];
                        final raceSpells = <CharacterSpell>[];
                        final featSpells = <CharacterSpell>[];
                        final itemSpells = <CharacterSpell>[];
                        final customSpells = <CharacterSpell>[];
                        final otherSpells = <CharacterSpell>[];

                        for (final spell in character.spells) {
                          switch (spell.sourceType) {
                            case 'class':
                              classSpells.add(spell);
                              break;
                            case 'race':
                              raceSpells.add(spell);
                              break;
                            case 'feat':
                              featSpells.add(spell);
                              break;
                            case 'item':
                              itemSpells.add(spell);
                              break;
                            case 'custom':
                              customSpells.add(spell);
                              break;
                            default:
                              otherSpells.add(spell);
                              break;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Magias do Personagem',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            if (classSpells.isNotEmpty)
                              _OriginSection(
                                title: 'Magias de Classe',
                                spells: classSpells,
                                spellEntries: spellEntries,
                                character: character,
                                slotSummary: slotSummary,
                                usedSlots: usedSlots,
                              ),
                            if (raceSpells.isNotEmpty)
                              _OriginSection(
                                title: 'Magias Raciais',
                                spells: raceSpells,
                                spellEntries: spellEntries,
                                character: character,
                                slotSummary: slotSummary,
                                usedSlots: usedSlots,
                              ),
                            if (featSpells.isNotEmpty)
                              _OriginSection(
                                title: 'Magias de Talento',
                                spells: featSpells,
                                spellEntries: spellEntries,
                                character: character,
                                slotSummary: slotSummary,
                                usedSlots: usedSlots,
                              ),
                            if (itemSpells.isNotEmpty)
                              _OriginSection(
                                title: 'Magias de Item',
                                spells: itemSpells,
                                spellEntries: spellEntries,
                                character: character,
                                slotSummary: slotSummary,
                                usedSlots: usedSlots,
                              ),
                            if (customSpells.isNotEmpty)
                              _OriginSection(
                                title: 'Origens Customizadas',
                                spells: customSpells,
                                spellEntries: spellEntries,
                                character: character,
                                slotSummary: slotSummary,
                                usedSlots: usedSlots,
                              ),
                            if (otherSpells.isNotEmpty)
                              _OriginSection(
                                title: 'Outras Origens',
                                spells: otherSpells,
                                spellEntries: spellEntries,
                                character: character,
                                slotSummary: slotSummary,
                                usedSlots: usedSlots,
                              ),
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
                    return Text('Erro ao carregar progressão de slots: $error');
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                );
              },
              error: (error, stackTrace) {
                return Text('Erro ao carregar classes: $error');
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            );
          },
          error: (error, stackTrace) {
            return Text('Erro ao carregar magias: $error');
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  _SpellcastingSummaryData _buildSpellcastingSummary(
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

    for (final classLevel in classLevels) {
      final classEntry = classForId(classLevel.classId);
      final type = classEntry?.spellcastingType;

      switch (type) {
        case 'full':
          fullCasterLevels += classLevel.level;
          break;
        case 'half':
          halfCasterLevels += classLevel.level;
          break;
        case 'third':
          thirdCasterLevels += classLevel.level;
          break;
        case 'pact':
          pactLevels += classLevel.level;
          break;
      }
    }

    SpellSlotProgressionEntry? standardSlots;
    SpellSlotProgressionEntry? pactSlots;

    final nonPactCastingPresent =
        fullCasterLevels > 0 || halfCasterLevels > 0 || thirdCasterLevels > 0;

    if (classLevels.length == 1) {
      final classEntry = classForId(classLevels.first.classId);
      final type = classEntry?.spellcastingType;

      if (type == 'full' || type == 'half' || type == 'third') {
        standardSlots = findRow(type!, classLevels.first.level);
      } else if (type == 'pact') {
        pactSlots = findRow('pact', classLevels.first.level);
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
        }
      }

      if (pactLevels > 0) {
        pactSlots = findRow('pact', pactLevels > 20 ? 20 : pactLevels);
      }
    }

    final standardMap = <int, int>{};
    if (standardSlots != null) {
      standardMap.addAll({
        1: standardSlots.first,
        2: standardSlots.second,
        3: standardSlots.third,
        4: standardSlots.fourth,
        5: standardSlots.fifth,
        6: standardSlots.sixth,
        7: standardSlots.seventh,
        8: standardSlots.eighth,
        9: standardSlots.ninth,
      });
    }

    int? pactSlotLevel;
    int? pactSlotCount;
    if (pactSlots != null) {
      pactSlotLevel = pactSlots.pactSlotLevel ?? 1;
      pactSlotCount = pactSlots.first > 0
          ? pactSlots.first
          : pactSlots.second > 0
              ? pactSlots.second
              : pactSlots.third > 0
                  ? pactSlots.third
                  : pactSlots.fourth > 0
                      ? pactSlots.fourth
                      : pactSlots.fifth;
    }

    return _SpellcastingSummaryData(
      standardSlots: standardMap,
      pactSlotLevel: pactSlotLevel,
      pactSlotCount: pactSlotCount,
    );
  }
}

class _OriginSection extends StatelessWidget {
  const _OriginSection({
    required this.title,
    required this.spells,
    required this.spellEntries,
    required this.character,
    required this.slotSummary,
    required this.usedSlots,
  });

  final String title;
  final List<CharacterSpell> spells;
  final List<SpellEntry> spellEntries;
  final Character character;
  final _SpellcastingSummaryData slotSummary;
  final Map<int, int> usedSlots;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<_SpellViewData>>{};

    for (final entry in spells) {
      final spell = spellEntries
          .where((s) => s.id == entry.spellId)
          .cast<SpellEntry?>()
          .firstWhere(
            (s) => s != null,
            orElse: () => null,
          );

      if (spell == null) continue;

      final key = entry.sourceName;

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(
        _SpellViewData(
          spell: spell,
          sourceType: entry.sourceType,
          sourceId: entry.sourceId,
          sourceName: entry.sourceName,
          isPrepared: entry.isPrepared,
          isKnown: entry.isKnown,
          isAlwaysAvailable: entry.isAlwaysAvailable,
        ),
      );
    }

    final sortedKeys = groups.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          ...sortedKeys.map((groupKey) {
            final groupSpells = groups[groupKey]!;
            final byLevel = <int, List<_SpellViewData>>{};

            for (final spell in groupSpells) {
              byLevel.putIfAbsent(spell.spell.level, () => []);
              byLevel[spell.spell.level]!.add(spell);
            }

            final sortedLevels = byLevel.keys.toList()..sort();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupKey,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  ...sortedLevels.map((level) {
                    final spellsAtLevel = byLevel[level]!
                      ..sort((a, b) => a.spell.namePt.compareTo(b.spell.namePt));

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _levelLabel(level),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ...spellsAtLevel.map(
                            (spellData) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          onTap: () =>
                                              showSpellDetailsBottomSheet(
                                            context,
                                            spellData.spell,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                              horizontal: 4,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  spellData.spell.namePt,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _buildSubtitle(spellData),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _CastSpellButton(
                                        character: character,
                                        spellData: spellData,
                                        slotSummary: slotSummary,
                                        usedSlots: usedSlots,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _buildSubtitle(_SpellViewData spellData) {
    final parts = <String>[
      _levelLabel(spellData.spell.level),
      spellData.spell.school,
    ];

    if (spellData.isPrepared) parts.add('Preparada');
    if (spellData.isKnown) parts.add('Conhecida');
    if (spellData.isAlwaysAvailable) parts.add('Sempre disponível');

    return parts.join(' • ');
  }

  String _levelLabel(int level) {
    if (level == 0) return 'Truque';
    return '${level}º círculo';
  }
}

class _CastSpellButton extends ConsumerWidget {
  const _CastSpellButton({
    required this.character,
    required this.spellData,
    required this.slotSummary,
    required this.usedSlots,
  });

  final Character character;
  final _SpellViewData spellData;
  final _SpellcastingSummaryData slotSummary;
  final Map<int, int> usedSlots;

  static int pactUsageKey(int slotLevel) => 100 + slotLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.tonal(
      onPressed: () => _handleCast(context, ref),
      style: FilledButton.styleFrom(
        minimumSize: const Size(92, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: const Text('Conjurar'),
    );
  }

  Future<void> _handleCast(BuildContext context, WidgetRef ref) async {
    if (spellData.sourceType == 'item') {
      await _handleItemCast(context, ref);
      return;
    }

    if (spellData.spell.level == 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${spellData.spell.namePt} conjurada sem gastar slot.',
          ),
        ),
      );
      return;
    }

    final options = _availableCastOptions();
    if (options.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há slots disponíveis para conjurar essa magia.'),
        ),
      );
      return;
    }

    final chosen = await showDialog<_CastOption>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Conjurar ${spellData.spell.namePt}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                title: Text(option.label),
                subtitle: Text(
                  'Restantes: ${option.remaining}/${option.max}',
                ),
                onTap: () => Navigator.of(dialogContext).pop(option),
              );
            }).toList(),
          ),
        );
      },
    );

    if (chosen == null) return;

    final used = usedSlots[chosen.usageKey] ?? 0;

    await ref.read(characterRepositoryProvider).updateUsedSpellSlot(
          characterId: character.id,
          slotLevel: chosen.usageKey,
          used: used + 1,
        );

    ref.invalidate(characterUsedSpellSlotsProvider(character.id));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${spellData.spell.namePt} conjurada usando ${chosen.label.toLowerCase()}.',
        ),
      ),
    );
  }

  Future<void> _handleItemCast(BuildContext context, WidgetRef ref) async {
    final item = _findSourceItem();
    if (item == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item mágico de origem não encontrado.'),
        ),
      );
      return;
    }

    final itemSpell = _findItemSpell(item);
    if (itemSpell == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vínculo da magia com o item não encontrado.'),
        ),
      );
      return;
    }

    if (itemSpell.isAtWill || !itemSpell.usesCharges) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${spellData.spell.namePt} conjurada pelo item ${item.name} sem gastar cargas.',
          ),
        ),
      );
      return;
    }

    final currentCharges = item.charges ?? 0;
    final cost = itemSpell.chargeCost;

    if (currentCharges < cost) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'O item ${item.name} não possui cargas suficientes.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Conjurar ${spellData.spell.namePt}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Origem'),
                subtitle: Text(item.name),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Custo'),
                subtitle: Text('$cost carga(s)'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cargas atuais'),
                subtitle: Text('$currentCharges/${item.maxCharges ?? '-'}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Conjurar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(updateCharacterMagicItemChargesProvider)(
          magicItemId: item.localId,
          charges: currentCharges - cost,
        );

    ref.invalidate(characterByIdProvider(character.id));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${spellData.spell.namePt} conjurada pelo item ${item.name}, consumindo $cost carga(s).',
        ),
      ),
    );
  }

  CharacterMagicItem? _findSourceItem() {
    for (final item in character.magicItems) {
      final itemIdAsString = item.localId.toString();
      if (spellData.sourceId == itemIdAsString ||
          spellData.sourceName == item.name) {
        return item;
      }
    }
    return null;
  }

  CharacterMagicItemSpell? _findItemSpell(CharacterMagicItem item) {
    for (final itemSpell in item.spells) {
      if (itemSpell.spellId == spellData.spell.id) {
        return itemSpell;
      }
    }
    return null;
  }

  List<_CastOption> _availableCastOptions() {
    final options = <_CastOption>[];

    for (var level = spellData.spell.level; level <= 9; level++) {
      final normalMax = slotSummary.standardSlots[level] ?? 0;
      final normalUsed = usedSlots[level] ?? 0;
      final normalRemaining = normalMax - normalUsed;

      if (normalRemaining > 0) {
        options.add(
          _CastOption(
            castLevel: level,
            usageKey: level,
            label: '${level}º círculo — slot normal',
            max: normalMax,
            remaining: normalRemaining,
          ),
        );
      }

      final hasPactAtThisLevel =
          slotSummary.pactSlotLevel != null &&
          slotSummary.pactSlotCount != null &&
          slotSummary.pactSlotLevel == level &&
          slotSummary.pactSlotCount! > 0;

      if (hasPactAtThisLevel) {
        final usageKey = pactUsageKey(level);
        final pactUsed = usedSlots[usageKey] ?? 0;
        final pactMax = slotSummary.pactSlotCount!;
        final pactRemaining = pactMax - pactUsed;

        if (pactRemaining > 0) {
          options.add(
            _CastOption(
              castLevel: level,
              usageKey: usageKey,
              label: '${level}º círculo — slot de pacto',
              max: pactMax,
              remaining: pactRemaining,
            ),
          );
        }
      }
    }

    return options;
  }
}

class _CastOption {
  const _CastOption({
    required this.castLevel,
    required this.usageKey,
    required this.label,
    required this.max,
    required this.remaining,
  });

  final int castLevel;
  final int usageKey;
  final String label;
  final int max;
  final int remaining;
}

class _SpellViewData {
  const _SpellViewData({
    required this.spell,
    required this.sourceType,
    required this.sourceId,
    required this.sourceName,
    required this.isPrepared,
    required this.isKnown,
    required this.isAlwaysAvailable,
  });

  final SpellEntry spell;
  final String sourceType;
  final String sourceId;
  final String sourceName;
  final bool isPrepared;
  final bool isKnown;
  final bool isAlwaysAvailable;
}

class _SpellcastingSummaryData {
  const _SpellcastingSummaryData({
    required this.standardSlots,
    required this.pactSlotLevel,
    required this.pactSlotCount,
  });

  final Map<int, int> standardSlots;
  final int? pactSlotLevel;
  final int? pactSlotCount;
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

void showSpellDetailsBottomSheet(BuildContext context, SpellEntry spell) {
  String levelLabel(int level) {
    if (level == 0) return 'Truque';
    return '${level}º círculo';
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    spell.namePt,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${levelLabel(spell.level)} • ${spell.school}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  _DetailLine(
                    label: 'Tempo de conjuração',
                    value: spell.castingTime,
                  ),
                  _DetailLine(label: 'Alcance', value: spell.range),
                  _DetailLine(label: 'Componentes', value: spell.components),
                  _DetailLine(
                    label: 'Materiais custosos',
                    value: spell.hasCostlyMaterials ? 'Sim' : 'Não',
                  ),
                  _DetailLine(label: 'Duração', value: spell.duration),
                  _DetailLine(
                    label: 'Concentração',
                    value: spell.concentration ? 'Sim' : 'Não',
                  ),
                  _DetailLine(
                    label: 'Ritual',
                    value: spell.ritual ? 'Sim' : 'Não',
                  ),
                  _DetailLine(
                    label: 'Fonte',
                    value: '${spell.source} • p. ${spell.page}',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descrição',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(spell.description),
                  if (spell.upcast != null && spell.upcast!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Conjuração em nível superior',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(spell.upcast!),
                  ],
                ],
              ),
            );
          },
        ),
      );
    },
  );
}