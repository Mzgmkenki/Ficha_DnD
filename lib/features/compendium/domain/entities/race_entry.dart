import 'package:dnd_ficha_app/features/compendium/domain/entities/ability_score_rule.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_choice_group.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_spell_feature.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_trait.dart';

class RaceEntry {
  const RaceEntry({
    required this.id,
    required this.name,
    required this.source,

    // Compatibilidade com o que já existe
    this.size,
    this.speed,
    this.allowsCustomOrigin = true,
    this.fixedAbilityBonuses = const {},
    this.traits = const [],

    // Estrutura nova
    this.parentRaceId,
    this.isSubrace = false,
    this.description,
    this.sizeOptions = const [],
    this.creatureType,
    this.darkvision,
    this.languages = const [],
    this.skillOptions = const [],
    this.abilityScoreRules = const [],
    this.spellcasting = const [],
    this.choiceGroups = const [],
    this.tags = const [],
  });

  final String id;
  final String name;
  final String source;

  // ===== COMPATIBILIDADE ANTIGA =====
  final String? size;
  final int? speed;
  final bool allowsCustomOrigin;
  final Map<String, int> fixedAbilityBonuses;
  final List<String> traits;

  // ===== ESTRUTURA NOVA =====
  final String? parentRaceId;
  final bool isSubrace;
  final String? description;
  final List<String> sizeOptions;
  final String? creatureType;
  final int? darkvision;
  final List<String> languages;
  final List<String> skillOptions;
  final List<AbilityScoreRule> abilityScoreRules;
  final List<RaceSpellFeature> spellcasting;
  final List<RaceChoiceGroup> choiceGroups;
  final List<String> tags;

  bool get hasSubraceParent => parentRaceId != null && parentRaceId!.isNotEmpty;

  List<String> get effectiveSizeOptions {
    if (sizeOptions.isNotEmpty) return sizeOptions;
    if (size != null && size!.trim().isNotEmpty) return [size!];
    return const [];
  }

  List<RaceTrait> get structuredTraits {
    return traits
        .asMap()
        .entries
        .map(
          (entry) => RaceTrait(
            id: '${id}_trait_${entry.key}',
            name: 'Traço ${entry.key + 1}',
            description: entry.value,
          ),
        )
        .toList(growable: false);
  }

  RaceEntry copyWith({
    String? id,
    String? name,
    String? source,
    String? size,
    int? speed,
    bool? allowsCustomOrigin,
    Map<String, int>? fixedAbilityBonuses,
    List<String>? traits,
    String? parentRaceId,
    bool? isSubrace,
    String? description,
    List<String>? sizeOptions,
    String? creatureType,
    int? darkvision,
    List<String>? languages,
    List<String>? skillOptions,
    List<AbilityScoreRule>? abilityScoreRules,
    List<RaceSpellFeature>? spellcasting,
    List<RaceChoiceGroup>? choiceGroups,
    List<String>? tags,
  }) {
    return RaceEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      size: size ?? this.size,
      speed: speed ?? this.speed,
      allowsCustomOrigin: allowsCustomOrigin ?? this.allowsCustomOrigin,
      fixedAbilityBonuses: fixedAbilityBonuses ?? this.fixedAbilityBonuses,
      traits: traits ?? this.traits,
      parentRaceId: parentRaceId ?? this.parentRaceId,
      isSubrace: isSubrace ?? this.isSubrace,
      description: description ?? this.description,
      sizeOptions: sizeOptions ?? this.sizeOptions,
      creatureType: creatureType ?? this.creatureType,
      darkvision: darkvision ?? this.darkvision,
      languages: languages ?? this.languages,
      skillOptions: skillOptions ?? this.skillOptions,
      abilityScoreRules: abilityScoreRules ?? this.abilityScoreRules,
      spellcasting: spellcasting ?? this.spellcasting,
      choiceGroups: choiceGroups ?? this.choiceGroups,
      tags: tags ?? this.tags,
    );
  }
}