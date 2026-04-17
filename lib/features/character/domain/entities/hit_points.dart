class HitPoints {
  const HitPoints({
    required this.current,
    required this.maximum,
    this.temporary = 0,
  }) : assert(maximum >= 1),
       assert(current >= 0),
       assert(temporary >= 0);

  final int current;
  final int maximum;
  final int temporary;

  HitPoints applyDamage(int amount) {
    final damage = amount < 0 ? 0 : amount;
    var remainingDamage = damage;
    var newTemp = temporary;

    if (newTemp > 0) {
      if (remainingDamage >= newTemp) {
        remainingDamage -= newTemp;
        newTemp = 0;
      } else {
        newTemp -= remainingDamage;
        remainingDamage = 0;
      }
    }

    final newCurrent = (current - remainingDamage).clamp(0, maximum);
    return HitPoints(current: newCurrent, maximum: maximum, temporary: newTemp);
  }

  HitPoints heal(int amount) {
    final healAmount = amount < 0 ? 0 : amount;
    return HitPoints(
      current: (current + healAmount).clamp(0, maximum),
      maximum: maximum,
      temporary: temporary,
    );
  }

  HitPoints copyWith({int? current, int? maximum, int? temporary}) {
    return HitPoints(
      current: current ?? this.current,
      maximum: maximum ?? this.maximum,
      temporary: temporary ?? this.temporary,
    );
  }
}
