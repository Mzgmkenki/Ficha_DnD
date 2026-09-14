/// Perícias que a raça deixa o jogador escolher.
///
/// Diferente de `grantedSkills`, que a raça concede direto: aqui o jogador
/// escolhe [choose] entre [options], como o Centauro, que fica com uma entre
/// Adestrar Animais, Medicina, Natureza e Sobrevivência.
class RaceSkillChoice {
  const RaceSkillChoice({required this.choose, required this.options});

  final int choose;

  /// Ids de `Skill`.
  final List<String> options;
}
