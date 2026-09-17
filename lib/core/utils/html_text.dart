/// Converte o HTML embutido nos assets em texto plano.
///
/// Os arquivos de magia vieram de uma extração de site e guardam markup dentro
/// dos campos de texto: `<br>`, `<b>`, `<i>`, `<div>`, listas `<ul>/<li>`,
/// tabelas completas (`<table>/<tr>/<th>/<td>`) e a entidade `&emsp;`, usada
/// como recuo de parágrafo. São 2.058 ocorrências nos três arquivos.
///
/// A ficha renderiza descrição com `Text`, que não interpreta HTML, então o
/// markup aparecia literal na tela — era o `.<br>&emsp;A criatura...` visível
/// em Invocar Besta.
///
/// A conversão roda na leitura do asset, e não na tela, porque a descrição é
/// exibida em mais de um lugar (detalhe da magia no compêndio e painel de
/// magias da ficha) e um deles não limpava nada.
library;

/// Separador de célula de tabela no texto plano.
const _cellSeparator = ' | ';

final _lineBreak = RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false);
final _listItemEnd = RegExp(r'<\s*/\s*li\s*>', caseSensitive: false);
final _listItemStart = RegExp(r'<\s*li[^>]*>', caseSensitive: false);
final _listWrapper = RegExp(r'<\s*/?\s*(?:ul|ol)[^>]*>', caseSensitive: false);
final _tableRowEnd = RegExp(r'<\s*/\s*tr\s*>', caseSensitive: false);
final _tableCellEnd = RegExp(r'<\s*/\s*(?:td|th)\s*>', caseSensitive: false);
final _tableWrapper = RegExp(
  r'<\s*/?\s*(?:table|thead|tbody|tfoot)[^>]*>',
  caseSensitive: false,
);
final _anyTag = RegExp(r'<[^>]*>');
final _entity = RegExp(r'&(#[xX]?[0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]*);');
final _horizontalSpace = RegExp(r'[ \t\u00a0\u2002\u2003\u2009]+');
final _blankLines = RegExp(r'\n{3,}');

/// Entidades nomeadas que o decodificador reconhece.
///
/// Nos assets atuais só aparece `emsp`, mas o resto é o conjunto comum de
/// extração de HTML e não custa nada manter aqui: sem isso, uma entidade nova
/// em algum asset futuro voltaria a vazar para a tela sem ninguém notar.
const _namedEntities = <String, String>{
  'emsp': ' ',
  'ensp': ' ',
  'thinsp': ' ',
  'nbsp': ' ',
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'bull': '•',
  'mdash': '—',
  'ndash': '–',
  'hellip': '…',
  'times': '×',
  'deg': '°',
  'ldquo': '“',
  'rdquo': '”',
  'lsquo': '‘',
  'rsquo': '’',
  'laquo': '«',
  'raquo': '»',
  'frac12': '½',
  'frac14': '¼',
  'frac34': '¾',
};

/// Devolve [raw] sem markup, pronto para exibição em `Text`.
///
/// Preserva a estrutura do texto: `<br>` e fim de `<li>`/`<tr>` viram quebra de
/// linha, item de lista ganha marcador, e célula de tabela é separada por
/// barra vertical. Tag que só formata (`<b>`, `<i>`, `<div>`) desaparece, já
/// que a exibição é em texto plano.
String htmlToPlainText(String raw) {
  // A grande maioria dos campos não tem markup nenhum. Sair cedo evita rodar
  // dez expressões regulares em cima de milhares de strings limpas.
  if (!raw.contains('<') && !raw.contains('&')) return raw;

  var text = raw
      .replaceAll(_lineBreak, '\n')
      // Listas: cada item vira uma linha com marcador.
      .replaceAll(_listItemEnd, '\n')
      .replaceAll(_listItemStart, '• ')
      .replaceAll(_listWrapper, '\n')
      // Tabelas: uma linha por `<tr>`, células separadas por barra vertical.
      .replaceAll(_tableRowEnd, '\n')
      .replaceAll(_tableCellEnd, _cellSeparator)
      .replaceAll(_tableWrapper, '\n')
      // O que sobrou só embrulha texto que já vai ser exibido: abertura de
      // célula e de linha, `<b>`, `<i>`, `<div>`.
      .replaceAll(_anyTag, '');

  text = _decodeEntities(text);

  return _tidy(text);
}

/// Igual a [htmlToPlainText], mas repassa nulo adiante.
///
/// Existe porque `upcast` é opcional e virar string vazia mudaria o
/// comportamento de quem checa `!= null` antes de mostrar a seção.
String? htmlToPlainTextOrNull(String? raw) {
  if (raw == null) return null;
  return htmlToPlainText(raw);
}

String _decodeEntities(String value) {
  if (!value.contains('&')) return value;

  return value.replaceAllMapped(_entity, (match) {
    final body = match.group(1)!;
    final original = match.group(0)!;

    if (body.startsWith('#')) {
      final isHex = body.length > 1 && (body[1] == 'x' || body[1] == 'X');
      final digits = isHex ? body.substring(2) : body.substring(1);
      final code = int.tryParse(digits, radix: isHex ? 16 : 10);

      // Código inválido ou substituto UTF-16 solto estouraria em
      // `fromCharCode`; nesse caso é melhor deixar o texto como estava.
      final invalid = code == null ||
          code <= 0 ||
          code > 0x10ffff ||
          (code >= 0xd800 && code <= 0xdfff);

      return invalid ? original : String.fromCharCode(code);
    }

    // Entidade desconhecida fica visível de propósito: some do texto seria
    // pior, porque ninguém descobriria que falta mapear.
    return _namedEntities[body.toLowerCase()] ?? original;
  });
}

/// Ajusta o espaçamento que o markup deixa para trás.
String _tidy(String value) {
  final lines = value.split('\n').map((line) {
    // O markup das tabelas vem com dezenas de espaços entre as tags. Sem
    // colapsar, a linha sai cheia de buracos.
    var cleaned = line.replaceAll(_horizontalSpace, ' ').trim();

    // A última célula da linha deixa um separador sobrando no fim.
    while (cleaned.endsWith('|')) {
      cleaned = cleaned.substring(0, cleaned.length - 1).trimRight();
    }

    return cleaned;
  });

  return lines.join('\n').replaceAll(_blankLines, '\n\n').trim();
}
