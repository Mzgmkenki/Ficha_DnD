import 'package:dnd_ficha_app/features/character/domain/entities/combat_option.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';

/// As opções que todo personagem tem por ser um personagem, sem depender de
/// classe, raça ou item (PHB 2014, capítulo 9).
///
/// Ficam como dado, e não espalhadas na tela, porque são a base da lista: o
/// resolvedor acrescenta o que a build concede por cima destas.
///
/// Atacar não está aqui com número de ataques fixo de propósito — a contagem
/// vem das características da build, e é o resolvedor que preenche.
class UniversalCombatActions {
  const UniversalCombatActions._();

  /// Id da ação de Atacar, que o resolvedor precisa reencontrar para ajustar a
  /// quantidade de ataques.
  static const String attackId = 'universal.attack';

  static const List<CombatOption> all = [
    CombatOption(
      id: attackId,
      name: 'Atacar',
      summary: 'Um ataque corpo a corpo ou à distância.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      priority: 0,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.cast',
      name: 'Conjurar magia',
      summary: 'Conjura uma magia cujo tempo de conjuração seja de 1 ação.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      priority: 1,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.dash',
      name: 'Correr',
      summary: 'Ganha deslocamento extra igual ao seu deslocamento.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      priority: 10,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.disengage',
      name: 'Desengajar',
      summary: 'Seu movimento não provoca ataques de oportunidade neste turno.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      priority: 11,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.dodge',
      name: 'Esquivar',
      summary:
          'Ataques contra você têm desvantagem e você tem vantagem em '
          'salvaguardas de Destreza, até seu próximo turno.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      requirement: 'Perde o efeito se ficar Incapacitado ou com deslocamento 0.',
      priority: 12,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.help',
      name: 'Ajudar',
      summary:
          'Dá vantagem no próximo teste de um aliado, ou no próximo ataque '
          'dele contra um inimigo a até 1,5 m de você.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      priority: 13,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.hide',
      name: 'Esconder-se',
      summary: 'Teste de Furtividade para ficar escondido.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      priority: 14,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.ready',
      name: 'Preparar uma ação',
      summary:
          'Escolhe um gatilho e a ação a executar quando ele acontecer. '
          'A execução gasta sua reação.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      priority: 15,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.search',
      name: 'Procurar',
      summary: 'Teste de Percepção ou Investigação para achar algo.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      priority: 16,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.use_object',
      name: 'Usar objeto',
      summary:
          'Usa um objeto que exija ação, ou uma segunda interação com objeto '
          'no mesmo turno.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      priority: 17,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.improvise',
      name: 'Improvisar',
      summary: 'Qualquer coisa fora da lista, com o mestre decidindo como.',
      actionType: CombatActionType.action,
      source: CombatOptionSource.universal,
      priority: 30,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.opportunity_attack',
      name: 'Ataque de oportunidade',
      summary: 'Um ataque corpo a corpo em quem sair do seu alcance.',
      actionType: CombatActionType.reaction,
      source: CombatOptionSource.universal,
      trigger: 'Uma criatura hostil sai do seu alcance corpo a corpo.',
      priority: 0,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.move',
      name: 'Mover',
      summary: 'Anda, escala, nada ou salta dentro do seu deslocamento.',
      actionType: CombatActionType.movement,
      source: CombatOptionSource.universal,
      priority: 0,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.stand_up',
      name: 'Levantar-se',
      summary: 'Sair de Caído custa metade do seu deslocamento.',
      actionType: CombatActionType.movement,
      source: CombatOptionSource.universal,
      requirement: 'Só quando estiver Caído.',
      priority: 5,
      ruleReference: 'PHB, cap. 9',
    ),
    CombatOption(
      id: 'universal.interact',
      name: 'Interagir com objeto',
      summary:
          'Saca ou guarda uma arma, abre uma porta, pega algo do chão. '
          'Uma por turno de graça; a segunda exige a ação de Usar objeto.',
      actionType: CombatActionType.freeInteraction,
      source: CombatOptionSource.universal,
      priority: 0,
      ruleReference: 'PHB, cap. 9',
    ),
  ];
}
