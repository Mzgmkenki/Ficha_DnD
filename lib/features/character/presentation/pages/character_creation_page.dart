import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/core/routing/app_navigator.dart';
import 'package:dnd_ficha_app/core/storage/portrait_storage.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/core/utils/distance_format.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_skills.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/alignment.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/spellcasting_type.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/alignment_field.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/custom_background_form.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/portrait_avatar.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/subclass_summary.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart'
    as compendium_providers;
import 'package:dnd_ficha_app/features/compendium/domain/entities/ability_bonus_mode.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_skill_choice.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
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
  String? _selectedSubclassId;
  String? _selectedBackgroundId;

  /// Alinhamento escolhido. Nulo é "não definido", e é o padrão: o campo é
  /// opcional, e assumir neutro seria decidir pelo jogador.
  CharacterAlignment? _selectedAlignment;

  /// Perícias do antecedente customizável (um antecedente concede duas).
  String? _customBackgroundSkillOne;
  String? _customBackgroundSkillTwo;

  /// Imagem escolhida para a aparência, ainda não copiada para o app.
  ///
  /// A cópia só acontece no [_save], porque o nome do arquivo usa o id do
  /// personagem — que só existe depois. Guardar só a escolha aqui também
  /// evita deixar arquivo órfão se o jogador desistir da criação.
  PickedImage? _pickedPortrait;

  final Set<String> _selectedSkills = {};

  /// Perícias escolhidas dentro das opções que a raça oferece.
  final Set<String> _raceSkillPicks = {};

  /// Atributo escolhido para cada bônus que o jogador distribui, por posição.
  ///
  /// Guardar por índice em vez de uma lista fixa evita ter que sincronizar
  /// estado quando a raça muda e o número de bônus muda com ela: posição sem
  /// escolha cai num atributo livre, resolvido no [_resolveBonusAbilities].
  final Map<int, String> _bonusPicks = {};

  /// No padrão flexível, alterna entre +2/+1 e +1/+1/+1.
  bool _flexibleTriple = false;

  bool _useCustomOrigin = false;
  bool _saving = false;

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

  Future<void> _pickPortrait() async {
    try {
      final picked = await ref.read(portraitStorageProvider).pick();
      if (picked == null || !mounted) return;
      setState(() => _pickedPortrait = picked);
    } on PortraitException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao escolher a imagem: $error')),
      );
    }
  }

  /// Copia a imagem escolhida para o diretório do app.
  ///
  /// Devolve `null` e apenas avisa se falhar: perder a criação inteira do
  /// personagem por causa da imagem seria um péssimo negócio, e o retrato
  /// pode ser posto depois pela ficha.
  Future<String?> _storePortrait(String characterId) async {
    final picked = _pickedPortrait;
    if (picked == null) return null;

    try {
      return await ref.read(portraitStorageProvider).save(
            characterId: characterId,
            sourcePath: picked.path,
            extension: picked.extension,
          );
    } catch (error) {
      debugPrint('Falha ao salvar o retrato na criacao: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Personagem criado, mas a imagem não pôde ser salva. '
              'Escolha novamente na ficha.',
            ),
          ),
        );
      }

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(compendium_providers.classEntriesProvider);
    final racesAsync = ref.watch(compendium_providers.raceEntriesProvider);
    // Não bloqueia o formulário: se ainda estiver carregando, o dropdown de
    // antecedente simplesmente não aparece.
    final backgrounds =
        ref.watch(compendium_providers.backgroundEntriesProvider).value ??
            const <BackgroundEntry>[];

    // Mesma tolerância: enquanto as subclasses carregam, o seletor não aparece
    // e o resto do formulário segue utilizável.
    final subclasses =
        ref.watch(compendium_providers.subclassEntriesProvider).value ??
            const <SubclassEntry>[];

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

              final classSubclasses = subclasses
                  .where((item) => item.classId == selectedClass.id)
                  .toList(growable: false);

              // O dropdown auto-seleciona a primeira opção, então o id que vai
              // para o personagem tem que ser o resolvido, não o que está no
              // estado (que fica nulo até o jogador tocar no campo).
              final effectiveSubclassId = selectedClass.subclassUnlockedAt(1)
                  ? _resolveSelectedSubclassId(classSubclasses)
                  : null;

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
                  // A folga da barra de navegação entra aqui: o botão de criar
                  // é o último filho, e sem ela ficava atrás dos controles do
                  // sistema no fim da rolagem.
                  padding: context.scrollContentPadding(),
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
                    AlignmentField(
                      value: _selectedAlignment,
                      onChanged: (value) =>
                          setState(() => _selectedAlignment = value),
                    ),
                    const SizedBox(height: 16),
                    _PortraitField(
                      picked: _pickedPortrait,
                      onPick: _pickPortrait,
                      onClear: () => setState(() => _pickedPortrait = null),
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
                          // Bônus e perícias são da raça anterior: manter faria
                          // o Anão herdar a escolha feita para o Elfo.
                          _bonusPicks.clear();
                          _raceSkillPicks.clear();
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
                            _bonusPicks.clear();
                            _raceSkillPicks.clear();
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
                      if (_isCustomBackground)
                        CustomBackgroundForm(
                          nameController: _customBackgroundNameController,
                          featuresController:
                              _customBackgroundFeaturesController,
                          skillOneId: _customBackgroundSkillOne,
                          skillTwoId: _customBackgroundSkillTwo,
                          onSkillsChanged: (one, two) {
                            setState(() {
                              _customBackgroundSkillOne = one;
                              _customBackgroundSkillTwo = two;
                            });
                          },
                        ),
                    ],
                    const SizedBox(height: 12),
                    _RaceSummaryCard(
                      race: combinedRace,
                      bonuses: _allBonusesOf(combinedRace),
                    ),
                    const SizedBox(height: 12),
                    ..._buildAbilityBonusSection(combinedRace),
                    ..._buildRaceSkillSection(combinedRace),
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
                          final previous = selectedClass;
                          _selectedClassId = value;
                          // A subclasse pertence à classe anterior.
                          _selectedSubclassId = null;
                          // As perícias marcadas dentro da lista da classe
                          // anterior também: manter faria um Ladino nascer com
                          // as quatro escolhas de um Bardo já gastas.
                          _selectedSkills.removeAll(
                            _classSkillPicks(previous).toList(growable: false),
                          );
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma classe.';
                        }
                        return null;
                      },
                    ),
                    ..._buildSubclassSection(selectedClass, classSubclasses),
                    const SizedBox(height: 20),
                    Text(
                      'Perícias',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ..._buildClassSkillSection(selectedClass),
                    ..._buildExtraSkillSection(selectedClass),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _saving
                          ? null
                          : () => _save(
                                classes,
                                combinedRace,
                                effectiveClassId,
                                backgrounds,
                                effectiveSubclassId,
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

    // O modo mais aberto ganha: o Shifter usa padrão flexível na raça base e
    // as naturezas bestiais não mexem em atributo, então a combinação tem que
    // continuar flexível.
    final mode = baseRace.abilityBonusMode == AbilityBonusMode.flexible ||
            subrace?.abilityBonusMode == AbilityBonusMode.flexible
        ? AbilityBonusMode.flexible
        : baseRace.abilityBonusMode == AbilityBonusMode.choice ||
              subrace?.abilityBonusMode == AbilityBonusMode.choice
        ? AbilityBonusMode.choice
        : AbilityBonusMode.fixed;

    return _CombinedRaceData(
      idToSave: subrace?.id ?? baseRace.id,
      name: name,
      description: description,
      size: subrace?.size ?? baseRace.size,
      speed: subrace?.speed ?? baseRace.speed,
      abilityBonusMode: mode,
      abilityBonusChoices: [
        ...baseRace.abilityBonusChoices,
        if (subrace != null) ...subrace.abilityBonusChoices,
      ],
      grantedSkills: <String>{
        ...baseRace.grantedSkills,
        if (subrace != null) ...subrace.grantedSkills,
      }.toList(growable: false),
      skillChoice: baseRace.skillChoice ?? subrace?.skillChoice,
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
    String? subclassId,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    // O formulário é um ListView: os campos que saem da viewport são
    // desmontados e se desregistram do Form, então `validate()` não enxerga
    // mais os validators deles. As regras que não podem escapar são checadas
    // aqui de novo, contra o estado, e não contra a árvore de widgets.
    final raceChoice = selectedRace.skillChoice;
    final raceSkillsPicked = raceChoice == null
        ? 0
        : _raceSkillPicks.where(raceChoice.options.contains).length;

    final selectedClass = classes.firstWhere(
      (item) => item.id == effectiveClassId,
    );

    final classSkillsPicked = _classSkillPicks(selectedClass).length;

    final missing = <String>[
      if (_nameController.text.trim().isEmpty) 'o nome do personagem',
      if (_isCustomBackground &&
          (_customBackgroundSkillOne == null ||
              _customBackgroundSkillTwo == null))
        'as duas perícias do antecedente',
      // A tela já impede passar do limite; o que falta checar é ficar abaixo
      // dele, porque a seção sai da viewport e o Form não a valida mais.
      if (selectedClass.hasSkillChoices &&
          classSkillsPicked < selectedClass.skillChoices)
        'as ${selectedClass.skillChoices} perícias da classe',
      if (raceChoice != null && raceSkillsPicked < raceChoice.choose)
        raceChoice.choose == 1
            ? 'a perícia da raça'
            : 'as ${raceChoice.choose} perícias da raça',
    ];

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falta preencher ${missing.join(' e ')}.')),
      );
      return;
    }

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

      final portraitPath = await _storePortrait(id);

      final character = Character(
        id: id,
        name: _nameController.text.trim(),
        portraitPath: portraitPath,
        playerName: _playerController.text.trim().isEmpty
            ? null
            : _playerController.text.trim(),
        speciesId: selectedRace.idToSave,
        backgroundId: _selectedBackgroundId,
        alignment: _selectedAlignment,
        customBackground: customBackground,
        abilityScores: finalScores,
        classLevels: [
          ClassLevel(
            classId: selectedClass.id,
            subclassId: subclassId,
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
          speedInMeters: selectedRace.speed ?? 9,
        ),
        savingThrowProficiencies: _savingThrowsForClass(selectedClass),
        skillProficiencies: _buildSkillProficienciesFromSelection(
          backgroundSkills,
          selectedRace,
        ),
        createdAt: now,
        updatedAt: now,
      );

      await repository.create(character);

      // Clérigo, Feiticeiro e Bruxo escolhem a subclasse já no 1º nível, então
      // as magias dela precisam entrar no livro assim que o personagem nasce.
      if (subclassId != null) {
        await _syncSubclassSpells(id);
      }

      if (!mounted) return;
      await AppNavigator.replaceWithCharacterSheet(context, characterId: id);
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

  /// Coloca as magias da subclasse no livro do personagem recém-criado.
  ///
  /// Não interrompe a criação se falhar: o personagem já existe, e perder a
  /// ficha inteira por causa das magias seria pior que avisar.
  Future<void> _syncSubclassSpells(String characterId) async {
    try {
      final subclasses = await ref.read(
        compendium_providers.subclassEntriesProvider.future,
      );
      final spellIndex = await ref.read(spellNameIndexProvider.future);

      await ref.read(syncSubclassSpellsProvider)(
        characterId: characterId,
        subclasses: subclasses,
        spellIndex: spellIndex,
      );
    } catch (error, stackTrace) {
      debugPrint('Falha ao sincronizar magias de subclasse: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Personagem criado, mas as magias da subclasse não entraram. '
              'Adicione pelo gerenciador de magias.',
            ),
          ),
        );
      }
    }
  }

  String? _resolveSelectedSubclassId(List<SubclassEntry> options) {
    if (options.isEmpty) return null;

    final current = _selectedSubclassId;
    if (current != null && options.any((item) => item.id == current)) {
      return current;
    }

    return options.first.id;
  }

  /// Seletor de subclasse.
  ///
  /// O personagem novo começa no 1º nível, então o seletor só aparece para
  /// quem escolhe já no 1º (Clérigo, Feiticeiro, Bruxo). Nas outras classes
  /// fica o aviso do nível em que a escolha vai acontecer, para o jogador não
  /// procurar por uma opção que ainda não existe.
  List<Widget> _buildSubclassSection(
    ClassEntry classEntry,
    List<SubclassEntry> options,
  ) {
    final label = classEntry.subclassLabelOrDefault;

    if (!classEntry.subclassUnlockedAt(1)) {
      final level = classEntry.subclassLevel;

      return [
        const SizedBox(height: 8),
        Text(
          level == null
              ? '$label: esta classe não define nível de escolha.'
              : '$label: você escolhe no $levelº nível.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ];
    }

    if (options.isEmpty) {
      return [
        const SizedBox(height: 8),
        Text(
          '$label: nenhuma opção cadastrada no compêndio ainda.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.onDarkVariant,
          ),
        ),
      ];
    }

    final effectiveId = _resolveSelectedSubclassId(options);
    final selected = options.firstWhere((item) => item.id == effectiveId);

    return [
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: effectiveId,
        decoration: InputDecoration(labelText: label),
        items: options
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.name),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedSubclassId = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Selecione ${label.toLowerCase()}.';
          }
          return null;
        },
      ),
      SubclassSummary(subclass: selected, level: 1),
    ];
  }

  /// Controles dos bônus de atributo que dependem de escolha.
  ///
  /// Três situações caem aqui: o padrão flexível de Mordenkainen (+2/+1 ou
  /// +1/+1/+1), as raças com parte à escolha (Meio-Elfo, Híbrido Simic) e a
  /// origem personalizada, que é opcional e substitui os bônus da raça.
  List<Widget> _buildAbilityBonusSection(_CombinedRaceData race) {
    final slots = _bonusSlots(race);
    final abilities = _resolveBonusAbilities(race);
    final fixed = _fixedBonusesOf(race);

    return [
      if (race.abilityBonusMode == AbilityBonusMode.flexible) ...[
        Text(
          'Bônus de atributo',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Esta raça usa o padrão flexível: escolha como distribuir.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(value: false, label: Text('+2 e +1')),
            ButtonSegment<bool>(value: true, label: Text('+1, +1 e +1')),
          ],
          selected: {_flexibleTriple},
          onSelectionChanged: (selection) {
            setState(() {
              _flexibleTriple = selection.first;
              // As posições mudam de significado ao trocar a variante.
              _bonusPicks.clear();
            });
          },
        ),
        const SizedBox(height: 12),
      ],
      if (race.abilityBonusMode == AbilityBonusMode.fixed &&
          race.allowsCustomOrigin) ...[
        SwitchListTile(
          value: _useCustomOrigin,
          onChanged: (value) {
            setState(() {
              _useCustomOrigin = value;
              _bonusPicks.clear();
            });
          },
          title: const Text('Usar origem customizada'),
          subtitle: const Text(
            'Regra opcional: troca os bônus da raça por +2 em um atributo e '
            '+1 em outro.',
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
      for (var index = 0; index < slots.length; index++) ...[
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: abilities[index],
          decoration: InputDecoration(
            labelText: 'Atributo que recebe +${slots[index]}',
          ),
          items: _abilityKeys
              // Não deixa repetir atributo nem cair em cima de um bônus que a
              // raça já concede: a regra não permite somar dois no mesmo.
              .where(
                (ability) =>
                    ability == abilities[index] ||
                    (!fixed.containsKey(ability) &&
                        !abilities.contains(ability)),
              )
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
              _bonusPicks[index] = value;
            });
          },
        ),
      ],
      if (slots.isNotEmpty) const SizedBox(height: 4),
    ];
  }

  /// Perícias que o jogador já marcou dentro das opções da classe.
  Iterable<String> _classSkillPicks(ClassEntry entry) {
    return _selectedSkills.where(entry.skillOptions.contains);
  }

  /// Perícias da classe, limitadas ao que ela concede.
  ///
  /// A classe dá uma quantidade fixa: quase todas 2, bardo e patrulheiro 3,
  /// ladino 4. Antes a tela listava as opções e aceitava marcar quantas o
  /// jogador quisesse, o que virava uma ficha fora das regras logo na criação.
  List<Widget> _buildClassSkillSection(ClassEntry entry) {
    final options = entry.skillOptions
        .map(Skill.fromId)
        .whereType<Skill>()
        .toList(growable: false);

    if (options.isEmpty) return const [];

    final picked = _classSkillPicks(entry).length;
    final limit = entry.skillChoices;
    // Sem quantidade declarada no asset a tela não trava nada: melhor deixar
    // escolher que impedir por falta de dado.
    final atLimit = entry.hasSkillChoices && picked >= limit;

    return [
      const SizedBox(height: 8),
      Text(
        'Perícias da classe',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      const SizedBox(height: 4),
      if (entry.hasSkillChoices)
        Text(
          'Perícias da classe: ${entry.skillChoiceLabel(picked)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: picked == limit
                ? AppColors.onDarkVariant
                : AppColors.error,
          ),
        )
      else
        Text(
          '${entry.name} não declara quantas perícias concede.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      const SizedBox(height: 4),
      ...options.map((skill) {
        final selected = _selectedSkills.contains(skill.id);

        return CheckboxListTile(
          // A seção seguinte repete rótulos; a key separa os dois grupos.
          key: ValueKey('class-skill-${skill.id}'),
          value: selected,
          // Desabilitar no limite deixa claro que acabou, em vez de aceitar a
          // marcação e reclamar só ao salvar.
          onChanged: atLimit && !selected
              ? null
              : (value) {
                  setState(() {
                    if (value == true) {
                      _selectedSkills.add(skill.id);
                    } else {
                      _selectedSkills.remove(skill.id);
                    }
                  });
                },
          title: Text('${skill.label} (${skill.abbreviation})'),
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );
      }),
    ];
  }

  /// Perícias fora da lista da classe.
  ///
  /// Continuam disponíveis porque antecedente, raça, talento e concessão do
  /// mestre também dão perícia, e a criação não modela todas essas origens.
  /// Ficam separadas para não parecerem parte da cota da classe.
  List<Widget> _buildExtraSkillSection(ClassEntry entry) {
    final extras = Skill.sortedByLabel
        .where((skill) => !entry.skillOptions.contains(skill.id))
        .toList(growable: false);

    if (extras.isEmpty) return const [];

    return [
      const SizedBox(height: 12),
      Text(
        'Outras perícias',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      const SizedBox(height: 4),
      Text(
        'Fora da lista de ${entry.name}. Não contam na cota da classe: '
        'marque só o que vier de outra origem.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 4),
      ...extras.map((skill) {
        return CheckboxListTile(
          key: ValueKey('extra-skill-${skill.id}'),
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
          title: Text('${skill.label} (${skill.abbreviation})'),
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );
      }),
    ];
  }

  /// Perícias que vêm da raça: as concedidas direto e as que o jogador escolhe.
  List<Widget> _buildRaceSkillSection(_CombinedRaceData race) {
    final choice = race.skillChoice;
    if (race.grantedSkills.isEmpty && choice == null) return const [];

    final granted = race.grantedSkills
        .map(Skill.fromId)
        .whereType<Skill>()
        .toList(growable: false);

    final picks = _raceSkillPicks.where(
      (id) => choice?.options.contains(id) ?? false,
    );

    return [
      const SizedBox(height: 12),
      Text(
        'Perícias da raça',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      if (granted.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(
          'Já concedidas: ${granted.map((skill) => skill.label).join(', ')}.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      if (choice != null) ...[
        const SizedBox(height: 4),
        Text(
          'Escolha ${choice.choose} '
          '(${picks.length} de ${choice.choose} marcadas).',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: picks.length == choice.choose
                ? AppColors.onDarkVariant
                : AppColors.error,
          ),
        ),
        const SizedBox(height: 4),
        ...choice.options.map(Skill.fromId).whereType<Skill>().map((skill) {
          final selected = _raceSkillPicks.contains(skill.id);

          return CheckboxListTile(
            // A lista geral de perícias tem itens com o mesmo rótulo; a key
            // separa os dois grupos.
            key: ValueKey('race-skill-${skill.id}'),
            value: selected,
            // Impede marcar além do limite, em vez de avisar depois.
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  if (picks.length >= choice.choose) return;
                  _raceSkillPicks.add(skill.id);
                } else {
                  _raceSkillPicks.remove(skill.id);
                }
              });
            },
            title: Text('${skill.label} (${skill.abbreviation})'),
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    ];
  }

  /// Valores que o jogador distribui, conforme o modo da raça.
  ///
  /// Vazio quando a raça define tudo e o jogador não pediu origem
  /// personalizada.
  List<int> _bonusSlots(_CombinedRaceData race) {
    switch (race.abilityBonusMode) {
      case AbilityBonusMode.flexible:
        return _flexibleTriple ? const [1, 1, 1] : const [2, 1];
      case AbilityBonusMode.choice:
        return race.abilityBonusChoices;
      case AbilityBonusMode.fixed:
        return _useCustomOrigin && race.allowsCustomOrigin
            ? const [2, 1]
            : const [];
    }
  }

  /// Bônus que a raça define sozinha.
  ///
  /// A origem personalizada substitui os bônus da raça, e o padrão flexível
  /// não tem parte fixa.
  Map<String, int> _fixedBonusesOf(_CombinedRaceData race) {
    if (race.abilityBonusMode == AbilityBonusMode.flexible) return const {};
    if (_useCustomOrigin && race.allowsCustomOrigin) return const {};
    return race.fixedAbilityBonuses;
  }

  /// Resolve em qual atributo cai cada bônus distribuído.
  ///
  /// Posição sem escolha do jogador, ou com escolha que colidiria com outro
  /// bônus, cai no primeiro atributo livre. Assim a ficha nunca soma dois
  /// bônus no mesmo atributo, que a regra não permite.
  List<String> _resolveBonusAbilities(_CombinedRaceData race) {
    final slots = _bonusSlots(race);
    if (slots.isEmpty) return const [];

    final taken = <String>{..._fixedBonusesOf(race).keys};
    final resolved = <String>[];

    for (var index = 0; index < slots.length; index++) {
      final picked = _bonusPicks[index];

      if (picked != null && !taken.contains(picked)) {
        taken.add(picked);
        resolved.add(picked);
        continue;
      }

      final fallback = _abilityKeys.firstWhere(
        (ability) => !taken.contains(ability),
        orElse: () => _abilityKeys.first,
      );
      taken.add(fallback);
      resolved.add(fallback);
    }

    return resolved;
  }

  Map<String, int> _allBonusesOf(_CombinedRaceData race) {
    final bonuses = <String, int>{..._fixedBonusesOf(race)};
    final slots = _bonusSlots(race);
    final abilities = _resolveBonusAbilities(race);

    for (var index = 0; index < abilities.length; index++) {
      final ability = abilities[index];
      bonuses[ability] = (bonuses[ability] ?? 0) + slots[index];
    }

    return bonuses;
  }

  AbilityScores _buildFinalAbilityScores(_CombinedRaceData race) {
    final bonuses = _allBonusesOf(race);

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

  /// Junta tudo que dá proficiência em perícia no nível 1: o que o jogador
  /// marcou, o que o antecedente concede e o que vem da raça — concedido ou
  /// escolhido dentro das opções dela.
  SkillProficiencies _buildSkillProficienciesFromSelection(
    List<Skill> backgroundSkills,
    _CombinedRaceData race,
  ) {
    // A escolha da raça é filtrada contra as opções dela: sem isso, uma opção
    // desmarcada depois de trocar de raça entraria de carona.
    final raceOptions = race.skillChoice?.options ?? const <String>[];
    final racePicks = _raceSkillPicks.where(raceOptions.contains);

    return GrantedSkills.apply(const SkillProficiencies(), [
      // Perícias de classe marcadas pelo jogador.
      ...GrantedSkills.fromIds(_selectedSkills),
      ...backgroundSkills,
      ...GrantedSkills.fromIds(race.grantedSkills),
      ...GrantedSkills.fromIds(racePicks),
    ]);
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

class _CombinedRaceData {
  const _CombinedRaceData({
    required this.idToSave,
    required this.name,
    required this.allowsCustomOrigin,
    required this.abilityBonusMode,
    required this.fixedAbilityBonuses,
    required this.abilityBonusChoices,
    required this.grantedSkills,
    required this.traits,
    required this.languages,
    this.skillChoice,
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

  /// Deslocamento em metros.
  final double? speed;
  final String? creatureType;
  final int? darkvision;
  final bool allowsCustomOrigin;
  final AbilityBonusMode abilityBonusMode;
  final Map<String, int> fixedAbilityBonuses;
  final List<int> abilityBonusChoices;
  final List<String> grantedSkills;
  final RaceSkillChoice? skillChoice;
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
  const _RaceSummaryCard({required this.race, required this.bonuses});

  final _CombinedRaceData race;

  /// Bônus já resolvidos: parte fixa da raça mais o que o jogador distribuiu.
  final Map<String, int> bonuses;

  @override
  Widget build(BuildContext context) {

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
              'Deslocamento: ${formatMeters(race.speed ?? 9)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (race.darkvision != null) ...[
              const SizedBox(height: 4),
              Text(
                'Visão no Escuro: ${formatMeters(race.darkvision)}',
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


/// Campo de aparência do personagem na criação.
///
/// Mostra a imagem escolhida direto do caminho de origem: a cópia para o
/// diretório do app só acontece ao salvar, então aqui o preview aponta para o
/// arquivo temporário do gerenciador de arquivos.
class _PortraitField extends StatelessWidget {
  const _PortraitField({
    required this.picked,
    required this.onPick,
    required this.onClear,
  });

  final PickedImage? picked;
  final Future<void> Function() onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final has = picked != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PortraitAvatar(
          path: picked?.path,
          size: 78,
          emptyLabel: 'imagem',
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aparência',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 2),
              Text(
                has
                    ? 'Imagem escolhida. Ela é salva junto com o personagem.'
                    : 'Opcional. Você também pode adicionar depois, na ficha.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: Text(has ? 'Trocar' : 'Escolher imagem'),
                  ),
                  if (has)
                    TextButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Remover'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
