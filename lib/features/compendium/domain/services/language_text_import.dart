import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_grant.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_catalog.dart';

/// O que sobrou sem reconhecimento numa importação de texto livre.
class LanguageTextIssue {
  const LanguageTextIssue({required this.text, required this.reason});

  final String text;
  final String reason;

  String get description => '"$text": $reason';
}

/// Resultado de converter texto livre em concessões estruturadas.
class LanguageTextImport {
  const LanguageTextImport({required this.grants, required this.issues});

  static const LanguageTextImport empty = LanguageTextImport(
    grants: <LanguageGrant>[],
    issues: <LanguageTextIssue>[],
  );

  final List<LanguageGrant> grants;

  /// Trechos que o catálogo não reconheceu.
  ///
  /// Não viram concessão: um texto que o app não entendeu não pode conceder
  /// idioma inventado nem abrir vaga fantasma. Ficam aqui para o relatório.
  final List<LanguageTextIssue> issues;

  bool get isEmpty => grants.isEmpty;
}

/// Converte a lista de idiomas em texto livre do compêndio em concessões.
///
/// Por que isto existe: o asset de raças sempre guardou idioma como frase
/// (`["Comum", "um idioma à escolha"]`), que é ótimo para exibir e inútil para
/// validar. Em vez de reescrever as 78 raças à mão, o texto é IMPORTADO uma vez
/// na carga do compêndio e normalizado em ids pelo catálogo — que é exatamente
/// o passo de importação pedido no levantamento, com acento, caixa e espaço
/// normalizados e reconhecimento por nome, nome original e alias.
///
/// A distinção que importa: nome é usado para RECONHECER na importação, nunca
/// para identificar o idioma depois. O que sai daqui são ids, e é só com id que
/// as regras e a ficha trabalham. Uma raça que precise de algo que a frase não
/// expressa declara `language_grants` no asset, e aí a declaração vence.
class LanguageTextImporter {
  const LanguageTextImporter._();

  /// Frases que significam "o jogador escolhe", por quantidade.
  static const Map<String, int> _quantityWords = {
    'um': 1,
    'uma': 1,
    'dois': 2,
    'duas': 2,
    'tres': 3,
    'quatro': 4,
  };

  /// Converte [texts] em concessões, usando [catalog] para reconhecer nomes.
  static LanguageTextImport convert({
    required Iterable<String> texts,
    required LanguageCatalog catalog,
    required String idPrefix,
  }) {
    if (catalog.isEmpty) return LanguageTextImport.empty;

    final fixed = <String>[];
    final grants = <LanguageGrant>[];
    final issues = <LanguageTextIssue>[];
    var choiceIndex = 0;

    for (final raw in texts) {
      final text = raw.trim();
      if (text.isEmpty) continue;

      // 1. Nome direto: o caso da maioria.
      final direct = catalog.resolve(text);
      if (direct != null) {
        if (!fixed.contains(direct.id)) fixed.add(direct.id);
        continue;
      }

      // 2. "Élfico ou Vedalken": escolha entre uma lista nomeada.
      final alternatives = _splitAlternatives(text, catalog);
      if (alternatives.length > 1) {
        grants.add(
          LanguageGrant(
            id: '$idPrefix.choice.$choiceIndex',
            choose: 1,
            options: alternatives,
            label: 'Escolha entre as opções da origem',
          ),
        );
        choiceIndex++;
        continue;
      }

      // 3. "um idioma à escolha": vaga livre.
      final quantity = _quantityOfFreeChoice(text);
      if (quantity != null) {
        grants.add(
          LanguageGrant(
            id: '$idPrefix.choice.$choiceIndex',
            choose: quantity,
            label: 'Idioma à escolha',
          ),
        );
        choiceIndex++;
        continue;
      }

      issues.add(
        LanguageTextIssue(
          text: text,
          reason: 'não corresponde a nenhum idioma do catálogo nem a uma '
              'frase de escolha reconhecida',
        ),
      );
    }

    return LanguageTextImport(
      grants: [
        if (fixed.isNotEmpty)
          LanguageGrant(id: '$idPrefix.fixed', fixed: fixed),
        ...grants,
      ],
      issues: issues,
    );
  }

  /// Quebra `"A ou B"` nos ids reconhecidos, ou devolve lista vazia.
  static List<String> _splitAlternatives(
    String text,
    LanguageCatalog catalog,
  ) {
    final normalized = LanguageEntry.normalizeName(text);
    if (!normalized.contains(' ou ')) return const [];

    final result = <String>[];
    for (final part in normalized.split(' ou ')) {
      final entry = catalog.resolve(part);
      // Uma parte não reconhecida invalida a leitura inteira: oferecer só
      // metade das opções seria pior que não oferecer escolha nenhuma.
      if (entry == null) return const [];
      if (!result.contains(entry.id)) result.add(entry.id);
    }

    return result;
  }

  /// Quantas vagas a frase abre, ou nulo se não for frase de escolha.
  static int? _quantityOfFreeChoice(String text) {
    final normalized = LanguageEntry.normalizeName(text);
    if (!normalized.contains('idioma')) return null;

    // Exige a marca de escolha: "idioma anão" não é vaga, é idioma.
    const markers = ['a escolha', 'escolha', 'adicional', 'adicionais'];
    if (!markers.any(normalized.contains)) return null;

    for (final entry in _quantityWords.entries) {
      if (normalized.startsWith('${entry.key} ') ||
          normalized.contains(' ${entry.key} ')) {
        return entry.value;
      }
    }

    // "idiomas à escolha" no plural, sem número: assume um, que é o mínimo
    // defensável. Inventar dois daria idioma de graça.
    return 1;
  }
}
