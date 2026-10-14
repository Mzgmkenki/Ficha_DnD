/// Um registro de magia no formato dos assets, antes de virar `SpellEntry`.
///
/// O importador trabalha neste formato (chaves em português, `classes` e
/// `subclasses` como texto separado por vírgula) porque é o que vai para o
/// arquivo. Converter para `SpellEntry` primeiro perderia o que o asset guarda
/// e não a entidade: a grafia exata do nome da classe, por exemplo, que é o que
/// decide se a magia aparece nos filtros.
///
/// Fora do formato do asset existem dois campos só de importação, [edition] e
/// [aliases], usados para decidir identidade. Eles não são gravados no arquivo
/// porque `loadSpells` não os lê — [edition] entra na identidade com o valor
/// padrão `2014`, que é a edição de todo o conteúdo do app hoje.
class SpellRecord {
  const SpellRecord({
    required this.id,
    required this.namePt,
    required this.nameOriginal,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.components,
    required this.hasCostlyMaterials,
    required this.duration,
    required this.concentration,
    required this.ritual,
    required this.classes,
    required this.subclasses,
    required this.description,
    required this.upcast,
    required this.source,
    required this.page,
    required this.isSrd,
    this.edition = defaultEdition,
    this.aliases = const [],
  });

  /// Edição assumida quando a fonte não declara uma.
  ///
  /// Todo o conteúdo do app é 2014. Assumir em silêncio seria errado num app
  /// com duas edições, mas aqui o alternativo seria pedir o campo em todas as
  /// 477 magias já existentes.
  static const String defaultEdition = '2014';

  final int id;
  final String namePt;
  final String nameOriginal;
  final int level;
  final String school;
  final String castingTime;
  final String range;
  final String components;
  final bool hasCostlyMaterials;
  final String duration;
  final bool concentration;
  final bool ritual;
  final List<String> classes;
  final List<String> subclasses;
  final String description;
  final String? upcast;
  final String source;
  final String page;
  final bool isSrd;
  final String edition;
  final List<String> aliases;

  /// Rótulo para relatório e mensagem de erro.
  String get label {
    final name =
        namePt.isNotEmpty
            ? namePt
            : (nameOriginal.isNotEmpty ? nameOriginal : '(sem nome)');
    return '$name [id $id, $source]';
  }

  SpellRecord copyWith({
    int? id,
    String? namePt,
    String? nameOriginal,
    int? level,
    String? school,
    String? castingTime,
    String? range,
    String? components,
    bool? hasCostlyMaterials,
    String? duration,
    bool? concentration,
    bool? ritual,
    List<String>? classes,
    List<String>? subclasses,
    String? description,
    String? upcast,
    String? source,
    String? page,
    bool? isSrd,
    String? edition,
    List<String>? aliases,
  }) {
    return SpellRecord(
      id: id ?? this.id,
      namePt: namePt ?? this.namePt,
      nameOriginal: nameOriginal ?? this.nameOriginal,
      level: level ?? this.level,
      school: school ?? this.school,
      castingTime: castingTime ?? this.castingTime,
      range: range ?? this.range,
      components: components ?? this.components,
      hasCostlyMaterials: hasCostlyMaterials ?? this.hasCostlyMaterials,
      duration: duration ?? this.duration,
      concentration: concentration ?? this.concentration,
      ritual: ritual ?? this.ritual,
      classes: classes ?? this.classes,
      subclasses: subclasses ?? this.subclasses,
      description: description ?? this.description,
      upcast: upcast ?? this.upcast,
      source: source ?? this.source,
      page: page ?? this.page,
      isSrd: isSrd ?? this.isSrd,
      edition: edition ?? this.edition,
      aliases: aliases ?? this.aliases,
    );
  }

  /// Serializa na forma exata que `loadSpells` lê.
  ///
  /// A ordem das chaves segue os assets que já existem, para o `git diff` de
  /// uma magia nova ficar legível ao lado das antigas.
  Map<String, dynamic> toAssetJson() {
    return {
      'nome': namePt,
      'id': id,
      'original': nameOriginal,
      'nivel': level,
      'escola': school,
      'tempo': castingTime,
      'alcance': range,
      'componentes': components,
      'materiaispagos': hasCostlyMaterials,
      'duracao': duration,
      'concentracao': concentration,
      'ritual': ritual,
      'classes': classes.join(', '),
      'subclasses': subclasses.join(', '),
      'descricao': description,
      'upcast': upcast ?? '',
      'fonte': source,
      'pagina': page,
      'srd': isSrd,
    };
  }
}
