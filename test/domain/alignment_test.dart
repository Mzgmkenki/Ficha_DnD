import 'package:dnd_ficha_app/features/character/domain/value_objects/alignment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

/// Guarda o modelo de alinhamento.
///
/// O ponto delicado: "não definido" é `null`, e não um décimo valor do enum nem
/// o neutro. Confundir os dois faria toda ficha antiga nascer neutra.
void main() {
  group('as nove combinações', () {
    test('existem exatamente nove', () {
      expect(CharacterAlignment.values.length, 9);
    });

    test('cada uma tem id, rótulo e descrição', () {
      for (final alignment in CharacterAlignment.values) {
        expect(alignment.id, isNotEmpty, reason: '${alignment.name} sem id');
        expect(alignment.label, isNotEmpty);
        expect(alignment.description, isNotEmpty);
      }
    });

    test('os ids são estáveis e únicos', () {
      final ids = CharacterAlignment.values.map((item) => item.id).toList();

      expect(ids.toSet().length, ids.length);
      expect(
        ids,
        containsAll(const [
          'lawful_good',
          'neutral_good',
          'chaotic_good',
          'lawful_neutral',
          'true_neutral',
          'chaotic_neutral',
          'lawful_evil',
          'neutral_evil',
          'chaotic_evil',
        ]),
      );
    });

    test('os rótulos cobrem as combinações tradicionais', () {
      expect(CharacterAlignment.lawfulGood.label, 'Leal e Bom');
      expect(CharacterAlignment.neutralGood.label, 'Neutro e Bom');
      expect(CharacterAlignment.chaoticGood.label, 'Caótico e Bom');
      expect(CharacterAlignment.lawfulNeutral.label, 'Leal e Neutro');
      expect(CharacterAlignment.chaoticNeutral.label, 'Caótico e Neutro');
      expect(CharacterAlignment.lawfulEvil.label, 'Leal e Mau');
      expect(CharacterAlignment.neutralEvil.label, 'Neutro e Mau');
      expect(CharacterAlignment.chaoticEvil.label, 'Caótico e Mau');
    });

    test('os dois eixos batem com o rótulo', () {
      expect(CharacterAlignment.lawfulGood.ethics, AlignmentEthics.lawful);
      expect(CharacterAlignment.lawfulGood.morals, AlignmentMorals.good);
      expect(CharacterAlignment.chaoticEvil.ethics, AlignmentEthics.chaotic);
      expect(CharacterAlignment.chaoticEvil.morals, AlignmentMorals.evil);
    });

    test('cada par de eixos aparece uma única vez', () {
      final pairs = CharacterAlignment.values
          .map((item) => '${item.ethics.id}/${item.morals.id}')
          .toList();

      expect(pairs.toSet().length, 9);
    });
  });

  group('neutro', () {
    test('neutro nos dois eixos se chama apenas Neutro', () {
      // Nem "Neutro e Neutro" nem "Neutro Verdadeiro": é o termo que a mesa usa.
      expect(CharacterAlignment.trueNeutral.label, 'Neutro');
      expect(CharacterAlignment.trueNeutral.ethics, AlignmentEthics.neutral);
      expect(CharacterAlignment.trueNeutral.morals, AlignmentMorals.neutral);
    });

    test('o id do neutro é true_neutral', () {
      expect(CharacterAlignment.trueNeutral.id, 'true_neutral');
      expect(
        CharacterAlignment.fromId('true_neutral'),
        CharacterAlignment.trueNeutral,
      );
    });
  });

  group('fromId', () {
    test('encontra todos os ids', () {
      for (final alignment in CharacterAlignment.values) {
        expect(CharacterAlignment.fromId(alignment.id), alignment);
      }
    });

    test('tolera espaço em volta', () {
      expect(
        CharacterAlignment.fromId('  lawful_evil  '),
        CharacterAlignment.lawfulEvil,
      );
    });

    test('id desconhecido, vazio ou nulo devolve nulo', () {
      // Nulo em vez de exceção: um id legado não pode travar a abertura da
      // ficha.
      expect(CharacterAlignment.fromId('inventado'), isNull);
      expect(CharacterAlignment.fromId(''), isNull);
      expect(CharacterAlignment.fromId('   '), isNull);
      expect(CharacterAlignment.fromId(null), isNull);
    });

    test('não confunde ausência com neutro', () {
      expect(
        CharacterAlignment.fromId(null),
        isNot(CharacterAlignment.trueNeutral),
      );
    });
  });

  group('personagem', () {
    test('nasce sem alinhamento definido', () {
      // É o estado do personagem criado antes do campo existir, e o padrão de
      // quem não escolheu.
      expect(characterFixture().alignment, isNull);
    });

    test('aceita cada uma das nove combinações', () {
      for (final alignment in CharacterAlignment.values) {
        final character = characterFixture().copyWith(alignment: alignment);
        expect(character.alignment, alignment);
      }
    });

    test('pode voltar para não definido', () {
      // Só funciona por causa da sentinela no copyWith: com `?? this.alignment`
      // passar null seria omissão, e limpar o campo seria impossível.
      final character = characterFixture()
          .copyWith(alignment: CharacterAlignment.lawfulGood);

      expect(character.copyWith(alignment: null).alignment, isNull);
    });

    test('copyWith sem informar alinhamento preserva o que havia', () {
      final character = characterFixture()
          .copyWith(alignment: CharacterAlignment.chaoticNeutral);

      expect(
        character.copyWith(name: 'Outro').alignment,
        CharacterAlignment.chaoticNeutral,
      );
    });
  });

  group('rótulo de exibição', () {
    test('ausência aparece como Não definido', () {
      expect(CharacterAlignment.labelOrUndefined(null), 'Não definido');
      expect(CharacterAlignment.undefinedLabel, 'Não definido');
    });

    test('presença aparece com o rótulo do alinhamento', () {
      expect(
        CharacterAlignment.labelOrUndefined(CharacterAlignment.neutralEvil),
        'Neutro e Mau',
      );
    });
  });
}
