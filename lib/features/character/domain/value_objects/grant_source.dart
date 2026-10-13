/// De onde veio um item do inventário ou um valor em moedas.
///
/// Existe para a troca de antecedente conseguir remover só o que o antecedente
/// anterior concedeu, preservando o que o jogador adicionou à mão e o que veio
/// de classe, raça ou talento. Sem isso só restaria comparar nomes, e nome é
/// editável pelo jogador.
///
/// O [id] é persistido: renomear um valor existente invalidaria o rastro de
/// origem de fichas já gravadas. Para acrescentar origem, adicione no fim.
///
/// Irmão de `SkillGrantSource`, que faz o mesmo para proficiências. Os dois
/// não foram unificados porque aquele distingue automático de escolhido, o que
/// não tem sentido para um item.
enum GrantSource {
  /// Adicionado pelo jogador, na mão. É o padrão de todo item novo.
  manual('manual', 'Manual'),

  background('background', 'Antecedente'),
  characterClass('class', 'Classe'),
  race('race', 'Raça'),
  feat('feat', 'Talento'),
  magicItem('magic_item', 'Item mágico'),

  /// Origem conhecida mas fora da lista acima, ou gravada por uma versão mais
  /// nova do app.
  other('other', 'Outra origem');

  const GrantSource(this.id, this.label);

  final String id;
  final String label;

  /// `true` quando a origem é uma fonte automática, e não o próprio jogador.
  ///
  /// Só o que é automático pode ser removido por recálculo; o manual nunca é
  /// tocado.
  bool get isAutomatic => this != GrantSource.manual;

  static GrantSource? fromId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    final normalized = id.trim();
    for (final item in values) {
      if (item.id == normalized) return item;
    }
    return null;
  }

  /// Igual a [fromId], mas cai em [GrantSource.manual] no desconhecido.
  ///
  /// Cair em `manual` é a escolha segura: um recálculo nunca apaga item
  /// manual, então uma origem ilegível preserva o item em vez de arriscar
  /// perdê-lo.
  static GrantSource fromIdOrManual(String? id) =>
      fromId(id) ?? GrantSource.manual;
}
