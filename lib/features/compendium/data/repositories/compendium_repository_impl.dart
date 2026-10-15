import 'package:dnd_ficha_app/core/utils/html_text.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/compendium/data/sources/srd_asset_source.dart';
import 'package:dnd_ficha_app/features/compendium/data/spell_assets.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/ability_bonus_mode.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_choices.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_personality.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_prerequisite.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/initiative_rule.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_grant.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_choice_group.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_skill_choice.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_proficiencies.dart';
import 'package:dnd_ficha_app/features/compendium/domain/repositories/compendium_repository.dart';

class CompendiumRepositoryImpl implements CompendiumRepository {
  CompendiumRepositoryImpl(this._source);

  final SrdAssetSource _source;

  @override
  Future<List<ClassEntry>> loadClasses() async {
    final items = await _source.loadJsonList('assets/data/srd/classes.json');

    return items
        .map((item) {
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
            featLevels:
                featLevelsRaw.isEmpty
                    ? ClassEntry.defaultFeatLevels
                    : featLevelsRaw,
            variantOf: item['variant_of'] as String?,
            source: item['source'] as String? ?? 'srd',
            skillOptions: skillOptionsRaw
                .map((e) => e.toString())
                .toList(growable: false),
            // Zero quando o asset não declara: a tela não impõe limite nesse caso,
            // em vez de travar o jogador em zero perícias.
            skillChoices: _asInt(item['skill_choices']) ?? 0,
            weaponProficiencies: WeaponProficiencies.tryParse(
              item['weapon_proficiencies'],
            ),
            savingThrows: savingThrowsRaw
                .map((e) => e.toString())
                .toList(growable: false),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<RaceEntry>> loadRaces() async {
    final items = await _source.loadJsonList('assets/data/srd/races.json');

    return items
        .map((item) {
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
            allowsCustomOrigin: _asBool(
              item['allows_custom_origin'],
              fallback: true,
            ),
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
            skillChoice:
                rawSkillChoice is Map
                    ? _parseRaceSkillChoice(
                      Map<String, dynamic>.from(rawSkillChoice),
                    )
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
            initiative: InitiativeRule.tryParse(item['initiative']),

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
            languageGrants: LanguageGrant.parseList(
              item['language_grants'],
              idPrefix: 'race.${item['id']}',
            ),
            choiceGroups: rawChoiceGroups
                .whereType<Map>()
                .map((e) => _parseRaceChoiceGroup(Map<String, dynamic>.from(e)))
                .toList(growable: false),
            tags: rawTags.map((e) => e.toString()).toList(growable: false),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<BackgroundEntry>> loadBackgrounds() async {
    final items = await _source.loadJsonList(
      'assets/data/srd/backgrounds.json',
    );

    // Primeira passada: só as tabelas narrativas de quem as declara.
    //
    // É preciso ter todas antes de montar as entradas porque o livro deixa um
    // antecedente reaproveitar as tabelas de outro ("Este antecedente usa as
    // tabelas oficiais de Acólito"), e o dono pode aparecer depois no arquivo.
    // Guardar a referência em vez de repetir as 26 opções evita que a mesma
    // tabela exista em cinco cópias que depois divergem entre si.
    final tablesByOwner = <String, BackgroundPersonality>{};
    for (final raw in items) {
      final item = _asMap(raw);
      final ownerId = (item['id'] as String?)?.trim();
      if (ownerId == null || ownerId.isEmpty) continue;

      final tables = _parsePersonalityTables(ownerId, item);
      if (tables != null) tablesByOwner[ownerId] = tables;
    }

    final entries =
        items.map((raw) {
          final item = _asMap(raw);
          final id = item['id'] as String;
          final inheritFrom = (item['personality_from'] as String?)?.trim();

          // Tabelas próprias quando existem; senão as do antecedente apontado.
          // Referência quebrada cai em "sem personalidade" em vez de lançar: um
          // antecedente sem traços continua jogável, e derrubar o compêndio
          // inteiro por causa de uma linha de dado seria pior.
          final tables =
              tablesByOwner[id] ??
              (inheritFrom == null ? null : tablesByOwner[inheritFrom]);

          final startingGold = _asInt(item['starting_gold']) ?? 0;

          return BackgroundEntry(
            id: id,
            name: item['name'] as String,
            description: item['description'] as String?,
            skillIds: _asList(
              item['skills'],
            ).map((e) => e.toString()).toList(growable: false),
            languages: _asInt(item['languages']) ?? 0,
            languageGrants: LanguageGrant.parseList(
              item['language_grants'],
              idPrefix: 'background.$id',
            ),
            tools: _asList(
              item['tools'],
            ).map((e) => e.toString()).toList(growable: false),
            featureName: item['feature_name'] as String?,
            featureDescription: item['feature_description'] as String?,
            startingGold: startingGold,
            source: item['source'] as String? ?? 'phb',
            variantOf: (item['variant_of'] as String?)?.trim(),
            personality: _personalityFor(tables, item),
            startingCurrency: _parseStartingCurrency(item, startingGold),
            startingEquipment: _parseEquipmentItems(
              _asList(item['starting_equipment']),
            ),
            equipmentChoices: _parseEquipmentChoices(
              _asList(item['equipment_choices']),
            ),
            skillChoice: _parseBackgroundSkillChoice(item['skill_choices']),
            extraChoices: _parseExtraChoices(_asList(item['extra_choices'])),
            featureOptions: _parseFeatureOptions(
              _asList(item['feature_options']),
            ),
            specialty: (item['specialty'] as String?)?.trim(),
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
  Future<List<LanguageEntry>> loadLanguages() async {
    final items = await _source.loadJsonList('assets/data/srd/languages.json');

    return LanguageEntry.parseList(items);
  }

  /// Lê as quatro tabelas narrativas declaradas pelo próprio antecedente.
  ///
  /// Devolve `null` quando ele não declara nenhuma — é o caso de quem herda as
  /// tabelas de outro, e de quem simplesmente não tem.
  BackgroundPersonality? _parsePersonalityTables(
    String ownerId,
    Map<String, dynamic> item,
  ) {
    final traits = _parsePersonalityTable(
      ownerId,
      PersonalityCategory.trait,
      item['personality_traits'],
    );
    final ideals = _parsePersonalityTable(
      ownerId,
      PersonalityCategory.ideal,
      item['ideals'],
    );
    final bonds = _parsePersonalityTable(
      ownerId,
      PersonalityCategory.bond,
      item['bonds'],
    );
    final flaws = _parsePersonalityTable(
      ownerId,
      PersonalityCategory.flaw,
      item['flaws'],
    );

    if (traits == null && ideals == null && bonds == null && flaws == null) {
      return null;
    }

    return BackgroundPersonality(
      sourceId: ownerId,
      traits: traits ?? PersonalityTable.noTraits,
      ideals: ideals ?? PersonalityTable.noIdeals,
      bonds: bonds ?? PersonalityTable.noBonds,
      flaws: flaws ?? PersonalityTable.noFlaws,
      // As contagens do dono ficam guardadas junto das tabelas para servirem
      // de base a quem as reaproveita: a variante segue a regra do
      // antecedente-base, e repetir os quatro números em cada entrada que
      // herda só criaria oportunidade de divergirem.
      traitChoiceCount: _asInt(item['personality_trait_choices']) ?? 0,
      idealChoiceCount: _asInt(item['ideal_choices']) ?? 0,
      bondChoiceCount: _asInt(item['bond_choices']) ?? 0,
      flawChoiceCount: _asInt(item['flaw_choices']) ?? 0,
    );
  }

  PersonalityTable? _parsePersonalityTable(
    String ownerId,
    PersonalityCategory category,
    dynamic raw,
  ) {
    if (raw == null) return null;

    final map = _asMap(raw);
    final parsed = <PersonalityOption>[];

    for (final optionRaw in _asList(map['options'])) {
      final option = _asMap(optionRaw);
      final roll = _asInt(option['roll']);
      final text = (option['text'] as String?)?.trim();
      // Linha sem resultado de dado ou sem texto é descartada em silêncio: ela
      // não teria id estável nem nada para mostrar ao jogador.
      if (roll == null || text == null || text.isEmpty) continue;

      final name = (option['name'] as String?)?.trim();

      parsed.add(
        PersonalityOption(
          // O id deriva do DONO da tabela, não de quem a usa. Assim Acólito e
          // Agente compartilham os mesmos ids e trocar entre os dois não
          // invalida a escolha já feita.
          id: '$ownerId.${category.id}.$roll',
          category: category,
          roll: roll,
          text: text,
          name: name == null || name.isEmpty ? null : name,
        ),
      );
    }

    if (parsed.isEmpty) return null;

    return PersonalityTable(
      category: category,
      die: (map['die'] as String?)?.trim() ?? '',
      options: List<PersonalityOption>.unmodifiable(parsed),
    );
  }

  /// Combina as tabelas (que podem vir de outro antecedente) com as contagens
  /// de escolha.
  ///
  /// A entrada que usa as tabelas pode declarar as próprias contagens; quando
  /// não declara, herda as do dono das tabelas. É isso que faz o Espião seguir
  /// a contagem do Criminoso sem repetir o número: o livro manda a variante
  /// seguir a regra do antecedente-base.
  BackgroundPersonality _personalityFor(
    BackgroundPersonality? tables,
    Map<String, dynamic> item,
  ) {
    if (tables == null) return BackgroundPersonality.none;

    return BackgroundPersonality(
      sourceId: tables.sourceId,
      traits: tables.traits,
      ideals: tables.ideals,
      bonds: tables.bonds,
      flaws: tables.flaws,
      traitChoiceCount:
          _asInt(item['personality_trait_choices']) ?? tables.traitChoiceCount,
      idealChoiceCount:
          _asInt(item['ideal_choices']) ?? tables.idealChoiceCount,
      bondChoiceCount: _asInt(item['bond_choices']) ?? tables.bondChoiceCount,
      flawChoiceCount: _asInt(item['flaw_choices']) ?? tables.flawChoiceCount,
    );
  }

  /// Moedas concedidas. Cai no ouro solto quando o antecedente só declara ele,
  /// que é o formato do compêndio antigo.
  Currency _parseStartingCurrency(Map<String, dynamic> item, int startingGold) {
    final raw = item['starting_currency'];
    if (raw == null) {
      return startingGold > 0 ? Currency(gold: startingGold) : const Currency();
    }

    final map = _asMap(raw);

    // Negativo é descartado: antecedente não cobra dinheiro do personagem.
    int coin(String key) {
      final value = _asInt(map[key]) ?? 0;
      return value < 0 ? 0 : value;
    }

    return Currency(
      copper: coin('copper'),
      silver: coin('silver'),
      electrum: coin('electrum'),
      gold: coin('gold'),
      platinum: coin('platinum'),
    );
  }

  List<BackgroundEquipmentItem> _parseEquipmentItems(List<dynamic> raw) {
    final result = <BackgroundEquipmentItem>[];

    for (final entry in raw) {
      final map = _asMap(entry);
      final id = (map['id'] as String?)?.trim();
      final name = (map['name'] as String?)?.trim();
      // Sem id não há como rastrear a origem na troca de antecedente, e sem
      // nome não há o que mostrar. Nos dois casos o item é ignorado.
      if (id == null || id.isEmpty) continue;
      if (name == null || name.isEmpty) continue;

      final quantity = _asInt(map['quantity']) ?? 1;

      result.add(
        BackgroundEquipmentItem(
          id: id,
          name: name,
          quantity: quantity < 1 ? 1 : quantity,
          category: ItemCategory.fromIdOrOther(map['category'] as String?),
        ),
      );
    }

    return List<BackgroundEquipmentItem>.unmodifiable(result);
  }

  List<BackgroundEquipmentChoice> _parseEquipmentChoices(List<dynamic> raw) {
    final result = <BackgroundEquipmentChoice>[];

    for (final entry in raw) {
      final map = _asMap(entry);
      final id = (map['id'] as String?)?.trim();
      if (id == null || id.isEmpty) continue;

      final options = <BackgroundEquipmentOption>[];
      for (final optionRaw in _asList(map['options'])) {
        final option = _asMap(optionRaw);
        final optionId = (option['id'] as String?)?.trim();
        if (optionId == null || optionId.isEmpty) continue;

        options.add(
          BackgroundEquipmentOption(
            id: optionId,
            label: (option['label'] as String?)?.trim() ?? optionId,
            items: _parseEquipmentItems(_asList(option['items'])),
          ),
        );
      }

      if (options.isEmpty) continue;

      result.add(
        BackgroundEquipmentChoice(
          id: id,
          label: (map['label'] as String?)?.trim() ?? '',
          count: _asInt(map['count']) ?? 1,
          options: List<BackgroundEquipmentOption>.unmodifiable(options),
        ),
      );
    }

    return List<BackgroundEquipmentChoice>.unmodifiable(result);
  }

  BackgroundSkillChoice? _parseBackgroundSkillChoice(dynamic raw) {
    if (raw == null) return null;

    final map = _asMap(raw);
    final count = _asInt(map['count']) ?? 0;
    final ids = _asList(map['options'])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);

    if (count <= 0 || ids.isEmpty) return null;

    return BackgroundSkillChoice(
      count: count,
      label: (map['label'] as String?)?.trim(),
      skillIds: ids,
    );
  }

  List<BackgroundExtraChoice> _parseExtraChoices(List<dynamic> raw) {
    final result = <BackgroundExtraChoice>[];

    for (final entry in raw) {
      final map = _asMap(entry);
      final id = (map['id'] as String?)?.trim();
      if (id == null || id.isEmpty) continue;

      final options = <BackgroundTableOption>[];
      for (final optionRaw in _asList(map['options'])) {
        final option = _asMap(optionRaw);
        final roll = _asInt(option['roll']);
        final text = (option['text'] as String?)?.trim();
        if (roll == null || text == null || text.isEmpty) continue;

        options.add(BackgroundTableOption(roll: roll, text: text));
      }

      if (options.isEmpty) continue;

      result.add(
        BackgroundExtraChoice(
          id: id,
          label: (map['label'] as String?)?.trim() ?? '',
          die: (map['die'] as String?)?.trim() ?? '',
          options: List<BackgroundTableOption>.unmodifiable(options),
        ),
      );
    }

    return List<BackgroundExtraChoice>.unmodifiable(result);
  }

  List<BackgroundFeatureOption> _parseFeatureOptions(List<dynamic> raw) {
    final result = <BackgroundFeatureOption>[];

    for (final entry in raw) {
      final map = _asMap(entry);
      final id = (map['id'] as String?)?.trim();
      final name = (map['name'] as String?)?.trim();
      if (id == null || id.isEmpty) continue;
      if (name == null || name.isEmpty) continue;

      result.add(
        BackgroundFeatureOption(
          id: id,
          name: name,
          description: (map['description'] as String?)?.trim(),
        ),
      );
    }

    return List<BackgroundFeatureOption>.unmodifiable(result);
  }

  @override
  Future<List<FeatEntry>> loadFeats() async {
    final items = await _source.loadJsonList('assets/data/srd/feats.json');

    return items
        .map((item) {
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
            skillIds: _asList(
              item['skills'],
            ).map((e) => e.toString()).toList(growable: false),
            // `choose: 0` não é escolha nenhuma, então vira nulo em vez de um
            // objeto que a tela teria de checar depois.
            skillChoice:
                rawChoice.isEmpty || (_asInt(rawChoice['choose']) ?? 0) <= 0
                    ? null
                    : FeatSkillChoice(
                      choose: _asInt(rawChoice['choose']) ?? 0,
                      options: _asList(
                        rawChoice['options'],
                      ).map((e) => e.toString()).toList(growable: false),
                    ),
            abilityIncreases: {
              for (final entry in rawIncreases.entries)
                if (_asInt(entry.value) case final value?) entry.key: value,
            },
            abilityIncreaseOptions: _asList(
              item['ability_increase_options'],
            ).map((e) => e.toString()).toList(growable: false),
            initiative: InitiativeRule.tryParse(item['initiative']),
            languageGrants: LanguageGrant.parseList(
              item['language_grants'],
              idPrefix: 'feat.${item['id']}',
            ),
            source: item['source'] as String? ?? 'phb',
          );
        })
        .toList(growable: false);
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
    final items = await _source.loadJsonList(
      'assets/data/srd/class_features.json',
    );

    return items
        .map((item) {
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
        })
        .toList(growable: false);
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
    final items = await _source.loadJsonList(
      'assets/data/srd/spell_slots.json',
    );

    return items
        .map((item) {
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
        })
        .toList(growable: false);
  }

  @override
  Future<List<SpellEntry>> loadSpells() async {
    final List<SpellEntry> allSpells = [];

    for (final path in spellAssetPaths) {
      final raw = await _source.loadRawJson(path);
      final dados = raw['dados'] as List<dynamic>? ?? const [];

      final spellsFromFile =
          dados.map((item) {
            final spell = Map<String, dynamic>.from(item as Map);

            // Os assets de magia guardam HTML dentro dos campos de texto (`<br>`,
            // `<b>`, listas e tabelas, além de `&emsp;`). A limpeza fica aqui, na
            // leitura, porque a descrição é exibida no compêndio e no painel de
            // magias da ficha, e o painel mostrava o markup literal.
            String text(String key) =>
                htmlToPlainText(spell[key] as String? ?? '');

            return SpellEntry(
              id: spell['id'] as int,
              namePt: text('nome'),
              // O campo no asset chama `original`. Lia-se `nome_original`, que não
              // existe, então o nome em inglês vinha vazio e a busca por ele nunca
              // achava nada.
              nameOriginal: text('original'),
              level: spell['nivel'] as int? ?? 0,
              school: text('escola'),
              castingTime: text('tempo'),
              range: text('alcance'),
              components: text('componentes'),
              hasCostlyMaterials: spell['materiaispagos'] as bool? ?? false,
              duration: text('duracao'),
              concentration: spell['concentracao'] as bool? ?? false,
              ritual: spell['ritual'] as bool? ?? false,
              classes: _parseClasses(spell['classes'] as String?),
              subclasses: _splitCommaList(spell['subclasses'] as String?),
              description: text('descricao'),
              upcast: htmlToPlainTextOrNull(spell['upcast'] as String?),
              source: spell['fonte'] as String? ?? '',
              page: spell['pagina'] as String? ?? '',
              isSrd: spell['srd'] as bool? ?? false,
            );
          }).toList();

      allSpells.addAll(spellsFromFile);
    }

    return allSpells;
  }

  @override
  Future<List<WeaponEntry>> loadWeapons() async {
    final items = await _source.loadJsonList('assets/data/srd/weapons.json');

    return items
        .map(_parseWeapon)
        .whereType<WeaponEntry>()
        .toList(growable: false);
  }

  /// Lê uma arma. Devolve nulo quando falta o que define a arma.
  ///
  /// Tolerante como o resto do compêndio: uma entrada quebrada some da lista em
  /// vez de derrubar a leitura das outras 36. O teste de asset é quem garante
  /// que nenhuma sumiu.
  WeaponEntry? _parseWeapon(Map<String, dynamic> item) {
    final id = item['id'] as String?;
    final name = item['name'] as String?;
    final category = WeaponCategory.fromId(item['category'] as String?);
    final rangeType = WeaponRangeType.fromId(item['range_type'] as String?);

    if (id == null || name == null || category == null || rangeType == null) {
      return null;
    }

    final damage = (item['damage'] as String?)?.trim();
    final special = (item['special'] as String?)?.trim();
    final versatile = (item['versatile_damage'] as String?)?.trim();

    return WeaponEntry(
      id: id,
      name: name,
      nameOriginal: item['name_original'] as String?,
      category: category,
      rangeType: rangeType,
      damage: damage == null || damage.isEmpty ? null : damage,
      damageType:
          WeaponDamageType.fromId(item['damage_type'] as String?) ??
          WeaponDamageType.none,
      properties: [
        for (final raw in _asList(item['properties']))
          if (WeaponProperty.fromId(raw.toString()) case final property?)
            property,
      ],
      range: WeaponRange.tryParse(item['range']),
      thrownRange: WeaponRange.tryParse(item['thrown_range']),
      versatileDamage:
          versatile == null || versatile.isEmpty ? null : versatile,
      special: special == null || special.isEmpty ? null : special,
      source: item['source'] as String? ?? 'phb',
    );
  }

  @override
  Future<List<ClassStartingEquipment>> loadClassEquipment() async {
    final items = await _source.loadJsonList(
      'assets/data/srd/class_equipment.json',
    );

    final parsed = <ClassStartingEquipment>[];
    // Classes que só apontam para outra (`same_as`), resolvidas num segundo
    // passo: o Patrulheiro Revisado concede o mesmo equipamento do
    // Patrulheiro, e duplicar o bloco no asset criaria duas verdades.
    final aliases = <String, String>{};
    final names = <String, String>{};

    for (final item in items) {
      final classId = (item['class_id'] as String?)?.trim();
      if (classId == null || classId.isEmpty) continue;

      final className = (item['class_name'] as String?)?.trim() ?? '';
      names[classId] = className;

      final sameAs = (item['same_as'] as String?)?.trim();
      if (sameAs != null && sameAs.isNotEmpty) {
        aliases[classId] = sameAs;
        continue;
      }

      parsed.add(
        ClassStartingEquipment(
          classId: classId,
          className: className,
          fixedItems: _parseClassEquipmentItems(_asList(item['fixed_items'])),
          fixedPicks: _parseClassEquipmentPicks(_asList(item['fixed_picks'])),
          groups: _parseClassEquipmentGroups(_asList(item['groups'])),
          source: (item['source'] as String?)?.trim() ?? 'phb',
          edition: (item['edition'] as String?)?.trim() ?? '2014',
        ),
      );
    }

    for (final entry in aliases.entries) {
      ClassStartingEquipment? target;
      for (final candidate in parsed) {
        if (candidate.classId == entry.value) {
          target = candidate;
          break;
        }
      }
      // Apontar para uma classe que não existe é dado quebrado, e some em vez
      // de derrubar a leitura das outras.
      if (target == null) continue;

      parsed.add(
        target.copyWith(
          classId: entry.key,
          className: names[entry.key] ?? target.className,
        ),
      );
    }

    return List<ClassStartingEquipment>.unmodifiable(parsed);
  }

  /// Lê os itens de equipamento de classe.
  ///
  /// Tolerante como o resto do compêndio: entrada sem id ou sem nome não tem
  /// como ser rastreada nem exibida, então some da lista em vez de derrubar a
  /// classe inteira. O teste de asset é quem garante que nenhuma sumiu.
  List<ClassEquipmentItem> _parseClassEquipmentItems(List<dynamic> raw) {
    final result = <ClassEquipmentItem>[];

    for (final entry in raw) {
      final map = _asMap(entry);
      final id = (map['id'] as String?)?.trim();
      final name = (map['name'] as String?)?.trim();
      if (id == null || id.isEmpty) continue;
      if (name == null || name.isEmpty) continue;

      final quantity = _asInt(map['quantity']) ?? 1;
      final weaponId = (map['weapon_id'] as String?)?.trim();
      final armorId = (map['armor_id'] as String?)?.trim();

      result.add(
        ClassEquipmentItem(
          id: id,
          name: name,
          quantity: quantity < 1 ? 1 : quantity,
          category: ItemCategory.fromIdOrOther(map['category'] as String?),
          weaponId: weaponId == null || weaponId.isEmpty ? null : weaponId,
          armorId: armorId == null || armorId.isEmpty ? null : armorId,
          isShield: _asBool(map['shield']),
          description: (map['description'] as String?)?.trim() ?? '',
        ),
      );
    }

    return List<ClassEquipmentItem>.unmodifiable(result);
  }

  List<ClassEquipmentPick> _parseClassEquipmentPicks(List<dynamic> raw) {
    final result = <ClassEquipmentPick>[];

    for (final entry in raw) {
      final map = _asMap(entry);
      final id = (map['id'] as String?)?.trim();
      if (id == null || id.isEmpty) continue;

      final count = _asInt(map['count']) ?? 1;
      final category = WeaponCategory.fromId(map['weapon_category'] as String?);
      final options = _parseClassEquipmentItems(_asList(map['options']));

      // Sem categoria de arma e sem lista explícita não há o que escolher: a
      // escolha ficaria eternamente pendente e travaria a criação.
      if (category == null && options.isEmpty) continue;

      result.add(
        ClassEquipmentPick(
          id: id,
          label: (map['label'] as String?)?.trim() ?? '',
          count: count < 1 ? 1 : count,
          allowDuplicates: _asBool(map['allow_duplicates']),
          weaponCategory: category,
          rangeType: WeaponRangeType.fromId(map['range_type'] as String?),
          explicitOptions: options,
        ),
      );
    }

    return List<ClassEquipmentPick>.unmodifiable(result);
  }

  List<ClassEquipmentGroup> _parseClassEquipmentGroups(List<dynamic> raw) {
    final result = <ClassEquipmentGroup>[];

    for (final entry in raw) {
      final map = _asMap(entry);
      final id = (map['id'] as String?)?.trim();
      if (id == null || id.isEmpty) continue;

      final options = <ClassEquipmentOption>[];
      for (final optionRaw in _asList(map['options'])) {
        final option = _asMap(optionRaw);
        final optionId = (option['id'] as String?)?.trim();
        if (optionId == null || optionId.isEmpty) continue;

        final items = _parseClassEquipmentItems(_asList(option['items']));
        final picks = _parseClassEquipmentPicks(_asList(option['picks']));

        // Alternativa que não entrega nem pede nada não é alternativa.
        if (items.isEmpty && picks.isEmpty) continue;

        options.add(
          ClassEquipmentOption(
            id: optionId,
            label: (option['label'] as String?)?.trim() ?? optionId,
            items: items,
            picks: picks,
            note: (option['note'] as String?)?.trim() ?? '',
          ),
        );
      }

      if (options.isEmpty) continue;

      final choose = _asInt(map['choose']) ?? 1;
      final requires = (map['requires_option'] as String?)?.trim();

      result.add(
        ClassEquipmentGroup(
          id: id,
          label: (map['label'] as String?)?.trim() ?? '',
          // Não faz sentido pedir mais alternativas do que existem.
          choose:
              choose < 1
                  ? 1
                  : (choose > options.length ? options.length : choose),
          options: List<ClassEquipmentOption>.unmodifiable(options),
          requiresOptionId:
              requires == null || requires.isEmpty ? null : requires,
        ),
      );
    }

    return List<ClassEquipmentGroup>.unmodifiable(result);
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
      action: FeatureAction.tryParse(item['action']),
      initiative: InitiativeRule.tryParse(item['initiative']),
      effects: FeatureEffect.parseList(item['effects']),
      choice: FeatureChoice.tryParse(item['choice']),
      languageGrants: LanguageGrant.parseList(
        item['language_grants'],
        idPrefix: 'feature.${LanguageEntry.normalizeName(
          item['name'] as String? ?? '',
        )}',
      ),
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
