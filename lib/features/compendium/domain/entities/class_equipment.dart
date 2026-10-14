import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';

/// Para onde um equipamento inicial vai na ficha.
///
/// A ficha mantém três áreas separadas, cada uma respondendo uma pergunta
/// diferente: Armas resolve ataque e dano, o gerenciamento de CA resolve
/// defesa, e o Inventário responde o que está na mochila. O destino é
/// decidido aqui, pelo dado, e não por palpite sobre o nome do item.
enum EquipmentDestination {
  /// Vira `CharacterWeapon` e aparece na seção Armas.
  weapon,

  /// Vira item de inventário na categoria armadura e alimenta o
  /// gerenciamento de CA (armadura vestível ou escudo).
  armor,

  /// Vira item de inventário comum. É o destino de munição, pacotes,
  /// ferramentas, focos e tudo mais.
  inventory,
}

/// Um equipamento concedido pela classe.
///
/// É dado de referência: descreve o que o livro manda entregar, não o item que
/// o personagem possui. O que passa a pertencer à ficha é o `InventoryItem` ou
/// o `CharacterWeapon` gerado a partir daqui, que guardam a origem e podem ser
/// editados pelo jogador depois.
class ClassEquipmentItem {
  const ClassEquipmentItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.category = ItemCategory.gear,
    this.weaponId,
    this.armorId,
    this.isShield = false,
    this.description = '',
  });

  /// Id estável do equipamento. Quando o item existe num catálogo, é o id do
  /// catálogo (`longbow`, `chain_mail`); quando não existe em catálogo nenhum,
  /// é o id declarado no asset (`explorers_pack`, `thieves_tools`).
  ///
  /// Junto com a origem forma a chave que permite remover na troca de classe
  /// exatamente o que a classe havia concedido. Identificar pelo nome não
  /// serviria: o jogador pode renomear o item.
  final String id;

  final String name;

  /// Quantidade concedida. Sempre ao menos 1.
  final int quantity;

  final ItemCategory category;

  /// Id da arma no compêndio (`WeaponEntry.id`), quando este item é uma arma.
  final String? weaponId;

  /// Id da armadura (`ArmorOption.id`), quando este item é uma armadura
  /// vestível. Escudo não usa este campo — ver [isShield].
  final String? armorId;

  /// `true` no escudo, que não é uma armadura vestível e entra na CA como
  /// bônus próprio.
  final bool isShield;

  final String description;

  EquipmentDestination get destination {
    if (weaponId != null) return EquipmentDestination.weapon;
    if (isShield || armorId != null) return EquipmentDestination.armor;
    return EquipmentDestination.inventory;
  }

  bool get isWeapon => destination == EquipmentDestination.weapon;
  bool get isArmor => destination == EquipmentDestination.armor;

  /// Texto curto com nome e quantidade, como a interface mostra.
  String get label => quantity > 1 ? '$name (x$quantity)' : name;

  ClassEquipmentItem withQuantity(int value) {
    return ClassEquipmentItem(
      id: id,
      name: name,
      quantity: value < 1 ? 1 : value,
      category: category,
      weaponId: weaponId,
      armorId: armorId,
      isShield: isShield,
      description: description,
    );
  }

  @override
  String toString() => 'ClassEquipmentItem($id x$quantity)';
}

/// Uma escolha complementar dentro de uma alternativa ou do equipamento fixo.
///
/// Representa o "qualquer arma marcial" e o "um instrumento musical" do livro:
/// a alternativa já foi escolhida, mas falta dizer QUAL item ela entrega. São
/// duas formas de declarar o que é válido, e exatamente uma delas é usada por
/// pick:
///
/// - [weaponCategory] (e opcionalmente [rangeType]) filtra o compêndio de
///   armas, para a lista nunca sair do que o livro realmente permite;
/// - [explicitOptions] enumera os itens quando não há catálogo para filtrar,
///   como nos focos arcanos e nos símbolos sagrados.
class ClassEquipmentPick {
  const ClassEquipmentPick({
    required this.id,
    required this.label,
    this.count = 1,
    this.allowDuplicates = false,
    this.weaponCategory,
    this.rangeType,
    this.explicitOptions = const <ClassEquipmentItem>[],
  });

  final String id;
  final String label;

  /// Quantos itens o jogador escolhe. "Duas armas marciais" é `count: 2`.
  final int count;

  /// Se a mesma opção pode ser escolhida mais de uma vez.
  ///
  /// Verdadeiro em "duas armas marciais", porque o livro permite levar duas
  /// espadas longas.
  final bool allowDuplicates;

  final WeaponCategory? weaponCategory;
  final WeaponRangeType? rangeType;

  final List<ClassEquipmentItem> explicitOptions;

  /// `true` quando as opções vêm do compêndio de armas.
  bool get isWeaponPick => weaponCategory != null;

