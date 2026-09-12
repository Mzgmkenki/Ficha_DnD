import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart' as domain;
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/spellcasting_type.dart';

class CharacterMapper {
  static domain.Character fromDatabase({
    required Character character,
    required List<CharacterClassLevel> classLevels,
  }) {
    return domain.Character(
      id: character.id,
      name: character.name,
      playerName: character.playerName,
      portraitPath: character.portraitPath,
      speciesId: character.speciesId,
      backgroundId: character.backgroundId,
      customBackground: CustomBackground(
        name: character.customBackgroundName,
        skillIds: CustomBackground.parseSkillIdsCsv(
          character.customBackgroundSkills,
        ),
        features: character.customBackgroundFeatures,
      ),
      notes: character.notes,

      abilityScores: AbilityScores(
        strength: character.strength,
        dexterity: character.dexterity,
        constitution: character.constitution,
        intelligence: character.intelligence,
        wisdom: character.wisdom,
        charisma: character.charisma,
      ),

      classLevels: classLevels.map((item) => ClassLevel(
        classId: item.classId,
        subclassId: item.subclassId,
        level: item.level,
        spellcastingAbility: _abilityFromDb(item.spellcastingAbility),
        spellcastingType: _spellcastingTypeFromDb(item.spellcastingType),
      )).toList(),

      hitPoints: HitPoints(
        current: character.currentHitPoints,
        maximum: character.maxHitPoints,
        temporary: character.temporaryHitPoints,
      ),

      combatStats: CombatStats(
        armorClass: character.armorClass,
        initiativeBonus: character.initiativeBonus,
        speedInSquares: character.speed,
      ),

      // ✅ NOVO
      savingThrowProficiencies: SavingThrowProficiencies(
        strength: character.saveStrength,
        dexterity: character.saveDexterity,
        constitution: character.saveConstitution,
        intelligence: character.saveIntelligence,
        wisdom: character.saveWisdom,
        charisma: character.saveCharisma,
      ),

      skillProficiencies: SkillProficiencies(
        levels: {
          Skill.acrobatics: ProficiencyLevel.fromDb(character.lvlAcrobatics),
          Skill.animalHandling:
              ProficiencyLevel.fromDb(character.lvlAnimalHandling),
          Skill.arcana: ProficiencyLevel.fromDb(character.lvlArcana),
          Skill.athletics: ProficiencyLevel.fromDb(character.lvlAthletics),
          Skill.deception: ProficiencyLevel.fromDb(character.lvlDeception),
          Skill.history: ProficiencyLevel.fromDb(character.lvlHistory),
          Skill.insight: ProficiencyLevel.fromDb(character.lvlInsight),
          Skill.intimidation:
              ProficiencyLevel.fromDb(character.lvlIntimidation),
          Skill.investigation:
              ProficiencyLevel.fromDb(character.lvlInvestigation),
          Skill.medicine: ProficiencyLevel.fromDb(character.lvlMedicine),
          Skill.nature: ProficiencyLevel.fromDb(character.lvlNature),
          Skill.perception: ProficiencyLevel.fromDb(character.lvlPerception),
          Skill.performance: ProficiencyLevel.fromDb(character.lvlPerformance),
          Skill.persuasion: ProficiencyLevel.fromDb(character.lvlPersuasion),
          Skill.religion: ProficiencyLevel.fromDb(character.lvlReligion),
          Skill.sleightOfHand:
              ProficiencyLevel.fromDb(character.lvlSleightOfHand),
          Skill.stealth: ProficiencyLevel.fromDb(character.lvlStealth),
          Skill.survival: ProficiencyLevel.fromDb(character.lvlSurvival),
        },
      ),

      inspiration: character.inspiration,
      exhaustion: character.exhaustion,
      hitDiceUsed: character.hitDiceUsed,

      currency: Currency(
        copper: character.copperPieces,
        silver: character.silverPieces,
        electrum: character.electrumPieces,
        gold: character.goldPieces,
        platinum: character.platinumPieces,
      ),

      createdAt: character.createdAt,
      updatedAt: character.updatedAt,
    );
  }

  /// Valores desconhecidos retornam `null` em vez de lançar `StateError`.
  /// Antes, um dado legado tornava o personagem inacessível para sempre.
  static Ability? _abilityFromDb(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final item in Ability.values) {
      if (item.name == value) return item;
    }
    return null;
  }

  static SpellcastingType? _spellcastingTypeFromDb(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final item in SpellcastingType.values) {
      if (item.name == value) return item;
    }
    return null;
  }
}