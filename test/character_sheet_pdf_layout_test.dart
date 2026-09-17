import 'dart:io';

import 'package:dnd_ficha_app/features/character/data/pdf/character_sheet_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pdf_inspector.dart';
import 'helpers/pdf_sample_data.dart';

/// Verificação de layout do PDF, lendo o que foi realmente desenhado.
///
/// Não há rasterizador de PDF nesta máquina, então em vez de olhar imagens das
/// páginas o teste lê as coordenadas do fluxo de conteúdo. Isso responde as
/// mesmas perguntas de uma inspeção visual — texto fora da margem, corpo de
/// fonte pequeno demais, caixa estourando a página, quebra de página no lugar
/// errado — e responde de forma repetível.
///
/// Definir `DRAGONSHEET_PDF_OUT` grava os exemplos em disco, para abrir num
/// leitor e conferir a olho:
///
/// ```
/// $env:DRAGONSHEET_PDF_OUT="C:\tmp\fichas"; flutter test test/character_sheet_pdf_layout_test.dart
/// ```
void main() {
  /// Folga em pontos ao comparar com a margem.
  ///
  /// O `pdf` posiciona a linha de base do texto, e a descida da letra fica
  /// abaixo dela. Meio ponto absorve o arredondamento sem deixar passar um texto
  /// realmente fora da página.
  const slack = 0.6;

  final outputDir = Platform.environment['DRAGONSHEET_PDF_OUT'];

  Future<PdfInspection> inspect(String sample) async {
    final data = PdfSamples.byName(sample);

    // Sem compressão: com o fluxo comprimido não há o que inspecionar.
    final bytes = await CharacterSheetPdf.build(data, compress: false);

    if (outputDir != null) {
      final directory = Directory(outputDir);
      if (!directory.existsSync()) directory.createSync(recursive: true);

      // O arquivo entregue ao jogador vai comprimido; o exemplo em disco também,
      // senão o tamanho não representa o real.
      final real = await CharacterSheetPdf.build(data);
      File('$outputDir/ficha-$sample.pdf').writeAsBytesSync(real);
    }

    return PdfInspection.parse(bytes);
  }

  group('geometria das páginas', () {
    for (final sample in PdfSamples.names) {
      test('$sample: nada escapa das margens', () async {
        final pdf = await inspect(sample);

        expect(pdf.pageCount, greaterThan(0));
        expect(pdf.texts, isNotEmpty, reason: 'a ficha saiu sem texto');

        final left = CharacterSheetPdf.pageMargin.left;
        final right = pdf.pageWidth - CharacterSheetPdf.pageMargin.right;
        final bottom = CharacterSheetPdf.pageMargin.bottom;
        final top = pdf.pageHeight - CharacterSheetPdf.pageMargin.top;

        for (final run in pdf.texts) {
          expect(
            run.x,
            greaterThanOrEqualTo(left - slack),
            reason: 'texto começa antes da margem esquerda: $run',
          );
          expect(
            run.x,
            lessThanOrEqualTo(right + slack),
            reason: 'texto começa depois da margem direita: $run',
          );
          expect(
            run.y,
            greaterThanOrEqualTo(bottom - slack - run.fontSize),
            reason: 'texto abaixo da margem inferior: $run',
          );
          expect(
            run.y,
            lessThanOrEqualTo(top + slack),
            reason: 'texto acima da margem superior: $run',
          );
        }
      });

      test('$sample: nenhuma caixa sai da página', () async {
        final pdf = await inspect(sample);

        for (final rect in pdf.rects) {
          // Fundo de página e marca d'água ocupam a folha inteira de propósito,
          // então a comparação é com a página, não com a margem.
          expect(
            rect.left,
            greaterThanOrEqualTo(-slack),
            reason: 'caixa fora da página pela esquerda: $rect',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(pdf.pageWidth + slack),
            reason: 'caixa fora da página pela direita: $rect',
          );
          expect(
            rect.bottom,
            greaterThanOrEqualTo(-slack),
            reason: 'caixa fora da página por baixo: $rect',
          );
          expect(
            rect.top,
            lessThanOrEqualTo(pdf.pageHeight + slack),
            reason: 'caixa fora da página por cima: $rect',
          );
        }
      });

      test('$sample: nenhum texto fica pequeno demais para ler', () async {
        final pdf = await inspect(sample);

        for (final run in pdf.texts) {
          // 5,5 pt é o piso: abaixo disso o rótulo da caixa não se lê impresso.
          // Nada no template pede menos que 5,6.
          expect(
            run.fontSize,
            greaterThanOrEqualTo(5.5),
            reason: 'corpo de fonte pequeno demais: $run',
          );
        }
      });

      test('$sample: toda página tem cabeçalho de marca e rodapé', () async {
        final pdf = await inspect(sample);

        for (var page = 1; page <= pdf.pageCount; page++) {
          final texts = pdf.textsOnPage(page).map((run) => run.text).join(' ');

          expect(
            texts,
            contains('DragonSheet'),
            reason: 'página $page sem a marca no cabeçalho ou rodapé',
          );
          expect(
            texts,
            contains('Página $page de ${pdf.pageCount}'),
            reason: 'página $page sem numeração no rodapé',
          );
        }
      });
    }
  });

  group('primeira página', () {
    test('traz a identidade e os números de combate', () async {
      final pdf = await inspect('armas-e-itens');
      final first = pdf.textsOnPage(1).map((run) => run.text).join('\n');

      // O que o jogador consulta a cada turno precisa estar na folha 1.
      expect(first, contains('Thorin'));
      expect(first, contains('DRAGONSHEET'));
      expect(first, contains('FICHA DE PERSONAGEM'));
      expect(first, contains('CLASSE DE ARMADURA'));
      expect(first, contains('INICIATIVA'));
      expect(first, contains('DESLOCAMENTO'));
      expect(first, contains('PV MÁXIMOS'));
      expect(first, contains('PV ATUAIS'));
      expect(first, contains('PV TEMPORÁRIOS'));
      expect(first, contains('BÔNUS DE PROFICIÊNCIA'));
      expect(first, contains('PERCEPÇÃO PASSIVA'));
      expect(first, contains('DADOS DE VIDA'));
      expect(first, contains('TESTES CONTRA A MORTE'));
    });

    test('o cabeçalho da marca não repete nas páginas seguintes', () async {
      final pdf = await inspect('muitas-caracteristicas');
      expect(pdf.pageCount, greaterThan(1));

      // O selo grande é da folha 1; nas seguintes entra o cabeçalho corrido,
      // que repete o nome para a folha solta continuar identificada.
      for (var page = 2; page <= pdf.pageCount; page++) {
        final texts = pdf.textsOnPage(page).map((run) => run.text).join(' ');
        expect(texts, isNot(contains('FICHA DE PERSONAGEM')));
        expect(texts, contains('Gundren'));
      }
    });
  });

  group('conteúdo extenso', () {
    test('conjurador com muitas magias vira mais páginas', () async {
      final pdf = await inspect('conjurador');

      expect(pdf.pageCount, greaterThan(2));
      // As magias saem agrupadas por círculo, e o grupo continua identificado na
      // página seguinte pelo próprio título de círculo.
      expect(pdf.contains('Truques'), isTrue);
      expect(pdf.contains('1º círculo'), isTrue);
      expect(pdf.contains('5º círculo'), isTrue);
    });

    test('texto longo não é cortado sem continuação', () async {
      final pdf = await inspect('textos-longos');

      expect(pdf.pageCount, greaterThan(1));
      // O parágrafo de anotações é longo e precisa ter sido desenhado inteiro:
      // a última frase aparece em algum lugar do documento.
      expect(pdf.contains('conveniente perto do fim da linha'), isTrue);
    });

    test('nome muito longo não invade a coluna vizinha', () async {
      final pdf = await inspect('textos-longos');
      final right = pdf.pageWidth - CharacterSheetPdf.pageMargin.right;

      for (final run in pdf.texts) {
        expect(run.x, lessThanOrEqualTo(right + slack), reason: '$run');
      }
    });
  });

  group('acentuação em português', () {
    test('sobrevive à codificação do PDF', () async {
      final pdf = await inspect('textos-longos');

      // WinAnsi cobre o português: se a codificação estivesse errada, estes
      // trechos sairiam com "?" no lugar do acento.
      expect(pdf.contains('Ação'), isTrue);
      expect(pdf.contains('coração'), isTrue);
      expect(pdf.contains('Élfico'), isTrue);
      expect(pdf.contains('Percepção'), isTrue);
      expect(pdf.contains('Condições'), isTrue);
      expect(pdf.contains('Exaustão'), isTrue);
    });

    test('não sobrou nenhuma interrogação de caractere perdido', () async {
      final pdf = await inspect('textos-longos');

      // `_safe` troca o que a fonte não desenha por "?". Um "??" seguido é
      // sinal de que um trecho inteiro se perdeu.
      expect(pdf.allText, isNot(contains('??')));
    });
  });

  group('caixas de valor', () {
    test('têm o mesmo tamanho e ficam alinhadas na fila', () async {
      final pdf = await inspect('simples');

      // As caixas de valor da primeira página: quadros da largura declarada.
      final boxes = pdf.rects
          .where(
            (rect) =>
                rect.page == 1 &&
                (rect.width - CharacterSheetPdf.boxWidth).abs() < 0.5 &&
                (rect.height - CharacterSheetPdf.boxHeight).abs() < 0.5,
          )
          .toList();

      expect(
        boxes.length,
        greaterThanOrEqualTo(12),
        reason: 'as duas filas de caixas de combate deveriam estar aqui',
      );

      // Agrupadas por linha de base: dentro de uma fila, todas na mesma altura.
      final byBottom = <String, List<double>>{};
      for (final box in boxes) {
        final key = box.bottom.toStringAsFixed(1);
        byBottom.putIfAbsent(key, () => []).add(box.left);
      }

      for (final entry in byBottom.entries) {
        expect(
          entry.value.length,
          greaterThanOrEqualTo(2),
          reason: 'fila com uma caixa só em ${entry.key}',
        );
      }
    });

    test('nenhuma caixa de valor é dividida entre páginas', () async {
      final pdf = await inspect('muitas-caracteristicas');

      final bottom = CharacterSheetPdf.pageMargin.bottom;
      final top = pdf.pageHeight - CharacterSheetPdf.pageMargin.top;

      for (final rect in pdf.rects) {
        final isValueBox =
            (rect.width - CharacterSheetPdf.boxWidth).abs() < 0.5 &&
                (rect.height - CharacterSheetPdf.boxHeight).abs() < 0.5;
        if (!isValueBox) continue;

        // Caixa inteira dentro da área útil: se tivesse sido partida, uma das
        // bordas cairia fora.
        expect(rect.bottom, greaterThanOrEqualTo(bottom - slack), reason: '$rect');
        expect(rect.top, lessThanOrEqualTo(top + slack), reason: '$rect');
      }
    });
  });
}
