import 'package:dnd_ficha_app/features/character/domain/services/granted_ability_increases.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

/// Um talento que o personagem pegou.
///
/// O id do talento aponta para o compêndio; aqui ficam só as decisões do
/// jogador e o efeito que elas tiveram na ficha.
class CharacterFeat {
  const CharacterFeat({
    required this.featId,
    this.localId,
    this.classId,
    this.level,
    this.chosenSkillIds = const [],
    this.grantedSkillIds = const [],
    this.chosenAbility,
    this.appliedAbilityIncreases = const {},
  });

  /// Chave da linha no banco. Nulo em talento recém-montado, ainda não salvo.
  final int? localId;

  /// Id no compêndio (`FeatEntry.id`).
  final String featId;

  /// Classe que concedeu a escolha, e nível dela em que isso aconteceu.
  ///
  /// Servem para a ficha saber quantas escolhas de talento já foram gastas por
  /// classe, já que o personagem multiclasse ganha talento por classe.
  final String? classId;
  final int? level;

  /// Perícias que o jogador escolheu dentro das opções do talento.
  final List<String> chosenSkillIds;

  /// Perícias que este talento realmente passou a conceder.
  ///
  /// Subconjunto do que o talento oferece: uma perícia que o personagem já
  /// tinha não entra aqui, senão remover o talento apagaria uma proficiência
  /// que vinha da classe ou do antecedente.
  final List<String> grantedSkillIds;

  /// Atributo que o jogador escolheu, quando o talento deixa escolher.
  ///
  /// Guardado separado de [appliedAbilityIncreases] porque responde outra
  /// pergunta: um Resiliente pego com Constituição já em 20 não aumenta nada,
  /// mas a ficha ainda precisa dizer "Resiliente (Constituição)".
  final Ability? chosenAbility;

  /// Quanto este talento realmente somou em cada atributo.
  ///
  /// Mesma ideia de [grantedSkillIds]: é o efeito que de fato aconteceu, não o
  /// que o talento promete. Atributo que já estava no teto de 20 não entra
  /// aqui, senão remover o talento tiraria um ponto que ele nunca deu.
  final Map<String, int> appliedAbilityIncreases;

  bool get increasesAbility => appliedAbilityIncreases.isNotEmpty;

  List<Skill> get chosenSkills => _resolve(chosenSkillIds);

  List<Skill> get grantedSkills => _resolve(grantedSkillIds);

  static List<Skill> _resolve(List<String> ids) {
    return [
      for (final id in ids)
        if (Skill.fromId(id) case final skill?) skill,
    ];
  }

  String get chosenSkillsAsCsv => chosenSkillIds.join(',');

  String get grantedSkillsAsCsv => grantedSkillIds.join(',');

  String get appliedAbilityIncreasesAsCsv =>
      GrantedAbilityIncreases.toCsv(appliedAbilityIncreases);

  /// Lê o CSV guardado no banco, tolerando nulo, vazio e espaços soltos.
  static List<String> parseSkillIdsCsv(String? raw) {
    if (raw == null) return const [];

    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  CharacterFeat copyWith({
    int? localId,
    String? featId,
    String? classId,
    int? level,
    List<String>? chosenSkillIds,
    List<String>? grantedSkillIds,
    Ability? chosenAbility,
    Map<String, int>? appliedAbilityIncreases,
  }) {
    return CharacterFeat(
      localId: localId ?? this.localId,
      featId: featId ?? this.featId,
      classId: classId ?? this.classId,
      level: level ?? this.level,
      chosenSkillIds: chosenSkillIds ?? this.chosenSkillIds,
      grantedSkillIds: grantedSkillIds ?? this.grantedSkillIds,
      chosenAbility: chosenAbility ?? this.chosenAbility,
      appliedAbilityIncreases:
          appliedAbilityIncreases ?? this.appliedAbilityIncreases,
    );
  }
}
