import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/routing/app_router.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/spellcasting_type.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
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

class _CharacterCreationPageState
    extends ConsumerState<CharacterCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _playerController = TextEditingController();

  String? _selectedClassId;
  String? _selectedRaceId;
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

  static const List<_SkillOptionData> _allSkills = [
    _SkillOptionData(
      id: 'acrobatics',
      label: 'Acrobacia',
      abilityAbbreviation: 'DES',
    ),
    _SkillOptionData(
      id: 'animalHandling',
      label: 'Adestrar Animais',
      abilityAbbreviation: 'SAB',
    ),
    _SkillOptionData(
      id: 'arcana',
      label: 'Arcanismo',
      abilityAbbreviation: 'INT',
    ),
    _SkillOptionData(
      id: 'athletics',
      label: 'Atletismo',
      abilityAbbreviation: 'FOR',
    ),
    _SkillOptionData(
      id: 'deception',
      label: 'Enganação',
      abilityAbbreviation: 'CAR',
    ),
    _SkillOptionData(
      id: 'history',
      label: 'História',
      abilityAbbreviation: 'INT',
    ),
    _SkillOptionData(
      id: 'insight',
      label: 'Intuição',
      abilityAbbreviation: 'SAB',
    ),
    _SkillOptionData(
      id: 'intimidation',
      label: 'Intimidação',
      abilityAbbreviation: 'CAR',
    ),
    _SkillOptionData(
      id: 'investigation',
      label: 'Investigação',
      abilityAbbreviation: 'INT',
    ),
    _SkillOptionData(
      id: 'medicine',
      label: 'Medicina',
      abilityAbbreviation: 'SAB',
    ),
    _SkillOptionData(
      id: 'nature',
      label: 'Natureza',
      abilityAbbreviation: 'INT',
    ),
    _SkillOptionData(
      id: 'perception',
      label: 'Percepção',
      abilityAbbreviation: 'SAB',
    ),
    _SkillOptionData(
      id: 'performance',
      label: 'Atuação',
      abilityAbbreviation: 'CAR',
    ),
    _SkillOptionData(
      id: 'persuasion',
      label: 'Persuasão',
      abilityAbbreviation: 'CAR',
    ),
    _SkillOptionData(
      id: 'religion',
      label: 'Religião',
      abilityAbbreviation: 'INT',
    ),
    _SkillOptionData(
      id: 'sleightOfHand',
      label: 'Prestidigitação',
      abilityAbbreviation: 'DES',
    ),
    _SkillOptionData(
      id: 'stealth',
      label: 'Furtividade',
      abilityAbbreviation: 'DES',
    ),
    _SkillOptionData(
      id: 'survival',
      label: 'Sobrevivência',
      abilityAbbreviation: 'SAB',
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classEntriesProvider);
    final racesAsync = ref.watch(raceEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Criar personagem')),
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

              final effectiveClassId = _resolveSelectedClassId(classes);
              final effectiveRaceId = _resolveSelectedRaceId(races);

              final selectedClass = classes.firstWhere(
                (item) => item.id == effectiveClassId,
              );
              final selectedRace = races.firstWhere(
                (item) => item.id == effectiveRaceId,
              );

              if (!selectedRace.allowsCustomOrigin && _useCustomOrigin) {
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
                        labelText: 'Nome do jogador',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: effectiveRaceId,
                      decoration: const InputDecoration(
                        labelText: 'Raça',
                      ),
                      items: races
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
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma raça.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bônus raciais de ${selectedRace.name}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(_formatRaceBonuses(selectedRace)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedRace.allowsCustomOrigin) ...[
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
                        title: const Text('Usar origem customizada (Tasha)'),
                        subtitle: const Text(
                          'Desative para usar os bônus raciais clássicos. '
                          'Ative para escolher manualmente um +2 e um +1.',
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
                      decoration: const InputDecoration(
                        labelText: 'Classe inicial',
                      ),
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
                      'As perícias destacadas são oferecidas pela classe selecionada. '
                      'Você pode marcar livremente as que quiser por enquanto.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    ..._allSkills.map((skill) {
                      final isClassSkill =
                          selectedClass.skillOptions.contains(skill.id);

                      return Card(
                        color: isClassSkill
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.55)
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
                            '${skill.label} (${skill.abilityAbbreviation})',
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
                          : () => _save(classes, races, effectiveClassId, effectiveRaceId),
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _saving
                            ? 'Salvando personagem...'
                            : 'Salvar personagem base',
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

  String _resolveSelectedClassId(List<ClassEntry> classes) {
    final current = _selectedClassId;
    if (current != null && classes.any((item) => item.id == current)) {
      return current;
    }
    return classes.first.id;
  }

  String _resolveSelectedRaceId(List<RaceEntry> races) {
    final current = _selectedRaceId;
    if (current != null && races.any((item) => item.id == current)) {
      return current;
    }
    return races.first.id;
  }

  Future<void> _save(
    List<ClassEntry> classes,
    List<RaceEntry> races,
    String effectiveClassId,
    String effectiveRaceId,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final selectedClass = classes.firstWhere((item) => item.id == effectiveClassId);
    final selectedRace = races.firstWhere((item) => item.id == effectiveRaceId);

    setState(() {
      _saving = true;
    });

    try {
      final repository = ref.read(characterRepositoryProvider);
      final now = DateTime.now();
      final id = now.microsecondsSinceEpoch.toString();

      final primaryAbility = _abilityFromString(selectedClass.primaryAbility);
      final spellcastingType = _spellcastingTypeForClass(
        selectedClass.spellcastingType,
      );
      final maxHp = _startingHitPointsForClass(selectedClass);
      final finalScores = _buildFinalAbilityScores(selectedRace);

      final character = Character(
        id: id,
        name: _nameController.text.trim(),
        playerName: _playerController.text.trim().isEmpty
            ? null
            : _playerController.text.trim(),
        speciesId: selectedRace.id,
        abilityScores: finalScores,
        classLevels: [
          ClassLevel(
            classId: selectedClass.id,
            level: 1,
            spellcastingAbility:
                spellcastingType == null ? null : primaryAbility,
            spellcastingType: spellcastingType,
          ),
        ],
        hitPoints: HitPoints(
          current: maxHp,
          maximum: maxHp,
        ),
        combatStats: CombatStats(
          armorClass: 10,
          initiativeBonus: 0,
          speedInSquares: selectedRace.speed ?? 9,
        ),
        savingThrowProficiencies: _savingThrowsForClass(selectedClass),
        skillProficiencies: _buildSkillProficienciesFromSelection(),
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
      print('ERRO AO CRIAR PERSONAGEM: $error');
      print(stackTrace);

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

  AbilityScores _buildFinalAbilityScores(RaceEntry race) {
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

  String _formatRaceBonuses(RaceEntry race) {
    if (_useCustomOrigin && race.allowsCustomOrigin) {
      return 'Origem customizada ativa: '
          '${_abilityLabels[_customPlusTwo]} +2 • '
          '${_abilityLabels[_customPlusOne]} +1';
    }

    if (race.fixedAbilityBonuses.isEmpty) {
      return 'Sem bônus raciais definidos.';
    }

    const labels = <String, String>{
      'strength': 'FOR',
      'dexterity': 'DES',
      'constitution': 'CON',
      'intelligence': 'INT',
      'wisdom': 'SAB',
      'charisma': 'CAR',
    };

    return race.fixedAbilityBonuses.entries
        .map((entry) => '${labels[entry.key] ?? entry.key} +${entry.value}')
        .join(' • ');
  }

  int _startingHitPointsForClass(ClassEntry classEntry) {
    final normalized = classEntry.hitDie.toLowerCase().replaceAll('d', '');
    final hitDie = int.tryParse(normalized) ?? 8;
    return hitDie;
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

  SkillProficiencies _buildSkillProficienciesFromSelection() {
    return SkillProficiencies(
      acrobatics: _selectedSkills.contains('acrobatics'),
      animalHandling: _selectedSkills.contains('animalHandling'),
      arcana: _selectedSkills.contains('arcana'),
      athletics: _selectedSkills.contains('athletics'),
      deception: _selectedSkills.contains('deception'),
      history: _selectedSkills.contains('history'),
      insight: _selectedSkills.contains('insight'),
      intimidation: _selectedSkills.contains('intimidation'),
      investigation: _selectedSkills.contains('investigation'),
      medicine: _selectedSkills.contains('medicine'),
      nature: _selectedSkills.contains('nature'),
      perception: _selectedSkills.contains('perception'),
      performance: _selectedSkills.contains('performance'),
      persuasion: _selectedSkills.contains('persuasion'),
      religion: _selectedSkills.contains('religion'),
      sleightOfHand: _selectedSkills.contains('sleightOfHand'),
      stealth: _selectedSkills.contains('stealth'),
      survival: _selectedSkills.contains('survival'),
    );
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

class _SkillOptionData {
  const _SkillOptionData({
    required this.id,
    required this.label,
    required this.abilityAbbreviation,
  });

  final String id;
  final String label;
  final String abilityAbbreviation;
}