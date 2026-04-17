import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.abilityScores,
    required this.classLevels,
    required this.hitPoints,
    required this.combatStats,
    required this.createdAt,
    required this.updatedAt,
    this.playerName,
    this.speciesId,
    this.backgroundId,
    this.notes = '',
    this.savingThrowProficiencies = const SavingThrowProficiencies(),
    this.skillProficiencies = const SkillProficiencies(),
    this.spells = const [],
    this.magicItems = const [],
  });

  final String id;
  final String name;
  final String? playerName;
  final String? speciesId;
  final String? backgroundId;
  final AbilityScores abilityScores;
  final List<ClassLevel> classLevels;
  final HitPoints hitPoints;
  final CombatStats combatStats;
  final String notes;
  final SavingThrowProficiencies savingThrowProficiencies;
  final SkillProficiencies skillProficiencies;
  final List<CharacterSpell> spells;
  final List<CharacterMagicItem> magicItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get totalLevel {
    return classLevels.fold(0, (total, item) => total + item.level);
  }

  int get proficiencyBonus {
    final level = totalLevel;

    if (level >= 17) return 6;
    if (level >= 13) return 5;
    if (level >= 9) return 4;
    if (level >= 5) return 3;
    return 2;
  }

  Character copyWith({
    String? id,
    String? name,
    String? playerName,
    String? speciesId,
    String? backgroundId,
    AbilityScores? abilityScores,
    List<ClassLevel>? classLevels,
    HitPoints? hitPoints,
    CombatStats? combatStats,
    String? notes,
    SavingThrowProficiencies? savingThrowProficiencies,
    SkillProficiencies? skillProficiencies,
    List<CharacterSpell>? spells,
    List<CharacterMagicItem>? magicItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      playerName: playerName ?? this.playerName,
      speciesId: speciesId ?? this.speciesId,
      backgroundId: backgroundId ?? this.backgroundId,
      abilityScores: abilityScores ?? this.abilityScores,
      classLevels: classLevels ?? this.classLevels,
      hitPoints: hitPoints ?? this.hitPoints,
      combatStats: combatStats ?? this.combatStats,
      notes: notes ?? this.notes,
      savingThrowProficiencies:
          savingThrowProficiencies ?? this.savingThrowProficiencies,
      skillProficiencies: skillProficiencies ?? this.skillProficiencies,
      spells: spells ?? this.spells,
      magicItems: magicItems ?? this.magicItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}