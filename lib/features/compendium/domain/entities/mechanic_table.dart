/// Uma linha de tabela mecânica de classe ou subclasse.
///
/// Guarda os valores como texto alinhado às colunas declaradas, e não em
/// campos nomeados, porque as tabelas do levantamento não têm forma comum: a
/// Aura da Tempestade tem uma coluna por nível, o Surto de Magia Selvagem tem
/// faixa e efeito, e o Ancestral Dracônico tem dragão e tipo de dano. Um
/// modelo por tabela seria quarenta modelos.
class MechanicTableRow {
  const MechanicTableRow({
    required this.id,
    required this.label,
    this.values = const [],
    this.min,
    this.max,
    this.optionId,
    this.note,
  });

  /// Identificador estável da linha, único dentro da tabela.
  ///
  /// É o que fica persistido quando o jogador registra um resultado. O rótulo
  /// não serve: `01–02` é texto de apresentação e muda com a formatação.
  final String id;

  /// Como a linha aparece na primeira coluna: `01–02`, `3`, `Urso`.
  final String label;

  /// Demais células, na ordem de [MechanicTable.columns] a partir da segunda.
  final List<String> values;

  /// Menor valor de rolagem que cai nesta linha. Nulo em tabela de consulta.
  final int? min;

  /// Maior valor de rolagem que cai nesta linha.
  ///
  /// Igual a [min] quando a linha cobre um número só. Nulo em tabela de
  /// consulta, que não é rolada.
  final int? max;

  /// Opção da mecânica que esta linha representa, quando representa alguma.
  ///
  /// É o que liga a tabela do Espírito Totêmico às cinco opções escolhíveis
  /// sem duplicar nome e descrição nos dois lugares. Nulo é o caso comum: a
  /// maioria das linhas é só consulta.
  final String? optionId;

  final String? note;

  /// Se [value] cai nesta linha.
  ///
  /// Linha sem faixa declarada nunca casa, em vez de casar com tudo: tabela de
  /// consulta não deve responder a rolagem.
  bool matches(int value) {
    final low = min;
    if (low == null) return false;
    final high = max ?? low;
    return value >= low && value <= high;
  }

  /// Todas as células, para quem desenha a linha inteira.
  List<String> get cells => [label, ...values];

  /// O texto da linha numa frase, para busca e para o leitor de tela.
  String get searchText => [label, ...values, note ?? ''].join(' ');

  static MechanicTableRow? tryParse(Object? raw, {required int index}) {
    if (raw is! Map) return null;

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    int? number(String key) {
      final value = raw[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    final min = number('min') ?? number('roll');
    final max = number('max');

    // O rótulo cai para a faixa, e a faixa cai para o índice: linha sem
    // rótulo é dado incompleto, mas escondê-la perderia um efeito da tabela.
    final label =
        text('label') ??
        (min == null
            ? '${index + 1}'
            : max == null || max == min
            ? '$min'
            : '$min–$max');

    return MechanicTableRow(
      id: text('id') ?? 'row_${index + 1}',
      label: label,
      values: _parseValues(raw['values'] ?? raw['effect'] ?? raw['value']),
      min: min,
      max: max,
      optionId: text('option_id'),
      note: text('note'),
    );
  }

  static List<String> _parseValues(Object? raw) {
    if (raw == null) return const [];

    if (raw is String) {
      final value = raw.trim();
      return value.isEmpty ? const [] : List<String>.unmodifiable([value]);
    }

    if (raw is! List) {
      return List<String>.unmodifiable([raw.toString()]);
    }

    return List<String>.unmodifiable([
      for (final item in raw) item?.toString() ?? '',
    ]);
  }
}

/// Uma tabela mecânica declarada por uma classe ou subclasse.
///
/// Existe para a tabela ser CONSULTADA, não convertida em escolha permanente.
/// O levantamento é explícito nisso: as linhas do Surto de Magia Selvagem não
/// são 50 opções que o jogador compra, são 50 resultados possíveis. Quando uma
/// linha é de fato escolhível, ela aponta para a opção por
/// [MechanicTableRow.optionId].
class MechanicTable {
  const MechanicTable({
    required this.id,
    required this.title,
    required this.rows,
    this.columns = const [],
    this.dice,
    this.notes = const [],
    this.description,
  });

  /// Identificador estável da tabela.
  final String id;

  final String title;

  /// Cabeçalhos, na ordem em que as células aparecem.
  ///
  /// Vazio é válido: a tabela vira duas colunas implícitas, rótulo e efeito, e
  /// é assim que a maioria das tabelas de resultado se apresenta.
  final List<String> columns;

  final List<MechanicTableRow> rows;

  /// Dado que rola nesta tabela: `d6`, `d8`, `d12`, `d100`.
  ///
  /// Nulo em tabela de consulta. É o que decide se a interface oferece o botão
  /// de rolar — e não um palpite a partir da quantidade de linhas, que daria
  /// errado numa tabela de faixas.
  final String? dice;

  /// Observações que acompanham a tabela no livro.
  final List<String> notes;

  final String? description;

  bool get isEmpty => rows.isEmpty;

  /// Se a tabela pode ser rolada.
  bool get isRollable => faces != null && faces! > 0;

  /// Quantidade de faces do dado declarado, ou nulo quando não há dado.
  ///
  /// `d100` devolve 100, e é o único caso em que a tabela cobre `00` como
  /// 100 — tratado na própria faixa da linha, não aqui.
  int? get faces {
    final value = dice?.trim().toLowerCase();
    if (value == null || value.isEmpty) return null;

    final match = RegExp(r'^(\d*)d(\d+)$').firstMatch(value);
    if (match == null) return int.tryParse(value);

    return int.tryParse(match.group(2) ?? '');
  }

  /// Quantos dados a tabela rola de uma vez. Um, salvo declaração explícita.
  int get diceCount {
    final value = dice?.trim().toLowerCase();
    if (value == null || value.isEmpty) return 1;

    final match = RegExp(r'^(\d*)d(\d+)$').firstMatch(value);
    final count = match?.group(1);
    if (count == null || count.isEmpty) return 1;

    return int.tryParse(count) ?? 1;
  }

  /// Cabeçalhos efetivos, já com o padrão de duas colunas quando o asset não
  /// declara nenhum.
  List<String> get effectiveColumns {
    if (columns.isNotEmpty) return columns;

    final width = rows.fold<int>(0, (max, row) {
      final length = row.cells.length;
      return length > max ? length : max;
    });

    if (width <= 1) return const ['Resultado'];
    if (width == 2) return const ['Resultado', 'Efeito'];

    return List<String>.unmodifiable([
      'Resultado',
      for (var index = 1; index < width; index++) 'Coluna $index',
    ]);
  }

  MechanicTableRow? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final row in rows) {
      if (row.id == id) return row;
    }
    return null;
  }

