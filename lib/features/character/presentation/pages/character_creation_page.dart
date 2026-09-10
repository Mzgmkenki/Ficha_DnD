import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/core/routing/app_router.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/spellcasting_type.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart'
    as compendium_providers;
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterCreationPage extends ConsumerStatefulWidget {
  const CharacterCreationPage({super.key});

  @override
  ConsumerState<CharacterCreationPage> createState() =>
      _CharacterCreationPageState();
}

class _CharacterCreationPageState extends ConsumerState<CharacterCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _playerController = TextEditingController();
  final _customBackgroundNameController = TextEditingController();
  final _customBackgroundFeaturesController = TextEditingController();

  String? _selectedClassId;
  String? _selectedRaceId;
  String? _selectedSubraceId;
  String? _selectedBackgroundId;

  /// Perícias do antecedente customizável (um antecedente concede duas).
  String? _customBackgroundSkillOne;
  String? _customBackgroundSkillTwo;

  final Set<String> _selectedSkills = {};

  bool _useCustomOrigin = false;
  bool _saving = false;
  String _customPlusTwo = 'strength';
  String _customPlusOne = 'dexterity';

  static const List<String> _abilityKeys = [
    'strength',
    'dexterity',
    'constitution',
    'intelligence',
    'wisdom',
    'charisma',
  ];

  static const Map<String, String> _abilityLabels = {
    'strength': 'Força',
    'dexterity': 'Destreza',
    'constitution': 'Constituição',
    'intelligence': 'Inteligência',
    'wisdom': 'Sabedoria',
    'charisma': 'Carisma',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _playerController.dispose();
    _customBackgroundNameController.dispose();
    _customBackgroundFeaturesController.dispose();
    super.dispose();
  }

  bool get _isCustomBackground =>
      _selectedBackgroundId == BackgroundEntry.customId;

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(compendium_providers.classEntriesProvider);
    final racesAsync = ref.watch(compendium_providers.raceEntriesProvider);
    // Não bloqueia o formulário: se ainda estiver carregando, o dropdown de
    // antecedente simplesmente não aparece.
    final backgrounds =
        ref.watch(compendium_providers.backgroundEntriesProvider).value ??
            const <BackgroundEntry>[];

    // Busca tolerante: enquanto os antecedentes carregam (ou se o id salvo
    // sumir da lista) o formulário continua funcionando.
    final selectedBackground = _findBackground(backgrounds);

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Personagem')),
      body: classesAsync.when(
        data: (classes) {
          return racesAsync.when(
            data: (races) {
              if (classes.isEmpty) {
                return const Center(
                  child: Text('Nenhuma classe encontrada no compêndio.'),
                );
              }

              if (races.isEmpty) {
                return const Center(
                  child: Text('Nenhuma raça encontrada no compêndio.'),
                );
              }

              final baseRaces = races
                  .where((race) => !race.shouldBeTreatedAsSubrace)
                  .toList(growable: false);

              if (baseRaces.isEmpty) {
                return const Center(
                  child: Text('Nenhuma raça base encontrada no compêndio.'),
                );
              }

              final effectiveClassId = _resolveSelectedClassId(classes);
              final effectiveRaceId = _resolveSelectedBaseRaceId(baseRaces);

              final selectedClass = classes.firstWhere(
                (item) => item.id == effectiveClassId,
              );

              final selectedRace = baseRaces.firstWhere(
                (item) => item.id == effectiveRaceId,
              );

              final subraces = races
                  .where((race) => race.parentRaceId == selectedRace.id)
                  .toList(growable: false);

              final effectiveSubraceId = _resolveSelectedSubraceId(subraces);
              final selectedSubrace = effectiveSubraceId == null
                  ? null
                  : subraces.firstWhere((item) => item.id == effectiveSubraceId);

              final combinedRace = _combineRaceAndSubrace(
                selectedRace,
                selectedSubrace,
              );

              if (!combinedRace.allowsCustomOrigin && _useCustomOrigin) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _useCustomOrigin = false;
                  });
                });
              }

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do personagem',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe um nome.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _playerController,
                      decoration: const InputDecoration(
                        labelText: 'Jogador (opcional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: effectiveRaceId,
                      decoration: const InputDecoration(
                        labelText: 'Raça base',
                      ),
                      items: baseRaces
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRaceId = value;
                          _selectedSubraceId = null;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma raça.';
                        }
                        return null;
                      },
                    ),
                    if (subraces.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: effectiveSubraceId,
                        decoration: const InputDecoration(
                          labelText: 'Sub-raça / linhagem',
                        ),
                        items: subraces
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubraceId = value;
                          });
                        },
                        validator: (value) {
                          if (subraces.isNotEmpty &&
                              (value == null || value.isEmpty)) {
                            return 'Selecione uma sub-raça.';
                          }
                          return null;
                        },
                      ),
                    ],
                    if (backgrounds.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBackgroundId,
                        decoration: const InputDecoration(
                          labelText: 'Antecedente',
                        ),
                        items: backgrounds
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedBackgroundId = value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione um antecedente.';
                          }
                          return null;
                        },
                      ),
                      if (selectedBackground != null &&
                          !selectedBackground.isCustom)
                        _BackgroundSummary(background: selectedBackground),
                      if (_isCustomBackground) _buildCustomBackgroundCard(),
                    ],
                    const SizedBox(height: 12),
                    _RaceSummaryCard(
                      race: combinedRace,
                      useCustomOrigin: _useCustomOrigin,
                      customPlusTwo: _customPlusTwo,
                      customPlusOne: _customPlusOne,
                    ),
                    const SizedBox(height: 12),
                    if (combinedRace.allowsCustomOrigin) ...[
                      SwitchListTile(
                        value: _useCustomOrigin,
                        onChanged: (value) {
                          setState(() {
                            _useCustomOrigin = value;
                            if (_customPlusTwo == _customPlusOne) {
                              _customPlusOne =
                                  _firstDifferentAbility(_customPlusTwo);
                            }
                          });
                        },
                        title: const Text('Usar origem customizada'),
                        subtitle: const Text(
                          'Ative para escolher manualmente um atributo com +2 '
                          'e outro atributo com +1.',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_useCustomOrigin) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _customPlusTwo,
                          decoration: const InputDecoration(
                            labelText: 'Atributo que recebe +2',
                          ),
                          items: _abilityKeys
                              .map(
                                (ability) => DropdownMenuItem<String>(
                                  value: ability,
                                  child: Text(_abilityLabels[ability]!),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _customPlusTwo = value;
                              if (_customPlusOne == _customPlusTwo) {
                                _customPlusOne =
                                    _firstDifferentAbility(_customPlusTwo);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _customPlusOne,
                          decoration: const InputDecoration(
                            labelText: 'Atributo que recebe +1',
                          ),
                          items: _abilityKeys
                              .where((ability) => ability != _customPlusTwo)
                              .map(
                                (ability) => DropdownMenuItem<String>(
                                  value: ability,
                                  child: Text(_abilityLabels[ability]!),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _customPlusOne = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Origem customizada ativa: '
                              '${_abilityLabels[_customPlusTwo]} +2 • '
                              '${_abilityLabels[_customPlusOne]} +1',
                            ),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: effectiveClassId,
                      decoration: const InputDecoration(labelText: 'Classe'),
                      items: classes
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text('${item.name} (${item.hitDie})'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClassId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma classe.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Perícias',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Perícias destacadas pertencem à classe selecionada.\n'
                      'Você pode escolher livremente por enquanto.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    ...Skill.sortedByLabel.map((skill) {
                      final isClassSkill =
                          selectedClass.skillOptions.contains(skill.id);

                      return Card(
                        color: isClassSkill
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.35)
                            : null,
                        child: CheckboxListTile(
                          value: _selectedSkills.contains(skill.id),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedSkills.add(skill.id);
                              } else {
                                _selectedSkills.remove(skill.id);
                              }
                            });
                          },
                          title: Text(
                            '${skill.label} (${skill.abbreviation})',
                          ),
                          subtitle: isClassSkill
                              ? const Text('Perícia oferecida pela classe')
                              : null,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _saving
                          ? null
                          : () => _save(
                                classes,
                                combinedRace,
                                effectiveClassId,
                                backgrounds,
                              ),
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _saving ? 'Criando personagem...' : 'Criar personagem',
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (error, stackTrace) {
              return Center(child: Text('Erro ao carregar raças: $error'));
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, stackTrace) {
          return Center(child: Text('Erro ao carregar classes: $error'));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  BackgroundEntry? _findBackground(List<BackgroundEntry> backgrounds) {
    for (final item in backgrounds) {
      if (item.id == _selectedBackgroundId) return item;
    }
    return null;
  }

  /// Formulário do "Antecedente Customizável": nome opcional, as duas perícias
  /// concedidas e o texto de características.
  Widget _buildCustomBackgroundCard() {
    final skills = Skill.sortedByLabel;

    List<DropdownMenuItem<String>> itemsExcept(String? excludedId) {
      return skills
          .where((skill) => skill.id != excludedId)
          .map(
            (skill) => DropdownMenuItem<String>(
              value: skill.id,
              child: Text('${skill.label} (${skill.abbreviation})'),
            ),
          )
          .toList();
    }

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monte o seu antecedente',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Um antecedente concede proficiência em duas perícias.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customBackgroundNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do antecedente (opcional)',
                hintText: 'Ex.: Caçador de Recompensas',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _customBackgroundSkillOne,
              decoration: const InputDecoration(
                labelText: 'Primeira perícia',
              ),
              items: itemsExcept(null),
              onChanged: (value) {
                setState(() {
                  final previous = _customBackgroundSkillOne;
                  _customBackgroundSkillOne = value;
                  // Evita as duas perícias iguais: troca com a anterior em vez
                  // de limpar, para o segundo dropdown nunca ficar com um
                  // valor que saiu da lista de opções.
                  if (_customBackgroundSkillTwo == value) {
                    _customBackgroundSkillTwo = previous;
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Escolha a primeira perícia.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _customBackgroundSkillTwo,
              decoration: const InputDecoration(
                labelText: 'Segunda perícia',
              ),
              items: itemsExcept(_customBackgroundSkillOne),
              onChanged: (value) {
                setState(() => _customBackgroundSkillTwo = value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Escolha a segunda perícia.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customBackgroundFeaturesController,
              decoration: const InputDecoration(
                labelText: 'Características do antecedente',
                hintText: 'Descreva o que o antecedente concede, sua história, '
                    'contatos, ferramentas...',
                alignLabelWithHint: true,
              ),
              minLines: 4,
              maxLines: 10,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }

  String _resolveSelectedClassId(List<ClassEntry> classes) {
    final current = _selectedClassId;
    if (current != null && classes.any((item) => item.id == current)) {
      return current;
    }
    return classes.first.id;
  }

  String _resolveSelectedBaseRaceId(List<RaceEntry> baseRaces) {
    final current = _selectedRaceId;
    if (current != null && baseRaces.any((item) => item.id == current)) {
      return current;
    }

    return baseRaces.first.id;
  }

  String? _resolveSelectedSubraceId(List<RaceEntry> subraces) {
    if (subraces.isEmpty) return null;

    final current = _selectedSubraceId;
    if (current != null && subraces.any((item) => item.id == current)) {
      return current;
    }

    return subraces.first.id;
  }

  _CombinedRaceData _combineRaceAndSubrace(
    RaceEntry baseRace,
    RaceEntry? subrace,
  ) {
    final bonuses = <String, int>{};

    for (final entry in baseRace.fixedAbilityBonuses.entries) {
      bonuses[entry.key] = (bonuses[entry.key] ?? 0) + entry.value;
    }

    if (subrace != null) {
      for (final entry in subrace.fixedAbilityBonuses.entries) {
        bonuses[entry.key] = (bonuses[entry.key] ?? 0) + entry.value;
      }
    }

    final traits = <String>[
      ...baseRace.traits,
      if (subrace != null) ...subrace.traits,
    ];

    final languages = <String>{
      ...baseRace.languages,
      if (subrace != null) ...subrace.languages,
    }.toList(growable: false);

    final name = subrace == null
        ? baseRace.name
        : '${baseRace.name} — ${subrace.name}';

    final description = subrace?.description?.trim().isNotEmpty == true
        ? '${baseRace.description ?? ''}\n\n${subrace!.description}'
        : baseRace.description;

    return _CombinedRaceData(
      idToSave: subrace?.id ?? baseRace.id,
      name: name,
      description: description,
      size: subrace?.size ?? baseRace.size,
      speed: subrace?.speed ?? baseRace.speed,
      creatureType: subrace?.creatureType ?? baseRace.creatureType,
      darkvision: subrace?.darkvision ?? baseRace.darkvision,
      allowsCustomOrigin:
          baseRace.allowsCustomOrigin && (subrace?.allowsCustomOrigin ?? true),
      fixedAbilityBonuses: bonuses,
      traits: traits,
      languages: languages,
    );
  }

  Future<void> _save(
    List<ClassEntry> classes,
    _CombinedRaceData selectedRace,
    String effectiveClassId,
    List<BackgroundEntry> backgrounds,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    // O formulário é um ListView: os campos que saem da viewport são
    // desmontados e se desregistram do Form, então `validate()` não enxerga
    // mais os validators deles. As regras que não podem escapar são checadas
    // aqui de novo, contra o estado, e não contra a árvore de widgets.
    final missing = <String>[
      if (_nameController.text.trim().isEmpty) 'o nome do personagem',
      if (_isCustomBackground &&
          (_customBackgroundSkillOne == null ||
              _customBackgroundSkillTwo == null))
        'as duas perícias do antecedente',
    ];

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falta preencher ${missing.join(' e ')}.')),
      );
      return;
    }

    final selectedClass = classes.firstWhere(
      (item) => item.id == effectiveClassId,
    );

    final background = _findBackground(backgrounds);

    // No antecedente customizável as perícias e as características vêm do
    // formulário, não do compêndio.
    final customBackground = _isCustomBackground
        ? _buildCustomBackground()
        : const CustomBackground();
    final backgroundSkills = _isCustomBackground
        ? customBackground.skills
        : (background?.skills ?? const <Skill>[]);

    setState(() {
      _saving = true;
    });

    try {
      final repository = ref.read(characterRepositoryProvider);
      final now = DateTime.now();
      final id = now.microsecondsSinceEpoch.toString();

      // Usa o atributo de conjuração declarado da classe (não o primário).
      final castingAbility = _abilityFromString(
        selectedClass.spellcastingAbility ?? selectedClass.primaryAbility,
      );
      final spellcastingType = _spellcastingTypeForClass(
        selectedClass.spellcastingType,
      );
      final finalScores = _buildFinalAbilityScores(selectedRace);
      final maxHp = _startingHitPointsForClass(selectedClass, finalScores);

      final character = Character(
        id: id,
        name: _nameController.text.trim(),
        playerName: _playerController.text.trim().isEmpty
            ? null
            : _playerController.text.trim(),
        speciesId: selectedRace.idToSave,
        backgroundId: _selectedBackgroundId,
        customBackground: customBackground,
        abilityScores: finalScores,
        classLevels: [
          ClassLevel(
            classId: selectedClass.id,
            level: 1,
            spellcastingAbility:
                spellcastingType == null ? null : castingAbility,
            spellcastingType: spellcastingType,
          ),
        ],
        hitPoints: HitPoints(current: maxHp, maximum: maxHp),
        combatStats: CombatStats(
          armorClass: 10,
          initiativeBonus: 0,
          speedInSquares: selectedRace.speed ?? 9,
        ),
        savingThrowProficiencies: _savingThrowsForClass(selectedClass),
        skillProficiencies:
            _buildSkillProficienciesFromSelection(backgroundSkills),
        createdAt: now,
        updatedAt: now,
      );

      await repository.create(character);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.characterSheet,
        arguments: id,
      );
    } catch (error, stackTrace) {
      debugPrint('ERRO AO CRIAR PERSONAGEM: $error');
      debugPrint('$stackTrace');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar personagem: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  AbilityScores _buildFinalAbilityScores(_CombinedRaceData race) {
    final bonuses =
        _useCustomOrigin ? _customOriginBonuses() : race.fixedAbilityBonuses;

    int bonusFor(String key) => bonuses[key] ?? 0;

    return AbilityScores(
      strength: 10 + bonusFor('strength'),
      dexterity: 10 + bonusFor('dexterity'),
      constitution: 10 + bonusFor('constitution'),
      intelligence: 10 + bonusFor('intelligence'),
      wisdom: 10 + bonusFor('wisdom'),
      charisma: 10 + bonusFor('charisma'),
    );
  }

  Map<String, int> _customOriginBonuses() {
    return {
      _customPlusTwo: 2,
      _customPlusOne: 1,
    };
  }

  String _firstDifferentAbility(String current) {
    for (final ability in _abilityKeys) {
      if (ability != current) return ability;
    }
    return 'dexterity';
  }

  /// PV no nível 1 = valor máximo do dado de vida + modificador de Constituição
  /// (regra 5e). O modificador de CON estava sendo ignorado.
  int _startingHitPointsForClass(
    ClassEntry classEntry,
    AbilityScores finalScores,
  ) {
    final normalized = classEntry.hitDie.toLowerCase().replaceAll('d', '');
    final hitDie = int.tryParse(normalized) ?? 8;
    final conModifier = finalScores.constitution.abilityModifier;

    final total = hitDie + conModifier;
    // Nunca abaixo de 1 PV, mesmo com Constituição muito baixa.
    return total < 1 ? 1 : total;
  }

  SavingThrowProficiencies _savingThrowsForClass(ClassEntry classEntry) {
    return SavingThrowProficiencies(
      strength: classEntry.savingThrows.contains('strength'),
      dexterity: classEntry.savingThrows.contains('dexterity'),
      constitution: classEntry.savingThrows.contains('constitution'),
      intelligence: classEntry.savingThrows.contains('intelligence'),
      wisdom: classEntry.savingThrows.contains('wisdom'),
      charisma: classEntry.savingThrows.contains('charisma'),
    );
  }

  /// Monta o antecedente criado pelo jogador a partir do formulário.
  CustomBackground _buildCustomBackground() {
    final name = _customBackgroundNameController.text.trim();

    return CustomBackground(
      name: name.isEmpty ? null : name,
      skillIds: [
        if (_customBackgroundSkillOne != null) _customBackgroundSkillOne!,
        if (_customBackgroundSkillTwo != null) _customBackgroundSkillTwo!,
      ],
      features: _customBackgroundFeaturesController.text.trim(),
    );
  }

  /// Combina as perícias escolhidas manualmente com as concedidas pelo
  /// antecedente (o antecedente sempre dá proficiência).
  SkillProficiencies _buildSkillProficienciesFromSelection(
    List<Skill> backgroundSkills,
  ) {
    final levels = <Skill, ProficiencyLevel>{};

    for (final skill in Skill.values) {
      if (_selectedSkills.contains(skill.id)) {
        levels[skill] = ProficiencyLevel.proficient;
      }
    }

    for (final skill in backgroundSkills) {
      levels[skill] = ProficiencyLevel.proficient;
    }

    return SkillProficiencies(levels: levels);
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
      default:
        return null;
    }
  }
}

class _CombinedRaceData {
  const _CombinedRaceData({
    required this.idToSave,
    required this.name,
    required this.allowsCustomOrigin,
    required this.fixedAbilityBonuses,
    required this.traits,
    required this.languages,
    this.description,
    this.size,
    this.speed,
    this.creatureType,
    this.darkvision,
  });

  final String idToSave;
  final String name;
  final String? description;
  final String? size;
  final int? speed;
  final String? creatureType;
  final int? darkvision;
  final bool allowsCustomOrigin;
  final Map<String, int> fixedAbilityBonuses;
  final List<String> traits;
  final List<String> languages;
}

/// Mostra o que o antecedente concede, para o jogador entender a escolha.
class _BackgroundSummary extends StatelessWidget {
  const _BackgroundSummary({required this.background});

  final BackgroundEntry background;

  @override
  Widget build(BuildContext context) {
    final skillLabels = background.skills.map((s) => s.label).join(', ');

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (background.description != null)
              Text(background.description!),
            if (skillLabels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Perícias concedidas: $skillLabels',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (background.tools.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Ferramentas: ${background.tools.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (background.languages > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Idiomas adicionais: ${background.languages}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (background.featureName != null) ...[
              const SizedBox(height: 8),
              Text(
                background.featureName!,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (background.featureDescription != null)
                Text(
                  background.featureDescription!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RaceSummaryCard extends StatelessWidget {
  const _RaceSummaryCard({
    required this.race,
    required this.useCustomOrigin,
    required this.customPlusTwo,
    required this.customPlusOne,
  });

  final _CombinedRaceData race;
  final bool useCustomOrigin;
  final String customPlusTwo;
  final String customPlusOne;

  @override
  Widget build(BuildContext context) {
    final bonuses = useCustomOrigin && race.allowsCustomOrigin
        ? {customPlusTwo: 2, customPlusOne: 1}
        : race.fixedAbilityBonuses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(race.name, style: Theme.of(context).textTheme.titleSmall),
            if (race.description != null &&
                race.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(race.description!),
            ],
            const SizedBox(height: 8),
            Text(
              'Tipo: ${_translateCreatureType(race.creatureType)} • '
              'Tamanho: ${_translateSize(race.size)} • '
              'Deslocamento: ${race.speed ?? 9}m',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (race.darkvision != null) ...[
              const SizedBox(height: 4),
              Text(
                'Visão no Escuro: ${race.darkvision}m',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (race.languages.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Idiomas: ${race.languages.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Bônus de atributos',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            if (bonuses.isEmpty)
              const Text('Sem bônus de atributos definidos.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: bonuses.entries.map((entry) {
                  return Chip(
                    label: Text(
                      '${_abilityShortLabel(entry.key)} +${entry.value}',
                    ),
                  );
                }).toList(),
              ),
            if (race.traits.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Características raciais',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              ...race.traits.take(8).map(
                    (trait) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $trait'),
                    ),
                  ),
              if (race.traits.length > 8)
                Text(
                  '+${race.traits.length - 8} característica(s) adicional(is).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _abilityShortLabel(String key) {
    const labels = <String, String>{
      'strength': 'FOR',
      'dexterity': 'DES',
      'constitution': 'CON',
      'intelligence': 'INT',
      'wisdom': 'SAB',
      'charisma': 'CAR',
      'dois_atributos_escolhidos': '2 atributos',
      'um_escolhido': '1 atributo',
    };

    return labels[key] ?? key;
  }

  String _translateCreatureType(String? value) {
    switch (value) {
      case 'humanoid':
        return 'Humanoide';
      case 'fey':
        return 'Feérico';
      case 'construct':
        return 'Construto';
      case 'ooze':
        return 'Gosma';
      case 'monstrosity':
        return 'Monstruosidade';
      default:
        return 'Humanoide';
    }
  }

  String _translateSize(String? value) {
    switch (value) {
      case 'small':
        return 'Pequeno';
      case 'medium':
        return 'Médio';
      case 'large':
        return 'Grande';
      default:
        return 'Não definido';
    }
  }
}

