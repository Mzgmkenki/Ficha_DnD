import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_prerequisite.dart';

/// Perícias que o talento deixa o jogador escolher.
///
/// Separado de [FeatEntry.skillIds] porque as duas coisas coexistem: um
/// talento pode conceder uma perícia fixa e ainda deixar escolher outras.
class FeatSkillChoice {
  const FeatSkillChoice({required this.choose, this.options = const []});

  /// Quantas perícias o jogador escolhe.
  final int choose;

  /// Ids de [Skill] entre os quais escolher. Vazio significa "qualquer
  /// perícia", que é o caso do talento Versátil.
  final List<String> options;

  /// As opções resolvidas; lista cheia quando o talento não restringe.
  List<Skill> get skills {
    if (options.isEmpty) return Skill.sortedByLabel;

    return [
      for (final id in options)
        if (Skill.fromId(id) case final skill?) skill,
    ];
  }

  bool get isEmpty => choose <= 0;
}

/// Um talento do compêndio.
///
/// Formato esperado em `assets/data/srd/feats.json` (chaves em snake_case,
/// como nos outros arquivos do compêndio):
///
/// ```json
/// [
///   {
///     "id": "skilled",
///     "name": "Habilidoso",
///     "name_original": "Skilled",
///     "description": "Proficiência em 3 perícias ou ferramentas à escolha.",
///     "prerequisite": "Nenhum",
///     "requires": {
///       "min_level": 4,
///       "min_ability_any": { "dexterity": 13 },
///       "spellcasting": true,
///       "race_ids": ["dwarf_phb"],
///       "race_sizes": ["small"],
///       "class_ids": ["wizard"],
///       "feat_ids": ["squire_of_solamnia"],
///       "not_feat_ids": ["aberrant_dragonmark"],
///       "notes": ["Proficiência com armaduras médias"]
///     },
///     "repeatable": false,
///     "skills": [],
///     "skill_choice": { "choose": 3, "options": [] },
///     "ability_increases": { "strength": 1 },
///     "ability_increase_options": ["strength", "dexterity"],
///     "source": "phb"
///   }
/// ]
/// ```
///
/// `skills` são as perícias concedidas direto; `skill_choice` é o que o jogador
/// escolhe. Os dois podem aparecer juntos. `requires` é a parte verificável do
/// pré-requisito; `prerequisite` é só o texto exibido.
class FeatEntry {
  const FeatEntry({
    required this.id,
    required this.name,
    this.nameOriginal,
    this.description,
    this.prerequisite,
    this.requires = const FeatPrerequisite(),
    this.repeatable = false,
    this.skillIds = const [],
    this.skillChoice,
    this.abilityIncreases = const {},
    this.abilityIncreaseOptions = const [],
    this.source = 'phb',
  });

  final String id;
  final String name;

  /// Nome em inglês, para achar o talento no livro ou no D&D Beyond.
  final String? nameOriginal;

  final String? description;

  /// Pré-requisito em texto, como aparece no livro. É o que a tela mostra.
  final String? prerequisite;

  /// A parte do pré-requisito que o app consegue conferir.
  final FeatPrerequisite requires;

  /// Se o talento pode ser pego mais de uma vez.
  final bool repeatable;

  /// Perícias concedidas direto, por id de [Skill].
  final List<String> skillIds;

  /// Perícias que o jogador escolhe ao pegar o talento.
  final FeatSkillChoice? skillChoice;

  /// Aumentos de atributo fixos, por nome de atributo em inglês.
  final Map<String, int> abilityIncreases;

  /// Atributos entre os quais o jogador escolhe um para receber +1.
  ///
  /// Guardado porque o dado está no compêndio, mas ainda não é aplicado na
  /// ficha: aplicar exigiria decidir o que fazer ao remover o talento e como
  /// respeitar o teto de 20, e isso é uma feature própria.
  final List<String> abilityIncreaseOptions;

  final String source;

  /// As perícias concedidas direto, já resolvidas. Ids inválidos são
  /// ignorados, como em `BackgroundEntry.skills`.
  List<Skill> get skills {
    return [
      for (final id in skillIds)
        if (Skill.fromId(id) case final skill?) skill,
    ];
  }

  /// Quantas perícias o jogador precisa escolher neste talento.
  int get skillsToChoose => skillChoice?.choose ?? 0;

  /// Se o talento mexe em perícia de alguma forma.
  bool get touchesSkills => skillIds.isNotEmpty || skillsToChoose > 0;
}
