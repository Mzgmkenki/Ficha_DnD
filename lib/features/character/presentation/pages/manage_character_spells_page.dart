import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/character_spells_panel.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageCharacterSpellsPage extends ConsumerStatefulWidget {
  const ManageCharacterSpellsPage({
    required this.characterId,
    super.key,
  });

  final String characterId;

  @override
  ConsumerState<ManageCharacterSpellsPage> createState() =>
      _ManageCharacterSpellsPageState();
}

class _ManageCharacterSpellsPageState
    extends ConsumerState<ManageCharacterSpellsPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customSourceNameController =
      TextEditingController();
  final TextEditingController _itemSourceNameController =
      TextEditingController();
  final TextEditingController _raceSourceNameController =
      TextEditingController();
  final TextEditingController _featSourceNameController =
      TextEditingController();

  String _search = '';
  String _selectedSourceType = 'class';
  String? _selectedClassSourceId;
  int? _selectedSpellLevel;
  bool _isPrepared = false;
  bool _isKnown = true;
  bool _isAlwaysAvailable = false;

  @override
  void dispose() {
    _searchController.dispose();
    _customSourceNameController.dispose();
    _itemSourceNameController.dispose();
    _raceSourceNameController.dispose();
    _featSourceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterAsync = ref.watch(characterByIdProvider(widget.characterId));
    final spellsAsync = ref.watch(spellEntriesProvider);
    final classesAsync = ref.watch(classEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar magias'),
      ),
      body: characterAsync.when(
        data: (character) {
          if (character == null) {
            return const Center(child: Text('Personagem não encontrado.'));
          }

          return classesAsync.when(
            data: (classes) {
              return spellsAsync.when(
                data: (spells) {
                  _selectedClassSourceId ??= character.classLevels.isNotEmpty
                      ? character.classLevels.first.classId
                      : (classes.isNotEmpty ? classes.first.id : null);

                  final filteredSpells = _applySpellFilters(spells);
                  final classLimit = _selectedSourceType == 'class'
                      ? _buildClassLimitInfo(character, classes, spells)
                      : null;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildCurrentSpellsCard(context, ref, character, spells),
                      const SizedBox(height: 16),
                      _buildAddSpellCard(
                        context: context,
                        ref: ref,
                        character: character,
                        classes: classes,
                        spells: filteredSpells,
                        classLimit: classLimit,
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
              );
            },
            error: (error, stackTrace) {
              return Center(
                child: Text('Erro ao carregar classes: $error'),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text('Erro ao carregar personagem: $error'),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildCurrentSpellsCard(
    BuildContext context,
    WidgetRef ref,
    Character character,
    List<SpellEntry> allSpells,
  ) {
    final grouped = <String, List<CharacterSpell>>{};

    for (final item in character.spells) {
      final key = '${item.sourceName} (${_sourceTypeLabel(item.sourceType)})';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Magias atuais',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (character.spells.isEmpty)
              const Text('Nenhuma magia adicionada ainda.')
            else
              ...grouped.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key} (${entry.value.length})',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ...entry.value.map((characterSpell) {
                        final spell = allSpells
                            .where((s) => s.id == characterSpell.spellId)
                            .cast<SpellEntry?>()
                            .firstWhere(
                              (item) => item != null,
                              orElse: () => null,
                            );

                        final spellName =
                            spell?.namePt ?? 'Magia #${characterSpell.spellId}';

                        final tags = <String>[];
                        if (characterSpell.isKnown) tags.add('Conhecida');
                        if (characterSpell.isPrepared) tags.add('Preparada');
                        if (characterSpell.isAlwaysAvailable) {
                          tags.add('Sempre disponível');
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.4),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              title: InkWell(
                                onTap: spell == null
                                    ? null
                                    : () => showSpellDetailsBottomSheet(
                                          context,
                                          spell,
                                        ),
                                child: Text(
                                  spellName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: spell == null
                                        ? TextDecoration.none
                                        : TextDecoration.underline,
                                  ),
                                ),
                              ),
                              subtitle: tags.isEmpty
                                  ? null
                                  : Text(tags.join(' • ')),
                              trailing: IconButton(
                                tooltip: 'Remover magia',
                                onPressed: () async {
                                  try {
                                    final removeSpell =
                                        ref.read(removeCharacterSpellProvider);

                                    await removeSpell(
                                      characterId: character.id,
                                      spellId: characterSpell.spellId,
                                      sourceType: characterSpell.sourceType,
                                      sourceId: characterSpell.sourceId,
                                    );

                                    ref.invalidate(
                                      characterByIdProvider(character.id),
                                    );

                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Magia removida: $spellName'),
                                      ),
                                    );
                                  } catch (error) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erro ao remover magia: $error',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSpellCard({
    required BuildContext context,
    required WidgetRef ref,
    required Character character,
    required List<ClassEntry> classes,
    required List<SpellEntry> spells,
    required _ClassLimitInfo? classLimit,
  }) {
    final groupedSpells = _groupSpellsByLevel(spells);
    final sortedLevels = groupedSpells.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adicionar magia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final useColumn = constraints.maxWidth < 560;

                final sourceField = DropdownButtonFormField<String>(
                  initialValue: _selectedSourceType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de origem',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'class',
                      child: Text('Classe'),
                    ),
                    DropdownMenuItem(
                      value: 'item',
                      child: Text('Item mágico'),
                    ),
                    DropdownMenuItem(
                      value: 'race',
                      child: Text('Raça'),
                    ),
                    DropdownMenuItem(
                      value: 'feat',
                      child: Text('Talento'),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text('Origem customizada'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedSourceType = value;
                    });
                  },
                );

                final levelField = DropdownButtonFormField<int?>(
                  initialValue: _selectedSpellLevel,
                  decoration: const InputDecoration(
                    labelText: 'Nível da magia',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 0,
                      child: Text('Truque'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 1,
                      child: Text('1º círculo'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 2,
                      child: Text('2º círculo'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 3,
                      child: Text('3º círculo'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 4,
                      child: Text('4º círculo'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 5,
                      child: Text('5º círculo'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 6,
                      child: Text('6º círculo'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 7,
                      child: Text('7º círculo'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 8,
                      child: Text('8º círculo'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 9,
                      child: Text('9º círculo'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSpellLevel = value;
                    });
                  },
                );

                if (useColumn) {
                  return Column(
                    children: [
                      sourceField,
                      const SizedBox(height: 12),
                      levelField,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: sourceField),
                    const SizedBox(width: 12),
                    Expanded(child: levelField),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            if (_selectedSourceType == 'class')
              DropdownButtonFormField<String>(
                initialValue: _selectedClassSourceId,
                decoration: const InputDecoration(
                  labelText: 'Classe de origem',
                  border: OutlineInputBorder(),
                ),
                items: classes
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClassSourceId = value;
                  });
                },
              ),
            if (_selectedSourceType == 'item')
              TextField(
                controller: _itemSourceNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do item mágico',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_selectedSourceType == 'race')
              TextField(
                controller: _raceSourceNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da raça',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_selectedSourceType == 'feat')
              TextField(
                controller: _featSourceNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do talento',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_selectedSourceType == 'custom')
              TextField(
                controller: _customSourceNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da origem customizada',
                  border: OutlineInputBorder(),
                ),
              ),
            if (classLimit != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classLimit.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(classLimit.summary),
                    if (classLimit.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        classLimit.note!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Conhecida'),
              value: _isKnown,
              onChanged: (value) {
                setState(() {
                  _isKnown = value ?? true;
                });
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Preparada'),
              value: _isPrepared,
              onChanged: (value) {
                setState(() {
                  _isPrepared = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sempre disponível'),
              value: _isAlwaysAvailable,
              onChanged: (value) {
                setState(() {
                  _isAlwaysAvailable = value ?? false;
                });
              },
            ),
            const SizedBox(height: 8),
            if (spells.isEmpty)
              const Text('Nenhuma magia encontrada com os filtros atuais.')
            else
              SizedBox(
                height: 420,
                child: ListView(
                  children: [
                    ...sortedLevels.map((level) {
                      final levelSpells = groupedSpells[level]!
                        ..sort((a, b) => a.namePt.compareTo(b.namePt));

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_levelLabel(level)} (${levelSpells.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            ...levelSpells.map(
                              (spell) => Padding(
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
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    title: InkWell(
                                      onTap: () =>
                                          showSpellDetailsBottomSheet(
                                        context,
                                        spell,
                                      ),
                                      child: Text(
                                        spell.namePt,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${_levelLabel(spell.level)} • ${spell.school}',
                                      ),
                                    ),
                                    trailing: IconButton(
                                      tooltip: 'Adicionar magia',
                                      onPressed: () async {
                                        final sourceData =
                                            _buildSourceData(classes);
                                        if (sourceData == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Preencha a origem da magia.',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final alreadyExists =
                                            character.spells.any(
                                          (item) =>
                                              item.spellId == spell.id &&
                                              item.sourceType ==
                                                  sourceData.type &&
                                              item.sourceId ==
                                                  sourceData.id,
                                        );

                                        if (alreadyExists) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Essa magia já foi adicionada nessa origem.',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        if (classLimit != null) {
                                          final blockReason =
                                              _validateAgainstClassLimit(
                                            classLimit: classLimit,
                                            spell: spell,
                                          );
                                          if (blockReason != null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(blockReason),
                                              ),
                                            );
                                            return;
                                          }
                                        }

                                        try {
                                          final addSpell = ref.read(
                                            addCharacterSpellProvider,
                                          );

                                          await addSpell(
                                            characterId: character.id,
                                            spell: CharacterSpell(
                                              spellId: spell.id,
                                              sourceType: sourceData.type,
                                              sourceId: sourceData.id,
                                              sourceName: sourceData.name,
                                              isPrepared: _isPrepared,
                                              isKnown: _isKnown,
                                              isAlwaysAvailable:
                                                  _isAlwaysAvailable,
                                            ),
                                          );

                                          ref.invalidate(
                                            characterByIdProvider(
                                              character.id,
                                            ),
                                          );

                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Magia adicionada: ${spell.namePt}',
                                              ),
                                            ),
                                          );
                                        } catch (error) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Erro ao adicionar magia: $error',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
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
              ),
          ],
        ),
      ),
    );
  }

  String? _validateAgainstClassLimit({
    required _ClassLimitInfo classLimit,
    required SpellEntry spell,
  }) {
    if (spell.level == 0) {
      return null;
    }

    if (classLimit.mode == _ClassLimitMode.known && _isKnown) {
      if (classLimit.current >= classLimit.limit) {
        return 'Limite de magias conhecidas dessa classe atingido.';
      }
    }

    if (classLimit.mode == _ClassLimitMode.prepared && _isPrepared) {
      if (classLimit.current >= classLimit.limit) {
        return 'Limite de magias preparadas dessa classe atingido.';
      }
    }

    return null;
  }

  Map<int, List<SpellEntry>> _groupSpellsByLevel(List<SpellEntry> spells) {
    final grouped = <int, List<SpellEntry>>{};

    for (final spell in spells) {
      grouped.putIfAbsent(spell.level, () => []);
      grouped[spell.level]!.add(spell);
    }

    return grouped;
  }

  List<SpellEntry> _applySpellFilters(List<SpellEntry> spells) {
    return spells.where((spell) {
      if (_search.isNotEmpty) {
        final matchPt = spell.namePt.toLowerCase().contains(_search);
        final matchOriginal =
            spell.nameOriginal.toLowerCase().contains(_search);
        if (!matchPt && !matchOriginal) {
          return false;
        }
      }

      if (_selectedSpellLevel != null && spell.level != _selectedSpellLevel) {
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

  _SourceData? _buildSourceData(List<ClassEntry> classes) {
    switch (_selectedSourceType) {
      case 'class':
        if (_selectedClassSourceId == null) return null;

        final classEntry = classes
            .where((item) => item.id == _selectedClassSourceId)
            .cast<ClassEntry?>()
            .firstWhere(
              (item) => item != null,
              orElse: () => null,
            );

        return _SourceData(
          type: 'class',
          id: _selectedClassSourceId!,
          name: classEntry?.name ?? _selectedClassSourceId!,
        );

      case 'item':
        final name = _itemSourceNameController.text.trim();
        if (name.isEmpty) return null;
        return _SourceData(
          type: 'item',
          id: _slugify(name),
          name: name,
        );

      case 'race':
        final name = _raceSourceNameController.text.trim();
        if (name.isEmpty) return null;
        return _SourceData(
          type: 'race',
          id: _slugify(name),
          name: name,
        );

      case 'feat':
        final name = _featSourceNameController.text.trim();
        if (name.isEmpty) return null;
        return _SourceData(
          type: 'feat',
          id: _slugify(name),
          name: name,
        );

      case 'custom':
        final name = _customSourceNameController.text.trim();
        if (name.isEmpty) return null;
        return _SourceData(
          type: 'custom',
          id: _slugify(name),
          name: name,
        );

      default:
        return null;
    }
  }

  _ClassLimitInfo? _buildClassLimitInfo(
    Character character,
    List<ClassEntry> classes,
    List<SpellEntry> allSpells,
  ) {
    if (_selectedClassSourceId == null) return null;

    final classId = _selectedClassSourceId!;
    final classEntry = classes
        .where((item) => item.id == classId)
        .cast<ClassEntry?>()
        .firstWhere(
          (item) => item != null,
          orElse: () => null,
        );

    final className = classEntry?.name ?? classId;
    final classLevel = character.classLevels
        .where((item) => item.classId == classId)
        .cast<dynamic>()
        .firstWhere(
          (item) => item != null,
          orElse: () => null,
        );

    final level = classLevel?.level as int?;
    if (level == null) return null;

    final classSpells = character.spells.where((spell) {
      return spell.sourceType == 'class' &&
          spell.sourceId == classId;
    }).toList(growable: false);

    int countKnownLevel1Plus() {
      return classSpells.where((spell) {
        if (!spell.isKnown) return false;
        final entry = allSpells
            .where((s) => s.id == spell.spellId)
            .cast<SpellEntry?>()
            .firstWhere(
              (s) => s != null,
              orElse: () => null,
            );
        return (entry?.level ?? 0) > 0;
      }).length;
    }

    int countPreparedLevel1Plus() {
      return classSpells.where((spell) {
        if (!spell.isPrepared) return false;
        final entry = allSpells
            .where((s) => s.id == spell.spellId)
            .cast<SpellEntry?>()
            .firstWhere(
              (s) => s != null,
              orElse: () => null,
            );
        return (entry?.level ?? 0) > 0;
      }).length;
    }

    int abilityModifier(String abilityName) {
      switch (abilityName) {
        case 'wisdom':
          return ((character.abilityScores.wisdom - 10) / 2).floor();
        case 'charisma':
          return ((character.abilityScores.charisma - 10) / 2).floor();
        case 'intelligence':
          return ((character.abilityScores.intelligence - 10) / 2).floor();
        default:
          return 0;
      }
    }

    final key = classId.trim().toLowerCase();

    switch (key) {
      case 'cleric':
      case 'clérigo':
        final limit = (abilityModifier('wisdom') + level).clamp(1, 999);
        return _ClassLimitInfo(
          mode: _ClassLimitMode.prepared,
          title: className,
          summary:
              'Magias preparadas dessa classe: ${countPreparedLevel1Plus()}/$limit',
          current: countPreparedLevel1Plus(),
          limit: limit,
          note: 'Truques não entram nesse limite.',
        );

      case 'druid':
      case 'druida':
        final limit = (abilityModifier('wisdom') + level).clamp(1, 999);
        return _ClassLimitInfo(
          mode: _ClassLimitMode.prepared,
          title: className,
          summary:
              'Magias preparadas dessa classe: ${countPreparedLevel1Plus()}/$limit',
          current: countPreparedLevel1Plus(),
          limit: limit,
          note: 'Truques não entram nesse limite.',
        );

      case 'paladin':
      case 'paladino':
        if (level < 2) {
          return _ClassLimitInfo(
            mode: _ClassLimitMode.prepared,
            title: className,
            summary: 'Essa classe ainda não possui magia nesse nível.',
            current: 0,
            limit: 0,
            note: null,
          );
        }
        final limit =
            (abilityModifier('charisma') + (level ~/ 2)).clamp(1, 999);
        return _ClassLimitInfo(
          mode: _ClassLimitMode.prepared,
          title: className,
          summary:
              'Magias preparadas dessa classe: ${countPreparedLevel1Plus()}/$limit',
          current: countPreparedLevel1Plus(),
          limit: limit,
          note: 'Truques não entram nesse limite.',
        );

      case 'wizard':
      case 'mago':
        final limit =
            (abilityModifier('intelligence') + level).clamp(1, 999);
        return _ClassLimitInfo(
          mode: _ClassLimitMode.prepared,
          title: className,
          summary:
              'Magias preparadas dessa classe: ${countPreparedLevel1Plus()}/$limit',
          current: countPreparedLevel1Plus(),
          limit: limit,
          note:
              'Truques não entram nesse limite.',
        );

      case 'bard':
      case 'bardo':
        final limit = _bardKnownLimit(level);
        return _ClassLimitInfo(
          mode: _ClassLimitMode.known,
          title: className,
          summary:
              'Magias conhecidas dessa classe: ${countKnownLevel1Plus()}/$limit',
          current: countKnownLevel1Plus(),
          limit: limit,
          note: 'Truques não entram nesse limite.',
        );

      case 'sorcerer':
      case 'feiticeiro':
        final limit = _sorcererKnownLimit(level);
        return _ClassLimitInfo(
          mode: _ClassLimitMode.known,
          title: className,
          summary:
              'Magias conhecidas dessa classe: ${countKnownLevel1Plus()}/$limit',
          current: countKnownLevel1Plus(),
          limit: limit,
          note: 'Truques não entram nesse limite.',
        );

      case 'warlock':
      case 'bruxo':
        final limit = _warlockKnownLimit(level);
        return _ClassLimitInfo(
          mode: _ClassLimitMode.known,
          title: className,
          summary:
              'Magias conhecidas dessa classe: ${countKnownLevel1Plus()}/$limit',
          current: countKnownLevel1Plus(),
          limit: limit,
          note: 'Truques não entram nesse limite.',
        );

      case 'ranger':
      case 'patrulheiro':
        if (level < 2) {
          return _ClassLimitInfo(
            mode: _ClassLimitMode.known,
            title: className,
            summary: 'Essa classe ainda não possui magia nesse nível.',
            current: 0,
            limit: 0,
            note: null,
          );
        }
        final limit = _rangerKnownLimit(level);
        return _ClassLimitInfo(
          mode: _ClassLimitMode.known,
          title: className,
          summary:
              'Magias conhecidas dessa classe: ${countKnownLevel1Plus()}/$limit',
          current: countKnownLevel1Plus(),
          limit: limit,
          note: 'Truques não entram nesse limite.',
        );

      default:
        return null;
    }
  }

  int _bardKnownLimit(int level) {
    const table = {
      1: 4,
      2: 5,
      3: 6,
      4: 7,
      5: 8,
      6: 9,
      7: 10,
      8: 11,
      9: 12,
      10: 14,
      11: 15,
      12: 15,
      13: 16,
      14: 18,
      15: 19,
      16: 19,
      17: 20,
      18: 22,
      19: 22,
      20: 22,
    };
    return table[level] ?? 0;
  }

  int _sorcererKnownLimit(int level) {
    const table = {
      1: 2,
      2: 3,
      3: 4,
      4: 5,
      5: 6,
      6: 7,
      7: 8,
      8: 9,
      9: 10,
      10: 11,
      11: 12,
      12: 12,
      13: 13,
      14: 13,
      15: 14,
      16: 14,
      17: 15,
      18: 15,
      19: 15,
      20: 15,
    };
    return table[level] ?? 0;
  }

  int _warlockKnownLimit(int level) {
    const table = {
      1: 2,
      2: 3,
      3: 4,
      4: 5,
      5: 6,
      6: 7,
      7: 8,
      8: 9,
      9: 10,
      10: 10,
      11: 11,
      12: 11,
      13: 12,
      14: 12,
      15: 13,
      16: 13,
      17: 14,
      18: 14,
      19: 15,
      20: 15,
    };
    return table[level] ?? 0;
  }

  int _rangerKnownLimit(int level) {
    const table = {
      2: 2,
      3: 3,
      4: 3,
      5: 4,
      6: 4,
      7: 5,
      8: 5,
      9: 6,
      10: 6,
      11: 7,
      12: 7,
      13: 8,
      14: 8,
      15: 9,
      16: 9,
      17: 10,
      18: 10,
      19: 11,
      20: 11,
    };
    return table[level] ?? 0;
  }

  String _slugify(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  String _sourceTypeLabel(String value) {
    switch (value) {
      case 'class':
        return 'classe';
      case 'item':
        return 'item';
      case 'race':
        return 'raça';
      case 'feat':
        return 'talento';
      case 'custom':
        return 'custom';
      default:
        return value;
    }
  }

  String _levelLabel(int level) {
    if (level == 0) return 'Truque';
    return '${level}º círculo';
  }
}

enum _ClassLimitMode {
  known,
  prepared,
}

class _ClassLimitInfo {
  const _ClassLimitInfo({
    required this.mode,
    required this.title,
    required this.summary,
    required this.current,
    required this.limit,
    required this.note,
  });

  final _ClassLimitMode mode;
  final String title;
  final String summary;
  final int current;
  final int limit;
  final String? note;
}

class _SourceData {
  const _SourceData({
    required this.type,
    required this.id,
    required this.name,
  });

  final String type;
  final String id;
  final String name;
}