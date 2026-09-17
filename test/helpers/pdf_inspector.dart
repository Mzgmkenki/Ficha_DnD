import 'dart:convert';
import 'dart:typed_data';

/// Um texto desenhado no PDF, com onde ele foi desenhado.
class PdfTextRun {
  const PdfTextRun({
    required this.page,
    required this.text,
    required this.x,
    required this.y,
    required this.fontSize,
  });

  /// Página em que o texto saiu, começando em 1.
  final int page;

  final String text;

  /// Posição da linha de base, em pontos, com origem no canto inferior
  /// esquerdo da página (é como o PDF conta).
  final double x;
  final double y;

  /// Corpo da fonte, já com a escala da matriz de texto aplicada.
  final double fontSize;

  @override
  String toString() =>
      'p$page (${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)}) '
      '${fontSize.toStringAsFixed(1)}pt "$text"';
}

/// Um retângulo desenhado no PDF: caixa de valor, faixa de seção, filete.
class PdfRect {
  const PdfRect({
    required this.page,
    required this.left,
    required this.bottom,
    required this.width,
    required this.height,
  });

  final int page;
  final double left;
  final double bottom;
  final double width;
  final double height;

  double get right => left + width;
  double get top => bottom + height;

  @override
  String toString() => 'p$page rect(${left.toStringAsFixed(1)}, '
      '${bottom.toStringAsFixed(1)}, ${width.toStringAsFixed(1)} x '
      '${height.toStringAsFixed(1)})';
}

/// O que foi desenhado num PDF, por página.
///
/// Existe porque não há rasterizador de PDF nesta máquina (nem poppler, nem
/// ghostscript, nem imagemagick), e "olhar as páginas" precisava de alguma
/// forma de acontecer. Ler as coordenadas do fluxo de conteúdo responde as
/// perguntas que a inspeção visual responderia — texto fora da margem, fonte
/// pequena demais, caixa cortada na quebra de página — e responde de forma
/// repetível, que uma olhada não faz.
///
/// Só funciona com o documento gerado sem compressão
/// (`CharacterSheetPdf.build(data, compress: false)`).
class PdfInspection {
  const PdfInspection({
    required this.pageCount,
    required this.pageWidth,
    required this.pageHeight,
    required this.texts,
    required this.rects,
    required this.fieldNames,
  });

  final int pageCount;
  final double pageWidth;
  final double pageHeight;
  final List<PdfTextRun> texts;
  final List<PdfRect> rects;

  /// Nomes dos campos de formulário (AcroForm) encontrados no arquivo.
  final List<String> fieldNames;

  /// Todo o texto de uma página, na ordem em que foi desenhado.
  List<PdfTextRun> textsOnPage(int page) =>
      texts.where((run) => run.page == page).toList(growable: false);

  /// Todo o texto do documento, concatenado. Serve para procurar um trecho sem
  /// se importar com onde ele está.
  String get allText => texts.map((run) => run.text).join('\n');

  bool contains(String needle) =>
      allText.toLowerCase().contains(needle.toLowerCase());

  static PdfInspection parse(Uint8List bytes) {
    // Latin-1 e não UTF-8: o PDF escreve as strings de texto em WinAnsi, que
    // coincide com Latin-1 nos acentos do português. Decodificar como UTF-8
    // quebraria em "ç" e derrubaria a leitura do arquivo inteiro.
    final raw = latin1.decode(bytes, allowInvalid: true);

    final pageCount = _pageCount(raw);
    final mediaBox = _mediaBox(raw);
    final fieldNames = _fieldNames(raw);

    final texts = <PdfTextRun>[];
    final rects = <PdfRect>[];

    var page = 0;
    for (final stream in _contentStreams(raw)) {
      page++;
      _readContentStream(
        stream: stream,
        page: page,
        texts: texts,
        rects: rects,
      );
    }

    return PdfInspection(
      pageCount: pageCount == 0 ? page : pageCount,
      pageWidth: mediaBox.$1,
      pageHeight: mediaBox.$2,
      texts: texts,
      rects: rects,
      fieldNames: fieldNames,
    );
  }

  static int _pageCount(String raw) {
    // O objeto /Type /Pages carrega a contagem. Pode aparecer antes ou depois
    // do /Count, então procuramos os dois lados.
    final match = RegExp(r'/Type\s*/Pages[^>]*?/Count\s+(\d+)').firstMatch(raw) ??
        RegExp(r'/Count\s+(\d+)[^>]*?/Type\s*/Pages').firstMatch(raw);

    return match == null ? 0 : int.parse(match.group(1)!);
  }

