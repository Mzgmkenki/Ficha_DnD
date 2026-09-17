import 'package:dnd_ficha_app/features/character/data/pdf/character_sheet_pdf.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pdf_inspector.dart';
import 'helpers/pdf_sample_data.dart';

/// O que a ficha exportada precisa dizer — e o que ela não deve dizer.
///
/// Lê o texto de volta do PDF em vez de conferir só que o arquivo saiu: um
/// template pode gerar bytes válidos e mesmo assim ter perdido uma seção.
void main() {
  Future<PdfInspection> inspect(String sample) async {
    final bytes = await CharacterSheetPdf.build(
      PdfSamples.byName(sample),
      compress: false,
    );

    return PdfInspection.parse(bytes);
  }

  group('seção de condições', () {
    test('existe com todas as condições do PHB 2014', () async {
      final pdf = await inspect('simples');

      expect(pdf.contains('CONDIÇÕES'), isTrue);

      // Todas as catorze, marcáveis, não só as ativas: a ficha impressa serve
      // para o jogador marcar durante a partida.
      for (final condition in Condition.values) {
        expect(
          pdf.contains(condition.label),
          isTrue,
          reason: 'condição ausente na ficha: ${condition.label}',
        );
      }
    });

    test('tem caixa de marcação para cada condição', () async {
      final pdf = await inspect('simples');

      for (final condition in Condition.values) {
        expect(
          pdf.fieldNames,
          contains('condition_${condition.id}'),
          reason: 'sem caixa de marcação para ${condition.label}',
        );
      }
    });

    test('traz exaustão em degraus e espaço para observação', () async {
      final pdf = await inspect('simples');

      expect(pdf.contains('EXAUSTÃO'), isTrue);
      expect(pdf.contains('Outras condições e observações'), isTrue);

      for (var step = 1; step <= 6; step++) {
        expect(pdf.fieldNames, contains('exhaustion_$step'));
      }
    });

    test('marca o que está ativo e explica o efeito', () async {
      final pdf = await inspect('textos-longos');

      expect(pdf.contains('Paralisado'), isTrue);
      expect(pdf.contains('Efeitos ativos ao exportar'), isTrue);
      // Incapacitado não foi marcado pelo jogador: entra por Paralisado.
      expect(pdf.contains('Incapacitado (por Paralisado)'), isTrue);
    });

    test('sem formulário, as caixas continuam desenhadas', () async {
      final data = PdfSamples.simple();
      final printOnly = CharacterSheetPdfData(
        character: data.character,
        classes: data.classes,
        weapons: data.weapons,
        iconBytes: data.iconBytes,
        interactiveForms: false,
      );

      final bytes = await CharacterSheetPdf.build(printOnly, compress: false);
      final pdf = PdfInspection.parse(bytes);

      // Sem campo de formulário nenhum, mas os nomes das condições continuam lá
      // com a caixa desenhada ao lado.
      expect(pdf.fieldNames, isEmpty);
      expect(pdf.contains('Paralisado'), isTrue);
      expect(pdf.contains('CONDIÇÕES'), isTrue);
    });
  });

  group('ações em combate', () {
    test('não aparecem no PDF', () async {
      // A seção continua no app; no PDF ela ocuparia páginas com o que muda a
      // cada turno, sem ajudar quem já tem a ficha na mão.
      for (final sample in PdfSamples.names) {
        final pdf = await inspect(sample);

        expect(pdf.contains('Ações em combate'), isFalse);
        expect(pdf.contains('ação bônus'), isFalse);
        expect(pdf.contains('Possibilidades para este turno'), isFalse);
        expect(pdf.contains('opções do turno'), isFalse);
        expect(pdf.contains('economia de ações'), isFalse);
      }
    });
  });

  group('ataques e armas', () {
    test('imprime a arma, o ataque e o dano', () async {
      final pdf = await inspect('armas-e-itens');

      expect(pdf.contains('ATAQUES E ARMAS'), isTrue);
      expect(pdf.contains('Machado da Alvorada'), isTrue);
      expect(pdf.contains('Arco Longo'), isTrue);
      expect(pdf.contains('Rapieira'), isTrue);
      // Dado, bônus e tipo de dano na mesma linha.
      expect(pdf.contains('de dano cortante'), isTrue);
      expect(pdf.contains('de dano perfurante'), isTrue);
    });

    test('mostra o bônus mágico da arma', () async {
      final pdf = await inspect('armas-e-itens');
      expect(pdf.contains('mágica +1'), isTrue);
    });

    test('avisa quando a arma não está no compêndio', () async {
      final pdf = await inspect('armas-e-itens');

      // Nada desaparece em silêncio: a linha não sai na tabela, mas a ficha diz.
      expect(pdf.contains('Sem dados no compêndio'), isTrue);
      expect(pdf.contains('arma_inventada'), isTrue);
    });

    test('explica de onde saiu o bônus de ataque', () async {
      final pdf = await inspect('armas-e-itens');
      expect(pdf.contains('do atributo'), isTrue);
      expect(pdf.contains('de proficiência'), isTrue);
    });
  });

  group('itens mágicos', () {
    test('imprime bônus, estatísticas afetadas e estado', () async {
      final pdf = await inspect('armas-e-itens');

      expect(pdf.contains('Machado da Alvorada'), isTrue);
      expect(pdf.contains('+1 no ataque com arma'), isTrue);
      expect(pdf.contains('+1 no dano com arma'), isTrue);
      expect(pdf.contains('equipado'), isTrue);
    });

    test('item de foco mágico afeta só conjuração', () async {
      final pdf = await inspect('armas-e-itens');

      expect(pdf.contains('+2 no ataque mágico'), isTrue);
      expect(pdf.contains('+2 na CD das magias'), isTrue);
      expect(pdf.contains('sintonizado'), isTrue);
    });

    test('item sem sintonia avisa que não está somando', () async {
      final pdf = await inspect('armas-e-itens');

      expect(pdf.contains('Bracelete Adormecido'), isTrue);
      expect(pdf.contains('sem sintonia'), isTrue);
      expect(pdf.contains('não está somando'), isTrue);
      expect(pdf.contains('exige sintonia'), isTrue);
    });

    test('item guardado avisa que não está somando', () async {
      final pdf = await inspect('armas-e-itens');

      expect(pdf.contains('Escudo de Reserva'), isTrue);
      expect(pdf.contains('guardado'), isTrue);
      expect(pdf.contains('não equipado'), isTrue);
    });

    test('CD fixa do item sai separada do bônus', () async {
      final pdf = await inspect('armas-e-itens');

      expect(pdf.contains('Varinha de Bolas de Fogo'), isTrue);
      expect(pdf.contains('CD fixa do item: 15'), isTrue);
      expect(pdf.contains('cargas 5/7'), isTrue);
    });

    test('item para revisão é avisado em vez de arredondado', () async {
      final pdf = await inspect('armas-e-itens');

      expect(pdf.contains('Adaga Rachada'), isTrue);
      expect(pdf.contains('-1 no ataque com arma'), isTrue);
      expect(pdf.contains('Revise o item no app'), isTrue);
    });

    test('arma mágica não vira bônus de CD na ficha impressa', () async {
      final pdf = await inspect('armas-e-itens');

      // O Machado é +1 em arma. Se vazasse para conjuração, apareceria como
      // bônus de CD — e este personagem não conjura, então não há CD nenhuma.
      expect(pdf.contains('+1 na CD das magias'), isFalse);
      expect(pdf.contains('Nenhuma classe conjuradora'), isTrue);
    });
  });

  group('conjuração', () {
    test('imprime atributo, CD e ataque mágico em caixas', () async {
      final pdf = await inspect('conjurador');

      expect(pdf.contains('ATRIBUTO DE CONJURAÇÃO'), isTrue);
      expect(pdf.contains('CD DAS MAGIAS'), isTrue);
      expect(pdf.contains('ATAQUE MÁGICO'), isTrue);
      expect(pdf.contains('ESPAÇOS DE MAGIA'), isTrue);
    });

    test('marca concentração, ritual e preparação', () async {
      final pdf = await inspect('conjurador');

      expect(pdf.contains('concentração'), isTrue);
      expect(pdf.contains('ritual'), isTrue);
      expect(pdf.contains('preparada'), isTrue);
    });
  });

  group('iniciativa', () {
    test('a caixa mostra o total final', () async {
      final pdf = await inspect('armas-e-itens');

      // Destreza 16 (+3) mais ajuste manual +2.
      expect(pdf.contains('INICIATIVA'), isTrue);
      expect(pdf.contains('+5'), isTrue);
    });

    test('a composição aparece como observação', () async {
      final pdf = await inspect('armas-e-itens');

      expect(pdf.contains('Iniciativa: +5'), isTrue);
      expect(pdf.contains('de Destreza'), isTrue);
      expect(pdf.contains('de ajuste manual'), isTrue);
    });
  });

  group('seções obrigatórias', () {
    test('a ficha simples traz todas as seções', () async {
      final pdf = await inspect('simples');

      for (final title in const [
        'COMBATE',
        'ATRIBUTOS E SALVAGUARDAS',
        'PERÍCIAS',
        'ATAQUES E ARMAS',
        'CONJURAÇÃO',
        'MAGIAS',
        'CARACTERÍSTICAS E PROFICIÊNCIAS',
        'EQUIPAMENTO',
        'CONDIÇÕES',
        'ANOTAÇÕES',
      ]) {
        expect(
          pdf.contains(title),
          isTrue,
          reason: 'seção ausente: $title',
        );
      }
    });

    test('seção vazia diz que está vazia, em vez de sumir', () async {
      final pdf = await inspect('simples');

      expect(pdf.contains('Nenhuma arma cadastrada'), isTrue);
      expect(pdf.contains('Nenhuma classe conjuradora'), isTrue);
      expect(pdf.contains('Nenhuma magia vinculada'), isTrue);
      expect(pdf.contains('Nenhum item mágico'), isTrue);
      expect(pdf.contains('Sem anotações'), isTrue);
    });

    test('imprime proficiências, talentos e idiomas', () async {
      final pdf = await inspect('textos-longos');

      expect(pdf.contains('Proficiências'), isTrue);
      expect(pdf.contains('Salvaguardas'), isTrue);
      expect(pdf.contains('Talentos'), isTrue);
      expect(pdf.contains('Alerta (Sabedoria)'), isTrue);
      expect(pdf.contains('Idiomas'), isTrue);
      expect(pdf.contains('Élfico'), isTrue);
    });

    test('imprime moedas em caixas', () async {
      final pdf = await inspect('armas-e-itens');

      expect(pdf.contains('Moedas'), isTrue);
      expect(pdf.contains('TOTAL EM OURO'), isTrue);
    });
  });
}
