import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Seção da ficha que abre e fecha, com o cabeçalho todo clicável.
///
/// Existe porque a ficha é uma coluna longa: com tudo aberto o jogador rola
/// muito para achar o que precisa em mesa. O cabeçalho continua igual ao das
/// seções que não recolhem — mesma tipografia e mesmo espaçamento — para a
/// página não virar duas linguagens visuais.
///
/// Só apresentação: nenhuma regra de ficha entra aqui. O resumo e o indicador
/// chegam prontos de quem monta a seção.
///
/// O conteúdo é construído somente quando aberto, e isso é decisão consciente.
/// Ganho: "Ações em combate" resolve a lista inteira de magias do compêndio, e
/// manter isso montado sem ninguém olhando custa caro numa página que já é
/// grande. Risco aceito: estado só de interface dentro da seção se perde ao
/// fechar — na prática, quais itens de ação estavam expandidos. Nada que o
/// jogador tenha digitado ou escolhido passa por aqui: condições, recursos e
/// características leem do personagem salvo, então fechar não apaga nem
/// reinicia nada.
class CollapsibleSection extends StatefulWidget {
  const CollapsibleSection({
    required this.id,
    required this.title,
    required this.child,
    this.summary,
    this.badge,
    this.initiallyExpanded = false,
    this.isExpanded,
    this.onExpansionChanged,
    super.key,
  });

  /// Identificador da seção. Serve para quem guarda o estado saber de quem é.
  final String id;

  final String title;

  /// Conteúdo, construído só quando aberto.
  final Widget child;

  /// Uma linha curta que descreve o estado sem precisar abrir.
  final String? summary;

  /// Aviso curto para o que não pode ficar escondido: condição ativa, recurso
  /// gasto. Aparece destacado mesmo com a seção fechada.
  final String? badge;

  /// Estado na primeira construção, quando a seção não é controlada.
  final bool initiallyExpanded;

  /// Estado controlado por quem usa o componente.
  ///
  /// Quando vem preenchido, o componente não guarda estado próprio: quem manda
  /// é o pai, e [onExpansionChanged] é o único caminho para mudar. Nulo deixa o
  /// componente cuidar de si.
  final bool? isExpanded;

  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _expanded = widget.initiallyExpanded;

  bool get _isExpanded => widget.isExpanded ?? _expanded;

  /// Rótulo lido pelo leitor de tela: título, resumo e indicador numa frase.
  ///
  /// Junta tudo de propósito. Quem navega por leitor ouve o estado da seção sem
  /// precisar percorrer quatro nós separados, e o indicador de condição ativa
  /// deixa de depender de enxergar a etiqueta vermelha.
  String get _semanticsLabel {
    final summary = widget.summary?.trim();
    final badge = widget.badge?.trim();

    return [
      widget.title,
      if (summary != null && summary.isNotEmpty) summary,
      if (badge != null && badge.isNotEmpty) badge,
    ].join('. ');
  }

  void _toggle() {
    final next = !_isExpanded;

    // Só guarda internamente quando não é controlada, senão o estado local
    // brigaria com o do pai.
    if (widget.isExpanded == null) {
      setState(() => _expanded = next);
    }

    widget.onExpansionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final expanded = _isExpanded;
    final stateLabel = expanded ? 'Recolher' : 'Expandir';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Um nó de acessibilidade só, descrevendo o cabeçalho inteiro.
        //
        // `container` mais `excludeSemantics` são o que faz isso funcionar: sem
        // eles os rótulos dos filhos se mesclam com o meu e o leitor de tela
        // recebe "Condições\nExpandir" num nó sem estado de expansão nenhum.
        // Com o nó próprio, o resumo e o indicador entram no rótulo em vez de
        // virarem fragmentos soltos, e o estado aberto ou fechado é anunciado.
        //
        // `excludeSemantics` não afeta o toque: o InkWell continua recebendo o
        // gesto real, e `onTap` aqui atende a ativação vinda do leitor.
        Semantics(
          container: true,
          header: true,
          button: true,
          expanded: expanded,
          label: _semanticsLabel,
          hint: stateLabel,
          onTap: _toggle,
          excludeSemantics: true,
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              // 48 é o alvo de toque mínimo recomendado; a fonte decorativa do
              // título já chega perto, e a trava garante o resto.
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.title, style: text.titleLarge),
                          if (widget.summary case final summary?
                              when summary.trim().isNotEmpty)
                            Text(
                              summary,
                              style: text.bodySmall?.copyWith(
                                color: AppColors.onDarkVariant,
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (widget.badge case final badge?
                        when badge.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _Badge(label: badge),
                      ),

                    // O texto acompanha o ícone de propósito: o requisito era
                    // o estado não depender só do desenho da seta, que some
                    // para quem não distingue a direção dela.
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          Text(
                            stateLabel,
                            style: text.labelSmall?.copyWith(
                              color: AppColors.onDarkVariant,
                            ),
                          ),
                          const SizedBox(width: 2),
                          // Gira em vez de trocar de ícone: a transição
                          // acompanha a do conteúdo e fica mais claro que é a
                          // mesma seção mudando de estado.
                          AnimatedRotation(
                            turns: expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: const Icon(
                              Icons.expand_more,
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Cresce para baixo por ancorar no topo: crescer do centro empurraria
        // o cabeçalho para cima e faria a página pular sob o dedo.
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: widget.child,
                )
              // Largura infinita mantém a coluna na mesma medida ao fechar, e
              // evita o pulo lateral que um `shrink` puro causaria.
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Aviso curto no cabeçalho, para o que não pode ficar escondido.
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.redContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onRedContainer,
            ),
      ),
    );
  }
}
