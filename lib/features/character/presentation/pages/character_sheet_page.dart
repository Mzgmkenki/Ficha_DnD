import 'package:dnd_ficha_app/core/routing/app_navigator.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/level_up_character_class.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/level_up_class_dialog.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/ability_score_block.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/background_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/character_portrait.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/character_spells_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/class_features_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/combat_summary_card.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/conditions_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/currency_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/magic_items_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/racial_traits_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/rest_and_resources_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/saving_throws_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/sheet_header_action.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/skills_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/spell_slots_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/spellcasting_summary_panel.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

class CharacterSheetPage extends ConsumerStatefulWidget {
  const CharacterSheetPage({required this.characterId, super.key});

  final String characterId;

  @override
  ConsumerState<CharacterSheetPage> createState() => _CharacterSheetPageState();
}

class _CharacterSheetPageState extends ConsumerState<CharacterSheetPage> {
  bool? _showSpellcasting;

  /// Trava o atalho enquanto a subida grava, para dois toques rápidos não
  /// virarem dois níveis.
  bool _levelingUp = false;

  /// Trava a exportação: gerar o PDF lê o compêndio inteiro e leva um instante.
  bool _exportingPdf = false;

  @override
  Widget build(BuildContext context) {
    final characterAsync = ref.watch(characterByIdProvider(widget.characterId));
    final classesAsync = ref.watch(classEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha do personagem'),
        actions: [
          IconButton(
            tooltip: 'Exportar em PDF',
            onPressed: _exportingPdf ? null : _exportPdf,
            icon: _exportingPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: characterAsync.when(
        data: (character) {
          if (character == null) {
            return const Center(child: Text('Personagem não encontrado.'));
          }

          return classesAsync.when(
            data: (classes) {
              final isCaster = _isCaster(character, classes);
              _showSpellcasting ??= isCaster;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CharacterPortrait(
                        characterId: character.id,
                        portraitPath: character.portraitPath,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              character.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nível ${character.totalLevel} • Proficiência +${character.proficiencyBonus}',
                            ),
                            if (character.playerName != null &&
                                character.playerName!.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Jogador: ${character.playerName}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openIdentityEditor(character),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar identidade',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _SectionHeader(
                    title: 'Classes',
                    actionLabel: 'Editar nível',
                    actionIcon: Icons.upgrade,
                    onPressed: () =>
                        AppNavigator.toEditClassLevels(context, character: character),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SheetHeaderAction(
                      label: _levelingUp ? 'Subindo...' : 'Subir de nível',
                      icon: Icons.arrow_circle_up_outlined,
                      // No teto o botão fica visível mas apagado: some da tela
                      // seria pior, o jogador ia procurar por ele.
                      onPressed: (_levelingUp ||
                              character.totalLevel >= maxCharacterLevel)
                          ? null
                          : () => _levelUp(character, classes),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: character.classLevels.map((classLevel) {
                      final className = _classNameForId(
                        classes,
                        classLevel.classId,
                      );
                      return Chip(
                        label: Text('$className Nv. ${classLevel.level}'),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Combate',
                    actionLabel: 'Editar HP',
                    actionIcon: Icons.favorite_border,
                    onPressed: () =>
                        AppNavigator.toEditHitPoints(context, character: character),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SheetHeaderAction(
                      label: 'Calcular CA',
                      icon: Icons.shield_outlined,
                      onPressed: () => AppNavigator.toEditArmorClass(
                        context,
                        character: character,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CombatSummaryCard(character: character),

                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Condições'),
                  const SizedBox(height: 8),
                  ConditionsPanel(character: character),

                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Recursos e descanso'),
                  const SizedBox(height: 8),
                  RestAndResourcesPanel(
                    character: character,
                    classes: classes,
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Atributos',
                    actionLabel: 'Editar',
                    actionIcon: Icons.tune,
                    onPressed: () => AppNavigator.toEditAbilityScores(
                      context,
                      character: character,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final ability in Ability.values)
                        AbilityScoreBlock(
                          ability: ability,
                          value: character.abilityScores.valueFor(ability),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Proficiências',
                    actionLabel: 'Editar',
                    actionIcon: Icons.verified_outlined,
                    onPressed: () => AppNavigator.toEditProficiencies(
                      context,
                      character: character,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SavingThrowsPanel(character: character),

                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Perícias'),
                  const SizedBox(height: 8),
                  SkillsPanel(character: character),

                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Slots de magia'),
                  const SizedBox(height: 8),
                  SpellSlotsPanel(
                    classLevels: character.classLevels,
                    characterId: character.id,
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Conjuração',
                    actionLabel: _showSpellcasting == true ? 'Ocultar' : 'Mostrar',
                    actionIcon: _showSpellcasting == true
                        ? Icons.expand_less
                        : Icons.expand_more,
                    onPressed: () {
                      setState(() {
                        _showSpellcasting = !(_showSpellcasting ?? false);
                      });
                    },
                  ),
                  if (_showSpellcasting == true) ...[
                    const SizedBox(height: 8),
                    SpellcastingSummaryPanel(
                      character: character,
                      classes: classes,
                    ),
                  ],

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Magias do personagem',
                    actionLabel: 'Gerenciar',
                    actionIcon: Icons.auto_fix_high,
                    onPressed: () => AppNavigator.toManageSpells(
                      context,
                      characterId: character.id,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CharacterSpellsPanel(character: character),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Itens mágicos',
                    actionLabel: 'Gerenciar',
                    actionIcon: Icons.backpack_outlined,
                    onPressed: () => AppNavigator.toManageMagicItems(
                      context,
                      characterId: character.id,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MagicItemsPanel(character: character),

                  const SizedBox(height: 16),
                  CurrencyPanel(character: character),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Antecedente',
                    actionLabel: 'Editar',
                    actionIcon: Icons.history_edu,
                    onPressed: () => _openIdentityEditor(character),
                  ),
                  const SizedBox(height: 8),
                  BackgroundPanel(
                    backgroundId: character.backgroundId,
                    customBackground: character.customBackground,
                  ),

                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Características raciais'),
                  const SizedBox(height: 8),
                  RacialTraitsPanel(speciesId: character.speciesId),

                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Características de classe'),
                  const SizedBox(height: 8),
                  ClassFeaturesPanel(classLevels: character.classLevels),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Anotações',
                    actionLabel: 'Editar',
                    actionIcon: Icons.edit_note,
                    onPressed: () => _openIdentityEditor(character),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        character.notes.isEmpty
                            ? 'Sem anotações ainda.'
                            : character.notes,
                      ),
                    ),
                  ),
                ],
              );
            },
            error: (error, stackTrace) {
              return Center(child: Text('Erro ao carregar classes: $error'));
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, stackTrace) => Center(child: Text('Erro: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _openIdentityEditor(Character character) {
    return AppNavigator.toEditIdentity(context, character: character);
  }

  /// Gera o PDF e entrega ao sistema.
  ///
  /// Usa a folha de compartilhamento em vez de gravar num diretório: o jogador
  /// escolhe onde o arquivo vai parar (nuvem, mensagem, impressora) e o app não
  /// precisa de permissão de escrita nem de um caminho que ele nunca acha.
  Future<void> _exportPdf() async {
    setState(() {
      _exportingPdf = true;
    });

    try {
      final pdf = await ref.read(exportCharacterPdfProvider)(
        widget.characterId,
      );

      await Printing.sharePdf(bytes: pdf.bytes, filename: pdf.fileName);
    } catch (error, stackTrace) {
      debugPrint('Falha ao exportar o PDF: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar o PDF: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _exportingPdf = false;
        });
      }
    }
  }

  /// Atalho de subida de nível.
  ///
  /// Com uma classe só sobe direto. No multiclasse pergunta qual classe recebe
  /// o nível, porque adivinhar erraria justamente no caso em que a escolha
  /// importa.
  Future<void> _levelUp(Character character, List<ClassEntry> classes) async {
    final String? classId;

    if (character.classLevels.length == 1) {
      classId = character.classLevels.single.classId;
    } else {
      classId = await showLevelUpClassDialog(
        context: context,
        totalLevel: character.totalLevel,
        options: character.classLevels
            .map(
              (item) => LevelUpClassOption(
                classId: item.classId,
                className: _classNameForId(classes, item.classId),
                level: item.level,
              ),
            )
            .toList(growable: false),
      );
    }

    if (classId == null) return;
    if (!mounted) return;

    setState(() {
      _levelingUp = true;
    });

    try {
      final subclasses = await ref.read(subclassEntriesProvider.future);
      final spellIndex = await ref.read(spellNameIndexProvider.future);

      final outcome = await ref.read(levelUpCharacterClassProvider)(
        characterId: widget.characterId,
        classId: classId,
        classes: classes,
        subclasses: subclasses,
        spellIndex: spellIndex,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_levelUpMessage(outcome))),
      );
    } catch (error, stackTrace) {
      debugPrint('Falha ao subir de nível: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao subir de nível: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _levelingUp = false;
        });
      }
    }
  }

  String _levelUpMessage(LevelUpOutcome outcome) {
    final parts = <String>[
      '${outcome.className} agora está no nível ${outcome.newLevel} '
          '(total ${outcome.totalLevel}).',
    ];

    if (outcome.pendingSubclassLabel != null) {
      parts.add(
        'Escolha ${outcome.pendingSubclassLabel} em Editar nível.',
      );
    }

    if (outcome.spellSyncError != null) {
      parts.add(
        'As magias da subclasse não entraram; use o gerenciador de magias.',
      );
    }

    return parts.join(' ');
  }

  /// Usa o compêndio como fonte da verdade.
  ///
  /// Antes havia também uma lista de ids fixa aqui, que ignorava
  /// `ClassEntry.isSpellcaster`: classe nova ou homebrew marcada como
  /// conjuradora no compêndio não aparecia como tal na ficha.
  bool _isCaster(Character character, List<ClassEntry> classes) {
    for (final classLevel in character.classLevels) {
      for (final entry in classes) {
        if (entry.id == classLevel.classId && entry.isSpellcaster) {
          return true;
        }
      }
    }

    return false;
  }

  String _classNameForId(List<ClassEntry> classes, String classId) {
    for (final item in classes) {
      if (item.id == classId) {
        return item.name;
      }
    }
    return classId;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onPressed,
  });

  final String title;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final hasAction =
        actionLabel != null && actionIcon != null && onPressed != null;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (hasAction) ...[
          // A fonte decorativa é larga: sem esta folga o rótulo encosta no
          // título quando o nome da seção é comprido.
          const SizedBox(width: 8),
          SheetHeaderAction(
            label: actionLabel!,
            icon: actionIcon!,
            onPressed: onPressed!,
          ),
        ],
      ],
    );
  }
}