import 'package:dnd_ficha_app/features/compendium/data/sources/srd_asset_source.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/ability_bonus_mode.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_prerequisite.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_choice_group.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_skill_choice.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/repositories/compendium_repository.dart';

class CompendiumRepositoryImpl implements CompendiumRepository {
  CompendiumRepositoryImpl(this._source);

  final SrdAssetSource _source;

  @override
  Future<List<ClassEntry>> loadClasses() async {
    final items = await _source.loadJsonList('assets/data/srd/classes.json');

    return items.map((item) {
      final skillOptionsRaw =
          item['skill_options'] as List<dynamic>? ?? const [];
      final savingThrowsRaw =
          item['saving_throws'] as List<dynamic>? ?? const [];
      final featLevelsRaw = _asList(item['feat_levels'])
          .map(_asInt)
          .whereType<int>()
          .where((level) => level > 0)
          .toList(growable: false);

      return ClassEntry(
        id: item['id'] as String,
        name: item['name'] as String,
        hitDie: item['hit_die'] as String,
        primaryAbility: item['primary_ability'] as String?,
        spellcastingType: item['spellcasting_type'] as String?,
        spellcastingAbility: item['spellcasting_ability'] as String?,
        subclassLevel: _asInt(item['subclass_level']),
        subclassLabel: item['subclass_label'] as String?,
        // Ausente no JSON cai no padrão 4/8/12/16/19, que vale para quase
        // todas as classes; só Guerreiro e Ladino precisam declarar.
        featLevels: featLevelsRaw.isEmpty
            ? ClassEntry.defaultFeatLevels
            : featLevelsRaw,
        variantOf: item['variant_of'] as String?,
        source: item['source'] as String? ?? 'srd',
        skillOptions: skillOptionsRaw
            .map((e) => e.toString())
            .toList(growable: false),
        savingThrows: savingThrowsRaw
            .map((e) => e.toString())
            .toList(growable: false),
      );
    }).toList(growable: false);
  }

  @override
  Future<List<RaceEntry>> loadRaces() async {
    final items = await _source.loadJsonList('assets/data/srd/races.json');

    return items.map((item) {
      final rawBonuses = _asMap(item['fixed_ability_bonuses']);
      final rawTraits = _asList(item['traits']);
      final rawSizeOptions = _asList(item['size_options']);
      final rawLanguages = _asList(item['languages']);
      final rawGrantedSkills = _asList(item['granted_skills']);
      final rawChoiceGroups = _asList(item['choice_groups']);
      final rawTags = _asList(item['tags']);
      final rawSkillChoice = item['skill_choice'];

      return RaceEntry(
        id: item['id'] as String,
        name: item['name'] as String,
        source: item['source'] as String? ?? 'srd',

        size: item['size'] as String?,
        speed: _asDouble(item['speed']),
        allowsCustomOrigin: _asBool(item['allows_custom_origin'], fallback: true),
        abilityBonusMode: AbilityBonusMode.fromId(
          item['ability_bonus_mode'] as String?,
        ),
        fixedAbilityBonuses: rawBonuses.map(
          (key, value) => MapEntry(key, _asInt(value) ?? 0),
        ),
        abilityBonusChoices: _asList(item['ability_bonus_choices'])
            .map((e) => _asInt(e) ?? 0)
            .where((value) => value > 0)
            .toList(growable: false),
        grantsFeat: _asBool(item['grants_feat']),
        grantedSkills: rawGrantedSkills
            .map((e) => e.toString())
            .toList(growable: false),
        skillChoice: rawSkillChoice is Map
            ? _parseRaceSkillChoice(Map<String, dynamic>.from(rawSkillChoice))
            : null,
        traits: rawTraits
            .map((e) {
              if (e is String) return e;
              if (e is Map<String, dynamic>) {
                return e['description']?.toString() ?? '';
              }
              if (e is Map) {
                return e['description']?.toString() ?? '';
              }
              return e.toString();
            })
            .where((e) => e.trim().isNotEmpty)
            .toList(growable: false),

        parentRaceId: item['parent_race_id'] as String?,
        isSubrace: _asBool(item['is_subrace']),
        description: item['description'] as String?,
        sizeOptions: rawSizeOptions
            .map((e) => e.toString())
            .toList(growable: false),
        creatureType: item['creature_type'] as String?,
        darkvision: _asInt(item['darkvision']),
        languages: rawLanguages
            .map((e) => e.toString())
            .toList(growable: false),
        choiceGroups: rawChoiceGroups
            .whereType<Map>()
            .map((e) => _parseRaceChoiceGroup(Map<String, dynamic>.from(e)))
            .toList(growable: false),
        tags: rawTags.map((e) => e.toString()).toList(growable: false),
      );
    }).toList(growable: false);
  }

