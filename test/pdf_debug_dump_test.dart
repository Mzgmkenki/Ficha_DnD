import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/data/pdf/character_sheet_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pdf_sample_data.dart';

void main() {
  test('dump', () async {
    final bytes = await CharacterSheetPdf.build(
      PdfSamples.simple(),
      compress: false,
    );

    final raw = latin1.decode(bytes, allowInvalid: true);
    final out = StringBuffer();

    final pattern = RegExp(r'stream\r?\n');
    var index = 0;
    var found = 0;

    while (true) {
      final start = pattern.firstMatch(raw.substring(index));
      if (start == null) break;

      final bodyStart = index + start.end;
      final bodyEnd = raw.indexOf('endstream', bodyStart);
      if (bodyEnd < 0) break;

      final body = raw.substring(bodyStart, bodyEnd);
      index = bodyEnd + 'endstream'.length;
      found++;

      final hasText = body.contains('BT') && body.contains('ET');
      out.writeln('--- stream $found len=${body.length} hasText=$hasText');
      if (hasText) {
        out.writeln(body.substring(0, body.length > 3000 ? 3000 : body.length));
      }
    }

    out.writeln('=== total streams: $found');
    File('C:/app/Ficha_DnD/.dart_tool/pdf-dump.txt').writeAsStringSync(
      out.toString(),
    );
  });
}
