import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/spell_slot_calculator.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:flutter_test/flutter_test.dart';

ClassEntry _classEntry(String id, String name, String? casting) {
  return ClassEntry(
    id: id,
    name: name,
    hitDie: 'd8',
    source: 'srd',
    skillOptions: const [],
    savingThrows: const [],
    spellcastingType: casting,
  );
}

final _classes = [
  _classEntry('wizard', 'Mago', 'full'),
  _classEntry('cleric', 'Clérigo', 'full'),
  _classEntry('paladin', 'Paladino', 'half'),
  _classEntry('ranger', 'Patrulheiro', 'half'),
  _classEntry('artificer', 'Artífice', 'artificer'),
  _classEntry('rogue_arcane', 'Trapaceiro Arcano', 'third'),
  _classEntry('warlock', 'Bruxo', 'pact'),
  _classEntry('fighter', 'Guerreiro', null),
];

/// Linha sintética: o valor de `first` guarda o nível, para o teste conseguir
/// afirmar QUAL linha foi escolhida sem depender da tabela real do compêndio.
SpellSlotProgressionEntry _row(String tableId, int level) {
  return SpellSlotProgressionEntry(
    tableId: tableId,
    level: level,
    first: level,
    second: 0,
    third: 0,
    fourth: 0,
    fifth: 0,
    sixth: 0,
    seventh: 0,
    eighth: 0,
    ninth: 0,
  );
}

final _progressions = [
  for (final table in const [
    'full',
    'half',
    'third',
    'artificer',
    'pact',
    'multiclass',
  ])
    for (var level = 1; level <= 20; level++) _row(table, level),
];

SpellSlotSummary _summarize(List<ClassLevel> levels) {
  return SpellSlotCalculator.summarize(
    classLevels: levels,
    classes: _classes,
    progressions: _progressions,
  );
}

