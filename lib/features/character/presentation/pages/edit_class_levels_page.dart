import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/subclass_choice.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/spellcasting_type.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/subclass_choice_dialog.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/subclass_summary.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditClassLevelsPage extends ConsumerStatefulWidget {
  const EditClassLevelsPage({
    required this.characterId,
    required this.initialClassLevels,
    required this.abilityScores,
    super.key,
  });

  final String characterId;
  final List<ClassLevel> initialClassLevels;
  final AbilityScores abilityScores;

  @override
  ConsumerState<EditClassLevelsPage> createState() =>
      _EditClassLevelsPageState();
}

class _EditClassLevelsPageState extends ConsumerState<EditClassLevelsPage> {
  late List<ClassLevel> _classLevels;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _classLevels = widget.initialClassLevels
        .map(
          (item) => ClassLevel(
            classId: item.classId,
            subclassId: item.subclassId,
            level: item.level,
            spellcastingAbility: item.spellcastingAbility,
            spellcastingType: item.spellcastingType,
          ),
        )
        .toList();
  }

  int get _totalLevel {
    return _classLevels.fold(0, (sum, item) => sum + item.level);
  }

  bool get _isMulticlass => _classLevels.length > 1;

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classEntriesProvider);

    // Tolerante ao carregamento: sem as subclasses o resto da tela funciona.
    final subclasses =
        ref.watch(subclassEntriesProvider).value ?? const <SubclassEntry>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Editar multiclasse')),
      body: classesAsync.when(
        data: (classes) {
          return ListView(
            padding: context.scrollContentPadding(),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nível total atual: $_totalLevel / 20',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'A primeira classe da lista é tratada como classe primária e não exige pré-requisito. '
                    'Os pré-requisitos se aplicam apenas às classes adicionadas depois.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ..._classLevels.asMap().entries.map((entry) {
                final index = entry.key;
                final classLevel = entry.value;
                final isPrimary = index == 0;
                final className = _classNameForId(classes, classLevel.classId);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isPrimary
                                    ? '$className (Primária)'
                                    : className,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (_classLevels.length > 1 && !isPrimary)
                              IconButton(
                                tooltip: 'Remover classe',
                                onPressed: () {
                                  setState(() {
                                    _classLevels.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.delete_outline),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              onPressed: classLevel.level > 1
                                  ? () => _changeLevel(
                                        index,
                                        classLevel.level - 1,
                                        classes,
                                      )
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Nível ${classLevel.level}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  (_totalLevel < 20 && classLevel.level < 20)
                                      ? () => _changeLevel(
                                            index,
                                            classLevel.level + 1,
                                            classes,
                                          )
                                      : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        ..._buildSubclassPicker(
                          index: index,
                          classLevel: classLevel,
                          classEntry: _classEntryForId(
                            classes,
                            classLevel.classId,
                          ),
                          options: subclasses
                              .where(
                                (item) => item.classId == classLevel.classId,
                              )
                              .toList(growable: false),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _totalLevel < 20
                    ? () => _showAddClassDialog(context, classes)
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar classe'),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Salvando...' : 'Salvar'),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return Center(child: Text('Erro ao carregar classes: $error'));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _showAddClassDialog(
    BuildContext context,
    List<ClassEntry> classes,
  ) async {
    final usedClassIds = _classLevels.map((e) => e.classId).toSet();
    final availableClasses =
        classes.where((item) => !usedClassIds.contains(item.id)).toList();

    if (availableClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as classes disponíveis já foram adicionadas.'),
        ),
      );
      return;
    }

    // Guarda a própria entrada em vez do id: antes o diálogo reencontrava a
    // classe com `firstWhere` sem `orElse`, inclusive depois do await, o que
    // seria um StateError não tratado se a lista mudasse.
    ClassEntry selectedClass = availableClasses.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final missingForNewClass =
                _missingPrerequisitesForClass(selectedClass.id);

            return AlertDialog(
              title: const Text('Adicionar classe'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ClassEntry>(
                    initialValue: selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'Classe',
                      border: OutlineInputBorder(),
                    ),
                    items: availableClasses
                        .map(
                          (item) => DropdownMenuItem<ClassEntry>(
                            value: item,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedClass = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pré-requisito: ${_requirementTextForClassId(selectedClass.id)}',
                    ),
                  ),
                  if (missingForNewClass != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Falta para a nova classe: $missingForNewClass',
                        style: TextStyle(
                          color: Theme.of(dialogContext).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final missingForNewClass = _missingPrerequisitesForClass(selectedClass.id);
    if (missingForNewClass != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Você não cumpre o pré-requisito para ${selectedClass.name}: $missingForNewClass',
          ),
        ),
      );
      return;
    }

    setState(() {
      _classLevels.add(
        ClassLevel(
          classId: selectedClass.id,
          level: 1,
          // Usa o atributo de conjuração declarado, não o primário
          // (Patrulheiro conjura com Sabedoria, mas tem Destreza primária).
          spellcastingAbility: _abilityFromString(
            selectedClass.spellcastingAbility ?? selectedClass.primaryAbility,
          ),
          spellcastingType:
              _spellcastingTypeForClass(selectedClass.spellcastingType),
        ),
      );
    });

    // Clérigo, Feiticeiro e Bruxo escolhem no 1º nível, então a classe nasce
    // com a decisão aberta e o diálogo aparece já ao adicionar.
    await _promptSubclassIfPending(_classLevels.length - 1, selectedClass);
  }

  Future<void> _save() async {
    if (_classLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O personagem precisa ter pelo menos 1 classe.'),
        ),
      );
      return;
    }

    if (_totalLevel > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nível total não pode passar de 20.'),
        ),
      );
      return;
    }

    if (_isMulticlass) {
      final invalidRequirement = _missingPrerequisitesForSecondaryClasses();
      if (invalidRequirement != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pré-requisito de multiclasse não cumprido: $invalidRequirement',
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      _saving = true;
    });

    try {
      final useCase = ref.read(updateCharacterClassLevelsProvider);
      final classes = await ref.read(classEntriesProvider.future);

      await useCase(
        characterId: widget.characterId,
        classLevels: _classLevels,
        dieSizeForClass: (classId) {
          for (final entry in classes) {
            if (entry.id == classId) {
              return HitPointsCalculator.parseDieSize(entry.hitDie);
            }
          }
          return 8;
        },
      );

      // As magias de domínio, juramento e patrono acompanham a subclasse e o
      // nível, então precisam ser reconciliadas depois de salvar.
      await _syncSubclassSpells();

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      debugPrint('ERRO AO SALVAR MULTICLASSE: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar níveis: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String? _missingPrerequisitesForSecondaryClasses() {
    if (_classLevels.length <= 1) return null;

    for (var i = 1; i < _classLevels.length; i++) {
      final classId = _classLevels[i].classId;
      final missing = _missingPrerequisitesForClass(classId);
      if (missing != null) return missing;
    }

    return null;
  }

  /// Id da classe-base, para variante seguir o pré-requisito da original.
  ///
  /// O Patrulheiro Revisado pede Destreza 13 e Sabedoria 13 igual ao
  /// Patrulheiro. Sem resolver isso, o id da variante cairia no `default` dos
  /// dois switches abaixo e o multiclasse entraria sem exigir atributo nenhum.
  ///
  /// Tolerante ao carregamento: com o compêndio ainda em voo, devolve o id
  /// recebido, que é o comportamento de antes.
  String _baseClassIdOf(String classId) {
    final classes = ref.read(classEntriesProvider).value ?? const <ClassEntry>[];

    for (final item in classes) {
      if (item.id == classId) return item.baseClassId;
    }

    return classId;
  }

  String? _missingPrerequisitesForClass(String classId) {
    final scores = widget.abilityScores;

    int score(String key) {
      switch (key) {
        case 'strength':
          return scores.strength;
        case 'dexterity':
          return scores.dexterity;
        case 'constitution':
          return scores.constitution;
        case 'intelligence':
          return scores.intelligence;
        case 'wisdom':
          return scores.wisdom;
        case 'charisma':
          return scores.charisma;
        default:
          return 0;
      }
    }

    bool atLeast13(String key) => score(key) >= 13;

    String label(String key) {
      switch (key) {
        case 'strength':
          return 'Força 13';
        case 'dexterity':
          return 'Destreza 13';
        case 'constitution':
          return 'Constituição 13';
        case 'intelligence':
          return 'Inteligência 13';
        case 'wisdom':
          return 'Sabedoria 13';
        case 'charisma':
          return 'Carisma 13';
        default:
          return key;
      }
    }

    switch (_baseClassIdOf(classId)) {
      case 'barbarian':
        return atLeast13('strength') ? null : label('strength');
      case 'bard':
        return atLeast13('charisma') ? null : label('charisma');
      case 'cleric':
        return atLeast13('wisdom') ? null : label('wisdom');
      case 'druid':
        return atLeast13('wisdom') ? null : label('wisdom');
      case 'fighter':
        return (atLeast13('strength') || atLeast13('dexterity'))
            ? null
            : 'Força 13 ou Destreza 13';
      case 'monk':
        final missing = <String>[];
        if (!atLeast13('dexterity')) missing.add(label('dexterity'));
        if (!atLeast13('wisdom')) missing.add(label('wisdom'));
        return missing.isEmpty ? null : missing.join(' e ');
      case 'paladin':
        final missing = <String>[];
        if (!atLeast13('strength')) missing.add(label('strength'));
        if (!atLeast13('charisma')) missing.add(label('charisma'));
        return missing.isEmpty ? null : missing.join(' e ');
      case 'ranger':
        final missing = <String>[];
        if (!atLeast13('dexterity')) missing.add(label('dexterity'));
        if (!atLeast13('wisdom')) missing.add(label('wisdom'));
        return missing.isEmpty ? null : missing.join(' e ');
      case 'rogue':
        return atLeast13('dexterity') ? null : label('dexterity');
      case 'sorcerer':
        return atLeast13('charisma') ? null : label('charisma');
      case 'warlock':
        return atLeast13('charisma') ? null : label('charisma');
      case 'wizard':
        return atLeast13('intelligence') ? null : label('intelligence');
      default:
        return null;
    }
  }

  String _requirementTextForClassId(String classId) {
    switch (_baseClassIdOf(classId)) {
      case 'barbarian':
        return 'Força 13';
      case 'bard':
        return 'Carisma 13';
      case 'cleric':
        return 'Sabedoria 13';
      case 'druid':
        return 'Sabedoria 13';
      case 'fighter':
        return 'Força 13 ou Destreza 13';
      case 'monk':
        return 'Destreza 13 e Sabedoria 13';
      case 'paladin':
        return 'Força 13 e Carisma 13';
      case 'ranger':
        return 'Destreza 13 e Sabedoria 13';
      case 'rogue':
        return 'Destreza 13';
      case 'sorcerer':
        return 'Carisma 13';
      case 'warlock':
        return 'Carisma 13';
      case 'wizard':
        return 'Inteligência 13';
      default:
        return 'Sem requisito cadastrado';
    }
  }

  /// Põe no livro as magias que a subclasse concede até o nível atual e tira as
  /// que não valem mais.
  ///
  /// Falhar aqui não desfaz o nível já salvo: o jogador é avisado e pode
  /// adicionar a magia à mão.
  Future<void> _syncSubclassSpells() async {
    try {
      final subclasses = await ref.read(subclassEntriesProvider.future);
      final spellIndex = await ref.read(spellNameIndexProvider.future);

      final result = await ref.read(syncSubclassSpellsProvider)(
        characterId: widget.characterId,
        subclasses: subclasses,
        spellIndex: spellIndex,
      );

      if (result.unknownSpellNames.isNotEmpty) {
        debugPrint(
          'Magias de subclasse sem correspondência no compendio: '
          '${result.unknownSpellNames.join(', ')}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Falha ao sincronizar magias de subclasse: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Níveis salvos, mas as magias da subclasse não entraram. '
              'Adicione pelo gerenciador de magias.',
            ),
          ),
        );
      }
    }
  }

  ClassEntry? _classEntryForId(List<ClassEntry> classes, String classId) {
    for (final item in classes) {
      if (item.id == classId) return item;
    }
    return null;
  }

  /// Muda o nível de uma das classes.
  ///
  /// Descer abaixo do nível em que a subclasse é escolhida limpa a subclasse:
  /// manter deixaria a ficha exibindo um arquétipo que o personagem não tem
  /// mais.
  void _changeLevel(int index, int newLevel, List<ClassEntry> classes) {
    final current = _classLevels[index];
    final classEntry = _classEntryForId(classes, current.classId);
    final keepSubclass =
        classEntry == null || classEntry.subclassUnlockedAt(newLevel);

    setState(() {
      _classLevels[index] = ClassLevel(
        classId: current.classId,
        subclassId: keepSubclass ? current.subclassId : null,
        level: newLevel,
        spellcastingAbility: current.spellcastingAbility,
        spellcastingType: current.spellcastingType,
      );
    });

    // Subir até o nível de escolha abre o diálogo na hora. Descer não pergunta
    // nada, senão limpar a subclasse ao descer provocaria a pergunta de volta.
    if (newLevel > current.level) {
      _promptSubclassIfPending(index, classEntry);
    }
  }

  /// Pergunta a subclasse quando a classe do índice está com a escolha aberta.
  ///
  /// Aqui só mexe no formulário: quem grava é o [_save], igual a qualquer outro
  /// campo desta tela. Gravar direto faria a escolha sobreviver a um cancelar.
  Future<void> _promptSubclassIfPending(
    int index,
    ClassEntry? classEntry,
  ) async {
    if (index >= _classLevels.length) return;

    final classLevel = _classLevels[index];
    if (!SubclassChoices.isPending(classLevel, classEntry)) return;

    final all = ref.read(subclassEntriesProvider).value ?? const [];
    final options = all
        .where((item) => item.classId == classLevel.classId)
        .toList(growable: false);

    if (options.isEmpty) return;

    final chosen = await showSubclassChoiceDialog(
      context: context,
      choice: PendingSubclassChoice(
        classId: classLevel.classId,
        className: classEntry?.name ?? classLevel.classId,
        label: classEntry?.subclassLabelOrDefault ?? 'Subclasse',
        level: classLevel.level,
      ),
      options: options,
    );

    if (chosen == null || !mounted) return;

    setState(() {
      // Reencontra pelo id da classe: a lista pode ter mudado durante o
      // diálogo, e o índice antigo apontaria para outra classe.
      final target = _classLevels.indexWhere(
        (item) => item.classId == classLevel.classId,
      );
      if (target < 0) return;

      _classLevels[target] = _classLevels[target].copyWith(subclassId: chosen);
    });
  }

  /// Seletor de subclasse de uma classe da lista.
  ///
  /// Aparece só quando o nível dela alcança o nível de escolha da classe. Antes
  /// disso mostra em que nível a escolha vai abrir, que é a dúvida de quem
  /// procura o arquétipo do Guerreiro no 1º nível.
  List<Widget> _buildSubclassPicker({
    required int index,
    required ClassLevel classLevel,
    required ClassEntry? classEntry,
    required List<SubclassEntry> options,
  }) {
    if (classEntry == null) return const [];

    final required = classEntry.subclassLevel;
    if (required == null) return const [];

    final label = classEntry.subclassLabelOrDefault;
    final text = Theme.of(context).textTheme;

    if (classLevel.level < required) {
      return [
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '$label: abre no $requiredº nível desta classe.',
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
        ),
      ];
    }

    if (options.isEmpty) {
      return [
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '$label: nenhuma opção cadastrada no compêndio ainda.',
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
        ),
      ];
    }

    final currentId = options.any((item) => item.id == classLevel.subclassId)
        ? classLevel.subclassId
        : null;
    final selected = currentId == null
        ? null
        : options.firstWhere((item) => item.id == currentId);

    return [
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: currentId,
        decoration: InputDecoration(
          labelText: label,
          // Sem auto-seleção aqui: subir de nível não deve escolher o
          // arquétipo no lugar do jogador.
          helperText: currentId == null ? 'Escolha para liberar as características' : null,
        ),
        isExpanded: true,
        items: options
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            final current = _classLevels[index];
            _classLevels[index] = ClassLevel(
              classId: current.classId,
              subclassId: value,
              level: current.level,
              spellcastingAbility: current.spellcastingAbility,
              spellcastingType: current.spellcastingType,
            );
          });
        },
      ),
      if (selected != null)
        SubclassSummary(subclass: selected, level: classLevel.level),
    ];
  }

  String _classNameForId(List<ClassEntry> classes, String classId) {
    for (final item in classes) {
      if (item.id == classId) return item.name;
    }
    return classId;
  }

  Ability? _abilityFromString(String? value) {
    switch (value) {
      case 'strength':
        return Ability.strength;
      case 'dexterity':
        return Ability.dexterity;
      case 'constitution':
        return Ability.constitution;
      case 'intelligence':
        return Ability.intelligence;
      case 'wisdom':
        return Ability.wisdom;
      case 'charisma':
        return Ability.charisma;
      default:
        return null;
    }
  }

  SpellcastingType? _spellcastingTypeForClass(String? value) {
    switch (value) {
      case 'full':
        return SpellcastingType.full;
      case 'half':
        return SpellcastingType.half;
      case 'third':
        return SpellcastingType.third;
      case 'pact':
        return SpellcastingType.pact;
      case 'artificer':
        return SpellcastingType.artificer;
      default:
        return null;
    }
  }
}
