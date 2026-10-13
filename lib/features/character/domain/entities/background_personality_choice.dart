import 'package:dnd_ficha_app/features/compendium/domain/entities/background_personality.dart';

/// Uma escolha narrativa que o jogador fez no antecedente.
///
/// Guarda o IDENTIFICADOR da opção, não o texto. Assim corrigir uma frase do
/// compêndio corrige todas as fichas, e o mesmo texto não fica copiado em cada
/// personagem. A exceção é [customText], que é conteúdo do próprio jogador e
/// por isso mora na ficha.
class BackgroundPersonalityChoice {
  const BackgroundPersonalityChoice({
    required this.category,
    this.optionId,
    this.customText,
  });

  /// Escolha vinda de uma tabela do compêndio.
  factory BackgroundPersonalityChoice.fromOption(PersonalityOption option) {
    return BackgroundPersonalityChoice(
      category: option.category,
      optionId: option.id,
    );
  }

  /// Escolha escrita pelo jogador.
  ///
  /// Só existe porque o app já suporta conteúdo próprio no antecedente
  /// customizável; não foi inventada para esta tela.
  factory BackgroundPersonalityChoice.custom({
    required PersonalityCategory category,
    required String text,
  }) {
    return BackgroundPersonalityChoice(
      category: category,
      customText: text.trim(),
    );
  }

  final PersonalityCategory category;

  /// Id da opção escolhida (`acolyte.trait.3`). Nulo quando é texto próprio.
  final String? optionId;

  /// Texto escrito pelo jogador. Nulo quando a escolha veio da tabela.
  final String? customText;

  bool get isCustom => optionId == null;

  /// `true` quando a escolha não aponta para nada utilizável.
  bool get isEmpty {
    final id = optionId?.trim();
    final text = customText?.trim();
    return (id == null || id.isEmpty) && (text == null || text.isEmpty);
  }

  /// Chave usada para impedir escolha repetida dentro da mesma categoria.
  ///
  /// Dois traços personalizados com o mesmo texto também colidem, e isso é
  /// intencional: o requisito é não escolher a mesma coisa duas vezes, e
  /// repetir a frase é escolher a mesma coisa.
  String get dedupeKey {
    final id = optionId?.trim();
    if (id != null && id.isNotEmpty) return 'option:$id';
    return 'custom:${customText?.trim().toLowerCase() ?? ''}';
  }

  /// Texto para exibir, resolvido contra as tabelas do antecedente.
  ///
  /// Devolve `null` quando o id não existe mais nas tabelas — é o caso de uma
  /// escolha feita num antecedente e consultada em outro. Quem chama decide o
  /// que fazer: a ficha mostra um aviso, a criação descarta.
  String? resolveText(BackgroundPersonality personality) {
    final text = customText?.trim();
    if (text != null && text.isNotEmpty) return text;

    final option = personality.optionById(optionId);
    return option?.displayText;
  }

  /// `true` quando a escolha continua válida para estas tabelas.
  bool isValidFor(BackgroundPersonality personality) {
    if (isEmpty) return false;
    if (isCustom) return true;
    return personality.optionById(optionId) != null;
  }

  BackgroundPersonalityChoice copyWith({
    PersonalityCategory? category,
    String? optionId,
    String? customText,
  }) {
    return BackgroundPersonalityChoice(
      category: category ?? this.category,
      optionId: optionId ?? this.optionId,
      customText: customText ?? this.customText,
    );
  }

  @override
  String toString() => 'BackgroundPersonalityChoice(${category.id}, $dedupeKey)';
}

/// O conjunto de escolhas narrativas do personagem, com as regras de validação.
///
/// Centraliza aqui o que a tela precisaria repetir: quantas faltam, se há
/// repetição, se tudo continua compatível com o antecedente atual. A tela
/// pergunta, não decide.
class BackgroundPersonalitySelection {
  BackgroundPersonalitySelection(Iterable<BackgroundPersonalityChoice> choices)
      : choices = List<BackgroundPersonalityChoice>.unmodifiable(
          choices.where((choice) => !choice.isEmpty),
        );

  static final BackgroundPersonalitySelection empty =
      BackgroundPersonalitySelection(const []);

  final List<BackgroundPersonalityChoice> choices;

  bool get isEmpty => choices.isEmpty;
  bool get isNotEmpty => choices.isNotEmpty;

