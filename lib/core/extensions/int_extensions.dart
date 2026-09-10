extension DndIntExtensions on int {
  /// Modificador de atributo: (valor - 10) / 2, arredondado para baixo.
  int get abilityModifier => ((this - 10) / 2).floor();
}
