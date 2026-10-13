/// Moedas do personagem.
///
/// Taxas oficiais de 5e: 1 PL = 10 PO = 20 PE = 100 PP = 1000 PC.
class Currency {
  const Currency({
    this.copper = 0,
    this.silver = 0,
    this.electrum = 0,
    this.gold = 0,
    this.platinum = 0,
  });

  final int copper;
  final int silver;
  final int electrum;
  final int gold;
  final int platinum;

  /// Valor total convertido em peças de ouro (com fração).
  double get totalInGold {
    return platinum * 10 +
        gold +
        electrum * 0.5 +
        silver * 0.1 +
        copper * 0.01;
  }

  bool get isEmpty =>
      copper == 0 &&
      silver == 0 &&
      electrum == 0 &&
      gold == 0 &&
      platinum == 0;

  bool get isNotEmpty => !isEmpty;

  /// Soma moeda por moeda, sem converter nada.
  ///
  /// Converter aqui seria errado: 10 PP não devem virar 1 PO sozinhas, porque
  /// a mesa conta as peças que o personagem carrega. A conversão existe só na
  /// leitura, em [totalInGold], e é informativa.
  Currency plus(Currency other) {
    return Currency(
      copper: copper + other.copper,
      silver: silver + other.silver,
      electrum: electrum + other.electrum,
      gold: gold + other.gold,
      platinum: platinum + other.platinum,
    );
  }

  /// Subtrai moeda por moeda, cortando em zero.
  ///
  /// O corte importa na troca de antecedente: se o jogador já gastou o ouro
  /// inicial, remover o antecedente não pode deixar a carteira negativa nem
  /// "roubar" de outra moeda para fechar a conta.
  Currency minus(Currency other) {
    int sub(int a, int b) {
      final result = a - b;
      return result < 0 ? 0 : result;
    }

    return Currency(
      copper: sub(copper, other.copper),
      silver: sub(silver, other.silver),
      electrum: sub(electrum, other.electrum),
      gold: sub(gold, other.gold),
      platinum: sub(platinum, other.platinum),
    );
  }

  /// Versão sem valores negativos, para o que vem de fora (banco, import).
  Currency get nonNegative {
    int clamp(int value) => value < 0 ? 0 : value;

    return Currency(
      copper: clamp(copper),
      silver: clamp(silver),
      electrum: clamp(electrum),
      gold: clamp(gold),
      platinum: clamp(platinum),
    );
  }

  Currency copyWith({
    int? copper,
    int? silver,
    int? electrum,
    int? gold,
    int? platinum,
  }) {
    return Currency(
      copper: copper ?? this.copper,
      silver: silver ?? this.silver,
      electrum: electrum ?? this.electrum,
      gold: gold ?? this.gold,
      platinum: platinum ?? this.platinum,
    );
  }
}
