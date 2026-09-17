import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/services/initiative_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/initiative_rule.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

/// Guarda o cálculo da iniciativa.
///
/// Duas regras que o teste protege explicitamente:
///
/// - todo personagem soma o modificador de Destreza, e isso não depende de
///   proficiência em salvaguarda de Destreza;
/// - regra especial de subclasse só entra com a subclasse certa, a
///   característica certa e o nível certo. Ser patrulheiro ou ter Sabedoria
///   alta não basta.
void main() {
  /// Uma característica de classe com bloco `initiative`.
  ClassFeatureEntry classFeature({
    required String classId,
    required int level,
    required String name,
    required InitiativeRule rule,
  }) {
    return ClassFeatureEntry(
      classId: classId,
      level: level,
      features: [ClassFeature(name: name, initiative: rule)],
      source: 'phb',
    );
  }

  /// A subclasse Perseguidor da Penumbra como está no asset: Emboscador
  /// Terrível no 3º nível, somando Sabedoria.
  const gloomStalker = SubclassEntry(
    id: 'ranger_gloom_stalker',
    classId: 'ranger',
    name: 'Perseguidor da Penumbra',
    source: 'xgte',
    features: [
      SubclassFeature(
        level: 3,
        name: 'Emboscador Terrível',
        description: 'Soma o modificador de Sabedoria à iniciativa.',
        initiative: InitiativeRule(ability: Ability.wisdom),
      ),
      SubclassFeature(
        level: 7,
        name: 'Passo Iridescente',
        description: 'Sem efeito na iniciativa.',
      ),
    ],
  );

  const hunter = SubclassEntry(
    id: 'ranger_hunter',
    classId: 'ranger',
    name: 'Caçador',
    source: 'phb',
    features: [
      SubclassFeature(
        level: 3,
        name: 'Presa do Caçador',
        description: 'Sem efeito na iniciativa.',
      ),
    ],
  );

  group('regra base', () {
    test('soma o modificador de Destreza', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 16),
        ),
      );

      expect(result.total, 3);
      expect(result.modifiers.single.source, InitiativeSource.dexterity);
    });

    test('Destreza baixa penaliza', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(abilityScores: scoresWith(dexterity: 7)),
      );

      expect(result.total, -2);
      expect(result.formattedTotal, '-2');
    });

    test('não depende de proficiência em salvaguarda de Destreza', () {
      // A iniciativa é um teste de Destreza, não uma salvaguarda. Quem não tem
      // proficiência em salvaguarda de Destreza soma o modificador do mesmo
      // jeito, e quem tem não ganha nada a mais.
      final semProficiencia = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 18),
        ),
      );

      final comProficiencia = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 18),
        ).copyWith(
          savingThrowProficiencies:
              const SavingThrowProficiencies(dexterity: true),
        ),
      );

      expect(semProficiencia.total, 4);
      expect(comProficiencia.total, 4);
    });

    test('o ajuste manual entra na soma e fica no fim', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 14),
          combatStats: const CombatStats(
            armorClass: 10,
            initiativeBonus: 2,
            speedInMeters: 9,
          ),
        ),
      );

      expect(result.total, 4);
      expect(result.modifiers.last.source, InitiativeSource.manual);
      expect(
        result.modifiers.last.label,
        InitiativeCalculator.manualAdjustmentLabel,
      );
    });

    test('ajuste manual em zero não aparece na composição', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(),
      );

      expect(result.modifiers.length, 1);
    });
  });

  group('ajuste manual', () {
    InitiativeResult withAdjustment(int adjustment, {int dexterity = 16}) {
      return InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: dexterity),
          combatStats: CombatStats(
            armorClass: 10,
            initiativeBonus: adjustment,
            speedInMeters: 9,
          ),
        ),
      );
    }

    test('total é a calculada mais o ajuste', () {
      // O exemplo do enunciado: calculada +4, ajuste +2, total +6.
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 18),
          combatStats: const CombatStats(
            armorClass: 10,
            initiativeBonus: 2,
            speedInMeters: 9,
          ),
        ),
      );

      expect(result.calculatedTotal, 4);
      expect(result.manualAdjustment, 2);
      expect(result.total, 6);
      expect(result.formattedTotal, '+6');
      expect(result.formattedCalculatedTotal, '+4');
      expect(result.formattedManualAdjustment, '+2');
    });

    test('ajuste negativo diminui o total sem apagar o cálculo', () {
      final result = withAdjustment(-2);

      expect(result.calculatedTotal, 3);
      expect(result.manualAdjustment, -2);
      expect(result.total, 1);
      expect(result.formattedManualAdjustment, '-2');
      // O importante: a parcela de Destreza continua na composição.
      expect(result.calculatedModifiers.first.value, 3);
    });

    test('sem ajuste, total e calculada são o mesmo número', () {
      final result = withAdjustment(0);

      expect(result.hasManualAdjustment, isFalse);
      expect(result.manualAdjustment, 0);
      expect(result.total, result.calculatedTotal);
    });

    test('remover o ajuste volta ao valor calculado', () {
      final adjusted = withAdjustment(3);
      expect(adjusted.total, 6);

      final cleared = withAdjustment(0);
      expect(cleared.total, 3);
      expect(cleared.hasManualAdjustment, isFalse);
    });

    test('a calculada não conta o ajuste, mesmo com regras somando', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 16, wisdom: 14),
          classLevels: const [
            ClassLevel(
              classId: 'ranger',
              level: 3,
              subclassId: 'ranger_gloom_stalker',
            ),
          ],
          combatStats: const CombatStats(
            armorClass: 10,
            initiativeBonus: -1,
            speedInMeters: 9,
          ),
        ),
        subclasses: const [gloomStalker],
      );

      // +3 de Destreza, +2 de Sabedoria pela subclasse, -1 de ajuste.
      expect(result.calculatedTotal, 5);
      expect(result.manualAdjustment, -1);
      expect(result.total, 4);
      expect(result.calculatedModifiers.length, 2);
      expect(
        result.calculatedModifiers.every(
          (item) => item.source != InitiativeSource.manual,
        ),
        isTrue,
      );
    });

    test('trocar de atributo muda a calculada e mantém o ajuste', () {
      // A iniciativa continua automática: o ajuste não congela o número.
      final antes = withAdjustment(2, dexterity: 14);
      final depois = withAdjustment(2, dexterity: 18);

      expect(antes.calculatedTotal, 2);
      expect(depois.calculatedTotal, 4);
      expect(antes.manualAdjustment, depois.manualAdjustment);
      expect(antes.total, 4);
      expect(depois.total, 6);
    });
  });

  group('característica de subclasse', () {
    test('Emboscador Terrível soma Sabedoria à Destreza', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 16, wisdom: 14),
          classLevels: const [
            ClassLevel(
              classId: 'ranger',
              level: 3,
              subclassId: 'ranger_gloom_stalker',
            ),
          ],
        ),
        subclasses: const [gloomStalker],
      );

      // DES +3 e SAB +2.
      expect(result.total, 5);
      expect(
        result.modifiers.map((item) => item.label),
        containsAll(['Destreza', 'Sabedoria']),
      );
      expect(
        result.modifiers
            .firstWhere((item) => item.label == 'Sabedoria')
            .origin,
        'Emboscador Terrível',
      );
    });

    test('não soma só por ser patrulheiro com Sabedoria alta', () {
      // Mesma classe, mesma Sabedoria, subclasse diferente.
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 16, wisdom: 20),
          classLevels: const [
            ClassLevel(
              classId: 'ranger',
              level: 5,
              subclassId: 'ranger_hunter',
            ),
          ],
        ),
        subclasses: const [gloomStalker, hunter],
      );

      expect(result.total, 3);
      expect(result.modifiers.length, 1);
    });

    test('não soma sem subclasse escolhida', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 16, wisdom: 20),
          classLevels: const [ClassLevel(classId: 'ranger', level: 2)],
        ),
        subclasses: const [gloomStalker],
      );

      expect(result.total, 3);
    });

    test('não soma abaixo do nível da característica', () {
      // A subclasse do patrulheiro é escolhida no 3º nível, e é aí que
      // Emboscador Terrível entra. Um personagem forçado a 2º nível com a
      // subclasse marcada não deve receber o bônus.
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 16, wisdom: 20),
          classLevels: const [
            ClassLevel(
              classId: 'ranger',
              level: 2,
              subclassId: 'ranger_gloom_stalker',
            ),
          ],
        ),
        subclasses: const [gloomStalker],
      );

      expect(result.total, 3);
    });

    test('subclasse desconhecida no compêndio não quebra a conta', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 12),
          classLevels: const [
            ClassLevel(classId: 'ranger', level: 3, subclassId: 'inexistente'),
          ],
        ),
        subclasses: const [gloomStalker],
      );

      expect(result.total, 1);
    });
  });

  group('proficiência', () {
    test('proficiência inteira usa o bônus do personagem', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 14),
          classLevels: const [
            ClassLevel(
              classId: 'paladin',
              level: 7,
              subclassId: 'paladin_watchers',
            ),
          ],
        ),
        subclasses: const [
          SubclassEntry(
            id: 'paladin_watchers',
            classId: 'paladin',
            name: 'Juramento dos Vigilantes',
            source: 'tcoe',
            features: [
              SubclassFeature(
                level: 7,
                name: 'Aura da Sentinela',
                description: 'Soma o bônus de proficiência à iniciativa.',
                initiative: InitiativeRule(
                  proficiency: InitiativeProficiencyUse.full,
                ),
              ),
            ],
          ),
        ],
      );

      // DES +2 e proficiência +3 no 7º nível.
      expect(result.total, 5);
    });

    test('meia proficiência arredonda para baixo', () {
      // Pau para Toda Obra: com bônus +3, soma +1.
      final bard = characterFixture(
        abilityScores: scoresWith(dexterity: 14),
        classLevels: const [ClassLevel(classId: 'bard', level: 5)],
      );

      final result = InitiativeCalculator.calculate(
        character: bard,
        classFeatures: [
          classFeature(
            classId: 'bard',
            level: 2,
            name: 'Pau para Toda Obra',
            rule: const InitiativeRule(
              proficiency: InitiativeProficiencyUse.half,
            ),
          ),
        ],
      );

      expect(bard.proficiencyBonus, 3);
      expect(result.total, 3);
    });

    test('meia proficiência não entra antes do nível da característica', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 14),
          classLevels: const [ClassLevel(classId: 'bard', level: 1)],
        ),
        classFeatures: [
          classFeature(
            classId: 'bard',
            level: 2,
            name: 'Pau para Toda Obra',
            rule: const InitiativeRule(
              proficiency: InitiativeProficiencyUse.half,
            ),
          ),
        ],
      );

      expect(result.total, 2);
    });
  });

  group('talento', () {
    const alert = FeatEntry(
      id: 'alert',
      name: 'Alerta',
      initiative: InitiativeRule(bonus: 5),
    );

    test('Alerta soma +5', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 14),
          feats: const [CharacterFeat(featId: 'alert')],
        ),
        feats: const [alert],
      );

      expect(result.total, 7);
      expect(
        result.modifiers.any(
          (item) => item.source == InitiativeSource.feat && item.value == 5,
        ),
        isTrue,
      );
    });

    test('talento sem regra de iniciativa não muda nada', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 14),
          feats: const [CharacterFeat(featId: 'athlete')],
        ),
        feats: const [alert, FeatEntry(id: 'athlete', name: 'Atleta')],
      );

      expect(result.total, 2);
    });
  });

  group('raça', () {
    const harengon = RaceEntry(
      id: 'harengon_motm',
      name: 'Harengon',
      source: 'motm',
      initiative: InitiativeRule(
        proficiency: InitiativeProficiencyUse.full,
        note: 'Gatilho de Lebre',
      ),
    );

    test('Gatilho de Lebre soma o bônus de proficiência', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 16),
          speciesId: 'harengon_motm',
        ),
        races: const [harengon],
      );

      // DES +3 e proficiência +2 no 1º nível.
      expect(result.total, 5);
      expect(
        result.modifiers.last.origin,
        'Gatilho de Lebre',
      );
    });

    test('sub-raça herda a regra da raça base', () {
      const base = RaceEntry(
        id: 'elf_phb',
        name: 'Elfo',
        source: 'phb',
        initiative: InitiativeRule(bonus: 1, note: 'Traço da raça base'),
      );
      const subrace = RaceEntry(
        id: 'elf_high',
        name: 'Elfo Alto',
        source: 'phb',
        parentRaceId: 'elf_phb',
        isSubrace: true,
      );

      final result = InitiativeCalculator.calculate(
        character: characterFixture(speciesId: 'elf_high'),
        races: const [base, subrace],
      );

      expect(result.total, 1);
    });

    test('raça sem regra não muda nada', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 14),
          speciesId: 'human_phb',
        ),
        races: const [
          RaceEntry(id: 'human_phb', name: 'Humano', source: 'phb'),
        ],
      );

      expect(result.total, 2);
    });
  });

  group('vantagem', () {
    test('Instinto Feral dá vantagem sem somar número', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 16),
          classLevels: const [ClassLevel(classId: 'barbarian', level: 7)],
        ),
        classFeatures: [
          classFeature(
            classId: 'barbarian',
            level: 7,
            name: 'Instinto Feral',
            rule: const InitiativeRule(advantage: true),
          ),
        ],
      );

      expect(result.total, 3);
      expect(result.hasAdvantage, isTrue);
      expect(result.advantageSources, ['Instinto Feral']);
    });

    test('sem característica de vantagem, não há vantagem', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(),
      );

      expect(result.hasAdvantage, isFalse);
    });
  });

  group('multiclasse', () {
    test('soma as regras das duas classes, cada uma no seu nível', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 14, wisdom: 16),
          classLevels: const [
            ClassLevel(classId: 'bard', level: 2),
            ClassLevel(
              classId: 'ranger',
              level: 3,
              subclassId: 'ranger_gloom_stalker',
            ),
          ],
        ),
        classFeatures: [
          classFeature(
            classId: 'bard',
            level: 2,
            name: 'Pau para Toda Obra',
            rule: const InitiativeRule(
              proficiency: InitiativeProficiencyUse.half,
            ),
          ),
        ],
        subclasses: const [gloomStalker],
      );

      // Nível total 5, então proficiência +3: DES +2, meia proficiência +1,
      // SAB +3.
      expect(result.total, 6);
    });

    test('característica da outra classe não vale para esta', () {
      // Pau para Toda Obra é do bardo. Um patrulheiro de 5º nível com a
      // característica declarada para `bard` não pode recebê-la.
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 14),
          classLevels: const [ClassLevel(classId: 'ranger', level: 5)],
        ),
        classFeatures: [
          classFeature(
            classId: 'bard',
            level: 2,
            name: 'Pau para Toda Obra',
            rule: const InitiativeRule(
              proficiency: InitiativeProficiencyUse.half,
            ),
          ),
        ],
      );

      expect(result.total, 2);
    });
  });

  group('composição exibida', () {
    test('explica o total parcela por parcela', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(dexterity: 16, wisdom: 14),
          classLevels: const [
            ClassLevel(
              classId: 'ranger',
              level: 3,
              subclassId: 'ranger_gloom_stalker',
            ),
          ],
          combatStats: const CombatStats(
            armorClass: 10,
            initiativeBonus: 1,
            speedInMeters: 9,
          ),
        ),
        subclasses: const [gloomStalker],
      );

      expect(
        result.explanation,
        '+6 = +3 de Destreza +2 de Sabedoria (Emboscador Terrível) '
        '+1 de ajuste manual',
      );
    });

    test('sem parcela extra, a explicação é só o total', () {
      final result = InitiativeCalculator.calculate(
        character: characterFixture(abilityScores: scoresWith(dexterity: 12)),
      );

      expect(result.explanation, '+1 = +1 de Destreza');
    });
  });

  group('leitura do bloco initiative', () {
    test('bloco ausente ou inválido vira nulo', () {
      expect(InitiativeRule.tryParse(null), isNull);
      expect(InitiativeRule.tryParse('texto'), isNull);
      expect(InitiativeRule.tryParse(const <String, Object>{}), isNull);
    });

    test('bloco que não faz nada é descartado', () {
      // Preencher `{"advantage": false}` no asset é erro de digitação, e uma
      // regra vazia viraria linha sem efeito na composição.
      expect(
        InitiativeRule.tryParse(const {'advantage': false}),
        isNull,
      );
      expect(InitiativeRule.tryParse(const {'bonus': 0}), isNull);
    });

    test('lê os campos que reconhece e ignora o resto', () {
      final rule = InitiativeRule.tryParse(const {
        'ability': 'wisdom',
        'proficiency': 'half',
        'bonus': 2,
        'advantage': true,
        'note': 'Teste',
        'campo_desconhecido': 'ignorado',
      });

      expect(rule, isNotNull);
      expect(rule!.ability, Ability.wisdom);
      expect(rule.proficiency, InitiativeProficiencyUse.half);
      expect(rule.bonus, 2);
      expect(rule.advantage, isTrue);
      expect(rule.note, 'Teste');
    });

    test('atributo desconhecido é ignorado sem derrubar a regra', () {
      final rule = InitiativeRule.tryParse(const {
        'ability': 'sorte',
        'bonus': 1,
      });

      expect(rule, isNotNull);
      expect(rule!.ability, isNull);
      expect(rule.bonus, 1);
    });
  });
}
