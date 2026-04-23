class RaceSpellFeature {
  const RaceSpellFeature({
    required this.spellId,
    this.level,
    this.isAtWill = false,
    this.usesPerRest,
    this.notes,
  });

  final int spellId;
  final int? level;
  final bool isAtWill;
  final int? usesPerRest;
  final String? notes;
}