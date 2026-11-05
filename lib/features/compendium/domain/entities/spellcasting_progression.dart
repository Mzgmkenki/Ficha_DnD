/// Regras de progressão de conjuração, independentes de quem concede.
///
/// Existe porque a conjuração nem sempre vem da classe: o Trapaceiro Arcano e
/// o Cavaleiro Arcano a recebem da subclasse. Antes destas regras morarem num
/// lugar só, `ClassEntry` era a única dona delas, e a subclasse não tinha como
/// responder "isto conjura?" sem copiar o mesmo `switch`.
///
/// Os nomes são os mesmos dos assets (`spellcasting_type`), para o JSON
/// continuar legível sem tabela de tradução.
abstract final class SpellcastingProgression {
  /// Conjurador completo: Mago, Clérigo, Druida, Bardo, Feiticeiro.
  static const String full = 'full';

  /// Meio-conjurador: Paladino e Patrulheiro.
  static const String half = 'half';

  /// Um-terço-conjurador: Trapaceiro Arcano e Cavaleiro Arcano.
  static const String third = 'third';

  /// Magia de pacto do Bruxo, que corre por fora dos espaços normais.
  static const String pact = 'pact';

  /// Meio-conjurador que arredonda para cima e conjura desde o 1º nível.
  static const String artificer = 'artificer';

  static const List<String> all = [full, half, third, pact, artificer];

  /// O valor cru do asset reduzido à forma canônica, ou nulo se não for um
  /// tipo conhecido. Tolera espaço e caixa porque o JSON é escrito à mão.
  static String? normalize(String? raw) {
    final value = raw?.trim().toLowerCase();
    if (value == null || value.isEmpty) return null;
    return all.contains(value) ? value : null;
  }

  /// Se [raw] descreve alguma forma de conjuração.
  static bool isCasting(String? raw) => normalize(raw) != null;

  /// Nível, na classe que concede, a partir do qual a conjuração existe.
  ///
  /// Meio-conjuradores começam no 2º e um-terço-conjuradores no 3º. Zero
  /// quando não há conjuração nenhuma, para quem compara com `<`.
  static int startLevel(String? raw) {
    switch (normalize(raw)) {
      case half:
        return 2;
      case third:
        return 3;
      case full:
      case pact:
      // O artífice conjura desde o 1º nível, diferente dos outros
      // meio-conjuradores.
      case artificer:
        return 1;
      default:
        return 0;
    }
  }

  /// Nome da tabela de espaços, como aparece em `spell_slots.json`.
  static String tableLabel(String type) {
    switch (normalize(type)) {
      case full:
        return 'conjurador completo';
      case half:
        return 'meio conjurador';
      case artificer:
        return 'meio conjurador (artífice)';
      case third:
        return 'um-terço conjurador';
      case pact:
        return 'magia de pacto';
      default:
        return type;
    }
  }
}
