/// Uma decisão do jogador dentro de uma mecânica de classe ou subclasse.
///
/// Guarda só o que é DECISÃO ou HISTÓRICO: qual mecânica, qual opção, em que
/// nível foi escolhida, o que ela substituiu e o resultado de tabela
/// registrado. Nome, descrição, pré-requisito, limite e efeito NÃO são
/// copiados para o personagem — eles vêm do catálogo a cada leitura, como nas
/// características de classe e nas Invocações Místicas. Corrigir o catálogo
/// corrige todas as fichas, e perder níveis simplesmente faz a escolha
/// aparecer como inválida.
///
/// Por que usos e estado ativo NÃO ficam aqui: eles já têm lugar em
/// `CharacterFeatureState`, indexado por
/// `ClassMechanicEntry.mechanicFeatureId`. Reaproveitar aquele armazenamento é
/// o que faz o painel de Recursos e descanso, o descanso curto e o descanso
/// longo funcionarem sem nenhum código novo — é o mesmo caminho que as
/// invocações com usos limitados já usam.
class CharacterClassMechanic {
  const CharacterClassMechanic({
    required this.mechanicId,
    this.localId,
    this.optionId,
    this.isSelected = true,
    this.chosenAtLevel = 0,
    this.replacedOptionId,
    this.replacedAtLevel,
    this.rollResult,
    this.note,
  });

  /// Chave da linha no banco. Nula em registro recém-montado.
  final int? localId;

  /// Id estável da mecânica no catálogo
  /// (`fighter_battle_master.maneuvers`).
  final String mechanicId;

  /// Id da opção escolhida dentro da mecânica (`riposte`).
  ///
  /// Nulo é um registro de MECÂNICA, não de opção: é assim que o resultado de
  /// uma tabela de rolagem fica guardado, porque o Surto de Magia Selvagem não
  /// tem opção escolhida, tem resultado.
  final String? optionId;

  /// Se este registro CONTA contra o limite de escolhas.
  ///
  /// Existe porque uma linha pode existir sem ser escolha: o resultado de
  /// tabela e a anotação do jogador também moram aqui. Sem o campo, o
  /// resultado "3" do Surto Selvagem viraria uma manobra escolhida na
  /// contagem.
  final bool isSelected;

  /// Nível NA CLASSE responsável em que a opção foi escolhida.
  ///
  /// Zero significa "não registrado", o que é o caso de ficha importada de
  /// versão anterior a este campo. Não é tratado como nível 0: quem lê usa
  /// apenas para exibir o histórico.
  final int chosenAtLevel;

  /// Id da opção que esta substituiu, quando houve substituição.
  ///
  /// Fica na própria linha, em vez de numa tabela de histórico separada,
  /// porque a pergunta que a ficha faz é sempre "esta opção veio de uma
  /// troca?" — e a resposta é um campo, não uma consulta.
  final String? replacedOptionId;

  /// Nível em que a substituição aconteceu.
  final int? replacedAtLevel;

  /// Resultado registrado de uma tabela de rolagem.
  ///
  /// Guarda o id da LINHA da tabela, não o número rolado, pela mesma razão de
  /// [optionId]: a faixa `01–02` é apresentação e muda com a formatação, o id
  /// da linha não.
  final String? rollResult;

  /// Anotação livre do jogador sobre esta escolha.
  final String? note;

  /// Se o registro é de uma opção, e não da mecânica como um todo.
  bool get hasOption => (optionId ?? '').isNotEmpty;

  /// Se o registro guarda um resultado de tabela.
  bool get hasRollResult => (rollResult ?? '').isNotEmpty;

  /// Se o registro conta como escolha permanente feita pelo jogador.
  bool get countsAsPick => isSelected && hasOption;

  bool get replacedSomething => (replacedOptionId ?? '').isNotEmpty;

  /// Se a linha não carrega informação nenhuma e pode ser descartada.
  ///
  /// Serve para a gravação não acumular linha vazia a cada abertura da ficha,
  /// que é o que tornaria "abrir e salvar várias vezes" uma fonte de lixo.
  bool get isPristine => !hasOption && !hasRollResult && (note ?? '').isEmpty;

  CharacterClassMechanic copyWith({
    int? localId,
    String? mechanicId,
    String? optionId,
    bool? isSelected,
    int? chosenAtLevel,
    String? replacedOptionId,
    int? replacedAtLevel,
    String? rollResult,
    String? note,
  }) {
    return CharacterClassMechanic(
      localId: localId ?? this.localId,
      mechanicId: mechanicId ?? this.mechanicId,
      optionId: optionId ?? this.optionId,
      isSelected: isSelected ?? this.isSelected,
      chosenAtLevel: chosenAtLevel ?? this.chosenAtLevel,
      replacedOptionId: replacedOptionId ?? this.replacedOptionId,
      replacedAtLevel: replacedAtLevel ?? this.replacedAtLevel,
      rollResult: rollResult ?? this.rollResult,
      note: note ?? this.note,
    );
  }
}
