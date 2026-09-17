import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';

/// Argumentos das rotas nomeadas.
///
/// Cada rota que precisa de dados declara aqui a sua classe, em vez de passar
/// um `Object?` solto pelo `RouteSettings`. Assim o roteador valida o tipo num
/// lugar só e a chamada de navegação não compila com o argumento errado.

/// Rotas que só precisam saber de qual personagem se trata.
class CharacterIdArgs {
  const CharacterIdArgs(this.characterId);

  final String characterId;
}

class EditIdentityArgs {
  const EditIdentityArgs({required this.character});

  final Character character;
}

class EditAbilityScoresArgs {
  const EditAbilityScoresArgs({
    required this.characterId,
    required this.scores,
  });

  final String characterId;
  final AbilityScores scores;
}

class EditHitPointsArgs {
  const EditHitPointsArgs({
    required this.characterId,
    required this.hitPoints,
  });

  final String characterId;
  final HitPoints hitPoints;
}

class EditClassLevelsArgs {
  const EditClassLevelsArgs({
    required this.characterId,
    required this.classLevels,
    required this.abilityScores,
  });

  final String characterId;
  final List<ClassLevel> classLevels;
  final AbilityScores abilityScores;
}

class EditProficienciesArgs {
  const EditProficienciesArgs({
    required this.characterId,
    required this.savingThrows,
    required this.skills,
  });

  final String characterId;
  final SavingThrowProficiencies savingThrows;
  final SkillProficiencies skills;
}

class EditArmorClassArgs {
  const EditArmorClassArgs({required this.character});

  final Character character;
}

class EditInitiativeArgs {
  const EditInitiativeArgs({required this.character});

  final Character character;
}

class SpellDetailArgs {
  const SpellDetailArgs({required this.spell});

  final SpellEntry spell;
}
