import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';

/// Marcador usado no [Character.copyWith] para distinguir "não informado"
/// de "informado como null".
const Object _sentinel = Object();

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
    this.inspiration = false,
    this.exhaustion = 0,
    this.hitDiceUsed = 0,
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

  /// Inspiração heroica concedida pelo mestre.
  final bool inspiration;

  /// Níveis de exaustão (0 a 6). A partir de 1 já impõe desvantagem em
  /// testes de atributo, o que afeta os valores passivos.
  final int exhaustion;

  /// Dados de vida gastos desde o último descanso longo.
  final int hitDiceUsed;

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
    Object? playerName = _sentinel,
    Object? speciesId = _sentinel,
    Object? backgroundId = _sentinel,
    AbilityScores? abilityScores,
    List<ClassLevel>? classLevels,
    HitPoints? hitPoints,
    CombatStats? combatStats,
    String? notes,
    SavingThrowProficiencies? savingThrowProficiencies,
    SkillProficiencies? skillProficiencies,
    List<CharacterSpell>? spells,
    List<CharacterMagicItem>? magicItems,
    bool? inspiration,
    int? exhaustion,
    int? hitDiceUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      // Sentinela permite explicitamente setar estes campos para null
      // (com `x ?? this.x` era impossível limpá-los).
      playerName:
          playerName == _sentinel ? this.playerName : playerName as String?,
      speciesId:
          speciesId == _sentinel ? this.speciesId : speciesId as String?,
      backgroundId: backgroundId == _sentinel
          ? this.backgroundId
          : backgroundId as String?,
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
      inspiration: inspiration ?? this.inspiration,
      exhaustion: exhaustion ?? this.exhaustion,
      hitDiceUsed: hitDiceUsed ?? this.hitDiceUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}