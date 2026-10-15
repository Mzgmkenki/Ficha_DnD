import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';

/// O que uma fonte concede em idiomas.
///
/// Uma única concessão cobre as cinco formas que o levantamento pede, porque
/// elas se combinam em vez de se excluir:
///
/// ```json
/// { "languages": ["common", "elvish"] }                        // fixos
/// { "choose": 1 }                                              // uma vaga livre
/// { "choose": 2, "categories": ["standard"] }                  // duas vagas padrão
/// { "choose": 1, "options": ["dwarvish", "elvish", "giant"] }  // vaga restrita a 3
/// { "languages": ["druidic"], "requires_feature": "Druídico" } // condicionada
/// ```
///
/// Declarar isto no asset, em vez de inferir da descrição, é o que impede
/// `if (raca == 'elfo')` de aparecer na interface: a regra vem do dado.
class LanguageGrant {
  const LanguageGrant({
    required this.id,
    this.fixed = const [],
    this.choose = 0,
    this.categories = const [],
    this.options = const [],
    this.requiresFeature,
    this.label,
  });

  /// Id estável da concessão dentro da fonte.
  ///
  /// Entra na composição do id da vaga, que é o que o idioma escolhido guarda
  /// como origem. Sem ele, reordenar o asset mudaria a origem de escolhas já
  /// gravadas.
  final String id;

  /// Ids de idioma concedidos automaticamente, sem escolha.
  final List<String> fixed;

  /// Quantas vagas de escolha esta concessão abre.
  final int choose;

  /// Categorias às quais as vagas estão restritas. Vazio é "sem restrição de
  /// categoria", e aí vale a disponibilidade de cada idioma.
  final List<LanguageCategory> categories;

  /// Ids específicos entre os quais escolher.
  ///
  /// Quando preenchido, vence [categories]: é a forma mais restrita, do tipo
  /// "escolha entre Anão, Élfico e Gigante".
  final List<String> options;

  /// Nome da característica que precisa estar ativa para a concessão valer.
  ///
  /// Nulo é o caso normal. Preenchido, a concessão só entra se a fonte da
  /// característica estiver presente — é como Druídico e Gíria dos Ladrões
  /// entram sem virar escolha livre de ninguém.
  final String? requiresFeature;

  /// Texto curto para a interface explicar a vaga.
  final String? label;

  bool get hasFixed => fixed.isNotEmpty;

  bool get hasChoices => choose > 0;

  bool get isEmpty => !hasFixed && !hasChoices;

  /// Se a vaga aceita qualquer idioma oferecido, sem lista nem categoria.
  bool get isUnrestrictedChoice => options.isEmpty && categories.isEmpty;

  /// Rótulo pronto da restrição, para a vaga se explicar sozinha.
  String describeRestriction() {
    if (options.isNotEmpty) return 'escolha entre as opções listadas';
    if (categories.isEmpty) return 'qualquer idioma disponível';

    final labels = categories.map((item) => item.label).toList();
    if (labels.length == 1) return 'somente ${labels.single.toLowerCase()}';

    return 'somente ${labels.take(labels.length - 1).join(', ').toLowerCase()} '
        'ou ${labels.last.toLowerCase()}';
  }

  /// Se o idioma cabe nesta vaga, pelas regras declaradas na concessão.
  ///
  /// Não decide disponibilidade: isso é do catálogo. Aqui só se responde
  /// "a restrição desta vaga admite este idioma".
  bool admits(LanguageEntry language) {
    if (options.isNotEmpty) return options.contains(language.id);
    if (categories.isEmpty) return true;
    return categories.contains(language.category);
  }

  static LanguageGrant? tryParse(Object? raw, {required String fallbackId}) {
    if (raw is! Map) return null;

    final id = raw['id']?.toString().trim();

    int? asInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    List<String> idList(Object? value) {
      if (value is! List) return const [];
      return [
        for (final item in value)
          if (item.toString().trim().isNotEmpty) item.toString().trim(),
      ];
    }

    final choose = asInt(raw['choose']) ?? 0;
    final fixed = idList(raw['languages']);

    final categories = <LanguageCategory>[
      for (final item in idList(raw['categories']))
        if (LanguageCategory.fromId(item) case final category?) category,
    ];

    final feature = raw['requires_feature']?.toString().trim();
    final label = raw['label']?.toString().trim();

    final grant = LanguageGrant(
      id: id == null || id.isEmpty ? fallbackId : id,
      fixed: fixed,
      // Negativo viraria vaga fantasma na contagem; zero é "não abre vaga".
      choose: choose < 0 ? 0 : choose,
      categories: categories,
      options: idList(raw['options']),
      requiresFeature:
          feature == null || feature.isEmpty ? null : feature,
      label: label == null || label.isEmpty ? null : label,
    );

    // Concessão que não concede nada é dado incompleto, não regra.
    return grant.isEmpty ? null : grant;
  }

  static List<LanguageGrant> parseList(
    Object? raw, {
    required String idPrefix,
  }) {
    if (raw is! List) return const [];

    final result = <LanguageGrant>[];
    for (var index = 0; index < raw.length; index++) {
      final parsed = tryParse(
        raw[index],
        fallbackId: '$idPrefix.$index',
      );
      if (parsed != null) result.add(parsed);
    }

    return result;
  }
}
