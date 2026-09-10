import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

ClassEntry _classEntry(String id, String hitDie) => ClassEntry(
      id: id,
      name: id,
      hitDie: hitDie,
      source: 'srd',
      skillOptions: const [],
      savingThrows: const [],
    );

final _classes = [
  _classEntry('fighter', 'd10'),
  _classEntry('wizard', 'd6'),
  _classEntry('barbarian', 'd12'),
  _classEntry('rogue', 'd8'),
];

int _maxHp({
  required List<ClassLevel> levels,
  int constitution = 10,
}) {
  return HitPointsCalculator.maxHitPointsFromEntries(
    classLevels: levels,
    abilityScores: scoresWith(constitution: constitution),
    classes: _classes,
  );
}

void main() {
  group('parseDieSize', () {
    test('entende as grafias que aparecem no compêndio', () {
      expect(HitPointsCalculator.parseDieSize('d10'), 10);
      expect(HitPointsCalculator.parseDieSize('D12'), 12);
      expect(HitPointsCalculator.parseDieSize('8'), 8);
      expect(HitPointsCalculator.parseDieSize(' d6 '), 6);
    });

    test('cai no d8 quando o dado é desconhecido ou ausente', () {
      expect(HitPointsCalculator.parseDieSize(null), 8);
      expect(HitPointsCalculator.parseDieSize('dado'), 8);
      expect(HitPointsCalculator.parseDieSize(''), 8);
    });
  });

  group('PV máximo, classe única', () {
    test('nível 1 usa o dado cheio mais CON', () {
      // Guerreiro d10, CON 14 (+2): 10 + 2.
      expect(
        _maxHp(
          levels: const [ClassLevel(classId: 'fighter', level: 1)],
          constitution: 14,
        ),
        12,
      );
    });

    test('níveis seguintes usam a média do dado, arredondada para cima', () {
      // d10: 1º nível 10+2; níveis 2 e 3 valem (5+1)+2 = 8 cada.
      expect(
        _maxHp(
          levels: const [ClassLevel(classId: 'fighter', level: 3)],
          constitution: 14,
        ),
        12 + 8 + 8,
      );
    });

    test('CON zero não some do cálculo', () {
      // d6: 6 no primeiro nível, depois 4 por nível.
      expect(
        _maxHp(levels: const [ClassLevel(classId: 'wizard', level: 3)]),
        6 + 4 + 4,
      );
    });

    test('CON negativa reduz cada nível', () {
      // Bárbaro d12, CON 8 (-1): 12-1, depois (6+1)-1 = 6 por nível.
      expect(
        _maxHp(
          levels: const [ClassLevel(classId: 'barbarian', level: 3)],
          constitution: 8,
        ),
        11 + 6 + 6,
      );
    });

    test('nível 20 de guerreiro com CON 16 fecha em 184', () {
      // 12 no 1º nível + 19 x 9 = 171.
      expect(
        _maxHp(
          levels: const [ClassLevel(classId: 'fighter', level: 20)],
          constitution: 16,
        ),
        13 + 19 * 9,
      );
    });
  });

  group('PV máximo, multiclasse', () {
    test('só a primeira classe da lista ganha o dado cheio', () {
      // Guerreiro 1 (10+2) + Mago 1 (média 4 + 2) = 18.
      expect(
        _maxHp(
          levels: const [
            ClassLevel(classId: 'fighter', level: 1),
            ClassLevel(classId: 'wizard', level: 1),
          ],
          constitution: 14,
        ),
        12 + 6,
      );
    });

    test('a ordem da lista muda o resultado, porque define a classe inicial',
        () {
      const fighterFirst = [
        ClassLevel(classId: 'fighter', level: 1),
        ClassLevel(classId: 'wizard', level: 1),
      ];
      const wizardFirst = [
        ClassLevel(classId: 'wizard', level: 1),
        ClassLevel(classId: 'fighter', level: 1),
      ];

      expect(_maxHp(levels: fighterFirst), 10 + 4);
      expect(_maxHp(levels: wizardFirst), 6 + 6);
    });
  });

  group('piso de 1 PV por nível', () {
    test('CON 1 no nível 1 não deixa o PV zerar', () {
      // d6 com CON 1 (-5): 6-5 = 1.
      expect(
        _maxHp(
          levels: const [ClassLevel(classId: 'wizard', level: 1)],
          constitution: 1,
        ),
        1,
      );
    });

    test('CON muito baixa em vários níveis respeita 1 PV por nível', () {
      // d6 com CON 1 (-5): 1 no primeiro nível e -2 nos outros dois daria
      // -3, então o piso (3 níveis) assume.
      expect(
        _maxHp(
          levels: const [ClassLevel(classId: 'wizard', level: 3)],
          constitution: 1,
        ),
        3,
      );
    });

    test('sem classes, devolve 1', () {
      expect(_maxHp(levels: const []), 1);
    });
  });

  group('hitDicePool', () {
    test('agrupa níveis da mesma classe num só grupo', () {
      final pool = HitPointsCalculator.hitDicePool(
        classLevels: const [ClassLevel(classId: 'fighter', level: 5)],
        classes: _classes,
      );

      expect(pool.length, 1);
      expect(pool.first.dieSize, 10);
      expect(pool.first.quantity, 5);
      expect(pool.first.label, '5d10');
    });

    test('classes com o mesmo dado somam no mesmo grupo', () {
      final pool = HitPointsCalculator.hitDicePool(
        classLevels: const [
          ClassLevel(classId: 'rogue', level: 2),
          ClassLevel(classId: 'unknown', level: 3),
        ],
        classes: _classes,
      );

      // 'unknown' cai no d8 padrão e se junta ao ladino.
      expect(pool.length, 1);
      expect(pool.first.label, '5d8');
    });

    test('ordena do dado maior para o menor', () {
      final pool = HitPointsCalculator.hitDicePool(
        classLevels: const [
          ClassLevel(classId: 'wizard', level: 1),
          ClassLevel(classId: 'barbarian', level: 2),
          ClassLevel(classId: 'fighter', level: 3),
        ],
        classes: _classes,
      );

      expect(pool.map((g) => g.label).toList(), ['2d12', '3d10', '1d6']);
    });
  });

  group('dados de vida recuperados no descanso longo', () {
    test('metade do total, arredondando para baixo', () {
      expect(HitPointsCalculator.hitDiceRecoveredOnLongRest(20), 10);
      expect(HitPointsCalculator.hitDiceRecoveredOnLongRest(5), 2);
      expect(HitPointsCalculator.hitDiceRecoveredOnLongRest(4), 2);
    });

    test('sempre pelo menos 1 dado', () {
      expect(HitPointsCalculator.hitDiceRecoveredOnLongRest(1), 1);
      expect(HitPointsCalculator.hitDiceRecoveredOnLongRest(0), 1);
    });
  });
}