void main() {
  group('sem conjuração', () {
    test('classe que não conjura não tem espaços', () {
      final result = _summarize(const [
        ClassLevel(classId: 'fighter', level: 10),
      ]);

      expect(result.hasAnyCasting, isFalse);
      expect(result.standardSlots, isNull);
      expect(result.pactSlots, isNull);
    });
  });

  group('classe única', () {
    test('conjurador completo usa a própria tabela no próprio nível', () {
      final result = _summarize(const [
        ClassLevel(classId: 'wizard', level: 7),
      ]);

      expect(result.hasAnyCasting, isTrue);
      expect(result.standardSlots?.tableId, 'full');
      expect(result.standardSlots?.level, 7);
      expect(result.effectiveCasterLevel, 7);
    });

    test('meio-conjurador usa a tabela de meio, sem dividir o nível', () {
      // Numa classe só a tabela já embute a progressão, então o nível entra
      // inteiro. A divisão é regra de multiclasse.
      final result = _summarize(const [
        ClassLevel(classId: 'paladin', level: 6),
      ]);

      expect(result.standardSlots?.tableId, 'half');
      expect(result.standardSlots?.level, 6);
    });

    test('bruxo cai em pacto, e não nos espaços normais', () {
      final result = _summarize(const [
        ClassLevel(classId: 'warlock', level: 5),
      ]);

      expect(result.standardSlots, isNull);
      expect(result.pactSlots?.tableId, 'pact');
      expect(result.pactSlots?.level, 5);
      expect(result.modeLabel, 'Magia de Pacto');
    });
  });

  group('multiclasse', () {
    test('arredonda por classe, não sobre a soma', () {
      // A regra que motiva o serviço existir: Paladino 3 + Patrulheiro 3 dá
      // 1 + 1 = 2, e não 6 ÷ 2 = 3.
      final result = _summarize(const [
        ClassLevel(classId: 'paladin', level: 3),
        ClassLevel(classId: 'ranger', level: 3),
      ]);

      expect(result.effectiveCasterLevel, 2);
      expect(result.standardSlots?.tableId, 'multiclass');
      expect(result.standardSlots?.level, 2);
    });

    test('conjurador completo soma o nível cheio', () {
      final result = _summarize(const [
        ClassLevel(classId: 'wizard', level: 5),
        ClassLevel(classId: 'cleric', level: 3),
      ]);

      expect(result.effectiveCasterLevel, 8);
      expect(result.standardSlots?.level, 8);
    });

    test('artífice é o único meio-conjurador que arredonda para cima', () {
      // Artífice 3 contribui 2; Paladino 3 contribuiria 1.
      final artificer = _summarize(const [
        ClassLevel(classId: 'artificer', level: 3),
        ClassLevel(classId: 'fighter', level: 1),
      ]);
      final paladin = _summarize(const [
        ClassLevel(classId: 'paladin', level: 3),
        ClassLevel(classId: 'fighter', level: 1),
      ]);

      expect(artificer.effectiveCasterLevel, 2);
      expect(paladin.effectiveCasterLevel, 1);
    });

    test('um-terço-conjurador divide por três', () {
      final result = _summarize(const [
        ClassLevel(classId: 'rogue_arcane', level: 7),
        ClassLevel(classId: 'wizard', level: 2),
      ]);

      // 7 ÷ 3 = 2, mais os 2 do mago.
      expect(result.effectiveCasterLevel, 4);
    });

    test('nível baixo demais explica em vez de deixar vazio', () {
      final result = _summarize(const [
        ClassLevel(classId: 'paladin', level: 1),
        ClassLevel(classId: 'fighter', level: 1),
      ]);

      expect(result.hasAnyCasting, isTrue);
      expect(result.standardSlots, isNull);
      expect(result.modeLabel, 'Ainda sem slots de magia');
      expect(result.explanation, contains('nível 2'));
    });

    test('pacto continua separado dos espaços normais', () {
      final result = _summarize(const [
        ClassLevel(classId: 'warlock', level: 3),
        ClassLevel(classId: 'wizard', level: 4),
      ]);

      expect(result.standardSlots?.level, 4, reason: 'só o mago conta aqui');
      expect(result.pactSlots?.level, 3);
      expect(result.explanation, contains('separada'));
    });

    test('não passa do teto da tabela', () {
      final result = _summarize(const [
        ClassLevel(classId: 'wizard', level: 20),
        ClassLevel(classId: 'cleric', level: 20),
      ]);

      expect(result.effectiveCasterLevel, 40);
      expect(result.standardSlots?.level, SpellSlotCalculator.maxTableLevel);
    });
  });

  group('espaços de pacto', () {
    SpellSlotProgressionEntry pactRow({
      required int slotLevel,
      required int count,
    }) {
      // A tabela guarda a quantidade na coluna do círculo em que o bruxo
      // conjura, então a linha muda de coluna conforme o nível.
      return SpellSlotProgressionEntry(
        tableId: 'pact',
        level: 5,
        pactSlotLevel: slotLevel,
        first: slotLevel == 1 ? count : 0,
        second: slotLevel == 2 ? count : 0,
        third: slotLevel == 3 ? count : 0,
        fourth: slotLevel == 4 ? count : 0,
        fifth: slotLevel == 5 ? count : 0,
        sixth: 0,
        seventh: 0,
        eighth: 0,
        ninth: 0,
      );
    }

    test('acha a quantidade na coluna do círculo, não numa coluna fixa', () {
      expect(SpellSlotCalculator.pactSlotCount(pactRow(slotLevel: 1, count: 1)), 1);
      expect(SpellSlotCalculator.pactSlotCount(pactRow(slotLevel: 3, count: 2)), 2);
      expect(SpellSlotCalculator.pactSlotCount(pactRow(slotLevel: 5, count: 4)), 4);
    });

    test('linha sem espaço nenhum devolve zero', () {
      expect(
        SpellSlotCalculator.pactSlotCount(pactRow(slotLevel: 3, count: 0)),
        0,
      );
    });

    test('círculo cai no primeiro quando a linha não diz', () {
      const row = SpellSlotProgressionEntry(
        tableId: 'pact',
        level: 1,
        first: 1,
        second: 0,
        third: 0,
        fourth: 0,
        fifth: 0,
        sixth: 0,
        seventh: 0,
        eighth: 0,
        ninth: 0,
      );

      expect(SpellSlotCalculator.pactSlotLevel(row), 1);
    });

    test('a chave de uso sai fora do alcance dos círculos normais', () {
      // É o ponto da existência do deslocamento: gastar um espaço de pacto de
      // 3º círculo não pode escrever na mesma chave do 3º círculo normal.
      for (var level = 1; level <= SpellSlotCalculator.maxPactSlotLevel; level++) {
        expect(SpellSlotCalculator.pactUsageKey(level), greaterThan(9));
      }

      expect(SpellSlotCalculator.pactUsageKey(3), isNot(3));
    });

    test('pactUsageKeys cobre todos os círculos possíveis', () {
      final keys = SpellSlotCalculator.pactUsageKeys();

      expect(keys, hasLength(SpellSlotCalculator.maxPactSlotLevel));
      expect(keys.first, SpellSlotCalculator.pactUsageKey(1));
      expect(
        keys.last,
        SpellSlotCalculator.pactUsageKey(SpellSlotCalculator.maxPactSlotLevel),
      );
    });
  });

  group('slotsByLevel', () {
    test('devolve só os círculos com espaço', () {
      const row = SpellSlotProgressionEntry(
        tableId: 'full',
        level: 3,
        first: 4,
        second: 2,
        third: 0,
        fourth: 0,
        fifth: 0,
        sixth: 0,
        seventh: 0,
        eighth: 0,
        ninth: 0,
      );

      expect(SpellSlotCalculator.slotsByLevel(row), {1: 4, 2: 2});
    });
  });
}
