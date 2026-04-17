import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart' as domain;
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
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
      speciesId: character.speciesId,
      backgroundId: character.backgroundId,
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
        acrobatics: character.skillAcrobatics,
        animalHandling: character.skillAnimalHandling,
        arcana: character.skillArcana,
        athletics: character.skillAthletics,
        deception: character.skillDeception,
        history: character.skillHistory,
        insight: character.skillInsight,
        intimidation: character.skillIntimidation,
        investigation: character.skillInvestigation,
        medicine: character.skillMedicine,
        nature: character.skillNature,
        perception: character.skillPerception,
        performance: character.skillPerformance,
        persuasion: character.skillPersuasion,
        religion: character.skillReligion,
        sleightOfHand: character.skillSleightOfHand,
        stealth: character.skillStealth,
        survival: character.skillSurvival,
      ),

      createdAt: character.createdAt,
      updatedAt: character.updatedAt,
    );
  }

  static Ability? _abilityFromDb(String? value) {
    if (value == null || value.isEmpty) return null;
    return Ability.values.firstWhere((item) => item.name == value);
  }

  static SpellcastingType? _spellcastingTypeFromDb(String? value) {
    if (value == null || value.isEmpty) return null;
    return SpellcastingType.values.firstWhere((item) => item.name == value);
  }
}