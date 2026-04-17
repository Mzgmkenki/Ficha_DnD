class RaceEntry {
  const RaceEntry({
    required this.id,
    required this.name,
    required this.source,
    required this.fixedAbilityBonuses,
    required this.traits,
    required this.allowsCustomOrigin,
    this.size,
    this.speed,
  });

  final String id;
  final String name;
  final String source;
  final Map<String, int> fixedAbilityBonuses;
  final List<String> traits;
  final bool allowsCustomOrigin;
  final String? size;
  final int? speed;
}