import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

/// Atributos todos em 10 (modificador 0), para o teste só mexer no que importa.
const AbilityScores flatScores = AbilityScores(
  strength: 10,
  dexterity: 10,
  constitution: 10,
  intelligence: 10,
  wisdom: 10,
  charisma: 10,
);

AbilityScores scoresWith({
  int strength = 10,
  int dexterity = 10,
  int constitution = 10,
  int intelligence = 10,
  int wisdom = 10,
  int charisma = 10,
}) {
  return AbilityScores(
    strength: strength,
    dexterity: dexterity,
    constitution: constitution,
    intelligence: intelligence,
    wisdom: wisdom,
    charisma: charisma,
  );
}

SkillProficiencies skillsWith(Map<Skill, ProficiencyLevel> levels) {
  return SkillProficiencies(levels: levels);
}

/// Personagem mínimo para testar regras. Só o que o teste declara importa.
Character characterFixture({
  String id = 'c1',
  String name = 'Teste',
  AbilityScores? abilityScores,
  List<ClassLevel> classLevels = const [
    ClassLevel(classId: 'fighter', level: 1),
  ],
  HitPoints hitPoints = const HitPoints(current: 10, maximum: 10),
  SkillProficiencies skillProficiencies = const SkillProficiencies(),
  List<CharacterSpell> spells = const [],
  int exhaustion = 0,
  Set<Condition> conditions = const {},
  int hitDiceUsed = 0,
}) {
  final now = DateTime(2026, 1, 1);

  return Character(
    id: id,
    name: name,
    abilityScores: abilityScores ?? flatScores,
    classLevels: classLevels,
    hitPoints: hitPoints,
    combatStats: const CombatStats(
      armorClass: 10,
      initiativeBonus: 0,
      speedInMeters: 9,
    ),
    skillProficiencies: skillProficiencies,
    spells: spells,
    exhaustion: exhaustion,
    conditions: conditions,
    hitDiceUsed: hitDiceUsed,
    createdAt: now,
    updatedAt: now,
  );
}
