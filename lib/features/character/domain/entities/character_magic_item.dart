import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart';

class CharacterMagicItem {
  const CharacterMagicItem({
    required this.localId,
    required this.name,
    required this.description,
    required this.spells,
    this.charges,
    this.maxCharges,
    this.rechargeRule,
    this.castingAbility,
    this.saveDc,
    this.attackBonus,
  });

  final int localId;
  final String name;
  final String description;
  final int? charges;
  final int? maxCharges;
  final String? rechargeRule;
  final String? castingAbility;
  final int? saveDc;
  final int? attackBonus;
  final List<CharacterMagicItemSpell> spells;
}