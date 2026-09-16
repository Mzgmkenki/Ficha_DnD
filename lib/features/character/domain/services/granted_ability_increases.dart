import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Aumento de atributo concedido por uma fonte da ficha — hoje, talento.
///
/// Espelha `GrantedSkills` de propósito, inclusive nos nomes: a fonte pede um
/// aumento, o serviço decide quanto realmente cabe, e é esse valor que fica
/// guardado junto com a fonte. Sem registrar o que de fato entrou, remover o
/// talento não teria como saber o que devolver — o mesmo problema que
/// `grantedSkillIds` resolve para perícia.
class GrantedAbilityIncreases {
  const GrantedAbilityIncreases._();

  /// Teto que a regra impõe a aumento por talento ou incremento de nível.
  ///
  /// [AbilityScores] aceita até 30 porque monstro e magia passam de 20; o 20
  /// aqui é o limite de quem *sobe* atributo, que é caso diferente.
  static const int maximum = 20;

  /// O que o talento pede: os aumentos fixos dele mais o atributo que o
  /// jogador escolheu, quando havia escolha.
  ///
  /// A escolha vale +1 — é assim em todos os talentos do compêndio, e deixar a
  /// conta num só lugar evita que cada chamador repita o número.
  static Map<String, int> wanted({
    required Map<String, int> fixed,
    Ability? chosen,
  }) {
    final result = <String, int>{...fixed};

    if (chosen != null) {
      // Soma em vez de sobrescrever: um talento pode dar +1 fixo num atributo
      // e ainda deixar escolher, e cair no mesmo atributo vale +2.
      result[chosen.name] = (result[chosen.name] ?? 0) + 1;
    }

    return result;
  }

  /// De [wanted], quanto realmente cabe em cada atributo.
  ///
  /// É o análogo de `GrantedSkills.newlyGranted`: o que precisa ser guardado
  /// junto com a fonte para poder ser desfeito. Atributo já no teto rende
  /// zero, e zero não entra no mapa — assim remover o talento depois não
  /// subtrai um aumento que nunca aconteceu.
  static Map<String, int> resolve(
    AbilityScores current,
    Map<String, int> wanted,
  ) {
    final applied = <String, int>{};

    for (final entry in wanted.entries) {
      // Nome fora dos seis atributos vem de dado escrito à mão no compêndio;
      // ignorar é melhor que derrubar a ficha.
      final ability = Ability.fromName(entry.key);
      if (ability == null || entry.value <= 0) continue;

      final room = maximum - current.valueFor(ability);
      if (room <= 0) continue;

      applied[ability.name] = entry.value < room ? entry.value : room;
    }

    return applied;
  }

  /// Soma [applied] nos atributos.
  static AbilityScores apply(
    AbilityScores current,
    Map<String, int> applied,
  ) {
    return _shift(current, applied, sign: 1);
  }

  /// Devolve o que [applied] havia somado.
  ///
  /// Subtrai o valor registrado, sem tentar adivinhar se o jogador mexeu no
  /// atributo à mão depois. É o mesmo espírito de `GrantedSkills.revoke`: a
  /// fonte desfaz o que ela fez, e o que veio de outro lugar fica.
  static AbilityScores revoke(
    AbilityScores current,
    Map<String, int> applied,
  ) {
    return _shift(current, applied, sign: -1);
  }

  static AbilityScores _shift(
    AbilityScores current,
    Map<String, int> amounts, {
    required int sign,
  }) {
    var result = current;

    for (final entry in amounts.entries) {
      final ability = Ability.fromName(entry.key);
      if (ability == null || entry.value <= 0) continue;

      // O clamp é pela faixa que [AbilityScores] aceita, não pelo teto de 20:
      // `resolve` já cuidou da regra, e aqui o que importa é não estourar o
      // assert do value object com um mapa vindo de ficha importada.
      final target = result.valueFor(ability) + sign * entry.value;
      result = result.withValue(ability, target.clamp(1, 30));
    }

    return result;
  }

  /// Serializa como CSV `atributo:valor`, para a coluna de texto do banco.
  static String toCsv(Map<String, int> increases) {
    return increases.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join(',');
  }

  /// Lê o CSV guardado no banco, tolerando nulo, vazio, espaço solto, par
  /// malformado e atributo desconhecido.
  static Map<String, int> parseCsv(String? raw) {
    if (raw == null) return const {};

    final result = <String, int>{};

    for (final part in raw.split(',')) {
      final pair = part.split(':');
      if (pair.length != 2) continue;

      final ability = Ability.fromName(pair.first.trim());
      final amount = int.tryParse(pair.last.trim());
      if (ability == null || amount == null || amount <= 0) continue;

      result[ability.name] = amount;
    }

    return result;
  }
}