  @override
  Future<List<BackgroundEntry>> loadBackgrounds() async {
    final items =
        await _source.loadJsonList('assets/data/srd/backgrounds.json');

    final entries = items.map((item) {
      return BackgroundEntry(
        id: item['id'] as String,
        name: item['name'] as String,
        description: item['description'] as String?,
        skillIds: _asList(item['skills'])
            .map((e) => e.toString())
            .toList(growable: false),
        languages: _asInt(item['languages']) ?? 0,
        tools: _asList(item['tools'])
            .map((e) => e.toString())
            .toList(growable: false),
        featureName: item['feature_name'] as String?,
        featureDescription: item['feature_description'] as String?,
        startingGold: _asInt(item['starting_gold']) ?? 0,
        source: item['source'] as String? ?? 'phb',
      );
    }).toList();

    // "Antecedente Customizável" não vem do JSON: é uma opção sintética que
    // libera o jogador para montar o próprio antecedente. Fica sempre no fim
    // da lista, depois dos antecedentes oficiais.
    if (!entries.any((entry) => entry.isCustom)) {
      entries.add(BackgroundEntry.customOption);
    }

    return List<BackgroundEntry>.unmodifiable(entries);
  }

  @override
  Future<List<FeatEntry>> loadFeats() async {
    final items = await _source.loadJsonList('assets/data/srd/feats.json');

    return items.map((item) {
      final rawChoice = _asMap(item['skill_choice']);
      final rawIncreases = _asMap(item['ability_increases']);

      return FeatEntry(
        id: item['id'] as String,
        name: item['name'] as String,
        nameOriginal: item['name_original'] as String?,
        description: item['description'] as String?,
        prerequisite: item['prerequisite'] as String?,
        requires: _parseFeatPrerequisite(_asMap(item['requires'])),
        repeatable: _asBool(item['repeatable'], fallback: false),
        skillIds: _asList(item['skills'])
            .map((e) => e.toString())
            .toList(growable: false),
        // `choose: 0` não é escolha nenhuma, então vira nulo em vez de um
        // objeto que a tela teria de checar depois.
        skillChoice: rawChoice.isEmpty || (_asInt(rawChoice['choose']) ?? 0) <= 0
            ? null
            : FeatSkillChoice(
                choose: _asInt(rawChoice['choose']) ?? 0,
                options: _asList(rawChoice['options'])
                    .map((e) => e.toString())
                    .toList(growable: false),
              ),
        abilityIncreases: {
          for (final entry in rawIncreases.entries)
            if (_asInt(entry.value) case final value?) entry.key: value,
        },
        abilityIncreaseOptions: _asList(item['ability_increase_options'])
            .map((e) => e.toString())
            .toList(growable: false),
        source: item['source'] as String? ?? 'phb',
      );
    }).toList(growable: false);
  }

  FeatPrerequisite _parseFeatPrerequisite(Map<String, dynamic> raw) {
    if (raw.isEmpty) return const FeatPrerequisite();

    List<String> ids(String key) => _asList(raw[key])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final rawAbilities = _asMap(raw['min_ability_any']);

    return FeatPrerequisite(
      minLevel: _asInt(raw['min_level']) ?? 0,
      minAbilityAny: {
        for (final entry in rawAbilities.entries)
          if (_asInt(entry.value) case final value?) entry.key: value,
      },
      requiresSpellcasting: _asBool(raw['spellcasting']),
      raceIds: ids('race_ids'),
      raceSizes: ids('race_sizes'),
      classIds: ids('class_ids'),
      requiredFeatIds: ids('feat_ids'),
      forbiddenFeatIds: ids('not_feat_ids'),
      notes: ids('notes'),
    );
  }

