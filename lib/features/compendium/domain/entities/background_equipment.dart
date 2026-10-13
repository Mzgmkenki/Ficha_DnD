import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';

/// Um item que o antecedente concede.
///
/// É dado de referência: descreve o que o livro manda entregar, não o item que
/// o personagem possui. Quem passa a pertencer à ficha é o item do inventário
/// gerado a partir daqui (ver `InventoryItem`), que guarda a origem e pode ser
/// editado ou consumido pelo jogador depois.
class BackgroundEquipmentItem {
  const BackgroundEquipmentItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.category = ItemCategory.gear,
  });

  /// Id estável do item dentro do antecedente (`crowbar`, `common_clothes`).
  ///
  /// É metade da chave usada para reconhecer o que veio do antecedente na hora
  /// de trocá-lo; a outra metade é o id do antecedente. Identificar pelo nome
  /// não serviria: o jogador pode renomear o item.
  final String id;

  final String name;

  /// Quantidade concedida. Sempre ao menos 1 — item com quantidade zero não é
  /// concedido, simplesmente não existe na lista.
  final int quantity;

  final ItemCategory category;

  @override
  String toString() => 'BackgroundEquipmentItem($id x$quantity)';
}

/// Uma das alternativas de uma escolha de equipamento.
class BackgroundEquipmentOption {
  const BackgroundEquipmentOption({
    required this.id,
    required this.label,
    this.items = const <BackgroundEquipmentItem>[],
  });

  final String id;
  final String label;
  final List<BackgroundEquipmentItem> items;
}

/// Uma escolha de equipamento prevista pelo antecedente.
///
/// O Mercante de Guilda, por exemplo, escolhe entre ferramentas de artesão e
/// uma mula com carroça. Estas alternativas NÃO são adicionadas sozinhas ao
/// inventário: escolher por conta própria seria decidir pelo jogador. Elas
/// aparecem na ficha como informação, e o jogador adiciona o que escolheu.
class BackgroundEquipmentChoice {
  const BackgroundEquipmentChoice({
    required this.id,
    required this.label,
    this.count = 1,
    this.options = const <BackgroundEquipmentOption>[],
  });

  final String id;
  final String label;

  /// Quantas alternativas o jogador leva.
  final int count;

  final List<BackgroundEquipmentOption> options;

  bool get isEmpty => options.isEmpty;
}
