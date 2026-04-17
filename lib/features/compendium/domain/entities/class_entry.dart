class ClassEntry {
  const ClassEntry({
    required this.id,
    required this.name,
    required this.hitDie,
    required this.source,
    required this.skillOptions,
    required this.savingThrows,
    this.primaryAbility,
    this.spellcastingType,
  });

  final String id;
  final String name;
  final String hitDie;
  final String? primaryAbility;
  final String? spellcastingType;
  final String source;
  final List<String> skillOptions;
  final List<String> savingThrows;
}