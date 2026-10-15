/// Em que grupo de regra o idioma se encaixa.
///
/// A categoria é o que permite uma vaga de escolha dizer "dois idiomas
/// padrão" sem listar os oito nomes: a restrição é declarada pela categoria,
/// e a lista sai do catálogo.
enum LanguageCategory {
  standard('standard', 'Idioma padrão'),
  exotic('exotic', 'Idioma exótico'),
  primordialDialect('primordial_dialect', 'Dialeto de Primordial'),
  secret('secret', 'Idioma secreto'),
  peopleSetting('people_setting', 'Idioma de povo ou cenário'),
  faerunRegional('faerun_regional', 'Idioma regional de Faerûn'),
  historical('historical', 'Idioma histórico'),
  creature('creature', 'Idioma de criatura');

  const LanguageCategory(this.id, this.label);

  final String id;
  final String label;

  static LanguageCategory? fromId(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}

/// Quando o idioma pode ser escolhido pelo jogador.
///
/// Separado de [LanguageCategory] de propósito: categoria é o que o idioma
/// É, disponibilidade é o que o app faz com ele. Dialeto de Primordial e
/// idioma exótico são categorias diferentes com a mesma disponibilidade, e
/// Druídico é secreto por categoria mas indisponível por ser de classe.
enum LanguageAvailability {
  /// Aparece na lista sem filtro adicional.
  standard('standard'),

  /// Opção exótica condicionada ao Mestre. Aparece, com aviso.
  dungeonMaster('dm_authorization'),

  /// Só entra por característica que o conceda. NUNCA aparece como escolha.
  ///
  /// É o caso de Druídico e Gíria dos Ladrões: deixá-los na lista comum
  /// permitiria a um Guerreiro escolher o idioma secreto dos druidas.
  featureOnly('feature_only'),

  /// Depende de a fonte do livro estar ativa.
  sourceGated('source_gated'),

  /// Depende de o cenário estar ativo.
  settingGated('setting_gated'),

  /// Uso excepcional: só por concessão explícita.
  restricted('restricted'),

  /// Idioma de criatura. Fora da lista padrão.
  hidden('hidden');

  const LanguageAvailability(this.id);

  final String id;

  /// Se entra na lista de uma vaga comum, sem o jogador pedir nada.
  bool get isOfferedByDefault =>
      this == standard || this == dungeonMaster;

  /// Se entra na lista quando o jogador liga "incluir cenários e fontes".
  ///
  /// Idioma de criatura e histórico ficam fora mesmo com o filtro ligado: o
  /// levantamento é explícito em não poluir a lista com eles.
  bool get isOfferedWhenGatedShown =>
      isOfferedByDefault || this == sourceGated || this == settingGated;

  /// Se só pode entrar por concessão, nunca por escolha livre.
  bool get requiresExplicitGrant =>
      this == featureOnly || this == restricted || this == hidden;

  static LanguageAvailability? fromId(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}

/// Um idioma do compêndio.
///
/// Formato esperado em `assets/data/srd/languages.json`:
///
/// ```json
/// {
///   "id": "elvish",
///   "name": "Élfico",
///   "name_original": "Elvish",
///   "category": "standard",
///   "script": "Élfico",
///   "speakers": "Elfos.",
///   "availability": "standard",
///   "source": "phb",
///   "edition": "2014",
///   "aliases": ["Elfico", "Elfo"],
///   "dialect_of": "primordial",
///   "notes": "..."
/// }
/// ```
///
/// O [id] é a única coisa que o personagem guarda. Nome traduzido, nome
/// original e [aliases] existem para RECONHECER o idioma num texto livre
/// (é o que permite converter `"languages": ["Comum", "Élfico"]` das raças
/// em ids), nunca para identificá-lo na ficha salva: renomear "Leonino" para
/// "Leonin" não pode fazer um personagem perder o idioma.
class LanguageEntry {
  const LanguageEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.availability,
    this.nameOriginal,
    this.script,
    this.speakers,
    this.source = 'phb',
    this.edition = '2014',
    this.aliases = const [],
    this.dialectOf,
    this.notes,
  });

  /// Id estável. É o que vai para a ficha.
  final String id;

  /// Nome em português, como a interface mostra.
  final String name;

  /// Nome em inglês, para conferir no livro.
  final String? nameOriginal;

  final LanguageCategory category;
  final LanguageAvailability availability;

  /// Escrita ou alfabeto. Nulo é "não especificado na fonte", e não vale
  /// inventar: conhecer uma escrita não concede os idiomas que a usam.
  final String? script;

