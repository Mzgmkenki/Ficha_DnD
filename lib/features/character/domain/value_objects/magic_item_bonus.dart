/// Como um item mágico declara o bônus que concede.
///
/// Antes cada efeito tinha um campo numérico livre, e nada impedia um `+7` ou
/// um texto inválido. Aqui o bônus é um degrau fechado ([MagicItemBonus]) e as
/// estatísticas que ele afeta são uma escolha explícita
/// ([MagicItemBonusTarget]). A separação continua sendo o ponto principal: uma
/// arma `+1` afeta ataque e dano dela, e só mexe em ataque mágico ou CD se a
/// descrição do item mandar.
library;

/// O bônus mágico de um item: nenhum, `+1`, `+2` ou `+3`.
///
/// São os degraus que as regras usam. Fora deles não existe item padrão, e
/// deixar digitar livre só abria espaço para erro de digitação virar vantagem
/// mecânica.
enum MagicItemBonus {
  none(0, 'Sem bônus'),
  plusOne(1, '+1'),
  plusTwo(2, '+2'),
  plusThree(3, '+3');

  const MagicItemBonus(this.value, this.label);

  /// Quanto o degrau soma.
  final int value;

  /// Como aparece no seletor e na ficha.
  final String label;

  bool get isNone => this == MagicItemBonus.none;

  /// O degrau correspondente ao número, ou nulo se o número não for um deles.
  ///
  /// Nulo em vez de exceção porque a entrada vem do banco e de arquivo
  /// importado: um valor fora da faixa precisa ser tratado, não derrubar a
  /// leitura da ficha.
  static MagicItemBonus? tryFromValue(int? value) {
    if (value == null) return null;

    for (final bonus in MagicItemBonus.values) {
      if (bonus.value == value) return bonus;
    }

    return null;
  }

  /// Igual a [tryFromValue], caindo em [none] quando não reconhece.
  static MagicItemBonus fromValue(int? value) =>
      tryFromValue(value) ?? MagicItemBonus.none;
}

/// Qual estatística o bônus do item afeta.
///
/// Um item pode afetar mais de uma — um foco mágico que dá `+1` no ataque
/// mágico e `+1` na CD marca as duas. O que ele não faz é afetar todas por
/// padrão: é exatamente isso que impedia um Escudo `+1` de aumentar a CD das
/// magias.
enum MagicItemBonusTarget {
  weaponAttack('weaponAttack', 'Ataque com arma', 'no ataque com arma'),
  weaponDamage('weaponDamage', 'Dano com arma', 'no dano com arma'),
  spellAttack('spellAttack', 'Ataque mágico', 'no ataque mágico'),
  spellSaveDc('spellSaveDc', 'CD de magia', 'na CD das magias');

  const MagicItemBonusTarget(this.id, this.label, this.phrase);

  /// Identificador estável, gravado no banco e no arquivo exportado.
  ///
  /// Separado do `name` do enum de propósito, como em `Condition`: renomear o
  /// valor em Dart não pode invalidar o que já está salvo.
  final String id;

  /// Rótulo curto, para caixa de seleção e etiqueta.
  final String label;

  /// Trecho para montar frase: `+1 no ataque com arma`.
  final String phrase;

  static MagicItemBonusTarget? fromId(String? id) {
    if (id == null) return null;

    for (final target in MagicItemBonusTarget.values) {
      if (target.id == id) return target;
    }

    return null;
  }

  /// Ids separados por vírgula, no formato gravado na coluna do banco.
  ///
  /// Mesma escolha de `Condition.toCsv`: vocabulário pequeno e fixo, sempre
  /// lido e escrito inteiro, então não vale uma tabela filha. A ordem do enum
  /// mantém o CSV estável entre gravações.
  static String toCsv(Set<MagicItemBonusTarget> targets) {
    return MagicItemBonusTarget.values
        .where(targets.contains)
        .map((target) => target.id)
        .join(',');
  }

  /// Lê o CSV, descartando em silêncio o que não reconhecer.
  static Set<MagicItemBonusTarget> parseCsv(String? raw) {
    if (raw == null || raw.isEmpty) return const {};

    final result = <MagicItemBonusTarget>{};
    for (final part in raw.split(',')) {
      final target = fromId(part.trim());
      if (target != null) result.add(target);
    }

    return result;
  }

  /// Ordenadas como o enum declara, que é a ordem mostrada na interface.
  static List<MagicItemBonusTarget> get ordered =>
      List.unmodifiable(MagicItemBonusTarget.values);
}

