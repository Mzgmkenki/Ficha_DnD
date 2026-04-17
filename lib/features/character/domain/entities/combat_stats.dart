class CombatStats {
  const CombatStats({
    required this.armorClass,
    required this.initiativeBonus,
    required this.speedInSquares,
  }) : assert(armorClass >= 0),
       assert(speedInSquares >= 0);

  final int armorClass;
  final int initiativeBonus;
  final int speedInSquares;

  CombatStats copyWith({
    int? armorClass,
    int? initiativeBonus,
    int? speedInSquares,
  }) {
    return CombatStats(
      armorClass: armorClass ?? this.armorClass,
      initiativeBonus: initiativeBonus ?? this.initiativeBonus,
      speedInSquares: speedInSquares ?? this.speedInSquares,
    );
  }
}
