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
    this.tags = const [],
  });

  final String id;

  /// Id da classe a que pertence.
  final String classId;

  final String name;
  final String source;
  final String? description;
  final List<SubclassFeature> features;
  final List<String> tags;

  /// Características já liberadas para quem tem [level] níveis na classe.
  List<SubclassFeature> featuresUpTo(int level) {
    final visible = features
        .where((feature) => feature.level <= level)
        .toList(growable: false);

    return visible..sort((a, b) => a.level.compareTo(b.level));
  }
}
