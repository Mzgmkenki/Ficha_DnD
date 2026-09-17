// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CharactersTable extends Characters
    with TableInfo<$CharactersTable, Character> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerNameMeta = const VerificationMeta(
    'playerName',
  );
  @override
  late final GeneratedColumn<String> playerName = GeneratedColumn<String>(
    'player_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portraitPathMeta = const VerificationMeta(
    'portraitPath',
  );
  @override
  late final GeneratedColumn<String> portraitPath = GeneratedColumn<String>(
    'portrait_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<String> speciesId = GeneratedColumn<String>(
    'species_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backgroundIdMeta = const VerificationMeta(
    'backgroundId',
  );
  @override
  late final GeneratedColumn<String> backgroundId = GeneratedColumn<String>(
    'background_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customBackgroundNameMeta =
      const VerificationMeta('customBackgroundName');
  @override
  late final GeneratedColumn<String> customBackgroundName =
      GeneratedColumn<String>(
        'custom_background_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _customBackgroundSkillsMeta =
      const VerificationMeta('customBackgroundSkills');
  @override
  late final GeneratedColumn<String> customBackgroundSkills =
      GeneratedColumn<String>(
        'custom_background_skills',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _customBackgroundFeaturesMeta =
      const VerificationMeta('customBackgroundFeatures');
  @override
  late final GeneratedColumn<String> customBackgroundFeatures =
      GeneratedColumn<String>(
        'custom_background_features',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<int> strength = GeneratedColumn<int>(
    'strength',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _dexterityMeta = const VerificationMeta(
    'dexterity',
  );
  @override
  late final GeneratedColumn<int> dexterity = GeneratedColumn<int>(
    'dexterity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _constitutionMeta = const VerificationMeta(
    'constitution',
  );
  @override
  late final GeneratedColumn<int> constitution = GeneratedColumn<int>(
    'constitution',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _intelligenceMeta = const VerificationMeta(
    'intelligence',
  );
  @override
  late final GeneratedColumn<int> intelligence = GeneratedColumn<int>(
    'intelligence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _wisdomMeta = const VerificationMeta('wisdom');
  @override
  late final GeneratedColumn<int> wisdom = GeneratedColumn<int>(
    'wisdom',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _charismaMeta = const VerificationMeta(
    'charisma',
  );
  @override
  late final GeneratedColumn<int> charisma = GeneratedColumn<int>(
    'charisma',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _armorClassMeta = const VerificationMeta(
    'armorClass',
  );
  @override
  late final GeneratedColumn<int> armorClass = GeneratedColumn<int>(
    'armor_class',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _initiativeBonusMeta = const VerificationMeta(
    'initiativeBonus',
  );
  @override
  late final GeneratedColumn<int> initiativeBonus = GeneratedColumn<int>(
    'initiative_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<int> speed = GeneratedColumn<int>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(9),
  );
  static const VerificationMeta _speedMetersMeta = const VerificationMeta(
    'speedMeters',
  );
  @override
  late final GeneratedColumn<double> speedMeters = GeneratedColumn<double>(
    'speed_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHitPointsMeta = const VerificationMeta(
    'maxHitPoints',
  );
  @override
  late final GeneratedColumn<int> maxHitPoints = GeneratedColumn<int>(
    'max_hit_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _currentHitPointsMeta = const VerificationMeta(
    'currentHitPoints',
  );
  @override
  late final GeneratedColumn<int> currentHitPoints = GeneratedColumn<int>(
    'current_hit_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _temporaryHitPointsMeta =
      const VerificationMeta('temporaryHitPoints');
  @override
  late final GeneratedColumn<int> temporaryHitPoints = GeneratedColumn<int>(
    'temporary_hit_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _saveStrengthMeta = const VerificationMeta(
    'saveStrength',
  );
  @override
  late final GeneratedColumn<bool> saveStrength = GeneratedColumn<bool>(
    'save_strength',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("save_strength" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _saveDexterityMeta = const VerificationMeta(
    'saveDexterity',
  );
  @override
  late final GeneratedColumn<bool> saveDexterity = GeneratedColumn<bool>(
    'save_dexterity',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("save_dexterity" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _saveConstitutionMeta = const VerificationMeta(
    'saveConstitution',
  );
  @override
  late final GeneratedColumn<bool> saveConstitution = GeneratedColumn<bool>(
    'save_constitution',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("save_constitution" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _saveIntelligenceMeta = const VerificationMeta(
    'saveIntelligence',
  );
  @override
  late final GeneratedColumn<bool> saveIntelligence = GeneratedColumn<bool>(
    'save_intelligence',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("save_intelligence" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _saveWisdomMeta = const VerificationMeta(
    'saveWisdom',
  );
  @override
  late final GeneratedColumn<bool> saveWisdom = GeneratedColumn<bool>(
    'save_wisdom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("save_wisdom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _saveCharismaMeta = const VerificationMeta(
    'saveCharisma',
  );
  @override
  late final GeneratedColumn<bool> saveCharisma = GeneratedColumn<bool>(
    'save_charisma',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("save_charisma" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillAcrobaticsMeta = const VerificationMeta(
    'skillAcrobatics',
  );
  @override
  late final GeneratedColumn<bool> skillAcrobatics = GeneratedColumn<bool>(
    'skill_acrobatics',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_acrobatics" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillAnimalHandlingMeta =
      const VerificationMeta('skillAnimalHandling');
  @override
  late final GeneratedColumn<bool> skillAnimalHandling = GeneratedColumn<bool>(
    'skill_animal_handling',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_animal_handling" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillArcanaMeta = const VerificationMeta(
    'skillArcana',
  );
  @override
  late final GeneratedColumn<bool> skillArcana = GeneratedColumn<bool>(
    'skill_arcana',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_arcana" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillAthleticsMeta = const VerificationMeta(
    'skillAthletics',
  );
  @override
  late final GeneratedColumn<bool> skillAthletics = GeneratedColumn<bool>(
    'skill_athletics',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_athletics" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillDeceptionMeta = const VerificationMeta(
    'skillDeception',
  );
  @override
  late final GeneratedColumn<bool> skillDeception = GeneratedColumn<bool>(
    'skill_deception',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_deception" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillHistoryMeta = const VerificationMeta(
    'skillHistory',
  );
  @override
  late final GeneratedColumn<bool> skillHistory = GeneratedColumn<bool>(
    'skill_history',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_history" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillInsightMeta = const VerificationMeta(
    'skillInsight',
  );
  @override
  late final GeneratedColumn<bool> skillInsight = GeneratedColumn<bool>(
    'skill_insight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_insight" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillIntimidationMeta = const VerificationMeta(
    'skillIntimidation',
  );
  @override
  late final GeneratedColumn<bool> skillIntimidation = GeneratedColumn<bool>(
    'skill_intimidation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_intimidation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillInvestigationMeta =
      const VerificationMeta('skillInvestigation');
  @override
  late final GeneratedColumn<bool> skillInvestigation = GeneratedColumn<bool>(
    'skill_investigation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_investigation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillMedicineMeta = const VerificationMeta(
    'skillMedicine',
  );
  @override
  late final GeneratedColumn<bool> skillMedicine = GeneratedColumn<bool>(
    'skill_medicine',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_medicine" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillNatureMeta = const VerificationMeta(
    'skillNature',
  );
  @override
  late final GeneratedColumn<bool> skillNature = GeneratedColumn<bool>(
    'skill_nature',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_nature" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillPerceptionMeta = const VerificationMeta(
    'skillPerception',
  );
  @override
  late final GeneratedColumn<bool> skillPerception = GeneratedColumn<bool>(
    'skill_perception',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_perception" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillPerformanceMeta = const VerificationMeta(
    'skillPerformance',
  );
  @override
  late final GeneratedColumn<bool> skillPerformance = GeneratedColumn<bool>(
    'skill_performance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_performance" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillPersuasionMeta = const VerificationMeta(
    'skillPersuasion',
  );
  @override
  late final GeneratedColumn<bool> skillPersuasion = GeneratedColumn<bool>(
    'skill_persuasion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_persuasion" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillReligionMeta = const VerificationMeta(
    'skillReligion',
  );
  @override
  late final GeneratedColumn<bool> skillReligion = GeneratedColumn<bool>(
    'skill_religion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_religion" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillSleightOfHandMeta =
      const VerificationMeta('skillSleightOfHand');
  @override
  late final GeneratedColumn<bool> skillSleightOfHand = GeneratedColumn<bool>(
    'skill_sleight_of_hand',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_sleight_of_hand" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillStealthMeta = const VerificationMeta(
    'skillStealth',
  );
  @override
  late final GeneratedColumn<bool> skillStealth = GeneratedColumn<bool>(
    'skill_stealth',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_stealth" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skillSurvivalMeta = const VerificationMeta(
    'skillSurvival',
  );
  @override
  late final GeneratedColumn<bool> skillSurvival = GeneratedColumn<bool>(
    'skill_survival',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skill_survival" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lvlAcrobaticsMeta = const VerificationMeta(
    'lvlAcrobatics',
  );
  @override
  late final GeneratedColumn<int> lvlAcrobatics = GeneratedColumn<int>(
    'lvl_acrobatics',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlAnimalHandlingMeta = const VerificationMeta(
    'lvlAnimalHandling',
  );
  @override
  late final GeneratedColumn<int> lvlAnimalHandling = GeneratedColumn<int>(
    'lvl_animal_handling',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlArcanaMeta = const VerificationMeta(
    'lvlArcana',
  );
  @override
  late final GeneratedColumn<int> lvlArcana = GeneratedColumn<int>(
    'lvl_arcana',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlAthleticsMeta = const VerificationMeta(
    'lvlAthletics',
  );
  @override
  late final GeneratedColumn<int> lvlAthletics = GeneratedColumn<int>(
    'lvl_athletics',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlDeceptionMeta = const VerificationMeta(
    'lvlDeception',
  );
  @override
  late final GeneratedColumn<int> lvlDeception = GeneratedColumn<int>(
    'lvl_deception',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlHistoryMeta = const VerificationMeta(
    'lvlHistory',
  );
  @override
  late final GeneratedColumn<int> lvlHistory = GeneratedColumn<int>(
    'lvl_history',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlInsightMeta = const VerificationMeta(
    'lvlInsight',
  );
  @override
  late final GeneratedColumn<int> lvlInsight = GeneratedColumn<int>(
    'lvl_insight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlIntimidationMeta = const VerificationMeta(
    'lvlIntimidation',
  );
  @override
  late final GeneratedColumn<int> lvlIntimidation = GeneratedColumn<int>(
    'lvl_intimidation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlInvestigationMeta = const VerificationMeta(
    'lvlInvestigation',
  );
  @override
  late final GeneratedColumn<int> lvlInvestigation = GeneratedColumn<int>(
    'lvl_investigation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlMedicineMeta = const VerificationMeta(
    'lvlMedicine',
  );
  @override
  late final GeneratedColumn<int> lvlMedicine = GeneratedColumn<int>(
    'lvl_medicine',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlNatureMeta = const VerificationMeta(
    'lvlNature',
  );
  @override
  late final GeneratedColumn<int> lvlNature = GeneratedColumn<int>(
    'lvl_nature',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlPerceptionMeta = const VerificationMeta(
    'lvlPerception',
  );
  @override
  late final GeneratedColumn<int> lvlPerception = GeneratedColumn<int>(
    'lvl_perception',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlPerformanceMeta = const VerificationMeta(
    'lvlPerformance',
  );
  @override
  late final GeneratedColumn<int> lvlPerformance = GeneratedColumn<int>(
    'lvl_performance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlPersuasionMeta = const VerificationMeta(
    'lvlPersuasion',
  );
  @override
  late final GeneratedColumn<int> lvlPersuasion = GeneratedColumn<int>(
    'lvl_persuasion',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlReligionMeta = const VerificationMeta(
    'lvlReligion',
  );
  @override
  late final GeneratedColumn<int> lvlReligion = GeneratedColumn<int>(
    'lvl_religion',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlSleightOfHandMeta = const VerificationMeta(
    'lvlSleightOfHand',
  );
  @override
  late final GeneratedColumn<int> lvlSleightOfHand = GeneratedColumn<int>(
    'lvl_sleight_of_hand',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlStealthMeta = const VerificationMeta(
    'lvlStealth',
  );
  @override
  late final GeneratedColumn<int> lvlStealth = GeneratedColumn<int>(
    'lvl_stealth',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lvlSurvivalMeta = const VerificationMeta(
    'lvlSurvival',
  );
  @override
  late final GeneratedColumn<int> lvlSurvival = GeneratedColumn<int>(
    'lvl_survival',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _inspirationMeta = const VerificationMeta(
    'inspiration',
  );
  @override
  late final GeneratedColumn<bool> inspiration = GeneratedColumn<bool>(
    'inspiration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("inspiration" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _exhaustionMeta = const VerificationMeta(
    'exhaustion',
  );
  @override
  late final GeneratedColumn<int> exhaustion = GeneratedColumn<int>(
    'exhaustion',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _conditionsMeta = const VerificationMeta(
    'conditions',
  );
  @override
  late final GeneratedColumn<String> conditions = GeneratedColumn<String>(
    'conditions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hitDiceUsedMeta = const VerificationMeta(
    'hitDiceUsed',
  );
  @override
  late final GeneratedColumn<int> hitDiceUsed = GeneratedColumn<int>(
    'hit_dice_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _copperPiecesMeta = const VerificationMeta(
    'copperPieces',
  );
  @override
  late final GeneratedColumn<int> copperPieces = GeneratedColumn<int>(
    'copper_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _silverPiecesMeta = const VerificationMeta(
    'silverPieces',
  );
  @override
  late final GeneratedColumn<int> silverPieces = GeneratedColumn<int>(
    'silver_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _electrumPiecesMeta = const VerificationMeta(
    'electrumPieces',
  );
  @override
  late final GeneratedColumn<int> electrumPieces = GeneratedColumn<int>(
    'electrum_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _goldPiecesMeta = const VerificationMeta(
    'goldPieces',
  );
  @override
  late final GeneratedColumn<int> goldPieces = GeneratedColumn<int>(
    'gold_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _platinumPiecesMeta = const VerificationMeta(
    'platinumPieces',
  );
  @override
  late final GeneratedColumn<int> platinumPieces = GeneratedColumn<int>(
    'platinum_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    playerName,
    portraitPath,
    speciesId,
    backgroundId,
    customBackgroundName,
    customBackgroundSkills,
    customBackgroundFeatures,
    notes,
    strength,
    dexterity,
    constitution,
    intelligence,
    wisdom,
    charisma,
    armorClass,
    initiativeBonus,
    speed,
    speedMeters,
    maxHitPoints,
    currentHitPoints,
    temporaryHitPoints,
    saveStrength,
    saveDexterity,
    saveConstitution,
    saveIntelligence,
    saveWisdom,
    saveCharisma,
    skillAcrobatics,
    skillAnimalHandling,
    skillArcana,
    skillAthletics,
    skillDeception,
    skillHistory,
    skillInsight,
    skillIntimidation,
    skillInvestigation,
    skillMedicine,
    skillNature,
    skillPerception,
    skillPerformance,
    skillPersuasion,
    skillReligion,
    skillSleightOfHand,
    skillStealth,
    skillSurvival,
    lvlAcrobatics,
    lvlAnimalHandling,
    lvlArcana,
    lvlAthletics,
    lvlDeception,
    lvlHistory,
    lvlInsight,
    lvlIntimidation,
    lvlInvestigation,
    lvlMedicine,
    lvlNature,
    lvlPerception,
    lvlPerformance,
    lvlPersuasion,
    lvlReligion,
    lvlSleightOfHand,
    lvlStealth,
    lvlSurvival,
    inspiration,
    exhaustion,
    conditions,
    hitDiceUsed,
    copperPieces,
    silverPieces,
    electrumPieces,
    goldPieces,
    platinumPieces,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Character> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('player_name')) {
      context.handle(
        _playerNameMeta,
        playerName.isAcceptableOrUnknown(data['player_name']!, _playerNameMeta),
      );
    }
    if (data.containsKey('portrait_path')) {
      context.handle(
        _portraitPathMeta,
        portraitPath.isAcceptableOrUnknown(
          data['portrait_path']!,
          _portraitPathMeta,
        ),
      );
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    }
    if (data.containsKey('background_id')) {
      context.handle(
        _backgroundIdMeta,
        backgroundId.isAcceptableOrUnknown(
          data['background_id']!,
          _backgroundIdMeta,
        ),
      );
    }
    if (data.containsKey('custom_background_name')) {
      context.handle(
        _customBackgroundNameMeta,
        customBackgroundName.isAcceptableOrUnknown(
          data['custom_background_name']!,
          _customBackgroundNameMeta,
        ),
      );
    }
    if (data.containsKey('custom_background_skills')) {
      context.handle(
        _customBackgroundSkillsMeta,
        customBackgroundSkills.isAcceptableOrUnknown(
          data['custom_background_skills']!,
          _customBackgroundSkillsMeta,
        ),
      );
    }
    if (data.containsKey('custom_background_features')) {
      context.handle(
        _customBackgroundFeaturesMeta,
        customBackgroundFeatures.isAcceptableOrUnknown(
          data['custom_background_features']!,
          _customBackgroundFeaturesMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    }
    if (data.containsKey('dexterity')) {
      context.handle(
        _dexterityMeta,
        dexterity.isAcceptableOrUnknown(data['dexterity']!, _dexterityMeta),
      );
    }
    if (data.containsKey('constitution')) {
      context.handle(
        _constitutionMeta,
        constitution.isAcceptableOrUnknown(
          data['constitution']!,
          _constitutionMeta,
        ),
      );
    }
    if (data.containsKey('intelligence')) {
      context.handle(
        _intelligenceMeta,
        intelligence.isAcceptableOrUnknown(
          data['intelligence']!,
          _intelligenceMeta,
        ),
      );
    }
    if (data.containsKey('wisdom')) {
      context.handle(
        _wisdomMeta,
        wisdom.isAcceptableOrUnknown(data['wisdom']!, _wisdomMeta),
      );
    }
    if (data.containsKey('charisma')) {
      context.handle(
        _charismaMeta,
        charisma.isAcceptableOrUnknown(data['charisma']!, _charismaMeta),
      );
    }
    if (data.containsKey('armor_class')) {
      context.handle(
        _armorClassMeta,
        armorClass.isAcceptableOrUnknown(data['armor_class']!, _armorClassMeta),
      );
    }
    if (data.containsKey('initiative_bonus')) {
      context.handle(
        _initiativeBonusMeta,
        initiativeBonus.isAcceptableOrUnknown(
          data['initiative_bonus']!,
          _initiativeBonusMeta,
        ),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('speed_meters')) {
      context.handle(
        _speedMetersMeta,
        speedMeters.isAcceptableOrUnknown(
          data['speed_meters']!,
          _speedMetersMeta,
        ),
      );
    }
    if (data.containsKey('max_hit_points')) {
      context.handle(
        _maxHitPointsMeta,
        maxHitPoints.isAcceptableOrUnknown(
          data['max_hit_points']!,
          _maxHitPointsMeta,
        ),
      );
    }
    if (data.containsKey('current_hit_points')) {
      context.handle(
        _currentHitPointsMeta,
        currentHitPoints.isAcceptableOrUnknown(
          data['current_hit_points']!,
          _currentHitPointsMeta,
        ),
      );
    }
    if (data.containsKey('temporary_hit_points')) {
      context.handle(
        _temporaryHitPointsMeta,
        temporaryHitPoints.isAcceptableOrUnknown(
          data['temporary_hit_points']!,
          _temporaryHitPointsMeta,
        ),
      );
    }
    if (data.containsKey('save_strength')) {
      context.handle(
        _saveStrengthMeta,
        saveStrength.isAcceptableOrUnknown(
          data['save_strength']!,
          _saveStrengthMeta,
        ),
      );
    }
    if (data.containsKey('save_dexterity')) {
      context.handle(
        _saveDexterityMeta,
        saveDexterity.isAcceptableOrUnknown(
          data['save_dexterity']!,
          _saveDexterityMeta,
        ),
      );
    }
    if (data.containsKey('save_constitution')) {
      context.handle(
        _saveConstitutionMeta,
        saveConstitution.isAcceptableOrUnknown(
          data['save_constitution']!,
          _saveConstitutionMeta,
        ),
      );
    }
    if (data.containsKey('save_intelligence')) {
      context.handle(
        _saveIntelligenceMeta,
        saveIntelligence.isAcceptableOrUnknown(
          data['save_intelligence']!,
          _saveIntelligenceMeta,
        ),
      );
    }
    if (data.containsKey('save_wisdom')) {
      context.handle(
        _saveWisdomMeta,
        saveWisdom.isAcceptableOrUnknown(data['save_wisdom']!, _saveWisdomMeta),
      );
    }
    if (data.containsKey('save_charisma')) {
      context.handle(
        _saveCharismaMeta,
        saveCharisma.isAcceptableOrUnknown(
          data['save_charisma']!,
          _saveCharismaMeta,
        ),
      );
    }
    if (data.containsKey('skill_acrobatics')) {
      context.handle(
        _skillAcrobaticsMeta,
        skillAcrobatics.isAcceptableOrUnknown(
          data['skill_acrobatics']!,
          _skillAcrobaticsMeta,
        ),
      );
    }
    if (data.containsKey('skill_animal_handling')) {
      context.handle(
        _skillAnimalHandlingMeta,
        skillAnimalHandling.isAcceptableOrUnknown(
          data['skill_animal_handling']!,
          _skillAnimalHandlingMeta,
        ),
      );
    }
    if (data.containsKey('skill_arcana')) {
      context.handle(
        _skillArcanaMeta,
        skillArcana.isAcceptableOrUnknown(
          data['skill_arcana']!,
          _skillArcanaMeta,
        ),
      );
    }
    if (data.containsKey('skill_athletics')) {
      context.handle(
        _skillAthleticsMeta,
        skillAthletics.isAcceptableOrUnknown(
          data['skill_athletics']!,
          _skillAthleticsMeta,
        ),
      );
    }
    if (data.containsKey('skill_deception')) {
      context.handle(
        _skillDeceptionMeta,
        skillDeception.isAcceptableOrUnknown(
          data['skill_deception']!,
          _skillDeceptionMeta,
        ),
      );
    }
    if (data.containsKey('skill_history')) {
      context.handle(
        _skillHistoryMeta,
        skillHistory.isAcceptableOrUnknown(
          data['skill_history']!,
          _skillHistoryMeta,
        ),
      );
    }
    if (data.containsKey('skill_insight')) {
      context.handle(
        _skillInsightMeta,
        skillInsight.isAcceptableOrUnknown(
          data['skill_insight']!,
          _skillInsightMeta,
        ),
      );
    }
    if (data.containsKey('skill_intimidation')) {
      context.handle(
        _skillIntimidationMeta,
        skillIntimidation.isAcceptableOrUnknown(
          data['skill_intimidation']!,
          _skillIntimidationMeta,
        ),
      );
    }
    if (data.containsKey('skill_investigation')) {
      context.handle(
        _skillInvestigationMeta,
        skillInvestigation.isAcceptableOrUnknown(
          data['skill_investigation']!,
          _skillInvestigationMeta,
        ),
      );
    }
    if (data.containsKey('skill_medicine')) {
      context.handle(
        _skillMedicineMeta,
        skillMedicine.isAcceptableOrUnknown(
          data['skill_medicine']!,
          _skillMedicineMeta,
        ),
      );
    }
    if (data.containsKey('skill_nature')) {
      context.handle(
        _skillNatureMeta,
        skillNature.isAcceptableOrUnknown(
          data['skill_nature']!,
          _skillNatureMeta,
        ),
      );
    }
    if (data.containsKey('skill_perception')) {
      context.handle(
        _skillPerceptionMeta,
        skillPerception.isAcceptableOrUnknown(
          data['skill_perception']!,
          _skillPerceptionMeta,
        ),
      );
    }
    if (data.containsKey('skill_performance')) {
      context.handle(
        _skillPerformanceMeta,
        skillPerformance.isAcceptableOrUnknown(
          data['skill_performance']!,
          _skillPerformanceMeta,
        ),
      );
    }
    if (data.containsKey('skill_persuasion')) {
      context.handle(
        _skillPersuasionMeta,
        skillPersuasion.isAcceptableOrUnknown(
          data['skill_persuasion']!,
          _skillPersuasionMeta,
        ),
      );
    }
    if (data.containsKey('skill_religion')) {
      context.handle(
        _skillReligionMeta,
        skillReligion.isAcceptableOrUnknown(
          data['skill_religion']!,
          _skillReligionMeta,
        ),
      );
    }
    if (data.containsKey('skill_sleight_of_hand')) {
      context.handle(
        _skillSleightOfHandMeta,
        skillSleightOfHand.isAcceptableOrUnknown(
          data['skill_sleight_of_hand']!,
          _skillSleightOfHandMeta,
        ),
      );
    }
    if (data.containsKey('skill_stealth')) {
      context.handle(
        _skillStealthMeta,
        skillStealth.isAcceptableOrUnknown(
          data['skill_stealth']!,
          _skillStealthMeta,
        ),
      );
    }
    if (data.containsKey('skill_survival')) {
      context.handle(
        _skillSurvivalMeta,
        skillSurvival.isAcceptableOrUnknown(
          data['skill_survival']!,
          _skillSurvivalMeta,
        ),
      );
    }
    if (data.containsKey('lvl_acrobatics')) {
      context.handle(
        _lvlAcrobaticsMeta,
        lvlAcrobatics.isAcceptableOrUnknown(
          data['lvl_acrobatics']!,
          _lvlAcrobaticsMeta,
        ),
      );
    }
    if (data.containsKey('lvl_animal_handling')) {
      context.handle(
        _lvlAnimalHandlingMeta,
        lvlAnimalHandling.isAcceptableOrUnknown(
          data['lvl_animal_handling']!,
          _lvlAnimalHandlingMeta,
        ),
      );
    }
    if (data.containsKey('lvl_arcana')) {
      context.handle(
        _lvlArcanaMeta,
        lvlArcana.isAcceptableOrUnknown(data['lvl_arcana']!, _lvlArcanaMeta),
      );
    }
    if (data.containsKey('lvl_athletics')) {
      context.handle(
        _lvlAthleticsMeta,
        lvlAthletics.isAcceptableOrUnknown(
          data['lvl_athletics']!,
          _lvlAthleticsMeta,
        ),
      );
    }
    if (data.containsKey('lvl_deception')) {
      context.handle(
        _lvlDeceptionMeta,
        lvlDeception.isAcceptableOrUnknown(
          data['lvl_deception']!,
          _lvlDeceptionMeta,
        ),
      );
    }
    if (data.containsKey('lvl_history')) {
      context.handle(
        _lvlHistoryMeta,
        lvlHistory.isAcceptableOrUnknown(data['lvl_history']!, _lvlHistoryMeta),
      );
    }
    if (data.containsKey('lvl_insight')) {
      context.handle(
        _lvlInsightMeta,
        lvlInsight.isAcceptableOrUnknown(data['lvl_insight']!, _lvlInsightMeta),
      );
    }
    if (data.containsKey('lvl_intimidation')) {
      context.handle(
        _lvlIntimidationMeta,
        lvlIntimidation.isAcceptableOrUnknown(
          data['lvl_intimidation']!,
          _lvlIntimidationMeta,
        ),
      );
    }
    if (data.containsKey('lvl_investigation')) {
      context.handle(
        _lvlInvestigationMeta,
        lvlInvestigation.isAcceptableOrUnknown(
          data['lvl_investigation']!,
          _lvlInvestigationMeta,
        ),
      );
    }
    if (data.containsKey('lvl_medicine')) {
      context.handle(
        _lvlMedicineMeta,
        lvlMedicine.isAcceptableOrUnknown(
          data['lvl_medicine']!,
          _lvlMedicineMeta,
        ),
      );
    }
    if (data.containsKey('lvl_nature')) {
      context.handle(
        _lvlNatureMeta,
        lvlNature.isAcceptableOrUnknown(data['lvl_nature']!, _lvlNatureMeta),
      );
    }
    if (data.containsKey('lvl_perception')) {
      context.handle(
        _lvlPerceptionMeta,
        lvlPerception.isAcceptableOrUnknown(
          data['lvl_perception']!,
          _lvlPerceptionMeta,
        ),
      );
    }
    if (data.containsKey('lvl_performance')) {
      context.handle(
        _lvlPerformanceMeta,
        lvlPerformance.isAcceptableOrUnknown(
          data['lvl_performance']!,
          _lvlPerformanceMeta,
        ),
      );
    }
    if (data.containsKey('lvl_persuasion')) {
      context.handle(
        _lvlPersuasionMeta,
        lvlPersuasion.isAcceptableOrUnknown(
          data['lvl_persuasion']!,
          _lvlPersuasionMeta,
        ),
      );
    }
    if (data.containsKey('lvl_religion')) {
      context.handle(
        _lvlReligionMeta,
        lvlReligion.isAcceptableOrUnknown(
          data['lvl_religion']!,
          _lvlReligionMeta,
        ),
      );
    }
    if (data.containsKey('lvl_sleight_of_hand')) {
      context.handle(
        _lvlSleightOfHandMeta,
        lvlSleightOfHand.isAcceptableOrUnknown(
          data['lvl_sleight_of_hand']!,
          _lvlSleightOfHandMeta,
        ),
      );
    }
    if (data.containsKey('lvl_stealth')) {
      context.handle(
        _lvlStealthMeta,
        lvlStealth.isAcceptableOrUnknown(data['lvl_stealth']!, _lvlStealthMeta),
      );
    }
    if (data.containsKey('lvl_survival')) {
      context.handle(
        _lvlSurvivalMeta,
        lvlSurvival.isAcceptableOrUnknown(
          data['lvl_survival']!,
          _lvlSurvivalMeta,
        ),
      );
    }
    if (data.containsKey('inspiration')) {
      context.handle(
        _inspirationMeta,
        inspiration.isAcceptableOrUnknown(
          data['inspiration']!,
          _inspirationMeta,
        ),
      );
    }
    if (data.containsKey('exhaustion')) {
      context.handle(
        _exhaustionMeta,
        exhaustion.isAcceptableOrUnknown(data['exhaustion']!, _exhaustionMeta),
      );
    }
    if (data.containsKey('conditions')) {
      context.handle(
        _conditionsMeta,
        conditions.isAcceptableOrUnknown(data['conditions']!, _conditionsMeta),
      );
    }
    if (data.containsKey('hit_dice_used')) {
      context.handle(
        _hitDiceUsedMeta,
        hitDiceUsed.isAcceptableOrUnknown(
          data['hit_dice_used']!,
          _hitDiceUsedMeta,
        ),
      );
    }
    if (data.containsKey('copper_pieces')) {
      context.handle(
        _copperPiecesMeta,
        copperPieces.isAcceptableOrUnknown(
          data['copper_pieces']!,
          _copperPiecesMeta,
        ),
      );
    }
    if (data.containsKey('silver_pieces')) {
      context.handle(
        _silverPiecesMeta,
        silverPieces.isAcceptableOrUnknown(
          data['silver_pieces']!,
          _silverPiecesMeta,
        ),
      );
    }
    if (data.containsKey('electrum_pieces')) {
      context.handle(
        _electrumPiecesMeta,
        electrumPieces.isAcceptableOrUnknown(
          data['electrum_pieces']!,
          _electrumPiecesMeta,
        ),
      );
    }
    if (data.containsKey('gold_pieces')) {
      context.handle(
        _goldPiecesMeta,
        goldPieces.isAcceptableOrUnknown(data['gold_pieces']!, _goldPiecesMeta),
      );
    }
    if (data.containsKey('platinum_pieces')) {
      context.handle(
        _platinumPiecesMeta,
        platinumPieces.isAcceptableOrUnknown(
          data['platinum_pieces']!,
          _platinumPiecesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Character map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Character(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      playerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_name'],
      ),
      portraitPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portrait_path'],
      ),
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_id'],
      ),
      backgroundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}background_id'],
      ),
      customBackgroundName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_background_name'],
      ),
      customBackgroundSkills:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}custom_background_skills'],
          )!,
      customBackgroundFeatures:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}custom_background_features'],
          )!,
      notes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}notes'],
          )!,
      strength:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}strength'],
          )!,
      dexterity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}dexterity'],
          )!,
      constitution:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}constitution'],
          )!,
      intelligence:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}intelligence'],
          )!,
      wisdom:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}wisdom'],
          )!,
      charisma:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}charisma'],
          )!,
      armorClass:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}armor_class'],
          )!,
      initiativeBonus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}initiative_bonus'],
          )!,
      speed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}speed'],
          )!,
      speedMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_meters'],
      ),
      maxHitPoints:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}max_hit_points'],
          )!,
      currentHitPoints:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}current_hit_points'],
          )!,
      temporaryHitPoints:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}temporary_hit_points'],
          )!,
      saveStrength:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}save_strength'],
          )!,
      saveDexterity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}save_dexterity'],
          )!,
      saveConstitution:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}save_constitution'],
          )!,
      saveIntelligence:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}save_intelligence'],
          )!,
      saveWisdom:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}save_wisdom'],
          )!,
      saveCharisma:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}save_charisma'],
          )!,
      skillAcrobatics:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_acrobatics'],
          )!,
      skillAnimalHandling:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_animal_handling'],
          )!,
      skillArcana:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_arcana'],
          )!,
      skillAthletics:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_athletics'],
          )!,
      skillDeception:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_deception'],
          )!,
      skillHistory:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_history'],
          )!,
      skillInsight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_insight'],
          )!,
      skillIntimidation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_intimidation'],
          )!,
      skillInvestigation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_investigation'],
          )!,
      skillMedicine:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_medicine'],
          )!,
      skillNature:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_nature'],
          )!,
      skillPerception:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_perception'],
          )!,
      skillPerformance:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_performance'],
          )!,
      skillPersuasion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_persuasion'],
          )!,
      skillReligion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_religion'],
          )!,
      skillSleightOfHand:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_sleight_of_hand'],
          )!,
      skillStealth:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_stealth'],
          )!,
      skillSurvival:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}skill_survival'],
          )!,
      lvlAcrobatics:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_acrobatics'],
          )!,
      lvlAnimalHandling:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_animal_handling'],
          )!,
      lvlArcana:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_arcana'],
          )!,
      lvlAthletics:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_athletics'],
          )!,
      lvlDeception:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_deception'],
          )!,
      lvlHistory:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_history'],
          )!,
      lvlInsight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_insight'],
          )!,
      lvlIntimidation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_intimidation'],
          )!,
      lvlInvestigation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_investigation'],
          )!,
      lvlMedicine:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_medicine'],
          )!,
      lvlNature:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_nature'],
          )!,
      lvlPerception:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_perception'],
          )!,
      lvlPerformance:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_performance'],
          )!,
      lvlPersuasion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_persuasion'],
          )!,
      lvlReligion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_religion'],
          )!,
      lvlSleightOfHand:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_sleight_of_hand'],
          )!,
      lvlStealth:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_stealth'],
          )!,
      lvlSurvival:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lvl_survival'],
          )!,
      inspiration:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}inspiration'],
          )!,
      exhaustion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}exhaustion'],
          )!,
      conditions:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}conditions'],
          )!,
      hitDiceUsed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}hit_dice_used'],
          )!,
      copperPieces:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}copper_pieces'],
          )!,
      silverPieces:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}silver_pieces'],
          )!,
      electrumPieces:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}electrum_pieces'],
          )!,
      goldPieces:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}gold_pieces'],
          )!,
      platinumPieces:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}platinum_pieces'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }
}

class Character extends DataClass implements Insertable<Character> {
  final String id;
  final String name;
  final String? playerName;

  /// Caminho da imagem de aparência, dentro do diretório do app.
  final String? portraitPath;
  final String? speciesId;
  final String? backgroundId;
  final String? customBackgroundName;

  /// Ids das perícias do antecedente customizado, separados por vírgula.
  final String customBackgroundSkills;

  /// Texto livre com as características do antecedente customizado.
  final String customBackgroundFeatures;
  final String notes;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final int armorClass;
  final int initiativeBonus;

  /// Deslocamento em metros, arredondado. Legado: a coluna é inteira e não
  /// cabia o 7,5 m do anão. A leitura usa [speedMeters]; esta continua sendo
  /// gravada para bases antigas não ficarem incoerentes.
  final int speed;

  /// Deslocamento em metros, com fração. Nulo em base que ainda não migrou.
  final double? speedMeters;
  final int maxHitPoints;
  final int currentHitPoints;
  final int temporaryHitPoints;
  final bool saveStrength;
  final bool saveDexterity;
  final bool saveConstitution;
  final bool saveIntelligence;
  final bool saveWisdom;
  final bool saveCharisma;
  final bool skillAcrobatics;
  final bool skillAnimalHandling;
  final bool skillArcana;
  final bool skillAthletics;
  final bool skillDeception;
  final bool skillHistory;
  final bool skillInsight;
  final bool skillIntimidation;
  final bool skillInvestigation;
  final bool skillMedicine;
  final bool skillNature;
  final bool skillPerception;
  final bool skillPerformance;
  final bool skillPersuasion;
  final bool skillReligion;
  final bool skillSleightOfHand;
  final bool skillStealth;
  final bool skillSurvival;
  final int lvlAcrobatics;
  final int lvlAnimalHandling;
  final int lvlArcana;
  final int lvlAthletics;
  final int lvlDeception;
  final int lvlHistory;
  final int lvlInsight;
  final int lvlIntimidation;
  final int lvlInvestigation;
  final int lvlMedicine;
  final int lvlNature;
  final int lvlPerception;
  final int lvlPerformance;
  final int lvlPersuasion;
  final int lvlReligion;
  final int lvlSleightOfHand;
  final int lvlStealth;
  final int lvlSurvival;

