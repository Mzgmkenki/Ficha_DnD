import 'package:dnd_ficha_app/core/utils/pt_collation.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ordenação alfabética em português.
///
/// O que estes testes protegem é o erro concreto que motivou a refatoração:
/// `String.compareTo` compara ponto de código, e `'á'` (225) é maior que
/// `'r'` (114). Com o `compareTo` cru, a lista de classes abria com "Bardo"
/// acima de "Bárbaro" — errado na primeira linha que o jogador lê.
void main() {
  group('comparePtBr', () {
    test('acento não muda a posição da letra base', () {
      // O caso real: as duas primeiras classes do compêndio.
      expect(comparePtBr('Bárbaro', 'Bardo'), isNegative);
      expect(comparePtBr('Bardo', 'Bárbaro'), isPositive);
    });

    test('compareTo cru erraria este mesmo par', () {
      // Fixa o motivo da função existir. Se algum dia alguém trocar
      // `comparePtBr` por `compareTo`, este teste explica o que se perdeu.
      expect('Bárbaro'.compareTo('Bardo'), isPositive);
    });

    test('caixa não decide a ordem', () {
      // Minúscula contra maiúscula: `'a'` é 97 e `'B'` é 66, então o
      // `compareTo` cru colocaria "Bardo" antes de "anão".
      expect(comparePtBr('anão', 'Bardo'), isNegative);
      expect('anão'.compareTo('Bardo'), isPositive);
    });

    test('espaço nas pontas não decide a ordem', () {
      // Espaço é 32 e vem antes de qualquer letra, então sem o `trim` a
      // entrada com espaço iria para o começo da lista.
      expect(comparePtBr('  Zelo', 'Anão'), isPositive);
      expect('  Zelo'.compareTo('Anão'), isNegative);
    });

    test('ç entra como c', () {
      // O par é escolhido para o ç ser o PRIMEIRO caractere que difere: em
      // "Caçador" contra "Cadeia" a comparação chega ao ç antes de qualquer
      // outra diferença. `'ç'` é 231 e `'d'` é 100, então o `compareTo` cru
      // inverte a dupla e põe "Cadeia" primeiro.
      expect(comparePtBr('Caçador', 'Cadeia'), isNegative);
      expect('Caçador'.compareTo('Cadeia'), isPositive);
      expect(foldPtAccents('Atuação'), 'Atuacao');
    });

    test('texto igual depois de dobrado nunca empata de verdade', () {
      // Devolver 0 aqui diria "são o mesmo item", e a ordem entre os dois
      // passaria a depender do algoritmo de ordenação. O desempate pelo texto
      // cru é o que torna a lista reproduzível.
      expect(comparePtBr('anão', 'ANÃO'), isNot(0));
      expect(comparePtBr('Atuação', 'Atuacao'), isNot(0));
      expect(comparePtBr('  Gnomo', 'Gnomo  '), isNot(0));
    });

    test('ordena a lista de raças do PHB como um leitor espera', () {
      final nomes = [
        'Tiefling',
        'Meio-Orc',
        'Anão',
        'Elfo',
        'Draconato',
        'Humano',
        'Halfling',
        'Gnomo',
        'Meio-Elfo',
      ]..sort(comparePtBr);

      expect(nomes, [
        'Anão',
        'Draconato',
        'Elfo',
        'Gnomo',
        'Halfling',
        'Humano',
        'Meio-Elfo',
        'Meio-Orc',
        'Tiefling',
      ]);
    });

    test('empate sem acento é resolvido, e sempre do mesmo jeito', () {
      // Sem o desempate pelo texto cru, "Ioun" e "Íoun" ficariam empatados e a
      // posição relativa mudaria conforme o algoritmo de ordenação.
      final um = comparePtBr('Ioun', 'Íoun');
      final outro = comparePtBr('Ioun', 'Íoun');

      expect(um, isNot(0));
      expect(um, outro);
    });
  });

  group('compareDisplayNames', () {
    test('nome decide primeiro', () {
      expect(
        compareDisplayNames(
          nameA: 'Anão',
          idA: 'z_dwarf',
          nameB: 'Elfo',
          idB: 'a_elf',
        ),
        isNegative,
      );
    });

    test('id desempata nome igual', () {
      // Dois conteúdos homônimos de fontes diferentes não podem trocar de
      // lugar entre reconstruções: a lista "dançaria" na tela.
      expect(
        compareDisplayNames(
          nameA: 'Arcano',
          idA: 'arcane_phb',
          nameB: 'Arcano',
          idB: 'arcane_tcoe',
        ),
        isNegative,
      );
    });
  });

  group('sortedByDisplayName', () {
    test('devolve cópia e não mexe na lista original', () {
      // A lista do compêndio é compartilhada entre telas. Reordená-la no lugar
      // mudaria a ordem para todo mundo, inclusive para quem depende da ordem
      // do arquivo.
      final original = ['Mago', 'Bárbaro', 'Clérigo'];

      final ordenada = sortedByDisplayName(
        original,
        name: (item) => item,
        id: (item) => item,
      );

      expect(ordenada, ['Bárbaro', 'Clérigo', 'Mago']);
      expect(original, ['Mago', 'Bárbaro', 'Clérigo']);
    });

    test('a cópia é imutável', () {
      final ordenada = sortedByDisplayName(
        ['b', 'a'],
        name: (item) => item,
        id: (item) => item,
      );

      expect(() => ordenada.sort(), throwsUnsupportedError);
    });
  });

  group('foldPtAccents', () {
    test('cobre as vogais acentuadas do português', () {
      expect(foldPtAccents('áàâãéêíóôõúüç'), 'aaaaeeiooouuc');
    });

    test('deixa o resto intacto', () {
      expect(foldPtAccents('Meio-Orc 42'), 'Meio-Orc 42');
    });
  });

  group('listas do domínio', () {
    test('perícias saem em ordem alfabética', () {
      final labels = Skill.sortedByLabel.map((item) => item.label).toList();

      expect(labels.first, 'Acrobacia');
      expect(labels.last, 'Sobrevivência');
      expect(labels, hasLength(Skill.values.length));
    });

    test('condições saem em ordem alfabética, e o enum não', () {
      final labels = Condition.sortedByLabel.map((item) => item.label).toList();

      expect(labels.first, 'Agarrado');
      expect(labels, hasLength(Condition.values.length));

      // A ordem de declaração continua diferente, e tem que continuar: é ela
      // que mantém estável o CSV gravado por `Condition.toCsv`.
      expect(
        Condition.values.map((item) => item.label).toList(),
        isNot(labels),
      );
    });

    test('a lista ordenada é a mesma instância entre chamadas', () {
      // Cache: o getter é lido dentro de `build`, e reordenar a cada quadro
      // seria trabalho jogado fora.
      expect(identical(Skill.sortedByLabel, Skill.sortedByLabel), isTrue);
      expect(
        identical(Condition.sortedByLabel, Condition.sortedByLabel),
        isTrue,
      );
    });
  });
}
