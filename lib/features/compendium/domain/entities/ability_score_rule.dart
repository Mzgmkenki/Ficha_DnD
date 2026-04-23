class AbilityScoreRule {
  const AbilityScoreRule({
    required this.type,
    this.fixedBonuses,
    this.choose,
    this.maxPerAbility,
  });

  /// fixed | flexible
  final String type;

  /// Ex.: {"strength": 2, "constitution": 1}
  final Map<String, int>? fixedBonuses;

  /// Quantos atributos o usuário pode escolher
  final int? choose;

  /// Valor máximo por atributo na escolha flexível
  final int? maxPerAbility;
}