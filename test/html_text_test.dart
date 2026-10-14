import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/core/utils/html_text.dart';
import 'package:dnd_ficha_app/features/compendium/data/spell_assets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda a limpeza do HTML que vem embutido nos assets de magia.
///
/// O caso que motivou o teste: o painel de magias da ficha mostrava
/// `...quando a magia termina.<br>&emsp;A criatura é uma aliada...` na descrição
/// de Invocar Besta. O markup estava no asset e a tela renderiza com `Text`,
/// que não interpreta HTML.
void main() {
  const spellFiles = spellAssetPaths;

  group('htmlToPlainText', () {
    test('texto sem markup passa intacto', () {
      const raw =
          'Você invoca um espírito bestial. Escolha: Ar, Terra ou Água.';
      expect(htmlToPlainText(raw), raw);
    });

    test('<br> vira quebra de linha e &emsp; não sobra como recuo', () {
      expect(
        htmlToPlainText('Fim do parágrafo.<br>&emsp;Começo do outro.'),
        'Fim do parágrafo.\nComeço do outro.',
      );
    });

    test('aceita as variações de <br>', () {
      expect(htmlToPlainText('a<br>b<br/>c<br />d<BR>e'), 'a\nb\nc\nd\ne');
    });

    test('tag que só formata desaparece sem comer o texto', () {
      expect(
        htmlToPlainText('O <b>alvo</b> faz um teste de <i>Destreza</i>.'),
        'O alvo faz um teste de Destreza.',
      );
      expect(htmlToPlainText('<div>Bloco solto</div>'), 'Bloco solto');
    });

    test('lista vira uma linha por item, com marcador', () {
      expect(
        htmlToPlainText(
          'Escolha uma opção:<ul><li>Expandir a chama.</li>'
          '<li>Extinguir a chama.</li></ul>',
        ),
        'Escolha uma opção:\n• Expandir a chama.\n• Extinguir a chama.',
      );
    });

    test('tabela vira linhas com células separadas por barra', () {
      const raw =
          '<table class="big">     <tr>         <th>d6</th>         '
          '<th>Demônios Invocados</th>     </tr>     <tr>         '
          '<td class="centernumber" style="width: 15%;">1-2</td>         '
          '<td>Dois demônios de desafio 1 ou menor</td>     </tr> </table>';

      expect(
        htmlToPlainText(raw),
        'd6 | Demônios Invocados\n1-2 | Dois demônios de desafio 1 ou menor',
      );
    });

    test('espaço entre tags não deixa buraco na linha', () {
      expect(htmlToPlainText('um    <b>dois</b>     três'), 'um dois três');
    });

    test('não acumula linhas em branco', () {
      expect(htmlToPlainText('a<br><br><br><br>b'), 'a\n\nb');
    });

    test('decodifica entidade nomeada e numérica', () {
      expect(htmlToPlainText('mais &amp; menos'), 'mais & menos');
      expect(htmlToPlainText('3 &times; 1d6'), '3 × 1d6');
      expect(htmlToPlainText('&#65;&#x42;'), 'AB');
    });

    test('entidade desconhecida fica visível em vez de sumir', () {
      // Sumir seria pior: ninguém descobriria que falta mapear.
      expect(
        htmlToPlainText('valor &naoexiste; aqui'),
        'valor &naoexiste; aqui',
      );
    });

    test('código numérico inválido não estoura', () {
      expect(htmlToPlainText('&#0;'), '&#0;');
      expect(htmlToPlainText('&#xD800;'), '&#xD800;');
      expect(htmlToPlainText('&#99999999;'), '&#99999999;');
    });

    test('string vazia continua vazia', () {
      expect(htmlToPlainText(''), '');
    });

    test('htmlToPlainTextOrNull repassa nulo', () {
      // `upcast` é opcional: virar string vazia mudaria quem checa `!= null`
      // antes de mostrar a seção "Em círculos superiores".
      expect(htmlToPlainTextOrNull(null), isNull);
      expect(htmlToPlainTextOrNull('a<br>b'), 'a\nb');
    });
  });

  group('assets de magia', () {
    late List<Map<String, dynamic>> spells;

    setUpAll(() {
      final loaded = <Map<String, dynamic>>[];

      for (final path in spellFiles) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'asset ausente: $path');

        final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        for (final item in raw['dados'] as List<dynamic>) {
          loaded.add(Map<String, dynamic>.from(item as Map));
        }
      }

      spells = loaded;
    });

    test('o caso de Invocar Besta sai limpo e com o parágrafo separado', () {
      final spell = spells.firstWhere(
        (item) => item['nome'] == 'Invocar Besta',
      );
      final description = htmlToPlainText(spell['descricao'] as String);

      expect(
        description,
        contains('quando a magia termina.\nA criatura é uma aliada'),
      );
      expect(description, isNot(contains('<br>')));
      expect(description, isNot(contains('&emsp;')));
    });

    test('nenhum campo de texto sobra com tag ou entidade', () {
      // Vale para todas as magias: uma tag nova em qualquer arquivo derruba o
      // teste em vez de aparecer literal na ficha.
      const textFields = [
        'nome',
        'original',
        'escola',
        'tempo',
        'alcance',
        'componentes',
        'duracao',
        'descricao',
        'upcast',
      ];

      final leftovers = <String>[];

      for (final spell in spells) {
        for (final field in textFields) {
          final raw = spell[field];
          if (raw is! String) continue;

          final clean = htmlToPlainText(raw);
          if (RegExp(r'<[^>]+>').hasMatch(clean) ||
              RegExp(r'&[a-zA-Z]+;').hasMatch(clean)) {
            leftovers.add('${spell['nome']} / $field');
          }
        }
      }

      expect(leftovers, isEmpty, reason: 'markup não tratado em: $leftovers');
    });

    test('a limpeza não engole o texto das magias', () {
      // Uma expressão gulosa demais poderia zerar descrições inteiras.
      for (final spell in spells) {
        final raw = spell['descricao'] as String? ?? '';
        if (raw.trim().isEmpty) continue;

        expect(
          htmlToPlainText(raw).trim(),
          isNotEmpty,
          reason: '${spell['nome']} ficou sem descrição depois da limpeza',
        );
      }
    });
  });
}
