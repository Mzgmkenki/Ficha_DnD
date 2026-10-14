import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';

/// Marcador para distinguir "não informado" de "informado como null" no
/// [InventoryItem.copyWith], igual ao que `Character` faz.
const Object _sentinel = Object();

/// Um item que o personagem carrega.
///
/// É do personagem, não do compêndio: nome, quantidade e estado são decisão do
/// jogador. O que o item FAZ continua fora daqui — arma resolve dano pelo
/// compêndio de armas e item mágico resolve bônus pelo próprio registro. Este
/// inventário responde "o que eu tenho e quanto", e por isso pode conter tanto
/// a corda de 15 m quanto um vínculo para a espada já cadastrada.
class InventoryItem {
  const InventoryItem({
    required this.name,
    this.localId,
    this.itemId,
    this.quantity = 1,
    this.description = '',
    this.weight,
    this.category = ItemCategory.gear,
    this.equipped = false,
    this.note = '',
    this.isCustom = false,
    this.source = GrantSource.manual,
    this.sourceId,
    this.sourceLabel,
    this.grantedAtCreation = false,
    this.grantedQuantity,
    this.manuallyEdited = false,
    this.grantRef,
    this.armorStrengthRequirement,
    this.armorStealthDisadvantage,
    this.armorMagicBonus = 0,
    this.linkedWeaponLocalId,
    this.linkedMagicItemLocalId,
  });

  /// Chave da linha no banco. Nula em item que ainda não foi gravado.
  final int? localId;

  /// Id estável da definição do item (`crowbar`, `common_clothes`).
  ///
  /// Junto com [source] e [sourceId] forma a identidade do que foi concedido.
  /// Nulo em item avulso criado pelo jogador.
  final String? itemId;

  final String name;

  /// Quantidade atual. Nunca negativa — use [withQuantity], que corta em zero.
  final int quantity;

  final String description;

  /// Peso em quilos, quando conhecido. Nulo é "não informado", e não zero: o
  /// app não tem tabela de pesos, então inventar um número seria mentir.
  final double? weight;

  final ItemCategory category;

  /// Se está equipado ou guardado.
  final bool equipped;

  /// Observação livre do jogador.
  final String note;

  /// `true` quando o jogador criou o item do zero, em vez de recebê-lo.
  final bool isCustom;

  // --------------------------------------------------------------- origem
  //
  // Os cinco campos abaixo são o que permite trocar o antecedente sem
  // estragar o inventário. Guardam a origem, o identificador dela, o momento
  // da inclusão e a quantidade originalmente concedida — tudo o que a remoção
  // seletiva precisa saber. O estado atual continua em [quantity].

  final GrantSource source;

  /// Id da fonte (`criminal` para o antecedente Criminoso).
  final String? sourceId;

  /// Rótulo da fonte, já pronto para exibir ("Antecedente: Criminoso").
  ///
  /// Fica persistido em vez de ser remontado na leitura porque o compêndio
  /// pode mudar de nome, e a ficha deve continuar dizendo de onde o item veio
  /// na época em que foi concedido.
  final String? sourceLabel;

  /// `true` quando o item entrou durante a criação do personagem.
  final bool grantedAtCreation;

  /// Quantidade que a fonte concedeu. Nula em item manual.
  ///
  /// Serve para reconhecer que o jogador consumiu ou acumulou unidades de um
  /// item concedido, e por isso ele não pode ser apagado em silêncio.
  final int? grantedQuantity;

  /// `true` quando o jogador editou um item que havia sido concedido.
  ///
  /// Marcado pela edição, não deduzido: renomear ou mudar a descrição também
  /// conta, e isso não aparece na comparação de quantidade.
  final bool manuallyEdited;

  /// Qual grupo e qual alternativa da fonte concederam este item
  /// (`armor|leather_longbow`), ou `fixed` no que vem automático.
  ///
  /// Nulo quando a fonte não tem grupos de escolha — é o caso do antecedente,
  /// cujo equipamento é uma lista única. Guardado para a ficha conseguir
  /// explicar a procedência depois da criação, quando a seleção em memória já
  /// não existe mais.
  final String? grantRef;

  // ------------------------------------------------- exceções de armadura
  //
  // Só fazem sentido no item que É uma armadura ou escudo. Existem para a peça
  // mágica ou especial divergir da tabela SEM alterar a armadura básica: umas
  // Placas Adamantinas que dispensam Força, ou uma Brunea Élfica sem
  // desvantagem em Furtividade, são exceção desta peça. Nulo em ambos os casos
  // significa "usa o que a tabela diz", que é o padrão seguro para todo item
  // já gravado.

  /// Requisito de Força próprio desta peça. Nulo usa o da tabela.
  ///
  /// Zero é significativo: é como uma peça declara "não exige Força".
  final int? armorStrengthRequirement;

  /// Desvantagem em Furtividade própria desta peça. Nulo usa o da tabela.
  final bool? armorStealthDisadvantage;

  /// O `+1`, `+2` ou `+3` da armadura (ou escudo) mágica.
  ///
  /// Soma na CA. Fica no item, e não no registro de item mágico, porque é a
  /// peça de armadura possuída que entra no cálculo — e é ela que o jogador
  /// equipa.
  final int armorMagicBonus;

  // --------------------------------------------------------------- vínculos

