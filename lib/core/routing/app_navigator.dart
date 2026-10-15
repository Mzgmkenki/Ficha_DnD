import 'package:dnd_ficha_app/core/routing/app_router.dart';
import 'package:dnd_ficha_app/core/routing/route_args.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:flutter/material.dart';

/// Navegação tipada.
///
/// A UI chama estes métodos em vez de `pushNamed` com string e argumento
/// soltos: o compilador cobra os dados certos de cada tela, e não há mais
/// `MaterialPageRoute` espalhado pelas páginas.
class AppNavigator {
  const AppNavigator._();

  static Future<void> toCharacterCreation(BuildContext context) {
    return Navigator.of(context).pushNamed(AppRoutes.characterCreation);
  }

  static Future<void> toCharacterSheet(
    BuildContext context, {
    required String characterId,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.characterSheet,
      arguments: CharacterIdArgs(characterId),
    );
  }

  /// Usado depois de criar o personagem: a tela de criação sai da pilha.
  static Future<void> replaceWithCharacterSheet(
    BuildContext context, {
    required String characterId,
  }) {
    return Navigator.of(context).pushReplacementNamed(
      AppRoutes.characterSheet,
      arguments: CharacterIdArgs(characterId),
    );
  }

  static Future<void> toCharacterTransfer(BuildContext context) {
    return Navigator.of(context).pushNamed(AppRoutes.characterTransfer);
  }

  static Future<void> toEditIdentity(
    BuildContext context, {
    required Character character,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.editIdentity,
      arguments: EditIdentityArgs(character: character),
    );
  }

  static Future<void> toEditAbilityScores(
    BuildContext context, {
    required Character character,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.editAbilityScores,
      arguments: EditAbilityScoresArgs(
        characterId: character.id,
        scores: character.abilityScores,
      ),
    );
  }

  static Future<void> toEditHitPoints(
    BuildContext context, {
    required Character character,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.editHitPoints,
      arguments: EditHitPointsArgs(
        characterId: character.id,
        hitPoints: character.hitPoints,
      ),
    );
  }

  static Future<void> toEditArmorClass(
    BuildContext context, {
    required Character character,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.editArmorClass,
      arguments: EditArmorClassArgs(character: character),
    );
  }

  static Future<void> toEditLanguages(
    BuildContext context, {
    required Character character,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.editLanguages,
      arguments: EditLanguagesArgs(character: character),
    );
  }

  static Future<void> toEditInitiative(
    BuildContext context, {
    required Character character,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.editInitiative,
      arguments: EditInitiativeArgs(character: character),
    );
  }

  /// Abre o Painel de combate (Ações, Condições e Recursos) do personagem.
  ///
  /// Recebe o id, e não a entidade: o painel lê do provider para refletir na
  /// hora o que foi mudado na ficha, e vice-versa.
  static Future<void> toCombatPanel(
    BuildContext context, {
    required String characterId,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.combatPanel,
      arguments: CharacterIdArgs(characterId),
    );
  }

  static Future<void> toEditClassLevels(
    BuildContext context, {
    required Character character,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.editClassLevels,
      arguments: EditClassLevelsArgs(
        characterId: character.id,
        classLevels: character.classLevels,
        abilityScores: character.abilityScores,
      ),
    );
  }

  static Future<void> toEditProficiencies(
    BuildContext context, {
    required Character character,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.editProficiencies,
      arguments: EditProficienciesArgs(
        characterId: character.id,
        savingThrows: character.savingThrowProficiencies,
        skills: character.skillProficiencies,
      ),
    );
  }

  static Future<void> toManageSpells(
    BuildContext context, {
    required String characterId,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.manageSpells,
      arguments: CharacterIdArgs(characterId),
    );
  }

  static Future<void> toManageMagicItems(
    BuildContext context, {
    required String characterId,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.manageMagicItems,
      arguments: CharacterIdArgs(characterId),
    );
  }

  static Future<void> toManageWeapons(
    BuildContext context, {
    required String characterId,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.manageWeapons,
      arguments: CharacterIdArgs(characterId),
    );
  }

  static Future<void> toSpellCompendium(BuildContext context) {
    return Navigator.of(context).pushNamed(AppRoutes.spellCompendium);
  }

  static Future<void> toSpellDetail(
    BuildContext context, {
    required SpellEntry spell,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.spellDetail,
      arguments: SpellDetailArgs(spell: spell),
    );
  }
}