  /// Inspiração heroica: o personagem tem ou não.
  final bool inspiration;

  /// Níveis de exaustão (0 a 6).
  final int exhaustion;

  /// Ids das condições ativas, separados por vírgula (`paralyzed,stunned`).
  ///
  /// CSV em vez de tabela filha porque o vocabulário é fixo e pequeno, e o
  /// conjunto é sempre lido e gravado inteiro. Mesma escolha de
  /// [customBackgroundSkills]. Exaustão não entra aqui: tem níveis, não
  /// ligado/desligado, e já mora em [exhaustion].
  final String conditions;

  /// Dados de vida já gastos desde o último descanso longo.
  final int hitDiceUsed;
  final int copperPieces;
  final int silverPieces;
  final int electrumPieces;
  final int goldPieces;
  final int platinumPieces;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Character({
    required this.id,
    required this.name,
    this.playerName,
    this.portraitPath,
    this.speciesId,
    this.backgroundId,
    this.customBackgroundName,
    required this.customBackgroundSkills,
    required this.customBackgroundFeatures,
    required this.notes,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    required this.armorClass,
    required this.initiativeBonus,
    required this.speed,
    this.speedMeters,
    required this.maxHitPoints,
    required this.currentHitPoints,
    required this.temporaryHitPoints,
    required this.saveStrength,
    required this.saveDexterity,
    required this.saveConstitution,
    required this.saveIntelligence,
    required this.saveWisdom,
    required this.saveCharisma,
    required this.skillAcrobatics,
    required this.skillAnimalHandling,
    required this.skillArcana,
    required this.skillAthletics,
    required this.skillDeception,
    required this.skillHistory,
    required this.skillInsight,
    required this.skillIntimidation,
    required this.skillInvestigation,
    required this.skillMedicine,
    required this.skillNature,
    required this.skillPerception,
    required this.skillPerformance,
    required this.skillPersuasion,
    required this.skillReligion,
    required this.skillSleightOfHand,
    required this.skillStealth,
    required this.skillSurvival,
    required this.lvlAcrobatics,
    required this.lvlAnimalHandling,
    required this.lvlArcana,
    required this.lvlAthletics,
    required this.lvlDeception,
    required this.lvlHistory,
    required this.lvlInsight,
    required this.lvlIntimidation,
    required this.lvlInvestigation,
    required this.lvlMedicine,
    required this.lvlNature,
    required this.lvlPerception,
    required this.lvlPerformance,
    required this.lvlPersuasion,
    required this.lvlReligion,
    required this.lvlSleightOfHand,
    required this.lvlStealth,
    required this.lvlSurvival,
    required this.inspiration,
    required this.exhaustion,
    required this.conditions,
    required this.hitDiceUsed,
    required this.copperPieces,
    required this.silverPieces,
    required this.electrumPieces,
    required this.goldPieces,
    required this.platinumPieces,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || playerName != null) {
      map['player_name'] = Variable<String>(playerName);
    }
    if (!nullToAbsent || portraitPath != null) {
      map['portrait_path'] = Variable<String>(portraitPath);
    }
    if (!nullToAbsent || speciesId != null) {
      map['species_id'] = Variable<String>(speciesId);
    }
    if (!nullToAbsent || backgroundId != null) {
      map['background_id'] = Variable<String>(backgroundId);
    }
    if (!nullToAbsent || customBackgroundName != null) {
      map['custom_background_name'] = Variable<String>(customBackgroundName);
    }
    map['custom_background_skills'] = Variable<String>(customBackgroundSkills);
    map['custom_background_features'] = Variable<String>(
      customBackgroundFeatures,
    );
    map['notes'] = Variable<String>(notes);
    map['strength'] = Variable<int>(strength);
    map['dexterity'] = Variable<int>(dexterity);
    map['constitution'] = Variable<int>(constitution);
    map['intelligence'] = Variable<int>(intelligence);
    map['wisdom'] = Variable<int>(wisdom);
    map['charisma'] = Variable<int>(charisma);
    map['armor_class'] = Variable<int>(armorClass);
    map['initiative_bonus'] = Variable<int>(initiativeBonus);
    map['speed'] = Variable<int>(speed);
    if (!nullToAbsent || speedMeters != null) {
      map['speed_meters'] = Variable<double>(speedMeters);
    }
    map['max_hit_points'] = Variable<int>(maxHitPoints);
    map['current_hit_points'] = Variable<int>(currentHitPoints);
    map['temporary_hit_points'] = Variable<int>(temporaryHitPoints);
    map['save_strength'] = Variable<bool>(saveStrength);
    map['save_dexterity'] = Variable<bool>(saveDexterity);
    map['save_constitution'] = Variable<bool>(saveConstitution);
    map['save_intelligence'] = Variable<bool>(saveIntelligence);
    map['save_wisdom'] = Variable<bool>(saveWisdom);
    map['save_charisma'] = Variable<bool>(saveCharisma);
    map['skill_acrobatics'] = Variable<bool>(skillAcrobatics);
    map['skill_animal_handling'] = Variable<bool>(skillAnimalHandling);
    map['skill_arcana'] = Variable<bool>(skillArcana);
    map['skill_athletics'] = Variable<bool>(skillAthletics);
    map['skill_deception'] = Variable<bool>(skillDeception);
    map['skill_history'] = Variable<bool>(skillHistory);
    map['skill_insight'] = Variable<bool>(skillInsight);
    map['skill_intimidation'] = Variable<bool>(skillIntimidation);
    map['skill_investigation'] = Variable<bool>(skillInvestigation);
    map['skill_medicine'] = Variable<bool>(skillMedicine);
    map['skill_nature'] = Variable<bool>(skillNature);
    map['skill_perception'] = Variable<bool>(skillPerception);
    map['skill_performance'] = Variable<bool>(skillPerformance);
    map['skill_persuasion'] = Variable<bool>(skillPersuasion);
    map['skill_religion'] = Variable<bool>(skillReligion);
    map['skill_sleight_of_hand'] = Variable<bool>(skillSleightOfHand);
    map['skill_stealth'] = Variable<bool>(skillStealth);
    map['skill_survival'] = Variable<bool>(skillSurvival);
    map['lvl_acrobatics'] = Variable<int>(lvlAcrobatics);
    map['lvl_animal_handling'] = Variable<int>(lvlAnimalHandling);
    map['lvl_arcana'] = Variable<int>(lvlArcana);
    map['lvl_athletics'] = Variable<int>(lvlAthletics);
    map['lvl_deception'] = Variable<int>(lvlDeception);
    map['lvl_history'] = Variable<int>(lvlHistory);
    map['lvl_insight'] = Variable<int>(lvlInsight);
    map['lvl_intimidation'] = Variable<int>(lvlIntimidation);
    map['lvl_investigation'] = Variable<int>(lvlInvestigation);
    map['lvl_medicine'] = Variable<int>(lvlMedicine);
    map['lvl_nature'] = Variable<int>(lvlNature);
    map['lvl_perception'] = Variable<int>(lvlPerception);
    map['lvl_performance'] = Variable<int>(lvlPerformance);
    map['lvl_persuasion'] = Variable<int>(lvlPersuasion);
    map['lvl_religion'] = Variable<int>(lvlReligion);
    map['lvl_sleight_of_hand'] = Variable<int>(lvlSleightOfHand);
    map['lvl_stealth'] = Variable<int>(lvlStealth);
    map['lvl_survival'] = Variable<int>(lvlSurvival);
    map['inspiration'] = Variable<bool>(inspiration);
    map['exhaustion'] = Variable<int>(exhaustion);
    map['conditions'] = Variable<String>(conditions);
    map['hit_dice_used'] = Variable<int>(hitDiceUsed);
    map['copper_pieces'] = Variable<int>(copperPieces);
    map['silver_pieces'] = Variable<int>(silverPieces);
    map['electrum_pieces'] = Variable<int>(electrumPieces);
    map['gold_pieces'] = Variable<int>(goldPieces);
    map['platinum_pieces'] = Variable<int>(platinumPieces);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      name: Value(name),
      playerName:
          playerName == null && nullToAbsent
              ? const Value.absent()
              : Value(playerName),
      portraitPath:
          portraitPath == null && nullToAbsent
              ? const Value.absent()
              : Value(portraitPath),
      speciesId:
          speciesId == null && nullToAbsent
              ? const Value.absent()
              : Value(speciesId),
      backgroundId:
          backgroundId == null && nullToAbsent
              ? const Value.absent()
              : Value(backgroundId),
      customBackgroundName:
          customBackgroundName == null && nullToAbsent
              ? const Value.absent()
              : Value(customBackgroundName),
      customBackgroundSkills: Value(customBackgroundSkills),
      customBackgroundFeatures: Value(customBackgroundFeatures),
      notes: Value(notes),
      strength: Value(strength),
      dexterity: Value(dexterity),
      constitution: Value(constitution),
      intelligence: Value(intelligence),
      wisdom: Value(wisdom),
      charisma: Value(charisma),
      armorClass: Value(armorClass),
      initiativeBonus: Value(initiativeBonus),
      speed: Value(speed),
      speedMeters:
          speedMeters == null && nullToAbsent
              ? const Value.absent()
              : Value(speedMeters),
      maxHitPoints: Value(maxHitPoints),
      currentHitPoints: Value(currentHitPoints),
      temporaryHitPoints: Value(temporaryHitPoints),
      saveStrength: Value(saveStrength),
      saveDexterity: Value(saveDexterity),
      saveConstitution: Value(saveConstitution),
      saveIntelligence: Value(saveIntelligence),
      saveWisdom: Value(saveWisdom),
      saveCharisma: Value(saveCharisma),
      skillAcrobatics: Value(skillAcrobatics),
      skillAnimalHandling: Value(skillAnimalHandling),
      skillArcana: Value(skillArcana),
      skillAthletics: Value(skillAthletics),
      skillDeception: Value(skillDeception),
      skillHistory: Value(skillHistory),
      skillInsight: Value(skillInsight),
      skillIntimidation: Value(skillIntimidation),
      skillInvestigation: Value(skillInvestigation),
      skillMedicine: Value(skillMedicine),
      skillNature: Value(skillNature),
      skillPerception: Value(skillPerception),
      skillPerformance: Value(skillPerformance),
      skillPersuasion: Value(skillPersuasion),
      skillReligion: Value(skillReligion),
      skillSleightOfHand: Value(skillSleightOfHand),
      skillStealth: Value(skillStealth),
      skillSurvival: Value(skillSurvival),
      lvlAcrobatics: Value(lvlAcrobatics),
      lvlAnimalHandling: Value(lvlAnimalHandling),
      lvlArcana: Value(lvlArcana),
      lvlAthletics: Value(lvlAthletics),
      lvlDeception: Value(lvlDeception),
      lvlHistory: Value(lvlHistory),
      lvlInsight: Value(lvlInsight),
      lvlIntimidation: Value(lvlIntimidation),
      lvlInvestigation: Value(lvlInvestigation),
      lvlMedicine: Value(lvlMedicine),
      lvlNature: Value(lvlNature),
      lvlPerception: Value(lvlPerception),
      lvlPerformance: Value(lvlPerformance),
      lvlPersuasion: Value(lvlPersuasion),
      lvlReligion: Value(lvlReligion),
      lvlSleightOfHand: Value(lvlSleightOfHand),
      lvlStealth: Value(lvlStealth),
      lvlSurvival: Value(lvlSurvival),
      inspiration: Value(inspiration),
      exhaustion: Value(exhaustion),
      conditions: Value(conditions),
      hitDiceUsed: Value(hitDiceUsed),
      copperPieces: Value(copperPieces),
      silverPieces: Value(silverPieces),
      electrumPieces: Value(electrumPieces),
      goldPieces: Value(goldPieces),
      platinumPieces: Value(platinumPieces),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Character.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Character(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      playerName: serializer.fromJson<String?>(json['playerName']),
      portraitPath: serializer.fromJson<String?>(json['portraitPath']),
      speciesId: serializer.fromJson<String?>(json['speciesId']),
      backgroundId: serializer.fromJson<String?>(json['backgroundId']),
      customBackgroundName: serializer.fromJson<String?>(
        json['customBackgroundName'],
      ),
      customBackgroundSkills: serializer.fromJson<String>(
        json['customBackgroundSkills'],
      ),
      customBackgroundFeatures: serializer.fromJson<String>(
        json['customBackgroundFeatures'],
      ),
      notes: serializer.fromJson<String>(json['notes']),
      strength: serializer.fromJson<int>(json['strength']),
      dexterity: serializer.fromJson<int>(json['dexterity']),
      constitution: serializer.fromJson<int>(json['constitution']),
      intelligence: serializer.fromJson<int>(json['intelligence']),
      wisdom: serializer.fromJson<int>(json['wisdom']),
      charisma: serializer.fromJson<int>(json['charisma']),
      armorClass: serializer.fromJson<int>(json['armorClass']),
      initiativeBonus: serializer.fromJson<int>(json['initiativeBonus']),
      speed: serializer.fromJson<int>(json['speed']),
      speedMeters: serializer.fromJson<double?>(json['speedMeters']),
      maxHitPoints: serializer.fromJson<int>(json['maxHitPoints']),
      currentHitPoints: serializer.fromJson<int>(json['currentHitPoints']),
      temporaryHitPoints: serializer.fromJson<int>(json['temporaryHitPoints']),
      saveStrength: serializer.fromJson<bool>(json['saveStrength']),
      saveDexterity: serializer.fromJson<bool>(json['saveDexterity']),
      saveConstitution: serializer.fromJson<bool>(json['saveConstitution']),
      saveIntelligence: serializer.fromJson<bool>(json['saveIntelligence']),
      saveWisdom: serializer.fromJson<bool>(json['saveWisdom']),
      saveCharisma: serializer.fromJson<bool>(json['saveCharisma']),
      skillAcrobatics: serializer.fromJson<bool>(json['skillAcrobatics']),
      skillAnimalHandling: serializer.fromJson<bool>(
        json['skillAnimalHandling'],
      ),
      skillArcana: serializer.fromJson<bool>(json['skillArcana']),
      skillAthletics: serializer.fromJson<bool>(json['skillAthletics']),
      skillDeception: serializer.fromJson<bool>(json['skillDeception']),
      skillHistory: serializer.fromJson<bool>(json['skillHistory']),
      skillInsight: serializer.fromJson<bool>(json['skillInsight']),
      skillIntimidation: serializer.fromJson<bool>(json['skillIntimidation']),
      skillInvestigation: serializer.fromJson<bool>(json['skillInvestigation']),
      skillMedicine: serializer.fromJson<bool>(json['skillMedicine']),
      skillNature: serializer.fromJson<bool>(json['skillNature']),
      skillPerception: serializer.fromJson<bool>(json['skillPerception']),
      skillPerformance: serializer.fromJson<bool>(json['skillPerformance']),
      skillPersuasion: serializer.fromJson<bool>(json['skillPersuasion']),
      skillReligion: serializer.fromJson<bool>(json['skillReligion']),
      skillSleightOfHand: serializer.fromJson<bool>(json['skillSleightOfHand']),
      skillStealth: serializer.fromJson<bool>(json['skillStealth']),
      skillSurvival: serializer.fromJson<bool>(json['skillSurvival']),
      lvlAcrobatics: serializer.fromJson<int>(json['lvlAcrobatics']),
      lvlAnimalHandling: serializer.fromJson<int>(json['lvlAnimalHandling']),
      lvlArcana: serializer.fromJson<int>(json['lvlArcana']),
      lvlAthletics: serializer.fromJson<int>(json['lvlAthletics']),
      lvlDeception: serializer.fromJson<int>(json['lvlDeception']),
      lvlHistory: serializer.fromJson<int>(json['lvlHistory']),
      lvlInsight: serializer.fromJson<int>(json['lvlInsight']),
      lvlIntimidation: serializer.fromJson<int>(json['lvlIntimidation']),
      lvlInvestigation: serializer.fromJson<int>(json['lvlInvestigation']),
      lvlMedicine: serializer.fromJson<int>(json['lvlMedicine']),
      lvlNature: serializer.fromJson<int>(json['lvlNature']),
      lvlPerception: serializer.fromJson<int>(json['lvlPerception']),
      lvlPerformance: serializer.fromJson<int>(json['lvlPerformance']),
      lvlPersuasion: serializer.fromJson<int>(json['lvlPersuasion']),
      lvlReligion: serializer.fromJson<int>(json['lvlReligion']),
      lvlSleightOfHand: serializer.fromJson<int>(json['lvlSleightOfHand']),
      lvlStealth: serializer.fromJson<int>(json['lvlStealth']),
      lvlSurvival: serializer.fromJson<int>(json['lvlSurvival']),
      inspiration: serializer.fromJson<bool>(json['inspiration']),
      exhaustion: serializer.fromJson<int>(json['exhaustion']),
      conditions: serializer.fromJson<String>(json['conditions']),
      hitDiceUsed: serializer.fromJson<int>(json['hitDiceUsed']),
      copperPieces: serializer.fromJson<int>(json['copperPieces']),
      silverPieces: serializer.fromJson<int>(json['silverPieces']),
      electrumPieces: serializer.fromJson<int>(json['electrumPieces']),
      goldPieces: serializer.fromJson<int>(json['goldPieces']),
      platinumPieces: serializer.fromJson<int>(json['platinumPieces']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'playerName': serializer.toJson<String?>(playerName),
      'portraitPath': serializer.toJson<String?>(portraitPath),
      'speciesId': serializer.toJson<String?>(speciesId),
      'backgroundId': serializer.toJson<String?>(backgroundId),
      'customBackgroundName': serializer.toJson<String?>(customBackgroundName),
      'customBackgroundSkills': serializer.toJson<String>(
        customBackgroundSkills,
      ),
      'customBackgroundFeatures': serializer.toJson<String>(
        customBackgroundFeatures,
      ),
      'notes': serializer.toJson<String>(notes),
      'strength': serializer.toJson<int>(strength),
      'dexterity': serializer.toJson<int>(dexterity),
      'constitution': serializer.toJson<int>(constitution),
      'intelligence': serializer.toJson<int>(intelligence),
      'wisdom': serializer.toJson<int>(wisdom),
      'charisma': serializer.toJson<int>(charisma),
      'armorClass': serializer.toJson<int>(armorClass),
      'initiativeBonus': serializer.toJson<int>(initiativeBonus),
      'speed': serializer.toJson<int>(speed),
      'speedMeters': serializer.toJson<double?>(speedMeters),
      'maxHitPoints': serializer.toJson<int>(maxHitPoints),
      'currentHitPoints': serializer.toJson<int>(currentHitPoints),
      'temporaryHitPoints': serializer.toJson<int>(temporaryHitPoints),
      'saveStrength': serializer.toJson<bool>(saveStrength),
      'saveDexterity': serializer.toJson<bool>(saveDexterity),
      'saveConstitution': serializer.toJson<bool>(saveConstitution),
      'saveIntelligence': serializer.toJson<bool>(saveIntelligence),
      'saveWisdom': serializer.toJson<bool>(saveWisdom),
      'saveCharisma': serializer.toJson<bool>(saveCharisma),
      'skillAcrobatics': serializer.toJson<bool>(skillAcrobatics),
      'skillAnimalHandling': serializer.toJson<bool>(skillAnimalHandling),
      'skillArcana': serializer.toJson<bool>(skillArcana),
      'skillAthletics': serializer.toJson<bool>(skillAthletics),
      'skillDeception': serializer.toJson<bool>(skillDeception),
      'skillHistory': serializer.toJson<bool>(skillHistory),
      'skillInsight': serializer.toJson<bool>(skillInsight),
      'skillIntimidation': serializer.toJson<bool>(skillIntimidation),
      'skillInvestigation': serializer.toJson<bool>(skillInvestigation),
      'skillMedicine': serializer.toJson<bool>(skillMedicine),
      'skillNature': serializer.toJson<bool>(skillNature),
      'skillPerception': serializer.toJson<bool>(skillPerception),
      'skillPerformance': serializer.toJson<bool>(skillPerformance),
      'skillPersuasion': serializer.toJson<bool>(skillPersuasion),
      'skillReligion': serializer.toJson<bool>(skillReligion),
      'skillSleightOfHand': serializer.toJson<bool>(skillSleightOfHand),
      'skillStealth': serializer.toJson<bool>(skillStealth),
      'skillSurvival': serializer.toJson<bool>(skillSurvival),
      'lvlAcrobatics': serializer.toJson<int>(lvlAcrobatics),
      'lvlAnimalHandling': serializer.toJson<int>(lvlAnimalHandling),
      'lvlArcana': serializer.toJson<int>(lvlArcana),
      'lvlAthletics': serializer.toJson<int>(lvlAthletics),
      'lvlDeception': serializer.toJson<int>(lvlDeception),
      'lvlHistory': serializer.toJson<int>(lvlHistory),
      'lvlInsight': serializer.toJson<int>(lvlInsight),
      'lvlIntimidation': serializer.toJson<int>(lvlIntimidation),
      'lvlInvestigation': serializer.toJson<int>(lvlInvestigation),
      'lvlMedicine': serializer.toJson<int>(lvlMedicine),
      'lvlNature': serializer.toJson<int>(lvlNature),
      'lvlPerception': serializer.toJson<int>(lvlPerception),
      'lvlPerformance': serializer.toJson<int>(lvlPerformance),
      'lvlPersuasion': serializer.toJson<int>(lvlPersuasion),
      'lvlReligion': serializer.toJson<int>(lvlReligion),
      'lvlSleightOfHand': serializer.toJson<int>(lvlSleightOfHand),
      'lvlStealth': serializer.toJson<int>(lvlStealth),
      'lvlSurvival': serializer.toJson<int>(lvlSurvival),
      'inspiration': serializer.toJson<bool>(inspiration),
      'exhaustion': serializer.toJson<int>(exhaustion),
      'conditions': serializer.toJson<String>(conditions),
      'hitDiceUsed': serializer.toJson<int>(hitDiceUsed),
      'copperPieces': serializer.toJson<int>(copperPieces),
      'silverPieces': serializer.toJson<int>(silverPieces),
      'electrumPieces': serializer.toJson<int>(electrumPieces),
      'goldPieces': serializer.toJson<int>(goldPieces),
      'platinumPieces': serializer.toJson<int>(platinumPieces),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Character copyWith({
    String? id,
    String? name,
    Value<String?> playerName = const Value.absent(),
    Value<String?> portraitPath = const Value.absent(),
    Value<String?> speciesId = const Value.absent(),
    Value<String?> backgroundId = const Value.absent(),
    Value<String?> customBackgroundName = const Value.absent(),
    String? customBackgroundSkills,
    String? customBackgroundFeatures,
    String? notes,
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
    int? armorClass,
    int? initiativeBonus,
    int? speed,
    Value<double?> speedMeters = const Value.absent(),
    int? maxHitPoints,
    int? currentHitPoints,
    int? temporaryHitPoints,
    bool? saveStrength,
    bool? saveDexterity,
    bool? saveConstitution,
    bool? saveIntelligence,
    bool? saveWisdom,
    bool? saveCharisma,
    bool? skillAcrobatics,
    bool? skillAnimalHandling,
    bool? skillArcana,
    bool? skillAthletics,
    bool? skillDeception,
    bool? skillHistory,
    bool? skillInsight,
    bool? skillIntimidation,
    bool? skillInvestigation,
    bool? skillMedicine,
    bool? skillNature,
    bool? skillPerception,
    bool? skillPerformance,
    bool? skillPersuasion,
    bool? skillReligion,
    bool? skillSleightOfHand,
    bool? skillStealth,
    bool? skillSurvival,
    int? lvlAcrobatics,
    int? lvlAnimalHandling,
    int? lvlArcana,
    int? lvlAthletics,
    int? lvlDeception,
    int? lvlHistory,
    int? lvlInsight,
    int? lvlIntimidation,
    int? lvlInvestigation,
    int? lvlMedicine,
    int? lvlNature,
    int? lvlPerception,
    int? lvlPerformance,
    int? lvlPersuasion,
    int? lvlReligion,
    int? lvlSleightOfHand,
    int? lvlStealth,
    int? lvlSurvival,
    bool? inspiration,
    int? exhaustion,
    String? conditions,
    int? hitDiceUsed,
    int? copperPieces,
    int? silverPieces,
    int? electrumPieces,
    int? goldPieces,
    int? platinumPieces,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Character(
    id: id ?? this.id,
    name: name ?? this.name,
    playerName: playerName.present ? playerName.value : this.playerName,
    portraitPath: portraitPath.present ? portraitPath.value : this.portraitPath,
    speciesId: speciesId.present ? speciesId.value : this.speciesId,
    backgroundId: backgroundId.present ? backgroundId.value : this.backgroundId,
    customBackgroundName:
        customBackgroundName.present
            ? customBackgroundName.value
            : this.customBackgroundName,
    customBackgroundSkills:
        customBackgroundSkills ?? this.customBackgroundSkills,
    customBackgroundFeatures:
        customBackgroundFeatures ?? this.customBackgroundFeatures,
    notes: notes ?? this.notes,
    strength: strength ?? this.strength,
    dexterity: dexterity ?? this.dexterity,
    constitution: constitution ?? this.constitution,
    intelligence: intelligence ?? this.intelligence,
    wisdom: wisdom ?? this.wisdom,
    charisma: charisma ?? this.charisma,
    armorClass: armorClass ?? this.armorClass,
    initiativeBonus: initiativeBonus ?? this.initiativeBonus,
    speed: speed ?? this.speed,
    speedMeters: speedMeters.present ? speedMeters.value : this.speedMeters,
    maxHitPoints: maxHitPoints ?? this.maxHitPoints,
    currentHitPoints: currentHitPoints ?? this.currentHitPoints,
    temporaryHitPoints: temporaryHitPoints ?? this.temporaryHitPoints,
    saveStrength: saveStrength ?? this.saveStrength,
    saveDexterity: saveDexterity ?? this.saveDexterity,
    saveConstitution: saveConstitution ?? this.saveConstitution,
    saveIntelligence: saveIntelligence ?? this.saveIntelligence,
    saveWisdom: saveWisdom ?? this.saveWisdom,
    saveCharisma: saveCharisma ?? this.saveCharisma,
    skillAcrobatics: skillAcrobatics ?? this.skillAcrobatics,
    skillAnimalHandling: skillAnimalHandling ?? this.skillAnimalHandling,
    skillArcana: skillArcana ?? this.skillArcana,
    skillAthletics: skillAthletics ?? this.skillAthletics,
    skillDeception: skillDeception ?? this.skillDeception,
    skillHistory: skillHistory ?? this.skillHistory,
    skillInsight: skillInsight ?? this.skillInsight,
    skillIntimidation: skillIntimidation ?? this.skillIntimidation,
    skillInvestigation: skillInvestigation ?? this.skillInvestigation,
    skillMedicine: skillMedicine ?? this.skillMedicine,
    skillNature: skillNature ?? this.skillNature,
    skillPerception: skillPerception ?? this.skillPerception,
    skillPerformance: skillPerformance ?? this.skillPerformance,
    skillPersuasion: skillPersuasion ?? this.skillPersuasion,
    skillReligion: skillReligion ?? this.skillReligion,
    skillSleightOfHand: skillSleightOfHand ?? this.skillSleightOfHand,
    skillStealth: skillStealth ?? this.skillStealth,
    skillSurvival: skillSurvival ?? this.skillSurvival,
    lvlAcrobatics: lvlAcrobatics ?? this.lvlAcrobatics,
    lvlAnimalHandling: lvlAnimalHandling ?? this.lvlAnimalHandling,
    lvlArcana: lvlArcana ?? this.lvlArcana,
    lvlAthletics: lvlAthletics ?? this.lvlAthletics,
    lvlDeception: lvlDeception ?? this.lvlDeception,
    lvlHistory: lvlHistory ?? this.lvlHistory,
    lvlInsight: lvlInsight ?? this.lvlInsight,
    lvlIntimidation: lvlIntimidation ?? this.lvlIntimidation,
    lvlInvestigation: lvlInvestigation ?? this.lvlInvestigation,
    lvlMedicine: lvlMedicine ?? this.lvlMedicine,
    lvlNature: lvlNature ?? this.lvlNature,
    lvlPerception: lvlPerception ?? this.lvlPerception,
    lvlPerformance: lvlPerformance ?? this.lvlPerformance,
    lvlPersuasion: lvlPersuasion ?? this.lvlPersuasion,
    lvlReligion: lvlReligion ?? this.lvlReligion,
    lvlSleightOfHand: lvlSleightOfHand ?? this.lvlSleightOfHand,
    lvlStealth: lvlStealth ?? this.lvlStealth,
    lvlSurvival: lvlSurvival ?? this.lvlSurvival,
    inspiration: inspiration ?? this.inspiration,
    exhaustion: exhaustion ?? this.exhaustion,
    conditions: conditions ?? this.conditions,
    hitDiceUsed: hitDiceUsed ?? this.hitDiceUsed,
    copperPieces: copperPieces ?? this.copperPieces,
    silverPieces: silverPieces ?? this.silverPieces,
    electrumPieces: electrumPieces ?? this.electrumPieces,
    goldPieces: goldPieces ?? this.goldPieces,
    platinumPieces: platinumPieces ?? this.platinumPieces,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Character copyWithCompanion(CharactersCompanion data) {
    return Character(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      playerName:
          data.playerName.present ? data.playerName.value : this.playerName,
      portraitPath:
          data.portraitPath.present
              ? data.portraitPath.value
              : this.portraitPath,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      backgroundId:
          data.backgroundId.present
              ? data.backgroundId.value
              : this.backgroundId,
      customBackgroundName:
          data.customBackgroundName.present
              ? data.customBackgroundName.value
              : this.customBackgroundName,
      customBackgroundSkills:
          data.customBackgroundSkills.present
              ? data.customBackgroundSkills.value
              : this.customBackgroundSkills,
      customBackgroundFeatures:
          data.customBackgroundFeatures.present
              ? data.customBackgroundFeatures.value
              : this.customBackgroundFeatures,
      notes: data.notes.present ? data.notes.value : this.notes,
      strength: data.strength.present ? data.strength.value : this.strength,
      dexterity: data.dexterity.present ? data.dexterity.value : this.dexterity,
      constitution:
          data.constitution.present
              ? data.constitution.value
              : this.constitution,
      intelligence:
          data.intelligence.present
              ? data.intelligence.value
              : this.intelligence,
      wisdom: data.wisdom.present ? data.wisdom.value : this.wisdom,
      charisma: data.charisma.present ? data.charisma.value : this.charisma,
      armorClass:
          data.armorClass.present ? data.armorClass.value : this.armorClass,
      initiativeBonus:
          data.initiativeBonus.present
              ? data.initiativeBonus.value
              : this.initiativeBonus,
      speed: data.speed.present ? data.speed.value : this.speed,
      speedMeters:
          data.speedMeters.present ? data.speedMeters.value : this.speedMeters,
      maxHitPoints:
          data.maxHitPoints.present
              ? data.maxHitPoints.value
              : this.maxHitPoints,
      currentHitPoints:
          data.currentHitPoints.present
              ? data.currentHitPoints.value
              : this.currentHitPoints,
      temporaryHitPoints:
          data.temporaryHitPoints.present
              ? data.temporaryHitPoints.value
              : this.temporaryHitPoints,
      saveStrength:
          data.saveStrength.present
              ? data.saveStrength.value
              : this.saveStrength,
      saveDexterity:
          data.saveDexterity.present
              ? data.saveDexterity.value
              : this.saveDexterity,
      saveConstitution:
          data.saveConstitution.present
              ? data.saveConstitution.value
              : this.saveConstitution,
      saveIntelligence:
          data.saveIntelligence.present
              ? data.saveIntelligence.value
              : this.saveIntelligence,
      saveWisdom:
          data.saveWisdom.present ? data.saveWisdom.value : this.saveWisdom,
      saveCharisma:
          data.saveCharisma.present
              ? data.saveCharisma.value
              : this.saveCharisma,
      skillAcrobatics:
          data.skillAcrobatics.present
              ? data.skillAcrobatics.value
              : this.skillAcrobatics,
      skillAnimalHandling:
          data.skillAnimalHandling.present
              ? data.skillAnimalHandling.value
              : this.skillAnimalHandling,
      skillArcana:
          data.skillArcana.present ? data.skillArcana.value : this.skillArcana,
      skillAthletics:
          data.skillAthletics.present
              ? data.skillAthletics.value
              : this.skillAthletics,
      skillDeception:
          data.skillDeception.present
              ? data.skillDeception.value
              : this.skillDeception,
      skillHistory:
          data.skillHistory.present
              ? data.skillHistory.value
              : this.skillHistory,
      skillInsight:
          data.skillInsight.present
              ? data.skillInsight.value
              : this.skillInsight,
      skillIntimidation:
          data.skillIntimidation.present
              ? data.skillIntimidation.value
              : this.skillIntimidation,
      skillInvestigation:
          data.skillInvestigation.present
              ? data.skillInvestigation.value
              : this.skillInvestigation,
      skillMedicine:
          data.skillMedicine.present
              ? data.skillMedicine.value
              : this.skillMedicine,
      skillNature:
          data.skillNature.present ? data.skillNature.value : this.skillNature,
      skillPerception:
          data.skillPerception.present
              ? data.skillPerception.value
              : this.skillPerception,
      skillPerformance:
          data.skillPerformance.present
              ? data.skillPerformance.value
              : this.skillPerformance,
      skillPersuasion:
          data.skillPersuasion.present
              ? data.skillPersuasion.value
              : this.skillPersuasion,
      skillReligion:
          data.skillReligion.present
              ? data.skillReligion.value
              : this.skillReligion,
      skillSleightOfHand:
          data.skillSleightOfHand.present
              ? data.skillSleightOfHand.value
              : this.skillSleightOfHand,
      skillStealth:
          data.skillStealth.present
              ? data.skillStealth.value
              : this.skillStealth,
      skillSurvival:
          data.skillSurvival.present
              ? data.skillSurvival.value
              : this.skillSurvival,
      lvlAcrobatics:
          data.lvlAcrobatics.present
              ? data.lvlAcrobatics.value
              : this.lvlAcrobatics,
      lvlAnimalHandling:
          data.lvlAnimalHandling.present
              ? data.lvlAnimalHandling.value
              : this.lvlAnimalHandling,
      lvlArcana: data.lvlArcana.present ? data.lvlArcana.value : this.lvlArcana,
      lvlAthletics:
          data.lvlAthletics.present
              ? data.lvlAthletics.value
              : this.lvlAthletics,
      lvlDeception:
          data.lvlDeception.present
              ? data.lvlDeception.value
              : this.lvlDeception,
      lvlHistory:
          data.lvlHistory.present ? data.lvlHistory.value : this.lvlHistory,
      lvlInsight:
          data.lvlInsight.present ? data.lvlInsight.value : this.lvlInsight,
      lvlIntimidation:
          data.lvlIntimidation.present
              ? data.lvlIntimidation.value
              : this.lvlIntimidation,
      lvlInvestigation:
          data.lvlInvestigation.present
              ? data.lvlInvestigation.value
              : this.lvlInvestigation,
      lvlMedicine:
          data.lvlMedicine.present ? data.lvlMedicine.value : this.lvlMedicine,
      lvlNature: data.lvlNature.present ? data.lvlNature.value : this.lvlNature,
      lvlPerception:
          data.lvlPerception.present
              ? data.lvlPerception.value
              : this.lvlPerception,
      lvlPerformance:
          data.lvlPerformance.present
              ? data.lvlPerformance.value
              : this.lvlPerformance,
      lvlPersuasion:
          data.lvlPersuasion.present
              ? data.lvlPersuasion.value
              : this.lvlPersuasion,
      lvlReligion:
          data.lvlReligion.present ? data.lvlReligion.value : this.lvlReligion,
      lvlSleightOfHand:
          data.lvlSleightOfHand.present
              ? data.lvlSleightOfHand.value
              : this.lvlSleightOfHand,
      lvlStealth:
          data.lvlStealth.present ? data.lvlStealth.value : this.lvlStealth,
      lvlSurvival:
          data.lvlSurvival.present ? data.lvlSurvival.value : this.lvlSurvival,
      inspiration:
          data.inspiration.present ? data.inspiration.value : this.inspiration,
      exhaustion:
          data.exhaustion.present ? data.exhaustion.value : this.exhaustion,
      conditions:
          data.conditions.present ? data.conditions.value : this.conditions,
      hitDiceUsed:
          data.hitDiceUsed.present ? data.hitDiceUsed.value : this.hitDiceUsed,
      copperPieces:
          data.copperPieces.present
              ? data.copperPieces.value
              : this.copperPieces,
      silverPieces:
          data.silverPieces.present
              ? data.silverPieces.value
              : this.silverPieces,
      electrumPieces:
          data.electrumPieces.present
              ? data.electrumPieces.value
              : this.electrumPieces,
      goldPieces:
          data.goldPieces.present ? data.goldPieces.value : this.goldPieces,
      platinumPieces:
          data.platinumPieces.present
              ? data.platinumPieces.value
              : this.platinumPieces,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Character(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('playerName: $playerName, ')
          ..write('portraitPath: $portraitPath, ')
          ..write('speciesId: $speciesId, ')
          ..write('backgroundId: $backgroundId, ')
          ..write('customBackgroundName: $customBackgroundName, ')
          ..write('customBackgroundSkills: $customBackgroundSkills, ')
          ..write('customBackgroundFeatures: $customBackgroundFeatures, ')
          ..write('notes: $notes, ')
          ..write('strength: $strength, ')
          ..write('dexterity: $dexterity, ')
          ..write('constitution: $constitution, ')
          ..write('intelligence: $intelligence, ')
          ..write('wisdom: $wisdom, ')
          ..write('charisma: $charisma, ')
          ..write('armorClass: $armorClass, ')
          ..write('initiativeBonus: $initiativeBonus, ')
          ..write('speed: $speed, ')
          ..write('speedMeters: $speedMeters, ')
          ..write('maxHitPoints: $maxHitPoints, ')
          ..write('currentHitPoints: $currentHitPoints, ')
          ..write('temporaryHitPoints: $temporaryHitPoints, ')
          ..write('saveStrength: $saveStrength, ')
          ..write('saveDexterity: $saveDexterity, ')
          ..write('saveConstitution: $saveConstitution, ')
          ..write('saveIntelligence: $saveIntelligence, ')
          ..write('saveWisdom: $saveWisdom, ')
          ..write('saveCharisma: $saveCharisma, ')
          ..write('skillAcrobatics: $skillAcrobatics, ')
          ..write('skillAnimalHandling: $skillAnimalHandling, ')
          ..write('skillArcana: $skillArcana, ')
          ..write('skillAthletics: $skillAthletics, ')
          ..write('skillDeception: $skillDeception, ')
          ..write('skillHistory: $skillHistory, ')
          ..write('skillInsight: $skillInsight, ')
          ..write('skillIntimidation: $skillIntimidation, ')
          ..write('skillInvestigation: $skillInvestigation, ')
          ..write('skillMedicine: $skillMedicine, ')
          ..write('skillNature: $skillNature, ')
          ..write('skillPerception: $skillPerception, ')
          ..write('skillPerformance: $skillPerformance, ')
          ..write('skillPersuasion: $skillPersuasion, ')
          ..write('skillReligion: $skillReligion, ')
          ..write('skillSleightOfHand: $skillSleightOfHand, ')
          ..write('skillStealth: $skillStealth, ')
          ..write('skillSurvival: $skillSurvival, ')
          ..write('lvlAcrobatics: $lvlAcrobatics, ')
          ..write('lvlAnimalHandling: $lvlAnimalHandling, ')
          ..write('lvlArcana: $lvlArcana, ')
          ..write('lvlAthletics: $lvlAthletics, ')
          ..write('lvlDeception: $lvlDeception, ')
          ..write('lvlHistory: $lvlHistory, ')
          ..write('lvlInsight: $lvlInsight, ')
          ..write('lvlIntimidation: $lvlIntimidation, ')
          ..write('lvlInvestigation: $lvlInvestigation, ')
          ..write('lvlMedicine: $lvlMedicine, ')
          ..write('lvlNature: $lvlNature, ')
          ..write('lvlPerception: $lvlPerception, ')
          ..write('lvlPerformance: $lvlPerformance, ')
          ..write('lvlPersuasion: $lvlPersuasion, ')
          ..write('lvlReligion: $lvlReligion, ')
          ..write('lvlSleightOfHand: $lvlSleightOfHand, ')
          ..write('lvlStealth: $lvlStealth, ')
          ..write('lvlSurvival: $lvlSurvival, ')
          ..write('inspiration: $inspiration, ')
          ..write('exhaustion: $exhaustion, ')
          ..write('conditions: $conditions, ')
          ..write('hitDiceUsed: $hitDiceUsed, ')
          ..write('copperPieces: $copperPieces, ')
          ..write('silverPieces: $silverPieces, ')
          ..write('electrumPieces: $electrumPieces, ')
          ..write('goldPieces: $goldPieces, ')
          ..write('platinumPieces: $platinumPieces, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    playerName,
    portraitPath,
    speciesId,
    backgroundId,
    customBackgroundName,
    customBackgroundSkills,
    customBackgroundFeatures,
    notes,
    strength,
    dexterity,
    constitution,
    intelligence,
    wisdom,
    charisma,
    armorClass,
    initiativeBonus,
    speed,
    speedMeters,
    maxHitPoints,
    currentHitPoints,
    temporaryHitPoints,
    saveStrength,
    saveDexterity,
    saveConstitution,
    saveIntelligence,
    saveWisdom,
    saveCharisma,
    skillAcrobatics,
    skillAnimalHandling,
    skillArcana,
    skillAthletics,
    skillDeception,
    skillHistory,
    skillInsight,
    skillIntimidation,
    skillInvestigation,
    skillMedicine,
    skillNature,
    skillPerception,
    skillPerformance,
    skillPersuasion,
    skillReligion,
    skillSleightOfHand,
    skillStealth,
    skillSurvival,
    lvlAcrobatics,
    lvlAnimalHandling,
    lvlArcana,
    lvlAthletics,
    lvlDeception,
    lvlHistory,
    lvlInsight,
    lvlIntimidation,
    lvlInvestigation,
    lvlMedicine,
    lvlNature,
    lvlPerception,
    lvlPerformance,
    lvlPersuasion,
    lvlReligion,
    lvlSleightOfHand,
    lvlStealth,
    lvlSurvival,
    inspiration,
    exhaustion,
    conditions,
    hitDiceUsed,
    copperPieces,
    silverPieces,
    electrumPieces,
    goldPieces,
    platinumPieces,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Character &&
          other.id == this.id &&
          other.name == this.name &&
          other.playerName == this.playerName &&
          other.portraitPath == this.portraitPath &&
          other.speciesId == this.speciesId &&
          other.backgroundId == this.backgroundId &&
          other.customBackgroundName == this.customBackgroundName &&
          other.customBackgroundSkills == this.customBackgroundSkills &&
          other.customBackgroundFeatures == this.customBackgroundFeatures &&
          other.notes == this.notes &&
          other.strength == this.strength &&
          other.dexterity == this.dexterity &&
          other.constitution == this.constitution &&
          other.intelligence == this.intelligence &&
          other.wisdom == this.wisdom &&
          other.charisma == this.charisma &&
          other.armorClass == this.armorClass &&
          other.initiativeBonus == this.initiativeBonus &&
          other.speed == this.speed &&
          other.speedMeters == this.speedMeters &&
          other.maxHitPoints == this.maxHitPoints &&
          other.currentHitPoints == this.currentHitPoints &&
          other.temporaryHitPoints == this.temporaryHitPoints &&
          other.saveStrength == this.saveStrength &&
          other.saveDexterity == this.saveDexterity &&
          other.saveConstitution == this.saveConstitution &&
          other.saveIntelligence == this.saveIntelligence &&
          other.saveWisdom == this.saveWisdom &&
          other.saveCharisma == this.saveCharisma &&
          other.skillAcrobatics == this.skillAcrobatics &&
          other.skillAnimalHandling == this.skillAnimalHandling &&
          other.skillArcana == this.skillArcana &&
          other.skillAthletics == this.skillAthletics &&
          other.skillDeception == this.skillDeception &&
          other.skillHistory == this.skillHistory &&
          other.skillInsight == this.skillInsight &&
          other.skillIntimidation == this.skillIntimidation &&
          other.skillInvestigation == this.skillInvestigation &&
          other.skillMedicine == this.skillMedicine &&
          other.skillNature == this.skillNature &&
          other.skillPerception == this.skillPerception &&
          other.skillPerformance == this.skillPerformance &&
          other.skillPersuasion == this.skillPersuasion &&
          other.skillReligion == this.skillReligion &&
          other.skillSleightOfHand == this.skillSleightOfHand &&
          other.skillStealth == this.skillStealth &&
          other.skillSurvival == this.skillSurvival &&
          other.lvlAcrobatics == this.lvlAcrobatics &&
          other.lvlAnimalHandling == this.lvlAnimalHandling &&
          other.lvlArcana == this.lvlArcana &&
          other.lvlAthletics == this.lvlAthletics &&
          other.lvlDeception == this.lvlDeception &&
          other.lvlHistory == this.lvlHistory &&
          other.lvlInsight == this.lvlInsight &&
          other.lvlIntimidation == this.lvlIntimidation &&
          other.lvlInvestigation == this.lvlInvestigation &&
          other.lvlMedicine == this.lvlMedicine &&
          other.lvlNature == this.lvlNature &&
          other.lvlPerception == this.lvlPerception &&
          other.lvlPerformance == this.lvlPerformance &&
          other.lvlPersuasion == this.lvlPersuasion &&
          other.lvlReligion == this.lvlReligion &&
          other.lvlSleightOfHand == this.lvlSleightOfHand &&
          other.lvlStealth == this.lvlStealth &&
          other.lvlSurvival == this.lvlSurvival &&
          other.inspiration == this.inspiration &&
          other.exhaustion == this.exhaustion &&
          other.conditions == this.conditions &&
          other.hitDiceUsed == this.hitDiceUsed &&
          other.copperPieces == this.copperPieces &&
          other.silverPieces == this.silverPieces &&
          other.electrumPieces == this.electrumPieces &&
          other.goldPieces == this.goldPieces &&
          other.platinumPieces == this.platinumPieces &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CharactersCompanion extends UpdateCompanion<Character> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> playerName;
  final Value<String?> portraitPath;
  final Value<String?> speciesId;
  final Value<String?> backgroundId;
  final Value<String?> customBackgroundName;
  final Value<String> customBackgroundSkills;
  final Value<String> customBackgroundFeatures;
  final Value<String> notes;
  final Value<int> strength;
  final Value<int> dexterity;
  final Value<int> constitution;
  final Value<int> intelligence;
  final Value<int> wisdom;
  final Value<int> charisma;
  final Value<int> armorClass;
  final Value<int> initiativeBonus;
  final Value<int> speed;
  final Value<double?> speedMeters;
  final Value<int> maxHitPoints;
  final Value<int> currentHitPoints;
  final Value<int> temporaryHitPoints;
  final Value<bool> saveStrength;
  final Value<bool> saveDexterity;
  final Value<bool> saveConstitution;
  final Value<bool> saveIntelligence;
  final Value<bool> saveWisdom;
  final Value<bool> saveCharisma;
  final Value<bool> skillAcrobatics;
  final Value<bool> skillAnimalHandling;
  final Value<bool> skillArcana;
  final Value<bool> skillAthletics;
  final Value<bool> skillDeception;
  final Value<bool> skillHistory;
  final Value<bool> skillInsight;
  final Value<bool> skillIntimidation;
  final Value<bool> skillInvestigation;
  final Value<bool> skillMedicine;
  final Value<bool> skillNature;
  final Value<bool> skillPerception;
  final Value<bool> skillPerformance;
  final Value<bool> skillPersuasion;
  final Value<bool> skillReligion;
  final Value<bool> skillSleightOfHand;
  final Value<bool> skillStealth;
  final Value<bool> skillSurvival;
  final Value<int> lvlAcrobatics;
  final Value<int> lvlAnimalHandling;
  final Value<int> lvlArcana;
  final Value<int> lvlAthletics;
  final Value<int> lvlDeception;
  final Value<int> lvlHistory;
  final Value<int> lvlInsight;
  final Value<int> lvlIntimidation;
  final Value<int> lvlInvestigation;
  final Value<int> lvlMedicine;
  final Value<int> lvlNature;
  final Value<int> lvlPerception;
  final Value<int> lvlPerformance;
  final Value<int> lvlPersuasion;
  final Value<int> lvlReligion;
  final Value<int> lvlSleightOfHand;
  final Value<int> lvlStealth;
  final Value<int> lvlSurvival;
  final Value<bool> inspiration;
  final Value<int> exhaustion;
  final Value<String> conditions;
  final Value<int> hitDiceUsed;
  final Value<int> copperPieces;
  final Value<int> silverPieces;
  final Value<int> electrumPieces;
  final Value<int> goldPieces;
  final Value<int> platinumPieces;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.playerName = const Value.absent(),
    this.portraitPath = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.backgroundId = const Value.absent(),
    this.customBackgroundName = const Value.absent(),
    this.customBackgroundSkills = const Value.absent(),
    this.customBackgroundFeatures = const Value.absent(),
    this.notes = const Value.absent(),
    this.strength = const Value.absent(),
    this.dexterity = const Value.absent(),
    this.constitution = const Value.absent(),
    this.intelligence = const Value.absent(),
    this.wisdom = const Value.absent(),
    this.charisma = const Value.absent(),
    this.armorClass = const Value.absent(),
    this.initiativeBonus = const Value.absent(),
    this.speed = const Value.absent(),
    this.speedMeters = const Value.absent(),
    this.maxHitPoints = const Value.absent(),
    this.currentHitPoints = const Value.absent(),
    this.temporaryHitPoints = const Value.absent(),
    this.saveStrength = const Value.absent(),
    this.saveDexterity = const Value.absent(),
    this.saveConstitution = const Value.absent(),
    this.saveIntelligence = const Value.absent(),
    this.saveWisdom = const Value.absent(),
    this.saveCharisma = const Value.absent(),
    this.skillAcrobatics = const Value.absent(),
    this.skillAnimalHandling = const Value.absent(),
    this.skillArcana = const Value.absent(),
    this.skillAthletics = const Value.absent(),
    this.skillDeception = const Value.absent(),
    this.skillHistory = const Value.absent(),
    this.skillInsight = const Value.absent(),
    this.skillIntimidation = const Value.absent(),
    this.skillInvestigation = const Value.absent(),
    this.skillMedicine = const Value.absent(),
    this.skillNature = const Value.absent(),
    this.skillPerception = const Value.absent(),
    this.skillPerformance = const Value.absent(),
    this.skillPersuasion = const Value.absent(),
    this.skillReligion = const Value.absent(),
    this.skillSleightOfHand = const Value.absent(),
    this.skillStealth = const Value.absent(),
    this.skillSurvival = const Value.absent(),
    this.lvlAcrobatics = const Value.absent(),
    this.lvlAnimalHandling = const Value.absent(),
    this.lvlArcana = const Value.absent(),
    this.lvlAthletics = const Value.absent(),
    this.lvlDeception = const Value.absent(),
    this.lvlHistory = const Value.absent(),
    this.lvlInsight = const Value.absent(),
    this.lvlIntimidation = const Value.absent(),
    this.lvlInvestigation = const Value.absent(),
    this.lvlMedicine = const Value.absent(),
    this.lvlNature = const Value.absent(),
    this.lvlPerception = const Value.absent(),
    this.lvlPerformance = const Value.absent(),
    this.lvlPersuasion = const Value.absent(),
    this.lvlReligion = const Value.absent(),
    this.lvlSleightOfHand = const Value.absent(),
    this.lvlStealth = const Value.absent(),
    this.lvlSurvival = const Value.absent(),
    this.inspiration = const Value.absent(),
    this.exhaustion = const Value.absent(),
    this.conditions = const Value.absent(),
    this.hitDiceUsed = const Value.absent(),
    this.copperPieces = const Value.absent(),
    this.silverPieces = const Value.absent(),
    this.electrumPieces = const Value.absent(),
    this.goldPieces = const Value.absent(),
    this.platinumPieces = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharactersCompanion.insert({
    required String id,
    required String name,
    this.playerName = const Value.absent(),
    this.portraitPath = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.backgroundId = const Value.absent(),
    this.customBackgroundName = const Value.absent(),
    this.customBackgroundSkills = const Value.absent(),
    this.customBackgroundFeatures = const Value.absent(),
    this.notes = const Value.absent(),
    this.strength = const Value.absent(),
    this.dexterity = const Value.absent(),
    this.constitution = const Value.absent(),
    this.intelligence = const Value.absent(),
    this.wisdom = const Value.absent(),
    this.charisma = const Value.absent(),
    this.armorClass = const Value.absent(),
    this.initiativeBonus = const Value.absent(),
    this.speed = const Value.absent(),
    this.speedMeters = const Value.absent(),
    this.maxHitPoints = const Value.absent(),
    this.currentHitPoints = const Value.absent(),
    this.temporaryHitPoints = const Value.absent(),
    this.saveStrength = const Value.absent(),
    this.saveDexterity = const Value.absent(),
    this.saveConstitution = const Value.absent(),
    this.saveIntelligence = const Value.absent(),
    this.saveWisdom = const Value.absent(),
    this.saveCharisma = const Value.absent(),
    this.skillAcrobatics = const Value.absent(),
    this.skillAnimalHandling = const Value.absent(),
    this.skillArcana = const Value.absent(),
    this.skillAthletics = const Value.absent(),
    this.skillDeception = const Value.absent(),
    this.skillHistory = const Value.absent(),
    this.skillInsight = const Value.absent(),
    this.skillIntimidation = const Value.absent(),
    this.skillInvestigation = const Value.absent(),
    this.skillMedicine = const Value.absent(),
    this.skillNature = const Value.absent(),
    this.skillPerception = const Value.absent(),
    this.skillPerformance = const Value.absent(),
    this.skillPersuasion = const Value.absent(),
    this.skillReligion = const Value.absent(),
    this.skillSleightOfHand = const Value.absent(),
    this.skillStealth = const Value.absent(),
    this.skillSurvival = const Value.absent(),
    this.lvlAcrobatics = const Value.absent(),
    this.lvlAnimalHandling = const Value.absent(),
    this.lvlArcana = const Value.absent(),
    this.lvlAthletics = const Value.absent(),
    this.lvlDeception = const Value.absent(),
    this.lvlHistory = const Value.absent(),
    this.lvlInsight = const Value.absent(),
    this.lvlIntimidation = const Value.absent(),
    this.lvlInvestigation = const Value.absent(),
    this.lvlMedicine = const Value.absent(),
    this.lvlNature = const Value.absent(),
    this.lvlPerception = const Value.absent(),
    this.lvlPerformance = const Value.absent(),
    this.lvlPersuasion = const Value.absent(),
    this.lvlReligion = const Value.absent(),
    this.lvlSleightOfHand = const Value.absent(),
    this.lvlStealth = const Value.absent(),
    this.lvlSurvival = const Value.absent(),
    this.inspiration = const Value.absent(),
    this.exhaustion = const Value.absent(),
    this.conditions = const Value.absent(),
    this.hitDiceUsed = const Value.absent(),
    this.copperPieces = const Value.absent(),
    this.silverPieces = const Value.absent(),
    this.electrumPieces = const Value.absent(),
    this.goldPieces = const Value.absent(),
    this.platinumPieces = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Character> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? playerName,
    Expression<String>? portraitPath,
    Expression<String>? speciesId,
    Expression<String>? backgroundId,
    Expression<String>? customBackgroundName,
    Expression<String>? customBackgroundSkills,
    Expression<String>? customBackgroundFeatures,
    Expression<String>? notes,
    Expression<int>? strength,
    Expression<int>? dexterity,
    Expression<int>? constitution,
    Expression<int>? intelligence,
    Expression<int>? wisdom,
    Expression<int>? charisma,
    Expression<int>? armorClass,
    Expression<int>? initiativeBonus,
    Expression<int>? speed,
    Expression<double>? speedMeters,
    Expression<int>? maxHitPoints,
    Expression<int>? currentHitPoints,
    Expression<int>? temporaryHitPoints,
    Expression<bool>? saveStrength,
    Expression<bool>? saveDexterity,
    Expression<bool>? saveConstitution,
    Expression<bool>? saveIntelligence,
    Expression<bool>? saveWisdom,
    Expression<bool>? saveCharisma,
    Expression<bool>? skillAcrobatics,
    Expression<bool>? skillAnimalHandling,
    Expression<bool>? skillArcana,
    Expression<bool>? skillAthletics,
    Expression<bool>? skillDeception,
    Expression<bool>? skillHistory,
    Expression<bool>? skillInsight,
    Expression<bool>? skillIntimidation,
    Expression<bool>? skillInvestigation,
    Expression<bool>? skillMedicine,
    Expression<bool>? skillNature,
    Expression<bool>? skillPerception,
    Expression<bool>? skillPerformance,
    Expression<bool>? skillPersuasion,
    Expression<bool>? skillReligion,
    Expression<bool>? skillSleightOfHand,
    Expression<bool>? skillStealth,
    Expression<bool>? skillSurvival,
    Expression<int>? lvlAcrobatics,
    Expression<int>? lvlAnimalHandling,
    Expression<int>? lvlArcana,
    Expression<int>? lvlAthletics,
    Expression<int>? lvlDeception,
    Expression<int>? lvlHistory,
    Expression<int>? lvlInsight,
    Expression<int>? lvlIntimidation,
    Expression<int>? lvlInvestigation,
    Expression<int>? lvlMedicine,
    Expression<int>? lvlNature,
    Expression<int>? lvlPerception,
    Expression<int>? lvlPerformance,
    Expression<int>? lvlPersuasion,
    Expression<int>? lvlReligion,
    Expression<int>? lvlSleightOfHand,
    Expression<int>? lvlStealth,
    Expression<int>? lvlSurvival,
    Expression<bool>? inspiration,
    Expression<int>? exhaustion,
    Expression<String>? conditions,
    Expression<int>? hitDiceUsed,
    Expression<int>? copperPieces,
    Expression<int>? silverPieces,
    Expression<int>? electrumPieces,
    Expression<int>? goldPieces,
    Expression<int>? platinumPieces,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (playerName != null) 'player_name': playerName,
      if (portraitPath != null) 'portrait_path': portraitPath,
      if (speciesId != null) 'species_id': speciesId,
      if (backgroundId != null) 'background_id': backgroundId,
      if (customBackgroundName != null)
        'custom_background_name': customBackgroundName,
      if (customBackgroundSkills != null)
        'custom_background_skills': customBackgroundSkills,
      if (customBackgroundFeatures != null)
        'custom_background_features': customBackgroundFeatures,
      if (notes != null) 'notes': notes,
      if (strength != null) 'strength': strength,
      if (dexterity != null) 'dexterity': dexterity,
      if (constitution != null) 'constitution': constitution,
      if (intelligence != null) 'intelligence': intelligence,
      if (wisdom != null) 'wisdom': wisdom,
      if (charisma != null) 'charisma': charisma,
      if (armorClass != null) 'armor_class': armorClass,
      if (initiativeBonus != null) 'initiative_bonus': initiativeBonus,
      if (speed != null) 'speed': speed,
      if (speedMeters != null) 'speed_meters': speedMeters,
      if (maxHitPoints != null) 'max_hit_points': maxHitPoints,
      if (currentHitPoints != null) 'current_hit_points': currentHitPoints,
      if (temporaryHitPoints != null)
        'temporary_hit_points': temporaryHitPoints,
      if (saveStrength != null) 'save_strength': saveStrength,
      if (saveDexterity != null) 'save_dexterity': saveDexterity,
      if (saveConstitution != null) 'save_constitution': saveConstitution,
      if (saveIntelligence != null) 'save_intelligence': saveIntelligence,
      if (saveWisdom != null) 'save_wisdom': saveWisdom,
      if (saveCharisma != null) 'save_charisma': saveCharisma,
      if (skillAcrobatics != null) 'skill_acrobatics': skillAcrobatics,
      if (skillAnimalHandling != null)
        'skill_animal_handling': skillAnimalHandling,
      if (skillArcana != null) 'skill_arcana': skillArcana,
      if (skillAthletics != null) 'skill_athletics': skillAthletics,
      if (skillDeception != null) 'skill_deception': skillDeception,
      if (skillHistory != null) 'skill_history': skillHistory,
      if (skillInsight != null) 'skill_insight': skillInsight,
      if (skillIntimidation != null) 'skill_intimidation': skillIntimidation,
      if (skillInvestigation != null) 'skill_investigation': skillInvestigation,
      if (skillMedicine != null) 'skill_medicine': skillMedicine,
      if (skillNature != null) 'skill_nature': skillNature,
      if (skillPerception != null) 'skill_perception': skillPerception,
      if (skillPerformance != null) 'skill_performance': skillPerformance,
      if (skillPersuasion != null) 'skill_persuasion': skillPersuasion,
      if (skillReligion != null) 'skill_religion': skillReligion,
      if (skillSleightOfHand != null)
        'skill_sleight_of_hand': skillSleightOfHand,
      if (skillStealth != null) 'skill_stealth': skillStealth,
      if (skillSurvival != null) 'skill_survival': skillSurvival,
      if (lvlAcrobatics != null) 'lvl_acrobatics': lvlAcrobatics,
      if (lvlAnimalHandling != null) 'lvl_animal_handling': lvlAnimalHandling,
      if (lvlArcana != null) 'lvl_arcana': lvlArcana,
      if (lvlAthletics != null) 'lvl_athletics': lvlAthletics,
      if (lvlDeception != null) 'lvl_deception': lvlDeception,
      if (lvlHistory != null) 'lvl_history': lvlHistory,
      if (lvlInsight != null) 'lvl_insight': lvlInsight,
      if (lvlIntimidation != null) 'lvl_intimidation': lvlIntimidation,
      if (lvlInvestigation != null) 'lvl_investigation': lvlInvestigation,
      if (lvlMedicine != null) 'lvl_medicine': lvlMedicine,
      if (lvlNature != null) 'lvl_nature': lvlNature,
      if (lvlPerception != null) 'lvl_perception': lvlPerception,
      if (lvlPerformance != null) 'lvl_performance': lvlPerformance,
      if (lvlPersuasion != null) 'lvl_persuasion': lvlPersuasion,
      if (lvlReligion != null) 'lvl_religion': lvlReligion,
      if (lvlSleightOfHand != null) 'lvl_sleight_of_hand': lvlSleightOfHand,
      if (lvlStealth != null) 'lvl_stealth': lvlStealth,
      if (lvlSurvival != null) 'lvl_survival': lvlSurvival,
      if (inspiration != null) 'inspiration': inspiration,
      if (exhaustion != null) 'exhaustion': exhaustion,
      if (conditions != null) 'conditions': conditions,
      if (hitDiceUsed != null) 'hit_dice_used': hitDiceUsed,
      if (copperPieces != null) 'copper_pieces': copperPieces,
      if (silverPieces != null) 'silver_pieces': silverPieces,
      if (electrumPieces != null) 'electrum_pieces': electrumPieces,
      if (goldPieces != null) 'gold_pieces': goldPieces,
      if (platinumPieces != null) 'platinum_pieces': platinumPieces,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharactersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? playerName,
    Value<String?>? portraitPath,
    Value<String?>? speciesId,
    Value<String?>? backgroundId,
    Value<String?>? customBackgroundName,
    Value<String>? customBackgroundSkills,
    Value<String>? customBackgroundFeatures,
    Value<String>? notes,
    Value<int>? strength,
    Value<int>? dexterity,
    Value<int>? constitution,
    Value<int>? intelligence,
    Value<int>? wisdom,
    Value<int>? charisma,
    Value<int>? armorClass,
    Value<int>? initiativeBonus,
    Value<int>? speed,
    Value<double?>? speedMeters,
    Value<int>? maxHitPoints,
    Value<int>? currentHitPoints,
    Value<int>? temporaryHitPoints,
    Value<bool>? saveStrength,
    Value<bool>? saveDexterity,
    Value<bool>? saveConstitution,
    Value<bool>? saveIntelligence,
    Value<bool>? saveWisdom,
    Value<bool>? saveCharisma,
    Value<bool>? skillAcrobatics,
    Value<bool>? skillAnimalHandling,
    Value<bool>? skillArcana,
    Value<bool>? skillAthletics,
    Value<bool>? skillDeception,
    Value<bool>? skillHistory,
    Value<bool>? skillInsight,
    Value<bool>? skillIntimidation,
    Value<bool>? skillInvestigation,
    Value<bool>? skillMedicine,
    Value<bool>? skillNature,
    Value<bool>? skillPerception,
    Value<bool>? skillPerformance,
    Value<bool>? skillPersuasion,
    Value<bool>? skillReligion,
    Value<bool>? skillSleightOfHand,
    Value<bool>? skillStealth,
    Value<bool>? skillSurvival,
    Value<int>? lvlAcrobatics,
    Value<int>? lvlAnimalHandling,
    Value<int>? lvlArcana,
    Value<int>? lvlAthletics,
    Value<int>? lvlDeception,
    Value<int>? lvlHistory,
    Value<int>? lvlInsight,
    Value<int>? lvlIntimidation,
    Value<int>? lvlInvestigation,
    Value<int>? lvlMedicine,
    Value<int>? lvlNature,
    Value<int>? lvlPerception,
    Value<int>? lvlPerformance,
    Value<int>? lvlPersuasion,
    Value<int>? lvlReligion,
    Value<int>? lvlSleightOfHand,
    Value<int>? lvlStealth,
    Value<int>? lvlSurvival,
    Value<bool>? inspiration,
    Value<int>? exhaustion,
    Value<String>? conditions,
    Value<int>? hitDiceUsed,
    Value<int>? copperPieces,
    Value<int>? silverPieces,
    Value<int>? electrumPieces,
    Value<int>? goldPieces,
    Value<int>? platinumPieces,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      playerName: playerName ?? this.playerName,
      portraitPath: portraitPath ?? this.portraitPath,
      speciesId: speciesId ?? this.speciesId,
      backgroundId: backgroundId ?? this.backgroundId,
      customBackgroundName: customBackgroundName ?? this.customBackgroundName,
      customBackgroundSkills:
          customBackgroundSkills ?? this.customBackgroundSkills,
      customBackgroundFeatures:
          customBackgroundFeatures ?? this.customBackgroundFeatures,
      notes: notes ?? this.notes,
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
      armorClass: armorClass ?? this.armorClass,
      initiativeBonus: initiativeBonus ?? this.initiativeBonus,
      speed: speed ?? this.speed,
      speedMeters: speedMeters ?? this.speedMeters,
      maxHitPoints: maxHitPoints ?? this.maxHitPoints,
      currentHitPoints: currentHitPoints ?? this.currentHitPoints,
      temporaryHitPoints: temporaryHitPoints ?? this.temporaryHitPoints,
      saveStrength: saveStrength ?? this.saveStrength,
      saveDexterity: saveDexterity ?? this.saveDexterity,
      saveConstitution: saveConstitution ?? this.saveConstitution,
      saveIntelligence: saveIntelligence ?? this.saveIntelligence,
      saveWisdom: saveWisdom ?? this.saveWisdom,
      saveCharisma: saveCharisma ?? this.saveCharisma,
      skillAcrobatics: skillAcrobatics ?? this.skillAcrobatics,
      skillAnimalHandling: skillAnimalHandling ?? this.skillAnimalHandling,
      skillArcana: skillArcana ?? this.skillArcana,
      skillAthletics: skillAthletics ?? this.skillAthletics,
      skillDeception: skillDeception ?? this.skillDeception,
      skillHistory: skillHistory ?? this.skillHistory,
      skillInsight: skillInsight ?? this.skillInsight,
      skillIntimidation: skillIntimidation ?? this.skillIntimidation,
      skillInvestigation: skillInvestigation ?? this.skillInvestigation,
      skillMedicine: skillMedicine ?? this.skillMedicine,
      skillNature: skillNature ?? this.skillNature,
      skillPerception: skillPerception ?? this.skillPerception,
      skillPerformance: skillPerformance ?? this.skillPerformance,
      skillPersuasion: skillPersuasion ?? this.skillPersuasion,
      skillReligion: skillReligion ?? this.skillReligion,
      skillSleightOfHand: skillSleightOfHand ?? this.skillSleightOfHand,
      skillStealth: skillStealth ?? this.skillStealth,
      skillSurvival: skillSurvival ?? this.skillSurvival,
      lvlAcrobatics: lvlAcrobatics ?? this.lvlAcrobatics,
      lvlAnimalHandling: lvlAnimalHandling ?? this.lvlAnimalHandling,
      lvlArcana: lvlArcana ?? this.lvlArcana,
      lvlAthletics: lvlAthletics ?? this.lvlAthletics,
      lvlDeception: lvlDeception ?? this.lvlDeception,
      lvlHistory: lvlHistory ?? this.lvlHistory,
      lvlInsight: lvlInsight ?? this.lvlInsight,
      lvlIntimidation: lvlIntimidation ?? this.lvlIntimidation,
      lvlInvestigation: lvlInvestigation ?? this.lvlInvestigation,
      lvlMedicine: lvlMedicine ?? this.lvlMedicine,
      lvlNature: lvlNature ?? this.lvlNature,
      lvlPerception: lvlPerception ?? this.lvlPerception,
      lvlPerformance: lvlPerformance ?? this.lvlPerformance,
      lvlPersuasion: lvlPersuasion ?? this.lvlPersuasion,
      lvlReligion: lvlReligion ?? this.lvlReligion,
      lvlSleightOfHand: lvlSleightOfHand ?? this.lvlSleightOfHand,
      lvlStealth: lvlStealth ?? this.lvlStealth,
      lvlSurvival: lvlSurvival ?? this.lvlSurvival,
      inspiration: inspiration ?? this.inspiration,
      exhaustion: exhaustion ?? this.exhaustion,
      conditions: conditions ?? this.conditions,
      hitDiceUsed: hitDiceUsed ?? this.hitDiceUsed,
      copperPieces: copperPieces ?? this.copperPieces,
      silverPieces: silverPieces ?? this.silverPieces,
      electrumPieces: electrumPieces ?? this.electrumPieces,
      goldPieces: goldPieces ?? this.goldPieces,
      platinumPieces: platinumPieces ?? this.platinumPieces,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (playerName.present) {
      map['player_name'] = Variable<String>(playerName.value);
    }
    if (portraitPath.present) {
      map['portrait_path'] = Variable<String>(portraitPath.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (backgroundId.present) {
      map['background_id'] = Variable<String>(backgroundId.value);
    }
    if (customBackgroundName.present) {
      map['custom_background_name'] = Variable<String>(
        customBackgroundName.value,
      );
    }
    if (customBackgroundSkills.present) {
      map['custom_background_skills'] = Variable<String>(
        customBackgroundSkills.value,
      );
    }
    if (customBackgroundFeatures.present) {
      map['custom_background_features'] = Variable<String>(
        customBackgroundFeatures.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (strength.present) {
      map['strength'] = Variable<int>(strength.value);
    }
    if (dexterity.present) {
      map['dexterity'] = Variable<int>(dexterity.value);
    }
    if (constitution.present) {
      map['constitution'] = Variable<int>(constitution.value);
    }
    if (intelligence.present) {
      map['intelligence'] = Variable<int>(intelligence.value);
    }
    if (wisdom.present) {
      map['wisdom'] = Variable<int>(wisdom.value);
    }
    if (charisma.present) {
      map['charisma'] = Variable<int>(charisma.value);
    }
    if (armorClass.present) {
      map['armor_class'] = Variable<int>(armorClass.value);
    }
    if (initiativeBonus.present) {
      map['initiative_bonus'] = Variable<int>(initiativeBonus.value);
    }
    if (speed.present) {
      map['speed'] = Variable<int>(speed.value);
    }
    if (speedMeters.present) {
      map['speed_meters'] = Variable<double>(speedMeters.value);
    }
    if (maxHitPoints.present) {
      map['max_hit_points'] = Variable<int>(maxHitPoints.value);
    }
    if (currentHitPoints.present) {
      map['current_hit_points'] = Variable<int>(currentHitPoints.value);
    }
    if (temporaryHitPoints.present) {
      map['temporary_hit_points'] = Variable<int>(temporaryHitPoints.value);
    }
    if (saveStrength.present) {
      map['save_strength'] = Variable<bool>(saveStrength.value);
    }
    if (saveDexterity.present) {
      map['save_dexterity'] = Variable<bool>(saveDexterity.value);
    }
    if (saveConstitution.present) {
      map['save_constitution'] = Variable<bool>(saveConstitution.value);
    }
    if (saveIntelligence.present) {
      map['save_intelligence'] = Variable<bool>(saveIntelligence.value);
    }
    if (saveWisdom.present) {
      map['save_wisdom'] = Variable<bool>(saveWisdom.value);
    }
    if (saveCharisma.present) {
      map['save_charisma'] = Variable<bool>(saveCharisma.value);
    }
    if (skillAcrobatics.present) {
      map['skill_acrobatics'] = Variable<bool>(skillAcrobatics.value);
    }
    if (skillAnimalHandling.present) {
      map['skill_animal_handling'] = Variable<bool>(skillAnimalHandling.value);
    }
    if (skillArcana.present) {
      map['skill_arcana'] = Variable<bool>(skillArcana.value);
    }
    if (skillAthletics.present) {
      map['skill_athletics'] = Variable<bool>(skillAthletics.value);
    }
    if (skillDeception.present) {
      map['skill_deception'] = Variable<bool>(skillDeception.value);
    }
    if (skillHistory.present) {
      map['skill_history'] = Variable<bool>(skillHistory.value);
    }
    if (skillInsight.present) {
      map['skill_insight'] = Variable<bool>(skillInsight.value);
    }
    if (skillIntimidation.present) {
      map['skill_intimidation'] = Variable<bool>(skillIntimidation.value);
    }
    if (skillInvestigation.present) {
      map['skill_investigation'] = Variable<bool>(skillInvestigation.value);
    }
    if (skillMedicine.present) {
      map['skill_medicine'] = Variable<bool>(skillMedicine.value);
    }
    if (skillNature.present) {
      map['skill_nature'] = Variable<bool>(skillNature.value);
    }
    if (skillPerception.present) {
      map['skill_perception'] = Variable<bool>(skillPerception.value);
    }
    if (skillPerformance.present) {
      map['skill_performance'] = Variable<bool>(skillPerformance.value);
    }
    if (skillPersuasion.present) {
      map['skill_persuasion'] = Variable<bool>(skillPersuasion.value);
    }
    if (skillReligion.present) {
      map['skill_religion'] = Variable<bool>(skillReligion.value);
    }
    if (skillSleightOfHand.present) {
      map['skill_sleight_of_hand'] = Variable<bool>(skillSleightOfHand.value);
    }
    if (skillStealth.present) {
      map['skill_stealth'] = Variable<bool>(skillStealth.value);
    }
    if (skillSurvival.present) {
      map['skill_survival'] = Variable<bool>(skillSurvival.value);
    }
    if (lvlAcrobatics.present) {
      map['lvl_acrobatics'] = Variable<int>(lvlAcrobatics.value);
    }
    if (lvlAnimalHandling.present) {
      map['lvl_animal_handling'] = Variable<int>(lvlAnimalHandling.value);
    }
    if (lvlArcana.present) {
      map['lvl_arcana'] = Variable<int>(lvlArcana.value);
    }
    if (lvlAthletics.present) {
      map['lvl_athletics'] = Variable<int>(lvlAthletics.value);
    }
    if (lvlDeception.present) {
      map['lvl_deception'] = Variable<int>(lvlDeception.value);
    }
    if (lvlHistory.present) {
      map['lvl_history'] = Variable<int>(lvlHistory.value);
    }
    if (lvlInsight.present) {
      map['lvl_insight'] = Variable<int>(lvlInsight.value);
    }
    if (lvlIntimidation.present) {
      map['lvl_intimidation'] = Variable<int>(lvlIntimidation.value);
    }
    if (lvlInvestigation.present) {
      map['lvl_investigation'] = Variable<int>(lvlInvestigation.value);
    }
    if (lvlMedicine.present) {
      map['lvl_medicine'] = Variable<int>(lvlMedicine.value);
    }
    if (lvlNature.present) {
      map['lvl_nature'] = Variable<int>(lvlNature.value);
    }
    if (lvlPerception.present) {
      map['lvl_perception'] = Variable<int>(lvlPerception.value);
    }
    if (lvlPerformance.present) {
      map['lvl_performance'] = Variable<int>(lvlPerformance.value);
    }
    if (lvlPersuasion.present) {
      map['lvl_persuasion'] = Variable<int>(lvlPersuasion.value);
    }
    if (lvlReligion.present) {
      map['lvl_religion'] = Variable<int>(lvlReligion.value);
    }
    if (lvlSleightOfHand.present) {
      map['lvl_sleight_of_hand'] = Variable<int>(lvlSleightOfHand.value);
    }
    if (lvlStealth.present) {
      map['lvl_stealth'] = Variable<int>(lvlStealth.value);
    }
    if (lvlSurvival.present) {
      map['lvl_survival'] = Variable<int>(lvlSurvival.value);
    }
    if (inspiration.present) {
      map['inspiration'] = Variable<bool>(inspiration.value);
    }
    if (exhaustion.present) {
      map['exhaustion'] = Variable<int>(exhaustion.value);
    }
    if (conditions.present) {
      map['conditions'] = Variable<String>(conditions.value);
    }
    if (hitDiceUsed.present) {
      map['hit_dice_used'] = Variable<int>(hitDiceUsed.value);
    }
    if (copperPieces.present) {
      map['copper_pieces'] = Variable<int>(copperPieces.value);
    }
    if (silverPieces.present) {
      map['silver_pieces'] = Variable<int>(silverPieces.value);
    }
    if (electrumPieces.present) {
      map['electrum_pieces'] = Variable<int>(electrumPieces.value);
    }
    if (goldPieces.present) {
      map['gold_pieces'] = Variable<int>(goldPieces.value);
    }
    if (platinumPieces.present) {
      map['platinum_pieces'] = Variable<int>(platinumPieces.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('playerName: $playerName, ')
          ..write('portraitPath: $portraitPath, ')
          ..write('speciesId: $speciesId, ')
          ..write('backgroundId: $backgroundId, ')
          ..write('customBackgroundName: $customBackgroundName, ')
          ..write('customBackgroundSkills: $customBackgroundSkills, ')
          ..write('customBackgroundFeatures: $customBackgroundFeatures, ')
          ..write('notes: $notes, ')
          ..write('strength: $strength, ')
          ..write('dexterity: $dexterity, ')
          ..write('constitution: $constitution, ')
          ..write('intelligence: $intelligence, ')
          ..write('wisdom: $wisdom, ')
          ..write('charisma: $charisma, ')
          ..write('armorClass: $armorClass, ')
          ..write('initiativeBonus: $initiativeBonus, ')
          ..write('speed: $speed, ')
          ..write('speedMeters: $speedMeters, ')
          ..write('maxHitPoints: $maxHitPoints, ')
          ..write('currentHitPoints: $currentHitPoints, ')
          ..write('temporaryHitPoints: $temporaryHitPoints, ')
          ..write('saveStrength: $saveStrength, ')
          ..write('saveDexterity: $saveDexterity, ')
          ..write('saveConstitution: $saveConstitution, ')
          ..write('saveIntelligence: $saveIntelligence, ')
          ..write('saveWisdom: $saveWisdom, ')
          ..write('saveCharisma: $saveCharisma, ')
          ..write('skillAcrobatics: $skillAcrobatics, ')
          ..write('skillAnimalHandling: $skillAnimalHandling, ')
          ..write('skillArcana: $skillArcana, ')
          ..write('skillAthletics: $skillAthletics, ')
          ..write('skillDeception: $skillDeception, ')
          ..write('skillHistory: $skillHistory, ')
          ..write('skillInsight: $skillInsight, ')
          ..write('skillIntimidation: $skillIntimidation, ')
          ..write('skillInvestigation: $skillInvestigation, ')
          ..write('skillMedicine: $skillMedicine, ')
          ..write('skillNature: $skillNature, ')
          ..write('skillPerception: $skillPerception, ')
          ..write('skillPerformance: $skillPerformance, ')
          ..write('skillPersuasion: $skillPersuasion, ')
          ..write('skillReligion: $skillReligion, ')
          ..write('skillSleightOfHand: $skillSleightOfHand, ')
          ..write('skillStealth: $skillStealth, ')
          ..write('skillSurvival: $skillSurvival, ')
          ..write('lvlAcrobatics: $lvlAcrobatics, ')
          ..write('lvlAnimalHandling: $lvlAnimalHandling, ')
          ..write('lvlArcana: $lvlArcana, ')
          ..write('lvlAthletics: $lvlAthletics, ')
          ..write('lvlDeception: $lvlDeception, ')
          ..write('lvlHistory: $lvlHistory, ')
          ..write('lvlInsight: $lvlInsight, ')
          ..write('lvlIntimidation: $lvlIntimidation, ')
          ..write('lvlInvestigation: $lvlInvestigation, ')
          ..write('lvlMedicine: $lvlMedicine, ')
          ..write('lvlNature: $lvlNature, ')
          ..write('lvlPerception: $lvlPerception, ')
          ..write('lvlPerformance: $lvlPerformance, ')
          ..write('lvlPersuasion: $lvlPersuasion, ')
          ..write('lvlReligion: $lvlReligion, ')
          ..write('lvlSleightOfHand: $lvlSleightOfHand, ')
          ..write('lvlStealth: $lvlStealth, ')
          ..write('lvlSurvival: $lvlSurvival, ')
          ..write('inspiration: $inspiration, ')
          ..write('exhaustion: $exhaustion, ')
          ..write('conditions: $conditions, ')
          ..write('hitDiceUsed: $hitDiceUsed, ')
          ..write('copperPieces: $copperPieces, ')
          ..write('silverPieces: $silverPieces, ')
          ..write('electrumPieces: $electrumPieces, ')
          ..write('goldPieces: $goldPieces, ')
          ..write('platinumPieces: $platinumPieces, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharacterClassLevelsTable extends CharacterClassLevels
    with TableInfo<$CharacterClassLevelsTable, CharacterClassLevel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterClassLevelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id)',
    ),
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subclassIdMeta = const VerificationMeta(
    'subclassId',
  );
  @override
  late final GeneratedColumn<String> subclassId = GeneratedColumn<String>(
    'subclass_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spellcastingAbilityMeta =
      const VerificationMeta('spellcastingAbility');
  @override
  late final GeneratedColumn<String> spellcastingAbility =
      GeneratedColumn<String>(
        'spellcasting_ability',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _spellcastingTypeMeta = const VerificationMeta(
    'spellcastingType',
  );
  @override
  late final GeneratedColumn<String> spellcastingType = GeneratedColumn<String>(
    'spellcasting_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    characterId,
    classId,
    subclassId,
    level,
    spellcastingAbility,
    spellcastingType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_class_levels';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterClassLevel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('subclass_id')) {
      context.handle(
        _subclassIdMeta,
        subclassId.isAcceptableOrUnknown(data['subclass_id']!, _subclassIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('spellcasting_ability')) {
      context.handle(
        _spellcastingAbilityMeta,
        spellcastingAbility.isAcceptableOrUnknown(
          data['spellcasting_ability']!,
          _spellcastingAbilityMeta,
        ),
      );
    }
    if (data.containsKey('spellcasting_type')) {
      context.handle(
        _spellcastingTypeMeta,
        spellcastingType.isAcceptableOrUnknown(
          data['spellcasting_type']!,
          _spellcastingTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  CharacterClassLevel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterClassLevel(
      localId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}local_id'],
          )!,
      characterId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}character_id'],
          )!,
      classId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}class_id'],
          )!,
      subclassId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subclass_id'],
      ),
      level:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}level'],
          )!,
      spellcastingAbility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spellcasting_ability'],
      ),
      spellcastingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spellcasting_type'],
      ),
    );
  }

  @override
  $CharacterClassLevelsTable createAlias(String alias) {
    return $CharacterClassLevelsTable(attachedDatabase, alias);
  }
}

class CharacterClassLevel extends DataClass
    implements Insertable<CharacterClassLevel> {
  final int localId;
  final String characterId;
  final String classId;
  final String? subclassId;
  final int level;
  final String? spellcastingAbility;
  final String? spellcastingType;
  const CharacterClassLevel({
    required this.localId,
    required this.characterId,
    required this.classId,
    this.subclassId,
    required this.level,
    this.spellcastingAbility,
    this.spellcastingType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['character_id'] = Variable<String>(characterId);
    map['class_id'] = Variable<String>(classId);
    if (!nullToAbsent || subclassId != null) {
      map['subclass_id'] = Variable<String>(subclassId);
    }
    map['level'] = Variable<int>(level);
    if (!nullToAbsent || spellcastingAbility != null) {
      map['spellcasting_ability'] = Variable<String>(spellcastingAbility);
    }
    if (!nullToAbsent || spellcastingType != null) {
      map['spellcasting_type'] = Variable<String>(spellcastingType);
    }
    return map;
  }

  CharacterClassLevelsCompanion toCompanion(bool nullToAbsent) {
    return CharacterClassLevelsCompanion(
      localId: Value(localId),
      characterId: Value(characterId),
      classId: Value(classId),
      subclassId:
          subclassId == null && nullToAbsent
              ? const Value.absent()
              : Value(subclassId),
      level: Value(level),
      spellcastingAbility:
          spellcastingAbility == null && nullToAbsent
              ? const Value.absent()
              : Value(spellcastingAbility),
      spellcastingType:
          spellcastingType == null && nullToAbsent
              ? const Value.absent()
              : Value(spellcastingType),
    );
  }

  factory CharacterClassLevel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterClassLevel(
      localId: serializer.fromJson<int>(json['localId']),
      characterId: serializer.fromJson<String>(json['characterId']),
      classId: serializer.fromJson<String>(json['classId']),
      subclassId: serializer.fromJson<String?>(json['subclassId']),
      level: serializer.fromJson<int>(json['level']),
      spellcastingAbility: serializer.fromJson<String?>(
        json['spellcastingAbility'],
      ),
      spellcastingType: serializer.fromJson<String?>(json['spellcastingType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'characterId': serializer.toJson<String>(characterId),
      'classId': serializer.toJson<String>(classId),
      'subclassId': serializer.toJson<String?>(subclassId),
      'level': serializer.toJson<int>(level),
      'spellcastingAbility': serializer.toJson<String?>(spellcastingAbility),
      'spellcastingType': serializer.toJson<String?>(spellcastingType),
    };
  }

  CharacterClassLevel copyWith({
    int? localId,
    String? characterId,
    String? classId,
    Value<String?> subclassId = const Value.absent(),
    int? level,
    Value<String?> spellcastingAbility = const Value.absent(),
    Value<String?> spellcastingType = const Value.absent(),
  }) => CharacterClassLevel(
    localId: localId ?? this.localId,
    characterId: characterId ?? this.characterId,
    classId: classId ?? this.classId,
    subclassId: subclassId.present ? subclassId.value : this.subclassId,
    level: level ?? this.level,
    spellcastingAbility:
        spellcastingAbility.present
            ? spellcastingAbility.value
            : this.spellcastingAbility,
    spellcastingType:
        spellcastingType.present
            ? spellcastingType.value
            : this.spellcastingType,
  );
  CharacterClassLevel copyWithCompanion(CharacterClassLevelsCompanion data) {
    return CharacterClassLevel(
      localId: data.localId.present ? data.localId.value : this.localId,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      classId: data.classId.present ? data.classId.value : this.classId,
      subclassId:
          data.subclassId.present ? data.subclassId.value : this.subclassId,
      level: data.level.present ? data.level.value : this.level,
      spellcastingAbility:
          data.spellcastingAbility.present
              ? data.spellcastingAbility.value
              : this.spellcastingAbility,
      spellcastingType:
          data.spellcastingType.present
              ? data.spellcastingType.value
              : this.spellcastingType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterClassLevel(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('classId: $classId, ')
          ..write('subclassId: $subclassId, ')
          ..write('level: $level, ')
          ..write('spellcastingAbility: $spellcastingAbility, ')
          ..write('spellcastingType: $spellcastingType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    characterId,
    classId,
    subclassId,
    level,
    spellcastingAbility,
    spellcastingType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterClassLevel &&
          other.localId == this.localId &&
          other.characterId == this.characterId &&
          other.classId == this.classId &&
          other.subclassId == this.subclassId &&
          other.level == this.level &&
          other.spellcastingAbility == this.spellcastingAbility &&
          other.spellcastingType == this.spellcastingType);
}

class CharacterClassLevelsCompanion
    extends UpdateCompanion<CharacterClassLevel> {
  final Value<int> localId;
  final Value<String> characterId;
  final Value<String> classId;
  final Value<String?> subclassId;
  final Value<int> level;
  final Value<String?> spellcastingAbility;
  final Value<String?> spellcastingType;
  const CharacterClassLevelsCompanion({
    this.localId = const Value.absent(),
    this.characterId = const Value.absent(),
    this.classId = const Value.absent(),
    this.subclassId = const Value.absent(),
    this.level = const Value.absent(),
    this.spellcastingAbility = const Value.absent(),
    this.spellcastingType = const Value.absent(),
  });
  CharacterClassLevelsCompanion.insert({
    this.localId = const Value.absent(),
    required String characterId,
    required String classId,
    this.subclassId = const Value.absent(),
    required int level,
    this.spellcastingAbility = const Value.absent(),
    this.spellcastingType = const Value.absent(),
  }) : characterId = Value(characterId),
       classId = Value(classId),
       level = Value(level);
  static Insertable<CharacterClassLevel> custom({
    Expression<int>? localId,
    Expression<String>? characterId,
    Expression<String>? classId,
    Expression<String>? subclassId,
    Expression<int>? level,
    Expression<String>? spellcastingAbility,
    Expression<String>? spellcastingType,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (characterId != null) 'character_id': characterId,
      if (classId != null) 'class_id': classId,
      if (subclassId != null) 'subclass_id': subclassId,
      if (level != null) 'level': level,
      if (spellcastingAbility != null)
        'spellcasting_ability': spellcastingAbility,
      if (spellcastingType != null) 'spellcasting_type': spellcastingType,
    });
  }

  CharacterClassLevelsCompanion copyWith({
    Value<int>? localId,
    Value<String>? characterId,
    Value<String>? classId,
    Value<String?>? subclassId,
    Value<int>? level,
    Value<String?>? spellcastingAbility,
    Value<String?>? spellcastingType,
  }) {
    return CharacterClassLevelsCompanion(
      localId: localId ?? this.localId,
      characterId: characterId ?? this.characterId,
      classId: classId ?? this.classId,
      subclassId: subclassId ?? this.subclassId,
      level: level ?? this.level,
      spellcastingAbility: spellcastingAbility ?? this.spellcastingAbility,
      spellcastingType: spellcastingType ?? this.spellcastingType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (subclassId.present) {
      map['subclass_id'] = Variable<String>(subclassId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (spellcastingAbility.present) {
      map['spellcasting_ability'] = Variable<String>(spellcastingAbility.value);
    }
    if (spellcastingType.present) {
      map['spellcasting_type'] = Variable<String>(spellcastingType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterClassLevelsCompanion(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('classId: $classId, ')
          ..write('subclassId: $subclassId, ')
          ..write('level: $level, ')
          ..write('spellcastingAbility: $spellcastingAbility, ')
          ..write('spellcastingType: $spellcastingType')
          ..write(')'))
        .toString();
  }
}

class $CharacterSpellsTable extends CharacterSpells
    with TableInfo<$CharacterSpellsTable, CharacterSpell> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterSpellsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id)',
    ),
  );
  static const VerificationMeta _spellIdMeta = const VerificationMeta(
    'spellId',
  );
  @override
  late final GeneratedColumn<int> spellId = GeneratedColumn<int>(
    'spell_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPreparedMeta = const VerificationMeta(
    'isPrepared',
  );
  @override
  late final GeneratedColumn<bool> isPrepared = GeneratedColumn<bool>(
    'is_prepared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_prepared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isKnownMeta = const VerificationMeta(
    'isKnown',
  );
  @override
  late final GeneratedColumn<bool> isKnown = GeneratedColumn<bool>(
    'is_known',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_known" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isAlwaysAvailableMeta = const VerificationMeta(
    'isAlwaysAvailable',
  );
  @override
  late final GeneratedColumn<bool> isAlwaysAvailable = GeneratedColumn<bool>(
    'is_always_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_always_available" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    characterId,
    spellId,
    sourceType,
    sourceId,
    sourceName,
    isPrepared,
    isKnown,
    isAlwaysAvailable,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_spells';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterSpell> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('spell_id')) {
      context.handle(
        _spellIdMeta,
        spellId.isAcceptableOrUnknown(data['spell_id']!, _spellIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spellIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('is_prepared')) {
      context.handle(
        _isPreparedMeta,
        isPrepared.isAcceptableOrUnknown(data['is_prepared']!, _isPreparedMeta),
      );
    }
    if (data.containsKey('is_known')) {
      context.handle(
        _isKnownMeta,
        isKnown.isAcceptableOrUnknown(data['is_known']!, _isKnownMeta),
      );
    }
    if (data.containsKey('is_always_available')) {
      context.handle(
        _isAlwaysAvailableMeta,
        isAlwaysAvailable.isAcceptableOrUnknown(
          data['is_always_available']!,
          _isAlwaysAvailableMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  CharacterSpell map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterSpell(
      localId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}local_id'],
          )!,
      characterId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}character_id'],
          )!,
      spellId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}spell_id'],
          )!,
      sourceType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}source_type'],
          )!,
      sourceId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}source_id'],
          )!,
      sourceName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}source_name'],
          )!,
      isPrepared:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_prepared'],
          )!,
      isKnown:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_known'],
          )!,
      isAlwaysAvailable:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_always_available'],
          )!,
      notes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}notes'],
          )!,
    );
  }

  @override
  $CharacterSpellsTable createAlias(String alias) {
    return $CharacterSpellsTable(attachedDatabase, alias);
  }
}

class CharacterSpell extends DataClass implements Insertable<CharacterSpell> {
  final int localId;
  final String characterId;
  final int spellId;
  final String sourceType;
  final String sourceId;
  final String sourceName;
  final bool isPrepared;
  final bool isKnown;
  final bool isAlwaysAvailable;
  final String notes;
  const CharacterSpell({
    required this.localId,
    required this.characterId,
    required this.spellId,
    required this.sourceType,
    required this.sourceId,
    required this.sourceName,
    required this.isPrepared,
    required this.isKnown,
    required this.isAlwaysAvailable,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['character_id'] = Variable<String>(characterId);
    map['spell_id'] = Variable<int>(spellId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['source_name'] = Variable<String>(sourceName);
    map['is_prepared'] = Variable<bool>(isPrepared);
    map['is_known'] = Variable<bool>(isKnown);
    map['is_always_available'] = Variable<bool>(isAlwaysAvailable);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  CharacterSpellsCompanion toCompanion(bool nullToAbsent) {
    return CharacterSpellsCompanion(
      localId: Value(localId),
      characterId: Value(characterId),
      spellId: Value(spellId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      sourceName: Value(sourceName),
      isPrepared: Value(isPrepared),
      isKnown: Value(isKnown),
      isAlwaysAvailable: Value(isAlwaysAvailable),
      notes: Value(notes),
    );
  }

  factory CharacterSpell.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterSpell(
      localId: serializer.fromJson<int>(json['localId']),
      characterId: serializer.fromJson<String>(json['characterId']),
      spellId: serializer.fromJson<int>(json['spellId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      isPrepared: serializer.fromJson<bool>(json['isPrepared']),
      isKnown: serializer.fromJson<bool>(json['isKnown']),
      isAlwaysAvailable: serializer.fromJson<bool>(json['isAlwaysAvailable']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'characterId': serializer.toJson<String>(characterId),
      'spellId': serializer.toJson<int>(spellId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'sourceName': serializer.toJson<String>(sourceName),
      'isPrepared': serializer.toJson<bool>(isPrepared),
      'isKnown': serializer.toJson<bool>(isKnown),
      'isAlwaysAvailable': serializer.toJson<bool>(isAlwaysAvailable),
      'notes': serializer.toJson<String>(notes),
    };
  }

  CharacterSpell copyWith({
    int? localId,
    String? characterId,
    int? spellId,
    String? sourceType,
    String? sourceId,
    String? sourceName,
    bool? isPrepared,
    bool? isKnown,
    bool? isAlwaysAvailable,
    String? notes,
  }) => CharacterSpell(
    localId: localId ?? this.localId,
    characterId: characterId ?? this.characterId,
    spellId: spellId ?? this.spellId,
    sourceType: sourceType ?? this.sourceType,
    sourceId: sourceId ?? this.sourceId,
    sourceName: sourceName ?? this.sourceName,
    isPrepared: isPrepared ?? this.isPrepared,
    isKnown: isKnown ?? this.isKnown,
    isAlwaysAvailable: isAlwaysAvailable ?? this.isAlwaysAvailable,
    notes: notes ?? this.notes,
  );
  CharacterSpell copyWithCompanion(CharacterSpellsCompanion data) {
    return CharacterSpell(
      localId: data.localId.present ? data.localId.value : this.localId,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      spellId: data.spellId.present ? data.spellId.value : this.spellId,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceName:
          data.sourceName.present ? data.sourceName.value : this.sourceName,
      isPrepared:
          data.isPrepared.present ? data.isPrepared.value : this.isPrepared,
      isKnown: data.isKnown.present ? data.isKnown.value : this.isKnown,
      isAlwaysAvailable:
          data.isAlwaysAvailable.present
              ? data.isAlwaysAvailable.value
              : this.isAlwaysAvailable,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSpell(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('spellId: $spellId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceName: $sourceName, ')
          ..write('isPrepared: $isPrepared, ')
          ..write('isKnown: $isKnown, ')
          ..write('isAlwaysAvailable: $isAlwaysAvailable, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    characterId,
    spellId,
    sourceType,
    sourceId,
    sourceName,
    isPrepared,
    isKnown,
    isAlwaysAvailable,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterSpell &&
          other.localId == this.localId &&
          other.characterId == this.characterId &&
          other.spellId == this.spellId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.sourceName == this.sourceName &&
          other.isPrepared == this.isPrepared &&
          other.isKnown == this.isKnown &&
          other.isAlwaysAvailable == this.isAlwaysAvailable &&
          other.notes == this.notes);
}

class CharacterSpellsCompanion extends UpdateCompanion<CharacterSpell> {
  final Value<int> localId;
  final Value<String> characterId;
  final Value<int> spellId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> sourceName;
  final Value<bool> isPrepared;
  final Value<bool> isKnown;
  final Value<bool> isAlwaysAvailable;
  final Value<String> notes;
  const CharacterSpellsCompanion({
    this.localId = const Value.absent(),
    this.characterId = const Value.absent(),
    this.spellId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.isPrepared = const Value.absent(),
    this.isKnown = const Value.absent(),
    this.isAlwaysAvailable = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CharacterSpellsCompanion.insert({
    this.localId = const Value.absent(),
    required String characterId,
    required int spellId,
    required String sourceType,
    required String sourceId,
    required String sourceName,
    this.isPrepared = const Value.absent(),
    this.isKnown = const Value.absent(),
    this.isAlwaysAvailable = const Value.absent(),
    this.notes = const Value.absent(),
  }) : characterId = Value(characterId),
       spellId = Value(spellId),
       sourceType = Value(sourceType),
       sourceId = Value(sourceId),
       sourceName = Value(sourceName);
  static Insertable<CharacterSpell> custom({
    Expression<int>? localId,
    Expression<String>? characterId,
    Expression<int>? spellId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? sourceName,
    Expression<bool>? isPrepared,
    Expression<bool>? isKnown,
    Expression<bool>? isAlwaysAvailable,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (characterId != null) 'character_id': characterId,
      if (spellId != null) 'spell_id': spellId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceName != null) 'source_name': sourceName,
      if (isPrepared != null) 'is_prepared': isPrepared,
      if (isKnown != null) 'is_known': isKnown,
      if (isAlwaysAvailable != null) 'is_always_available': isAlwaysAvailable,
      if (notes != null) 'notes': notes,
    });
  }

  CharacterSpellsCompanion copyWith({
    Value<int>? localId,
    Value<String>? characterId,
    Value<int>? spellId,
    Value<String>? sourceType,
    Value<String>? sourceId,
    Value<String>? sourceName,
    Value<bool>? isPrepared,
    Value<bool>? isKnown,
    Value<bool>? isAlwaysAvailable,
    Value<String>? notes,
  }) {
    return CharacterSpellsCompanion(
      localId: localId ?? this.localId,
      characterId: characterId ?? this.characterId,
      spellId: spellId ?? this.spellId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      isPrepared: isPrepared ?? this.isPrepared,
      isKnown: isKnown ?? this.isKnown,
      isAlwaysAvailable: isAlwaysAvailable ?? this.isAlwaysAvailable,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (spellId.present) {
      map['spell_id'] = Variable<int>(spellId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (isPrepared.present) {
      map['is_prepared'] = Variable<bool>(isPrepared.value);
    }
    if (isKnown.present) {
      map['is_known'] = Variable<bool>(isKnown.value);
    }
    if (isAlwaysAvailable.present) {
      map['is_always_available'] = Variable<bool>(isAlwaysAvailable.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSpellsCompanion(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('spellId: $spellId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceName: $sourceName, ')
          ..write('isPrepared: $isPrepared, ')
          ..write('isKnown: $isKnown, ')
          ..write('isAlwaysAvailable: $isAlwaysAvailable, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $CharacterWeaponsTable extends CharacterWeapons
    with TableInfo<$CharacterWeaponsTable, CharacterWeapon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterWeaponsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id)',
    ),
  );
  static const VerificationMeta _weaponIdMeta = const VerificationMeta(
    'weaponId',
  );
  @override
  late final GeneratedColumn<String> weaponId = GeneratedColumn<String>(
    'weapon_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _magicBonusMeta = const VerificationMeta(
    'magicBonus',
  );
  @override
  late final GeneratedColumn<int> magicBonus = GeneratedColumn<int>(
    'magic_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chosenAbilityMeta = const VerificationMeta(
    'chosenAbility',
  );
  @override
  late final GeneratedColumn<String> chosenAbility = GeneratedColumn<String>(
    'chosen_ability',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _twoHandedMeta = const VerificationMeta(
    'twoHanded',
  );
  @override
  late final GeneratedColumn<bool> twoHanded = GeneratedColumn<bool>(
    'two_handed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("two_handed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _proficiencyOverrideMeta =
      const VerificationMeta('proficiencyOverride');
  @override
  late final GeneratedColumn<bool> proficiencyOverride = GeneratedColumn<bool>(
    'proficiency_override',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("proficiency_override" IN (0, 1))',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    characterId,
    weaponId,
    name,
    magicBonus,
    chosenAbility,
    twoHanded,
    proficiencyOverride,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_weapons';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterWeapon> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('weapon_id')) {
      context.handle(
        _weaponIdMeta,
        weaponId.isAcceptableOrUnknown(data['weapon_id']!, _weaponIdMeta),
      );
    } else if (isInserting) {
      context.missing(_weaponIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('magic_bonus')) {
      context.handle(
        _magicBonusMeta,
        magicBonus.isAcceptableOrUnknown(data['magic_bonus']!, _magicBonusMeta),
      );
    }
    if (data.containsKey('chosen_ability')) {
      context.handle(
        _chosenAbilityMeta,
        chosenAbility.isAcceptableOrUnknown(
          data['chosen_ability']!,
          _chosenAbilityMeta,
        ),
      );
    }
    if (data.containsKey('two_handed')) {
      context.handle(
        _twoHandedMeta,
        twoHanded.isAcceptableOrUnknown(data['two_handed']!, _twoHandedMeta),
      );
    }
    if (data.containsKey('proficiency_override')) {
      context.handle(
        _proficiencyOverrideMeta,
        proficiencyOverride.isAcceptableOrUnknown(
          data['proficiency_override']!,
          _proficiencyOverrideMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  CharacterWeapon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterWeapon(
      localId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}local_id'],
          )!,
      characterId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}character_id'],
          )!,
      weaponId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}weapon_id'],
          )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      magicBonus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}magic_bonus'],
          )!,
      chosenAbility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chosen_ability'],
      ),
      twoHanded:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}two_handed'],
          )!,
      proficiencyOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}proficiency_override'],
      ),
      notes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}notes'],
          )!,
    );
  }

  @override
  $CharacterWeaponsTable createAlias(String alias) {
    return $CharacterWeaponsTable(attachedDatabase, alias);
  }
}

class CharacterWeapon extends DataClass implements Insertable<CharacterWeapon> {
  final int localId;
  final String characterId;

  /// Id da arma no compêndio (`WeaponEntry.id`).
  final String weaponId;

  /// Apelido da arma. Nulo usa o nome do compêndio.
  ///
  /// Serve para a arma mágica com nome próprio continuar sendo mecanicamente
  /// uma espada longa.
  final String? name;

  /// Bônus mágico da arma: o `+1`, `+2` ou `+3`.
  ///
  /// Soma nas jogadas de ataque E nas de dano daquela arma, que é o que a
  /// descrição de arma mágica diz. Não mexe em ataque de magia nem em CD: isso
  /// só acontece se o item declarar, e quem cuida disso é o item mágico.
  final int magicBonus;

  /// Atributo escolhido nas armas com Acuidade, pelo nome do enum `Ability`.
  ///
  /// Nulo deixa o cálculo pegar o melhor entre Força e Destreza, que é a
  /// escolha certa em praticamente todo caso.
  final String? chosenAbility;

  /// Se está empunhada com as duas mãos.
  ///
  /// Só muda algo nas armas Versáteis, que trocam o dado (1d8 vira 1d10 na
  /// espada longa).
  final bool twoHanded;

  /// Proficiência marcada à mão.
  ///
  /// Nulo é o normal: a proficiência vem da classe. O campo existe porque
  /// raça, antecedente e talento também concedem proficiência com arma, e
  /// nenhum dos três está cadastrado de forma estruturada — sem o override, um
  /// elfo com arco longo apareceria sem proficiência e não haveria como
  /// corrigir.
  final bool? proficiencyOverride;
  final String notes;
  const CharacterWeapon({
    required this.localId,
    required this.characterId,
    required this.weaponId,
    this.name,
    required this.magicBonus,
    this.chosenAbility,
    required this.twoHanded,
    this.proficiencyOverride,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['character_id'] = Variable<String>(characterId);
    map['weapon_id'] = Variable<String>(weaponId);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['magic_bonus'] = Variable<int>(magicBonus);
    if (!nullToAbsent || chosenAbility != null) {
      map['chosen_ability'] = Variable<String>(chosenAbility);
    }
    map['two_handed'] = Variable<bool>(twoHanded);
    if (!nullToAbsent || proficiencyOverride != null) {
      map['proficiency_override'] = Variable<bool>(proficiencyOverride);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  CharacterWeaponsCompanion toCompanion(bool nullToAbsent) {
    return CharacterWeaponsCompanion(
      localId: Value(localId),
      characterId: Value(characterId),
      weaponId: Value(weaponId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      magicBonus: Value(magicBonus),
      chosenAbility:
          chosenAbility == null && nullToAbsent
              ? const Value.absent()
              : Value(chosenAbility),
      twoHanded: Value(twoHanded),
      proficiencyOverride:
          proficiencyOverride == null && nullToAbsent
              ? const Value.absent()
              : Value(proficiencyOverride),
      notes: Value(notes),
    );
  }

  factory CharacterWeapon.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterWeapon(
      localId: serializer.fromJson<int>(json['localId']),
      characterId: serializer.fromJson<String>(json['characterId']),
      weaponId: serializer.fromJson<String>(json['weaponId']),
      name: serializer.fromJson<String?>(json['name']),
      magicBonus: serializer.fromJson<int>(json['magicBonus']),
      chosenAbility: serializer.fromJson<String?>(json['chosenAbility']),
      twoHanded: serializer.fromJson<bool>(json['twoHanded']),
      proficiencyOverride: serializer.fromJson<bool?>(
        json['proficiencyOverride'],
      ),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'characterId': serializer.toJson<String>(characterId),
      'weaponId': serializer.toJson<String>(weaponId),
      'name': serializer.toJson<String?>(name),
      'magicBonus': serializer.toJson<int>(magicBonus),
      'chosenAbility': serializer.toJson<String?>(chosenAbility),
      'twoHanded': serializer.toJson<bool>(twoHanded),
      'proficiencyOverride': serializer.toJson<bool?>(proficiencyOverride),
      'notes': serializer.toJson<String>(notes),
    };
  }

  CharacterWeapon copyWith({
    int? localId,
    String? characterId,
    String? weaponId,
    Value<String?> name = const Value.absent(),
    int? magicBonus,
    Value<String?> chosenAbility = const Value.absent(),
    bool? twoHanded,
    Value<bool?> proficiencyOverride = const Value.absent(),
    String? notes,
  }) => CharacterWeapon(
    localId: localId ?? this.localId,
    characterId: characterId ?? this.characterId,
    weaponId: weaponId ?? this.weaponId,
    name: name.present ? name.value : this.name,
    magicBonus: magicBonus ?? this.magicBonus,
    chosenAbility:
        chosenAbility.present ? chosenAbility.value : this.chosenAbility,
    twoHanded: twoHanded ?? this.twoHanded,
    proficiencyOverride:
        proficiencyOverride.present
            ? proficiencyOverride.value
            : this.proficiencyOverride,
    notes: notes ?? this.notes,
  );
  CharacterWeapon copyWithCompanion(CharacterWeaponsCompanion data) {
    return CharacterWeapon(
      localId: data.localId.present ? data.localId.value : this.localId,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      weaponId: data.weaponId.present ? data.weaponId.value : this.weaponId,
      name: data.name.present ? data.name.value : this.name,
      magicBonus:
          data.magicBonus.present ? data.magicBonus.value : this.magicBonus,
      chosenAbility:
          data.chosenAbility.present
              ? data.chosenAbility.value
              : this.chosenAbility,
      twoHanded: data.twoHanded.present ? data.twoHanded.value : this.twoHanded,
      proficiencyOverride:
          data.proficiencyOverride.present
              ? data.proficiencyOverride.value
              : this.proficiencyOverride,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterWeapon(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('weaponId: $weaponId, ')
          ..write('name: $name, ')
          ..write('magicBonus: $magicBonus, ')
          ..write('chosenAbility: $chosenAbility, ')
          ..write('twoHanded: $twoHanded, ')
          ..write('proficiencyOverride: $proficiencyOverride, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    characterId,
    weaponId,
    name,
    magicBonus,
    chosenAbility,
    twoHanded,
    proficiencyOverride,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterWeapon &&
          other.localId == this.localId &&
          other.characterId == this.characterId &&
          other.weaponId == this.weaponId &&
          other.name == this.name &&
          other.magicBonus == this.magicBonus &&
          other.chosenAbility == this.chosenAbility &&
          other.twoHanded == this.twoHanded &&
          other.proficiencyOverride == this.proficiencyOverride &&
          other.notes == this.notes);
}

class CharacterWeaponsCompanion extends UpdateCompanion<CharacterWeapon> {
  final Value<int> localId;
  final Value<String> characterId;
  final Value<String> weaponId;
  final Value<String?> name;
  final Value<int> magicBonus;
  final Value<String?> chosenAbility;
  final Value<bool> twoHanded;
  final Value<bool?> proficiencyOverride;
  final Value<String> notes;
  const CharacterWeaponsCompanion({
    this.localId = const Value.absent(),
    this.characterId = const Value.absent(),
    this.weaponId = const Value.absent(),
    this.name = const Value.absent(),
    this.magicBonus = const Value.absent(),
    this.chosenAbility = const Value.absent(),
    this.twoHanded = const Value.absent(),
    this.proficiencyOverride = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CharacterWeaponsCompanion.insert({
    this.localId = const Value.absent(),
    required String characterId,
    required String weaponId,
    this.name = const Value.absent(),
    this.magicBonus = const Value.absent(),
    this.chosenAbility = const Value.absent(),
    this.twoHanded = const Value.absent(),
    this.proficiencyOverride = const Value.absent(),
    this.notes = const Value.absent(),
  }) : characterId = Value(characterId),
       weaponId = Value(weaponId);
  static Insertable<CharacterWeapon> custom({
    Expression<int>? localId,
    Expression<String>? characterId,
    Expression<String>? weaponId,
    Expression<String>? name,
    Expression<int>? magicBonus,
    Expression<String>? chosenAbility,
    Expression<bool>? twoHanded,
    Expression<bool>? proficiencyOverride,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (characterId != null) 'character_id': characterId,
      if (weaponId != null) 'weapon_id': weaponId,
      if (name != null) 'name': name,
      if (magicBonus != null) 'magic_bonus': magicBonus,
      if (chosenAbility != null) 'chosen_ability': chosenAbility,
      if (twoHanded != null) 'two_handed': twoHanded,
      if (proficiencyOverride != null)
        'proficiency_override': proficiencyOverride,
      if (notes != null) 'notes': notes,
    });
  }

  CharacterWeaponsCompanion copyWith({
    Value<int>? localId,
    Value<String>? characterId,
    Value<String>? weaponId,
    Value<String?>? name,
    Value<int>? magicBonus,
    Value<String?>? chosenAbility,
    Value<bool>? twoHanded,
    Value<bool?>? proficiencyOverride,
    Value<String>? notes,
  }) {
    return CharacterWeaponsCompanion(
      localId: localId ?? this.localId,
      characterId: characterId ?? this.characterId,
      weaponId: weaponId ?? this.weaponId,
      name: name ?? this.name,
      magicBonus: magicBonus ?? this.magicBonus,
      chosenAbility: chosenAbility ?? this.chosenAbility,
      twoHanded: twoHanded ?? this.twoHanded,
      proficiencyOverride: proficiencyOverride ?? this.proficiencyOverride,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (weaponId.present) {
      map['weapon_id'] = Variable<String>(weaponId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (magicBonus.present) {
      map['magic_bonus'] = Variable<int>(magicBonus.value);
    }
    if (chosenAbility.present) {
      map['chosen_ability'] = Variable<String>(chosenAbility.value);
    }
    if (twoHanded.present) {
      map['two_handed'] = Variable<bool>(twoHanded.value);
    }
    if (proficiencyOverride.present) {
      map['proficiency_override'] = Variable<bool>(proficiencyOverride.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterWeaponsCompanion(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('weaponId: $weaponId, ')
          ..write('name: $name, ')
          ..write('magicBonus: $magicBonus, ')
          ..write('chosenAbility: $chosenAbility, ')
          ..write('twoHanded: $twoHanded, ')
          ..write('proficiencyOverride: $proficiencyOverride, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $CharacterMagicItemsTable extends CharacterMagicItems
    with TableInfo<$CharacterMagicItemsTable, CharacterMagicItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterMagicItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _chargesMeta = const VerificationMeta(
    'charges',
  );
  @override
  late final GeneratedColumn<int> charges = GeneratedColumn<int>(
    'charges',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxChargesMeta = const VerificationMeta(
    'maxCharges',
  );
  @override
  late final GeneratedColumn<int> maxCharges = GeneratedColumn<int>(
    'max_charges',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rechargeRuleMeta = const VerificationMeta(
    'rechargeRule',
  );
  @override
  late final GeneratedColumn<String> rechargeRule = GeneratedColumn<String>(
    'recharge_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _castingAbilityMeta = const VerificationMeta(
    'castingAbility',
  );
  @override
  late final GeneratedColumn<String> castingAbility = GeneratedColumn<String>(
    'casting_ability',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saveDcMeta = const VerificationMeta('saveDc');
  @override
  late final GeneratedColumn<int> saveDc = GeneratedColumn<int>(
    'save_dc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attackBonusMeta = const VerificationMeta(
    'attackBonus',
  );
  @override
  late final GeneratedColumn<int> attackBonus = GeneratedColumn<int>(
    'attack_bonus',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weaponAttackBonusMeta = const VerificationMeta(
    'weaponAttackBonus',
  );
  @override
  late final GeneratedColumn<int> weaponAttackBonus = GeneratedColumn<int>(
    'weapon_attack_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weaponDamageBonusMeta = const VerificationMeta(
    'weaponDamageBonus',
  );
  @override
  late final GeneratedColumn<int> weaponDamageBonus = GeneratedColumn<int>(
    'weapon_damage_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _spellAttackBonusMeta = const VerificationMeta(
    'spellAttackBonus',
  );
  @override
  late final GeneratedColumn<int> spellAttackBonus = GeneratedColumn<int>(
    'spell_attack_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _spellSaveDcBonusMeta = const VerificationMeta(
    'spellSaveDcBonus',
  );
  @override
  late final GeneratedColumn<int> spellSaveDcBonus = GeneratedColumn<int>(
    'spell_save_dc_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    characterId,
    name,
    description,
    charges,
    maxCharges,
    rechargeRule,
    castingAbility,
    saveDc,
    attackBonus,
    weaponAttackBonus,
    weaponDamageBonus,
    spellAttackBonus,
    spellSaveDcBonus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_magic_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterMagicItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('charges')) {
      context.handle(
        _chargesMeta,
        charges.isAcceptableOrUnknown(data['charges']!, _chargesMeta),
      );
    }
    if (data.containsKey('max_charges')) {
      context.handle(
        _maxChargesMeta,
        maxCharges.isAcceptableOrUnknown(data['max_charges']!, _maxChargesMeta),
      );
    }
    if (data.containsKey('recharge_rule')) {
      context.handle(
        _rechargeRuleMeta,
        rechargeRule.isAcceptableOrUnknown(
          data['recharge_rule']!,
          _rechargeRuleMeta,
        ),
      );
    }
    if (data.containsKey('casting_ability')) {
      context.handle(
        _castingAbilityMeta,
        castingAbility.isAcceptableOrUnknown(
          data['casting_ability']!,
          _castingAbilityMeta,
        ),
      );
    }
    if (data.containsKey('save_dc')) {
      context.handle(
        _saveDcMeta,
        saveDc.isAcceptableOrUnknown(data['save_dc']!, _saveDcMeta),
      );
    }
    if (data.containsKey('attack_bonus')) {
      context.handle(
        _attackBonusMeta,
        attackBonus.isAcceptableOrUnknown(
          data['attack_bonus']!,
          _attackBonusMeta,
        ),
      );
    }
    if (data.containsKey('weapon_attack_bonus')) {
      context.handle(
        _weaponAttackBonusMeta,
        weaponAttackBonus.isAcceptableOrUnknown(
          data['weapon_attack_bonus']!,
          _weaponAttackBonusMeta,
        ),
      );
    }
    if (data.containsKey('weapon_damage_bonus')) {
      context.handle(
        _weaponDamageBonusMeta,
        weaponDamageBonus.isAcceptableOrUnknown(
          data['weapon_damage_bonus']!,
          _weaponDamageBonusMeta,
        ),
      );
    }
    if (data.containsKey('spell_attack_bonus')) {
      context.handle(
        _spellAttackBonusMeta,
        spellAttackBonus.isAcceptableOrUnknown(
          data['spell_attack_bonus']!,
          _spellAttackBonusMeta,
        ),
      );
    }
    if (data.containsKey('spell_save_dc_bonus')) {
      context.handle(
        _spellSaveDcBonusMeta,
        spellSaveDcBonus.isAcceptableOrUnknown(
          data['spell_save_dc_bonus']!,
          _spellSaveDcBonusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  CharacterMagicItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterMagicItem(
      localId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}local_id'],
          )!,
      characterId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}character_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      description:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}description'],
          )!,
      charges: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charges'],
      ),
      maxCharges: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_charges'],
      ),
      rechargeRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recharge_rule'],
      ),
      castingAbility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}casting_ability'],
      ),
      saveDc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}save_dc'],
      ),
      attackBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attack_bonus'],
      ),
      weaponAttackBonus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}weapon_attack_bonus'],
          )!,
      weaponDamageBonus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}weapon_damage_bonus'],
          )!,
      spellAttackBonus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}spell_attack_bonus'],
          )!,
      spellSaveDcBonus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}spell_save_dc_bonus'],
          )!,
    );
  }

  @override
  $CharacterMagicItemsTable createAlias(String alias) {
    return $CharacterMagicItemsTable(attachedDatabase, alias);
  }
}

class CharacterMagicItem extends DataClass
    implements Insertable<CharacterMagicItem> {
  final int localId;
  final String characterId;
  final String name;
  final String description;
  final int? charges;
  final int? maxCharges;
  final String? rechargeRule;
  final String? castingAbility;

  /// CD fixa do item, quando ele define a própria.
  ///
  /// Valor ABSOLUTO, não bônus: é o "CD 15" impresso na descrição de varinhas
  /// e cajados, que não depende dos atributos de quem usa. Para o item que
  /// SOMA à CD do conjurador existe [spellSaveDcBonus].
  final int? saveDc;

  /// Bônus de ataque fixo do item, quando ele define o próprio.
  ///
  /// Também absoluto, pelo mesmo motivo de [saveDc].
  final int? attackBonus;

  /// Soma nas jogadas de ataque com arma.
  final int weaponAttackBonus;

  /// Soma nas jogadas de dano com arma.
  final int weaponDamageBonus;

  /// Soma no bônus de ataque com magia.
  final int spellAttackBonus;

  /// Soma na CD de resistência das magias do personagem.
  final int spellSaveDcBonus;
  const CharacterMagicItem({
    required this.localId,
    required this.characterId,
    required this.name,
    required this.description,
    this.charges,
    this.maxCharges,
    this.rechargeRule,
    this.castingAbility,
    this.saveDc,
    this.attackBonus,
    required this.weaponAttackBonus,
    required this.weaponDamageBonus,
    required this.spellAttackBonus,
    required this.spellSaveDcBonus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['character_id'] = Variable<String>(characterId);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || charges != null) {
      map['charges'] = Variable<int>(charges);
    }
    if (!nullToAbsent || maxCharges != null) {
      map['max_charges'] = Variable<int>(maxCharges);
    }
    if (!nullToAbsent || rechargeRule != null) {
      map['recharge_rule'] = Variable<String>(rechargeRule);
    }
    if (!nullToAbsent || castingAbility != null) {
      map['casting_ability'] = Variable<String>(castingAbility);
    }
    if (!nullToAbsent || saveDc != null) {
      map['save_dc'] = Variable<int>(saveDc);
    }
    if (!nullToAbsent || attackBonus != null) {
      map['attack_bonus'] = Variable<int>(attackBonus);
    }
    map['weapon_attack_bonus'] = Variable<int>(weaponAttackBonus);
    map['weapon_damage_bonus'] = Variable<int>(weaponDamageBonus);
    map['spell_attack_bonus'] = Variable<int>(spellAttackBonus);
    map['spell_save_dc_bonus'] = Variable<int>(spellSaveDcBonus);
    return map;
  }

  CharacterMagicItemsCompanion toCompanion(bool nullToAbsent) {
    return CharacterMagicItemsCompanion(
      localId: Value(localId),
      characterId: Value(characterId),
      name: Value(name),
      description: Value(description),
      charges:
          charges == null && nullToAbsent
              ? const Value.absent()
              : Value(charges),
      maxCharges:
          maxCharges == null && nullToAbsent
              ? const Value.absent()
              : Value(maxCharges),
      rechargeRule:
          rechargeRule == null && nullToAbsent
              ? const Value.absent()
              : Value(rechargeRule),
      castingAbility:
          castingAbility == null && nullToAbsent
              ? const Value.absent()
              : Value(castingAbility),
      saveDc:
          saveDc == null && nullToAbsent ? const Value.absent() : Value(saveDc),
      attackBonus:
          attackBonus == null && nullToAbsent
              ? const Value.absent()
              : Value(attackBonus),
      weaponAttackBonus: Value(weaponAttackBonus),
      weaponDamageBonus: Value(weaponDamageBonus),
      spellAttackBonus: Value(spellAttackBonus),
      spellSaveDcBonus: Value(spellSaveDcBonus),
    );
  }

  factory CharacterMagicItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterMagicItem(
      localId: serializer.fromJson<int>(json['localId']),
      characterId: serializer.fromJson<String>(json['characterId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      charges: serializer.fromJson<int?>(json['charges']),
      maxCharges: serializer.fromJson<int?>(json['maxCharges']),
      rechargeRule: serializer.fromJson<String?>(json['rechargeRule']),
      castingAbility: serializer.fromJson<String?>(json['castingAbility']),
      saveDc: serializer.fromJson<int?>(json['saveDc']),
      attackBonus: serializer.fromJson<int?>(json['attackBonus']),
      weaponAttackBonus: serializer.fromJson<int>(json['weaponAttackBonus']),
      weaponDamageBonus: serializer.fromJson<int>(json['weaponDamageBonus']),
      spellAttackBonus: serializer.fromJson<int>(json['spellAttackBonus']),
      spellSaveDcBonus: serializer.fromJson<int>(json['spellSaveDcBonus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'characterId': serializer.toJson<String>(characterId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'charges': serializer.toJson<int?>(charges),
      'maxCharges': serializer.toJson<int?>(maxCharges),
      'rechargeRule': serializer.toJson<String?>(rechargeRule),
      'castingAbility': serializer.toJson<String?>(castingAbility),
      'saveDc': serializer.toJson<int?>(saveDc),
      'attackBonus': serializer.toJson<int?>(attackBonus),
      'weaponAttackBonus': serializer.toJson<int>(weaponAttackBonus),
      'weaponDamageBonus': serializer.toJson<int>(weaponDamageBonus),
      'spellAttackBonus': serializer.toJson<int>(spellAttackBonus),
      'spellSaveDcBonus': serializer.toJson<int>(spellSaveDcBonus),
    };
  }

  CharacterMagicItem copyWith({
    int? localId,
    String? characterId,
    String? name,
    String? description,
    Value<int?> charges = const Value.absent(),
    Value<int?> maxCharges = const Value.absent(),
    Value<String?> rechargeRule = const Value.absent(),
    Value<String?> castingAbility = const Value.absent(),
    Value<int?> saveDc = const Value.absent(),
    Value<int?> attackBonus = const Value.absent(),
    int? weaponAttackBonus,
    int? weaponDamageBonus,
    int? spellAttackBonus,
    int? spellSaveDcBonus,
  }) => CharacterMagicItem(
    localId: localId ?? this.localId,
    characterId: characterId ?? this.characterId,
    name: name ?? this.name,
    description: description ?? this.description,
    charges: charges.present ? charges.value : this.charges,
    maxCharges: maxCharges.present ? maxCharges.value : this.maxCharges,
    rechargeRule: rechargeRule.present ? rechargeRule.value : this.rechargeRule,
    castingAbility:
        castingAbility.present ? castingAbility.value : this.castingAbility,
    saveDc: saveDc.present ? saveDc.value : this.saveDc,
    attackBonus: attackBonus.present ? attackBonus.value : this.attackBonus,
    weaponAttackBonus: weaponAttackBonus ?? this.weaponAttackBonus,
    weaponDamageBonus: weaponDamageBonus ?? this.weaponDamageBonus,
    spellAttackBonus: spellAttackBonus ?? this.spellAttackBonus,
    spellSaveDcBonus: spellSaveDcBonus ?? this.spellSaveDcBonus,
  );
  CharacterMagicItem copyWithCompanion(CharacterMagicItemsCompanion data) {
    return CharacterMagicItem(
      localId: data.localId.present ? data.localId.value : this.localId,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      charges: data.charges.present ? data.charges.value : this.charges,
      maxCharges:
          data.maxCharges.present ? data.maxCharges.value : this.maxCharges,
      rechargeRule:
          data.rechargeRule.present
              ? data.rechargeRule.value
              : this.rechargeRule,
      castingAbility:
          data.castingAbility.present
              ? data.castingAbility.value
              : this.castingAbility,
      saveDc: data.saveDc.present ? data.saveDc.value : this.saveDc,
      attackBonus:
          data.attackBonus.present ? data.attackBonus.value : this.attackBonus,
      weaponAttackBonus:
          data.weaponAttackBonus.present
              ? data.weaponAttackBonus.value
              : this.weaponAttackBonus,
      weaponDamageBonus:
          data.weaponDamageBonus.present
              ? data.weaponDamageBonus.value
              : this.weaponDamageBonus,
      spellAttackBonus:
          data.spellAttackBonus.present
              ? data.spellAttackBonus.value
              : this.spellAttackBonus,
      spellSaveDcBonus:
          data.spellSaveDcBonus.present
              ? data.spellSaveDcBonus.value
              : this.spellSaveDcBonus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterMagicItem(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('charges: $charges, ')
          ..write('maxCharges: $maxCharges, ')
          ..write('rechargeRule: $rechargeRule, ')
          ..write('castingAbility: $castingAbility, ')
          ..write('saveDc: $saveDc, ')
          ..write('attackBonus: $attackBonus, ')
          ..write('weaponAttackBonus: $weaponAttackBonus, ')
          ..write('weaponDamageBonus: $weaponDamageBonus, ')
          ..write('spellAttackBonus: $spellAttackBonus, ')
          ..write('spellSaveDcBonus: $spellSaveDcBonus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    characterId,
    name,
    description,
    charges,
    maxCharges,
    rechargeRule,
    castingAbility,
    saveDc,
    attackBonus,
    weaponAttackBonus,
    weaponDamageBonus,
    spellAttackBonus,
    spellSaveDcBonus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterMagicItem &&
          other.localId == this.localId &&
          other.characterId == this.characterId &&
          other.name == this.name &&
          other.description == this.description &&
          other.charges == this.charges &&
          other.maxCharges == this.maxCharges &&
          other.rechargeRule == this.rechargeRule &&
          other.castingAbility == this.castingAbility &&
          other.saveDc == this.saveDc &&
          other.attackBonus == this.attackBonus &&
          other.weaponAttackBonus == this.weaponAttackBonus &&
          other.weaponDamageBonus == this.weaponDamageBonus &&
          other.spellAttackBonus == this.spellAttackBonus &&
          other.spellSaveDcBonus == this.spellSaveDcBonus);
}

class CharacterMagicItemsCompanion extends UpdateCompanion<CharacterMagicItem> {
  final Value<int> localId;
  final Value<String> characterId;
  final Value<String> name;
  final Value<String> description;
  final Value<int?> charges;
  final Value<int?> maxCharges;
  final Value<String?> rechargeRule;
  final Value<String?> castingAbility;
  final Value<int?> saveDc;
  final Value<int?> attackBonus;
  final Value<int> weaponAttackBonus;
  final Value<int> weaponDamageBonus;
  final Value<int> spellAttackBonus;
  final Value<int> spellSaveDcBonus;
  const CharacterMagicItemsCompanion({
    this.localId = const Value.absent(),
    this.characterId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.charges = const Value.absent(),
    this.maxCharges = const Value.absent(),
    this.rechargeRule = const Value.absent(),
    this.castingAbility = const Value.absent(),
    this.saveDc = const Value.absent(),
    this.attackBonus = const Value.absent(),
    this.weaponAttackBonus = const Value.absent(),
    this.weaponDamageBonus = const Value.absent(),
    this.spellAttackBonus = const Value.absent(),
    this.spellSaveDcBonus = const Value.absent(),
  });
  CharacterMagicItemsCompanion.insert({
    this.localId = const Value.absent(),
    required String characterId,
    required String name,
    this.description = const Value.absent(),
    this.charges = const Value.absent(),
    this.maxCharges = const Value.absent(),
    this.rechargeRule = const Value.absent(),
    this.castingAbility = const Value.absent(),
    this.saveDc = const Value.absent(),
    this.attackBonus = const Value.absent(),
    this.weaponAttackBonus = const Value.absent(),
    this.weaponDamageBonus = const Value.absent(),
    this.spellAttackBonus = const Value.absent(),
    this.spellSaveDcBonus = const Value.absent(),
  }) : characterId = Value(characterId),
       name = Value(name);
  static Insertable<CharacterMagicItem> custom({
    Expression<int>? localId,
    Expression<String>? characterId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? charges,
    Expression<int>? maxCharges,
    Expression<String>? rechargeRule,
    Expression<String>? castingAbility,
    Expression<int>? saveDc,
    Expression<int>? attackBonus,
    Expression<int>? weaponAttackBonus,
    Expression<int>? weaponDamageBonus,
    Expression<int>? spellAttackBonus,
    Expression<int>? spellSaveDcBonus,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (characterId != null) 'character_id': characterId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (charges != null) 'charges': charges,
      if (maxCharges != null) 'max_charges': maxCharges,
      if (rechargeRule != null) 'recharge_rule': rechargeRule,
      if (castingAbility != null) 'casting_ability': castingAbility,
      if (saveDc != null) 'save_dc': saveDc,
      if (attackBonus != null) 'attack_bonus': attackBonus,
      if (weaponAttackBonus != null) 'weapon_attack_bonus': weaponAttackBonus,
      if (weaponDamageBonus != null) 'weapon_damage_bonus': weaponDamageBonus,
      if (spellAttackBonus != null) 'spell_attack_bonus': spellAttackBonus,
      if (spellSaveDcBonus != null) 'spell_save_dc_bonus': spellSaveDcBonus,
    });
  }

  CharacterMagicItemsCompanion copyWith({
    Value<int>? localId,
    Value<String>? characterId,
    Value<String>? name,
    Value<String>? description,
    Value<int?>? charges,
    Value<int?>? maxCharges,
    Value<String?>? rechargeRule,
    Value<String?>? castingAbility,
    Value<int?>? saveDc,
    Value<int?>? attackBonus,
    Value<int>? weaponAttackBonus,
    Value<int>? weaponDamageBonus,
    Value<int>? spellAttackBonus,
    Value<int>? spellSaveDcBonus,
  }) {
    return CharacterMagicItemsCompanion(
      localId: localId ?? this.localId,
      characterId: characterId ?? this.characterId,
      name: name ?? this.name,
      description: description ?? this.description,
      charges: charges ?? this.charges,
      maxCharges: maxCharges ?? this.maxCharges,
      rechargeRule: rechargeRule ?? this.rechargeRule,
      castingAbility: castingAbility ?? this.castingAbility,
      saveDc: saveDc ?? this.saveDc,
      attackBonus: attackBonus ?? this.attackBonus,
      weaponAttackBonus: weaponAttackBonus ?? this.weaponAttackBonus,
      weaponDamageBonus: weaponDamageBonus ?? this.weaponDamageBonus,
      spellAttackBonus: spellAttackBonus ?? this.spellAttackBonus,
      spellSaveDcBonus: spellSaveDcBonus ?? this.spellSaveDcBonus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (charges.present) {
      map['charges'] = Variable<int>(charges.value);
    }
    if (maxCharges.present) {
      map['max_charges'] = Variable<int>(maxCharges.value);
    }
    if (rechargeRule.present) {
      map['recharge_rule'] = Variable<String>(rechargeRule.value);
    }
    if (castingAbility.present) {
      map['casting_ability'] = Variable<String>(castingAbility.value);
    }
    if (saveDc.present) {
      map['save_dc'] = Variable<int>(saveDc.value);
    }
    if (attackBonus.present) {
      map['attack_bonus'] = Variable<int>(attackBonus.value);
    }
    if (weaponAttackBonus.present) {
      map['weapon_attack_bonus'] = Variable<int>(weaponAttackBonus.value);
    }
    if (weaponDamageBonus.present) {
      map['weapon_damage_bonus'] = Variable<int>(weaponDamageBonus.value);
    }
    if (spellAttackBonus.present) {
      map['spell_attack_bonus'] = Variable<int>(spellAttackBonus.value);
    }
    if (spellSaveDcBonus.present) {
      map['spell_save_dc_bonus'] = Variable<int>(spellSaveDcBonus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterMagicItemsCompanion(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('charges: $charges, ')
          ..write('maxCharges: $maxCharges, ')
          ..write('rechargeRule: $rechargeRule, ')
          ..write('castingAbility: $castingAbility, ')
          ..write('saveDc: $saveDc, ')
          ..write('attackBonus: $attackBonus, ')
          ..write('weaponAttackBonus: $weaponAttackBonus, ')
          ..write('weaponDamageBonus: $weaponDamageBonus, ')
          ..write('spellAttackBonus: $spellAttackBonus, ')
          ..write('spellSaveDcBonus: $spellSaveDcBonus')
          ..write(')'))
        .toString();
  }
}

class $CharacterMagicItemSpellsTable extends CharacterMagicItemSpells
    with TableInfo<$CharacterMagicItemSpellsTable, CharacterMagicItemSpell> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterMagicItemSpellsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _magicItemIdMeta = const VerificationMeta(
    'magicItemId',
  );
  @override
  late final GeneratedColumn<int> magicItemId = GeneratedColumn<int>(
    'magic_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES character_magic_items (local_id)',
    ),
  );
  static const VerificationMeta _spellIdMeta = const VerificationMeta(
    'spellId',
  );
  @override
  late final GeneratedColumn<int> spellId = GeneratedColumn<int>(
    'spell_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usesChargesMeta = const VerificationMeta(
    'usesCharges',
  );
  @override
  late final GeneratedColumn<bool> usesCharges = GeneratedColumn<bool>(
    'uses_charges',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uses_charges" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _chargeCostMeta = const VerificationMeta(
    'chargeCost',
  );
  @override
  late final GeneratedColumn<int> chargeCost = GeneratedColumn<int>(
    'charge_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isAtWillMeta = const VerificationMeta(
    'isAtWill',
  );
  @override
  late final GeneratedColumn<bool> isAtWill = GeneratedColumn<bool>(
    'is_at_will',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_at_will" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAlwaysAvailableMeta = const VerificationMeta(
    'isAlwaysAvailable',
  );
  @override
  late final GeneratedColumn<bool> isAlwaysAvailable = GeneratedColumn<bool>(
    'is_always_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_always_available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    magicItemId,
    spellId,
    usesCharges,
    chargeCost,
    isAtWill,
    isAlwaysAvailable,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_magic_item_spells';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterMagicItemSpell> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('magic_item_id')) {
      context.handle(
        _magicItemIdMeta,
        magicItemId.isAcceptableOrUnknown(
          data['magic_item_id']!,
          _magicItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_magicItemIdMeta);
    }
    if (data.containsKey('spell_id')) {
      context.handle(
        _spellIdMeta,
        spellId.isAcceptableOrUnknown(data['spell_id']!, _spellIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spellIdMeta);
    }
    if (data.containsKey('uses_charges')) {
      context.handle(
        _usesChargesMeta,
        usesCharges.isAcceptableOrUnknown(
          data['uses_charges']!,
          _usesChargesMeta,
        ),
      );
    }
    if (data.containsKey('charge_cost')) {
      context.handle(
        _chargeCostMeta,
        chargeCost.isAcceptableOrUnknown(data['charge_cost']!, _chargeCostMeta),
      );
    }
    if (data.containsKey('is_at_will')) {
      context.handle(
        _isAtWillMeta,
        isAtWill.isAcceptableOrUnknown(data['is_at_will']!, _isAtWillMeta),
      );
    }
    if (data.containsKey('is_always_available')) {
      context.handle(
        _isAlwaysAvailableMeta,
        isAlwaysAvailable.isAcceptableOrUnknown(
          data['is_always_available']!,
          _isAlwaysAvailableMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  CharacterMagicItemSpell map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterMagicItemSpell(
      localId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}local_id'],
          )!,
      magicItemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}magic_item_id'],
          )!,
      spellId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}spell_id'],
          )!,
      usesCharges:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}uses_charges'],
          )!,
      chargeCost:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}charge_cost'],
          )!,
      isAtWill:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_at_will'],
          )!,
      isAlwaysAvailable:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_always_available'],
          )!,
    );
  }

  @override
  $CharacterMagicItemSpellsTable createAlias(String alias) {
    return $CharacterMagicItemSpellsTable(attachedDatabase, alias);
  }
}

class CharacterMagicItemSpell extends DataClass
    implements Insertable<CharacterMagicItemSpell> {
  final int localId;
  final int magicItemId;
  final int spellId;
  final bool usesCharges;
  final int chargeCost;
  final bool isAtWill;
  final bool isAlwaysAvailable;
  const CharacterMagicItemSpell({
    required this.localId,
    required this.magicItemId,
    required this.spellId,
    required this.usesCharges,
    required this.chargeCost,
    required this.isAtWill,
    required this.isAlwaysAvailable,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['magic_item_id'] = Variable<int>(magicItemId);
    map['spell_id'] = Variable<int>(spellId);
    map['uses_charges'] = Variable<bool>(usesCharges);
    map['charge_cost'] = Variable<int>(chargeCost);
    map['is_at_will'] = Variable<bool>(isAtWill);
    map['is_always_available'] = Variable<bool>(isAlwaysAvailable);
    return map;
  }

  CharacterMagicItemSpellsCompanion toCompanion(bool nullToAbsent) {
    return CharacterMagicItemSpellsCompanion(
      localId: Value(localId),
      magicItemId: Value(magicItemId),
      spellId: Value(spellId),
      usesCharges: Value(usesCharges),
      chargeCost: Value(chargeCost),
      isAtWill: Value(isAtWill),
      isAlwaysAvailable: Value(isAlwaysAvailable),
    );
  }

  factory CharacterMagicItemSpell.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterMagicItemSpell(
      localId: serializer.fromJson<int>(json['localId']),
      magicItemId: serializer.fromJson<int>(json['magicItemId']),
      spellId: serializer.fromJson<int>(json['spellId']),
      usesCharges: serializer.fromJson<bool>(json['usesCharges']),
      chargeCost: serializer.fromJson<int>(json['chargeCost']),
      isAtWill: serializer.fromJson<bool>(json['isAtWill']),
      isAlwaysAvailable: serializer.fromJson<bool>(json['isAlwaysAvailable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'magicItemId': serializer.toJson<int>(magicItemId),
      'spellId': serializer.toJson<int>(spellId),
      'usesCharges': serializer.toJson<bool>(usesCharges),
      'chargeCost': serializer.toJson<int>(chargeCost),
      'isAtWill': serializer.toJson<bool>(isAtWill),
      'isAlwaysAvailable': serializer.toJson<bool>(isAlwaysAvailable),
    };
  }

  CharacterMagicItemSpell copyWith({
    int? localId,
    int? magicItemId,
    int? spellId,
    bool? usesCharges,
    int? chargeCost,
    bool? isAtWill,
    bool? isAlwaysAvailable,
  }) => CharacterMagicItemSpell(
    localId: localId ?? this.localId,
    magicItemId: magicItemId ?? this.magicItemId,
    spellId: spellId ?? this.spellId,
    usesCharges: usesCharges ?? this.usesCharges,
    chargeCost: chargeCost ?? this.chargeCost,
    isAtWill: isAtWill ?? this.isAtWill,
    isAlwaysAvailable: isAlwaysAvailable ?? this.isAlwaysAvailable,
  );
  CharacterMagicItemSpell copyWithCompanion(
    CharacterMagicItemSpellsCompanion data,
  ) {
    return CharacterMagicItemSpell(
      localId: data.localId.present ? data.localId.value : this.localId,
      magicItemId:
          data.magicItemId.present ? data.magicItemId.value : this.magicItemId,
      spellId: data.spellId.present ? data.spellId.value : this.spellId,
      usesCharges:
          data.usesCharges.present ? data.usesCharges.value : this.usesCharges,
      chargeCost:
          data.chargeCost.present ? data.chargeCost.value : this.chargeCost,
      isAtWill: data.isAtWill.present ? data.isAtWill.value : this.isAtWill,
      isAlwaysAvailable:
          data.isAlwaysAvailable.present
              ? data.isAlwaysAvailable.value
              : this.isAlwaysAvailable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterMagicItemSpell(')
          ..write('localId: $localId, ')
          ..write('magicItemId: $magicItemId, ')
          ..write('spellId: $spellId, ')
          ..write('usesCharges: $usesCharges, ')
          ..write('chargeCost: $chargeCost, ')
          ..write('isAtWill: $isAtWill, ')
          ..write('isAlwaysAvailable: $isAlwaysAvailable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    magicItemId,
    spellId,
    usesCharges,
    chargeCost,
    isAtWill,
    isAlwaysAvailable,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterMagicItemSpell &&
          other.localId == this.localId &&
          other.magicItemId == this.magicItemId &&
          other.spellId == this.spellId &&
          other.usesCharges == this.usesCharges &&
          other.chargeCost == this.chargeCost &&
          other.isAtWill == this.isAtWill &&
          other.isAlwaysAvailable == this.isAlwaysAvailable);
}

class CharacterMagicItemSpellsCompanion
    extends UpdateCompanion<CharacterMagicItemSpell> {
  final Value<int> localId;
  final Value<int> magicItemId;
  final Value<int> spellId;
  final Value<bool> usesCharges;
  final Value<int> chargeCost;
  final Value<bool> isAtWill;
  final Value<bool> isAlwaysAvailable;
  const CharacterMagicItemSpellsCompanion({
    this.localId = const Value.absent(),
    this.magicItemId = const Value.absent(),
    this.spellId = const Value.absent(),
    this.usesCharges = const Value.absent(),
    this.chargeCost = const Value.absent(),
    this.isAtWill = const Value.absent(),
    this.isAlwaysAvailable = const Value.absent(),
  });
  CharacterMagicItemSpellsCompanion.insert({
    this.localId = const Value.absent(),
    required int magicItemId,
    required int spellId,
    this.usesCharges = const Value.absent(),
    this.chargeCost = const Value.absent(),
    this.isAtWill = const Value.absent(),
    this.isAlwaysAvailable = const Value.absent(),
  }) : magicItemId = Value(magicItemId),
       spellId = Value(spellId);
  static Insertable<CharacterMagicItemSpell> custom({
    Expression<int>? localId,
    Expression<int>? magicItemId,
    Expression<int>? spellId,
    Expression<bool>? usesCharges,
    Expression<int>? chargeCost,
    Expression<bool>? isAtWill,
    Expression<bool>? isAlwaysAvailable,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (magicItemId != null) 'magic_item_id': magicItemId,
      if (spellId != null) 'spell_id': spellId,
      if (usesCharges != null) 'uses_charges': usesCharges,
      if (chargeCost != null) 'charge_cost': chargeCost,
      if (isAtWill != null) 'is_at_will': isAtWill,
      if (isAlwaysAvailable != null) 'is_always_available': isAlwaysAvailable,
    });
  }

  CharacterMagicItemSpellsCompanion copyWith({
    Value<int>? localId,
    Value<int>? magicItemId,
    Value<int>? spellId,
    Value<bool>? usesCharges,
    Value<int>? chargeCost,
    Value<bool>? isAtWill,
    Value<bool>? isAlwaysAvailable,
  }) {
    return CharacterMagicItemSpellsCompanion(
      localId: localId ?? this.localId,
      magicItemId: magicItemId ?? this.magicItemId,
      spellId: spellId ?? this.spellId,
      usesCharges: usesCharges ?? this.usesCharges,
      chargeCost: chargeCost ?? this.chargeCost,
      isAtWill: isAtWill ?? this.isAtWill,
      isAlwaysAvailable: isAlwaysAvailable ?? this.isAlwaysAvailable,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (magicItemId.present) {
      map['magic_item_id'] = Variable<int>(magicItemId.value);
    }
    if (spellId.present) {
      map['spell_id'] = Variable<int>(spellId.value);
    }
    if (usesCharges.present) {
      map['uses_charges'] = Variable<bool>(usesCharges.value);
    }
    if (chargeCost.present) {
      map['charge_cost'] = Variable<int>(chargeCost.value);
    }
    if (isAtWill.present) {
      map['is_at_will'] = Variable<bool>(isAtWill.value);
    }
    if (isAlwaysAvailable.present) {
      map['is_always_available'] = Variable<bool>(isAlwaysAvailable.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterMagicItemSpellsCompanion(')
          ..write('localId: $localId, ')
          ..write('magicItemId: $magicItemId, ')
          ..write('spellId: $spellId, ')
          ..write('usesCharges: $usesCharges, ')
          ..write('chargeCost: $chargeCost, ')
          ..write('isAtWill: $isAtWill, ')
          ..write('isAlwaysAvailable: $isAlwaysAvailable')
          ..write(')'))
        .toString();
  }
}

class $CharacterSpellSlotsUsageTable extends CharacterSpellSlotsUsage
    with
        TableInfo<
          $CharacterSpellSlotsUsageTable,
          CharacterSpellSlotsUsageData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterSpellSlotsUsageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id)',
    ),
  );
  static const VerificationMeta _slotLevelMeta = const VerificationMeta(
    'slotLevel',
  );
  @override
  late final GeneratedColumn<int> slotLevel = GeneratedColumn<int>(
    'slot_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usedMeta = const VerificationMeta('used');
  @override
  late final GeneratedColumn<int> used = GeneratedColumn<int>(
    'used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [localId, characterId, slotLevel, used];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_spell_slots_usage';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterSpellSlotsUsageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('slot_level')) {
      context.handle(
        _slotLevelMeta,
        slotLevel.isAcceptableOrUnknown(data['slot_level']!, _slotLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_slotLevelMeta);
    }
    if (data.containsKey('used')) {
      context.handle(
        _usedMeta,
        used.isAcceptableOrUnknown(data['used']!, _usedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  CharacterSpellSlotsUsageData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterSpellSlotsUsageData(
      localId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}local_id'],
          )!,
      characterId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}character_id'],
          )!,
      slotLevel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}slot_level'],
          )!,
      used:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}used'],
          )!,
    );
  }

  @override
  $CharacterSpellSlotsUsageTable createAlias(String alias) {
    return $CharacterSpellSlotsUsageTable(attachedDatabase, alias);
  }
}

class CharacterSpellSlotsUsageData extends DataClass
    implements Insertable<CharacterSpellSlotsUsageData> {
  final int localId;
  final String characterId;
  final int slotLevel;
  final int used;
  const CharacterSpellSlotsUsageData({
    required this.localId,
    required this.characterId,
    required this.slotLevel,
    required this.used,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['character_id'] = Variable<String>(characterId);
    map['slot_level'] = Variable<int>(slotLevel);
    map['used'] = Variable<int>(used);
    return map;
  }

  CharacterSpellSlotsUsageCompanion toCompanion(bool nullToAbsent) {
    return CharacterSpellSlotsUsageCompanion(
      localId: Value(localId),
      characterId: Value(characterId),
      slotLevel: Value(slotLevel),
      used: Value(used),
    );
  }

  factory CharacterSpellSlotsUsageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterSpellSlotsUsageData(
      localId: serializer.fromJson<int>(json['localId']),
      characterId: serializer.fromJson<String>(json['characterId']),
      slotLevel: serializer.fromJson<int>(json['slotLevel']),
      used: serializer.fromJson<int>(json['used']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'characterId': serializer.toJson<String>(characterId),
      'slotLevel': serializer.toJson<int>(slotLevel),
      'used': serializer.toJson<int>(used),
    };
  }

  CharacterSpellSlotsUsageData copyWith({
    int? localId,
    String? characterId,
    int? slotLevel,
    int? used,
  }) => CharacterSpellSlotsUsageData(
    localId: localId ?? this.localId,
    characterId: characterId ?? this.characterId,
    slotLevel: slotLevel ?? this.slotLevel,
    used: used ?? this.used,
  );
  CharacterSpellSlotsUsageData copyWithCompanion(
    CharacterSpellSlotsUsageCompanion data,
  ) {
    return CharacterSpellSlotsUsageData(
      localId: data.localId.present ? data.localId.value : this.localId,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      slotLevel: data.slotLevel.present ? data.slotLevel.value : this.slotLevel,
      used: data.used.present ? data.used.value : this.used,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSpellSlotsUsageData(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('slotLevel: $slotLevel, ')
          ..write('used: $used')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localId, characterId, slotLevel, used);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterSpellSlotsUsageData &&
          other.localId == this.localId &&
          other.characterId == this.characterId &&
          other.slotLevel == this.slotLevel &&
          other.used == this.used);
}

class CharacterSpellSlotsUsageCompanion
    extends UpdateCompanion<CharacterSpellSlotsUsageData> {
  final Value<int> localId;
  final Value<String> characterId;
  final Value<int> slotLevel;
  final Value<int> used;
  const CharacterSpellSlotsUsageCompanion({
    this.localId = const Value.absent(),
    this.characterId = const Value.absent(),
    this.slotLevel = const Value.absent(),
    this.used = const Value.absent(),
  });
  CharacterSpellSlotsUsageCompanion.insert({
    this.localId = const Value.absent(),
    required String characterId,
    required int slotLevel,
    this.used = const Value.absent(),
  }) : characterId = Value(characterId),
       slotLevel = Value(slotLevel);
  static Insertable<CharacterSpellSlotsUsageData> custom({
    Expression<int>? localId,
    Expression<String>? characterId,
    Expression<int>? slotLevel,
    Expression<int>? used,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (characterId != null) 'character_id': characterId,
      if (slotLevel != null) 'slot_level': slotLevel,
      if (used != null) 'used': used,
    });
  }

  CharacterSpellSlotsUsageCompanion copyWith({
    Value<int>? localId,
    Value<String>? characterId,
    Value<int>? slotLevel,
    Value<int>? used,
  }) {
    return CharacterSpellSlotsUsageCompanion(
      localId: localId ?? this.localId,
      characterId: characterId ?? this.characterId,
      slotLevel: slotLevel ?? this.slotLevel,
      used: used ?? this.used,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (slotLevel.present) {
      map['slot_level'] = Variable<int>(slotLevel.value);
    }
    if (used.present) {
      map['used'] = Variable<int>(used.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSpellSlotsUsageCompanion(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('slotLevel: $slotLevel, ')
          ..write('used: $used')
          ..write(')'))
        .toString();
  }
}

class $CharacterFeatsTable extends CharacterFeats
    with TableInfo<$CharacterFeatsTable, CharacterFeat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterFeatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id)',
    ),
  );
  static const VerificationMeta _featIdMeta = const VerificationMeta('featId');
  @override
  late final GeneratedColumn<String> featId = GeneratedColumn<String>(
    'feat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chosenSkillsMeta = const VerificationMeta(
    'chosenSkills',
  );
  @override
  late final GeneratedColumn<String> chosenSkills = GeneratedColumn<String>(
    'chosen_skills',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _grantedSkillsMeta = const VerificationMeta(
    'grantedSkills',
  );
  @override
  late final GeneratedColumn<String> grantedSkills = GeneratedColumn<String>(
    'granted_skills',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _chosenAbilityMeta = const VerificationMeta(
    'chosenAbility',
  );
  @override
  late final GeneratedColumn<String> chosenAbility = GeneratedColumn<String>(
    'chosen_ability',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appliedAbilityIncreasesMeta =
      const VerificationMeta('appliedAbilityIncreases');
  @override
  late final GeneratedColumn<String> appliedAbilityIncreases =
      GeneratedColumn<String>(
        'applied_ability_increases',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    characterId,
    featId,
    classId,
    level,
    chosenSkills,
    grantedSkills,
    chosenAbility,
    appliedAbilityIncreases,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_feats';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterFeat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('feat_id')) {
      context.handle(
        _featIdMeta,
        featId.isAcceptableOrUnknown(data['feat_id']!, _featIdMeta),
      );
    } else if (isInserting) {
      context.missing(_featIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('chosen_skills')) {
      context.handle(
        _chosenSkillsMeta,
        chosenSkills.isAcceptableOrUnknown(
          data['chosen_skills']!,
          _chosenSkillsMeta,
        ),
      );
    }
    if (data.containsKey('granted_skills')) {
      context.handle(
        _grantedSkillsMeta,
        grantedSkills.isAcceptableOrUnknown(
          data['granted_skills']!,
          _grantedSkillsMeta,
        ),
      );
    }
    if (data.containsKey('chosen_ability')) {
      context.handle(
        _chosenAbilityMeta,
        chosenAbility.isAcceptableOrUnknown(
          data['chosen_ability']!,
          _chosenAbilityMeta,
        ),
      );
    }
    if (data.containsKey('applied_ability_increases')) {
      context.handle(
        _appliedAbilityIncreasesMeta,
        appliedAbilityIncreases.isAcceptableOrUnknown(
          data['applied_ability_increases']!,
          _appliedAbilityIncreasesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  CharacterFeat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterFeat(
      localId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}local_id'],
          )!,
      characterId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}character_id'],
          )!,
      featId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}feat_id'],
          )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      ),
      chosenSkills:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chosen_skills'],
          )!,
      grantedSkills:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}granted_skills'],
          )!,
      chosenAbility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chosen_ability'],
      ),
      appliedAbilityIncreases:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}applied_ability_increases'],
          )!,
    );
  }

  @override
  $CharacterFeatsTable createAlias(String alias) {
    return $CharacterFeatsTable(attachedDatabase, alias);
  }
}