/// Os quatro valores livres do formato antigo, guardados como estavam.
///
/// Existe só para o item que não cabe no formato controlado: bônus negativo de
/// item maldito, valor acima de `+3`, ou valores diferentes entre as
/// estatísticas. Nesses casos o número original continua valendo e continua
/// aparecendo, com aviso de revisão — perder o efeito em silêncio seria pior
/// que manter um dado fora do padrão.
class LegacyMagicItemBonuses {
  const LegacyMagicItemBonuses({
    this.weaponAttack = 0,
    this.weaponDamage = 0,
    this.spellAttack = 0,
    this.spellSaveDc = 0,
  });

  final int weaponAttack;
  final int weaponDamage;
  final int spellAttack;
  final int spellSaveDc;

  int valueFor(MagicItemBonusTarget target) {
    switch (target) {
      case MagicItemBonusTarget.weaponAttack:
        return weaponAttack;
      case MagicItemBonusTarget.weaponDamage:
        return weaponDamage;
      case MagicItemBonusTarget.spellAttack:
        return spellAttack;
      case MagicItemBonusTarget.spellSaveDc:
        return spellSaveDc;
    }
  }

  bool get isEmpty =>
      weaponAttack == 0 &&
      weaponDamage == 0 &&
      spellAttack == 0 &&
      spellSaveDc == 0;

  Set<MagicItemBonusTarget> get targets {
    return {
      for (final target in MagicItemBonusTarget.values)
        if (valueFor(target) != 0) target,
    };
  }

  /// `+1 no ataque com arma, -1 na CD das magias`, para o aviso de revisão.
  String describe() {
    final parts = <String>[
      for (final target in MagicItemBonusTarget.values)
        if (valueFor(target) != 0)
          '${_signed(valueFor(target))} ${target.phrase}',
    ];

    return parts.join(', ');
  }

  static String _signed(int value) => value >= 0 ? '+$value' : '$value';

  @override
  bool operator ==(Object other) {
    return other is LegacyMagicItemBonuses &&
        other.weaponAttack == weaponAttack &&
        other.weaponDamage == weaponDamage &&
        other.spellAttack == spellAttack &&
        other.spellSaveDc == spellSaveDc;
  }

  @override
  int get hashCode =>
      Object.hash(weaponAttack, weaponDamage, spellAttack, spellSaveDc);

  @override
  String toString() => 'LegacyMagicItemBonuses(${describe()})';
}

/// Resultado da conversão do formato antigo para o controlado.
class MagicItemBonusConversion {
  const MagicItemBonusConversion({
    required this.bonus,
    required this.targets,
    this.legacy,
  });

  final MagicItemBonus bonus;
  final Set<MagicItemBonusTarget> targets;

  /// Preenchido só quando os valores antigos não cabem no formato novo.
  final LegacyMagicItemBonuses? legacy;

  bool get needsReview => legacy != null;
}

/// Converte os quatro campos livres antigos no bônus controlado.
///
/// Converte só o que é representável: todos os valores não-zero iguais e
/// dentro de `+1`..`+3`. Um Cajado `+2` que somava 2 no ataque mágico e 2 na CD
/// vira `+2` com as duas estatísticas marcadas, sem perguntar nada ao jogador.
///
/// O resto é preservado para revisão em vez de ser arredondado ou descartado:
/// bônus negativo (item maldito), acima de `+3`, ou valores diferentes entre
/// estatísticas (`+1` no ataque e `+2` no dano) não têm representação no
/// formato novo, e escolher um deles por conta própria mudaria a ficha do
/// jogador sem aviso.
MagicItemBonusConversion convertLegacyMagicItemBonuses({
  required int weaponAttack,
  required int weaponDamage,
  required int spellAttack,
  required int spellSaveDc,
}) {
  final legacy = LegacyMagicItemBonuses(
    weaponAttack: weaponAttack,
    weaponDamage: weaponDamage,
    spellAttack: spellAttack,
    spellSaveDc: spellSaveDc,
  );

  if (legacy.isEmpty) {
    return const MagicItemBonusConversion(
      bonus: MagicItemBonus.none,
      targets: {},
    );
  }

  final targets = legacy.targets;
  final values = targets.map(legacy.valueFor).toSet();

  if (values.length == 1) {
    final bonus = MagicItemBonus.tryFromValue(values.single);

    // `none` não entra aqui: um valor não-zero nunca converte para "sem
    // bônus", e se convertesse o item perderia o efeito.
    if (bonus != null && !bonus.isNone) {
      return MagicItemBonusConversion(bonus: bonus, targets: targets);
    }
  }

  return MagicItemBonusConversion(
    bonus: MagicItemBonus.none,
    targets: targets,
    legacy: legacy,
  );
}
