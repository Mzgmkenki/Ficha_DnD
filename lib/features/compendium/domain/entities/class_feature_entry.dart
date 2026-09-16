/// Uma característica de classe, com o texto que explica o que ela faz.
///
/// A descrição é opcional porque o compêndio pode ser preenchido por partes: um
/// nome sem texto continua aparecendo na ficha, só sem a explicação.
class ClassFeature {
  const ClassFeature({required this.name, this.description});

  final String name;
  final String? description;

  bool get hasDescription {
    final text = description;
    return text != null && text.trim().isNotEmpty;
  }

  /// Lê tanto `"Fúria"` quanto `{"name": "Fúria", "description": "..."}`.
  ///
  /// A tolerância é de propósito: com 13 classes e mais de 200 características,
  /// o arquivo pode ficar meio migrado por um tempo, e um formato antigo numa
  /// entrada não pode derrubar o compêndio inteiro.
  static ClassFeature? tryParse(Object? raw) {
    if (raw is String) {
      final name = raw.trim();
      return name.isEmpty ? null : ClassFeature(name: name);
    }

    if (raw is Map) {
      final name = raw['name']?.toString().trim() ?? '';
      if (name.isEmpty) return null;

      final description = raw['description']?.toString().trim();

      return ClassFeature(
        name: name,
        description: description == null || description.isEmpty
            ? null
            : description,
      );
    }

    return null;
  }
}

class ClassFeatureEntry {
  const ClassFeatureEntry({
    required this.classId,
    required this.level,
    required this.features,
    required this.source,
  });

  final String classId;
  final int level;
  final List<ClassFeature> features;
  final String source;

  /// Só os nomes, para quem não precisa do texto.
  List<String> get featureNames =>
      features.map((item) => item.name).toList(growable: false);
}