class CharacterFeat extends DataClass implements Insertable<CharacterFeat> {
  final int localId;
  final String characterId;
  final String featId;

  /// Classe e nível em que o talento foi pego, para a ficha saber qual escolha
  /// já foi gasta.
  final String? classId;
  final int? level;

  /// Perícias escolhidas pelo jogador dentro das opções do talento, como CSV
  /// de ids de perícia.
  final String chosenSkills;

  /// Perícias que este talento efetivamente concedeu, como CSV de ids.
  final String grantedSkills;

  /// Atributo que o jogador escolheu, quando o talento deixa escolher.
  ///
  /// Nome em inglês, igual ao do enum `Ability`.
  final String? chosenAbility;

  /// Quanto este talento somou em cada atributo, como CSV `atributo:valor`.
  ///
  /// Guardado pelo mesmo motivo de [grantedSkills]: sem saber o que entrou,
  /// remover o talento não teria como devolver. Atributo que já estava no teto
  /// de 20 não aparece aqui.
  final String appliedAbilityIncreases;
  const CharacterFeat({
    required this.localId,
    required this.characterId,
    required this.featId,
    this.classId,
    this.level,
    required this.chosenSkills,
    required this.grantedSkills,
    this.chosenAbility,
    required this.appliedAbilityIncreases,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['character_id'] = Variable<String>(characterId);
    map['feat_id'] = Variable<String>(featId);
    if (!nullToAbsent || classId != null) {
      map['class_id'] = Variable<String>(classId);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<int>(level);
    }
    map['chosen_skills'] = Variable<String>(chosenSkills);
    map['granted_skills'] = Variable<String>(grantedSkills);
    if (!nullToAbsent || chosenAbility != null) {
      map['chosen_ability'] = Variable<String>(chosenAbility);
    }
    map['applied_ability_increases'] = Variable<String>(
      appliedAbilityIncreases,
    );
    return map;
  }

  CharacterFeatsCompanion toCompanion(bool nullToAbsent) {
    return CharacterFeatsCompanion(
      localId: Value(localId),
      characterId: Value(characterId),
      featId: Value(featId),
      classId:
          classId == null && nullToAbsent
              ? const Value.absent()
              : Value(classId),
      level:
          level == null && nullToAbsent ? const Value.absent() : Value(level),
      chosenSkills: Value(chosenSkills),
      grantedSkills: Value(grantedSkills),
      chosenAbility:
          chosenAbility == null && nullToAbsent
              ? const Value.absent()
              : Value(chosenAbility),
      appliedAbilityIncreases: Value(appliedAbilityIncreases),
    );
  }

  factory CharacterFeat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterFeat(
      localId: serializer.fromJson<int>(json['localId']),
      characterId: serializer.fromJson<String>(json['characterId']),
      featId: serializer.fromJson<String>(json['featId']),
      classId: serializer.fromJson<String?>(json['classId']),
      level: serializer.fromJson<int?>(json['level']),
      chosenSkills: serializer.fromJson<String>(json['chosenSkills']),
      grantedSkills: serializer.fromJson<String>(json['grantedSkills']),
      chosenAbility: serializer.fromJson<String?>(json['chosenAbility']),
      appliedAbilityIncreases: serializer.fromJson<String>(
        json['appliedAbilityIncreases'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'characterId': serializer.toJson<String>(characterId),
      'featId': serializer.toJson<String>(featId),
      'classId': serializer.toJson<String?>(classId),
      'level': serializer.toJson<int?>(level),
      'chosenSkills': serializer.toJson<String>(chosenSkills),
      'grantedSkills': serializer.toJson<String>(grantedSkills),
      'chosenAbility': serializer.toJson<String?>(chosenAbility),
      'appliedAbilityIncreases': serializer.toJson<String>(
        appliedAbilityIncreases,
      ),
    };
  }

  CharacterFeat copyWith({
    int? localId,
    String? characterId,
    String? featId,
    Value<String?> classId = const Value.absent(),
    Value<int?> level = const Value.absent(),
    String? chosenSkills,
    String? grantedSkills,
    Value<String?> chosenAbility = const Value.absent(),
    String? appliedAbilityIncreases,
  }) => CharacterFeat(
    localId: localId ?? this.localId,
    characterId: characterId ?? this.characterId,
    featId: featId ?? this.featId,
    classId: classId.present ? classId.value : this.classId,
    level: level.present ? level.value : this.level,
    chosenSkills: chosenSkills ?? this.chosenSkills,
    grantedSkills: grantedSkills ?? this.grantedSkills,
    chosenAbility:
        chosenAbility.present ? chosenAbility.value : this.chosenAbility,
    appliedAbilityIncreases:
        appliedAbilityIncreases ?? this.appliedAbilityIncreases,
  );
  CharacterFeat copyWithCompanion(CharacterFeatsCompanion data) {
    return CharacterFeat(
      localId: data.localId.present ? data.localId.value : this.localId,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      featId: data.featId.present ? data.featId.value : this.featId,
      classId: data.classId.present ? data.classId.value : this.classId,
      level: data.level.present ? data.level.value : this.level,
      chosenSkills:
          data.chosenSkills.present
              ? data.chosenSkills.value
              : this.chosenSkills,
      grantedSkills:
          data.grantedSkills.present
              ? data.grantedSkills.value
              : this.grantedSkills,
      chosenAbility:
          data.chosenAbility.present
              ? data.chosenAbility.value
              : this.chosenAbility,
      appliedAbilityIncreases:
          data.appliedAbilityIncreases.present
              ? data.appliedAbilityIncreases.value
              : this.appliedAbilityIncreases,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterFeat(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('featId: $featId, ')
          ..write('classId: $classId, ')
          ..write('level: $level, ')
          ..write('chosenSkills: $chosenSkills, ')
          ..write('grantedSkills: $grantedSkills, ')
          ..write('chosenAbility: $chosenAbility, ')
          ..write('appliedAbilityIncreases: $appliedAbilityIncreases')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    characterId,
    featId,
    classId,
    level,
    chosenSkills,
    grantedSkills,
    chosenAbility,
    appliedAbilityIncreases,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterFeat &&
          other.localId == this.localId &&
          other.characterId == this.characterId &&
          other.featId == this.featId &&
          other.classId == this.classId &&
          other.level == this.level &&
          other.chosenSkills == this.chosenSkills &&
          other.grantedSkills == this.grantedSkills &&
          other.chosenAbility == this.chosenAbility &&
          other.appliedAbilityIncreases == this.appliedAbilityIncreases);
}

class CharacterFeatsCompanion extends UpdateCompanion<CharacterFeat> {
  final Value<int> localId;
  final Value<String> characterId;
  final Value<String> featId;
  final Value<String?> classId;
  final Value<int?> level;
  final Value<String> chosenSkills;
  final Value<String> grantedSkills;
  final Value<String?> chosenAbility;
  final Value<String> appliedAbilityIncreases;
  const CharacterFeatsCompanion({
    this.localId = const Value.absent(),
    this.characterId = const Value.absent(),
    this.featId = const Value.absent(),
    this.classId = const Value.absent(),
    this.level = const Value.absent(),
    this.chosenSkills = const Value.absent(),
    this.grantedSkills = const Value.absent(),
    this.chosenAbility = const Value.absent(),
    this.appliedAbilityIncreases = const Value.absent(),
  });
  CharacterFeatsCompanion.insert({
    this.localId = const Value.absent(),
    required String characterId,
    required String featId,
    this.classId = const Value.absent(),
    this.level = const Value.absent(),
    this.chosenSkills = const Value.absent(),
    this.grantedSkills = const Value.absent(),
    this.chosenAbility = const Value.absent(),
    this.appliedAbilityIncreases = const Value.absent(),
  }) : characterId = Value(characterId),
       featId = Value(featId);
  static Insertable<CharacterFeat> custom({
    Expression<int>? localId,
    Expression<String>? characterId,
    Expression<String>? featId,
    Expression<String>? classId,
    Expression<int>? level,
    Expression<String>? chosenSkills,
    Expression<String>? grantedSkills,
    Expression<String>? chosenAbility,
    Expression<String>? appliedAbilityIncreases,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (characterId != null) 'character_id': characterId,
      if (featId != null) 'feat_id': featId,
      if (classId != null) 'class_id': classId,
      if (level != null) 'level': level,
      if (chosenSkills != null) 'chosen_skills': chosenSkills,
      if (grantedSkills != null) 'granted_skills': grantedSkills,
      if (chosenAbility != null) 'chosen_ability': chosenAbility,
      if (appliedAbilityIncreases != null)
        'applied_ability_increases': appliedAbilityIncreases,
    });
  }

  CharacterFeatsCompanion copyWith({
    Value<int>? localId,
    Value<String>? characterId,
    Value<String>? featId,
    Value<String?>? classId,
    Value<int?>? level,
    Value<String>? chosenSkills,
    Value<String>? grantedSkills,
    Value<String?>? chosenAbility,
    Value<String>? appliedAbilityIncreases,
  }) {
    return CharacterFeatsCompanion(
      localId: localId ?? this.localId,
      characterId: characterId ?? this.characterId,
      featId: featId ?? this.featId,
      classId: classId ?? this.classId,
      level: level ?? this.level,
      chosenSkills: chosenSkills ?? this.chosenSkills,
      grantedSkills: grantedSkills ?? this.grantedSkills,
      chosenAbility: chosenAbility ?? this.chosenAbility,
      appliedAbilityIncreases:
          appliedAbilityIncreases ?? this.appliedAbilityIncreases,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (featId.present) {
      map['feat_id'] = Variable<String>(featId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (chosenSkills.present) {
      map['chosen_skills'] = Variable<String>(chosenSkills.value);
    }
    if (grantedSkills.present) {
      map['granted_skills'] = Variable<String>(grantedSkills.value);
    }
    if (chosenAbility.present) {
      map['chosen_ability'] = Variable<String>(chosenAbility.value);
    }
    if (appliedAbilityIncreases.present) {
      map['applied_ability_increases'] = Variable<String>(
        appliedAbilityIncreases.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterFeatsCompanion(')
          ..write('localId: $localId, ')
          ..write('characterId: $characterId, ')
          ..write('featId: $featId, ')
          ..write('classId: $classId, ')
          ..write('level: $level, ')
          ..write('chosenSkills: $chosenSkills, ')
          ..write('grantedSkills: $grantedSkills, ')
          ..write('chosenAbility: $chosenAbility, ')
          ..write('appliedAbilityIncreases: $appliedAbilityIncreases')
          ..write(')'))
        .toString();
  }
}

class $ClassEntriesTable extends ClassEntries
    with TableInfo<$ClassEntriesTable, ClassEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hitDieMeta = const VerificationMeta('hitDie');
  @override
  late final GeneratedColumn<String> hitDie = GeneratedColumn<String>(
    'hit_die',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryAbilityMeta = const VerificationMeta(
    'primaryAbility',
  );
  @override
  late final GeneratedColumn<String> primaryAbility = GeneratedColumn<String>(
    'primary_ability',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('srd'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    hitDie,
    primaryAbility,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hit_die')) {
      context.handle(
        _hitDieMeta,
        hitDie.isAcceptableOrUnknown(data['hit_die']!, _hitDieMeta),
      );
    } else if (isInserting) {
      context.missing(_hitDieMeta);
    }
    if (data.containsKey('primary_ability')) {
      context.handle(
        _primaryAbilityMeta,
        primaryAbility.isAcceptableOrUnknown(
          data['primary_ability']!,
          _primaryAbilityMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      hitDie:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}hit_die'],
          )!,
      primaryAbility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_ability'],
      ),
      source:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}source'],
          )!,
    );
  }

  @override
  $ClassEntriesTable createAlias(String alias) {
    return $ClassEntriesTable(attachedDatabase, alias);
  }
}

class ClassEntry extends DataClass implements Insertable<ClassEntry> {
  final String id;
  final String name;
  final String hitDie;
  final String? primaryAbility;
  final String source;
  const ClassEntry({
    required this.id,
    required this.name,
    required this.hitDie,
    this.primaryAbility,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['hit_die'] = Variable<String>(hitDie);
    if (!nullToAbsent || primaryAbility != null) {
      map['primary_ability'] = Variable<String>(primaryAbility);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  ClassEntriesCompanion toCompanion(bool nullToAbsent) {
    return ClassEntriesCompanion(
      id: Value(id),
      name: Value(name),
      hitDie: Value(hitDie),
      primaryAbility:
          primaryAbility == null && nullToAbsent
              ? const Value.absent()
              : Value(primaryAbility),
      source: Value(source),
    );
  }

  factory ClassEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      hitDie: serializer.fromJson<String>(json['hitDie']),
      primaryAbility: serializer.fromJson<String?>(json['primaryAbility']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'hitDie': serializer.toJson<String>(hitDie),
      'primaryAbility': serializer.toJson<String?>(primaryAbility),
      'source': serializer.toJson<String>(source),
    };
  }

  ClassEntry copyWith({
    String? id,
    String? name,
    String? hitDie,
    Value<String?> primaryAbility = const Value.absent(),
    String? source,
  }) => ClassEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    hitDie: hitDie ?? this.hitDie,
    primaryAbility:
        primaryAbility.present ? primaryAbility.value : this.primaryAbility,
    source: source ?? this.source,
  );
  ClassEntry copyWithCompanion(ClassEntriesCompanion data) {
    return ClassEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      hitDie: data.hitDie.present ? data.hitDie.value : this.hitDie,
      primaryAbility:
          data.primaryAbility.present
              ? data.primaryAbility.value
              : this.primaryAbility,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hitDie: $hitDie, ')
          ..write('primaryAbility: $primaryAbility, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, hitDie, primaryAbility, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.hitDie == this.hitDie &&
          other.primaryAbility == this.primaryAbility &&
          other.source == this.source);
}

class ClassEntriesCompanion extends UpdateCompanion<ClassEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> hitDie;
  final Value<String?> primaryAbility;
  final Value<String> source;
  final Value<int> rowid;
  const ClassEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.hitDie = const Value.absent(),
    this.primaryAbility = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassEntriesCompanion.insert({
    required String id,
    required String name,
    required String hitDie,
    this.primaryAbility = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       hitDie = Value(hitDie);
  static Insertable<ClassEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? hitDie,
    Expression<String>? primaryAbility,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (hitDie != null) 'hit_die': hitDie,
      if (primaryAbility != null) 'primary_ability': primaryAbility,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? hitDie,
    Value<String?>? primaryAbility,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return ClassEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      hitDie: hitDie ?? this.hitDie,
      primaryAbility: primaryAbility ?? this.primaryAbility,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hitDie.present) {
      map['hit_die'] = Variable<String>(hitDie.value);
    }
    if (primaryAbility.present) {
      map['primary_ability'] = Variable<String>(primaryAbility.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hitDie: $hitDie, ')
          ..write('primaryAbility: $primaryAbility, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final $CharacterClassLevelsTable characterClassLevels =
      $CharacterClassLevelsTable(this);
  late final $CharacterSpellsTable characterSpells = $CharacterSpellsTable(
    this,
  );
  late final $CharacterWeaponsTable characterWeapons = $CharacterWeaponsTable(
    this,
  );
  late final $CharacterMagicItemsTable characterMagicItems =
      $CharacterMagicItemsTable(this);
  late final $CharacterMagicItemSpellsTable characterMagicItemSpells =
      $CharacterMagicItemSpellsTable(this);
  late final $CharacterSpellSlotsUsageTable characterSpellSlotsUsage =
      $CharacterSpellSlotsUsageTable(this);
  late final $CharacterFeatsTable characterFeats = $CharacterFeatsTable(this);
  late final $ClassEntriesTable classEntries = $ClassEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    characters,
    characterClassLevels,
    characterSpells,
    characterWeapons,
    characterMagicItems,
    characterMagicItemSpells,
    characterSpellSlotsUsage,
    characterFeats,
    classEntries,
  ];
}

typedef $$CharactersTableCreateCompanionBuilder =
    CharactersCompanion Function({
      required String id,
      required String name,
      Value<String?> playerName,
      Value<String?> portraitPath,
      Value<String?> speciesId,
      Value<String?> backgroundId,
      Value<String?> customBackgroundName,
      Value<String> customBackgroundSkills,
      Value<String> customBackgroundFeatures,
      Value<String> notes,
      Value<int> strength,
      Value<int> dexterity,
      Value<int> constitution,
      Value<int> intelligence,
      Value<int> wisdom,
      Value<int> charisma,
      Value<int> armorClass,
      Value<int> initiativeBonus,
      Value<int> speed,
      Value<double?> speedMeters,
      Value<int> maxHitPoints,
      Value<int> currentHitPoints,
      Value<int> temporaryHitPoints,
      Value<bool> saveStrength,
      Value<bool> saveDexterity,
      Value<bool> saveConstitution,
      Value<bool> saveIntelligence,
      Value<bool> saveWisdom,
      Value<bool> saveCharisma,
      Value<bool> skillAcrobatics,
      Value<bool> skillAnimalHandling,
      Value<bool> skillArcana,
      Value<bool> skillAthletics,
      Value<bool> skillDeception,
      Value<bool> skillHistory,
      Value<bool> skillInsight,
      Value<bool> skillIntimidation,
      Value<bool> skillInvestigation,
      Value<bool> skillMedicine,
      Value<bool> skillNature,
      Value<bool> skillPerception,
      Value<bool> skillPerformance,
      Value<bool> skillPersuasion,
      Value<bool> skillReligion,
      Value<bool> skillSleightOfHand,
      Value<bool> skillStealth,
      Value<bool> skillSurvival,
      Value<int> lvlAcrobatics,
      Value<int> lvlAnimalHandling,
      Value<int> lvlArcana,
      Value<int> lvlAthletics,
      Value<int> lvlDeception,
      Value<int> lvlHistory,
      Value<int> lvlInsight,
      Value<int> lvlIntimidation,
      Value<int> lvlInvestigation,
      Value<int> lvlMedicine,
      Value<int> lvlNature,
      Value<int> lvlPerception,
      Value<int> lvlPerformance,
      Value<int> lvlPersuasion,
      Value<int> lvlReligion,
      Value<int> lvlSleightOfHand,
      Value<int> lvlStealth,
      Value<int> lvlSurvival,
      Value<bool> inspiration,
      Value<int> exhaustion,
      Value<String> conditions,
      Value<int> hitDiceUsed,
      Value<int> copperPieces,
      Value<int> silverPieces,
      Value<int> electrumPieces,
      Value<int> goldPieces,
      Value<int> platinumPieces,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CharactersTableUpdateCompanionBuilder =
    CharactersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> playerName,
      Value<String?> portraitPath,
      Value<String?> speciesId,
      Value<String?> backgroundId,
      Value<String?> customBackgroundName,
      Value<String> customBackgroundSkills,
      Value<String> customBackgroundFeatures,
      Value<String> notes,
      Value<int> strength,
      Value<int> dexterity,
      Value<int> constitution,
      Value<int> intelligence,
      Value<int> wisdom,
      Value<int> charisma,
      Value<int> armorClass,
      Value<int> initiativeBonus,
      Value<int> speed,
      Value<double?> speedMeters,
      Value<int> maxHitPoints,
      Value<int> currentHitPoints,
      Value<int> temporaryHitPoints,
      Value<bool> saveStrength,
      Value<bool> saveDexterity,
      Value<bool> saveConstitution,
      Value<bool> saveIntelligence,
      Value<bool> saveWisdom,
      Value<bool> saveCharisma,
      Value<bool> skillAcrobatics,
      Value<bool> skillAnimalHandling,
      Value<bool> skillArcana,
      Value<bool> skillAthletics,
      Value<bool> skillDeception,
      Value<bool> skillHistory,
      Value<bool> skillInsight,
      Value<bool> skillIntimidation,
      Value<bool> skillInvestigation,
      Value<bool> skillMedicine,
      Value<bool> skillNature,
      Value<bool> skillPerception,
      Value<bool> skillPerformance,
      Value<bool> skillPersuasion,
      Value<bool> skillReligion,
      Value<bool> skillSleightOfHand,
      Value<bool> skillStealth,
      Value<bool> skillSurvival,
      Value<int> lvlAcrobatics,
      Value<int> lvlAnimalHandling,
      Value<int> lvlArcana,
      Value<int> lvlAthletics,
      Value<int> lvlDeception,
      Value<int> lvlHistory,
      Value<int> lvlInsight,
      Value<int> lvlIntimidation,
      Value<int> lvlInvestigation,
      Value<int> lvlMedicine,
      Value<int> lvlNature,
      Value<int> lvlPerception,
      Value<int> lvlPerformance,
      Value<int> lvlPersuasion,
      Value<int> lvlReligion,
      Value<int> lvlSleightOfHand,
      Value<int> lvlStealth,
      Value<int> lvlSurvival,
      Value<bool> inspiration,
      Value<int> exhaustion,
      Value<String> conditions,
      Value<int> hitDiceUsed,
      Value<int> copperPieces,
      Value<int> silverPieces,
      Value<int> electrumPieces,
      Value<int> goldPieces,
      Value<int> platinumPieces,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CharactersTableReferences
    extends BaseReferences<_$AppDatabase, $CharactersTable, Character> {
  $$CharactersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $CharacterClassLevelsTable,
    List<CharacterClassLevel>
  >
  _characterClassLevelsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.characterClassLevels,
        aliasName: $_aliasNameGenerator(
          db.characters.id,
          db.characterClassLevels.characterId,
        ),
      );

  $$CharacterClassLevelsTableProcessedTableManager
  get characterClassLevelsRefs {
    final manager = $$CharacterClassLevelsTableTableManager(
      $_db,
      $_db.characterClassLevels,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characterClassLevelsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CharacterSpellsTable, List<CharacterSpell>>
  _characterSpellsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characterSpells,
    aliasName: $_aliasNameGenerator(
      db.characters.id,
      db.characterSpells.characterId,
    ),
  );

  $$CharacterSpellsTableProcessedTableManager get characterSpellsRefs {
    final manager = $$CharacterSpellsTableTableManager(
      $_db,
      $_db.characterSpells,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characterSpellsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CharacterWeaponsTable, List<CharacterWeapon>>
  _characterWeaponsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characterWeapons,
    aliasName: $_aliasNameGenerator(
      db.characters.id,
      db.characterWeapons.characterId,
    ),
  );

  $$CharacterWeaponsTableProcessedTableManager get characterWeaponsRefs {
    final manager = $$CharacterWeaponsTableTableManager(
      $_db,
      $_db.characterWeapons,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characterWeaponsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CharacterMagicItemsTable,
    List<CharacterMagicItem>
  >
  _characterMagicItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.characterMagicItems,
        aliasName: $_aliasNameGenerator(
          db.characters.id,
          db.characterMagicItems.characterId,
        ),
      );

  $$CharacterMagicItemsTableProcessedTableManager get characterMagicItemsRefs {
    final manager = $$CharacterMagicItemsTableTableManager(
      $_db,
      $_db.characterMagicItems,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characterMagicItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CharacterSpellSlotsUsageTable,
    List<CharacterSpellSlotsUsageData>
  >
  _characterSpellSlotsUsageRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.characterSpellSlotsUsage,
        aliasName: $_aliasNameGenerator(
          db.characters.id,
          db.characterSpellSlotsUsage.characterId,
        ),
      );

  $$CharacterSpellSlotsUsageTableProcessedTableManager
  get characterSpellSlotsUsageRefs {
    final manager = $$CharacterSpellSlotsUsageTableTableManager(
      $_db,
      $_db.characterSpellSlotsUsage,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characterSpellSlotsUsageRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CharacterFeatsTable, List<CharacterFeat>>
  _characterFeatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characterFeats,
    aliasName: $_aliasNameGenerator(
      db.characters.id,
      db.characterFeats.characterId,
    ),
  );

  $$CharacterFeatsTableProcessedTableManager get characterFeatsRefs {
    final manager = $$CharacterFeatsTableTableManager(
      $_db,
      $_db.characterFeats,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_characterFeatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CharactersTableFilterComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get portraitPath => $composableBuilder(
    column: $table.portraitPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backgroundId => $composableBuilder(
    column: $table.backgroundId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customBackgroundName => $composableBuilder(
    column: $table.customBackgroundName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customBackgroundSkills => $composableBuilder(
    column: $table.customBackgroundSkills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customBackgroundFeatures => $composableBuilder(
    column: $table.customBackgroundFeatures,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dexterity => $composableBuilder(
    column: $table.dexterity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get constitution => $composableBuilder(
    column: $table.constitution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intelligence => $composableBuilder(
    column: $table.intelligence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wisdom => $composableBuilder(
    column: $table.wisdom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charisma => $composableBuilder(
    column: $table.charisma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get armorClass => $composableBuilder(
    column: $table.armorClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initiativeBonus => $composableBuilder(
    column: $table.initiativeBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMeters => $composableBuilder(
    column: $table.speedMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHitPoints => $composableBuilder(
    column: $table.maxHitPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentHitPoints => $composableBuilder(
    column: $table.currentHitPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporaryHitPoints => $composableBuilder(
    column: $table.temporaryHitPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get saveStrength => $composableBuilder(
    column: $table.saveStrength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get saveDexterity => $composableBuilder(
    column: $table.saveDexterity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get saveConstitution => $composableBuilder(
    column: $table.saveConstitution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get saveIntelligence => $composableBuilder(
    column: $table.saveIntelligence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get saveWisdom => $composableBuilder(
    column: $table.saveWisdom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get saveCharisma => $composableBuilder(
    column: $table.saveCharisma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillAcrobatics => $composableBuilder(
    column: $table.skillAcrobatics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillAnimalHandling => $composableBuilder(
    column: $table.skillAnimalHandling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillArcana => $composableBuilder(
    column: $table.skillArcana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillAthletics => $composableBuilder(
    column: $table.skillAthletics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillDeception => $composableBuilder(
    column: $table.skillDeception,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillHistory => $composableBuilder(
    column: $table.skillHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillInsight => $composableBuilder(
    column: $table.skillInsight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillIntimidation => $composableBuilder(
    column: $table.skillIntimidation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillInvestigation => $composableBuilder(
    column: $table.skillInvestigation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillMedicine => $composableBuilder(
    column: $table.skillMedicine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillNature => $composableBuilder(
    column: $table.skillNature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillPerception => $composableBuilder(
    column: $table.skillPerception,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillPerformance => $composableBuilder(
    column: $table.skillPerformance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillPersuasion => $composableBuilder(
    column: $table.skillPersuasion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillReligion => $composableBuilder(
    column: $table.skillReligion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillSleightOfHand => $composableBuilder(
    column: $table.skillSleightOfHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillStealth => $composableBuilder(
    column: $table.skillStealth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skillSurvival => $composableBuilder(
    column: $table.skillSurvival,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlAcrobatics => $composableBuilder(
    column: $table.lvlAcrobatics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlAnimalHandling => $composableBuilder(
    column: $table.lvlAnimalHandling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlArcana => $composableBuilder(
    column: $table.lvlArcana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlAthletics => $composableBuilder(
    column: $table.lvlAthletics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlDeception => $composableBuilder(
    column: $table.lvlDeception,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlHistory => $composableBuilder(
    column: $table.lvlHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlInsight => $composableBuilder(
    column: $table.lvlInsight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlIntimidation => $composableBuilder(
    column: $table.lvlIntimidation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlInvestigation => $composableBuilder(
    column: $table.lvlInvestigation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlMedicine => $composableBuilder(
    column: $table.lvlMedicine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlNature => $composableBuilder(
    column: $table.lvlNature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlPerception => $composableBuilder(
    column: $table.lvlPerception,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlPerformance => $composableBuilder(
    column: $table.lvlPerformance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlPersuasion => $composableBuilder(
    column: $table.lvlPersuasion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlReligion => $composableBuilder(
    column: $table.lvlReligion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlSleightOfHand => $composableBuilder(
    column: $table.lvlSleightOfHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlStealth => $composableBuilder(
    column: $table.lvlStealth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvlSurvival => $composableBuilder(
    column: $table.lvlSurvival,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inspiration => $composableBuilder(
    column: $table.inspiration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exhaustion => $composableBuilder(
    column: $table.exhaustion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hitDiceUsed => $composableBuilder(
    column: $table.hitDiceUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get copperPieces => $composableBuilder(
    column: $table.copperPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get silverPieces => $composableBuilder(
    column: $table.silverPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get electrumPieces => $composableBuilder(
    column: $table.electrumPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goldPieces => $composableBuilder(
    column: $table.goldPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get platinumPieces => $composableBuilder(
    column: $table.platinumPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> characterClassLevelsRefs(
    Expression<bool> Function($$CharacterClassLevelsTableFilterComposer f) f,
  ) {
    final $$CharacterClassLevelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterClassLevels,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterClassLevelsTableFilterComposer(
            $db: $db,
            $table: $db.characterClassLevels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> characterSpellsRefs(
    Expression<bool> Function($$CharacterSpellsTableFilterComposer f) f,
  ) {
    final $$CharacterSpellsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterSpells,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSpellsTableFilterComposer(
            $db: $db,
            $table: $db.characterSpells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> characterWeaponsRefs(
    Expression<bool> Function($$CharacterWeaponsTableFilterComposer f) f,
  ) {
    final $$CharacterWeaponsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterWeapons,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterWeaponsTableFilterComposer(
            $db: $db,
            $table: $db.characterWeapons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> characterMagicItemsRefs(
    Expression<bool> Function($$CharacterMagicItemsTableFilterComposer f) f,
  ) {
    final $$CharacterMagicItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterMagicItems,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterMagicItemsTableFilterComposer(
            $db: $db,
            $table: $db.characterMagicItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> characterSpellSlotsUsageRefs(
    Expression<bool> Function($$CharacterSpellSlotsUsageTableFilterComposer f)
    f,
  ) {
    final $$CharacterSpellSlotsUsageTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.characterSpellSlotsUsage,
          getReferencedColumn: (t) => t.characterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacterSpellSlotsUsageTableFilterComposer(
                $db: $db,
                $table: $db.characterSpellSlotsUsage,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> characterFeatsRefs(
    Expression<bool> Function($$CharacterFeatsTableFilterComposer f) f,
  ) {
    final $$CharacterFeatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterFeats,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterFeatsTableFilterComposer(
            $db: $db,
            $table: $db.characterFeats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get portraitPath => $composableBuilder(
    column: $table.portraitPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backgroundId => $composableBuilder(
    column: $table.backgroundId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customBackgroundName => $composableBuilder(
    column: $table.customBackgroundName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customBackgroundSkills => $composableBuilder(
    column: $table.customBackgroundSkills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customBackgroundFeatures => $composableBuilder(
    column: $table.customBackgroundFeatures,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dexterity => $composableBuilder(
    column: $table.dexterity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get constitution => $composableBuilder(
    column: $table.constitution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intelligence => $composableBuilder(
    column: $table.intelligence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wisdom => $composableBuilder(
    column: $table.wisdom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charisma => $composableBuilder(
    column: $table.charisma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get armorClass => $composableBuilder(
    column: $table.armorClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initiativeBonus => $composableBuilder(
    column: $table.initiativeBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMeters => $composableBuilder(
    column: $table.speedMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHitPoints => $composableBuilder(
    column: $table.maxHitPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentHitPoints => $composableBuilder(
    column: $table.currentHitPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporaryHitPoints => $composableBuilder(
    column: $table.temporaryHitPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get saveStrength => $composableBuilder(
    column: $table.saveStrength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get saveDexterity => $composableBuilder(
    column: $table.saveDexterity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get saveConstitution => $composableBuilder(
    column: $table.saveConstitution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get saveIntelligence => $composableBuilder(
    column: $table.saveIntelligence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get saveWisdom => $composableBuilder(
    column: $table.saveWisdom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get saveCharisma => $composableBuilder(
    column: $table.saveCharisma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillAcrobatics => $composableBuilder(
    column: $table.skillAcrobatics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillAnimalHandling => $composableBuilder(
    column: $table.skillAnimalHandling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillArcana => $composableBuilder(
    column: $table.skillArcana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillAthletics => $composableBuilder(
    column: $table.skillAthletics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillDeception => $composableBuilder(
    column: $table.skillDeception,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillHistory => $composableBuilder(
    column: $table.skillHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillInsight => $composableBuilder(
    column: $table.skillInsight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillIntimidation => $composableBuilder(
    column: $table.skillIntimidation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillInvestigation => $composableBuilder(
    column: $table.skillInvestigation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillMedicine => $composableBuilder(
    column: $table.skillMedicine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillNature => $composableBuilder(
    column: $table.skillNature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillPerception => $composableBuilder(
    column: $table.skillPerception,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillPerformance => $composableBuilder(
    column: $table.skillPerformance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillPersuasion => $composableBuilder(
    column: $table.skillPersuasion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillReligion => $composableBuilder(
    column: $table.skillReligion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillSleightOfHand => $composableBuilder(
    column: $table.skillSleightOfHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillStealth => $composableBuilder(
    column: $table.skillStealth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skillSurvival => $composableBuilder(
    column: $table.skillSurvival,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlAcrobatics => $composableBuilder(
    column: $table.lvlAcrobatics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlAnimalHandling => $composableBuilder(
    column: $table.lvlAnimalHandling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlArcana => $composableBuilder(
    column: $table.lvlArcana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlAthletics => $composableBuilder(
    column: $table.lvlAthletics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlDeception => $composableBuilder(
    column: $table.lvlDeception,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlHistory => $composableBuilder(
    column: $table.lvlHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlInsight => $composableBuilder(
    column: $table.lvlInsight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlIntimidation => $composableBuilder(
    column: $table.lvlIntimidation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlInvestigation => $composableBuilder(
    column: $table.lvlInvestigation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlMedicine => $composableBuilder(
    column: $table.lvlMedicine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlNature => $composableBuilder(
    column: $table.lvlNature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlPerception => $composableBuilder(
    column: $table.lvlPerception,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlPerformance => $composableBuilder(
    column: $table.lvlPerformance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlPersuasion => $composableBuilder(
    column: $table.lvlPersuasion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlReligion => $composableBuilder(
    column: $table.lvlReligion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlSleightOfHand => $composableBuilder(
    column: $table.lvlSleightOfHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlStealth => $composableBuilder(
    column: $table.lvlStealth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvlSurvival => $composableBuilder(
    column: $table.lvlSurvival,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inspiration => $composableBuilder(
    column: $table.inspiration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exhaustion => $composableBuilder(
    column: $table.exhaustion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hitDiceUsed => $composableBuilder(
    column: $table.hitDiceUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get copperPieces => $composableBuilder(
    column: $table.copperPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get silverPieces => $composableBuilder(
    column: $table.silverPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get electrumPieces => $composableBuilder(
    column: $table.electrumPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goldPieces => $composableBuilder(
    column: $table.goldPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get platinumPieces => $composableBuilder(
    column: $table.platinumPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get portraitPath => $composableBuilder(
    column: $table.portraitPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get backgroundId => $composableBuilder(
    column: $table.backgroundId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customBackgroundName => $composableBuilder(
    column: $table.customBackgroundName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customBackgroundSkills => $composableBuilder(
    column: $table.customBackgroundSkills,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customBackgroundFeatures => $composableBuilder(
    column: $table.customBackgroundFeatures,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<int> get dexterity =>
      $composableBuilder(column: $table.dexterity, builder: (column) => column);

  GeneratedColumn<int> get constitution => $composableBuilder(
    column: $table.constitution,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intelligence => $composableBuilder(
    column: $table.intelligence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wisdom =>
      $composableBuilder(column: $table.wisdom, builder: (column) => column);

  GeneratedColumn<int> get charisma =>
      $composableBuilder(column: $table.charisma, builder: (column) => column);

  GeneratedColumn<int> get armorClass => $composableBuilder(
    column: $table.armorClass,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initiativeBonus => $composableBuilder(
    column: $table.initiativeBonus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get speedMeters => $composableBuilder(
    column: $table.speedMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxHitPoints => $composableBuilder(
    column: $table.maxHitPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentHitPoints => $composableBuilder(
    column: $table.currentHitPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get temporaryHitPoints => $composableBuilder(
    column: $table.temporaryHitPoints,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get saveStrength => $composableBuilder(
    column: $table.saveStrength,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get saveDexterity => $composableBuilder(
    column: $table.saveDexterity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get saveConstitution => $composableBuilder(
    column: $table.saveConstitution,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get saveIntelligence => $composableBuilder(
    column: $table.saveIntelligence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get saveWisdom => $composableBuilder(
    column: $table.saveWisdom,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get saveCharisma => $composableBuilder(
    column: $table.saveCharisma,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillAcrobatics => $composableBuilder(
    column: $table.skillAcrobatics,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillAnimalHandling => $composableBuilder(
    column: $table.skillAnimalHandling,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillArcana => $composableBuilder(
    column: $table.skillArcana,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillAthletics => $composableBuilder(
    column: $table.skillAthletics,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillDeception => $composableBuilder(
    column: $table.skillDeception,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillHistory => $composableBuilder(
    column: $table.skillHistory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillInsight => $composableBuilder(
    column: $table.skillInsight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillIntimidation => $composableBuilder(
    column: $table.skillIntimidation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillInvestigation => $composableBuilder(
    column: $table.skillInvestigation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillMedicine => $composableBuilder(
    column: $table.skillMedicine,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillNature => $composableBuilder(
    column: $table.skillNature,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillPerception => $composableBuilder(
    column: $table.skillPerception,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillPerformance => $composableBuilder(
    column: $table.skillPerformance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillPersuasion => $composableBuilder(
    column: $table.skillPersuasion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillReligion => $composableBuilder(
    column: $table.skillReligion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillSleightOfHand => $composableBuilder(
    column: $table.skillSleightOfHand,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillStealth => $composableBuilder(
    column: $table.skillStealth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skillSurvival => $composableBuilder(
    column: $table.skillSurvival,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlAcrobatics => $composableBuilder(
    column: $table.lvlAcrobatics,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlAnimalHandling => $composableBuilder(
    column: $table.lvlAnimalHandling,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlArcana =>
      $composableBuilder(column: $table.lvlArcana, builder: (column) => column);

  GeneratedColumn<int> get lvlAthletics => $composableBuilder(
    column: $table.lvlAthletics,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlDeception => $composableBuilder(
    column: $table.lvlDeception,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlHistory => $composableBuilder(
    column: $table.lvlHistory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlInsight => $composableBuilder(
    column: $table.lvlInsight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlIntimidation => $composableBuilder(
    column: $table.lvlIntimidation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlInvestigation => $composableBuilder(
    column: $table.lvlInvestigation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlMedicine => $composableBuilder(
    column: $table.lvlMedicine,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlNature =>
      $composableBuilder(column: $table.lvlNature, builder: (column) => column);

  GeneratedColumn<int> get lvlPerception => $composableBuilder(
    column: $table.lvlPerception,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlPerformance => $composableBuilder(
    column: $table.lvlPerformance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlPersuasion => $composableBuilder(
    column: $table.lvlPersuasion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlReligion => $composableBuilder(
    column: $table.lvlReligion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlSleightOfHand => $composableBuilder(
    column: $table.lvlSleightOfHand,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlStealth => $composableBuilder(
    column: $table.lvlStealth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lvlSurvival => $composableBuilder(
    column: $table.lvlSurvival,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get inspiration => $composableBuilder(
    column: $table.inspiration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exhaustion => $composableBuilder(
    column: $table.exhaustion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hitDiceUsed => $composableBuilder(
    column: $table.hitDiceUsed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get copperPieces => $composableBuilder(
    column: $table.copperPieces,
    builder: (column) => column,
  );

  GeneratedColumn<int> get silverPieces => $composableBuilder(
    column: $table.silverPieces,
    builder: (column) => column,
  );

  GeneratedColumn<int> get electrumPieces => $composableBuilder(
    column: $table.electrumPieces,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goldPieces => $composableBuilder(
    column: $table.goldPieces,
    builder: (column) => column,
  );

  GeneratedColumn<int> get platinumPieces => $composableBuilder(
    column: $table.platinumPieces,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> characterClassLevelsRefs<T extends Object>(
    Expression<T> Function($$CharacterClassLevelsTableAnnotationComposer a) f,
  ) {
    final $$CharacterClassLevelsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.characterClassLevels,
          getReferencedColumn: (t) => t.characterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacterClassLevelsTableAnnotationComposer(
                $db: $db,
                $table: $db.characterClassLevels,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> characterSpellsRefs<T extends Object>(
    Expression<T> Function($$CharacterSpellsTableAnnotationComposer a) f,
  ) {
    final $$CharacterSpellsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterSpells,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSpellsTableAnnotationComposer(
            $db: $db,
            $table: $db.characterSpells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> characterWeaponsRefs<T extends Object>(
    Expression<T> Function($$CharacterWeaponsTableAnnotationComposer a) f,
  ) {
    final $$CharacterWeaponsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterWeapons,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterWeaponsTableAnnotationComposer(
            $db: $db,
            $table: $db.characterWeapons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> characterMagicItemsRefs<T extends Object>(
    Expression<T> Function($$CharacterMagicItemsTableAnnotationComposer a) f,
  ) {
    final $$CharacterMagicItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.characterMagicItems,
          getReferencedColumn: (t) => t.characterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacterMagicItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.characterMagicItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> characterSpellSlotsUsageRefs<T extends Object>(
    Expression<T> Function($$CharacterSpellSlotsUsageTableAnnotationComposer a)
    f,
  ) {
    final $$CharacterSpellSlotsUsageTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.characterSpellSlotsUsage,
          getReferencedColumn: (t) => t.characterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacterSpellSlotsUsageTableAnnotationComposer(
                $db: $db,
                $table: $db.characterSpellSlotsUsage,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> characterFeatsRefs<T extends Object>(
    Expression<T> Function($$CharacterFeatsTableAnnotationComposer a) f,
  ) {
    final $$CharacterFeatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterFeats,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterFeatsTableAnnotationComposer(
            $db: $db,
            $table: $db.characterFeats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharactersTable,
          Character,
          $$CharactersTableFilterComposer,
          $$CharactersTableOrderingComposer,
          $$CharactersTableAnnotationComposer,
          $$CharactersTableCreateCompanionBuilder,
          $$CharactersTableUpdateCompanionBuilder,
          (Character, $$CharactersTableReferences),
          Character,
          PrefetchHooks Function({
            bool characterClassLevelsRefs,
            bool characterSpellsRefs,
            bool characterWeaponsRefs,
            bool characterMagicItemsRefs,
            bool characterSpellSlotsUsageRefs,
            bool characterFeatsRefs,
          })
        > {
  $$CharactersTableTableManager(_$AppDatabase db, $CharactersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> playerName = const Value.absent(),
                Value<String?> portraitPath = const Value.absent(),
                Value<String?> speciesId = const Value.absent(),
                Value<String?> backgroundId = const Value.absent(),
                Value<String?> customBackgroundName = const Value.absent(),
                Value<String> customBackgroundSkills = const Value.absent(),
                Value<String> customBackgroundFeatures = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> strength = const Value.absent(),
                Value<int> dexterity = const Value.absent(),
                Value<int> constitution = const Value.absent(),
                Value<int> intelligence = const Value.absent(),
                Value<int> wisdom = const Value.absent(),
                Value<int> charisma = const Value.absent(),
                Value<int> armorClass = const Value.absent(),
                Value<int> initiativeBonus = const Value.absent(),
                Value<int> speed = const Value.absent(),
                Value<double?> speedMeters = const Value.absent(),
                Value<int> maxHitPoints = const Value.absent(),
                Value<int> currentHitPoints = const Value.absent(),
                Value<int> temporaryHitPoints = const Value.absent(),
                Value<bool> saveStrength = const Value.absent(),
                Value<bool> saveDexterity = const Value.absent(),
                Value<bool> saveConstitution = const Value.absent(),
                Value<bool> saveIntelligence = const Value.absent(),
                Value<bool> saveWisdom = const Value.absent(),
                Value<bool> saveCharisma = const Value.absent(),
                Value<bool> skillAcrobatics = const Value.absent(),
                Value<bool> skillAnimalHandling = const Value.absent(),
                Value<bool> skillArcana = const Value.absent(),
                Value<bool> skillAthletics = const Value.absent(),
                Value<bool> skillDeception = const Value.absent(),
                Value<bool> skillHistory = const Value.absent(),
                Value<bool> skillInsight = const Value.absent(),
                Value<bool> skillIntimidation = const Value.absent(),
                Value<bool> skillInvestigation = const Value.absent(),
                Value<bool> skillMedicine = const Value.absent(),
                Value<bool> skillNature = const Value.absent(),
                Value<bool> skillPerception = const Value.absent(),
                Value<bool> skillPerformance = const Value.absent(),
                Value<bool> skillPersuasion = const Value.absent(),
                Value<bool> skillReligion = const Value.absent(),
                Value<bool> skillSleightOfHand = const Value.absent(),
                Value<bool> skillStealth = const Value.absent(),
                Value<bool> skillSurvival = const Value.absent(),
                Value<int> lvlAcrobatics = const Value.absent(),
                Value<int> lvlAnimalHandling = const Value.absent(),
                Value<int> lvlArcana = const Value.absent(),
                Value<int> lvlAthletics = const Value.absent(),
                Value<int> lvlDeception = const Value.absent(),
                Value<int> lvlHistory = const Value.absent(),
                Value<int> lvlInsight = const Value.absent(),
                Value<int> lvlIntimidation = const Value.absent(),
                Value<int> lvlInvestigation = const Value.absent(),
                Value<int> lvlMedicine = const Value.absent(),
                Value<int> lvlNature = const Value.absent(),
                Value<int> lvlPerception = const Value.absent(),
                Value<int> lvlPerformance = const Value.absent(),
                Value<int> lvlPersuasion = const Value.absent(),
                Value<int> lvlReligion = const Value.absent(),
                Value<int> lvlSleightOfHand = const Value.absent(),
                Value<int> lvlStealth = const Value.absent(),
                Value<int> lvlSurvival = const Value.absent(),
                Value<bool> inspiration = const Value.absent(),
                Value<int> exhaustion = const Value.absent(),
                Value<String> conditions = const Value.absent(),
                Value<int> hitDiceUsed = const Value.absent(),
                Value<int> copperPieces = const Value.absent(),
                Value<int> silverPieces = const Value.absent(),
                Value<int> electrumPieces = const Value.absent(),
                Value<int> goldPieces = const Value.absent(),
                Value<int> platinumPieces = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                name: name,
                playerName: playerName,
                portraitPath: portraitPath,
                speciesId: speciesId,
                backgroundId: backgroundId,
                customBackgroundName: customBackgroundName,
                customBackgroundSkills: customBackgroundSkills,
                customBackgroundFeatures: customBackgroundFeatures,
                notes: notes,
                strength: strength,
                dexterity: dexterity,
                constitution: constitution,
                intelligence: intelligence,
                wisdom: wisdom,
                charisma: charisma,
                armorClass: armorClass,
                initiativeBonus: initiativeBonus,
                speed: speed,
                speedMeters: speedMeters,
                maxHitPoints: maxHitPoints,
                currentHitPoints: currentHitPoints,
                temporaryHitPoints: temporaryHitPoints,
                saveStrength: saveStrength,
                saveDexterity: saveDexterity,
                saveConstitution: saveConstitution,
                saveIntelligence: saveIntelligence,
                saveWisdom: saveWisdom,
                saveCharisma: saveCharisma,
                skillAcrobatics: skillAcrobatics,
                skillAnimalHandling: skillAnimalHandling,
                skillArcana: skillArcana,
                skillAthletics: skillAthletics,
                skillDeception: skillDeception,
                skillHistory: skillHistory,
                skillInsight: skillInsight,
                skillIntimidation: skillIntimidation,
                skillInvestigation: skillInvestigation,
                skillMedicine: skillMedicine,
                skillNature: skillNature,
                skillPerception: skillPerception,
                skillPerformance: skillPerformance,
                skillPersuasion: skillPersuasion,
                skillReligion: skillReligion,
                skillSleightOfHand: skillSleightOfHand,
                skillStealth: skillStealth,
                skillSurvival: skillSurvival,
                lvlAcrobatics: lvlAcrobatics,
                lvlAnimalHandling: lvlAnimalHandling,
                lvlArcana: lvlArcana,
                lvlAthletics: lvlAthletics,
                lvlDeception: lvlDeception,
                lvlHistory: lvlHistory,
                lvlInsight: lvlInsight,
                lvlIntimidation: lvlIntimidation,
                lvlInvestigation: lvlInvestigation,
                lvlMedicine: lvlMedicine,
                lvlNature: lvlNature,
                lvlPerception: lvlPerception,
                lvlPerformance: lvlPerformance,
                lvlPersuasion: lvlPersuasion,
                lvlReligion: lvlReligion,
                lvlSleightOfHand: lvlSleightOfHand,
                lvlStealth: lvlStealth,
                lvlSurvival: lvlSurvival,
                inspiration: inspiration,
                exhaustion: exhaustion,
                conditions: conditions,
                hitDiceUsed: hitDiceUsed,
                copperPieces: copperPieces,
                silverPieces: silverPieces,
                electrumPieces: electrumPieces,
                goldPieces: goldPieces,
                platinumPieces: platinumPieces,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> playerName = const Value.absent(),
                Value<String?> portraitPath = const Value.absent(),
                Value<String?> speciesId = const Value.absent(),
                Value<String?> backgroundId = const Value.absent(),
                Value<String?> customBackgroundName = const Value.absent(),
                Value<String> customBackgroundSkills = const Value.absent(),
                Value<String> customBackgroundFeatures = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> strength = const Value.absent(),
                Value<int> dexterity = const Value.absent(),
                Value<int> constitution = const Value.absent(),
                Value<int> intelligence = const Value.absent(),
                Value<int> wisdom = const Value.absent(),
                Value<int> charisma = const Value.absent(),
                Value<int> armorClass = const Value.absent(),
                Value<int> initiativeBonus = const Value.absent(),
                Value<int> speed = const Value.absent(),
                Value<double?> speedMeters = const Value.absent(),
                Value<int> maxHitPoints = const Value.absent(),
                Value<int> currentHitPoints = const Value.absent(),
                Value<int> temporaryHitPoints = const Value.absent(),
                Value<bool> saveStrength = const Value.absent(),
                Value<bool> saveDexterity = const Value.absent(),
                Value<bool> saveConstitution = const Value.absent(),
                Value<bool> saveIntelligence = const Value.absent(),
                Value<bool> saveWisdom = const Value.absent(),
                Value<bool> saveCharisma = const Value.absent(),
                Value<bool> skillAcrobatics = const Value.absent(),
                Value<bool> skillAnimalHandling = const Value.absent(),
                Value<bool> skillArcana = const Value.absent(),
                Value<bool> skillAthletics = const Value.absent(),
                Value<bool> skillDeception = const Value.absent(),
                Value<bool> skillHistory = const Value.absent(),
                Value<bool> skillInsight = const Value.absent(),
                Value<bool> skillIntimidation = const Value.absent(),
                Value<bool> skillInvestigation = const Value.absent(),
                Value<bool> skillMedicine = const Value.absent(),
                Value<bool> skillNature = const Value.absent(),
                Value<bool> skillPerception = const Value.absent(),
                Value<bool> skillPerformance = const Value.absent(),
                Value<bool> skillPersuasion = const Value.absent(),
                Value<bool> skillReligion = const Value.absent(),
                Value<bool> skillSleightOfHand = const Value.absent(),
                Value<bool> skillStealth = const Value.absent(),
                Value<bool> skillSurvival = const Value.absent(),
                Value<int> lvlAcrobatics = const Value.absent(),
                Value<int> lvlAnimalHandling = const Value.absent(),
                Value<int> lvlArcana = const Value.absent(),
                Value<int> lvlAthletics = const Value.absent(),
                Value<int> lvlDeception = const Value.absent(),
                Value<int> lvlHistory = const Value.absent(),
                Value<int> lvlInsight = const Value.absent(),
                Value<int> lvlIntimidation = const Value.absent(),
                Value<int> lvlInvestigation = const Value.absent(),
                Value<int> lvlMedicine = const Value.absent(),
                Value<int> lvlNature = const Value.absent(),
                Value<int> lvlPerception = const Value.absent(),
                Value<int> lvlPerformance = const Value.absent(),
                Value<int> lvlPersuasion = const Value.absent(),
                Value<int> lvlReligion = const Value.absent(),
                Value<int> lvlSleightOfHand = const Value.absent(),
                Value<int> lvlStealth = const Value.absent(),
                Value<int> lvlSurvival = const Value.absent(),
                Value<bool> inspiration = const Value.absent(),
                Value<int> exhaustion = const Value.absent(),
                Value<String> conditions = const Value.absent(),
                Value<int> hitDiceUsed = const Value.absent(),
                Value<int> copperPieces = const Value.absent(),
                Value<int> silverPieces = const Value.absent(),
                Value<int> electrumPieces = const Value.absent(),
                Value<int> goldPieces = const Value.absent(),
                Value<int> platinumPieces = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                name: name,
                playerName: playerName,
                portraitPath: portraitPath,
                speciesId: speciesId,
                backgroundId: backgroundId,
                customBackgroundName: customBackgroundName,
                customBackgroundSkills: customBackgroundSkills,
                customBackgroundFeatures: customBackgroundFeatures,
                notes: notes,
                strength: strength,
                dexterity: dexterity,
                constitution: constitution,
                intelligence: intelligence,
                wisdom: wisdom,
                charisma: charisma,
                armorClass: armorClass,
                initiativeBonus: initiativeBonus,
                speed: speed,
                speedMeters: speedMeters,
                maxHitPoints: maxHitPoints,
                currentHitPoints: currentHitPoints,
                temporaryHitPoints: temporaryHitPoints,
                saveStrength: saveStrength,
                saveDexterity: saveDexterity,
                saveConstitution: saveConstitution,
                saveIntelligence: saveIntelligence,
                saveWisdom: saveWisdom,
                saveCharisma: saveCharisma,
                skillAcrobatics: skillAcrobatics,
                skillAnimalHandling: skillAnimalHandling,
                skillArcana: skillArcana,
                skillAthletics: skillAthletics,
                skillDeception: skillDeception,
                skillHistory: skillHistory,
                skillInsight: skillInsight,
                skillIntimidation: skillIntimidation,
                skillInvestigation: skillInvestigation,
                skillMedicine: skillMedicine,
                skillNature: skillNature,
                skillPerception: skillPerception,
                skillPerformance: skillPerformance,
                skillPersuasion: skillPersuasion,
                skillReligion: skillReligion,
                skillSleightOfHand: skillSleightOfHand,
                skillStealth: skillStealth,
                skillSurvival: skillSurvival,
                lvlAcrobatics: lvlAcrobatics,
                lvlAnimalHandling: lvlAnimalHandling,
                lvlArcana: lvlArcana,
                lvlAthletics: lvlAthletics,
                lvlDeception: lvlDeception,
                lvlHistory: lvlHistory,
                lvlInsight: lvlInsight,
                lvlIntimidation: lvlIntimidation,
                lvlInvestigation: lvlInvestigation,
                lvlMedicine: lvlMedicine,
                lvlNature: lvlNature,
                lvlPerception: lvlPerception,
                lvlPerformance: lvlPerformance,
                lvlPersuasion: lvlPersuasion,
                lvlReligion: lvlReligion,
                lvlSleightOfHand: lvlSleightOfHand,
                lvlStealth: lvlStealth,
                lvlSurvival: lvlSurvival,
                inspiration: inspiration,
                exhaustion: exhaustion,
                conditions: conditions,
                hitDiceUsed: hitDiceUsed,
                copperPieces: copperPieces,
                silverPieces: silverPieces,
                electrumPieces: electrumPieces,
                goldPieces: goldPieces,
                platinumPieces: platinumPieces,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CharactersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            characterClassLevelsRefs = false,
            characterSpellsRefs = false,
            characterWeaponsRefs = false,
            characterMagicItemsRefs = false,
            characterSpellSlotsUsageRefs = false,
            characterFeatsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (characterClassLevelsRefs) db.characterClassLevels,
                if (characterSpellsRefs) db.characterSpells,
                if (characterWeaponsRefs) db.characterWeapons,
                if (characterMagicItemsRefs) db.characterMagicItems,
                if (characterSpellSlotsUsageRefs) db.characterSpellSlotsUsage,
                if (characterFeatsRefs) db.characterFeats,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (characterClassLevelsRefs)
                    await $_getPrefetchedData<
                      Character,
                      $CharactersTable,
                      CharacterClassLevel
                    >(
                      currentTable: table,
                      referencedTable: $$CharactersTableReferences
                          ._characterClassLevelsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).characterClassLevelsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.characterId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (characterSpellsRefs)
                    await $_getPrefetchedData<
                      Character,
                      $CharactersTable,
                      CharacterSpell
                    >(
                      currentTable: table,
                      referencedTable: $$CharactersTableReferences
                          ._characterSpellsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).characterSpellsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.characterId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (characterWeaponsRefs)
                    await $_getPrefetchedData<
                      Character,
                      $CharactersTable,
                      CharacterWeapon
                    >(
                      currentTable: table,
                      referencedTable: $$CharactersTableReferences
                          ._characterWeaponsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).characterWeaponsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.characterId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (characterMagicItemsRefs)
                    await $_getPrefetchedData<
                      Character,
                      $CharactersTable,
                      CharacterMagicItem
                    >(
                      currentTable: table,
                      referencedTable: $$CharactersTableReferences
                          ._characterMagicItemsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).characterMagicItemsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.characterId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (characterSpellSlotsUsageRefs)
                    await $_getPrefetchedData<
                      Character,
                      $CharactersTable,
                      CharacterSpellSlotsUsageData
                    >(
                      currentTable: table,
                      referencedTable: $$CharactersTableReferences
                          ._characterSpellSlotsUsageRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).characterSpellSlotsUsageRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.characterId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (characterFeatsRefs)
                    await $_getPrefetchedData<
                      Character,
                      $CharactersTable,
                      CharacterFeat
                    >(
                      currentTable: table,
                      referencedTable: $$CharactersTableReferences
                          ._characterFeatsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).characterFeatsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.characterId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharactersTable,
      Character,
      $$CharactersTableFilterComposer,
      $$CharactersTableOrderingComposer,
      $$CharactersTableAnnotationComposer,
      $$CharactersTableCreateCompanionBuilder,
      $$CharactersTableUpdateCompanionBuilder,
      (Character, $$CharactersTableReferences),
      Character,
      PrefetchHooks Function({
        bool characterClassLevelsRefs,
        bool characterSpellsRefs,
        bool characterWeaponsRefs,
        bool characterMagicItemsRefs,
        bool characterSpellSlotsUsageRefs,
        bool characterFeatsRefs,
      })
    >;
typedef $$CharacterClassLevelsTableCreateCompanionBuilder =
    CharacterClassLevelsCompanion Function({
      Value<int> localId,
      required String characterId,
      required String classId,
      Value<String?> subclassId,
      required int level,
      Value<String?> spellcastingAbility,
      Value<String?> spellcastingType,
    });
typedef $$CharacterClassLevelsTableUpdateCompanionBuilder =
    CharacterClassLevelsCompanion Function({
      Value<int> localId,
      Value<String> characterId,
      Value<String> classId,
      Value<String?> subclassId,
      Value<int> level,
      Value<String?> spellcastingAbility,
      Value<String?> spellcastingType,
    });

final class $$CharacterClassLevelsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CharacterClassLevelsTable,
          CharacterClassLevel
        > {
  $$CharacterClassLevelsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias(
        $_aliasNameGenerator(
          db.characterClassLevels.characterId,
          db.characters.id,
        ),
      );

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<String>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CharacterClassLevelsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterClassLevelsTable> {
  $$CharacterClassLevelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subclassId => $composableBuilder(
    column: $table.subclassId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spellcastingAbility => $composableBuilder(
    column: $table.spellcastingAbility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spellcastingType => $composableBuilder(
    column: $table.spellcastingType,
    builder: (column) => ColumnFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterClassLevelsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterClassLevelsTable> {
  $$CharacterClassLevelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subclassId => $composableBuilder(
    column: $table.subclassId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spellcastingAbility => $composableBuilder(
    column: $table.spellcastingAbility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spellcastingType => $composableBuilder(
    column: $table.spellcastingType,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterClassLevelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterClassLevelsTable> {
  $$CharacterClassLevelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get subclassId => $composableBuilder(
    column: $table.subclassId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get spellcastingAbility => $composableBuilder(
    column: $table.spellcastingAbility,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spellcastingType => $composableBuilder(
    column: $table.spellcastingType,
    builder: (column) => column,
  );

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterClassLevelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterClassLevelsTable,
          CharacterClassLevel,
          $$CharacterClassLevelsTableFilterComposer,
          $$CharacterClassLevelsTableOrderingComposer,
          $$CharacterClassLevelsTableAnnotationComposer,
          $$CharacterClassLevelsTableCreateCompanionBuilder,
          $$CharacterClassLevelsTableUpdateCompanionBuilder,
          (CharacterClassLevel, $$CharacterClassLevelsTableReferences),
          CharacterClassLevel,
          PrefetchHooks Function({bool characterId})
        > {
  $$CharacterClassLevelsTableTableManager(
    _$AppDatabase db,
    $CharacterClassLevelsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CharacterClassLevelsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$CharacterClassLevelsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CharacterClassLevelsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String?> subclassId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String?> spellcastingAbility = const Value.absent(),
                Value<String?> spellcastingType = const Value.absent(),
              }) => CharacterClassLevelsCompanion(
                localId: localId,
                characterId: characterId,
                classId: classId,
                subclassId: subclassId,
                level: level,
                spellcastingAbility: spellcastingAbility,
                spellcastingType: spellcastingType,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String characterId,
                required String classId,
                Value<String?> subclassId = const Value.absent(),
                required int level,
                Value<String?> spellcastingAbility = const Value.absent(),
                Value<String?> spellcastingType = const Value.absent(),
              }) => CharacterClassLevelsCompanion.insert(
                localId: localId,
                characterId: characterId,
                classId: classId,
                subclassId: subclassId,
                level: level,
                spellcastingAbility: spellcastingAbility,
                spellcastingType: spellcastingType,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CharacterClassLevelsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (characterId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.characterId,
                            referencedTable:
                                $$CharacterClassLevelsTableReferences
                                    ._characterIdTable(db),
                            referencedColumn:
                                $$CharacterClassLevelsTableReferences
                                    ._characterIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CharacterClassLevelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterClassLevelsTable,
      CharacterClassLevel,
      $$CharacterClassLevelsTableFilterComposer,
      $$CharacterClassLevelsTableOrderingComposer,
      $$CharacterClassLevelsTableAnnotationComposer,
      $$CharacterClassLevelsTableCreateCompanionBuilder,
      $$CharacterClassLevelsTableUpdateCompanionBuilder,
      (CharacterClassLevel, $$CharacterClassLevelsTableReferences),
      CharacterClassLevel,
      PrefetchHooks Function({bool characterId})
    >;
typedef $$CharacterSpellsTableCreateCompanionBuilder =
    CharacterSpellsCompanion Function({
      Value<int> localId,
      required String characterId,
      required int spellId,
      required String sourceType,
      required String sourceId,
      required String sourceName,
      Value<bool> isPrepared,
      Value<bool> isKnown,
      Value<bool> isAlwaysAvailable,
      Value<String> notes,
    });
typedef $$CharacterSpellsTableUpdateCompanionBuilder =
    CharacterSpellsCompanion Function({
      Value<int> localId,
      Value<String> characterId,
      Value<int> spellId,
      Value<String> sourceType,
      Value<String> sourceId,
      Value<String> sourceName,
      Value<bool> isPrepared,
      Value<bool> isKnown,
      Value<bool> isAlwaysAvailable,
      Value<String> notes,
    });

final class $$CharacterSpellsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CharacterSpellsTable, CharacterSpell> {
  $$CharacterSpellsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias(
        $_aliasNameGenerator(db.characterSpells.characterId, db.characters.id),
      );

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<String>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CharacterSpellsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterSpellsTable> {
  $$CharacterSpellsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spellId => $composableBuilder(
    column: $table.spellId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrepared => $composableBuilder(
    column: $table.isPrepared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isKnown => $composableBuilder(
    column: $table.isKnown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAlwaysAvailable => $composableBuilder(
    column: $table.isAlwaysAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSpellsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterSpellsTable> {
  $$CharacterSpellsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spellId => $composableBuilder(
    column: $table.spellId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrepared => $composableBuilder(
    column: $table.isPrepared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isKnown => $composableBuilder(
    column: $table.isKnown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAlwaysAvailable => $composableBuilder(
    column: $table.isAlwaysAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSpellsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterSpellsTable> {
  $$CharacterSpellsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get spellId =>
      $composableBuilder(column: $table.spellId, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrepared => $composableBuilder(
    column: $table.isPrepared,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isKnown =>
      $composableBuilder(column: $table.isKnown, builder: (column) => column);

  GeneratedColumn<bool> get isAlwaysAvailable => $composableBuilder(
    column: $table.isAlwaysAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSpellsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterSpellsTable,
          CharacterSpell,
          $$CharacterSpellsTableFilterComposer,
          $$CharacterSpellsTableOrderingComposer,
          $$CharacterSpellsTableAnnotationComposer,
          $$CharacterSpellsTableCreateCompanionBuilder,
          $$CharacterSpellsTableUpdateCompanionBuilder,
          (CharacterSpell, $$CharacterSpellsTableReferences),
          CharacterSpell,
          PrefetchHooks Function({bool characterId})
        > {
  $$CharacterSpellsTableTableManager(
    _$AppDatabase db,
    $CharacterSpellsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$CharacterSpellsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CharacterSpellsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CharacterSpellsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<int> spellId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<bool> isPrepared = const Value.absent(),
                Value<bool> isKnown = const Value.absent(),
                Value<bool> isAlwaysAvailable = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => CharacterSpellsCompanion(
                localId: localId,
                characterId: characterId,
                spellId: spellId,
                sourceType: sourceType,
                sourceId: sourceId,
                sourceName: sourceName,
                isPrepared: isPrepared,
                isKnown: isKnown,
                isAlwaysAvailable: isAlwaysAvailable,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String characterId,
                required int spellId,
                required String sourceType,
                required String sourceId,
                required String sourceName,
                Value<bool> isPrepared = const Value.absent(),
                Value<bool> isKnown = const Value.absent(),
                Value<bool> isAlwaysAvailable = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => CharacterSpellsCompanion.insert(
                localId: localId,
                characterId: characterId,
                spellId: spellId,
                sourceType: sourceType,
                sourceId: sourceId,
                sourceName: sourceName,
                isPrepared: isPrepared,
                isKnown: isKnown,
                isAlwaysAvailable: isAlwaysAvailable,
                notes: notes,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CharacterSpellsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (characterId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.characterId,
                            referencedTable: $$CharacterSpellsTableReferences
                                ._characterIdTable(db),
                            referencedColumn:
                                $$CharacterSpellsTableReferences
                                    ._characterIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CharacterSpellsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterSpellsTable,
      CharacterSpell,
      $$CharacterSpellsTableFilterComposer,
      $$CharacterSpellsTableOrderingComposer,
      $$CharacterSpellsTableAnnotationComposer,
      $$CharacterSpellsTableCreateCompanionBuilder,
      $$CharacterSpellsTableUpdateCompanionBuilder,
      (CharacterSpell, $$CharacterSpellsTableReferences),
      CharacterSpell,
      PrefetchHooks Function({bool characterId})
    >;
typedef $$CharacterWeaponsTableCreateCompanionBuilder =
    CharacterWeaponsCompanion Function({
      Value<int> localId,
      required String characterId,
      required String weaponId,
      Value<String?> name,
      Value<int> magicBonus,
      Value<String?> chosenAbility,
      Value<bool> twoHanded,
      Value<bool?> proficiencyOverride,
      Value<String> notes,
    });
typedef $$CharacterWeaponsTableUpdateCompanionBuilder =
    CharacterWeaponsCompanion Function({
      Value<int> localId,
      Value<String> characterId,
      Value<String> weaponId,
      Value<String?> name,
      Value<int> magicBonus,
      Value<String?> chosenAbility,
      Value<bool> twoHanded,
      Value<bool?> proficiencyOverride,
      Value<String> notes,
    });

final class $$CharacterWeaponsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CharacterWeaponsTable, CharacterWeapon> {
  $$CharacterWeaponsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias(
        $_aliasNameGenerator(db.characterWeapons.characterId, db.characters.id),
      );

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<String>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CharacterWeaponsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterWeaponsTable> {
  $$CharacterWeaponsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weaponId => $composableBuilder(
    column: $table.weaponId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get magicBonus => $composableBuilder(
    column: $table.magicBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chosenAbility => $composableBuilder(
    column: $table.chosenAbility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get twoHanded => $composableBuilder(
    column: $table.twoHanded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get proficiencyOverride => $composableBuilder(
    column: $table.proficiencyOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterWeaponsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterWeaponsTable> {
  $$CharacterWeaponsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weaponId => $composableBuilder(
    column: $table.weaponId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get magicBonus => $composableBuilder(
    column: $table.magicBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chosenAbility => $composableBuilder(
    column: $table.chosenAbility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get twoHanded => $composableBuilder(
    column: $table.twoHanded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get proficiencyOverride => $composableBuilder(
    column: $table.proficiencyOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterWeaponsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterWeaponsTable> {
  $$CharacterWeaponsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get weaponId =>
      $composableBuilder(column: $table.weaponId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get magicBonus => $composableBuilder(
    column: $table.magicBonus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chosenAbility => $composableBuilder(
    column: $table.chosenAbility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get twoHanded =>
      $composableBuilder(column: $table.twoHanded, builder: (column) => column);

  GeneratedColumn<bool> get proficiencyOverride => $composableBuilder(
    column: $table.proficiencyOverride,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterWeaponsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterWeaponsTable,
          CharacterWeapon,
          $$CharacterWeaponsTableFilterComposer,
          $$CharacterWeaponsTableOrderingComposer,
          $$CharacterWeaponsTableAnnotationComposer,
          $$CharacterWeaponsTableCreateCompanionBuilder,
          $$CharacterWeaponsTableUpdateCompanionBuilder,
          (CharacterWeapon, $$CharacterWeaponsTableReferences),
          CharacterWeapon,
          PrefetchHooks Function({bool characterId})
        > {
  $$CharacterWeaponsTableTableManager(
    _$AppDatabase db,
    $CharacterWeaponsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$CharacterWeaponsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CharacterWeaponsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CharacterWeaponsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<String> weaponId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int> magicBonus = const Value.absent(),
                Value<String?> chosenAbility = const Value.absent(),
                Value<bool> twoHanded = const Value.absent(),
                Value<bool?> proficiencyOverride = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => CharacterWeaponsCompanion(
                localId: localId,
                characterId: characterId,
                weaponId: weaponId,
                name: name,
                magicBonus: magicBonus,
                chosenAbility: chosenAbility,
                twoHanded: twoHanded,
                proficiencyOverride: proficiencyOverride,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String characterId,
                required String weaponId,
                Value<String?> name = const Value.absent(),
                Value<int> magicBonus = const Value.absent(),
                Value<String?> chosenAbility = const Value.absent(),
                Value<bool> twoHanded = const Value.absent(),
                Value<bool?> proficiencyOverride = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => CharacterWeaponsCompanion.insert(
                localId: localId,
                characterId: characterId,
                weaponId: weaponId,
                name: name,
                magicBonus: magicBonus,
                chosenAbility: chosenAbility,
                twoHanded: twoHanded,
                proficiencyOverride: proficiencyOverride,
                notes: notes,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CharacterWeaponsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (characterId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.characterId,
                            referencedTable: $$CharacterWeaponsTableReferences
                                ._characterIdTable(db),
                            referencedColumn:
                                $$CharacterWeaponsTableReferences
                                    ._characterIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CharacterWeaponsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterWeaponsTable,
      CharacterWeapon,
      $$CharacterWeaponsTableFilterComposer,
      $$CharacterWeaponsTableOrderingComposer,
      $$CharacterWeaponsTableAnnotationComposer,
      $$CharacterWeaponsTableCreateCompanionBuilder,
      $$CharacterWeaponsTableUpdateCompanionBuilder,
      (CharacterWeapon, $$CharacterWeaponsTableReferences),
      CharacterWeapon,
      PrefetchHooks Function({bool characterId})
    >;
typedef $$CharacterMagicItemsTableCreateCompanionBuilder =
    CharacterMagicItemsCompanion Function({
      Value<int> localId,
      required String characterId,
      required String name,
      Value<String> description,
      Value<int?> charges,
      Value<int?> maxCharges,
      Value<String?> rechargeRule,
      Value<String?> castingAbility,
      Value<int?> saveDc,
      Value<int?> attackBonus,
      Value<int> weaponAttackBonus,
      Value<int> weaponDamageBonus,
      Value<int> spellAttackBonus,
      Value<int> spellSaveDcBonus,
    });
typedef $$CharacterMagicItemsTableUpdateCompanionBuilder =
    CharacterMagicItemsCompanion Function({
      Value<int> localId,
      Value<String> characterId,
      Value<String> name,
      Value<String> description,
      Value<int?> charges,
      Value<int?> maxCharges,
      Value<String?> rechargeRule,
      Value<String?> castingAbility,
      Value<int?> saveDc,
      Value<int?> attackBonus,
      Value<int> weaponAttackBonus,
      Value<int> weaponDamageBonus,
      Value<int> spellAttackBonus,
      Value<int> spellSaveDcBonus,
    });

final class $$CharacterMagicItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CharacterMagicItemsTable,
          CharacterMagicItem
        > {
  $$CharacterMagicItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias(
        $_aliasNameGenerator(
          db.characterMagicItems.characterId,
          db.characters.id,
        ),
      );

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<String>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CharacterMagicItemSpellsTable,
    List<CharacterMagicItemSpell>
  >
  _characterMagicItemSpellsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.characterMagicItemSpells,
        aliasName: $_aliasNameGenerator(
          db.characterMagicItems.localId,
          db.characterMagicItemSpells.magicItemId,
        ),
      );

  $$CharacterMagicItemSpellsTableProcessedTableManager
  get characterMagicItemSpellsRefs {
    final manager = $$CharacterMagicItemSpellsTableTableManager(
      $_db,
      $_db.characterMagicItemSpells,
    ).filter(
      (f) => f.magicItemId.localId.sqlEquals($_itemColumn<int>('local_id')!),
    );

    final cache = $_typedResult.readTableOrNull(
      _characterMagicItemSpellsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CharacterMagicItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterMagicItemsTable> {
  $$CharacterMagicItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charges => $composableBuilder(
    column: $table.charges,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxCharges => $composableBuilder(
    column: $table.maxCharges,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rechargeRule => $composableBuilder(
    column: $table.rechargeRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get castingAbility => $composableBuilder(
    column: $table.castingAbility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get saveDc => $composableBuilder(
    column: $table.saveDc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attackBonus => $composableBuilder(
    column: $table.attackBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weaponAttackBonus => $composableBuilder(
    column: $table.weaponAttackBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weaponDamageBonus => $composableBuilder(
    column: $table.weaponDamageBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spellAttackBonus => $composableBuilder(
    column: $table.spellAttackBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spellSaveDcBonus => $composableBuilder(
    column: $table.spellSaveDcBonus,
    builder: (column) => ColumnFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> characterMagicItemSpellsRefs(
    Expression<bool> Function($$CharacterMagicItemSpellsTableFilterComposer f)
    f,
  ) {
    final $$CharacterMagicItemSpellsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.localId,
          referencedTable: $db.characterMagicItemSpells,
          getReferencedColumn: (t) => t.magicItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacterMagicItemSpellsTableFilterComposer(
                $db: $db,
                $table: $db.characterMagicItemSpells,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CharacterMagicItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterMagicItemsTable> {
  $$CharacterMagicItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charges => $composableBuilder(
    column: $table.charges,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxCharges => $composableBuilder(
    column: $table.maxCharges,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rechargeRule => $composableBuilder(
    column: $table.rechargeRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get castingAbility => $composableBuilder(
    column: $table.castingAbility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saveDc => $composableBuilder(
    column: $table.saveDc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attackBonus => $composableBuilder(
    column: $table.attackBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weaponAttackBonus => $composableBuilder(
    column: $table.weaponAttackBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weaponDamageBonus => $composableBuilder(
    column: $table.weaponDamageBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spellAttackBonus => $composableBuilder(
    column: $table.spellAttackBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spellSaveDcBonus => $composableBuilder(
    column: $table.spellSaveDcBonus,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterMagicItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterMagicItemsTable> {
  $$CharacterMagicItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get charges =>
      $composableBuilder(column: $table.charges, builder: (column) => column);

  GeneratedColumn<int> get maxCharges => $composableBuilder(
    column: $table.maxCharges,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rechargeRule => $composableBuilder(
    column: $table.rechargeRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get castingAbility => $composableBuilder(
    column: $table.castingAbility,
    builder: (column) => column,
  );

  GeneratedColumn<int> get saveDc =>
      $composableBuilder(column: $table.saveDc, builder: (column) => column);

  GeneratedColumn<int> get attackBonus => $composableBuilder(
    column: $table.attackBonus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weaponAttackBonus => $composableBuilder(
    column: $table.weaponAttackBonus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weaponDamageBonus => $composableBuilder(
    column: $table.weaponDamageBonus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get spellAttackBonus => $composableBuilder(
    column: $table.spellAttackBonus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get spellSaveDcBonus => $composableBuilder(
    column: $table.spellSaveDcBonus,
    builder: (column) => column,
  );

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> characterMagicItemSpellsRefs<T extends Object>(
    Expression<T> Function($$CharacterMagicItemSpellsTableAnnotationComposer a)
    f,
  ) {
    final $$CharacterMagicItemSpellsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.localId,
          referencedTable: $db.characterMagicItemSpells,
          getReferencedColumn: (t) => t.magicItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacterMagicItemSpellsTableAnnotationComposer(
                $db: $db,
                $table: $db.characterMagicItemSpells,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CharacterMagicItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterMagicItemsTable,
          CharacterMagicItem,
          $$CharacterMagicItemsTableFilterComposer,
          $$CharacterMagicItemsTableOrderingComposer,
          $$CharacterMagicItemsTableAnnotationComposer,
          $$CharacterMagicItemsTableCreateCompanionBuilder,
          $$CharacterMagicItemsTableUpdateCompanionBuilder,
          (CharacterMagicItem, $$CharacterMagicItemsTableReferences),
          CharacterMagicItem,
          PrefetchHooks Function({
            bool characterId,
            bool characterMagicItemSpellsRefs,
          })
        > {
  $$CharacterMagicItemsTableTableManager(
    _$AppDatabase db,
    $CharacterMagicItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CharacterMagicItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$CharacterMagicItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CharacterMagicItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int?> charges = const Value.absent(),
                Value<int?> maxCharges = const Value.absent(),
                Value<String?> rechargeRule = const Value.absent(),
                Value<String?> castingAbility = const Value.absent(),
                Value<int?> saveDc = const Value.absent(),
                Value<int?> attackBonus = const Value.absent(),
                Value<int> weaponAttackBonus = const Value.absent(),
                Value<int> weaponDamageBonus = const Value.absent(),
                Value<int> spellAttackBonus = const Value.absent(),
                Value<int> spellSaveDcBonus = const Value.absent(),
              }) => CharacterMagicItemsCompanion(
                localId: localId,
                characterId: characterId,
                name: name,
                description: description,
                charges: charges,
                maxCharges: maxCharges,
                rechargeRule: rechargeRule,
                castingAbility: castingAbility,
                saveDc: saveDc,
                attackBonus: attackBonus,
                weaponAttackBonus: weaponAttackBonus,
                weaponDamageBonus: weaponDamageBonus,
                spellAttackBonus: spellAttackBonus,
                spellSaveDcBonus: spellSaveDcBonus,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String characterId,
                required String name,
                Value<String> description = const Value.absent(),
                Value<int?> charges = const Value.absent(),
                Value<int?> maxCharges = const Value.absent(),
                Value<String?> rechargeRule = const Value.absent(),
                Value<String?> castingAbility = const Value.absent(),
                Value<int?> saveDc = const Value.absent(),
                Value<int?> attackBonus = const Value.absent(),
                Value<int> weaponAttackBonus = const Value.absent(),
                Value<int> weaponDamageBonus = const Value.absent(),
                Value<int> spellAttackBonus = const Value.absent(),
                Value<int> spellSaveDcBonus = const Value.absent(),
              }) => CharacterMagicItemsCompanion.insert(
                localId: localId,
                characterId: characterId,
                name: name,
                description: description,
                charges: charges,
                maxCharges: maxCharges,
                rechargeRule: rechargeRule,
                castingAbility: castingAbility,
                saveDc: saveDc,
                attackBonus: attackBonus,
                weaponAttackBonus: weaponAttackBonus,
                weaponDamageBonus: weaponDamageBonus,
                spellAttackBonus: spellAttackBonus,
                spellSaveDcBonus: spellSaveDcBonus,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CharacterMagicItemsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            characterId = false,
            characterMagicItemSpellsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (characterMagicItemSpellsRefs) db.characterMagicItemSpells,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (characterId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.characterId,
                            referencedTable:
                                $$CharacterMagicItemsTableReferences
                                    ._characterIdTable(db),
                            referencedColumn:
                                $$CharacterMagicItemsTableReferences
                                    ._characterIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (characterMagicItemSpellsRefs)
                    await $_getPrefetchedData<
                      CharacterMagicItem,
                      $CharacterMagicItemsTable,
                      CharacterMagicItemSpell
                    >(
                      currentTable: table,
                      referencedTable: $$CharacterMagicItemsTableReferences
                          ._characterMagicItemSpellsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CharacterMagicItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).characterMagicItemSpellsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.magicItemId == item.localId,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CharacterMagicItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterMagicItemsTable,
      CharacterMagicItem,
      $$CharacterMagicItemsTableFilterComposer,
      $$CharacterMagicItemsTableOrderingComposer,
      $$CharacterMagicItemsTableAnnotationComposer,
      $$CharacterMagicItemsTableCreateCompanionBuilder,
      $$CharacterMagicItemsTableUpdateCompanionBuilder,
      (CharacterMagicItem, $$CharacterMagicItemsTableReferences),
      CharacterMagicItem,
      PrefetchHooks Function({
        bool characterId,
        bool characterMagicItemSpellsRefs,
      })
    >;
typedef $$CharacterMagicItemSpellsTableCreateCompanionBuilder =
    CharacterMagicItemSpellsCompanion Function({
      Value<int> localId,
      required int magicItemId,
      required int spellId,
      Value<bool> usesCharges,
      Value<int> chargeCost,
      Value<bool> isAtWill,
      Value<bool> isAlwaysAvailable,
    });
typedef $$CharacterMagicItemSpellsTableUpdateCompanionBuilder =
    CharacterMagicItemSpellsCompanion Function({
      Value<int> localId,
      Value<int> magicItemId,
      Value<int> spellId,
      Value<bool> usesCharges,
      Value<int> chargeCost,
      Value<bool> isAtWill,
      Value<bool> isAlwaysAvailable,
    });

final class $$CharacterMagicItemSpellsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CharacterMagicItemSpellsTable,
          CharacterMagicItemSpell
        > {
  $$CharacterMagicItemSpellsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharacterMagicItemsTable _magicItemIdTable(_$AppDatabase db) =>
      db.characterMagicItems.createAlias(
        $_aliasNameGenerator(
          db.characterMagicItemSpells.magicItemId,
          db.characterMagicItems.localId,
        ),
      );

  $$CharacterMagicItemsTableProcessedTableManager get magicItemId {
    final $_column = $_itemColumn<int>('magic_item_id')!;

    final manager = $$CharacterMagicItemsTableTableManager(
      $_db,
      $_db.characterMagicItems,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_magicItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CharacterMagicItemSpellsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterMagicItemSpellsTable> {
  $$CharacterMagicItemSpellsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spellId => $composableBuilder(
    column: $table.spellId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get usesCharges => $composableBuilder(
    column: $table.usesCharges,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chargeCost => $composableBuilder(
    column: $table.chargeCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAtWill => $composableBuilder(
    column: $table.isAtWill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAlwaysAvailable => $composableBuilder(
    column: $table.isAlwaysAvailable,
    builder: (column) => ColumnFilters(column),
  );

  $$CharacterMagicItemsTableFilterComposer get magicItemId {
    final $$CharacterMagicItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.magicItemId,
      referencedTable: $db.characterMagicItems,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterMagicItemsTableFilterComposer(
            $db: $db,
            $table: $db.characterMagicItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterMagicItemSpellsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterMagicItemSpellsTable> {
  $$CharacterMagicItemSpellsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spellId => $composableBuilder(
    column: $table.spellId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usesCharges => $composableBuilder(
    column: $table.usesCharges,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chargeCost => $composableBuilder(
    column: $table.chargeCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAtWill => $composableBuilder(
    column: $table.isAtWill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAlwaysAvailable => $composableBuilder(
    column: $table.isAlwaysAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharacterMagicItemsTableOrderingComposer get magicItemId {
    final $$CharacterMagicItemsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.magicItemId,
          referencedTable: $db.characterMagicItems,
          getReferencedColumn: (t) => t.localId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacterMagicItemsTableOrderingComposer(
                $db: $db,
                $table: $db.characterMagicItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CharacterMagicItemSpellsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterMagicItemSpellsTable> {
  $$CharacterMagicItemSpellsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get spellId =>
      $composableBuilder(column: $table.spellId, builder: (column) => column);

  GeneratedColumn<bool> get usesCharges => $composableBuilder(
    column: $table.usesCharges,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chargeCost => $composableBuilder(
    column: $table.chargeCost,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAtWill =>
      $composableBuilder(column: $table.isAtWill, builder: (column) => column);

  GeneratedColumn<bool> get isAlwaysAvailable => $composableBuilder(
    column: $table.isAlwaysAvailable,
    builder: (column) => column,
  );

  $$CharacterMagicItemsTableAnnotationComposer get magicItemId {
    final $$CharacterMagicItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.magicItemId,
          referencedTable: $db.characterMagicItems,
          getReferencedColumn: (t) => t.localId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacterMagicItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.characterMagicItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CharacterMagicItemSpellsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterMagicItemSpellsTable,
          CharacterMagicItemSpell,
          $$CharacterMagicItemSpellsTableFilterComposer,
          $$CharacterMagicItemSpellsTableOrderingComposer,
          $$CharacterMagicItemSpellsTableAnnotationComposer,
          $$CharacterMagicItemSpellsTableCreateCompanionBuilder,
          $$CharacterMagicItemSpellsTableUpdateCompanionBuilder,
          (CharacterMagicItemSpell, $$CharacterMagicItemSpellsTableReferences),
          CharacterMagicItemSpell,
          PrefetchHooks Function({bool magicItemId})
        > {
  $$CharacterMagicItemSpellsTableTableManager(
    _$AppDatabase db,
    $CharacterMagicItemSpellsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CharacterMagicItemSpellsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$CharacterMagicItemSpellsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CharacterMagicItemSpellsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int> magicItemId = const Value.absent(),
                Value<int> spellId = const Value.absent(),
                Value<bool> usesCharges = const Value.absent(),
                Value<int> chargeCost = const Value.absent(),
                Value<bool> isAtWill = const Value.absent(),
                Value<bool> isAlwaysAvailable = const Value.absent(),
              }) => CharacterMagicItemSpellsCompanion(
                localId: localId,
                magicItemId: magicItemId,
                spellId: spellId,
                usesCharges: usesCharges,
                chargeCost: chargeCost,
                isAtWill: isAtWill,
                isAlwaysAvailable: isAlwaysAvailable,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required int magicItemId,
                required int spellId,
                Value<bool> usesCharges = const Value.absent(),
                Value<int> chargeCost = const Value.absent(),
                Value<bool> isAtWill = const Value.absent(),
                Value<bool> isAlwaysAvailable = const Value.absent(),
              }) => CharacterMagicItemSpellsCompanion.insert(
                localId: localId,
                magicItemId: magicItemId,
                spellId: spellId,
                usesCharges: usesCharges,
                chargeCost: chargeCost,
                isAtWill: isAtWill,
                isAlwaysAvailable: isAlwaysAvailable,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CharacterMagicItemSpellsTableReferences(
                            db,
                            table,
                            e,
                          ),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({magicItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (magicItemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.magicItemId,
                            referencedTable:
                                $$CharacterMagicItemSpellsTableReferences
                                    ._magicItemIdTable(db),
                            referencedColumn:
                                $$CharacterMagicItemSpellsTableReferences
                                    ._magicItemIdTable(db)
                                    .localId,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CharacterMagicItemSpellsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterMagicItemSpellsTable,
      CharacterMagicItemSpell,
      $$CharacterMagicItemSpellsTableFilterComposer,
      $$CharacterMagicItemSpellsTableOrderingComposer,
      $$CharacterMagicItemSpellsTableAnnotationComposer,
      $$CharacterMagicItemSpellsTableCreateCompanionBuilder,
      $$CharacterMagicItemSpellsTableUpdateCompanionBuilder,
      (CharacterMagicItemSpell, $$CharacterMagicItemSpellsTableReferences),
      CharacterMagicItemSpell,
      PrefetchHooks Function({bool magicItemId})
    >;
typedef $$CharacterSpellSlotsUsageTableCreateCompanionBuilder =
    CharacterSpellSlotsUsageCompanion Function({
      Value<int> localId,
      required String characterId,
      required int slotLevel,
      Value<int> used,
    });
typedef $$CharacterSpellSlotsUsageTableUpdateCompanionBuilder =
    CharacterSpellSlotsUsageCompanion Function({
      Value<int> localId,
      Value<String> characterId,
      Value<int> slotLevel,
      Value<int> used,
    });

final class $$CharacterSpellSlotsUsageTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CharacterSpellSlotsUsageTable,
          CharacterSpellSlotsUsageData
        > {
  $$CharacterSpellSlotsUsageTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias(
        $_aliasNameGenerator(
          db.characterSpellSlotsUsage.characterId,
          db.characters.id,
        ),
      );

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<String>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CharacterSpellSlotsUsageTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterSpellSlotsUsageTable> {
  $$CharacterSpellSlotsUsageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotLevel => $composableBuilder(
    column: $table.slotLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get used => $composableBuilder(
    column: $table.used,
    builder: (column) => ColumnFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSpellSlotsUsageTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterSpellSlotsUsageTable> {
  $$CharacterSpellSlotsUsageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotLevel => $composableBuilder(
    column: $table.slotLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get used => $composableBuilder(
    column: $table.used,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSpellSlotsUsageTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterSpellSlotsUsageTable> {
  $$CharacterSpellSlotsUsageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get slotLevel =>
      $composableBuilder(column: $table.slotLevel, builder: (column) => column);

  GeneratedColumn<int> get used =>
      $composableBuilder(column: $table.used, builder: (column) => column);

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSpellSlotsUsageTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterSpellSlotsUsageTable,
          CharacterSpellSlotsUsageData,
          $$CharacterSpellSlotsUsageTableFilterComposer,
          $$CharacterSpellSlotsUsageTableOrderingComposer,
          $$CharacterSpellSlotsUsageTableAnnotationComposer,
          $$CharacterSpellSlotsUsageTableCreateCompanionBuilder,
          $$CharacterSpellSlotsUsageTableUpdateCompanionBuilder,
          (
            CharacterSpellSlotsUsageData,
            $$CharacterSpellSlotsUsageTableReferences,
          ),
          CharacterSpellSlotsUsageData,
          PrefetchHooks Function({bool characterId})
        > {
  $$CharacterSpellSlotsUsageTableTableManager(
    _$AppDatabase db,
    $CharacterSpellSlotsUsageTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CharacterSpellSlotsUsageTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$CharacterSpellSlotsUsageTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CharacterSpellSlotsUsageTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<int> slotLevel = const Value.absent(),
                Value<int> used = const Value.absent(),
              }) => CharacterSpellSlotsUsageCompanion(
                localId: localId,
                characterId: characterId,
                slotLevel: slotLevel,
                used: used,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String characterId,
                required int slotLevel,
                Value<int> used = const Value.absent(),
              }) => CharacterSpellSlotsUsageCompanion.insert(
                localId: localId,
                characterId: characterId,
                slotLevel: slotLevel,
                used: used,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CharacterSpellSlotsUsageTableReferences(
                            db,
                            table,
                            e,
                          ),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (characterId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.characterId,
                            referencedTable:
                                $$CharacterSpellSlotsUsageTableReferences
                                    ._characterIdTable(db),
                            referencedColumn:
                                $$CharacterSpellSlotsUsageTableReferences
                                    ._characterIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CharacterSpellSlotsUsageTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterSpellSlotsUsageTable,
      CharacterSpellSlotsUsageData,
      $$CharacterSpellSlotsUsageTableFilterComposer,
      $$CharacterSpellSlotsUsageTableOrderingComposer,
      $$CharacterSpellSlotsUsageTableAnnotationComposer,
      $$CharacterSpellSlotsUsageTableCreateCompanionBuilder,
      $$CharacterSpellSlotsUsageTableUpdateCompanionBuilder,
      (CharacterSpellSlotsUsageData, $$CharacterSpellSlotsUsageTableReferences),
      CharacterSpellSlotsUsageData,
      PrefetchHooks Function({bool characterId})
    >;
typedef $$CharacterFeatsTableCreateCompanionBuilder =
    CharacterFeatsCompanion Function({
      Value<int> localId,
      required String characterId,
      required String featId,
      Value<String?> classId,
      Value<int?> level,
      Value<String> chosenSkills,
      Value<String> grantedSkills,
      Value<String?> chosenAbility,
      Value<String> appliedAbilityIncreases,
    });
typedef $$CharacterFeatsTableUpdateCompanionBuilder =
    CharacterFeatsCompanion Function({
      Value<int> localId,
      Value<String> characterId,
      Value<String> featId,
      Value<String?> classId,
      Value<int?> level,
      Value<String> chosenSkills,
      Value<String> grantedSkills,
      Value<String?> chosenAbility,
      Value<String> appliedAbilityIncreases,
    });

final class $$CharacterFeatsTableReferences
    extends BaseReferences<_$AppDatabase, $CharacterFeatsTable, CharacterFeat> {
  $$CharacterFeatsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias(
        $_aliasNameGenerator(db.characterFeats.characterId, db.characters.id),
      );

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<String>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CharacterFeatsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterFeatsTable> {
  $$CharacterFeatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get featId => $composableBuilder(
    column: $table.featId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chosenSkills => $composableBuilder(
    column: $table.chosenSkills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grantedSkills => $composableBuilder(
    column: $table.grantedSkills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chosenAbility => $composableBuilder(
    column: $table.chosenAbility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliedAbilityIncreases => $composableBuilder(
    column: $table.appliedAbilityIncreases,
    builder: (column) => ColumnFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterFeatsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterFeatsTable> {
  $$CharacterFeatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get featId => $composableBuilder(
    column: $table.featId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chosenSkills => $composableBuilder(
    column: $table.chosenSkills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grantedSkills => $composableBuilder(
    column: $table.grantedSkills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chosenAbility => $composableBuilder(
    column: $table.chosenAbility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliedAbilityIncreases => $composableBuilder(
    column: $table.appliedAbilityIncreases,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterFeatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterFeatsTable> {
  $$CharacterFeatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get featId =>
      $composableBuilder(column: $table.featId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get chosenSkills => $composableBuilder(
    column: $table.chosenSkills,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grantedSkills => $composableBuilder(
    column: $table.grantedSkills,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chosenAbility => $composableBuilder(
    column: $table.chosenAbility,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appliedAbilityIncreases => $composableBuilder(
    column: $table.appliedAbilityIncreases,
    builder: (column) => column,
  );

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterFeatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterFeatsTable,
          CharacterFeat,
          $$CharacterFeatsTableFilterComposer,
          $$CharacterFeatsTableOrderingComposer,
          $$CharacterFeatsTableAnnotationComposer,
          $$CharacterFeatsTableCreateCompanionBuilder,
          $$CharacterFeatsTableUpdateCompanionBuilder,
          (CharacterFeat, $$CharacterFeatsTableReferences),
          CharacterFeat,
          PrefetchHooks Function({bool characterId})
        > {
  $$CharacterFeatsTableTableManager(
    _$AppDatabase db,
    $CharacterFeatsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CharacterFeatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$CharacterFeatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CharacterFeatsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<String> featId = const Value.absent(),
                Value<String?> classId = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<String> chosenSkills = const Value.absent(),
                Value<String> grantedSkills = const Value.absent(),
                Value<String?> chosenAbility = const Value.absent(),
                Value<String> appliedAbilityIncreases = const Value.absent(),
              }) => CharacterFeatsCompanion(
                localId: localId,
                characterId: characterId,
                featId: featId,
                classId: classId,
                level: level,
                chosenSkills: chosenSkills,
                grantedSkills: grantedSkills,
                chosenAbility: chosenAbility,
                appliedAbilityIncreases: appliedAbilityIncreases,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String characterId,
                required String featId,
                Value<String?> classId = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<String> chosenSkills = const Value.absent(),
                Value<String> grantedSkills = const Value.absent(),
                Value<String?> chosenAbility = const Value.absent(),
                Value<String> appliedAbilityIncreases = const Value.absent(),
              }) => CharacterFeatsCompanion.insert(
                localId: localId,
                characterId: characterId,
                featId: featId,
                classId: classId,
                level: level,
                chosenSkills: chosenSkills,
                grantedSkills: grantedSkills,
                chosenAbility: chosenAbility,
                appliedAbilityIncreases: appliedAbilityIncreases,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CharacterFeatsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (characterId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.characterId,
                            referencedTable: $$CharacterFeatsTableReferences
                                ._characterIdTable(db),
                            referencedColumn:
                                $$CharacterFeatsTableReferences
                                    ._characterIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CharacterFeatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterFeatsTable,
      CharacterFeat,
      $$CharacterFeatsTableFilterComposer,
      $$CharacterFeatsTableOrderingComposer,
      $$CharacterFeatsTableAnnotationComposer,
      $$CharacterFeatsTableCreateCompanionBuilder,
      $$CharacterFeatsTableUpdateCompanionBuilder,
      (CharacterFeat, $$CharacterFeatsTableReferences),
      CharacterFeat,
      PrefetchHooks Function({bool characterId})
    >;
typedef $$ClassEntriesTableCreateCompanionBuilder =
    ClassEntriesCompanion Function({
      required String id,
      required String name,
      required String hitDie,
      Value<String?> primaryAbility,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$ClassEntriesTableUpdateCompanionBuilder =
    ClassEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> hitDie,
      Value<String?> primaryAbility,
      Value<String> source,
      Value<int> rowid,
    });

class $$ClassEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ClassEntriesTable> {
  $$ClassEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hitDie => $composableBuilder(
    column: $table.hitDie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryAbility => $composableBuilder(
    column: $table.primaryAbility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClassEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassEntriesTable> {
  $$ClassEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hitDie => $composableBuilder(
    column: $table.hitDie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryAbility => $composableBuilder(
    column: $table.primaryAbility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClassEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassEntriesTable> {
  $$ClassEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get hitDie =>
      $composableBuilder(column: $table.hitDie, builder: (column) => column);

  GeneratedColumn<String> get primaryAbility => $composableBuilder(
    column: $table.primaryAbility,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$ClassEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClassEntriesTable,
          ClassEntry,
          $$ClassEntriesTableFilterComposer,
          $$ClassEntriesTableOrderingComposer,
          $$ClassEntriesTableAnnotationComposer,
          $$ClassEntriesTableCreateCompanionBuilder,
          $$ClassEntriesTableUpdateCompanionBuilder,
          (
            ClassEntry,
            BaseReferences<_$AppDatabase, $ClassEntriesTable, ClassEntry>,
          ),
          ClassEntry,
          PrefetchHooks Function()
        > {
  $$ClassEntriesTableTableManager(_$AppDatabase db, $ClassEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ClassEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ClassEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$ClassEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> hitDie = const Value.absent(),
                Value<String?> primaryAbility = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassEntriesCompanion(
                id: id,
                name: name,
                hitDie: hitDie,
                primaryAbility: primaryAbility,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String hitDie,
                Value<String?> primaryAbility = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassEntriesCompanion.insert(
                id: id,
                name: name,
                hitDie: hitDie,
                primaryAbility: primaryAbility,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClassEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClassEntriesTable,
      ClassEntry,
      $$ClassEntriesTableFilterComposer,
      $$ClassEntriesTableOrderingComposer,
      $$ClassEntriesTableAnnotationComposer,
      $$ClassEntriesTableCreateCompanionBuilder,
      $$ClassEntriesTableUpdateCompanionBuilder,
      (
        ClassEntry,
        BaseReferences<_$AppDatabase, $ClassEntriesTable, ClassEntry>,
      ),
      ClassEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
  $$CharacterClassLevelsTableTableManager get characterClassLevels =>
      $$CharacterClassLevelsTableTableManager(_db, _db.characterClassLevels);
  $$CharacterSpellsTableTableManager get characterSpells =>
      $$CharacterSpellsTableTableManager(_db, _db.characterSpells);
  $$CharacterWeaponsTableTableManager get characterWeapons =>
      $$CharacterWeaponsTableTableManager(_db, _db.characterWeapons);
  $$CharacterMagicItemsTableTableManager get characterMagicItems =>
      $$CharacterMagicItemsTableTableManager(_db, _db.characterMagicItems);
  $$CharacterMagicItemSpellsTableTableManager get characterMagicItemSpells =>
      $$CharacterMagicItemSpellsTableTableManager(
        _db,
        _db.characterMagicItemSpells,
      );
  $$CharacterSpellSlotsUsageTableTableManager get characterSpellSlotsUsage =>
      $$CharacterSpellSlotsUsageTableTableManager(
        _db,
        _db.characterSpellSlotsUsage,
      );
  $$CharacterFeatsTableTableManager get characterFeats =>
      $$CharacterFeatsTableTableManager(_db, _db.characterFeats);
  $$ClassEntriesTableTableManager get classEntries =>
      $$ClassEntriesTableTableManager(_db, _db.classEntries);
}
