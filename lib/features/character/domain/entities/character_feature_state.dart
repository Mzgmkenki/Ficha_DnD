/// O que é decisão ou gasto do jogador numa característica de classe.
///
/// A característica em si vem do compêndio e é recalculada a cada leitura (ver
/// `SpecialFeatureResolver`): nome, descrição, nível e efeitos NÃO são
/// copiados para o personagem. Corrigir o compêndio corrige a ficha, e trocar
/// de classe simplesmente deixa de produzir a característica.
///
/// Aqui mora só o que o app não consegue derivar: quantos usos foram gastos,
/// se o estado ativável está ligado, e qual opção o jogador escolheu dentro da
/// característica.
class CharacterFeatureState {
  const CharacterFeatureState({
    required this.featureId,
    this.localId,
    this.usesSpent = 0,
    this.isActive = false,
    this.choiceOptionId,
  });

  /// Chave da linha no banco. Nula em estado recém-montado.
  final int? localId;

  /// Id estável da característica, montado por
  /// `SpecialFeatureResolver.featureId`.
  ///
  /// Guardar o id, e não a classe mais o nível mais o nome, é o que faz o
  /// estado sobreviver a uma tradução de nome no compêndio.
  final String featureId;

  /// Usos já gastos desde a última recarga.
  ///
  /// Conta o GASTO, e não o restante, porque o máximo é derivado do nível e do
  /// atributo e muda sozinho: um Monge que sobe de nível passa a ter mais
  /// pontos, e um contador de "restantes" ficaria defasado sem ninguém mexer
  /// nele. Com o gasto guardado, o restante é sempre `máximo - gasto`.
  final int usesSpent;

  /// Se o estado ativável está ligado.
  final bool isActive;

  /// Opção escolhida dentro da característica, quando ela pede uma escolha.
  final String? choiceOptionId;

  bool get isPristine =>
      usesSpent == 0 && !isActive && (choiceOptionId ?? '').isEmpty;

  CharacterFeatureState copyWith({
    int? localId,
    String? featureId,
    int? usesSpent,
    bool? isActive,
    String? choiceOptionId,
  }) {
    return CharacterFeatureState(
      localId: localId ?? this.localId,
      featureId: featureId ?? this.featureId,
      usesSpent: usesSpent ?? this.usesSpent,
      isActive: isActive ?? this.isActive,
      choiceOptionId: choiceOptionId ?? this.choiceOptionId,
    );
  }
}
