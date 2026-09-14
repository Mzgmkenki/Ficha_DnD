enum SpellcastingType {
  full,
  half,
  third,
  pact,

  /// Artífice.
  ///
  /// Não dá para reaproveitar [half]: o artífice já tem espaços no 1º nível,
  /// enquanto paladino e patrulheiro só a partir do 2º, e no multiclasse ele
  /// arredonda o nível de conjurador para cima em vez de para baixo.
  artificer,
}
