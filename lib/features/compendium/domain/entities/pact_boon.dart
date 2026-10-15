/// A Dádiva do Pacto escolhida no 3º nível de Bruxo.
///
/// Existe como enum com [id] estável porque a dádiva é CHAVE DE DEPENDÊNCIA:
/// metade das Invocações Místicas só está disponível para um pacto específico,
/// e comparar o texto visível ("Pacto da Lâmina") seria a forma mais frágil
/// possível de ligar as duas coisas — o rótulo é traduzido, aparece com
/// variações no compêndio e muda quando o texto é revisado.
///
/// O [id] é o que fica persistido, em `CharacterFeatureState.choiceOptionId`,
/// e é o mesmo literal usado no bloco `choice` do asset e no campo
/// `prerequisites.pact_boon` do catálogo de invocações. Renomear um valor em
/// Dart não pode invalidar ficha salva: para acrescentar pacto, adicione no
/// fim.
enum PactBoon {
  blade('pact_of_the_blade', 'Pacto da Lâmina'),
  chain('pact_of_the_chain', 'Pacto da Corrente'),
  tome('pact_of_the_tome', 'Pacto do Tomo'),
  talisman('pact_of_the_talisman', 'Pacto do Talismã');

  const PactBoon(this.id, this.label);

  /// Identificador estável, persistido e usado nos pré-requisitos.
  final String id;

  /// Nome como a ficha mostra.
  final String label;

  /// Id da escolha declarada no asset, em `class_features.json`.
  ///
  /// Fica aqui, e não na tela, para o validador e a interface apontarem para o
  /// mesmo bloco sem repetir o literal.
  static const String choiceId = 'warlock.pact_boon';

  /// Id da característica de classe que carrega a escolha.
  ///
  /// É o que `SpecialFeatureResolver.featureId` produz para "Dádiva do Pacto"
  /// no 3º nível de Bruxo. Declarado como constante porque o validador precisa
  /// ler a escolha do jogador sem resolver o compêndio inteiro.
  static const String featureId = 'class.warlock.3.dadiva_do_pacto';

  static PactBoon? fromId(String? id) {
    if (id == null) return null;
    final normalized = id.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    for (final item in PactBoon.values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}
