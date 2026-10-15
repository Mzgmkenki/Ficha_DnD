/// De onde um idioma do personagem veio.
///
/// Só os valores que podem ser PERSISTIDOS entram aqui. Idioma automático de
/// raça, classe ou antecedente não é gravado: ele é derivado do compêndio a
/// cada leitura, pelo mesmo motivo das características especiais — corrigir o
/// compêndio corrige todas as fichas, e trocar de raça simplesmente deixa de
/// produzir o idioma, sem precisar de rotina de limpeza.
enum LanguageOriginKind {
  /// Escolha do jogador numa vaga aberta por alguma fonte.
  choice('choice', 'escolhido'),

  /// Acrescentado à mão, sem vaga. O Mestre concedeu em mesa.
  manual('manual', 'manual'),

  /// Veio de ficha antiga ou importada, sem origem identificável.
  ///
  /// Não é apagado e não é promovido a escolha: afirmar uma vaga que não se
  /// sabe se existiu gastaria uma escolha do jogador.
  legacy('legacy', 'dado legado');

  const LanguageOriginKind(this.id, this.label);

  final String id;
  final String label;

  static LanguageOriginKind fromId(String? value) {
    if (value == null) return legacy;
    final normalized = value.trim().toLowerCase();
    for (final item in values) {
      if (item.id == normalized) return item;
    }
    // Id desconhecido cai em legado em vez de lançar: um dado estranho não
    // pode tornar o personagem inacessível.
    return legacy;
  }
}

/// Um idioma gravado na ficha do personagem.
///
/// Guarda o ID do idioma, nunca o nome: renomear "Leonino" para "Leonin" no
/// compêndio não pode fazer o personagem perder o idioma.
class CharacterLanguage {
  const CharacterLanguage({
    required this.languageId,
    this.localId,
    this.kind = LanguageOriginKind.choice,
    this.slotId,
    this.sourceId,
    this.sourceLabel,
  });

  /// Nulo enquanto não foi gravado.
  final int? localId;

  /// Id do idioma no catálogo.
  final String languageId;

  final LanguageOriginKind kind;

  /// Id da vaga que permitiu a escolha.
  ///
  /// É o que o levantamento pede com "cada idioma selecionado deve guardar a
  /// origem da vaga que permitiu sua escolha": quando a vaga deixa de existir
  /// — trocou a raça, soltou o talento — a escolha perde o apoio e sai, e as
  /// que continuam apoiadas ficam. Nulo em idioma manual ou legado.
  final String? slotId;

  /// Id da fonte que abriu a vaga (`elf_phb`, `acolyte`, `linguist`).
  final String? sourceId;

  /// Rótulo da fonte, já pronto para exibir.
  ///
  /// Persistido em vez de remontado na leitura, igual ao inventário: o
  /// compêndio pode mudar de nome, e a ficha deve continuar dizendo de onde o
  /// idioma veio — inclusive quando a fonte já não existe mais.
  final String? sourceLabel;

  bool get isChoice => kind == LanguageOriginKind.choice;

  bool get isLegacy => kind == LanguageOriginKind.legacy;

  /// Se o registro depende de uma vaga para continuar válido.
  bool get needsSlot => isChoice;

  CharacterLanguage copyWith({
    int? localId,
    String? languageId,
    LanguageOriginKind? kind,
    String? slotId,
    String? sourceId,
    String? sourceLabel,
  }) {
    return CharacterLanguage(
      localId: localId ?? this.localId,
      languageId: languageId ?? this.languageId,
      kind: kind ?? this.kind,
      slotId: slotId ?? this.slotId,
      sourceId: sourceId ?? this.sourceId,
      sourceLabel: sourceLabel ?? this.sourceLabel,
    );
  }
}
