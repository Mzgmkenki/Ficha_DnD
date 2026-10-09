import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abas do Painel de combate, na ordem em que aparecem.
enum CombatPanelTab {
  actions('Ações'),
  conditions('Condições'),
  resources('Recursos');

  const CombatPanelTab(this.label);

  /// Rótulo curto. Já é curto de propósito: três palavras cabem na largura de
  /// um celular pequeno sem precisar de abreviação nem de menu escondido.
  final String label;
}

/// Lembra qual aba do Painel de combate ficou aberta.
///
/// É um índice e não o enum para encaixar direto no `TabController`.
class CombatPanelTabMemory {
  int _index = 0;

  /// Índice guardado, já limitado ao número de abas que existem — se o painel
  /// perder uma aba numa versão futura, o valor velho não estoura o controlador.
  int get index => _index.clamp(0, CombatPanelTab.values.length - 1);

  void remember(int value) {
    if (value < 0 || value >= CombatPanelTab.values.length) return;
    _index = value;
  }
}

/// Última aba aberta no Painel de combate, válida pela sessão do app.
///
/// Um objeto mutável atrás de um `Provider` comum, e não um provider de estado:
/// a página lê o índice uma vez ao montar e grava a cada troca, e ninguém
/// observa o valor. Um provider observável faria a árvore reconstruir a cada
/// arrasto entre abas sem nada mudar na tela, porque quem move o conteúdo é o
/// `TabController`.
///
/// Deliberadamente SEM `autoDispose`: o requisito é restaurar a aba ao sair e
/// voltar durante a mesma sessão, e com `autoDispose` o estado morreria junto
/// com a rota. Também não é persistido em banco — o projeto não tem
/// preferências locais, e uma tabela com migração para lembrar um índice de aba
/// não se paga. Reiniciar o app volta para Ações.
final combatPanelTabProvider = Provider<CombatPanelTabMemory>(
  (ref) => CombatPanelTabMemory(),
);