  static (double, double) _mediaBox(String raw) {
    final match = RegExp(
      r'/MediaBox\s*\[\s*([\d.-]+)\s+([\d.-]+)\s+([\d.-]+)\s+([\d.-]+)\s*\]',
    ).firstMatch(raw);

    if (match == null) return (595.28, 841.89);

    return (
      double.parse(match.group(3)!) - double.parse(match.group(1)!),
      double.parse(match.group(4)!) - double.parse(match.group(2)!),
    );
  }

  static List<String> _fieldNames(String raw) {
    return RegExp(r'/T\s*\(([^)]*)\)')
        .allMatches(raw)
        .map((match) => match.group(1)!)
        .toList(growable: false);
  }

  /// Os fluxos de conteúdo, um por página, na ordem do arquivo.
  ///
  /// Reconhecidos por conterem um bloco de texto (`BT` ... `ET`): é o que
  /// separa a página do fluxo de uma fonte embutida ou de uma imagem, que são
  /// binários.
  static List<String> _contentStreams(String raw) {
    final result = <String>[];
    final pattern = RegExp(r'stream\r?\n');

    var index = 0;
    while (true) {
      final start = pattern.firstMatch(raw.substring(index));
      if (start == null) break;

      final bodyStart = index + start.end;
      final bodyEnd = raw.indexOf('endstream', bodyStart);
      if (bodyEnd < 0) break;

      final body = raw.substring(bodyStart, bodyEnd);
      index = bodyEnd + 'endstream'.length;

      if (body.contains('BT') && body.contains('ET')) result.add(body);
    }

    return result;
  }

  /// Percorre os operadores do fluxo, mantendo a pilha de estado gráfico.
  ///
  /// Só o necessário para responder "onde isso foi desenhado": `q`/`Q`/`cm`
  /// para a matriz corrente, `BT`/`Tf`/`Td`/`TD`/`Tm`/`T*` para o texto, e `re`
  /// para os retângulos. Curvas, sombreado e recorte não interessam aqui.
  static void _readContentStream({
    required String stream,
    required int page,
    required List<PdfTextRun> texts,
    required List<PdfRect> rects,
  }) {
    final tokens = _tokenize(stream);

    // Matriz corrente como (a, d, e, f): só escala e translação. O gerador não
    // rotaciona nem inclina nada nesta ficha, então guardar os seis valores
    // seria complexidade sem uso.
    var ctm = <double>[1, 1, 0, 0];
    final stack = <List<double>>[];

    var fontSize = 0.0;
    var textX = 0.0;
    var textY = 0.0;
    var lineX = 0.0;
    var lineY = 0.0;
    var leading = 0.0;

    final operands = <String>[];

    double number(int fromEnd) {
      final index = operands.length - fromEnd;
      if (index < 0 || index >= operands.length) return 0;
      return double.tryParse(operands[index]) ?? 0;
    }

    void emit(String text) {
      if (text.isEmpty) return;

      texts.add(
        PdfTextRun(
          page: page,
          text: text,
          x: textX * ctm[0] + ctm[2],
          y: textY * ctm[1] + ctm[3],
          fontSize: fontSize * ctm[1],
        ),
      );
    }

    for (final token in tokens) {
      switch (token) {
        case 'q':
          stack.add([...ctm]);
        case 'Q':
          if (stack.isNotEmpty) ctm = stack.removeLast();
        case 'cm':
          final a = number(6);
          final d = number(3);
          final e = number(2);
          final f = number(1);
          ctm = [
            ctm[0] * a,
            ctm[1] * d,
            ctm[0] * e + ctm[2],
            ctm[1] * f + ctm[3],
          ];
        case 'BT':
          textX = textY = lineX = lineY = 0;
        case 'Tf':
          fontSize = number(1);
        case 'TL':
          leading = number(1);
        case 'Td':
          lineX += number(2);
          lineY += number(1);
          textX = lineX;
          textY = lineY;
        case 'TD':
          leading = -number(1);
          lineX += number(2);
          lineY += number(1);
          textX = lineX;
          textY = lineY;
        case 'Tm':
          lineX = number(2);
          lineY = number(1);
          textX = lineX;
          textY = lineY;
        case 'T*':
          lineY -= leading;
          textX = lineX;
          textY = lineY;
        case 'Tj':
        case "'":
          if (token == "'") {
            lineY -= leading;
            textX = lineX;
            textY = lineY;
          }
          if (operands.isNotEmpty) emit(_unescape(operands.last));
        case 'TJ':
          // Array de strings e ajustes de kerning. Só as strings interessam.
          final buffer = StringBuffer();
          for (final operand in operands) {
            if (operand.startsWith('(')) buffer.write(_unescape(operand));
          }
          emit(buffer.toString());
        case 're':
          final width = number(2) * ctm[0];
          final height = number(1) * ctm[1];
          rects.add(
            PdfRect(
              page: page,
              left: number(4) * ctm[0] + ctm[2],
              bottom: number(3) * ctm[1] + ctm[3],
              width: width,
              height: height,
            ),
          );
        default:
          // Operando: acumula. Operador desconhecido: limpa, senão o operando
          // de um comando sobra para o próximo e desloca as posições.
          if (_isOperand(token)) {
            operands.add(token);
            continue;
          }
      }

      operands.clear();
    }
  }

