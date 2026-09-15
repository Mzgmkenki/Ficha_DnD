import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';

/// Um bloco de efeitos vindo de uma única origem: uma condição ou a exaustão.
class ActiveEffect {
  const ActiveEffect({
    required this.source,
    required this.effects,
    this.impliedBy,
  });

  /// Nome da origem, como aparece na ficha.
  final String source;

  final List<String> effects;

  /// Quando a origem não foi marcada pelo jogador e sim arrastada por outra
  /// condição, guarda o rótulo de quem a arrastou.
  ///
  /// A ficha usa isso para explicar por que "Incapacitado" está na lista sem
  /// que ninguém tenha marcado a caixa.
  final String? impliedBy;

  bool get isImplied => impliedBy != null;
}

/// Junta num só lugar tudo que está afetando o personagem.
///
/// Existe porque as duas metades do problema moram em campos diferentes
/// (`conditions` e `exhaustion`) e o jogador precisa ler as duas de uma vez,
/// em combate, sem abrir o livro nem somar níveis de cabeça.
class ActiveEffects {
  const ActiveEffects._();

  /// Efeitos da exaustão até [level], acumulados.
  ///
  /// A tabela do PHB é cumulativa: o nível 3 sofre o efeito do 3, do 2 e do 1.
  /// Mostrar só o efeito do nível atual, como a ficha fazia antes, escondia a
  /// desvantagem em testes e o deslocamento pela metade.
  static const List<String> _exhaustionByLevel = [
    'Desvantagem em testes de atributo.',
    'Deslocamento reduzido à metade.',
    'Desvantagem em ataques e em salvaguardas.',
    'Pontos de vida máximos reduzidos à metade.',
    'Deslocamento reduzido a zero.',
    'Morte.',
  ];

  static const int maxExhaustion = 6;

  /// Efeitos acumulados do nível 1 até [level]. Vazio no nível 0.
  static List<String> exhaustionEffectsUpTo(int level) {
    final safe = level.clamp(0, maxExhaustion);
    if (safe <= 0) return const [];

    return _exhaustionByLevel.sublist(0, safe);
  }

  /// Efeito que o nível [level] acrescenta, sem os anteriores.
  ///
  /// Serve para rotular cada degrau do controle de exaustão.
  static String? exhaustionEffectAt(int level) {
    if (level < 1 || level > maxExhaustion) return null;
    return _exhaustionByLevel[level - 1];
  }

  /// Monta a lista completa, na ordem em que a ficha mostra: as condições
  /// marcadas pelo jogador, depois as arrastadas por elas, depois a exaustão.
  static List<ActiveEffect> from({
    required Set<Condition> conditions,
    required int exhaustion,
  }) {
    final result = <ActiveEffect>[];

    // Ordena pelo rótulo para a lista não dançar conforme a ordem de marcação.
    final chosen = Condition.sortedByLabel
        .where(conditions.contains)
        .toList(growable: false);

    for (final condition in chosen) {
      result.add(
        ActiveEffect(source: condition.label, effects: condition.effects),
      );
    }

    // As implicadas entram depois, e só se o jogador não as marcou direto:
    // repetir "Incapacitado" duas vezes seria ruído.
    final implied = <Condition, String>{};
    for (final condition in chosen) {
      for (final extra in condition.implies) {
        if (conditions.contains(extra)) continue;
        implied.putIfAbsent(extra, () => condition.label);
      }
    }

    for (final condition in Condition.sortedByLabel) {
      final by = implied[condition];
      if (by == null) continue;

      result.add(
        ActiveEffect(
          source: condition.label,
          effects: condition.effects,
          impliedBy: by,
        ),
      );
    }

    final exhaustionEffects = exhaustionEffectsUpTo(exhaustion);
    if (exhaustionEffects.isNotEmpty) {
      result.add(
        ActiveEffect(
          source: 'Exaustão (nível ${exhaustion.clamp(0, maxExhaustion)})',
          effects: exhaustionEffects,
        ),
      );
    }

    return result;
  }
}