  /// Quem fala, em texto curto.
  final String? speakers;

  /// Id da fonte (`phb`, `scag`, `ggr`).
  final String source;

  /// Linha de regras. Existe para não misturar edições.
  final String edition;

  /// Outros nomes pelos quais o idioma pode aparecer em texto livre.
  final List<String> aliases;

  /// Id do idioma de que este é dialeto, quando é.
  ///
  /// Aquan, Auran, Ignan e Terran apontam para `primordial`. Serve para a
  /// ficha explicar que falantes de dialetos diferentes se entendem.
  final String? dialectOf;

  final String? notes;

  bool get isSecret => category == LanguageCategory.secret;

  bool get isStandard => category == LanguageCategory.standard;

  bool get isExotic =>
      category == LanguageCategory.exotic ||
      category == LanguageCategory.primordialDialect;

  /// Nome com o original entre parênteses, quando há original diferente.
  String get displayName {
    final original = nameOriginal;
    if (original == null || original.isEmpty || original == name) return name;
    return '$name ($original)';
  }

  /// Todos os textos pelos quais este idioma pode ser reconhecido.
  List<String> get searchableNames => [
        name,
        if (nameOriginal case final value?) value,
        ...aliases,
      ];

  /// Se o texto bate com o nome, o original ou um alias.
  ///
  /// Comparação normalizada: `elfico`, `ÉLFICO` e `  Élfico  ` acham o mesmo
  /// idioma. É o que torna a importação do TXT tolerante a acentuação e
  /// caixa sem precisar de uma tabela de variantes por idioma.
  bool matchesName(String value) {
    final needle = normalizeName(value);
    if (needle.isEmpty) return false;
    if (normalizeName(id) == needle) return true;

    for (final candidate in searchableNames) {
      if (normalizeName(candidate) == needle) return true;
    }
    return false;
  }

  /// Se o texto aparece em qualquer campo pesquisável. Usado pela busca da
  /// interface, que precisa achar por pedaço do nome.
  bool containsQuery(String query) {
    final needle = normalizeName(query);
    if (needle.isEmpty) return true;

    for (final candidate in searchableNames) {
      if (normalizeName(candidate).contains(needle)) return true;
    }
    return normalizeName(id).contains(needle);
  }

  /// Caixa baixa, sem acento, sem espaço duplicado e sem pontuação de borda.
  ///
  /// Escrita à mão porque o Dart não traz normalização Unicode na biblioteca
  /// padrão e a alternativa seria uma dependência nova só para isto. Cobre o
  /// que o compêndio em português usa.
  static String normalizeName(String value) {
    final lowered = value.trim().toLowerCase();

    final buffer = StringBuffer();
    for (final rune in lowered.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_accentFolding[char] ?? char);
    }

    return buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static const Map<String, String> _accentFolding = {
    'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
  };

  /// Lê uma entrada do asset. Devolve nulo quando falta o essencial.
  ///
  /// Tolerante como o resto do compêndio: um registro quebrado é descartado
  /// em vez de derrubar a leitura dos outros 78. Categoria ou
  /// disponibilidade desconhecidas também descartam, porque adivinhar aqui
  /// colocaria um idioma de criatura na lista de escolha livre.
  static LanguageEntry? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final id = raw['id']?.toString().trim();
    if (id == null || id.isEmpty) return null;

    final name = raw['name']?.toString().trim();
    if (name == null || name.isEmpty) return null;

    final category = LanguageCategory.fromId(raw['category']?.toString());
    if (category == null) return null;

    final availability = LanguageAvailability.fromId(
      raw['availability']?.toString(),
    );
    if (availability == null) return null;

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    return LanguageEntry(
      id: id,
      name: name,
      nameOriginal: text('name_original'),
      category: category,
      availability: availability,
      script: text('script'),
      speakers: text('speakers'),
      source: text('source') ?? 'phb',
      edition: text('edition') ?? '2014',
      aliases: [
        for (final item in (raw['aliases'] is List
            ? raw['aliases'] as List
            : const []))
          if (item.toString().trim().isNotEmpty) item.toString().trim(),
      ],
      dialectOf: text('dialect_of'),
      notes: text('notes'),
    );
  }

  static List<LanguageEntry> parseList(Object? raw) {
    if (raw is! List) return const [];

    return [
      for (final item in raw)
        if (tryParse(item) case final entry?) entry,
    ];
  }
}