  static bool _isOperand(String token) {
    if (token.isEmpty) return false;

    final first = token.codeUnitAt(0);
    // Número, string literal, nome (/F1) ou delimitador de array.
    return (first >= 0x30 && first <= 0x39) ||
        first == 0x2D || // -
        first == 0x2B || // +
        first == 0x2E || // .
        first == 0x28 || // (
        first == 0x2F || // /
        first == 0x5B || // [
        first == 0x5D; // ]
  }

  /// Quebra o fluxo em tokens, mantendo string literal inteira.
  static List<String> _tokenize(String stream) {
    final tokens = <String>[];
    final buffer = StringBuffer();

    var index = 0;
    while (index < stream.length) {
      final char = stream[index];

      if (char == '(') {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }

        // String literal do PDF: parênteses podem estar aninhados, e `\` escapa
        // o próximo caractere. Sem tratar os dois, um "(" dentro do texto
        // encerraria a string no lugar errado.
        final literal = StringBuffer('(');
        var depth = 1;
        index++;

        while (index < stream.length && depth > 0) {
          final inner = stream[index];

          if (inner == r'\') {
            literal.write(inner);
            if (index + 1 < stream.length) {
              literal.write(stream[index + 1]);
              index += 2;
              continue;
            }
            index++;
            continue;
          }

          if (inner == '(') depth++;
          if (inner == ')') {
            depth--;
            if (depth == 0) {
              index++;
              break;
            }
          }

          literal.write(inner);
          index++;
        }

        tokens.add(literal.toString());
        continue;
      }

      if (char == ' ' || char == '\n' || char == '\r' || char == '\t') {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        index++;
        continue;
      }

      if (char == '[' || char == ']') {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(char);
        index++;
        continue;
      }

      buffer.write(char);
      index++;
    }

    if (buffer.isNotEmpty) tokens.add(buffer.toString());

    return tokens;
  }

  /// Desfaz os escapes da string literal do PDF.
  static String _unescape(String literal) {
    var body = literal;
    if (body.startsWith('(')) body = body.substring(1);
    if (body.endsWith(')')) body = body.substring(0, body.length - 1);

    final result = StringBuffer();

    for (var i = 0; i < body.length; i++) {
      if (body[i] != r'\') {
        result.write(body[i]);
        continue;
      }

      if (i + 1 >= body.length) break;
      final next = body[i + 1];
      i++;

      switch (next) {
        case 'n':
          result.write('\n');
        case 'r':
          result.write('\r');
        case 't':
          result.write('\t');
        case 'b':
        case 'f':
          break;
        default:
          // Escape octal de três dígitos (\347 = ç em WinAnsi).
          if (next.codeUnitAt(0) >= 0x30 && next.codeUnitAt(0) <= 0x37) {
            final digits = StringBuffer(next);
            while (digits.length < 3 &&
                i + 1 < body.length &&
                body.codeUnitAt(i + 1) >= 0x30 &&
                body.codeUnitAt(i + 1) <= 0x37) {
              digits.write(body[i + 1]);
              i++;
            }
            result.writeCharCode(int.parse(digits.toString(), radix: 8));
          } else {
            result.write(next);
          }
      }
    }

    return result.toString();
  }
}
