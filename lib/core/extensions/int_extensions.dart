extension DndIntExtensions on int {
  int get abilityModifier => ((this - 10) / 2).floor();

  int get proficiencyBonus {
    if (this <= 0) return 2;
    return ((this - 1) / 4).floor() + 2;
  }
}