  @override
  Future<List<ClassFeatureEntry>> loadClassFeatures() async {
    final items =
        await _source.loadJsonList('assets/data/srd/class_features.json');

    return items.map((item) {
      return ClassFeatureEntry(
        classId: item['class_id'] as String,
        level: item['level'] as int,
        // `tryParse` aceita texto e objeto, e descarta entrada sem nome.
        features: [
          for (final raw in _asList(item['features']))
            if (ClassFeature.tryParse(raw) case final feature?) feature,
        ],
        source: item['source'] as String? ?? 'srd',
      );
    }).toList(growable: false);
  }

  @override
  Future<List<SubclassEntry>> loadSubclasses() async {
    final items = await _source.loadJsonList('assets/data/srd/subclasses.json');

    final declared = items
        .map((item) => _parseSubclass(item))
        .toList(growable: false);

    // Variante de classe reaproveita as subclasses da classe-base. A expansão
    // acontece aqui, e não em cada tela, porque os filtros de subclasse
    // comparam `classId` por igualdade em vários lugares (criação, níveis,
    // ficha) e ainda há a guarda de `ChooseSubclass`. Resolvendo na leitura,
    // todos passam a funcionar sem saber que variantes existem.
    final variants = await _variantClassIds();
    if (variants.isEmpty) return declared;

    return [
      ...declared,
      for (final variant in variants.entries)
        ...declared
            .where((subclass) => subclass.classId == variant.value)
            .map((subclass) => subclass.forClass(variant.key)),
    ];
  }

  SubclassEntry _parseSubclass(Map<String, dynamic> item) {
    final rawFeatures = _asList(item['features']);
    final rawSpells = _asList(item['spells']);
    final rawTags = _asList(item['tags']);

    return SubclassEntry(
      id: item['id'] as String,
      classId: item['class_id'] as String,
      name: item['name'] as String,
      source: item['source'] as String? ?? 'srd',
      description: item['description'] as String?,
      features: rawFeatures
          .whereType<Map>()
          .map((e) => _parseSubclassFeature(Map<String, dynamic>.from(e)))
          .toList(growable: false),
      spells: rawSpells
          .whereType<Map>()
          .map((e) => _parseSubclassSpellGrant(Map<String, dynamic>.from(e)))
          .toList(growable: false),
      tags: rawTags.map((e) => e.toString()).toList(growable: false),
    );
  }

  /// Variantes declaradas em `classes.json`, no formato `{id: id da base}`.
  ///
  /// Só um nível de herança: a base precisa ser uma classe com subclasses
  /// próprias. Variante de variante não é resolvida em cadeia, porque não há
  /// caso real disso e a recursão só acrescentaria uma forma de escrever um
  /// ciclo no asset.
  Future<Map<String, String>> _variantClassIds() async {
    final items = await _source.loadJsonList('assets/data/srd/classes.json');
    final result = <String, String>{};

    for (final item in items) {
      final id = item['id'] as String?;
      final base = item['variant_of'] as String?;
      if (id == null || base == null || base == id) continue;

      result[id] = base;
    }

    return result;
  }

