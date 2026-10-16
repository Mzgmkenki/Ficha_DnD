import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_options.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Guarda os efeitos declarados no asset.
///
/// Os testes de regra usam dado sintético (ver
/// `test/domain/special_features_test.dart`). Aqui o alvo é o OUTRO risco: um
/// id duplicado, uma fórmula com token que o avaliador não entende ou uma
/// condição escrita errado passariam em silêncio — a característica apenas
/// deixaria de calcular, e ninguém notaria.
void main() {
  late List<Map<String, dynamic>> classFeatures;
  late List<Map<String, dynamic>> subclasses;

  List<Map<String, dynamic>> readList(String path) {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'asset não encontrado: $path');

    final decoded = jsonDecode(file.readAsStringSync());
    expect(decoded, isA<List<dynamic>>(), reason: '$path não é uma lista');

    return (decoded as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  /// Todos os blocos `effects` do asset, com a origem para a mensagem de erro.
  List<({String origin, Map<String, dynamic> raw})> allEffects() {
    final result = <({String origin, Map<String, dynamic> raw})>[];

    for (final entry in classFeatures) {
      final origin = '${entry['class_id']}/${entry['level']}';
      for (final raw in entry['features'] as List<dynamic>) {
        final feature = Map<String, dynamic>.from(raw as Map);
        for (final effect
            in (feature['effects'] as List<dynamic>?) ?? const []) {
          result.add((
            origin: '$origin "${feature['name']}"',
            raw: Map<String, dynamic>.from(effect as Map),
          ));
        }
      }
    }

    for (final entry in subclasses) {
      final origin = entry['id'] as String;
      for (final raw in (entry['features'] as List<dynamic>?) ?? const []) {
        final feature = Map<String, dynamic>.from(raw as Map);
        for (final effect
            in (feature['effects'] as List<dynamic>?) ?? const []) {
          result.add((
            origin: '$origin "${feature['name']}"',
            raw: Map<String, dynamic>.from(effect as Map),
          ));
        }
      }
    }

    return result;
  }

  setUpAll(() {
    classFeatures = readList('assets/data/srd/class_features.json');
    subclasses = readList('assets/data/srd/subclasses.json');
  });

  group('asset de efeitos', () {
    test('existe pelo menos um efeito declarado', () {
      expect(allEffects(), isNotEmpty);
    });

    test('todo efeito é legível pelo parser', () {
      for (final item in allEffects()) {
        expect(
          FeatureEffect.tryParse(item.raw),
          isNotNull,
          reason: 'efeito descartado em ${item.origin}: ${item.raw}',
        );
      }
    });

    test('nenhum id de efeito se repete', () {
      final seen = <String, String>{};

      for (final item in allEffects()) {
        final id = item.raw['id'] as String;
        final previous = seen[id];
        expect(
          previous,
          isNull,
          reason: 'id "$id" repetido em ${item.origin} e $previous',
        );
        seen[id] = item.origin;
      }
    });

    test('toda fórmula declarada é avaliável', () {
      // Fórmula com token desconhecido é descartada em silêncio pelo
      // avaliador, e a característica simplesmente não calcula nada.
      final context = FeatureFormulaContext.fromCharacter(
        characterFixture(
          classLevels: const [
            ClassLevel(classId: 'barbarian', level: 20),
            ClassLevel(classId: 'monk', level: 20),
            ClassLevel(classId: 'sorcerer', level: 20),
          ],
        ),
      );

      for (final item in allEffects()) {
        final effect = FeatureEffect.tryParse(item.raw)!;
        if (effect.formula == null) continue;

        expect(
          FeatureFormula.evaluate(effect.formula, context),
          isNotNull,
          reason: 'fórmula ilegível em ${item.origin}: "${effect.formula}"',
        );
      }
    });

    test('efeito calculado declara fórmula', () {
      for (final item in allEffects()) {
        final effect = FeatureEffect.tryParse(item.raw)!;
        if (!effect.isCalculated) continue;

        expect(
          effect.formula,
          isNotNull,
          reason: '${item.origin} promete cálculo sem fórmula',
        );
      }
    });

    test('efeito de teto de atributo diz quais atributos', () {
      for (final item in allEffects()) {
        final effect = FeatureEffect.tryParse(item.raw)!;
        if (effect.path != FeatureEffectPaths.abilityMaximum) continue;

        expect(
          effect.abilities,
          isNotEmpty,
          reason: '${item.origin} altera teto sem dizer de quê',
        );
      }
    });

    test('toda fórmula de CA-base fica no grupo exclusivo', () {
      // Sem isso duas fórmulas base poderiam somar, que é exatamente o erro
      // que o levantamento manda evitar.
      for (final item in allEffects()) {
        final effect = FeatureEffect.tryParse(item.raw)!;
        if (effect.path != FeatureEffectPaths.armorClassBase) continue;

        expect(
          effect.stacking,
          FeatureEffectStacking.exclusive,
          reason: '${item.origin} não é exclusiva',
        );
        expect(effect.group, 'ac.base', reason: '${item.origin} fora do grupo');
        expect(
          effect.conditions.armor,
          isNot(FeatureArmorCondition.any),
          reason: '${item.origin} não diz o que exige da armadura',
        );
      }
    });

    test('as duas Defesas sem Armadura compartilham a identidade', () {
      final defenses =
          allEffects()
              .map((item) => FeatureEffect.tryParse(item.raw)!)
              .where((effect) => effect.unique == 'unarmored_defense')
              .toList();

      expect(
        defenses,
        hasLength(2),
        reason:
            'Bárbaro e Monge; sem a chave comum o multiclasse concederia '
            'as duas',
      );
    });
  });

  group('as fórmulas do asset produzem os números do levantamento', () {
    /// Lê o asset de verdade pelos mesmos parsers que o app usa.
    List<ClassFeatureEntry> parsedClassFeatures() {
      return classFeatures
          .map(
            (item) => ClassFeatureEntry(
              classId: item['class_id'] as String,
              level: item['level'] as int,
              source: item['source'] as String? ?? 'srd',
              features: [
                for (final raw in item['features'] as List<dynamic>)
                  if (ClassFeature.tryParse(raw) case final feature?) feature,
              ],
            ),
          )
          .toList(growable: false);
    }

    List<SubclassEntry> parsedSubclasses() {
      return subclasses
          .map(
            (item) => SubclassEntry(
              id: item['id'] as String,
              classId: item['class_id'] as String,
              name: item['name'] as String,
              source: item['source'] as String? ?? 'srd',
              features: [
                for (final raw
                    in (item['features'] as List<dynamic>?) ?? const [])
                  SubclassFeature(
                    level: (raw as Map)['level'] as int? ?? 1,
                    name: raw['name'] as String? ?? '',
                    description: raw['description'] as String? ?? '',
                    effects: FeatureEffect.parseList(raw['effects']),
                    choice: FeatureChoice.tryParse(raw['choice']),
                  ),
              ],
            ),
          )
          .toList(growable: false);
    }

    const classes = [
      ClassEntry(
        id: 'barbarian',
        name: 'Bárbaro',
        hitDie: 'd12',
        source: 'srd',
        skillOptions: [],
        savingThrows: [],
        subclassLevel: 3,
      ),
      ClassEntry(
        id: 'monk',
        name: 'Monge',
        hitDie: 'd8',
        source: 'srd',
        skillOptions: [],
        savingThrows: [],
        subclassLevel: 3,
      ),
      ClassEntry(
        id: 'sorcerer',
        name: 'Feiticeiro',
        hitDie: 'd6',
        source: 'srd',
        skillOptions: [],
        savingThrows: [],
        subclassLevel: 1,
      ),
    ];

    test('Bárbaro: 10 + DES + CON, com escudo permitido', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        abilityScores: scoresWith(dexterity: 14, constitution: 16),
      );

      final selection = ArmorClassOptions.resolve(
        features: SpecialFeatureResolver.resolve(
          character: character,
          classes: classes,
          classFeatures: parsedClassFeatures(),
          subclasses: parsedSubclasses(),
        ),
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      expect(selection.result.total, 15, reason: '10 + 2 + 3');

      final option = selection.selected!;
      expect(option.id, 'barbarian.unarmored_defense');
      expect(option.allowsShield, isTrue);
    });

    test('Monge: 10 + DES + SAB, sem escudo', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'monk', level: 1)],
        abilityScores: scoresWith(dexterity: 16, wisdom: 14),
      );

      final selection = ArmorClassOptions.resolve(
        features: SpecialFeatureResolver.resolve(
          character: character,
          classes: classes,
          classFeatures: parsedClassFeatures(),
          subclasses: parsedSubclasses(),
        ),
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      expect(selection.result.total, 15, reason: '10 + 3 + 2');
      expect(selection.selected!.id, 'monk.unarmored_defense');
      expect(selection.selected!.allowsShield, isFalse);
    });

    test('Feiticeiro Dracônico: 13 + DES, com escudo permitido', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'sorcerer',
            level: 1,
            subclassId: 'sorcerer_draconic',
          ),
        ],
        abilityScores: scoresWith(dexterity: 14),
      );

      final selection = ArmorClassOptions.resolve(
        features: SpecialFeatureResolver.resolve(
          character: character,
          classes: classes,
          classFeatures: parsedClassFeatures(),
          subclasses: parsedSubclasses(),
        ),
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      expect(selection.result.total, 15, reason: '13 + 2');
      expect(selection.selected!.id, 'sorcerer_draconic.draconic_resilience');
      expect(selection.selected!.allowsShield, isTrue);
    });

    test('Campeão Primal leva Força e Constituição a 24 no asset', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 20)],
      );

      final features = SpecialFeatureResolver.resolve(
        character: character,
        classes: classes,
        classFeatures: parsedClassFeatures(),
        subclasses: parsedSubclasses(),
      );

      final maximums = features.abilityMaximums(
        FeatureFormulaContext.fromCharacter(character),
      );

      expect(maximums[Ability.strength], 24);
      expect(maximums[Ability.constitution], 24);
      expect(maximums[Ability.wisdom], isNull);
    });

    test('Campeão Primal concede +4 em Força e Constituição no asset', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 20)],
      );

      final features = SpecialFeatureResolver.resolve(
        character: character,
        classes: classes,
        classFeatures: parsedClassFeatures(),
        subclasses: parsedSubclasses(),
      );

      final bonuses = features.abilityBonuses(
        FeatureFormulaContext.fromCharacter(character),
      );

      expect(bonuses[Ability.strength], 4);
      expect(bonuses[Ability.constitution], 4);
      expect(bonuses[Ability.dexterity], isNull);
    });

    test('a característica de nível 20 do Bárbaro não vale no 19º', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 19)],
      );

      final features = SpecialFeatureResolver.resolve(
        character: character,
        classes: classes,
        classFeatures: parsedClassFeatures(),
        subclasses: parsedSubclasses(),
      );

      final context = FeatureFormulaContext.fromCharacter(character);

      expect(features.abilityBonuses(context), isEmpty);
      expect(features.abilityMaximums(context), isEmpty);
    });

    test(
      'Espírito Totêmico não declara mais escolha no asset de subclasses',
      () {
        // A escolha mudou de casa: ela vive em `class_mechanics.json`, que é o
        // sistema que realmente apresenta, grava e bloqueia. Deixar o bloco
        // `choice` aqui também duplicaria as cinco opções em dois arquivos.
        final totem = parsedSubclasses().firstWhere(
          (item) => item.id == 'barbarian_totem_warrior',
        );

        final feature = totem.features.firstWhere(
          (item) => item.name == 'Espírito Totêmico',
        );

        expect(feature.choice, isNull);
        expect(
          feature.description,
          contains('Urso'),
          reason: 'o texto da característica continua aqui: só a escolha saiu',
        );
      },
    );
  });
}
