import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiency_grant.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_skills.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

/// Resultado de uma reconciliação entre as perícias do antecedente e as que o
/// personagem já tinha.
///
/// [changed] existe para quem grava: aplicar isto ao abrir a ficha não pode
/// escrever no banco quando nada mudou.
class BackgroundSkillReconciliation {
  const BackgroundSkillReconciliation({
    required this.proficiencies,
    required this.grants,
    required this.changed,
  });

  final SkillProficiencies proficiencies;
  final List<SkillProficiencyGrant> grants;

  /// `false` quando a reconciliação não teve efeito nenhum.
  final bool changed;
}

/// Mantém as proficiências do antecedente em sincronia com a origem registrada.
///
/// Existe porque a ficha guarda duas coisas que precisam concordar: o nível de
/// proficiência por perícia (`SkillProficiencies`) e de onde cada proficiência
/// veio (`Character.skillProficiencyGrants`). A criação já montava as duas
/// juntas; a edição de identidade só mexia na primeira, então trocar o
/// antecedente somava perícia sem nunca tirar a do antecedente anterior e
/// deixava o registro de origem apontando para o antecedente antigo.
///
/// A regra que atravessa tudo aqui: só sai o que o antecedente sustentava
/// SOZINHO. Perícia que a classe, a raça, um talento ou uma escolha do jogador
/// também concedem fica, porque a origem está registrada e dá para saber.
abstract final class BackgroundSkillOrigins {
  /// As fontes que pertencem ao antecedente.
  static const Set<SkillGrantSource> sources = {
    SkillGrantSource.backgroundAutomatic,
    SkillGrantSource.backgroundChoice,
  };

  static bool isBackgroundSource(SkillGrantSource source) =>
      sources.contains(source);

  /// Troca o antecedente: tira o que só o anterior sustentava e aplica o novo.
  ///
  /// [grantedSkills] são as perícias fixas do antecedente novo (ou as duas
  /// escolhidas, no antecedente customizável). Passar lista vazia com
  /// [backgroundId] nulo limpa o que o antecedente concedia, sem encostar nas
  /// outras origens.
  ///
  /// Especialista nunca é rebaixado: é escolha do jogador e vale o dobro do
  /// bônus. Quando a perícia sobrevive por isso, a origem antiga é mantida —
  /// ficha com proficiência sem origem nenhuma é estado inválido, e a criação
  /// recusa gravar assim.
  static BackgroundSkillReconciliation reapply({
    required List<SkillProficiencyGrant> grants,
    required SkillProficiencies proficiencies,
    required List<Skill> grantedSkills,
    required String? backgroundId,
    required String? backgroundName,
    required bool isCustom,
  }) {
    final fromOtherSources = <SkillProficiencyGrant>[];
    final fromBackground = <SkillProficiencyGrant>[];

    for (final grant in grants) {
      if (isBackgroundSource(grant.source)) {
        fromBackground.add(grant);
      } else {
        fromOtherSources.add(grant);
      }
    }

    final sustainedElsewhere = {
      for (final grant in fromOtherSources) grant.skill,
    };
    final previous = {for (final grant in fromBackground) grant.skill};
    final incoming = grantedSkills.toSet();

    // Registradas pelo antecedente anterior, que o novo não concede e que
    // nenhuma outra origem sustenta.
    final candidates = previous
        .difference(incoming)
        .difference(sustainedElsewhere);

    // Dessas, saem só as que estão exatamente em Proficiente.
    final revoked = {
      for (final skill in candidates)
        if (proficiencies.levelFor(skill) == ProficiencyLevel.proficient) skill,
    };

    var nextProficiencies = GrantedSkills.revoke(proficiencies, revoked);
    nextProficiencies = GrantedSkills.apply(nextProficiencies, incoming);

    // Candidata que não foi revogada continua na ficha (Especialista), então a
    // origem dela precisa continuar registrada.
    final survivors = candidates.difference(revoked);
    final retained = [
      for (final grant in fromBackground)
        if (survivors.contains(grant.skill)) grant,
    ];

    final nextGrants = [
      ...fromOtherSources,
      ...retained,
      // Sem duplicar origem: perícia que outra fonte já registra fica com o
      // registro dela. A ficha mostra a perícia uma vez e soma o bônus uma
      // vez; registrar duas origens aqui faria a validação da criação tratar
      // como conflito e exigir substituição numa tela que não oferece essa
      // escolha.
      for (final skill in incoming)
        if (!sustainedElsewhere.contains(skill))
          _grantFor(
            skill: skill,
            backgroundId: backgroundId,
            backgroundName: backgroundName,
            isCustom: isCustom,
          ),
    ];

    return BackgroundSkillReconciliation(
      proficiencies: nextProficiencies,
      grants: nextGrants,
      changed: revoked.isNotEmpty || !_sameGrants(grants, nextGrants),
    );
  }

