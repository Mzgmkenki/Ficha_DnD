import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';

/// O que o Painel de combate tem de notável, resumido.
///
/// Existe para a ficha e o painel contarem a mesma coisa. O botão na ficha
/// mostra este resumo e as abas mostram o detalhe; se cada lado fizesse a
/// própria conta, os dois divergiriam na primeira mudança de regra.
///
/// Só lê o personagem — nada de compêndio nem de leitura assíncrona. É o que
/// permite a ficha mostrar o resumo sem pagar o custo que recolher as seções
/// evitava: contar as opções de ação obrigaria a resolver a lista inteira de
/// magias do compêndio a cada abertura da ficha.
class CombatPanelSummary {
  const CombatPanelSummary({
    required this.activeConditions,
    required this.exhaustion,
    required this.hitDiceUsed,
    required this.hitDiceTotal,
    required this.inspiration,
  });

  factory CombatPanelSummary.of(Character character) {
    return CombatPanelSummary(
      activeConditions: character.conditions.length,
      exhaustion: character.exhaustion,
      hitDiceUsed: character.hitDiceUsed,
      // Um dado de vida por nível, como o resto da ficha conta.
      hitDiceTotal: character.totalLevel,
      inspiration: character.inspiration,
    );
  }

  /// Condições que o jogador marcou. Não inclui as implicadas pelas regras:
  /// elas são derivadas na leitura e contá-las aqui inflaria o número.
  final int activeConditions;

  final int exhaustion;
  final int hitDiceUsed;
  final int hitDiceTotal;
  final bool inspiration;

  int get hitDiceAvailable => hitDiceTotal - hitDiceUsed;

  bool get hasActiveConditions => activeConditions > 0 || exhaustion > 0;

  /// Recursos reduzidos ou esgotados.
  ///
  /// Hoje é o dado de vida, que é o único consumível que a ficha lê de forma
  /// síncrona. Espaço de magia e carga de item mágico vivem em tabela própria e
  /// exigiriam leitura assíncrona, que é justamente o que este resumo evita.
  int get spentResources => hitDiceUsed;

  bool get hasSpentResources => spentResources > 0;

  /// Se há algo que o jogador deveria olhar antes de agir.
  bool get needsAttention => hasActiveConditions || hasSpentResources;

  /// Quantas marcas o indicador da aba Condições mostra.
  ///
  /// A exaustão conta como uma, porque na aba ela aparece ao lado das demais
  /// como um efeito ativo — mesmo não sendo uma condição liga/desliga.
  int get conditionBadgeCount => activeConditions + (exhaustion > 0 ? 1 : 0);

  /// `2 condições ativas`, ou nulo quando não há nenhuma.
  String? get conditionsLabel {
    if (!hasActiveConditions) return null;

    final parts = <String>[
      if (activeConditions == 1)
        '1 condição ativa'
      else if (activeConditions > 1)
        '$activeConditions condições ativas',
      if (exhaustion > 0) 'exaustão nível $exhaustion',
    ];

    return parts.join(' • ');
  }

  /// `1 dado de vida gasto`, ou nulo quando nada foi gasto.
  String? get resourcesLabel {
    if (!hasSpentResources) return null;

    return hitDiceUsed == 1
        ? '1 dado de vida gasto'
        : '$hitDiceUsed dados de vida gastos';
  }

  /// A linha que a ficha mostra sob o botão.
  ///
  /// `2 condições ativas • 1 dado de vida gasto`. Sem nada notável, diz isso em
  /// vez de ficar em branco: uma linha vazia pareceria falha de carregamento.
  String get compactLine {
    final parts = <String>[
      if (conditionsLabel case final label?) label,
      if (resourcesLabel case final label?) label,
      if (inspiration) 'com inspiração',
    ];

    if (parts.isEmpty) return 'Sem condições ativas • recursos completos';

    return parts.join(' • ');
  }

  /// Rótulo do indicador do botão, ou nulo quando não há o que avisar.
  ///
  /// Texto, e não só cor: o requisito de acessibilidade é o indicador não
  /// depender de enxergar a diferença entre vermelho e cinza.
  String? get badgeLabel {
    if (hasActiveConditions) {
      final count = conditionBadgeCount;
      return count == 1 ? '1 ativa' : '$count ativas';
    }

    if (hasSpentResources) return 'Gasto';

    return null;
  }
}
