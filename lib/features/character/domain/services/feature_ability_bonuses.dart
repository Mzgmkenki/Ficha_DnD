import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_ability_increases.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Aumento permanente de atributo concedido por característica de classe.
///
/// Espelha `GrantedAbilityIncreases`, inclusive na ideia central: a fonte pede
/// um aumento, o serviço decide quanto realmente cabe, e é esse valor que fica
/// guardado. A diferença é só de quem é a fonte — aqui ela é derivada do
/// compêndio a cada leitura, e não escolhida pelo jogador.
///
/// O caso do levantamento é o Campeão Primal: ao chegar ao 20º nível de
/// Bárbaro, Força e Constituição sobem 4 cada e o teto dos dois passa a 24.
///
/// Por que reconciliar em vez de aplicar e esquecer: o nível sobe e desce. Um
/// `apply` solto reaplicaria o +4 a cada abertura da ficha, e um `revoke` solto
/// não saberia quanto devolver se o compêndio mudasse. Comparar o que a regra
/// concede HOJE com o que a ficha JÁ TEM aplicado resolve os dois: a operação
/// fica idempotente e reversível por construção, sem o chamador precisar saber
/// se é a primeira vez.
class FeatureAbilityBonuses {
  const FeatureAbilityBonuses._();

  /// Acerta o personagem para que os bônus de característica aplicados sejam
  /// exatamente [granted].
  ///
  /// [granted] é o que as características ALCANÇADAS concedem, vindo de
  /// `ResolvedFeatures.abilityBonuses` — já cortado pelo nível da classe, e
  /// por isso um personagem de nível total 20 com 19 níveis de Bárbaro chega
  /// aqui com o mapa vazio.
  ///
  /// [maximums] é o teto por atributo, vindo de
  /// `ResolvedFeatures.abilityMaximums`. Precisa ser o teto JÁ COM as exceções
  /// da própria característica: é o Campeão Primal que leva o limite a 24, e
  /// sem isso o +4 dele não teria para onde ir.
  ///
  /// Devolve o próprio [character] quando nada muda, e isso é intencional: o
  /// chamador compara por identidade para não gravar à toa nem remontar o
  /// agregado a cada abertura da ficha.
  static Character reconcile({
    required Character character,
    required Map<Ability, int> granted,
    Map<Ability, int> maximums = const {},
  }) {
    final applied = character.featureAbilityBonuses;

    // O total sem a contribuição desta fonte. É contra ele que a folga é
    // medida, senão o que já foi aplicado contaria duas vezes e o aumento
    // encolheria a cada reconciliação.
    final baseline = _shift(character.abilityScores, applied, sign: -1);

    final target = <Ability, int>{};
    for (final ability in Ability.values) {
      final wanted = granted[ability] ?? 0;
      if (wanted <= 0) continue;

      final maximum = maximums[ability] ?? GrantedAbilityIncreases.maximum;
      final room = maximum - baseline.valueFor(ability);
      if (room <= 0) continue;

      // Não passa do teto, e também não reduz nada: o atributo que já está
      // acima por outra fonte simplesmente não recebe mais.
      target[ability] = wanted < room ? wanted : room;
    }

    if (_sameMap(applied, target)) return character;

    // Aplica a DIFERENÇA, não o total: o que veio de raça, talento, incremento
    // ou item fica onde está.
    final delta = <Ability, int>{};
    for (final ability in Ability.values) {
      final change = (target[ability] ?? 0) - (applied[ability] ?? 0);
      if (change != 0) delta[ability] = change;
    }

    var scores = character.abilityScores;
    for (final entry in delta.entries) {
      final value = scores.valueFor(entry.key) + entry.value;
      scores = scores.withValue(entry.key, value.clamp(1, 30));
    }

    return character.copyWith(
      abilityScores: scores,
      featureAbilityBonuses: Map<Ability, int>.unmodifiable(target),
    );
  }

  /// Serializa como CSV `atributo:valor`, para a coluna de texto do banco.
  ///
  /// Mesmo formato de `GrantedAbilityIncreases.toCsv`, e de propósito: é o
  /// formato que `baseAbilityScores` e `originAbilityBonuses` já usam na mesma
  /// tabela.
  static String? toCsv(Map<Ability, int> bonuses) {
    if (bonuses.isEmpty) return null;

    return bonuses.entries
        .where((entry) => entry.value != 0)
        .map((entry) => '${entry.key.name}:${entry.value}')
        .join(',');
  }

  /// Lê o CSV guardado no banco, tolerando nulo, vazio, par malformado e
  /// atributo desconhecido.
  static Map<Ability, int> parseCsv(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const {};

    final result = <Ability, int>{};

    for (final part in raw.split(',')) {
      final pair = part.split(':');
      if (pair.length != 2) continue;

      final ability = Ability.fromName(pair.first.trim());
      final amount = int.tryParse(pair.last.trim());
      if (ability == null || amount == null || amount == 0) continue;

      result[ability] = amount;
    }

    return result;
  }

  /// Lê um mapa de exportação, com nome de atributo como chave.
  static Map<Ability, int> parseMap(Object? raw) {
    if (raw is! Map) return const {};

    final result = <Ability, int>{};

    for (final entry in raw.entries) {
      final ability = Ability.fromName(entry.key?.toString().trim());
      if (ability == null) continue;

      final value = entry.value;
      final amount =
          value is int ? value : int.tryParse(value?.toString() ?? '');
      if (amount == null || amount == 0) continue;

      result[ability] = amount;
    }

    return result;
  }

  static bool _sameMap(Map<Ability, int> a, Map<Ability, int> b) {
    for (final ability in Ability.values) {
      if ((a[ability] ?? 0) != (b[ability] ?? 0)) return false;
    }
    return true;
  }

  static AbilityScores _shift(
    AbilityScores scores,
    Map<Ability, int> amounts, {
    required int sign,
  }) {
    var result = scores;

    for (final entry in amounts.entries) {
      if (entry.value == 0) continue;
      final value = result.valueFor(entry.key) + sign * entry.value;
      result = result.withValue(entry.key, value.clamp(1, 30));
    }

    return result;
  }
}
