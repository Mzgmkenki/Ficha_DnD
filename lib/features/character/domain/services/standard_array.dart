import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Regras do conjunto padrão de atributos do Livro do Jogador (5e 2014).
class StandardArray {
  const StandardArray._();

  static const List<int> values = [15, 14, 13, 12, 10, 8];

  /// Valores ainda não atribuídos. Entradas inválidas não consomem o conjunto.
  static List<int> available(Map<Ability, int> assignments) {
    final used = assignments.values.where(values.contains).toSet();
    return values.where((value) => !used.contains(value)).toList();
  }

  /// Devolve uma mensagem de validação ou `null` quando a distribuição é
  /// completa e usa cada valor exatamente uma vez.
  static String? validationError(Map<Ability, int> assignments) {
    if (assignments.length != Ability.values.length ||
        Ability.values.any((ability) => !assignments.containsKey(ability))) {
      return 'Distribua um valor para cada um dos seis atributos.';
    }

    final assigned = assignments.values.toList()..sort();
    final expected = [...values]..sort();

    if (assigned.length != assigned.toSet().length) {
      return 'Cada valor do conjunto padrão só pode ser usado uma vez.';
    }

    for (var index = 0; index < expected.length; index++) {
      if (assigned[index] != expected[index]) {
        return 'Use somente os valores 15, 14, 13, 12, 10 e 8.';
      }
    }

    return null;
  }

  static bool isValid(Map<Ability, int> assignments) =>
      validationError(assignments) == null;

  static AbilityScores toAbilityScores(Map<Ability, int> assignments) {
    final error = validationError(assignments);
    if (error != null) throw ArgumentError(error);

    return AbilityScores(
      strength: assignments[Ability.strength]!,
      dexterity: assignments[Ability.dexterity]!,
      constitution: assignments[Ability.constitution]!,
      intelligence: assignments[Ability.intelligence]!,
      wisdom: assignments[Ability.wisdom]!,
      charisma: assignments[Ability.charisma]!,
    );
  }

  static Map<Ability, int> asMap(AbilityScores scores) => {
    for (final ability in Ability.values) ability: scores.valueFor(ability),
  };
}

/// Parcela persistida dos atributos de um personagem criado pelo conjunto
/// padrão. Personagens antigos podem não possuir esta informação.
class AbilityScoreAllocation {
  const AbilityScoreAllocation({
    required this.baseScores,
    this.originBonuses = const {},
  });

  final AbilityScores baseScores;
  final Map<Ability, int> originBonuses;

  int baseFor(Ability ability) => baseScores.valueFor(ability);

  int originBonusFor(Ability ability) => originBonuses[ability] ?? 0;

  AbilityScores totals({Map<Ability, int> otherBonuses = const {}}) {
    int total(Ability ability) =>
        baseFor(ability) +
        originBonusFor(ability) +
        (otherBonuses[ability] ?? 0);

    return AbilityScores(
      strength: total(Ability.strength),
      dexterity: total(Ability.dexterity),
      constitution: total(Ability.constitution),
      intelligence: total(Ability.intelligence),
      wisdom: total(Ability.wisdom),
      charisma: total(Ability.charisma),
    );
  }

  void validate({Map<Ability, int> otherBonuses = const {}}) {
    final error = StandardArray.validationError(
      StandardArray.asMap(baseScores),
    );
    if (error != null) throw ArgumentError(error);

    for (final entry in originBonuses.entries) {
      if (entry.value < 0) {
        throw ArgumentError(
          'Bônus de origem inválido para ${entry.key.label}.',
        );
      }
    }

    for (final entry in otherBonuses.entries) {
      if (entry.value < 0) {
        throw ArgumentError(
          'Bônus permanente inválido para ${entry.key.label}.',
        );
      }
    }
  }
}
