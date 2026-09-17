/// Eixo ético do alinhamento: a relação do personagem com regra e ordem.
enum AlignmentEthics {
  lawful('lawful', 'Leal'),
  neutral('neutral', 'Neutro'),
  chaotic('chaotic', 'Caótico');

  const AlignmentEthics(this.id, this.label);

  final String id;
  final String label;
}

/// Eixo moral do alinhamento: a relação do personagem com o bem e o mal.
enum AlignmentMorals {
  good('good', 'Bom'),
  neutral('neutral', 'Neutro'),
  evil('evil', 'Mau');

  const AlignmentMorals(this.id, this.label);

  final String id;
  final String label;
}

/// As nove combinações de alinhamento de D&D 5e.
///
/// Modelado como enum de nove valores com os dois eixos declarados em cada um,
/// e não como um par de enums soltos: assim o tipo só representa combinação
/// válida, e "Neutro e Neutro" não pode existir ao lado de "Neutro" como se
/// fossem coisas diferentes.
///
/// A ausência de alinhamento é representada por `null` no personagem, nunca por
/// um valor deste enum. "Não definido" não é neutro: o neutro é uma escolha do
/// jogador, e não saber ainda é outra coisa.
///
/// O nome é `CharacterAlignment`, e não `Alignment`, porque o Flutter já define
/// `Alignment` em `material.dart`. Prefixar o import em cada tela funcionaria,
/// mas deixaria `Alignment.center` e o alinhamento do personagem parecidos o
/// bastante para trocar um pelo outro sem o compilador reclamar.
enum CharacterAlignment {
  lawfulGood(
    'lawful_good',
    'Leal e Bom',
    AlignmentEthics.lawful,
    AlignmentMorals.good,
    'Age como se espera de alguém de bem, seguindo regras e compromissos.',
  ),
  neutralGood(
    'neutral_good',
    'Neutro e Bom',
    AlignmentEthics.neutral,
    AlignmentMorals.good,
    'Faz o bem que pode, sem se prender a regras nem a rebeldia.',
  ),
  chaoticGood(
    'chaotic_good',
    'Caótico e Bom',
    AlignmentEthics.chaotic,
    AlignmentMorals.good,
    'Age pela própria consciência, mesmo contra regras e expectativas.',
  ),
  lawfulNeutral(
    'lawful_neutral',
    'Leal e Neutro',
    AlignmentEthics.lawful,
    AlignmentMorals.neutral,
    'Segue lei, tradição ou código pessoal acima de outras considerações.',
  ),
  trueNeutral(
    'true_neutral',
    'Neutro',
    AlignmentEthics.neutral,
    AlignmentMorals.neutral,
    'Evita tomar partido e prefere o que parecer mais sensato na hora.',
  ),
  chaoticNeutral(
    'chaotic_neutral',
    'Caótico e Neutro',
    AlignmentEthics.chaotic,
    AlignmentMorals.neutral,
    'Segue os próprios impulsos e valoriza a liberdade acima do resto.',
  ),
  lawfulEvil(
    'lawful_evil',
    'Leal e Mau',
    AlignmentEthics.lawful,
    AlignmentMorals.evil,
    'Toma o que quer dentro dos limites de um código, tradição ou ordem.',
  ),
  neutralEvil(
    'neutral_evil',
    'Neutro e Mau',
    AlignmentEthics.neutral,
    AlignmentMorals.evil,
    'Faz o que consegue escapar de fazer, sem apego a regras nem a caos.',
  ),
  chaoticEvil(
    'chaotic_evil',
    'Caótico e Mau',
    AlignmentEthics.chaotic,
    AlignmentMorals.evil,
    'Age por ganância, ódio ou impulso, sem respeito por ordem alguma.',
  );

  const CharacterAlignment(
    this.id,
    this.label,
    this.ethics,
    this.morals,
    this.description,
  );

  /// Identificador estável, gravado no banco e no arquivo exportado.
  ///
  /// Separado do `name` do enum de propósito, como em `Condition`: renomear o
  /// valor em Dart não pode invalidar o que já está salvo.
  final String id;

  /// Como aparece na tela e no PDF.
  ///
  /// A combinação neutra em ambos os eixos é "Neutro", e não "Neutro e Neutro":
  /// é o termo que a mesa usa.
  final String label;

  final AlignmentEthics ethics;
  final AlignmentMorals morals;

  /// Uma linha curta e descritiva, sem julgamento de valor.
  ///
  /// Existe para o jogador escolher sem precisar do livro aberto.
  final String description;

  /// Devolve o alinhamento do id, ou nulo se o id não existir.
  ///
  /// Nulo em vez de exceção: um id legado ou digitado errado num arquivo
  /// importado não pode tornar o personagem inacessível.
  static CharacterAlignment? fromId(String? id) {
    if (id == null) return null;

    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;

    for (final alignment in CharacterAlignment.values) {
      if (alignment.id == trimmed) return alignment;
    }

    return null;
  }

  /// Rótulo de exibição de um alinhamento que pode não existir.
  static String labelOrUndefined(CharacterAlignment? alignment) =>
      alignment?.label ?? undefinedLabel;

  /// Como a ausência de alinhamento aparece na interface.
  static const String undefinedLabel = 'Não definido';

  /// Os nove alinhamentos na ordem tradicional de grade: por moral e, dentro
  /// dela, por ética. É a ordem em que o livro os apresenta.
  static List<CharacterAlignment> get ordered =>
      List.unmodifiable(CharacterAlignment.values);
}
