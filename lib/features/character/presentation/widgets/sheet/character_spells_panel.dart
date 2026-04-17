import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterSpellsPanel extends ConsumerWidget {
  const CharacterSpellsPanel({
    required this.character,
    super.key,
  });

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spellsAsync = ref.watch(spellEntriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: spellsAsync.when(
          data: (spellEntries) {
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

            final alwaysAvailable = <CharacterSpell>[];
            final prepared = <CharacterSpell>[];
            final known = <CharacterSpell>[];
            final others = <CharacterSpell>[];

            for (final spell in character.spells) {
              if (spell.isAlwaysAvailable) {
                alwaysAvailable.add(spell);
              } else if (spell.isPrepared) {
                prepared.add(spell);
              } else if (spell.isKnown) {
                known.add(spell);
              } else {
                others.add(spell);
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
                if (alwaysAvailable.isNotEmpty)
                  _SpellSection(
                    title: 'Magias sempre disponíveis',
                    spells: alwaysAvailable,
                    spellEntries: spellEntries,
                  ),
                if (prepared.isNotEmpty)
                  _SpellSection(
                    title: 'Magias preparadas',
                    spells: prepared,
                    spellEntries: spellEntries,
                  ),
                if (known.isNotEmpty)
                  _SpellSection(
                    title: 'Magias conhecidas',
                    spells: known,
                    spellEntries: spellEntries,
                  ),
                if (others.isNotEmpty)
                  _SpellSection(
                    title: 'Outras magias',
                    spells: others,
                    spellEntries: spellEntries,
                  ),
              ],
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
}

class _SpellSection extends StatelessWidget {
  const _SpellSection({
    required this.title,
    required this.spells,
    required this.spellEntries,
  });

  final String title;
  final List<CharacterSpell> spells;
  final List<SpellEntry> spellEntries;

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

      final spellName = spell?.namePt ?? 'Magia #${entry.spellId}';
      final spellLevel = spell?.level ?? 0;

      final sourceTypeLabel = _translateSourceType(entry.sourceType);
      final key = '${entry.sourceName} ($sourceTypeLabel)';

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(
        _SpellViewData(
          name: spellName,
          level: spellLevel,
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
              byLevel.putIfAbsent(spell.level, () => []);
              byLevel[spell.level]!.add(spell);
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
                    final spellsAtLevel = byLevel[level]!..sort(
                        (a, b) => a.name.compareTo(b.name),
                      );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _levelLabel(level),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          ...spellsAtLevel.map(
                            (spell) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(
                                    child: Text(spell.name),
                                  ),
                                ],
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

  String _translateSourceType(String type) {
    switch (type) {
      case 'class':
        return 'Classe';
      case 'item':
        return 'Item mágico';
      case 'custom':
        return 'Origem customizada';
      default:
        return type;
    }
  }

  String _levelLabel(int level) {
    if (level == 0) {
      return 'Truques';
    }
    return '$levelº círculo';
  }
}

class _SpellViewData {
  const _SpellViewData({
    required this.name,
    required this.level,
  });

  final String name;
  final int level;
}