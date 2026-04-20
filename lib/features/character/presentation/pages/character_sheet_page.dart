import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_ability_scores_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_class_levels_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_hit_points_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_proficiencies_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/manage_character_magic_items_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/manage_character_spells_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/ability_score_block.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/character_spells_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/class_features_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/combat_summary_card.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/magic_items_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/racial_traits_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/saving_throws_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/skills_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/spell_slots_panel.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterSheetPage extends ConsumerWidget {
  const CharacterSheetPage({required this.characterId, super.key});

  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(characterByIdProvider(characterId));
    final classesAsync = ref.watch(classEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ficha do personagem')),
      body: characterAsync.when(
        data: (character) {
          if (character == null) {
            return const Center(child: Text('Personagem não encontrado.'));
          }

          return classesAsync.when(
            data: (classes) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Classes',
                    actionLabel: 'Editar nível',
                    actionIcon: Icons.trending_up,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditClassLevelsPage(
                            characterId: character.id,
                            initialClassLevels: character.classLevels,
                            abilityScores: character.abilityScores,
                          ),
                        ),
                      );
                      ref.invalidate(characterByIdProvider(characterId));
                    },
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
                    actionIcon: Icons.favorite,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditHitPointsPage(
                            characterId: character.id,
                            initialHitPoints: character.hitPoints,
                          ),
                        ),
                      );
                      ref.invalidate(characterByIdProvider(characterId));
                    },
                  ),
                  const SizedBox(height: 8),
                  CombatSummaryCard(character: character),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Atributos',
                    actionLabel: 'Editar atributos',
                    actionIcon: Icons.tune,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditAbilityScoresPage(
                            characterId: character.id,
                            initialScores: character.abilityScores,
                          ),
                        ),
                      );
                      ref.invalidate(characterByIdProvider(characterId));
                    },
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      AbilityScoreBlock(
                        label: 'FOR',
                        value: character.abilityScores.strength,
                      ),
                      AbilityScoreBlock(
                        label: 'DES',
                        value: character.abilityScores.dexterity,
                      ),
                      AbilityScoreBlock(
                        label: 'CON',
                        value: character.abilityScores.constitution,
                      ),
                      AbilityScoreBlock(
                        label: 'INT',
                        value: character.abilityScores.intelligence,
                      ),
                      AbilityScoreBlock(
                        label: 'SAB',
                        value: character.abilityScores.wisdom,
                      ),
                      AbilityScoreBlock(
                        label: 'CAR',
                        value: character.abilityScores.charisma,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Proficiências',
                    actionLabel: 'Editar proficiências',
                    actionIcon: Icons.tune,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditProficienciesPage(
                            characterId: character.id,
                            initialSavingThrows:
                                character.savingThrowProficiencies,
                            initialSkills: character.skillProficiencies,
                          ),
                        ),
                      );
                      ref.invalidate(characterByIdProvider(characterId));
                    },
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
                    title: 'Magias do personagem',
                    actionLabel: 'Gerenciar magias',
                    actionIcon: Icons.menu_book,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ManageCharacterSpellsPage(
                            characterId: character.id,
                          ),
                        ),
                      );
                      ref.invalidate(characterByIdProvider(characterId));
                    },
                  ),
                  const SizedBox(height: 8),
                  CharacterSpellsPanel(character: character),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Itens mágicos',
                    actionLabel: 'Gerenciar itens',
                    actionIcon: Icons.inventory_2_outlined,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ManageCharacterMagicItemsPage(
                            characterId: character.id,
                          ),
                        ),
                      );
                      ref.invalidate(characterByIdProvider(characterId));
                    },
                  ),
                  const SizedBox(height: 8),
                  MagicItemsPanel(character: character),
                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Características raciais'),
                  const SizedBox(height: 8),
                  RacialTraitsPanel(speciesId: character.speciesId),
                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Características de classe'),
                  const SizedBox(height: 8),
                  ClassFeaturesPanel(classLevels: character.classLevels),
                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Anotações'),
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (hasAction)
          TextButton.icon(
            onPressed: onPressed,
            icon: Icon(actionIcon),
            label: Text(actionLabel!),
          ),
      ],
    );
  }
}