  /// `CharacterWeapon.localId` da arma correspondente, quando este item é a
  /// contrapartida de uma arma já cadastrada.
  final int? linkedWeaponLocalId;

  /// `CharacterMagicItem.localId` do item mágico correspondente.
  final int? linkedMagicItemLocalId;

  /// `true` quando o item foi concedido por alguma fonte automática.
  bool get isGranted => source.isAutomatic;

  /// `true` quando aponta para uma arma ou item mágico já cadastrado.
  ///
  /// Armadura não entra: o app não tem registro de armadura, só o número de
  /// Classe de Armadura, então não há o que referenciar.
  bool get isLinked =>
      linkedWeaponLocalId != null || linkedMagicItemLocalId != null;

  /// `true` quando a quantidade chegou a zero.
  ///
  /// Zero é estado válido e não remoção: munição acabada continua na lista até
  /// o jogador confirmar que quer tirá-la.
  bool get isDepleted => quantity <= 0;

  /// `true` quando um item concedido não está mais como foi concedido.
  ///
  /// A troca de antecedente usa isto para pedir confirmação em vez de apagar.
  bool get divergedFromGrant {
    if (!isGranted) return false;
    if (manuallyEdited) return true;
    final granted = grantedQuantity;
    return granted != null && granted != quantity;
  }

  /// Rótulo de origem para exibir na ficha.
  String get originLabel {
    final label = sourceLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    return source.label;
  }

  /// Chave estável do que foi concedido por uma fonte automática.
  ///
  /// É o que impede duplicação quando a tela reconstrói e o antecedente é
  /// reaplicado: a comparação é por origem e identificador, nunca por nome,
  /// que o jogador pode ter trocado.
  ///
  /// Nula em item manual — item manual não participa de recálculo.
  String? get grantKey {
    if (!isGranted) return null;
    return '${source.id}|${sourceId ?? ''}|${itemId ?? name.toLowerCase()}';
  }

  /// Copia cortando quantidade negativa em zero.
  InventoryItem withQuantity(int value) {
    return copyWith(quantity: value < 0 ? 0 : value);
  }

  /// Marca como editado pelo jogador, preservando o rastro da origem.
  ///
  /// A origem NÃO é apagada ao editar: o jogador continua podendo consultar de
  /// onde o item veio, e é isso que a seção de inventário mostra.
  InventoryItem markEdited() {
    return isGranted && !manuallyEdited ? copyWith(manuallyEdited: true) : this;
  }

  InventoryItem copyWith({
    Object? localId = _sentinel,
    Object? itemId = _sentinel,
    String? name,
    int? quantity,
    String? description,
    Object? weight = _sentinel,
    ItemCategory? category,
    bool? equipped,
    String? note,
    bool? isCustom,
    GrantSource? source,
    Object? sourceId = _sentinel,
    Object? sourceLabel = _sentinel,
    bool? grantedAtCreation,
    Object? grantedQuantity = _sentinel,
    bool? manuallyEdited,
    Object? grantRef = _sentinel,
    Object? armorStrengthRequirement = _sentinel,
    Object? armorStealthDisadvantage = _sentinel,
    int? armorMagicBonus,
    Object? linkedWeaponLocalId = _sentinel,
    Object? linkedMagicItemLocalId = _sentinel,
  }) {
    return InventoryItem(
      // Sentinela em todo campo anulável: desvincular um item é setar o
      // vínculo para null, e com `?? this.x` isso seria impossível.
      localId: localId == _sentinel ? this.localId : localId as int?,
      itemId: itemId == _sentinel ? this.itemId : itemId as String?,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      weight: weight == _sentinel ? this.weight : weight as double?,
      category: category ?? this.category,
      equipped: equipped ?? this.equipped,
      note: note ?? this.note,
      isCustom: isCustom ?? this.isCustom,
      source: source ?? this.source,
      sourceId: sourceId == _sentinel ? this.sourceId : sourceId as String?,
      sourceLabel:
          sourceLabel == _sentinel ? this.sourceLabel : sourceLabel as String?,
      grantedAtCreation: grantedAtCreation ?? this.grantedAtCreation,
      grantedQuantity:
          grantedQuantity == _sentinel
              ? this.grantedQuantity
              : grantedQuantity as int?,
      manuallyEdited: manuallyEdited ?? this.manuallyEdited,
      grantRef: grantRef == _sentinel ? this.grantRef : grantRef as String?,
      armorStrengthRequirement:
          armorStrengthRequirement == _sentinel
              ? this.armorStrengthRequirement
              : armorStrengthRequirement as int?,
      armorStealthDisadvantage:
          armorStealthDisadvantage == _sentinel
              ? this.armorStealthDisadvantage
              : armorStealthDisadvantage as bool?,
      armorMagicBonus: armorMagicBonus ?? this.armorMagicBonus,
      linkedWeaponLocalId:
          linkedWeaponLocalId == _sentinel
              ? this.linkedWeaponLocalId
              : linkedWeaponLocalId as int?,
      linkedMagicItemLocalId:
          linkedMagicItemLocalId == _sentinel
              ? this.linkedMagicItemLocalId
              : linkedMagicItemLocalId as int?,
    );
  }

  @override
  String toString() => 'InventoryItem($name x$quantity, ${source.id})';
}
