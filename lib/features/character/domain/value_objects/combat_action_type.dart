/// A economia de ações de um turno em D&D 5e (PHB 2014, capítulo 9).
///
/// A ordem dos valores é a ordem de exibição na ficha, e é proposital: no turno
/// o jogador decide primeiro o que faz com a ação, depois com a ação bônus, e
/// só então o que reservou para fora do próprio turno.
enum CombatActionType {
  action('action', 'Ação', 'Uma por turno.'),
  bonusAction('bonus', 'Ação bônus', 'Uma por turno, e só se algo conceder.'),
  reaction('reaction', 'Reação', 'Uma por rodada, fora do seu turno.'),
  movement('movement', 'Movimento', 'Até o seu deslocamento, dividido como quiser.'),
  freeInteraction(
    'free',
    'Interação livre',
    'Uma interação com objeto por turno, sem gastar ação.',
  ),

  /// Recurso que não é em si um tipo de ação, mas muda o turno: Surto de Ação
  /// concede uma ação inteira a mais, e Fúria não custa a ação do turno.
  special('special', 'Recurso especial', 'Muda a economia do turno.');

  const CombatActionType(this.id, this.label, this.economyNote);

  /// Identificador estável, usado no asset e no que for persistido.
  ///
  /// Separado do `name` do enum de propósito, pelo mesmo motivo de
  /// `Condition.id`: renomear o valor em Dart não pode invalidar dado salvo.
  final String id;

  final String label;

  /// Uma linha explicando o limite do tipo, para o painel não precisar repetir
  /// a regra em cada item.
  final String economyNote;

  /// Se o tipo compete com outros pelo mesmo espaço do turno.
  ///
  /// Movimento e interação livre não competem: o jogador faz os dois junto com
  /// qualquer ação. É o que permite a área de possibilidades combinar sem
  /// sugerir algo ilegal.
  bool get isExclusive =>
      this == CombatActionType.action ||
      this == CombatActionType.bonusAction ||
      this == CombatActionType.reaction;

  static CombatActionType? fromId(String? id) {
    if (id == null) return null;

    final normalized = id.trim().toLowerCase();
    for (final type in CombatActionType.values) {
      if (type.id == normalized) return type;
    }

    // Sinônimos que aparecem em texto escrito à mão no asset.
    switch (normalized) {
      case 'bonus_action':
      case 'bonusaction':
      case 'acao_bonus':
        return CombatActionType.bonusAction;
      case 'acao':
        return CombatActionType.action;
      case 'reacao':
        return CombatActionType.reaction;
      case 'movimento':
        return CombatActionType.movement;
      default:
        return null;
    }
  }
}

/// De onde a opção veio, para a ficha dizer por que ela está na lista.
enum CombatOptionSource {
  universal('universal', 'Regra geral'),
  classFeature('class', 'Classe'),
  subclassFeature('subclass', 'Subclasse'),
  racialTrait('race', 'Raça'),
  feat('feat', 'Talento'),
  spell('spell', 'Magia'),
  magicItem('item', 'Item mágico');

  const CombatOptionSource(this.id, this.label);

  final String id;
  final String label;
}

/// Quando o recurso volta.
enum ActionRecharge {
  shortRest('short', 'descanso curto'),
  longRest('long', 'descanso longo'),
  turn('turn', 'início do seu turno'),
  round('round', 'rodada'),
  dawn('dawn', 'amanhecer'),

  /// Sem limite de usos: não gasta recurso nenhum.
  none('none', 'sem limite');

  const ActionRecharge(this.id, this.label);

  final String id;
  final String label;

  static ActionRecharge? fromId(String? id) {
    if (id == null) return null;

    final normalized = id.trim().toLowerCase();
    for (final rule in ActionRecharge.values) {
      if (rule.id == normalized) return rule;
    }

    switch (normalized) {
      case 'short_rest':
      case 'descanso_curto':
        return ActionRecharge.shortRest;
      case 'long_rest':
      case 'descanso_longo':
        return ActionRecharge.longRest;
      default:
        return null;
    }
  }
}
