class SkillProficiencies {
  const SkillProficiencies({
    this.acrobatics = false,
    this.animalHandling = false,
    this.arcana = false,
    this.athletics = false,
    this.deception = false,
    this.history = false,
    this.insight = false,
    this.intimidation = false,
    this.investigation = false,
    this.medicine = false,
    this.nature = false,
    this.perception = false,
    this.performance = false,
    this.persuasion = false,
    this.religion = false,
    this.sleightOfHand = false,
    this.stealth = false,
    this.survival = false,
  });

  final bool acrobatics;
  final bool animalHandling;
  final bool arcana;
  final bool athletics;
  final bool deception;
  final bool history;
  final bool insight;
  final bool intimidation;
  final bool investigation;
  final bool medicine;
  final bool nature;
  final bool perception;
  final bool performance;
  final bool persuasion;
  final bool religion;
  final bool sleightOfHand;
  final bool stealth;
  final bool survival;

  SkillProficiencies copyWith({
    bool? acrobatics,
    bool? animalHandling,
    bool? arcana,
    bool? athletics,
    bool? deception,
    bool? history,
    bool? insight,
    bool? intimidation,
    bool? investigation,
    bool? medicine,
    bool? nature,
    bool? perception,
    bool? performance,
    bool? persuasion,
    bool? religion,
    bool? sleightOfHand,
    bool? stealth,
    bool? survival,
  }) {
    return SkillProficiencies(
      acrobatics: acrobatics ?? this.acrobatics,
      animalHandling: animalHandling ?? this.animalHandling,
      arcana: arcana ?? this.arcana,
      athletics: athletics ?? this.athletics,
      deception: deception ?? this.deception,
      history: history ?? this.history,
      insight: insight ?? this.insight,
      intimidation: intimidation ?? this.intimidation,
      investigation: investigation ?? this.investigation,
      medicine: medicine ?? this.medicine,
      nature: nature ?? this.nature,
      perception: perception ?? this.perception,
      performance: performance ?? this.performance,
      persuasion: persuasion ?? this.persuasion,
      religion: religion ?? this.religion,
      sleightOfHand: sleightOfHand ?? this.sleightOfHand,
      stealth: stealth ?? this.stealth,
      survival: survival ?? this.survival,
    );
  }
}