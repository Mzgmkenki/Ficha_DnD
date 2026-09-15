import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';

/// Decide quais talentos o personagem pode pegar.
///
/// A regra pedida é esconder o que ele não alcança. O cuidado está no que o app
/// NÃO sabe: proficiência com armadura, cenário de campanha e antecedentes de
/// outros livros não existem na ficha. Essas exigências ficam em
/// `FeatPrerequisite.notes` e não escondem nada — esconder por falta de dado
/// tiraria da lista talentos que o personagem realmente pode ter.
class FeatEligibility {
  const FeatEligibility._();

  /// Se [feat] pode ser escolhido por [character].
  ///
  /// [classes] e [races] vêm do compêndio: a classe diz se o personagem conjura
  /// e a raça resolve sub-raça para raça mãe.
  static bool meets(
    FeatEntry feat, {
    required Character character,
    List<ClassEntry> classes = const [],
    List<RaceEntry> races = const [],
  }) {
    return missingRequirements(
      feat,
      character: character,
      classes: classes,
      races: races,
    ).isEmpty;
  }

  /// O que falta para [character] pegar [feat], em texto.
  ///
  /// Devolve lista vazia quando ele cumpre tudo. Existe separado de [meets]
  /// porque é o que permite testar POR QUE um talento ficou de fora, em vez de
  /// só saber que ficou.
  static List<String> missingRequirements(
    FeatEntry feat, {
    required Character character,
    List<ClassEntry> classes = const [],
    List<RaceEntry> races = const [],
  }) {
    final requires = feat.requires;
    final missing = <String>[];

    if (character.totalLevel < requires.minLevel) {
      missing.add('nível ${requires.minLevel}');
    }

    if (requires.minAbilityAny.isNotEmpty) {
      final reached = requires.minAbilityAny.entries.any(
        (entry) => _abilityScore(character, entry.key) >= entry.value,
      );

      if (!reached) {
        missing.add(
          requires.minAbilityAny.entries
              .map((entry) => '${_abilityLabel(entry.key)} ${entry.value}')
              .join(' ou '),
        );
      }
    }

    if (requires.requiresSpellcasting && !_canCast(character, classes)) {
      missing.add('saber conjurar');
    }

    if (requires.hasRaceCondition &&
        !_matchesRace(character, races, requires.raceIds, requires.raceSizes)) {
      missing.add('a raça exigida');
    }

    if (requires.classIds.isNotEmpty) {
      final has = character.classLevels.any(
        (item) => requires.classIds.contains(item.classId),
      );
      if (!has) missing.add('a classe exigida');
    }

    for (final required in requires.requiredFeatIds) {
      final has = character.feats.any((item) => item.featId == required);
      if (!has) missing.add('o talento $required');
    }

    for (final forbidden in requires.forbiddenFeatIds) {
      final has = character.feats.any((item) => item.featId == forbidden);
      if (has) missing.add('não ter o talento $forbidden');
    }

    return missing;
  }

  /// Os talentos de [feats] que [character] pode pegar agora.
  ///
  /// Já tira da lista o que ele tem e não é repetível, porque oferecer uma
  /// escolha que o caso de uso vai recusar é pior que não oferecer.
  static List<FeatEntry> available({
    required List<FeatEntry> feats,
    required Character character,
    List<ClassEntry> classes = const [],
    List<RaceEntry> races = const [],
  }) {
    final taken = character.feats.map((item) => item.featId).toSet();

    return [
      for (final feat in feats)
        if ((feat.repeatable || !taken.contains(feat.id)) &&
            meets(feat, character: character, classes: classes, races: races))
          feat,
    ];
  }

  static bool _matchesRace(
    Character character,
    List<RaceEntry> races,
    List<String> acceptedIds,
    List<String> acceptedSizes,
  ) {
    final speciesId = character.speciesId;
    if (speciesId == null || speciesId.isEmpty) return false;

    if (acceptedIds.contains(speciesId)) return true;

    RaceEntry? entry;
    for (final race in races) {
      if (race.id == speciesId) {
        entry = race;
        break;
      }
    }

    if (entry == null) return false;

    // Sub-raça cumpre o pré-requisito da raça mãe: quem é Elfo Alto é elfo.
    final parentId = entry.parentRaceId;
    if (parentId != null && acceptedIds.contains(parentId)) return true;

    final size = entry.size?.trim().toLowerCase();
    return size != null && acceptedSizes.contains(size);
  }

  /// Se o personagem já conjura de verdade.
  ///
  /// Não basta a classe ser conjuradora: paladino de 1º nível ainda não conjura,
  /// e o pré-requisito é "capacidade de conjurar pelo menos uma magia".
  static bool _canCast(Character character, List<ClassEntry> classes) {
    for (final classLevel in character.classLevels) {
      for (final entry in classes) {
        if (entry.id != classLevel.classId) continue;
        if (entry.isSpellcaster &&
            classLevel.level >= entry.spellcastingStartLevel) {
          return true;
        }
        break;
      }
    }

    return false;
  }

  static int _abilityScore(Character character, String ability) {
    final scores = character.abilityScores;

    switch (ability) {
      case 'strength':
        return scores.strength;
      case 'dexterity':
        return scores.dexterity;
      case 'constitution':
        return scores.constitution;
      case 'intelligence':
        return scores.intelligence;
      case 'wisdom':
        return scores.wisdom;
      case 'charisma':
        return scores.charisma;
      default:
        return 0;
    }
  }

  static String _abilityLabel(String ability) {
    switch (ability) {
      case 'strength':
        return 'Força';
      case 'dexterity':
        return 'Destreza';
      case 'constitution':
        return 'Constituição';
      case 'intelligence':
        return 'Inteligência';
      case 'wisdom':
        return 'Sabedoria';
      case 'charisma':
        return 'Carisma';
      default:
        return ability;
    }
  }
}
