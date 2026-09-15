import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';

/// Espaços de magia que o personagem tem, resolvidos a partir das classes.
class SpellSlotSummary {
  const SpellSlotSummary({
    required this.hasAnyCasting,
    this.standardSlots,
    this.pactSlots,
    this.modeLabel,
    this.explanation,
    this.effectiveCasterLevel = 0,
  });

  /// Falso quando nenhuma das classes conjura. Diferente de conjurar e ainda
  /// não ter espaços, que é o caso do paladino de 1º nível.
  final bool hasAnyCasting;

  /// Linha da tabela de espaços normais, ou nulo quando não há.
  final SpellSlotProgressionEntry? standardSlots;

  /// Espaços de pacto do bruxo, que correm por fora dos normais.
  final SpellSlotProgressionEntry? pactSlots;

  final String? modeLabel;
  final String? explanation;

  /// Nível de conjuração usado na tabela de multiclasse.
  final int effectiveCasterLevel;
}

/// Resolve quantos espaços de magia o personagem tem.
///
/// A regra que justifica este serviço existir é o arredondamento do
/// multiclasse: ele acontece POR CLASSE, não sobre a soma dos níveis. Paladino
/// 3 + Patrulheiro 3 dá 1 + 1 = 2 níveis de conjuração, não 6 ÷ 2 = 3.
class SpellSlotCalculator {
  const SpellSlotCalculator._();

  /// Teto das tabelas de progressão.
  static const int maxTableLevel = 20;

  static SpellSlotSummary summarize({
    required List<ClassLevel> classLevels,
    required List<ClassEntry> classes,
    required List<SpellSlotProgressionEntry> progressions,
  }) {
    ClassEntry? classForId(String id) {
      for (final item in classes) {
        if (item.id == id) return item;
      }
      return null;
    }

    SpellSlotProgressionEntry? findRow(String tableId, int level) {
      for (final row in progressions) {
        if (row.tableId == tableId && row.level == level) return row;
      }
      return null;
    }

    var fullCasterLevels = 0;
    var halfCasterLevels = 0;
    var thirdCasterLevels = 0;
    var halfContribution = 0;
    var thirdContribution = 0;
    var pactLevels = 0;
    var castingClassCount = 0;

    for (final classLevel in classLevels) {
      switch (classForId(classLevel.classId)?.spellcastingType) {
        case 'full':
          fullCasterLevels += classLevel.level;
          castingClassCount++;
        case 'half':
          halfCasterLevels += classLevel.level;
          halfContribution += classLevel.level ~/ 2;
          castingClassCount++;
        case 'artificer':
          halfCasterLevels += classLevel.level;
          // O artífice é o único meio-conjurador que arredonda para cima.
          halfContribution += (classLevel.level + 1) ~/ 2;
          castingClassCount++;
        case 'third':
          thirdCasterLevels += classLevel.level;
          thirdContribution += classLevel.level ~/ 3;
          castingClassCount++;
        case 'pact':
          pactLevels += classLevel.level;
          castingClassCount++;
      }
    }

    if (castingClassCount == 0) {
      return const SpellSlotSummary(hasAnyCasting: false);
    }

    final nonPactPresent =
        fullCasterLevels > 0 || halfCasterLevels > 0 || thirdCasterLevels > 0;

    SpellSlotProgressionEntry? standardSlots;
    SpellSlotProgressionEntry? pactSlots;
    String? modeLabel;
    String? explanation;
    var effectiveCasterLevel = 0;

    if (classLevels.length == 1) {
      final classLevel = classLevels.first;
      final classEntry = classForId(classLevel.classId);
      final type = classEntry?.spellcastingType;

      if (type == 'full' ||
          type == 'half' ||
          type == 'third' ||
          type == 'artificer') {
        standardSlots = findRow(type!, classLevel.level);
        effectiveCasterLevel = classLevel.level;
        modeLabel = 'Progressão de ${classEntry?.name ?? classLevel.classId}';
        explanation = 'Tabela usada: ${tableLabel(type)}, '
            'nível de conjuração: ${classLevel.level}';
      } else if (type == 'pact') {
        pactSlots = findRow('pact', classLevel.level);
        effectiveCasterLevel = classLevel.level;
        modeLabel = 'Magia de Pacto';
        explanation = 'Bruxo usa progressão própria de slots de pacto.';
      }
    } else {
      if (nonPactPresent) {
        effectiveCasterLevel =
            fullCasterLevels + halfContribution + thirdContribution;

        if (effectiveCasterLevel > 0) {
          standardSlots = findRow(
            'multiclass',
            effectiveCasterLevel > maxTableLevel
                ? maxTableLevel
                : effectiveCasterLevel,
          );
          modeLabel = 'Progressão multiclasses de conjuração';
          explanation = 'Nível efetivo de conjuração: $effectiveCasterLevel '
              '(inteiros = $fullCasterLevels, meio = $halfContribution, '
              'um-terço = $thirdContribution).';
        } else {
          // Paladino 1 / Guerreiro 1, por exemplo: conjura, mas ainda não tem
          // espaço nenhum. Dizer o motivo é melhor que um painel vazio.
          modeLabel = 'Ainda sem slots de magia';
          explanation = 'Meio-conjuradores começam a conjurar no nível 2 e '
              'um-terço-conjuradores no nível 3.';
        }
      }

      if (pactLevels > 0) {
        pactSlots = findRow(
          'pact',
          pactLevels > maxTableLevel ? maxTableLevel : pactLevels,
        );
      }

      if (pactLevels > 0 && nonPactPresent) {
        explanation = '${explanation ?? ''} Magia de Pacto permanece separada '
            'dos slots normais.';
      } else if (pactLevels > 0 && !nonPactPresent) {
        modeLabel = 'Magia de Pacto';
        explanation = 'Bruxo usa progressão própria de slots de pacto.';
      }
    }

    return SpellSlotSummary(
      hasAnyCasting: true,
      standardSlots: standardSlots,
      pactSlots: pactSlots,
      modeLabel: modeLabel,
      explanation: explanation,
      effectiveCasterLevel: effectiveCasterLevel,
    );
  }

  /// Espaços por círculo de uma linha da tabela, só os círculos com espaço.
  static Map<int, int> slotsByLevel(SpellSlotProgressionEntry row) {
    final all = <int, int>{
      1: row.first,
      2: row.second,
      3: row.third,
      4: row.fourth,
      5: row.fifth,
      6: row.sixth,
      7: row.seventh,
      8: row.eighth,
      9: row.ninth,
    };

    return {
      for (final entry in all.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
  }

  static String tableLabel(String type) {
    switch (type) {
      case 'full':
        return 'conjurador completo';
      case 'half':
        return 'meio conjurador';
      case 'artificer':
        return 'meio conjurador (artífice)';
      case 'third':
        return 'um-terço conjurador';
      case 'pact':
        return 'magia de pacto';
      default:
        return type;
    }
  }
}
