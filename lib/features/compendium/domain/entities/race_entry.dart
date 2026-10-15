import 'package:dnd_ficha_app/features/compendium/domain/entities/ability_bonus_mode.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/initiative_rule.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_grant.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_choice_group.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_skill_choice.dart';

class RaceEntry {
  const RaceEntry({
    required this.id,
    required this.name,
    required this.source,
    this.size,
    this.speed,
    this.allowsCustomOrigin = true,
    this.abilityBonusMode = AbilityBonusMode.fixed,
    this.fixedAbilityBonuses = const {},
    this.abilityBonusChoices = const [],
    this.grantedSkills = const [],
    this.grantsFeat = false,
    this.skillChoice,
    this.traits = const [],
    this.initiative,
    this.parentRaceId,
    this.isSubrace = false,
    this.description,
    this.sizeOptions = const [],
    this.creatureType,
    this.darkvision,
    this.languages = const [],
    this.languageGrants = const [],
    this.choiceGroups = const [],
    this.tags = const [],
  });

  final String id;
  final String name;
  final String source;

  final String? size;

  /// Deslocamento em metros.
  ///
  /// Decimal porque anão, halfling e gnomo andam 7,5 m e elfo da floresta,
  /// sátiro e genasi do ar andam 10,5 m. Com inteiro esses valores viravam
  /// 7 e 10.
  final double? speed;

  /// Permite trocar os bônus da raça pelos da origem personalizada (Tasha).
  /// Não se aplica a quem já usa o padrão flexível.
  final bool allowsCustomOrigin;

  final AbilityBonusMode abilityBonusMode;

  /// Bônus que a raça define, por nome de atributo.
  final Map<String, int> fixedAbilityBonuses;

  /// Valores que o jogador distribui quando o modo é [AbilityBonusMode.choice].
  /// Ex.: `[1, 1]` no Meio-Elfo, `[2]` na Linhagem Personalizada.
  final List<int> abilityBonusChoices;

  /// Perícias concedidas direto pela raça, por id de `Skill`.
  final List<String> grantedSkills;

  /// Se a raça concede um talento já no 1º nível.
  ///
  /// É a exceção do Humano Variante, que troca o +1 nos seis atributos por
  /// perícia e talento. Fica como dado do compêndio, e não como um id fixo no
  /// código, porque a Linhagem Personalizada tem a mesma regra e outras podem
  /// aparecer.
  final bool grantsFeat;

  final RaceSkillChoice? skillChoice;

  final List<String> traits;

  /// O que a raça faz com a iniciativa, quando faz algo.
  ///
  /// Fica no nível da raça, e não dentro de [traits], porque os traços são
  /// texto puro: dar estrutura a um deles obrigaria a mudar o formato dos
  /// outros trezentos. Por isso a regra traz um `note` com o nome do traço —
  /// hoje só o Gatilho de Lebre do harengon.
  final InitiativeRule? initiative;

  final String? parentRaceId;
  final bool isSubrace;

  final String? description;
  final List<String> sizeOptions;
  final String? creatureType;

  /// Alcance da visão no escuro, em metros.
  final int? darkvision;

  /// Idiomas em texto livre, como o livro escreve.
  ///
  /// Continua existindo para o resumo da raça e o PDF, que mostram a frase
  /// pronta. Quem decide o que o personagem RECEBE é [languageGrants]: texto
  /// livre não tem id estável e não dá para validar escolha contra ele.
  final List<String> languages;

  /// O que a raça concede em idiomas, em forma estruturada.
  ///
  /// Vazio significa "a raça não declara concessão" — e aí nada é inferido do
  /// texto de [languages], porque adivinhar produziria idioma que a regra não
  /// dá. Sub-raça costuma vir vazia e herdar a da raça base.
  final List<LanguageGrant> languageGrants;

  final List<RaceChoiceGroup> choiceGroups;
  final List<String> tags;

  bool get hasParentRace {
    return parentRaceId != null && parentRaceId!.trim().isNotEmpty;
  }

  bool get shouldBeTreatedAsSubrace {
    return isSubrace || hasParentRace;
  }

  RaceEntry copyWith({
    String? id,
    String? name,
    String? source,
    String? size,
    double? speed,
    bool? allowsCustomOrigin,
    AbilityBonusMode? abilityBonusMode,
    Map<String, int>? fixedAbilityBonuses,
    List<int>? abilityBonusChoices,
    List<String>? grantedSkills,
    bool? grantsFeat,
    RaceSkillChoice? skillChoice,
    List<String>? traits,
    InitiativeRule? initiative,
    String? parentRaceId,
    bool? isSubrace,
    String? description,
    List<String>? sizeOptions,
    String? creatureType,
    int? darkvision,
    List<String>? languages,
    List<LanguageGrant>? languageGrants,
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
      abilityBonusMode: abilityBonusMode ?? this.abilityBonusMode,
      fixedAbilityBonuses: fixedAbilityBonuses ?? this.fixedAbilityBonuses,
      abilityBonusChoices: abilityBonusChoices ?? this.abilityBonusChoices,
      grantedSkills: grantedSkills ?? this.grantedSkills,
      grantsFeat: grantsFeat ?? this.grantsFeat,
      skillChoice: skillChoice ?? this.skillChoice,
      traits: traits ?? this.traits,
      initiative: initiative ?? this.initiative,
      parentRaceId: parentRaceId ?? this.parentRaceId,
      isSubrace: isSubrace ?? this.isSubrace,
      description: description ?? this.description,
      sizeOptions: sizeOptions ?? this.sizeOptions,
      creatureType: creatureType ?? this.creatureType,
      darkvision: darkvision ?? this.darkvision,
      languages: languages ?? this.languages,
      languageGrants: languageGrants ?? this.languageGrants,
      choiceGroups: choiceGroups ?? this.choiceGroups,
      tags: tags ?? this.tags,
    );
  }
}
