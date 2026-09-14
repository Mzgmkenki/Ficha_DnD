/// Como a raça concede bônus de atributo.
///
/// Antes isso vivia implícito no JSON: quem tinha bônus à escolha usava chaves
/// inventadas em `fixed_ability_bonuses` (`um_escolhido`, por exemplo), e a
/// criação, que procura o bônus pelo nome do atributo, ignorava em silêncio —
/// o jogador simplesmente não recebia o bônus.
enum AbilityBonusMode {
  /// Valores definidos pela raça, como Anão com +2 de Constituição.
  fixed,

  /// Parte fixa mais valores distribuídos pelo jogador, como o Meio-Elfo:
  /// +2 de Carisma e +1 em dois atributos à escolha.
  choice,

  /// Padrão flexível de Mordenkainen: +2 e +1, ou +1 em três atributos.
  flexible;

  static AbilityBonusMode fromId(String? value) {
    switch (value) {
      case 'choice':
        return AbilityBonusMode.choice;
      case 'flexible':
        return AbilityBonusMode.flexible;
      default:
        return AbilityBonusMode.fixed;
    }
  }
}
