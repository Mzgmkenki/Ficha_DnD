import 'package:dnd_ficha_app/core/routing/route_args.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_creation_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_list_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_sheet_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_transfer_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/combat_panel_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_ability_scores_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_armor_class_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_class_levels_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_hit_points_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_identity_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_initiative_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_languages_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_proficiencies_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/manage_character_magic_items_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/manage_character_spells_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/manage_character_weapons_page.dart';
import 'package:dnd_ficha_app/features/compendium/presentation/pages/spell_compendium_page.dart';
import 'package:dnd_ficha_app/features/compendium/presentation/pages/spell_detail_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String characterList = '/';
  static const String characterCreation = '/character/create';
  static const String characterSheet = '/character/sheet';
  static const String characterTransfer = '/character/transfer';

  static const String editIdentity = '/character/identity';
  static const String editAbilityScores = '/character/ability-scores';
  static const String editHitPoints = '/character/hit-points';
  static const String editArmorClass = '/character/armor-class';
  static const String editLanguages = '/character/languages';
  static const String editInitiative = '/character/initiative';
  static const String combatPanel = '/character/combat-panel';
  static const String editClassLevels = '/character/class-levels';
  static const String editProficiencies = '/character/proficiencies';
  static const String manageSpells = '/character/spells';
  static const String manageMagicItems = '/character/magic-items';
  static const String manageWeapons = '/character/weapons';

  static const String spellCompendium = '/compendium/spells';
  static const String spellDetail = '/compendium/spells/detail';
}

/// Constrói todas as rotas do app.
///
/// Antes só três telas passavam por aqui e o resto era aberto com
/// `MaterialPageRoute` espalhado pelas páginas. Com tudo centralizado, os
/// argumentos são validados num lugar só e um argumento errado vira uma tela
/// de erro legível em vez de um crash de cast.
class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.characterList:
        return _page(settings, (_) => const CharacterListPage());

      case AppRoutes.characterCreation:
        return _page(settings, (_) => const CharacterCreationPage());

      case AppRoutes.spellCompendium:
        return _page(settings, (_) => const SpellCompendiumPage());

      case AppRoutes.characterSheet:
        return _withArgs<CharacterIdArgs>(
          settings,
          (args) => CharacterSheetPage(characterId: args.characterId),
        );

      case AppRoutes.characterTransfer:
        return _page(settings, (_) => const CharacterTransferPage());

      case AppRoutes.editIdentity:
        return _withArgs<EditIdentityArgs>(
          settings,
          (args) => EditIdentityPage(
            characterId: args.character.id,
            initialName: args.character.name,
            initialNotes: args.character.notes,
            initialPlayerName: args.character.playerName,
            initialBackgroundId: args.character.backgroundId,
            initialCustomBackground: args.character.customBackground,
            initialAlignment: args.character.alignment,
          ),
        );

      case AppRoutes.editAbilityScores:
        return _withArgs<EditAbilityScoresArgs>(
          settings,
          (args) => EditAbilityScoresPage(
            characterId: args.characterId,
            initialScores: args.scores,
          ),
        );

      case AppRoutes.editHitPoints:
        return _withArgs<EditHitPointsArgs>(
          settings,
          (args) => EditHitPointsPage(
            characterId: args.characterId,
            initialHitPoints: args.hitPoints,
          ),
        );

      case AppRoutes.editLanguages:
        return _withArgs<EditLanguagesArgs>(
          settings,
          (args) => EditLanguagesPage(character: args.character),
        );

      case AppRoutes.editArmorClass:
        return _withArgs<EditArmorClassArgs>(
          settings,
          (args) => EditArmorClassPage(character: args.character),
        );

      case AppRoutes.editInitiative:
        return _withArgs<EditInitiativeArgs>(
          settings,
          (args) => EditInitiativePage(character: args.character),
        );

      case AppRoutes.combatPanel:
        return _withArgs<CharacterIdArgs>(
          settings,
          (args) => CombatPanelPage(characterId: args.characterId),
        );

      case AppRoutes.editClassLevels:
        return _withArgs<EditClassLevelsArgs>(
          settings,
          (args) => EditClassLevelsPage(
            characterId: args.characterId,
            initialClassLevels: args.classLevels,
            abilityScores: args.abilityScores,
          ),
        );

      case AppRoutes.editProficiencies:
        return _withArgs<EditProficienciesArgs>(
          settings,
          (args) => EditProficienciesPage(
            characterId: args.characterId,
            initialSavingThrows: args.savingThrows,
            initialSkills: args.skills,
          ),
        );

      case AppRoutes.manageSpells:
        return _withArgs<CharacterIdArgs>(
          settings,
          (args) => ManageCharacterSpellsPage(characterId: args.characterId),
        );

      case AppRoutes.manageMagicItems:
        return _withArgs<CharacterIdArgs>(
          settings,
          (args) =>
              ManageCharacterMagicItemsPage(characterId: args.characterId),
        );

      case AppRoutes.manageWeapons:
        return _withArgs<CharacterIdArgs>(
          settings,
          (args) => ManageCharacterWeaponsPage(characterId: args.characterId),
        );

      case AppRoutes.spellDetail:
        return _withArgs<SpellDetailArgs>(
          settings,
          (args) => SpellDetailPage(spell: args.spell),
        );

      default:
        return _errorRoute(
          settings,
          'Rota não encontrada: ${settings.name}',
        );
    }
  }

  MaterialPageRoute<T> _page<T>(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return MaterialPageRoute<T>(settings: settings, builder: builder);
  }

  /// Valida o argumento antes de construir a tela.
  Route<dynamic> _withArgs<A>(
    RouteSettings settings,
    Widget Function(A args) builder,
  ) {
    final args = settings.arguments;

    if (args is! A) {
      return _errorRoute(
        settings,
        'A rota ${settings.name} esperava $A e recebeu '
        '${args?.runtimeType ?? 'nada'}.',
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => builder(args),
    );
  }

  Route<dynamic> _errorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Erro de navegação')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wrong_location_outlined, size: 48),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
