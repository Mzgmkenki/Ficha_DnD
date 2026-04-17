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
    speciesId,
    backgroundId,
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
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_id'],
      ),
      backgroundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}background_id'],
      ),
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
  final String? speciesId;
  final String? backgroundId;
  final String notes;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final int armorClass;
  final int initiativeBonus;
  final int speed;
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
  final DateTime createdAt;
  final DateTime updatedAt;
  const Character({
    required this.id,
    required this.name,
    this.playerName,
    this.speciesId,
    this.backgroundId,
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
    if (!nullToAbsent || speciesId != null) {
      map['species_id'] = Variable<String>(speciesId);
    }
    if (!nullToAbsent || backgroundId != null) {
      map['background_id'] = Variable<String>(backgroundId);
    }
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
      speciesId:
          speciesId == null && nullToAbsent
              ? const Value.absent()
              : Value(speciesId),
      backgroundId:
          backgroundId == null && nullToAbsent
              ? const Value.absent()
              : Value(backgroundId),
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
      speciesId: serializer.fromJson<String?>(json['speciesId']),
      backgroundId: serializer.fromJson<String?>(json['backgroundId']),
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
      'speciesId': serializer.toJson<String?>(speciesId),
      'backgroundId': serializer.toJson<String?>(backgroundId),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Character copyWith({
    String? id,
    String? name,
    Value<String?> playerName = const Value.absent(),
    Value<String?> speciesId = const Value.absent(),
    Value<String?> backgroundId = const Value.absent(),
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Character(
    id: id ?? this.id,
    name: name ?? this.name,
    playerName: playerName.present ? playerName.value : this.playerName,
    speciesId: speciesId.present ? speciesId.value : this.speciesId,
    backgroundId: backgroundId.present ? backgroundId.value : this.backgroundId,
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
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Character copyWithCompanion(CharactersCompanion data) {
    return Character(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      playerName:
          data.playerName.present ? data.playerName.value : this.playerName,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      backgroundId:
          data.backgroundId.present
              ? data.backgroundId.value
              : this.backgroundId,
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
          ..write('speciesId: $speciesId, ')
          ..write('backgroundId: $backgroundId, ')
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
    speciesId,
    backgroundId,
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
          other.speciesId == this.speciesId &&
          other.backgroundId == this.backgroundId &&
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
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CharactersCompanion extends UpdateCompanion<Character> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> playerName;
  final Value<String?> speciesId;
  final Value<String?> backgroundId;
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
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.playerName = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.backgroundId = const Value.absent(),
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
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharactersCompanion.insert({
    required String id,
    required String name,
    this.playerName = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.backgroundId = const Value.absent(),
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
    Expression<String>? speciesId,
    Expression<String>? backgroundId,
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
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (playerName != null) 'player_name': playerName,
      if (speciesId != null) 'species_id': speciesId,
      if (backgroundId != null) 'background_id': backgroundId,
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
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharactersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? playerName,
    Value<String?>? speciesId,
    Value<String?>? backgroundId,
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
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      playerName: playerName ?? this.playerName,
      speciesId: speciesId ?? this.speciesId,
      backgroundId: backgroundId ?? this.backgroundId,
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
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (backgroundId.present) {
      map['background_id'] = Variable<String>(backgroundId.value);
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
          ..write('speciesId: $speciesId, ')
          ..write('backgroundId: $backgroundId, ')
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
  final int? saveDc;
  final int? attackBonus;
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
          ..write('attackBonus: $attackBonus')
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
          other.attackBonus == this.attackBonus);
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
          ..write('attackBonus: $attackBonus')
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
  late final $CharacterMagicItemsTable characterMagicItems =
      $CharacterMagicItemsTable(this);
  late final $CharacterMagicItemSpellsTable characterMagicItemSpells =
      $CharacterMagicItemSpellsTable(this);
  late final $ClassEntriesTable classEntries = $ClassEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    characters,
    characterClassLevels,
    characterSpells,
    characterMagicItems,
    characterMagicItemSpells,
    classEntries,
  ];
}

typedef $$CharactersTableCreateCompanionBuilder =
    CharactersCompanion Function({
      required String id,
      required String name,
      Value<String?> playerName,
      Value<String?> speciesId,
      Value<String?> backgroundId,
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
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CharactersTableUpdateCompanionBuilder =
    CharactersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> playerName,
      Value<String?> speciesId,
      Value<String?> backgroundId,
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

  ColumnFilters<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backgroundId => $composableBuilder(
    column: $table.backgroundId,
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

  ColumnOrderings<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backgroundId => $composableBuilder(
    column: $table.backgroundId,
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

  GeneratedColumn<String> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get backgroundId => $composableBuilder(
    column: $table.backgroundId,
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
            bool characterMagicItemsRefs,
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
                Value<String?> speciesId = const Value.absent(),
                Value<String?> backgroundId = const Value.absent(),
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
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                name: name,
                playerName: playerName,
                speciesId: speciesId,
                backgroundId: backgroundId,
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
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> playerName = const Value.absent(),
                Value<String?> speciesId = const Value.absent(),
                Value<String?> backgroundId = const Value.absent(),
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
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                name: name,
                playerName: playerName,
                speciesId: speciesId,
                backgroundId: backgroundId,
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
            characterMagicItemsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (characterClassLevelsRefs) db.characterClassLevels,
                if (characterSpellsRefs) db.characterSpells,
                if (characterMagicItemsRefs) db.characterMagicItems,
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
        bool characterMagicItemsRefs,
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
  $$CharacterMagicItemsTableTableManager get characterMagicItems =>
      $$CharacterMagicItemsTableTableManager(_db, _db.characterMagicItems);
  $$CharacterMagicItemSpellsTableTableManager get characterMagicItemSpells =>
      $$CharacterMagicItemSpellsTableTableManager(
        _db,
        _db.characterMagicItemSpells,
      );
  $$ClassEntriesTableTableManager get classEntries =>
      $$ClassEntriesTableTableManager(_db, _db.classEntries);
}
