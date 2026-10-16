import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_table.dart';
import 'package:flutter/material.dart';

/// Uma tabela mecânica de classe, pronta para consulta.
///
/// Só apresentação: nenhuma regra entra aqui. A tabela chega resolvida de
/// `ResolvedClassMechanic.table`, e aplicar o resultado é decisão de quem usa
/// o componente — o levantamento é explícito em não aplicar automaticamente.
///
/// Três decisões de layout que existem por causa do conteúdo real:
///
/// - rolagem HORIZONTAL quando a tabela tem muitas colunas. A Aura da
///   Tempestade tem seis, e as Fases Lunares sete: numa tela de celular elas
///   não cabem, e quebrar o texto em cada célula tornaria a comparação entre
///   linhas impossível;
/// - busca quando a tabela é longa. O Surto de Magia Selvagem tem 50 linhas,
///   e rolar até achar "polymorph" é pior que digitar;
/// - cabeçalho fixo na primeira linha, para a coluna de resultado continuar
///   legível durante a rolagem horizontal.
class MechanicTableView extends StatefulWidget {
  const MechanicTableView({
    required this.table,
    this.highlightedRowId,
    this.onRowSelected,
    this.showSearch,
    super.key,
  });

  final MechanicTable table;

  /// Linha destacada: o resultado registrado pelo jogador.
  final String? highlightedRowId;

  /// Chamado quando o jogador escolhe uma linha como resultado.
  ///
  /// Nulo deixa a tabela apenas consultável, que é o caso das tabelas de
  /// consulta — e o que impede uma linha informativa de virar escolha.
  final ValueChanged<MechanicTableRow>? onRowSelected;

  /// Força mostrar ou esconder a busca. Nulo decide pelo tamanho da tabela.
  final bool? showSearch;

  /// A partir de quantas linhas a busca aparece sozinha.
  static const int searchThreshold = 12;

  @override
  State<MechanicTableView> createState() => _MechanicTableViewState();
}

class _MechanicTableViewState extends State<MechanicTableView> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool get _searchVisible =>
      widget.showSearch ??
      widget.table.rows.length >= MechanicTableView.searchThreshold;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final table = widget.table;
    final rows = table.search(_query.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(table.title, style: text.titleSmall),
        if (table.description case final description?) ...[
          const SizedBox(height: 2),
          Text(
            description,
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
        ],

        if (_searchVisible) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _query,
            key: const ValueKey('mechanic-table-search'),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              isDense: true,
              prefixIcon: Icon(Icons.search),
              labelText: 'Buscar na tabela',
            ),
          ),
        ],

        const SizedBox(height: 8),

        if (rows.isEmpty)
          Text(
            'Nenhuma linha corresponde à busca.',
            key: const ValueKey('mechanic-table-empty'),
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          )
        else
          // `SingleChildScrollView` horizontal é o que mantém as colunas
          // inteiras em vez de comprimi-las até ficarem ilegíveis.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              key: ValueKey('mechanic-table-${table.id}'),
              columnSpacing: 20,
              headingRowHeight: 40,
              dataRowMinHeight: 40,
              dataRowMaxHeight: double.infinity,
              columns: [
                for (final column in table.effectiveColumns)
                  DataColumn(label: Text(column, style: text.labelLarge)),
              ],
              rows: [for (final row in rows) _dataRow(context, table, row)],
            ),
          ),

        for (final note in table.notes)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              note,
              style: text.bodySmall?.copyWith(
                color: AppColors.onDarkVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  DataRow _dataRow(
    BuildContext context,
    MechanicTable table,
    MechanicTableRow row,
  ) {
    final text = Theme.of(context).textTheme;
    final isHighlighted = row.id == widget.highlightedRowId;
    final columns = table.effectiveColumns.length;
    final cells = row.cells;
    final onSelected = widget.onRowSelected;

    return DataRow(
      // Destaque por cor E por ícone: só a cor excluiria quem não a distingue.
      color:
          isHighlighted
              ? WidgetStatePropertyAll(AppColors.redContainer.withAlpha(120))
              : null,
      onSelectChanged: onSelected == null ? null : (_) => onSelected(row),
      cells: [
        for (var index = 0; index < columns; index++)
          DataCell(
            _cell(
              rowId: row.id,
              index: index,
              isHighlighted: isHighlighted,
              child: ConstrainedBox(
                // Largura máxima com quebra de linha: sem o teto, uma célula
                // de efeito longo esticaria a tabela por metros.
                constraints: const BoxConstraints(maxWidth: 280),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index == 0 && isHighlighted) ...[
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        index < cells.length ? cells[index] : '',
                        style: index == 0 ? text.labelLarge : text.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Dá chave à PRIMEIRA célula da linha, não à `DataRow`.
  ///
  /// `DataRow.key` vai para um `TableRow`, que é configuração e não widget: ela
  /// não aparece na árvore e nenhum teste consegue encontrá-la. A chave na
  /// célula fica localizável e, por ser descendente do `InkWell` que o
  /// `DataTable` cria quando há seleção, também serve de alvo de toque.
  Widget _cell({
    required String rowId,
    required int index,
    required bool isHighlighted,
    required Widget child,
  }) {
    if (index != 0) return child;

    return KeyedSubtree(
      key: ValueKey('mechanic-table-row-$rowId'),
      child: child,
    );
  }
}

/// Abre a tabela numa folha, para a ficha não crescer com 50 linhas.
///
/// Folha e não diálogo porque as tabelas são altas: um diálogo centralizado
/// numa tela de celular sobra pouco espaço útil, e a folha usa a altura toda.
Future<MechanicTableRow?> showMechanicTableSheet(
  BuildContext context, {
  required MechanicTable table,
  String? highlightedRowId,
  bool allowSelection = false,
}) {
  return showModalBottomSheet<MechanicTableRow>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: MechanicTableView(
                table: table,
                highlightedRowId: highlightedRowId,
                onRowSelected:
                    allowSelection
                        ? (row) => Navigator.of(sheetContext).pop(row)
                        : null,
              ),
            );
          },
        ),
      );
    },
  );
}
