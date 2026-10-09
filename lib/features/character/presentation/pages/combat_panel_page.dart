import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/combat_panel_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/combat_panel_summary.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/combat_actions_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/conditions_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/rest_and_resources_panel.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ações, condições e recursos do personagem, fora da ficha.
///
/// As três seções saíram da ficha principal porque juntas ocupavam mais tela
/// que todo o resto e empurravam atributos e perícias para longe do polegar.
/// Aqui elas viram abas de uma rota própria, e não de modais empilhados: o
/// jogador entra e sai várias vezes no mesmo combate, e pilha de modal não
/// sobrevive a isso.
///
/// Os três painéis são os MESMOS widgets que a ficha usava — nada foi
/// duplicado. Eles já recebiam o personagem por parâmetro e liam o estado dos
/// providers, então não precisaram de refatoração.
class CombatPanelPage extends ConsumerStatefulWidget {
  const CombatPanelPage({required this.characterId, super.key});

  final String characterId;

  @override
  ConsumerState<CombatPanelPage> createState() => _CombatPanelPageState();
}

class _CombatPanelPageState extends ConsumerState<CombatPanelPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();

    // Restaura a última aba da sessão. O índice é lido uma vez, e não observado:
    // observar faria a aba pular quando o próprio controlador gravasse.
    _tabs = TabController(
      length: CombatPanelTab.values.length,
      initialIndex: ref.read(combatPanelTabProvider).index,
      vsync: this,
    );

    _tabs.addListener(_rememberTab);
  }

  void _rememberTab() {
    // `indexIsChanging` é falso no fim da animação; gravar antes guardaria a
    // aba de passagem num arrasto entre a primeira e a terceira.
    if (_tabs.indexIsChanging) return;
    ref.read(combatPanelTabProvider).remember(_tabs.index);
  }

  @override
  void dispose() {
    _tabs.removeListener(_rememberTab);
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lê do mesmo provider da ficha, então toda mudança feita aqui aparece lá
    // na hora, e o que foi mudado na ficha já chega aberto aqui. Uma cópia do
    // personagem passada por argumento ficaria velha no primeiro toque.
    final characterAsync = ref.watch(characterByIdProvider(widget.characterId));
    final classesAsync = ref.watch(classEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de combate'),
        // O nome do personagem no subtítulo: o painel é aberto no meio de um
        // combate com várias fichas na mesa, e o título sozinho não diz de quem
        // é esta tela.
        bottom: _TabsBar(
          controller: _tabs,
          character: characterAsync.value,
        ),
      ),
      body: characterAsync.when(
        data: (character) {
          if (character == null) {
            return const Center(child: Text('Personagem não encontrado.'));
          }

          return classesAsync.when(
            data: (classes) => _Body(
              tabs: _tabs,
              character: character,
              classes: classes,
            ),
            error: (error, stackTrace) =>
                Center(child: Text('Erro ao carregar classes: $error')),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, stackTrace) => Center(child: Text('Erro: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// A barra de abas, com o nome do personagem acima dela.
///
/// `PreferredSizeWidget` próprio porque o `AppBar.bottom` precisa declarar
/// altura, e aqui há duas linhas: o nome e as abas.
class _TabsBar extends StatelessWidget implements PreferredSizeWidget {
  const _TabsBar({required this.controller, required this.character});

  final TabController controller;
  final Character? character;

  static const double _nameHeight = 26;
  static const double _tabsHeight = 48;

  @override
  Size get preferredSize => const Size.fromHeight(_nameHeight + _tabsHeight);

  @override
  Widget build(BuildContext context) {
    // Local porque campo público de widget não promove para não-nulo.
    final character = this.character;
    final summary =
        character == null ? null : CombatPanelSummary.of(character);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _nameHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                character?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onDarkVariant,
                    ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: _tabsHeight,
          child: TabBar(
            controller: controller,
            // Rolável para o rótulo não ser cortado com fonte ampliada. Com
            // três rótulos curtos, numa tela normal ela nem rola.
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final tab in CombatPanelTab.values)
                Tab(
                  // `Semantics` com o rótulo completo: o leitor de tela anuncia
                  // "Condições, 2 ativas" em vez de ler o número solto como se
                  // fosse outro elemento.
                  child: Semantics(
                    label: _semanticsFor(tab, summary),
                    excludeSemantics: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tab.label),
                        if (tab == CombatPanelTab.conditions &&
                            summary != null &&
                            summary.hasActiveConditions) ...[
                          const SizedBox(width: 6),
                          _TabBadge(count: summary.conditionBadgeCount),
                        ],
                        if (tab == CombatPanelTab.resources &&
                            summary != null &&
                            summary.hasSpentResources) ...[
                          const SizedBox(width: 6),
                          _TabBadge(count: summary.spentResources),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _semanticsFor(CombatPanelTab tab, CombatPanelSummary? summary) {
    if (summary == null) return tab.label;

    return switch (tab) {
      CombatPanelTab.conditions when summary.hasActiveConditions =>
        '${tab.label}, ${summary.conditionBadgeCount} '
            '${summary.conditionBadgeCount == 1 ? 'ativa' : 'ativas'}',
      CombatPanelTab.resources when summary.hasSpentResources =>
        '${tab.label}, ${summary.spentResources} '
            '${summary.spentResources == 1 ? 'gasto' : 'gastos'}',
      _ => tab.label,
    };
  }
}

/// Contagem no rótulo da aba.
///
/// Mostra o número, não só um ponto: o requisito é o indicador não depender de
/// cor, e um número é legível em preto e branco e para quem usa leitor de tela.
class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.redContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red, width: 0.8),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onRedContainer,
            ),
      ),
    );
  }
}

/// O conteúdo das três abas.
class _Body extends StatelessWidget {
  const _Body({
    required this.tabs,
    required this.character,
    required this.classes,
  });

  final TabController tabs;
  final Character character;
  final List<ClassEntry> classes;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabs,
      children: [
        _Tab(
          storageKey: 'combat_panel_actions',
          child: CombatActionsPanel(character: character),
        ),
        _Tab(
          storageKey: 'combat_panel_conditions',
          child: ConditionsPanel(character: character),
        ),
        _Tab(
          storageKey: 'combat_panel_resources',
          child: RestAndResourcesPanel(
            character: character,
            classes: classes,
          ),
        ),
      ],
    );
  }
}

/// Uma aba com rolagem própria e estado preservado.
///
/// Duas coisas acontecem aqui, e as duas são requisito:
///
/// - `AutomaticKeepAliveClientMixin` mantém a sub-árvore viva ao trocar de aba.
///   Sem ele o `TabBarView` descarta a aba que sai de tela, e o que estava
///   expandido dentro de "Ações" volta fechado na volta.
/// - `PageStorageKey` guarda a posição de rolagem por aba, então voltar para
///   "Ações" não joga o jogador de volta ao topo de uma lista longa.
///
/// A rolagem é por aba, e não uma só para o painel inteiro: as três têm alturas
/// bem diferentes, e uma rolagem comum faria a aba curta herdar o comprimento
/// da longa.
class _Tab extends StatefulWidget {
  const _Tab({required this.storageKey, required this.child});

  final String storageKey;
  final Widget child;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      key: PageStorageKey<String>(widget.storageKey),
      // `scrollContentPadding` é o mesmo da ficha: já respeita a safe area e a
      // barra de navegação do sistema, então o último botão não fica atrás dela.
      padding: context.scrollContentPadding(),
      child: widget.child,
    );
  }
}
