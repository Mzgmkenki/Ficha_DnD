import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Quanto os itens mágicos somam à conjuração do personagem.
class SpellcastingItemBonus {
  const SpellcastingItemBonus({
    this.attack = 0,
    this.saveDc = 0,
    this.sources = const [],
  });

  final int attack;
  final int saveDc;

  /// Nomes dos itens que contribuíram, para a ficha dizer de onde veio.
  final List<String> sources;

  bool get isEmpty => attack == 0 && saveDc == 0;
}

/// Números de conjuração de 5e.
///
/// Estático como os outros serviços de domínio. Antes era instanciável e não
/// tinha nenhum chamador: a UI reimplementava as duas contas.
class SpellcastingService {
  const SpellcastingService._();

  /// CD de resistência: 8 + bônus de proficiência + modificador do atributo.
  static int spellSaveDc({
    required int proficiencyBonus,
    required Ability castingAbility,
    required AbilityScores scores,
    int itemBonus = 0,
  }) {
    return 8 + proficiencyBonus + _modifier(castingAbility, scores) + itemBonus;
  }

  /// Bônus de ataque com magia: proficiência + modificador do atributo.
  static int spellAttackBonus({
    required int proficiencyBonus,
    required Ability castingAbility,
    required AbilityScores scores,
    int itemBonus = 0,
  }) {
    return proficiencyBonus + _modifier(castingAbility, scores) + itemBonus;
  }

  /// Soma os bônus de conjuração declarados pelos itens mágicos.
  ///
  /// Só entra o que o item declara em campo próprio. Um item cujo nome tem
  /// `+1` mas que não declarou nada não soma nada aqui: é a descrição do item
  /// que diz se o bônus vale para ataque mágico e CD, e o app não deduz isso do
  /// nome. Uma arma `+1` e um Escudo `+1` não aumentam CD de magia.
  static SpellcastingItemBonus itemBonuses(List<CharacterMagicItem> items) {
    var attack = 0;
    var saveDc = 0;
    final sources = <String>[];

    for (final item in items) {
      if (!item.affectsSpellcasting) continue;

      attack += item.spellAttackBonus;
      saveDc += item.spellSaveDcBonus;
      sources.add(item.name);
    }

    return SpellcastingItemBonus(
      attack: attack,
      saveDc: saveDc,
      sources: List.unmodifiable(sources),
    );
  }

  static int _modifier(Ability ability, AbilityScores scores) {
    return scores.valueFor(ability).abilityModifier;
  }
}
