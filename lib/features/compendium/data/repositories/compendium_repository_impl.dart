import 'package:dnd_ficha_app/features/compendium/data/sources/srd_asset_source.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/ability_score_rule.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_choice_group.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_spell_feature.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
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

      return ClassEntry(
        id: item['id'] as String,
        name: item['name'] as String,
        hitDie: item['hit_die'] as String,
        primaryAbility: item['primary_ability'] as String?,
        spellcastingType: item['spellcasting_type'] as String?,
        source: item['source'] as String? ?? 'srd',
        skillOptions:
            skillOptionsRaw.map((e) => e as String).toList(growable: false),
        savingThrows:
            savingThrowsRaw.map((e) => e as String).toList(growable: false),
      );
    }).toList(growable: false);
  }

  @override
  Future<List<RaceEntry>> loadRaces() async {
    final items = await _source.loadJsonList('assets/data/srd/races.json');

    return items.map((item) {
      final rawBonuses =
          item['fixed_ability_bonuses'] as Map<String, dynamic>? ?? const {};
      final rawTraits = item['traits'] as List<dynamic>? ?? const [];
      final rawSizeOptions = item['size_options'] as List<dynamic>? ?? const [];
      final rawLanguages = item['languages'] as List<dynamic>? ?? const [];
      final rawSkillOptions =
          item['skill_options'] as List<dynamic>? ?? const [];
      final rawAbilityRules =
          item['ability_score_rules'] as List<dynamic>? ?? const [];
      final rawSpellcasting =
          item['spellcasting'] as List<dynamic>? ?? const [];
      final rawChoiceGroups =
          item['choice_groups'] as List<dynamic>? ?? const [];
      final rawTags = item['tags'] as List<dynamic>? ?? const [];

      return RaceEntry(
        id: item['id'] as String,
        name: item['name'] as String,
        source: item['source'] as String? ?? 'srd',

        // Compatibilidade atual
        size: item['size'] as String?,
        speed: item['speed'] as int?,
        allowsCustomOrigin: item['allows_custom_origin'] as bool? ?? true,
        fixedAbilityBonuses: rawBonuses.map(
          (key, value) => MapEntry(key, value as int),
        ),
        traits: rawTraits.map((e) {
          if (e is String) return e;
          if (e is Map<String, dynamic>) {
            return e['description'] as String? ?? '';
          }
          return e.toString();
        }).where((e) => e.trim().isNotEmpty).toList(growable: false),

        // Estrutura nova
        parentRaceId: item['parent_race_id'] as String?,
        isSubrace: item['is_subrace'] as bool? ?? false,
        description: item['description'] as String?,
        sizeOptions:
            rawSizeOptions.map((e) => e.toString()).toList(growable: false),
        creatureType: item['creature_type'] as String?,
        darkvision: item['darkvision'] as int?,
        languages:
            rawLanguages.map((e) => e.toString()).toList(growable: false),
        skillOptions:
            rawSkillOptions.map((e) => e.toString()).toList(growable: false),
        abilityScoreRules: rawAbilityRules
            .map((e) => _parseAbilityScoreRule(Map<String, dynamic>.from(e as Map)))
            .toList(growable: false),
        spellcasting: rawSpellcasting
            .map((e) => _parseRaceSpellFeature(Map<String, dynamic>.from(e as Map)))
            .toList(growable: false),
        choiceGroups: rawChoiceGroups
            .map((e) => _parseRaceChoiceGroup(Map<String, dynamic>.from(e as Map)))
            .toList(growable: false),
        tags: rawTags.map((e) => e.toString()).toList(growable: false),
      );
    }).toList(growable: false);
  }

  @override
  Future<List<ClassFeatureEntry>> loadClassFeatures() async {
    final items =
        await _source.loadJsonList('assets/data/srd/class_features.json');

    return items.map((item) {
      final rawFeatures = item['features'] as List<dynamic>? ?? const [];

      return ClassFeatureEntry(
        classId: item['class_id'] as String,
        level: item['level'] as int,
        features:
            rawFeatures.map((e) => e as String).toList(growable: false),
        source: item['source'] as String? ?? 'srd',
      );
    }).toList(growable: false);
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
          nameOriginal: spell['nome_original'] as String? ?? '',
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

  AbilityScoreRule _parseAbilityScoreRule(Map<String, dynamic> item) {
    final rawBonuses =
        item['fixed_bonuses'] as Map<String, dynamic>? ?? const {};

    return AbilityScoreRule(
      type: item['type'] as String? ?? 'fixed',
      fixedBonuses: rawBonuses.isEmpty
          ? null
          : rawBonuses.map((key, value) => MapEntry(key, value as int)),
      choose: item['choose'] as int?,
      maxPerAbility: item['max_per_ability'] as int?,
    );
  }

  RaceSpellFeature _parseRaceSpellFeature(Map<String, dynamic> item) {
    return RaceSpellFeature(
      spellId: item['spell_id'] as int,
      level: item['level'] as int?,
      isAtWill: item['is_at_will'] as bool? ?? false,
      usesPerRest: item['uses_per_rest'] as int?,
      notes: item['notes'] as String?,
    );
  }

  RaceChoiceGroup _parseRaceChoiceGroup(Map<String, dynamic> item) {
    final rawOptions = item['options'] as List<dynamic>? ?? const [];

    return RaceChoiceGroup(
      id: item['id'] as String,
      name: item['name'] as String,
      options: rawOptions.map((e) => e.toString()).toList(growable: false),
      choose: item['choose'] as int? ?? 1,
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
}