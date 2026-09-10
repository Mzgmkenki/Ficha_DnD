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
    this.spellcastingAbility,
  });

  final String id;
  final String name;
  final String hitDie;
  final String? primaryAbility;
  final String? spellcastingType;

  /// Atributo usado para conjurar. Não confundir com [primaryAbility]: o
  /// Patrulheiro tem Destreza como atributo primário, mas conjura com
  /// Sabedoria.
  final String? spellcastingAbility;

  final String source;
  final List<String> skillOptions;
  final List<String> savingThrows;

  bool get isSpellcaster {
    final type = spellcastingType?.trim().toLowerCase();
    return type == 'full' || type == 'half' || type == 'third' || type == 'pact';
  }

  /// Nível de classe a partir do qual a classe realmente conjura.
  /// Meio-conjuradores começam no 2, um-terço-conjuradores no 3.
  int get spellcastingStartLevel {
    switch (spellcastingType?.trim().toLowerCase()) {
      case 'half':
        return 2;
      case 'third':
        return 3;
      case 'full':
      case 'pact':
        return 1;
      default:
        return 0;
    }
  }
}