  /// A linha em que [value] cai, ou nulo quando nenhuma cobre o valor.
  ///
  /// Nulo em vez de uma linha aproximada: resultado fora da tabela é dado
  /// inconsistente, e mostrar o efeito errado é pior que não mostrar nenhum.
  MechanicTableRow? rowFor(int value) {
    for (final row in rows) {
      if (row.matches(value)) return row;
    }
    return null;
  }

  /// Linhas que contêm [query], para a busca das tabelas longas.
  List<MechanicTableRow> search(String? query) {
    final needle = query?.trim().toLowerCase();
    if (needle == null || needle.isEmpty) return rows;

    return [
      for (final row in rows)
        if (row.searchText.toLowerCase().contains(needle)) row,
    ];
  }

  static MechanicTable? tryParse(Object? raw, {String? fallbackId}) {
    if (raw is! Map) return null;

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    final rows = <MechanicTableRow>[];
    final rawRows = raw['rows'];
    if (rawRows is List) {
      for (var index = 0; index < rawRows.length; index++) {
        final row = MechanicTableRow.tryParse(rawRows[index], index: index);
        if (row != null) rows.add(row);
      }
    }

    // Tabela sem linha nenhuma é dado incompleto, e mostrá-la como seção
    // vazia na ficha só ocuparia espaço.
    if (rows.isEmpty) return null;

    final id = text('id') ?? fallbackId;
    if (id == null) return null;

    return MechanicTable(
      id: id,
      title: text('title') ?? 'Tabela',
      columns: MechanicPrerequisiteStrings.parse(raw['columns']),
      rows: List<MechanicTableRow>.unmodifiable(rows),
      dice: text('dice'),
      notes: MechanicPrerequisiteStrings.parse(raw['notes']),
      description: text('description'),
    );
  }
}

/// Leitura de array de texto, compartilhada pelas entidades de mecânica.
///
/// Existe como utilitário próprio para a tabela não importar o arquivo de
/// pré-requisito só por causa de um parser de lista de strings.
class MechanicPrerequisiteStrings {
  const MechanicPrerequisiteStrings._();

  static List<String> parse(Object? raw) {
    if (raw == null) return const [];

    if (raw is String) {
      final value = raw.trim();
      return value.isEmpty ? const [] : List<String>.unmodifiable([value]);
    }

    if (raw is! List) return const [];

    final result = <String>[];
    for (final item in raw) {
      final value = item?.toString().trim();
      if (value == null || value.isEmpty) continue;
      result.add(value);
    }

    return result.isEmpty ? const [] : List<String>.unmodifiable(result);
  }
}
