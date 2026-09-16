import 'package:flutter/material.dart';

/// Espaçamento padrão do conteúdo das páginas.
///
/// Estava repetido como `EdgeInsets.all(16)` em cada tela; virou constante para
/// o cálculo da folga inferior não depender de alguém lembrar o número.
const double kContentPadding = 16;

extension SafeAreaContext on BuildContext {
  /// Faixa que a barra de navegação do sistema ocupa no rodapé.
  ///
  /// O Android desenha o app de ponta a ponta, então um rolável se estende por
  /// baixo dessa barra. Sem somar esta folga, o último filho da lista — que
  /// nestas telas costuma ser justamente o botão de salvar — fica atrás dos
  /// controles do sistema e não termina de aparecer no fim da rolagem.
  ///
  /// Vem de `paddingOf`, e não de `viewPaddingOf`, de propósito: com o teclado
  /// aberto o Scaffold encolhe o corpo e já consome essa faixa, e `paddingOf`
  /// zera sozinho. Com `viewPaddingOf` o espaço entraria duas vezes e o
  /// conteúdo ficaria flutuando acima do teclado.
  ///
  /// Também cobre o iOS: em aparelho com indicador de gesto o valor é o mesmo
  /// inset, e em aparelho sem inset inferior devolve zero, então nada fica
  /// afastado da borda sem motivo.
  double get systemBottomInset => MediaQuery.paddingOf(this).bottom;

  /// Padding de conteúdo rolável, com a folga da barra de navegação somada.
  ///
  /// É a fórmula pedida num lugar só: espaçamento do design + inset do
  /// aparelho. Quem chama não precisa saber de MediaQuery.
  EdgeInsets scrollContentPadding({
    double horizontal = kContentPadding,
    double top = kContentPadding,
    double bottom = kContentPadding,
  }) {
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      bottom + systemBottomInset,
    );
  }
}
