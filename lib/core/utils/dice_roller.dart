import 'dart:math';

class DiceRoller {
  DiceRoller({Random? random}) : _random = random ?? Random();

  final Random _random;

  int roll(int sides) => _random.nextInt(sides) + 1;
}
