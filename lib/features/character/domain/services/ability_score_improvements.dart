import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_ability_increases.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Uma distribuição de incremento em edição.
///
/// É imutável e cada toque devolve uma nova: a tela só guarda o rascunho e
/// pergunta a ele o que pode fazer. Toda a regra — quantos pontos, quantos
/// atributos, qual teto — fica aqui, e não no widget, porque o mesmo rascunho
/// precisa valer na criação, na evolução e na troca de um talento por um
/// incremento.
class AbilityScoreImprovementDraft {
  const AbilityScoreImprovementDraft({this.increases = const {}});

  /// Quanto o jogador já colocou em cada atributo.
  final Map<Ability, int> increases;

  /// Pontos que um incremento distribui.
  ///
  /// Dois, na regra de 2014: `+2` num atributo ou `+1` em dois diferentes.
  static const int points = 2;

  /// Quantos atributos diferentes um incremento pode tocar.
  static const int maxAbilities = 2;

  int get spent => increases.values.fold(0, (total, value) => total + value);

  int get remaining => points - spent;

  bool get isEmpty => spent == 0;

  /// Se a distribuição está fechada e pode ser confirmada.
  bool get isComplete => remaining == 0;

  int amountFor(Ability ability) => increases[ability] ?? 0;

  /// O valor que o atributo terá se a distribuição for confirmada.
  int previewFor(Ability ability, AbilityScores current) =>
      current.valueFor(ability) + amountFor(ability);

  /// Se dá para somar mais um ponto neste atributo.
  ///
  /// Recusa por três motivos diferentes, e cada um importa: pontos esgotados,
  /// teto do atributo alcançado, ou um terceiro atributo sendo tocado.
  bool canIncrement(
    Ability ability, {
    required AbilityScores current,
    Map<Ability, int> maximums = const {},
  }) {
    if (remaining <= 0) return false;

    final maximum = maximums[ability] ?? GrantedAbilityIncreases.maximum;
    if (previewFor(ability, current) >= maximum) return false;

    if (amountFor(ability) == 0 && increases.length >= maxAbilities) {
      return false;
    }

    return true;
  }

  /// Por que não dá para somar mais um ponto, ou `null` quando dá.
  ///
  /// Devolve texto porque a tela precisa EXPLICAR o bloqueio: um botão
  /// desabilitado sem motivo manda o jogador procurar o erro na própria
  /// cabeça.
  String? incrementBlockReason(
    Ability ability, {
    required AbilityScores current,
    Map<Ability, int> maximums = const {},
  }) {
    if (remaining <= 0) {
      return 'Os $points pontos deste incremento já foram distribuídos.';
    }

    final maximum = maximums[ability] ?? GrantedAbilityIncreases.maximum;
    if (previewFor(ability, current) >= maximum) {
      return '${ability.label} já está no máximo de $maximum.';
    }

    if (amountFor(ability) == 0 && increases.length >= maxAbilities) {
      return 'Um incremento toca no máximo $maxAbilities atributos: '
          '+$points em um, ou +1 em dois.';
    }

    return null;
  }

  AbilityScoreImprovementDraft increment(
    Ability ability, {
    required AbilityScores current,
    Map<Ability, int> maximums = const {},
  }) {
    if (!canIncrement(ability, current: current, maximums: maximums)) {
      return this;
    }

    return AbilityScoreImprovementDraft(
      increases: {...increases, ability: amountFor(ability) + 1},
    );
  }

  AbilityScoreImprovementDraft decrement(Ability ability) {
    final amount = amountFor(ability);
    if (amount <= 0) return this;

    final next = {...increases};
    if (amount == 1) {
      next.remove(ability);
    } else {
      next[ability] = amount - 1;
    }

    return AbilityScoreImprovementDraft(increases: next);
  }

  AbilityScoreImprovementDraft get cleared =>
      const AbilityScoreImprovementDraft();

  /// A distribuição no formato que o domínio persiste.
  Map<String, int> get asIncreaseMap => {
        for (final entry in increases.entries)
          if (entry.value > 0) entry.key.name: entry.value,
      };

  /// Resumo do que falta, para o rodapé da tela.
  String get progressLabel {
    if (isComplete) return 'Distribuição completa.';
    if (remaining == points) return 'Distribua $points pontos.';
    return remaining == 1 ? 'Falta 1 ponto.' : 'Faltam $remaining pontos.';
  }
}

/// Aplica e desfaz o Incremento no Valor de Atributo.
///
/// Reaproveita `GrantedAbilityIncreases` de propósito: a regra de "só entra o
/// que cabe até o teto, e é o que entrou que fica registrado" é a mesma do
/// talento, e duplicá-la aqui criaria duas verdades para o mesmo limite.
///
/// A diferença é o teto: o talento usa sempre 20, e o incremento aceita uma
/// exceção declarada por característica (Campeão Primal leva Força e
/// Constituição a 24). O teto chega por parâmetro, nunca de um `if` por
/// classe.
class AbilityScoreImprovements {
  const AbilityScoreImprovements._();

  /// Quanto de [wanted] realmente cabe, respeitando o teto de cada atributo.
  static Map<String, int> resolve({
    required AbilityScores current,
    required Map<String, int> wanted,
    Map<Ability, int> maximums = const {},
  }) {
    final applied = <String, int>{};

    for (final entry in wanted.entries) {
      final ability = Ability.fromName(entry.key);
      if (ability == null || entry.value <= 0) continue;

      final maximum = maximums[ability] ?? GrantedAbilityIncreases.maximum;
      final room = maximum - current.valueFor(ability);
      if (room <= 0) continue;

      applied[ability.name] = entry.value < room ? entry.value : room;
    }

    return applied;
  }

  /// Soma os aumentos nos atributos.
  static AbilityScores apply(
    AbilityScores current,
    Map<String, int> applied,
  ) => GrantedAbilityIncreases.apply(current, applied);

  /// Devolve exatamente o que o incremento havia somado.
  static AbilityScores revoke(
    AbilityScores current,
    Map<String, int> applied,
  ) => GrantedAbilityIncreases.revoke(current, applied);
}
