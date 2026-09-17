/// Os testes contra a morte registrados no personagem.
///
/// Regra de D&D 5e (Livro do Jogador 2014, capítulo 9): a 0 pontos de vida o
/// personagem rola um d20 no começo de cada turno, sem modificador. Três
/// sucessos estabilizam, três falhas matam. Um `1` natural conta como duas
/// falhas e um `20` natural devolve 1 ponto de vida.
///
/// Os marcadores são contagens, não uma lista de resultados: a ficha de papel
/// tem três bolinhas de cada lado, e é exatamente essa informação que a mesa
/// precisa. Guardar o histórico de cada rolagem seria outra funcionalidade.
class DeathSaves {
  const DeathSaves({this.successes = 0, this.failures = 0})
      : assert(successes >= 0),
        assert(failures >= 0);

  /// Quantos marcadores existem de cada lado.
  static const int maxMarks = 3;

  final int successes;
  final int failures;

  /// Nenhum marcador registrado: o personagem não está morrendo.
  bool get isEmpty => successes == 0 && failures == 0;

  bool get isNotEmpty => !isEmpty;

  /// Três sucessos: o personagem parou de morrer, mas segue a 0 PV.
  bool get isStable => successes >= maxMarks;

  /// Três falhas.
  bool get isDead => failures >= maxMarks;

  /// Se ainda há teste para rolar.
  ///
  /// Falso quando o personagem já estabilizou ou já morreu: nos dois casos a
  /// sequência terminou, e continuar rolando não muda nada.
  bool get isResolved => isStable || isDead;

  /// Soma um sucesso, respeitando o teto.
  DeathSaves withSuccess() {
    return copyWith(successes: (successes + 1).clamp(0, maxMarks));
  }

  /// Soma [amount] falhas, respeitando o teto.
  ///
  /// [amount] existe por causa do `1` natural, que vale duas de uma vez, e do
  /// acerto crítico contra quem está caído.
  DeathSaves withFailure({int amount = 1}) {
    return copyWith(failures: (failures + amount).clamp(0, maxMarks));
  }

  /// Apaga os dois lados.
  ///
  /// É o que acontece ao recuperar qualquer ponto de vida: a sequência de
  /// testes zera, e um novo desmaio começa do zero.
  DeathSaves cleared() => const DeathSaves();

  /// Devolve o valor com um marcador a menos, para desfazer marcação acidental.
  DeathSaves withoutSuccess() {
    return copyWith(successes: (successes - 1).clamp(0, maxMarks));
  }

  DeathSaves withoutFailure() {
    return copyWith(failures: (failures - 1).clamp(0, maxMarks));
  }

  /// `2 sucessos e 1 falha`, para o resumo da seção recolhida.
  String describe() {
    if (isEmpty) return 'Nenhum teste registrado';

    final parts = <String>[
      if (successes > 0) successes == 1 ? '1 sucesso' : '$successes sucessos',
      if (failures > 0) failures == 1 ? '1 falha' : '$failures falhas',
    ];

    return parts.join(' e ');
  }

  DeathSaves copyWith({int? successes, int? failures}) {
    return DeathSaves(
      successes: successes ?? this.successes,
      failures: failures ?? this.failures,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeathSaves &&
        other.successes == successes &&
        other.failures == failures;
  }

  @override
  int get hashCode => Object.hash(successes, failures);

  @override
  String toString() => 'DeathSaves(${describe()})';
}
