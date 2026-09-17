import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

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
    this.magicBonus = 0,
    this.chosenAbility,
    this.twoHanded = false,
    this.proficiencyOverride,
    this.notes = '',
  });

  /// Chave da linha no banco. Nulo em arma recém-montada, ainda não salva.
  final int? localId;

  /// Id da arma no compêndio (`WeaponEntry.id`).
  final String weaponId;

  /// Apelido dado pelo jogador. Nulo usa o nome do compêndio.
  final String? name;

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

  bool get isMagical => magicBonus != 0;

  CharacterWeapon copyWith({
    int? localId,
    String? weaponId,
    String? name,
    int? magicBonus,
    Ability? chosenAbility,
    bool? twoHanded,
    bool? proficiencyOverride,
    String? notes,
  }) {
    return CharacterWeapon(
      localId: localId ?? this.localId,
      weaponId: weaponId ?? this.weaponId,
      name: name ?? this.name,
      magicBonus: magicBonus ?? this.magicBonus,
      chosenAbility: chosenAbility ?? this.chosenAbility,
      twoHanded: twoHanded ?? this.twoHanded,
      proficiencyOverride: proficiencyOverride ?? this.proficiencyOverride,
      notes: notes ?? this.notes,
    );
  }
}
