import 'package:dnd_ficha_app/core/routing/app_navigator.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpellCompendiumPage extends ConsumerStatefulWidget {
  const SpellCompendiumPage({super.key});

  @override
  ConsumerState<SpellCompendiumPage> createState() =>
      _SpellCompendiumPageState();
}

class _SpellCompendiumPageState extends ConsumerState<SpellCompendiumPage> {
  final TextEditingController _searchController = TextEditingController();

  String _search = '';
  String _selectedClass = 'all';
  int? _selectedLevel;
  bool _onlyRitual = false;
  bool _onlyConcentration = false;

  static const Map<String, String> _classLabels = {
    'all': 'Todas',
    'artificer': 'Artífice',
    'barbarian': 'Bárbaro',
    'bard': 'Bardo',
    'cleric': 'Clérigo',
    'druid': 'Druida',
    'fighter': 'Guerreiro',
    'monk': 'Monge',
    'paladin': 'Paladino',
    'ranger': 'Patrulheiro',
    'rogue': 'Ladino',
    'sorcerer': 'Feiticeiro',
    'warlock': 'Bruxo',
    'wizard': 'Mago',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spellsAsync = ref.watch(spellEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compêndio de Magias'),
      ),
      body: spellsAsync.when(
        data: (spells) {
          final filtered = _applyFilters(spells);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar magia',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _search = '';
                                  });
                                },
                                icon: const Icon(Icons.clear),
                              ),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _search = value.trim().toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedClass,
                            decoration: const InputDecoration(
                              labelText: 'Classe',
                              border: OutlineInputBorder(),
                            ),
                            items: _classLabels.entries
                                .map(
                                  (entry) => DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedClass = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: _selectedLevel,
                            decoration: const InputDecoration(
                              labelText: 'Nível',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Todos'),
                              ),
                              const DropdownMenuItem<int?>(
                                value: 0,
                                child: Text('Truque'),
                              ),
                              ...List.generate(
                                9,
                                (index) => DropdownMenuItem<int?>(
                                  value: index + 1,
                                  child: Text('${index + 1}º círculo'),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedLevel = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            value: _onlyRitual,
                            onChanged: (value) {
                              setState(() {
                                _onlyRitual = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Só rituais'),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            value: _onlyConcentration,
                            onChanged: (value) {
                              setState(() {
                                _onlyConcentration = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Só concentração'),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('Nenhuma magia encontrada com esses filtros.'),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final spell = filtered[index];

                          return ListTile(
                            title: Text(spell.namePt),
                            subtitle: Text(
                              '${_levelLabel(spell.level)} • ${spell.school}',
                            ),
                            trailing: Wrap(
                              spacing: 6,
                              children: [
                                if (spell.ritual)
                                  const Icon(Icons.menu_book, size: 18),
                                if (spell.concentration)
                                  const Icon(Icons.blur_on, size: 18),
                              ],
                            ),
                            onTap: () {
                              AppNavigator.toSpellDetail(
                                context,
                                spell: spell,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text('Erro ao carregar magias: $error'),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  List<SpellEntry> _applyFilters(List<SpellEntry> spells) {
    return spells.where((spell) {
      if (_search.isNotEmpty) {
        final matchesPt = spell.namePt.toLowerCase().contains(_search);
        final matchesOriginal = spell.nameOriginal.toLowerCase().contains(_search);
        if (!matchesPt && !matchesOriginal) {
          return false;
        }
      }

      if (_selectedClass != 'all' && !spell.classes.contains(_selectedClass)) {
        return false;
      }

      if (_selectedLevel != null && spell.level != _selectedLevel) {
        return false;
      }

      if (_onlyRitual && !spell.ritual) {
        return false;
      }

      if (_onlyConcentration && !spell.concentration) {
        return false;
      }

      return true;
    }).toList(growable: false)
      ..sort((a, b) {
        final levelCompare = a.level.compareTo(b.level);
        if (levelCompare != 0) return levelCompare;
        return a.namePt.compareTo(b.namePt);
      });
  }

  String _levelLabel(int level) {
    if (level == 0) return 'Truque';
    return '$levelº círculo';
  }
}