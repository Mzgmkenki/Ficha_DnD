class SavingThrowProficiencies {
  const SavingThrowProficiencies({
    this.strength = false,
    this.dexterity = false,
    this.constitution = false,
    this.intelligence = false,
    this.wisdom = false,
    this.charisma = false,
  });

  final bool strength;
  final bool dexterity;
  final bool constitution;
  final bool intelligence;
  final bool wisdom;
  final bool charisma;

  SavingThrowProficiencies copyWith({
    bool? strength,
    bool? dexterity,
    bool? constitution,
    bool? intelligence,
    bool? wisdom,
    bool? charisma,
  }) {
    return SavingThrowProficiencies(
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
    );
  }
}