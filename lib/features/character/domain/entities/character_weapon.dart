import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';

/// Uma arma que o personagem carrega.
///
/// Guarda só o que é decisão do jogador. Dado de dano, tipo de dano e
/// propriedades vêm do compêndio pelo [weaponId]: duplicar aqui deixaria a
/// ficha desatualizada se a tabela do livro fosse corrigida.
class CharacterWeapon {
  const CharacterWeapon({
    required this.localId,
    required this.weaponId,
    this.name,
    this.quantity = 1,
    this.magicBonus = 0,
    this.chosenAbility,
    this.twoHanded = false,
    this.proficiencyOverride,
    this.notes = '',
    this.source = GrantSource.manual,
    this.sourceId,
    this.sourceLabel,
    this.grantedAtCreation = false,
    this.grantedQuantity,
    this.manuallyEdited = false,
    this.grantRef,
  });

  /// Chave da linha no banco. Nulo em arma recém-montada, ainda não salva.
  final int? localId;

  /// Id da arma no compêndio (`WeaponEntry.id`).
  final String weaponId;

  /// Apelido dado pelo jogador. Nulo usa o nome do compêndio.
  final String? name;

  /// Quantas unidades iguais o personagem carrega.
  ///
  /// Uma linha com quantidade, e não várias linhas idênticas: os dez dardos do
  /// Monge e as duas machadinhas do Guerreiro são o mesmo ataque repetido, e
  /// dez linhas iguais na seção de Armas só atrapalhariam a leitura em mesa.
  /// Não entra em nenhuma conta de ataque ou dano.
  final int quantity;

  /// O `+1`, `+2` ou `+3` da arma mágica.
  ///
  /// Soma nas jogadas de ataque e nas de dano daquela arma. Não mexe em ataque
  /// de magia nem em CD: isso é efeito de item mágico e só vale quando a
  /// descrição do item diz.
  final int magicBonus;

  /// Atributo escolhido nas armas com Acuidade.
  ///
  /// Nulo deixa o cálculo usar o melhor entre Força e Destreza.
  final Ability? chosenAbility;

  /// Se está empunhada com as duas mãos. Só muda o dado nas armas Versáteis.
  final bool twoHanded;

  /// Proficiência marcada à mão. Nulo deixa a classe decidir.
  final bool? proficiencyOverride;

  final String notes;

  // --------------------------------------------------------------- origem
  //
  // Os campos abaixo são o irmão do bloco de origem de `InventoryItem`, e
  // existem pelo mesmo motivo: trocar a classe tem que remover só o que
  // aquela classe concedeu, preservando a arma que o jogador cadastrou e a
  // que veio de outra fonte. Comparar nomes não serviria — nome é editável.

  final GrantSource source;

  /// Id da fonte (`fighter` para o equipamento inicial do Guerreiro).
  final String? sourceId;

  /// Rótulo da fonte, pronto para exibir na ficha.
  ///
  /// Persistido em vez de remontado na leitura: o compêndio pode mudar de
  /// nome, e a ficha deve continuar dizendo de onde a arma veio na época.
  final String? sourceLabel;

  /// `true` quando a arma entrou durante a criação do personagem.
  final bool grantedAtCreation;

  /// Quantidade que a fonte concedeu. Nula em arma manual.
  final int? grantedQuantity;

  /// `true` quando o jogador editou uma arma que havia sido concedida.
  final bool manuallyEdited;

  /// Qual grupo e qual alternativa concederam esta arma
  /// (`martial|two_martial`), ou `fixed` no equipamento automático.
  ///
  /// Guardado para a ficha conseguir explicar a procedência de cada arma depois
  /// da criação, quando a seleção em memória já não existe mais.
  final String? grantRef;

  bool get isMagical => magicBonus != 0;

  /// `true` quando a arma foi concedida por alguma fonte automática.
  bool get isGranted => source.isAutomatic;

  /// Rótulo de origem para exibir na ficha.
  String get originLabel {
    final label = sourceLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    return source.label;
  }

  /// Chave estável do que foi concedido por uma fonte automática.
  ///
  /// É o que impede duplicar a arma quando a tela reconstrói e a classe é
  /// reaplicada. Nula em arma manual, que não participa de recálculo.
  String? get grantKey {
    if (!isGranted) return null;
    return '${source.id}|${sourceId ?? ''}|$weaponId';
  }

  /// `true` quando uma arma concedida não está mais como foi concedida.
  ///
  /// A troca de classe usa isto para preservar em vez de apagar em silêncio.
  bool get divergedFromGrant {
    if (!isGranted) return false;
    if (manuallyEdited) return true;
    final granted = grantedQuantity;
    return granted != null && granted != quantity;
  }

  /// Marca como editada pelo jogador, preservando o rastro da origem.
  CharacterWeapon markEdited() {
    return isGranted && !manuallyEdited ? copyWith(manuallyEdited: true) : this;
  }

  CharacterWeapon copyWith({
    int? localId,
    String? weaponId,
    String? name,
    int? quantity,
    int? magicBonus,
    Ability? chosenAbility,
    bool? twoHanded,
    bool? proficiencyOverride,
    String? notes,
    GrantSource? source,
    String? sourceId,
    String? sourceLabel,
    bool? grantedAtCreation,
    int? grantedQuantity,
    bool? manuallyEdited,
    String? grantRef,
  }) {
    return CharacterWeapon(
      localId: localId ?? this.localId,
      weaponId: weaponId ?? this.weaponId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      magicBonus: magicBonus ?? this.magicBonus,
      chosenAbility: chosenAbility ?? this.chosenAbility,
      twoHanded: twoHanded ?? this.twoHanded,
      proficiencyOverride: proficiencyOverride ?? this.proficiencyOverride,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      grantedAtCreation: grantedAtCreation ?? this.grantedAtCreation,
      grantedQuantity: grantedQuantity ?? this.grantedQuantity,
      manuallyEdited: manuallyEdited ?? this.manuallyEdited,
      grantRef: grantRef ?? this.grantRef,
    );
  }

  @override
  String toString() => 'CharacterWeapon($weaponId x$quantity, ${source.id})';
}