  /// Completa um personagem já salvo, sem repetir nada.
  ///
  /// Serve para as fichas criadas antes de a origem ser registrada: a coluna
  /// nasce vazia, e a perícia do antecedente pode nunca ter sido aplicada.
  ///
  /// Idempotente de propósito: rodar duas vezes no mesmo personagem não muda
  /// nada na segunda. O que falta é aplicado, o que existe é preservado, e
  /// escolha manual válida não é removida.
  ///
  /// [ambiguousSkills] são as perícias que a classe ou a raça do personagem
  /// também poderiam ter concedido. Quando a perícia já está proficiente e cai
  /// nessa lista, a proficiência é preservada e a origem fica SEM registro, em
  /// vez de atribuir ao antecedente um palpite que pode estar errado.
  static BackgroundSkillReconciliation backfill({
    required List<SkillProficiencyGrant> grants,
    required SkillProficiencies proficiencies,
    required List<Skill> grantedSkills,
    required String? backgroundId,
    required String? backgroundName,
    required bool isCustom,
    Set<Skill> ambiguousSkills = const {},
  }) {
    final registered = {for (final grant in grants) grant.skill};
    final alreadyFromThisBackground = {
      for (final grant in grants)
        if (isBackgroundSource(grant.source) && grant.sourceId == backgroundId)
          grant.skill,
    };

    final added = <SkillProficiencyGrant>[];
    var nextProficiencies = proficiencies;

    for (final skill in grantedSkills) {
      // Já registrada por ESTE antecedente: nada a fazer. É o que torna a
      // correção idempotente.
      if (alreadyFromThisBackground.contains(skill)) continue;

      final isProficient =
          nextProficiencies.levelFor(skill).isProficientOrBetter;

      if (!isProficient) {
        // Caso inequívoco: o antecedente concede e a ficha não tem. Faltou.
        nextProficiencies = GrantedSkills.apply(nextProficiencies, [skill]);
        added.add(
          _grantFor(
            skill: skill,
            backgroundId: backgroundId,
            backgroundName: backgroundName,
            isCustom: isCustom,
          ),
        );
        continue;
      }

      // Proficiente e já com origem registrada por outra fonte: preserva como
      // está, sem segundo registro.
      if (registered.contains(skill)) continue;

      // Proficiente, sem origem nenhuma, e a classe ou a raça também poderiam
      // ter concedido: não há como atribuir com segurança.
      if (ambiguousSkills.contains(skill)) continue;

      // Proficiente, sem origem, e só o antecedente explica: registra.
      added.add(
        _grantFor(
          skill: skill,
          backgroundId: backgroundId,
          backgroundName: backgroundName,
          isCustom: isCustom,
        ),
      );
    }

    return BackgroundSkillReconciliation(
      proficiencies: nextProficiencies,
      grants: added.isEmpty ? grants : [...grants, ...added],
      changed: added.isNotEmpty,
    );
  }

  static SkillProficiencyGrant _grantFor({
    required Skill skill,
    required String? backgroundId,
    required String? backgroundName,
    required bool isCustom,
  }) {
    final name = backgroundName?.trim();

    return SkillProficiencyGrant(
      skill: skill,
      // O customizável é escolha do jogador; o do compêndio é concessão fixa.
      // É a mesma distinção que a criação faz.
      source:
          isCustom
              ? SkillGrantSource.backgroundChoice
              : SkillGrantSource.backgroundAutomatic,
      sourceId: backgroundId ?? '',
      sourceLabel:
          isCustom
              ? 'antecedente personalizado'
              : 'antecedente ${name == null || name.isEmpty ? backgroundId ?? '' : name}',
      automatic: !isCustom,
    );
  }

  static bool _sameGrants(
    List<SkillProficiencyGrant> a,
    List<SkillProficiencyGrant> b,
  ) {
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i].skill != b[i].skill ||
          a[i].source != b[i].source ||
          a[i].sourceId != b[i].sourceId) {
        return false;
      }
    }

    return true;
  }
}