  List<BackgroundPersonalityChoice> forCategory(PersonalityCategory category) {
    return choices
        .where((choice) => choice.category == category)
        .toList(growable: false);
  }

  int countFor(PersonalityCategory category) => forCategory(category).length;

  /// Mantém só o que continua válido para estas tabelas.
  ///
  /// Usado na troca de antecedente: a escolha que existe nas tabelas novas
  /// sobrevive (Acólito e Agente compartilham tabela, então nada é perdido ao
  /// trocar entre os dois), e o resto sai. Texto próprio do jogador sempre
  /// sobrevive, porque não pertence a tabela nenhuma.
  BackgroundPersonalitySelection retainValidFor(
    BackgroundPersonality personality,
  ) {
    return BackgroundPersonalitySelection(
      choices.where((choice) => choice.isValidFor(personality)),
    );
  }

  /// O que seria descartado por [retainValidFor].
  ///
  /// Serve para avisar o jogador exatamente o que precisa ser refeito, em vez
  /// de um aviso genérico.
  List<BackgroundPersonalityChoice> invalidFor(
    BackgroundPersonality personality,
  ) {
    return choices
        .where((choice) => !choice.isValidFor(personality))
        .toList(growable: false);
  }

  /// Categorias em que o jogador escolheu a mesma opção mais de uma vez.
  Map<PersonalityCategory, List<BackgroundPersonalityChoice>> get duplicates {
    final result = <PersonalityCategory, List<BackgroundPersonalityChoice>>{};

    for (final category in PersonalityCategory.values) {
      final items = forCategory(category);
      final seen = <String>{};
      final repeated = <BackgroundPersonalityChoice>[];

      for (final choice in items) {
        if (!seen.add(choice.dedupeKey)) repeated.add(choice);
      }

      if (repeated.isNotEmpty) result[category] = repeated;
    }

    return result;
  }

  /// Mensagem do que falta ou está repetido, ou `null` quando está tudo certo.
  ///
  /// Antecedente que não oferece uma categoria não gera pendência: o
  /// [personality] é quem diz quantas escolhas existem, e zero é um número
  /// válido. É isso que mantém a criação funcionando para antecedente sem
  /// tabela de defeitos, por exemplo.
  String? validationError(BackgroundPersonality personality) {
    for (final entry in duplicates.entries) {
      return 'Você escolheu a mesma opção duas vezes em '
          '${entry.key.pluralLabel.toLowerCase()}. Escolha outra.';
    }

    final missing = <String>[];
    for (final category in PersonalityCategory.values) {
      final required = personality.choiceCountFor(category);
      if (required == 0) continue;

      final chosen = countFor(category);
      if (chosen < required) {
        // O aviso conta o que ainda falta, não o total da categoria: com um
        // dos dois traços já escolhido, pedir "2 traços" manda o jogador
        // refazer o que já está feito.
        final remaining = required - chosen;
        missing.add(
          remaining == 1
              ? category.label.toLowerCase()
              : '$remaining ${category.pluralLabel.toLowerCase()}',
        );
      }
    }

    if (missing.isEmpty) return null;

    return 'Falta escolher ${missing.join(', ')} do antecedente.';
  }

  bool isComplete(BackgroundPersonality personality) =>
      validationError(personality) == null;

  /// Troca o que foi escolhido numa posição de uma categoria.
  ///
  /// A posição importa porque o padrão 2014 pede dois traços, e os dois são
  /// campos independentes na tela.
  BackgroundPersonalitySelection replaceAt({
    required PersonalityCategory category,
    required int index,
    BackgroundPersonalityChoice? choice,
  }) {
    final others = choices
        .where((item) => item.category != category)
        .toList(growable: true);
    final sameCategory = forCategory(category).toList(growable: true);

    while (sameCategory.length <= index) {
      sameCategory.add(
        BackgroundPersonalityChoice(category: category),
      );
    }

    if (choice == null) {
      sameCategory[index] = BackgroundPersonalityChoice(category: category);
    } else {
      sameCategory[index] = choice;
    }

    return BackgroundPersonalitySelection([...others, ...sameCategory]);
  }

  /// A escolha de uma posição, ou `null` quando ainda está vazia.
  ///
  /// Começar vazio é requisito: nenhuma opção é pré-selecionada.
  BackgroundPersonalityChoice? at(PersonalityCategory category, int index) {
    final items = forCategory(category);
    if (index < 0 || index >= items.length) return null;
    final choice = items[index];
    return choice.isEmpty ? null : choice;
  }
}
