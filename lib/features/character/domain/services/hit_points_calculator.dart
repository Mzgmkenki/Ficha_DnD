import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';

/// Um dado de vida disponível ao personagem (ex.: 3 x d10).
class HitDiceGroup {
  const HitDiceGroup({
    required this.dieSize,
    required this.quantity,
  });

  final int dieSize;
  final int quantity;

  String get label => '${quantity}d$dieSize';
}

/// Cálculo de pontos de vida conforme as regras de 5e.
class HitPointsCalculator {
  const HitPointsCalculator._();

  /// Converte "d10" (ou "D10", "10") no inteiro 10.
  static int parseDieSize(String? hitDie) {
    if (hitDie == null) return 8;
    final normalized = hitDie.toLowerCase().replaceAll('d', '').trim();
    return int.tryParse(normalized) ?? 8;
  }

  /// PV máximo usando a média fixa por nível, que é a opção mais comum em
  /// mesa por ser determinística.
  ///
  /// Regra: no 1º nível da classe inicial usa-se o valor MÁXIMO do dado;
  /// nos níveis seguintes soma-se a média arredondada para cima
  /// (`dado / 2 + 1`). O modificador de Constituição entra em CADA nível.
  ///
  /// [classLevels] deve estar na ordem em que as classes foram adquiridas —
  /// a primeira é a classe inicial.
  static int maxHitPoints({
    required List<ClassLevel> classLevels,
    required AbilityScores abilityScores,
    required int Function(String classId) dieSizeForClass,
  }) {
    if (classLevels.isEmpty) return 1;

    final conModifier = abilityScores.constitution.abilityModifier;
    var total = 0;
    var isFirstLevelOverall = true;

    for (final classLevel in classLevels) {
      final die = dieSizeForClass(classLevel.classId);
      final averagePerLevel = (die ~/ 2) + 1;

      for (var i = 0; i < classLevel.level; i++) {
        if (isFirstLevelOverall) {
          total += die + conModifier;
          isFirstLevelOverall = false;
        } else {
          total += averagePerLevel + conModifier;
        }
      }
    }

    // Um personagem nunca fica com menos de 1 PV por nível.
    final minimum = classLevels.fold<int>(0, (sum, c) => sum + c.level);
    return total < minimum ? minimum : total;
  }

  /// Conveniência quando se tem a lista de classes do compêndio.
  static int maxHitPointsFromEntries({
    required List<ClassLevel> classLevels,
    required AbilityScores abilityScores,
    required List<ClassEntry> classes,
  }) {
    return maxHitPoints(
      classLevels: classLevels,
      abilityScores: abilityScores,
      dieSizeForClass: (classId) {
        for (final entry in classes) {
          if (entry.id == classId) return parseDieSize(entry.hitDie);
        }
        return 8;
      },
    );
  }

  /// Dados de vida totais do personagem, agrupados por tamanho de dado.
  static List<HitDiceGroup> hitDicePool({
    required List<ClassLevel> classLevels,
    required List<ClassEntry> classes,
  }) {
    final byDie = <int, int>{};

    for (final classLevel in classLevels) {
      var die = 8;
      for (final entry in classes) {
        if (entry.id == classLevel.classId) {
          die = parseDieSize(entry.hitDie);
          break;
        }
      }
      byDie[die] = (byDie[die] ?? 0) + classLevel.level;
    }

    final groups = byDie.entries
        .map((e) => HitDiceGroup(dieSize: e.key, quantity: e.value))
        .toList();

    groups.sort((a, b) => b.dieSize.compareTo(a.dieSize));
    return groups;
  }

  /// Quantos dados de vida o personagem recupera num descanso longo:
  /// metade do total, no mínimo 1 (PHB).
  static int hitDiceRecoveredOnLongRest(int totalHitDice) {
    final half = totalHitDice ~/ 2;
    return half < 1 ? 1 : half;
  }
}
