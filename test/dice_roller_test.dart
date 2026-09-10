import 'dart:math';

import 'package:dnd_ficha_app/core/utils/dice_roller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Random previsível: entrega os valores da fila, em ordem.
///
/// `nextInt` recebe o número de faces e o roller soma 1, então a fila guarda
/// o resultado desejado menos 1.
class _ScriptedRandom implements Random {
  _ScriptedRandom(this.results);

  final List<int> results;
  int _index = 0;

  @override
  int nextInt(int max) {
    final value = results[_index % results.length];
    _index++;
    return value - 1;
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

DiceRoller _rollerOf(List<int> results) =>
    DiceRoller(random: _ScriptedRandom(results));

void main() {
  group('rollDie', () {
    test('devolve o valor do dado', () {
      expect(_rollerOf([13]).rollDie(20), 13);
      expect(_rollerOf([6]).rollDie(6), 6);
    });

    test('recusa dado com menos de 2 faces', () {
      final roller = _rollerOf([1]);
      expect(() => roller.rollDie(1), throwsArgumentError);
      expect(() => roller.rollDie(0), throwsArgumentError);
    });

    test('respeita os limites do dado ao longo de muitas rolagens', () {
      final roller = DiceRoller();
      for (var i = 0; i < 500; i++) {
        final value = roller.rollDie(20);
        expect(value, inInclusiveRange(1, 20));
      }
    });
  });

  group('rollD20 normal', () {
    test('rola um único dado e soma o modificador', () {
      final result = _rollerOf([13]).rollD20(modifier: 5, label: 'Furtividade');

      expect(result.rolls, [13]);
      expect(result.keptValue, 13);
      expect(result.total, 18);
      expect(result.label, 'Furtividade');
      expect(result.mode, RollMode.normal);
      expect(result.formula, '1d20 +5');
      expect(result.detail, '13 +5');
    });

    test('modificador negativo aparece com sinal', () {
      final result = _rollerOf([10]).rollD20(modifier: -2);

      expect(result.total, 8);
      expect(result.formula, '1d20 -2');
      expect(result.detail, '10 -2');
    });

    test('sem modificador não polui a fórmula', () {
      final result = _rollerOf([7]).rollD20();

      expect(result.total, 7);
      expect(result.formula, '1d20');
      expect(result.detail, '7');
    });
  });

  group('vantagem e desvantagem', () {
    test('vantagem rola dois dados e mantém o maior', () {
      final result = _rollerOf([8, 17]).rollD20(
        modifier: 3,
        mode: RollMode.advantage,
      );

      expect(result.rolls, [8, 17]);
      expect(result.keptValue, 17);
      expect(result.total, 20);
      expect(result.formula, '2d20 (maior) +3');
      expect(result.detail, '8, 17 → 17 +3');
    });

    test('desvantagem rola dois dados e mantém o menor', () {
      final result = _rollerOf([8, 17]).rollD20(
        modifier: 3,
        mode: RollMode.disadvantage,
      );

      expect(result.rolls, [8, 17]);
      expect(result.keptValue, 8);
      expect(result.total, 11);
      expect(result.formula, '2d20 (menor) +3');
    });

    test('dados iguais não confundem o que foi mantido', () {
      final result =
          _rollerOf([12, 12]).rollD20(mode: RollMode.advantage);

      expect(result.keptValue, 12);
      expect(result.total, 12);
    });
  });

  group('naturais', () {
    test('20 no dado é natural, mesmo com modificador', () {
      final result = _rollerOf([20]).rollD20(modifier: -4);

      expect(result.isNaturalTwenty, isTrue);
      expect(result.isNaturalOne, isFalse);
      expect(result.total, 16);
    });

    test('1 no dado é natural', () {
      final result = _rollerOf([1]).rollD20(modifier: 9);

      expect(result.isNaturalOne, isTrue);
      expect(result.isNaturalTwenty, isFalse);
    });

    test('total 20 por causa do modificador não é natural', () {
      final result = _rollerOf([15]).rollD20(modifier: 5);

      expect(result.total, 20);
      expect(result.isNaturalTwenty, isFalse);
    });

    test('com vantagem, vale o dado mantido', () {
      // O 20 é descartado pela desvantagem: não é 20 natural.
      final result =
          _rollerOf([20, 3]).rollD20(mode: RollMode.disadvantage);

      expect(result.keptValue, 3);
      expect(result.isNaturalTwenty, isFalse);
    });

    test('natural só existe no d20', () {
      final result = _rollerOf([6]).roll(amount: 1, sides: 6);

      expect(result.keptValue, 6);
      expect(result.isNaturalTwenty, isFalse);
      expect(result.isNaturalOne, isFalse);
    });
  });

  group('roll de vários dados', () {
    test('soma os dados e o modificador', () {
      final result = _rollerOf([3, 5, 2]).roll(
        amount: 3,
        sides: 6,
        modifier: 1,
        label: 'Dano',
      );

      expect(result.rolls, [3, 5, 2]);
      expect(result.keptValue, 10);
      expect(result.total, 11);
      expect(result.formula, '3d6 +1');
      expect(result.detail, '3, 5, 2 → 10 +1');
      expect(result.label, 'Dano');
    });

    test('recusa quantidade menor que 1', () {
      final roller = _rollerOf([1]);
      expect(
        () => roller.roll(amount: 0, sides: 6),
        throwsArgumentError,
      );
    });
  });
}