  @override
  Future<List<SpellSlotProgressionEntry>> loadSpellSlotProgressions() async {
    final items = await _source.loadJsonList('assets/data/srd/spell_slots.json');

    return items.map((item) {
      return SpellSlotProgressionEntry(
        tableId: item['table_id'] as String,
        level: item['level'] as int,
        first: item['1'] as int? ?? 0,
        second: item['2'] as int? ?? 0,
        third: item['3'] as int? ?? 0,
        fourth: item['4'] as int? ?? 0,
        fifth: item['5'] as int? ?? 0,
        sixth: item['6'] as int? ?? 0,
        seventh: item['7'] as int? ?? 0,
        eighth: item['8'] as int? ?? 0,
        ninth: item['9'] as int? ?? 0,
        pactSlotLevel: item['pact_slot_level'] as int?,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<SpellEntry>> loadSpells() async {
    final files = [
      'assets/data/spells/magias-livro-do-jogador.json',
      'assets/data/spells/magias-xanathar-guide.json',
      'assets/data/spells/magias-tasha-cauldron.json',
    ];

    final List<SpellEntry> allSpells = [];

    for (final path in files) {
      final raw = await _source.loadRawJson(path);
      final dados = raw['dados'] as List<dynamic>? ?? const [];

      final spellsFromFile = dados.map((item) {
        final spell = Map<String, dynamic>.from(item as Map);

        return SpellEntry(
          id: spell['id'] as int,
          namePt: spell['nome'] as String? ?? '',
          // O campo no asset chama `original`. Lia-se `nome_original`, que não
          // existe, então o nome em inglês vinha vazio e a busca por ele nunca
          // achava nada.
          nameOriginal: spell['original'] as String? ?? '',
          level: spell['nivel'] as int? ?? 0,
          school: spell['escola'] as String? ?? '',
          castingTime: spell['tempo'] as String? ?? '',
          range: spell['alcance'] as String? ?? '',
          components: spell['componentes'] as String? ?? '',
          hasCostlyMaterials: spell['materiaispagos'] as bool? ?? false,
          duration: spell['duracao'] as String? ?? '',
          concentration: spell['concentracao'] as bool? ?? false,
          ritual: spell['ritual'] as bool? ?? false,
          classes: _parseClasses(spell['classes'] as String?),
          subclasses: _splitCommaList(spell['subclasses'] as String?),
          description: spell['descricao'] as String? ?? '',
          upcast: spell['upcast'] as String?,
          source: spell['fonte'] as String? ?? '',
          page: spell['pagina'] as String? ?? '',
          isSrd: spell['srd'] as bool? ?? false,
        );
      }).toList();

      allSpells.addAll(spellsFromFile);
    }

    return allSpells;
  }

  SubclassSpellGrant _parseSubclassSpellGrant(Map<String, dynamic> item) {
    return SubclassSpellGrant(
      level: _asInt(item['level']) ?? 1,
      spellNames: _asList(
        item['names'],
      ).map((e) => e.toString()).toList(growable: false),
    );
  }

  SubclassFeature _parseSubclassFeature(Map<String, dynamic> item) {
    return SubclassFeature(
      level: _asInt(item['level']) ?? 1,
      name: item['name'] as String? ?? '',
      description: item['description'] as String? ?? '',
    );
  }

  RaceSkillChoice _parseRaceSkillChoice(Map<String, dynamic> item) {
    final options = _asList(
      item['options'],
    ).map((e) => e.toString()).toList(growable: false);

    return RaceSkillChoice(
      choose: _asInt(item['choose']) ?? 1,
      options: options,
    );
  }

  RaceChoiceGroup _parseRaceChoiceGroup(Map<String, dynamic> item) {
    final rawOptions = _asList(item['options']);

    return RaceChoiceGroup(
      id: item['id'] as String,
      name: item['name'] as String,
      options: rawOptions.map((e) => e.toString()).toList(growable: false),
      choose: _asInt(item['choose']) ?? 1,
    );
  }

  List<String> _parseClasses(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];

    return raw
        .split(',')
        .map((e) => _mapClassName(e.trim()))
        .whereType<String>()
        .toList(growable: false);
  }

  List<String> _splitCommaList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];

    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  String? _mapClassName(String value) {
    switch (value.toLowerCase()) {
      case 'bárbaro':
        return 'barbarian';
      case 'bardo':
        return 'bard';
      case 'clérigo':
        return 'cleric';
      case 'druida':
        return 'druid';
      case 'guerreiro':
        return 'fighter';
      case 'monge':
        return 'monk';
      case 'paladino':
        return 'paladin';
      case 'guardião':
        return 'ranger';
      case 'ladino':
        return 'rogue';
      case 'feiticeiro':
        return 'sorcerer';
      case 'bruxo':
        return 'warlock';
      case 'mago':
        return 'wizard';
      case 'artífice':
        return 'artificer';
      default:
        return null;
    }
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List<dynamic>) return value;
    if (value is List) return value.toList();
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Deslocamento aceita fração: 7,5 m do anão viraria 7 com `_asInt`.
  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.'));
    return null;
  }

  bool _asBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'sim';
    }
    return fallback;
  }
}