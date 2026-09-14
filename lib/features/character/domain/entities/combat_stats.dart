class CombatStats {
  const CombatStats({
    required this.armorClass,
    required this.initiativeBonus,
    required this.speedInMeters,
  }) : assert(armorClass >= 0),
       assert(speedInMeters >= 0);

  final int armorClass;
  final int initiativeBonus;

  /// Deslocamento em metros.
  ///
  /// Decimal porque anão, halfling e gnomo andam 7,5 m e elfo da floresta,
  /// sátiro e genasi do ar andam 10,5 m. O campo antigo era inteiro e chamava
  /// `speedInSquares`, apesar de guardar metros.
  final double speedInMeters;

  CombatStats copyWith({
    int? armorClass,
    int? initiativeBonus,
    double? speedInMeters,
  }) {
    return CombatStats(
      armorClass: armorClass ?? this.armorClass,
      initiativeBonus: initiativeBonus ?? this.initiativeBonus,
      speedInMeters: speedInMeters ?? this.speedInMeters,
    );
  }
}
