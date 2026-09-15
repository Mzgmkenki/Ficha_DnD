import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

/// Proficiência em perícia concedida por uma fonte da ficha: antecedente,
/// raça ou talento.
///
/// Existe para as três fontes se comportarem igual. Antes a criação atribuía
/// direto (`levels[skill] = proficient`) e a edição de identidade aplicava com
/// guarda — no 1º nível a diferença não aparecia, mas um talento pego no 8º
/// nível rebaixaria um Especialista.
class GrantedSkills {
  const GrantedSkills._();

  /// Marca [skills] como proficientes, sem rebaixar quem já está acima.
  ///
  /// Especialista é sempre escolha do jogador e vale o dobro do bônus, então
  /// reaplicar uma fonte não pode transformá-lo em Proficiente.
  static SkillProficiencies apply(
    SkillProficiencies current,
    Iterable<Skill> skills,
  ) {
    var result = current;

    for (final skill in skills) {
      if (result.levelFor(skill).isProficientOrBetter) continue;
      result = result.withLevel(skill, ProficiencyLevel.proficient);
    }

    return result;
  }

  /// De [skills], as que a fonte realmente concedeu — ou seja, as que ainda
  /// não eram proficiência.
  ///
  /// É o que precisa ser guardado junto com a fonte para poder ser desfeito.
  /// O que já era proficiente veio de outro lugar (classe, raça, escolha do
  /// jogador) e não pode sair quando esta fonte sair.
  static List<Skill> newlyGranted(
    SkillProficiencies current,
    Iterable<Skill> skills,
  ) {
    return [
      for (final skill in skills)
        if (!current.levelFor(skill).isProficientOrBetter) skill,
    ];
  }

  /// Tira a proficiência das perícias que a fonte havia concedido.
  ///
  /// Só rebaixa quem está exatamente em Proficiente: se o jogador promoveu a
  /// perícia a Especialista depois, essa escolha vale mais que a fonte que
  /// está saindo.
  static SkillProficiencies revoke(
    SkillProficiencies current,
    Iterable<Skill> skills,
  ) {
    var result = current;

    for (final skill in skills) {
      if (result.levelFor(skill) != ProficiencyLevel.proficient) continue;
      result = result.withLevel(skill, ProficiencyLevel.none);
    }

    return result;
  }

  /// Converte ids de perícia em enum, descartando os que não existem.
  ///
  /// Id inválido vem de dado do compêndio escrito à mão; ignorar é melhor que
  /// derrubar a ficha.
  static List<Skill> fromIds(Iterable<String> ids) {
    return [
      for (final id in ids)
        if (Skill.fromId(id) case final skill?) skill,
    ];
  }
}
