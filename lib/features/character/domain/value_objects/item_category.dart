/// Categoria de um item do inventário.
///
/// Serve para agrupar e filtrar a lista, não para calcular regra nenhuma: o
/// que uma arma faz continua vindo do compêndio de armas, e o que um item
/// mágico soma continua vindo do próprio item mágico.
///
/// O [id] é persistido, então renomear um valor existente invalidaria itens já
/// gravados. Para acrescentar categoria, adicione um valor novo no fim.
enum ItemCategory {
  weapon('weapon', 'Arma'),
  armor('armor', 'Armadura'),
  tool('tool', 'Ferramenta'),
  clothing('clothing', 'Vestuário'),
  gear('gear', 'Equipamento'),
  book('book', 'Livro'),
  instrument('instrument', 'Instrumento'),
  trinket('trinket', 'Bugiganga'),
  consumable('consumable', 'Consumível'),
  mount('mount', 'Montaria'),
  vehicle('vehicle', 'Veículo'),
  treasure('treasure', 'Tesouro'),
  magic('magic', 'Item mágico'),
  other('other', 'Outro');

  const ItemCategory(this.id, this.label);

  final String id;
  final String label;

  /// Devolve `null` quando o id não é conhecido.
  static ItemCategory? fromId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    final normalized = id.trim();
    for (final item in values) {
      if (item.id == normalized) return item;
    }
    return null;
  }

  /// Igual a [fromId], mas cai em [ItemCategory.other] no desconhecido.
  ///
  /// É o que a leitura da ficha usa: categoria gravada por uma versão mais
  /// nova não pode impedir o item de aparecer.
  static ItemCategory fromIdOrOther(String? id) =>
      fromId(id) ?? ItemCategory.other;
}
