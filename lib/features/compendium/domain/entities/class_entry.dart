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
    this.subclassLevel,
    this.subclassLabel,
  });

  final String id;
  final String name;
  final String hitDie;
  final String? primaryAbility;
  final String? spellcastingType;

  /// Nível de classe em que a subclasse é escolhida.
  ///
  /// Varia por classe: Clérigo, Feiticeiro e Bruxo no 1º, Druida e Mago no 2º,
  /// as demais no 3º.
  final int? subclassLevel;

  /// Como a classe chama a própria subclasse: Domínio Divino, Arquétipo
  /// Marcial, Círculo Druídico e assim por diante.
  final String? subclassLabel;

  String get subclassLabelOrDefault {
    final label = subclassLabel?.trim();
    if (label == null || label.isEmpty) return 'Subclasse';
    return label;
  }

  /// Se o personagem já pode escolher a subclasse com [level] níveis nesta
  /// classe.
  bool subclassUnlockedAt(int level) {
    final required = subclassLevel;
    if (required == null) return false;
    return level >= required;
  }

  /// Atributo usado para conjurar. Não confundir com [primaryAbility]: o
  /// Patrulheiro tem Destreza como atributo primário, mas conjura com
  /// Sabedoria.
  final String? spellcastingAbility;

  final String source;
  final List<String> skillOptions;
  final List<String> savingThrows;

  bool get isSpellcaster {
    final type = spellcastingType?.trim().toLowerCase();
    return type == 'full' ||
        type == 'half' ||
        type == 'third' ||
        type == 'pact' ||
        type == 'artificer';
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
      // O artífice conjura desde o 1º nível, diferente dos outros
      // meio-conjuradores.
      case 'artificer':
        return 1;
      default:
        return 0;
    }
  }
}
