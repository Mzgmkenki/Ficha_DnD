/// Categoria de opção narrativa que o antecedente oferece.
///
/// O [id] entra no identificador da opção (`acolyte.trait.3`) e é gravado na
/// ficha, então mudá-lo invalidaria escolhas já salvas.
enum PersonalityCategory {
  trait('trait', 'Traço de personalidade', 'Traços de personalidade'),
  ideal('ideal', 'Ideal', 'Ideais'),
  bond('bond', 'Vínculo', 'Vínculos'),
  flaw('flaw', 'Defeito', 'Defeitos');

  const PersonalityCategory(this.id, this.label, this.pluralLabel);

  final String id;
  final String label;
  final String pluralLabel;

  /// Devolve `null` em id desconhecido em vez de lançar: uma ficha gravada por
  /// uma versão futura não pode impedir o personagem de abrir.
  static PersonalityCategory? fromId(String? id) {
    if (id == null) return null;
    for (final item in values) {
      if (item.id == id) return item;
    }
    return null;
  }
}

/// Uma linha da tabela de traços, ideais, vínculos ou defeitos.
class PersonalityOption {
  const PersonalityOption({
    required this.id,
    required this.category,
    required this.roll,
    required this.text,
    this.name,
  });

  /// `<id do antecedente dono da tabela>.<categoria>.<resultado do dado>`.
  ///
  /// Deriva do dono da tabela, e não de quem a usa, para que antecedentes que
  /// compartilham tabela compartilhem também os identificadores: trocar de
  /// Acólito para Agente mantém a escolha válida em vez de descartá-la.
  final String id;

  final PersonalityCategory category;

  /// Resultado do dado que leva a esta opção. Serve para rolar na mesa e para
  /// manter a ordem impressa no livro.
  final int roll;

  final String text;

  /// Nome do ideal ("Comunidade", "Tradição"). Só os ideais têm.
  final String? name;

  /// Texto completo para exibir, com o nome do ideal quando existe.
  ///
  /// A tela mostra isto, e não [text] cru, porque "Eu estou nisso só pelo
  /// dinheiro" sem o rótulo "Ganância" perde a informação que o jogador usa
  /// para escolher.
  String get displayText {
    final prefix = name?.trim();
    if (prefix == null || prefix.isEmpty) return text;
    return '$prefix: $text';
  }

  @override
  String toString() => 'PersonalityOption($id)';
}

/// Uma tabela de opções narrativas de um antecedente.
class PersonalityTable {
  const PersonalityTable({
    required this.category,
    required this.die,
    required this.options,
  });

  final PersonalityCategory category;

  /// Dado da tabela (`d6`, `d8`, `d10`, `d20`). Vazio quando não há tabela.
  final String die;

  final List<PersonalityOption> options;

  /// Tabelas ausentes, usadas como padrão para o antecedente que não declara
  /// a categoria. Existir vazia em vez de ser nula evita espalhar checagem de
  /// nulo por toda a tela.
  static const PersonalityTable noTraits = PersonalityTable(
    category: PersonalityCategory.trait,
    die: '',
    options: <PersonalityOption>[],
  );
  static const PersonalityTable noIdeals = PersonalityTable(
    category: PersonalityCategory.ideal,
    die: '',
    options: <PersonalityOption>[],
  );
  static const PersonalityTable noBonds = PersonalityTable(
    category: PersonalityCategory.bond,
    die: '',
    options: <PersonalityOption>[],
  );
  static const PersonalityTable noFlaws = PersonalityTable(
    category: PersonalityCategory.flaw,
    die: '',
    options: <PersonalityOption>[],
  );

  bool get isEmpty => options.isEmpty;
  bool get isNotEmpty => options.isNotEmpty;

  PersonalityOption? optionById(String? id) {
    if (id == null) return null;
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  bool contains(String? id) => optionById(id) != null;
}

/// As quatro tabelas narrativas do antecedente e quantas escolhas cada uma
/// permite.
///
/// Fica num objeto próprio para as regras de personalidade não se espalharem
/// pelos widgets: a tela pergunta a este objeto quantas escolhas faltam e
/// quais opções existem, sem saber de qual antecedente vieram.
class BackgroundPersonality {
  const BackgroundPersonality({
    this.sourceId,
    this.traits = PersonalityTable.noTraits,
    this.ideals = PersonalityTable.noIdeals,
    this.bonds = PersonalityTable.noBonds,
    this.flaws = PersonalityTable.noFlaws,
    this.traitChoiceCount = 0,
    this.idealChoiceCount = 0,
    this.bondChoiceCount = 0,
    this.flawChoiceCount = 0,
  });

  /// Id do antecedente que é dono das tabelas.
  ///
  /// Diferente do id do antecedente quando ele reaproveita as tabelas de
  /// outro — o Agente usa as do Acólito, e o livro diz isso explicitamente.
  final String? sourceId;

  final PersonalityTable traits;
  final PersonalityTable ideals;
  final PersonalityTable bonds;
  final PersonalityTable flaws;

  final int traitChoiceCount;
  final int idealChoiceCount;
  final int bondChoiceCount;
  final int flawChoiceCount;

  static const BackgroundPersonality none = BackgroundPersonality();

  /// `true` quando o antecedente não oferece nenhuma tabela.
  ///
  /// A criação usa isto para simplesmente não mostrar os seletores, em vez de
  /// exibir campos vazios e obrigatórios que o jogador não teria como
  /// preencher.
  bool get isEmpty =>
      traits.isEmpty && ideals.isEmpty && bonds.isEmpty && flaws.isEmpty;

  bool get isNotEmpty => !isEmpty;

  PersonalityTable tableFor(PersonalityCategory category) {
    return switch (category) {
      PersonalityCategory.trait => traits,
      PersonalityCategory.ideal => ideals,
      PersonalityCategory.bond => bonds,
      PersonalityCategory.flaw => flaws,
    };
  }

  /// Quantas escolhas a categoria pede.
  ///
  /// Nunca passa do número de opções disponíveis: uma tabela com menos linhas
  /// do que o livro pede não pode gerar um formulário impossível de concluir.
  int choiceCountFor(PersonalityCategory category) {
    final declared = switch (category) {
      PersonalityCategory.trait => traitChoiceCount,
      PersonalityCategory.ideal => idealChoiceCount,
      PersonalityCategory.bond => bondChoiceCount,
      PersonalityCategory.flaw => flawChoiceCount,
    };

    final available = tableFor(category).options.length;
    if (declared <= 0 || available == 0) return 0;
    return declared > available ? available : declared;
  }

  /// Todas as categorias que este antecedente realmente pede.
  List<PersonalityCategory> get requiredCategories {
    return PersonalityCategory.values
        .where((category) => choiceCountFor(category) > 0)
        .toList(growable: false);
  }

  /// Procura a opção em qualquer categoria. Usado para resolver os ids
  /// gravados na ficha sem saber de antemão a que tabela pertencem.
  PersonalityOption? optionById(String? id) {
    if (id == null) return null;
    for (final category in PersonalityCategory.values) {
      final option = tableFor(category).optionById(id);
      if (option != null) return option;
    }
    return null;
  }
}
