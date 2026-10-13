import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/inventory_item_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Itens que o personagem carrega.
///
/// Não substitui "Armas" nem "Itens mágicos": aqueles continuam resolvendo
/// regra (dano, bônus, sintonia) e esta seção responde outra pergunta — o que
/// está na mochila e quanto. Um item daqui pode apontar para uma arma já
/// cadastrada pelo vínculo, e nesse caso a ficha avisa, para o jogador não
/// achar que são duas coisas diferentes.
///
/// Grava pelo mesmo caminho do `CurrencyPanel`: monta a lista nova e manda o
/// agregado inteiro para o repositório. Quem decide o que entra e o que sai na
/// troca de antecedente é o domínio (`BackgroundGrants`), não esta tela.
class InventoryPanel extends ConsumerStatefulWidget {
  const InventoryPanel({required this.character, super.key});

  final Character character;

  /// A partir de quantos itens o campo de busca aparece.
  ///
  /// Abaixo disso a busca só ocuparia espaço numa lista que cabe na tela.
  static const int searchThreshold = 6;

  @override
  ConsumerState<InventoryPanel> createState() => _InventoryPanelState();
}

class _InventoryPanelState extends ConsumerState<InventoryPanel> {
  final _searchController = TextEditingController();
  String _query = '';
  ItemCategory? _categoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InventoryItem> get _items => widget.character.inventory;

