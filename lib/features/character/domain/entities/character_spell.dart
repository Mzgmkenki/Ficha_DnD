class CharacterSpell {
  const CharacterSpell({
    required this.spellId,
    required this.sourceType,
    required this.sourceId,
    required this.sourceName,
    required this.isPrepared,
    required this.isKnown,
    required this.isAlwaysAvailable,
    this.notes = '',
  });

  final int spellId;
  final String sourceType;
  final String sourceId;
  final String sourceName;
  final bool isPrepared;
  final bool isKnown;
  final bool isAlwaysAvailable;
  final String notes;
}