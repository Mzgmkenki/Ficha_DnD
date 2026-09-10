import 'dart:math';

/// Como o d20 é rolado: normal, com vantagem ou com desvantagem.
enum RollMode {
  normal('Normal'),
  advantage('Vantagem'),
  disadvantage('Desvantagem');

  const RollMode(this.label);

  final String label;

  bool get isNormal => this == RollMode.normal;
}

/// Resultado de uma rolagem, com os dados individuais preservados para o
/// jogador conferir o que saiu (e não só o total).
class DiceRollResult {
  const DiceRollResult({
    required this.rolls,
    required this.keptValue,
    required this.sides,
    required this.modifier,
    required this.mode,
    this.label = '',
  });

  /// Todos os dados que caíram na mesa, na ordem em que foram rolados.
  final List<int> rolls;

  /// O que valeu: com vantagem/desvantagem é o maior/menor d20; nos demais
  /// casos é a soma dos dados.
  final int keptValue;

  final int sides;
  final int modifier;
  final RollMode mode;

  /// Nome do teste, por exemplo "Furtividade (DES)".
  final String label;

  int get total => keptValue + modifier;

  /// 20 natural: só faz sentido no d20 e olhando o dado que valeu.
  bool get isNaturalTwenty => sides == 20 && keptValue == 20;

  bool get isNaturalOne => sides == 20 && keptValue == 1;

  String get modifierText {
    if (modifier == 0) return '';
    return modifier > 0 ? '+$modifier' : '$modifier';
  }

  /// Ex.: `2d20 (maior) +5` ou `2d6 -1`.
  String get formula {
    final dice = '${rolls.length}d$sides';
    final suffix = switch (mode) {
      RollMode.advantage => ' (maior)',
      RollMode.disadvantage => ' (menor)',
      RollMode.normal => '',
    };
    final mod = modifierText.isEmpty ? '' : ' $modifierText';
    return '$dice$suffix$mod';
  }

  /// Ex.: `18, 4 → 18 +5`, para mostrar o caminho até o total.
  String get detail {
    final rolled = rolls.join(', ');
    final kept = rolls.length > 1 ? ' → $keptValue' : '';
    final mod = modifierText.isEmpty ? '' : ' $modifierText';
    return '$rolled$kept$mod';
  }
}

/// Rolador de dados. O [Random] é injetável para os testes poderem fixar a
/// sequência.
class DiceRoller {
  DiceRoller({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Um dado de [sides] faces, de 1 a [sides].
  int rollDie(int sides) {
    if (sides < 2) {
      throw ArgumentError.value(sides, 'sides', 'Um dado precisa de 2+ faces.');
    }
    return _random.nextInt(sides) + 1;
  }

  /// Rola [amount] dados de [sides] faces e soma [modifier].
  DiceRollResult roll({
    required int amount,
    required int sides,
    int modifier = 0,
    String label = '',
  }) {
    if (amount < 1) {
      throw ArgumentError.value(amount, 'amount', 'Role pelo menos 1 dado.');
    }

    final rolls = [for (var i = 0; i < amount; i++) rollDie(sides)];

    return DiceRollResult(
      rolls: rolls,
      keptValue: rolls.fold(0, (total, value) => total + value),
      sides: sides,
      modifier: modifier,
      mode: RollMode.normal,
      label: label,
    );
  }

  /// Teste de d20, respeitando vantagem e desvantagem: dois dados, vale o
  /// maior ou o menor.
  DiceRollResult rollD20({
    int modifier = 0,
    RollMode mode = RollMode.normal,
    String label = '',
  }) {
    final amount = mode.isNormal ? 1 : 2;
    final rolls = [for (var i = 0; i < amount; i++) rollDie(20)];

    final kept = switch (mode) {
      RollMode.normal => rolls.first,
      RollMode.advantage => rolls.reduce(max),
      RollMode.disadvantage => rolls.reduce(min),
    };

    return DiceRollResult(
      rolls: rolls,
      keptValue: kept,
      sides: 20,
      modifier: modifier,
      mode: mode,
      label: label,
    );
  }
}
