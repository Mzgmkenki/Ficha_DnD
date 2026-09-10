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