  List<InventoryItem> get _visibleItems {
    final query = _query.trim().toLowerCase();

    return _items.where((item) {
      if (_categoryFilter != null && item.category != _categoryFilter) {
        return false;
      }
      if (query.isEmpty) return true;

      // Busca por nome, origem e observação: em mesa o jogador lembra "aquilo
      // do antecedente" com a mesma frequência com que lembra o nome.
      return item.name.toLowerCase().contains(query) ||
          item.originLabel.toLowerCase().contains(query) ||
          item.note.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  Future<void> _persist(List<InventoryItem> next) {
    return ref.read(characterRepositoryProvider).update(
          widget.character.copyWith(
            inventory: next,
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// Substitui um item pela versão nova, casando pela identidade da linha.
  ///
  /// Casa por [InventoryItem.localId] quando existe e cai no índice quando o
  /// item ainda não foi gravado. Casar por nome seria frágil: dois itens podem
  /// ter o mesmo nome.
  Future<void> _replace(InventoryItem original, InventoryItem updated) {
    final next = <InventoryItem>[];
    var replaced = false;

    for (final item in _items) {
      final sameRow = original.localId != null
          ? item.localId == original.localId
          : identical(item, original);

      if (!replaced && sameRow) {
        next.add(updated);
        replaced = true;
      } else {
        next.add(item);
      }
    }

    if (!replaced) next.add(updated);
    return _persist(next);
  }

  Future<void> _remove(InventoryItem item) {
    final next = _items.where((other) {
      return item.localId != null
          ? other.localId != item.localId
          : !identical(other, item);
    }).toList(growable: false);

    return _persist(next);
  }

  Future<void> _add() async {
    final created = await showInventoryItemForm(context: context);
    if (created == null) return;

    await _persist([..._items, created]);
  }

  Future<void> _edit(InventoryItem item) async {
    final updated = await showInventoryItemForm(context: context, item: item);
    if (updated == null) return;

    // Editar um item concedido não apaga a origem — ela continua disponível
    // para consulta —, só registra que ele não está mais como foi concedido.
    await _replace(item, updated.markEdited());
  }

  /// Altera a quantidade, cuidando do zero e do negativo.
  ///
  /// Negativo nunca chega aqui (o botão fica desabilitado), mas `withQuantity`
  /// corta de novo: a mesma função é usada pelo formulário, onde o jogador
  /// digita o número à mão.
  Future<void> _changeQuantity(InventoryItem item, int value) async {
    final next = item.withQuantity(value);

    if (!next.isDepleted) {
      await _replace(item, next.markEdited());
      return;
    }

    // Zero é estado válido: munição acabada continua listada até o jogador
    // dizer o que fazer. Por isso pergunta em vez de remover.
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quantidade zerada'),
        content: Text(
          '"${item.name}" ficou com 0 unidades. Remover do inventário?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Manter com 0'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (shouldRemove == true) {
      await _remove(item);
    } else {
      await _replace(item, next.markEdited());
    }
  }

  Future<void> _confirmRemove(InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover item'),
        content: Text(
          item.isGranted
              ? 'Remover "${item.name}"? Ele foi concedido por '
                  '${item.originLabel} e não será devolvido automaticamente.'
              : 'Remover "${item.name}" do inventário?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) await _remove(item);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final items = _items;
    final visible = _visibleItems;
    final showSearch = items.length >= InventoryPanel.searchThreshold;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    items.isEmpty
                        ? 'Nenhum item registrado'
                        : '${items.length} '
                            '${items.length == 1 ? 'item' : 'itens'}',
                    style: text.bodyMedium,
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('inventory-add'),
                  onPressed: _add,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar'),
                ),
              ],
            ),

            if (showSearch) ...[
              const SizedBox(height: 8),
              TextField(
                key: const ValueKey('inventory-search'),
                controller: _searchController,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  hintText: 'Buscar por nome, origem ou observação',
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 8),
              _CategoryFilter(
                items: items,
                selected: _categoryFilter,
                onChanged: (value) => setState(() => _categoryFilter = value),
              ),
            ],

            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Use "Adicionar" para registrar o que o personagem carrega. '
                  'O equipamento concedido pelo antecedente entra aqui '
                  'automaticamente.',
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
              )
            else if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Nenhum item corresponde ao filtro.',
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
              )
            else
              ...visible.map(
                (item) => _InventoryRow(
                  item: item,
                  onQuantityChanged: (value) => _changeQuantity(item, value),
                  onEdit: () => _edit(item),
                  onRemove: () => _confirmRemove(item),
                  onToggleEquipped: () => _replace(
                    item,
                    item.copyWith(equipped: !item.equipped).markEdited(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Filtro por categoria, montado só com as categorias que existem na lista.
///
/// Mostrar as catorze categorias sempre encheria a tela de opções vazias.
class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  final List<InventoryItem> items;
  final ItemCategory? selected;
  final ValueChanged<ItemCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final present = <ItemCategory>[];
    for (final item in items) {
      if (!present.contains(item.category)) present.add(item.category);
    }
    if (present.length < 2) return const SizedBox.shrink();

    present.sort((a, b) => a.label.compareTo(b.label));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Todas'),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          for (final category in present) ...[
            const SizedBox(width: 6),
            ChoiceChip(
              label: Text(category.label),
              selected: selected == category,
              onSelected: (_) =>
                  onChanged(selected == category ? null : category),
            ),
          ],
        ],
      ),
    );
  }
}

/// Uma linha do inventário.
class _InventoryRow extends StatelessWidget {
  const _InventoryRow({
    required this.item,
    required this.onQuantityChanged,
    required this.onEdit,
    required this.onRemove,
    required this.onToggleEquipped,
  });

  final InventoryItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onToggleEquipped;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final details = <String>[
      item.category.label,
      if (item.weight != null) '${_formatWeight(item.weight!)} kg',
      if (item.isGranted) item.originLabel,
      if (item.isCustom) 'Personalizado',
      if (item.isLinked) 'Vinculado',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layout em coluna, e não numa Row só: o nome do item pode ser longo
          // ("Mapas rudimentares da terra natal...") e numa tela estreita a
          // linha única empurraria os botões para fora.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: text.bodyLarge?.copyWith(
                        decoration:
                            item.isDepleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (details.isNotEmpty)
                      Text(
                        details.join(' · '),
                        style: text.bodySmall?.copyWith(
                          color: AppColors.onDarkVariant,
                        ),
                      ),
                    if (item.note.trim().isNotEmpty)
                      Text(
                        item.note,
                        style: text.bodySmall?.copyWith(
                          color: AppColors.onDarkVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: item.equipped ? 'Guardar' : 'Equipar',
                onPressed: onToggleEquipped,
                icon: Icon(
                  item.equipped
                      ? Icons.shield
                      : Icons.shield_outlined,
                  size: 20,
                  color: item.equipped ? AppColors.red : null,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Mais ações',
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'remove') onRemove();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'remove', child: Text('Remover')),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                key: ValueKey('inventory-dec-${item.localId ?? item.name}'),
                tooltip: 'Remover 1',
                // Desabilitado em zero: é o que impede quantidade negativa
                // antes de qualquer validação.
                onPressed: item.quantity > 0
                    ? () => onQuantityChanged(item.quantity - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline, size: 20),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: text.titleMedium,
                ),
              ),
              IconButton(
                key: ValueKey('inventory-inc-${item.localId ?? item.name}'),
                tooltip: 'Adicionar 1',
                onPressed: () => onQuantityChanged(item.quantity + 1),
                icon: const Icon(Icons.add_circle_outline, size: 20),
              ),
              if (item.divergedFromGrant)
                Expanded(
                  child: Text(
                    'Editado por você',
                    style: text.labelSmall?.copyWith(
                      color: AppColors.onDarkVariant,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
            ],
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }

  /// Peso sem decimal inútil: 1 kg em vez de 1.0 kg.
  static String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}
