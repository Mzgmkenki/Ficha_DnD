/// Magias que a subclasse concede num nível de classe.
///
/// Guardamos o nome, não o id: o documento de origem lista as magias por nome,
/// e um id numérico digitado à mão seria impossível de revisar. A conversão
/// para id acontece no `SpellNameIndex`, e há teste garantindo que todo nome
/// citado existe no compêndio.
class SubclassSpellGrant {
  const SubclassSpellGrant({required this.level, required this.spellNames});

  /// Nível de classe em que as magias passam a estar disponíveis.
  final int level;

  final List<String> spellNames;
}

/// Característica que a subclasse concede num nível específico.
class SubclassFeature {
  const SubclassFeature({
    required this.level,
    required this.name,
    required this.description,
  });

  /// Nível de classe em que a característica é liberada.
  final int level;

  final String name;
  final String description;
}

/// Subclasse de uma classe: Campeão do Guerreiro, Domínio da Vida do Clérigo.
///
/// O nível em que a escolha acontece não fica aqui, e sim em
/// `ClassEntry.subclassLevel`, porque é a classe que define isso — o Guerreiro
/// escolhe no 3º nível, o Clérigo já no 1º.
class SubclassEntry {
  const SubclassEntry({
    required this.id,
    required this.classId,
    required this.name,
    required this.source,
    this.description,
    this.features = const [],
    this.spells = const [],
    this.tags = const [],
  });

  final String id;

  /// Id da classe a que pertence.
  final String classId;

  final String name;
  final String source;
  final String? description;
  final List<SubclassFeature> features;

  /// Magias concedidas pela subclasse, por nível de classe.
  final List<SubclassSpellGrant> spells;

  final List<String> tags;

  /// Características já liberadas para quem tem [level] níveis na classe.
  List<SubclassFeature> featuresUpTo(int level) {
    final visible = features
        .where((feature) => feature.level <= level)
        .toList(growable: false);

    return visible..sort((a, b) => a.level.compareTo(b.level));
  }

  /// Nomes das magias já liberadas para quem tem [level] níveis na classe.
  ///
  /// Sem repetição: uma magia que apareça em dois níveis (acontece nas listas
  /// escritas à mão) entra uma vez só.
  List<String> spellNamesUpTo(int level) {
    final names = <String>{};

    for (final grant in spells) {
      if (grant.level > level) continue;
      names.addAll(grant.spellNames.where((name) => name.trim().isNotEmpty));
    }

    return names.toList(growable: false);
  }
}