  /// As opções válidas, já resolvidas.
  ///
  /// Recebe o catálogo em vez de carregá-lo para continuar sendo uma função
  /// pura: é o que permite testar a resolução sem subir o compêndio.
  List<ClassEquipmentItem> resolveOptions(List<WeaponEntry> weapons) {
    final category = weaponCategory;
    if (category == null) return explicitOptions;

    final range = rangeType;

    return [
      for (final weapon in weapons)
        if (weapon.category == category &&
            (range == null || weapon.rangeType == range))
          ClassEquipmentItem(
            id: weapon.id,
            name: weapon.name,
            category: ItemCategory.weapon,
            weaponId: weapon.id,
          ),
    ];
  }

  /// Rótulo de progresso, como "1 de 2 selecionadas".
  String progressLabel(int selected) => '$selected de $count selecionadas';
}

/// Uma das alternativas de um grupo de escolha.
///
/// Pode conceder um único item, um pacote de vários itens, ou abrir uma
/// escolha complementar — e as três coisas ao mesmo tempo, como em "uma arma
/// marcial e um escudo", que entrega o escudo e pede a arma.
class ClassEquipmentOption {
  const ClassEquipmentOption({
    required this.id,
    required this.label,
    this.items = const <ClassEquipmentItem>[],
    this.picks = const <ClassEquipmentPick>[],
    this.note = '',
  });

  final String id;
  final String label;

  /// Itens concedidos direto por esta alternativa.
  final List<ClassEquipmentItem> items;

  /// Escolhas que ainda faltam para esta alternativa ficar completa.
  final List<ClassEquipmentPick> picks;

  /// Observação do livro, como a exigência de proficiência do Clérigo.
  ///
  /// É texto porque o app não tem proficiência de armadura cadastrada de forma
  /// estruturada: bloquear a opção exigiria um dado que não existe, e escondê-la
  /// esconderia uma escolha legítima do livro.
  final String note;

  bool get needsPicks => picks.isNotEmpty;
}

/// Um grupo de escolha de equipamento inicial.
///
/// Corresponde a uma das linhas numeradas do livro: o jogador leva
/// [choose] das [options].
class ClassEquipmentGroup {
  const ClassEquipmentGroup({
    required this.id,
    required this.label,
    this.choose = 1,
    this.options = const <ClassEquipmentOption>[],
    this.requiresOptionId,
  });

  final String id;
  final String label;

  /// Quantas alternativas o jogador leva.
  final int choose;

  final List<ClassEquipmentOption> options;

  /// Id da alternativa (de outro grupo) que precisa estar escolhida para este
  /// grupo valer.
  ///
  /// Nenhuma classe de 2014 usa, mas a estrutura precisa representar grupo
  /// dependente de escolha anterior; sem o campo, modelar isso depois exigiria
  /// mudar o formato do asset e migrar o dado.
  final String? requiresOptionId;

  bool get isEmpty => options.isEmpty;

  ClassEquipmentOption? optionById(String? id) {
    if (id == null) return null;
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  /// Rótulo da instrução, como "Escolha 1 de 2 opções".
  String get instructionLabel => 'Escolha $choose de ${options.length} opções';
}

/// O equipamento inicial que uma classe concede.
///
/// Os dados ficam em `assets/data/srd/class_equipment.json`, fora do código,
/// pelo mesmo motivo dos antecedentes: é tabela do livro, muda por correção de
/// tradução e precisa ser conferida por teste de asset sem subir interface.
class ClassStartingEquipment {
  const ClassStartingEquipment({
    required this.classId,
    this.className = '',
    this.fixedItems = const <ClassEquipmentItem>[],
    this.fixedPicks = const <ClassEquipmentPick>[],
    this.groups = const <ClassEquipmentGroup>[],
    this.source = 'phb',
    this.edition = '2014',
  });

  /// Id da classe em `classes.json` (`fighter`, `ranger_tcoe`).
  final String classId;

  /// Nome da classe, só para mensagem de erro legível. O nome exibido vem de
  /// `ClassEntry.name`, que é a fonte de verdade.
  final String className;

  /// Itens recebidos automaticamente, sem escolha nenhuma.
  final List<ClassEquipmentItem> fixedItems;

  /// Escolhas que não pertencem a grupo nenhum porque não têm alternativa.
  ///
  /// É o caso das "duas armas simples à escolha" do Artífice e da arma simples
  /// extra do Bruxo, que o livro concede sempre — o jogador só decide qual.
  /// Modelar como grupo de uma única alternativa faria a interface pedir uma
  /// escolha que não existe.
  final List<ClassEquipmentPick> fixedPicks;

  final List<ClassEquipmentGroup> groups;

  final String source;

  /// Edição das regras de onde o dado saiu.
  final String edition;

  bool get isEmpty =>
      fixedItems.isEmpty && fixedPicks.isEmpty && groups.isEmpty;

  /// `true` quando há alguma decisão a tomar.
  bool get hasChoices => groups.isNotEmpty || fixedPicks.isNotEmpty;

  ClassEquipmentGroup? groupById(String id) {
    for (final group in groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  ClassStartingEquipment copyWith({String? classId, String? className}) {
    return ClassStartingEquipment(
      classId: classId ?? this.classId,
      className: className ?? this.className,
      fixedItems: fixedItems,
      fixedPicks: fixedPicks,
      groups: groups,
      source: source,
      edition: edition,
    );
  }

  @override
  String toString() =>
      'ClassStartingEquipment($classId, ${groups.length} grupos)';
}
