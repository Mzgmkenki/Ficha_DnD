class CharacterMagicItemSpell {
  const CharacterMagicItemSpell({
    required this.spellId,
    required this.usesCharges,
    required this.chargeCost,
    required this.isAtWill,
    required this.isAlwaysAvailable,
  });

  final int spellId;
  final bool usesCharges;
  final int chargeCost;
  final bool isAtWill;
  final bool isAlwaysAvailable;
}