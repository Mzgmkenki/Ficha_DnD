/// Uma Invocação Mística que o personagem escolheu.
///
/// Guarda só o que é decisão do jogador: QUAL invocação, em que nível de Bruxo
/// ela foi escolhida e qual ela substituiu. Nome, descrição, pré-requisitos e
/// efeitos NÃO são copiados para o personagem — eles vêm do catálogo a cada
/// leitura, como nas características de classe. Corrigir o catálogo corrige a
/// ficha, e o jogador nunca fica preso a um texto antigo.
///
/// Por que o nível de escolha fica guardado: a regra de substituição é "ao
/// subir de nível você pode trocar uma invocação", e sem o nível de origem não
/// há como registrar o histórico nem explicar por que uma invocação deixou de
/// ser válida.
class CharacterEldritchInvocation {
  const CharacterEldritchInvocation({
    required this.invocationId,
    this.localId,
    this.chosenAtLevel = 0,
    this.replacedInvocationId,
    this.replacedAtLevel,
  });

  /// Chave da linha no banco. Nula em registro recém-montado.
  final int? localId;

  /// Id estável da invocação no catálogo.
  ///
  /// É um id, e não o nome: a validação compara propriedades estruturadas, e o
  /// nome é traduzido e revisável.
  final String invocationId;

  /// Nível NA CLASSE BRUXO em que a invocação foi escolhida.
  ///
  /// Zero significa "não registrado", o que é o caso de ficha importada de
  /// versão anterior a este campo. Não é tratado como nível 0: quem lê usa
  /// apenas para exibir o histórico.
  final int chosenAtLevel;

  /// Id da invocação que esta substituiu, quando houve substituição.
  ///
  /// Fica na própria linha, em vez de numa tabela de histórico separada,
  /// porque a pergunta que a ficha faz é sempre "esta invocação veio de uma
  /// troca?" — e a resposta é um campo, não uma consulta.
  final String? replacedInvocationId;

  /// Nível de Bruxo em que a substituição aconteceu.
  final int? replacedAtLevel;

  bool get replacedSomething =>
      replacedInvocationId != null && replacedInvocationId!.isNotEmpty;

  CharacterEldritchInvocation copyWith({
    int? localId,
    String? invocationId,
    int? chosenAtLevel,
    String? replacedInvocationId,
    int? replacedAtLevel,
  }) {
    return CharacterEldritchInvocation(
      localId: localId ?? this.localId,
      invocationId: invocationId ?? this.invocationId,
      chosenAtLevel: chosenAtLevel ?? this.chosenAtLevel,
      replacedInvocationId: replacedInvocationId ?? this.replacedInvocationId,
      replacedAtLevel: replacedAtLevel ?? this.replacedAtLevel,
    );
  }
}
