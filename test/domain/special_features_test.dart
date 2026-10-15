import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feature_state.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_options.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_resources.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/services/rest_service.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

// ---------------------------------------------------------------- compêndio
//
// Dados sintéticos de propósito: estes testes são sobre o COMPORTAMENTO do
// resolvedor e do cálculo de CA. O asset real é conferido num grupo próprio no
// fim do arquivo, e assim uma correção de texto no compêndio não quebra os
// testes de regra.

const _barbarian = ClassEntry(
  id: 'barbarian',
  name: 'Bárbaro',
  hitDie: 'd12',
  source: 'srd',
  skillOptions: [],
  savingThrows: ['strength', 'constitution'],
  subclassLevel: 3,
  subclassLabel: 'Caminho Primal',
);

const _monk = ClassEntry(
  id: 'monk',
  name: 'Monge',
  hitDie: 'd8',
  source: 'srd',
  skillOptions: [],
  savingThrows: ['strength', 'dexterity'],
  subclassLevel: 3,
);

const _sorcerer = ClassEntry(
  id: 'sorcerer',
  name: 'Feiticeiro',
  hitDie: 'd6',
  source: 'srd',
  skillOptions: [],
  savingThrows: ['constitution', 'charisma'],
  subclassLevel: 1,
);

/// Defesa sem Armadura do Bárbaro: aceita escudo.
const _barbarianUnarmored = FeatureEffect(
  id: 'barbarian.unarmored_defense',
  path: FeatureEffectPaths.armorClassBase,
  operation: FeatureEffectOperation.grant,
  formula: '10 + mod.dexterity + mod.constitution',
  conditions: FeatureEffectConditions(armor: FeatureArmorCondition.none),
  stacking: FeatureEffectStacking.exclusive,
  group: 'ac.base',
  unique: 'unarmored_defense',
  label: 'Defesa sem Armadura',
  display: FeatureDisplaySlot.armorClass,
);

/// Defesa sem Armadura do Monge: proíbe escudo.
const _monkUnarmored = FeatureEffect(
  id: 'monk.unarmored_defense',
  path: FeatureEffectPaths.armorClassBase,
  operation: FeatureEffectOperation.grant,
  formula: '10 + mod.dexterity + mod.wisdom',
  conditions: FeatureEffectConditions(
    armor: FeatureArmorCondition.none,
    shield: FeatureShieldCondition.forbidden,
  ),
  stacking: FeatureEffectStacking.exclusive,
  group: 'ac.base',
  unique: 'unarmored_defense',
  label: 'Defesa sem Armadura',
  display: FeatureDisplaySlot.armorClass,
);

/// Resiliência Dracônica: outra fórmula, SEM a identidade de Defesa sem
/// Armadura — por isso convive com ela e o jogador escolhe.
const _draconicResilience = FeatureEffect(
  id: 'sorcerer_draconic.draconic_resilience',
  path: FeatureEffectPaths.armorClassBase,
  operation: FeatureEffectOperation.grant,
  formula: '13 + mod.dexterity',
  conditions: FeatureEffectConditions(armor: FeatureArmorCondition.none),
  stacking: FeatureEffectStacking.exclusive,
  group: 'ac.base',
  label: 'Resiliência Dracônica',
  display: FeatureDisplaySlot.armorClass,
);

final _classFeatures = <ClassFeatureEntry>[
  const ClassFeatureEntry(
    classId: 'barbarian',
    level: 1,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Fúria',
        description: 'Ação bônus.',
        action: FeatureAction(
          type: CombatActionType.bonusAction,
          uses: 2,
          recharge: ActionRecharge.longRest,
        ),
      ),
      ClassFeature(
        name: 'Defesa sem Armadura',
        description: '10 + DES + CON.',
        effects: [_barbarianUnarmored],
      ),
    ],
  ),
  const ClassFeatureEntry(
    classId: 'barbarian',
    level: 5,
    source: 'phb',
    features: [
      ClassFeature(name: 'Movimento Rápido', description: '+3 m.'),
    ],
  ),
  const ClassFeatureEntry(
    classId: 'barbarian',
    level: 20,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Campeão Primal',
        description: 'Máximo 24.',
        effects: [
          FeatureEffect(
            id: 'barbarian.primal_champion.maximum',
            path: FeatureEffectPaths.abilityMaximum,
            operation: FeatureEffectOperation.max,
            formula: '24',
            abilities: [Ability.strength, Ability.constitution],
            stacking: FeatureEffectStacking.highest,
            display: FeatureDisplaySlot.abilities,
          ),
        ],
      ),
    ],
  ),
  const ClassFeatureEntry(
    classId: 'monk',
    level: 1,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Defesa sem Armadura',
        description: '10 + DES + SAB.',
        effects: [_monkUnarmored],
      ),
    ],
  ),
  const ClassFeatureEntry(
    classId: 'monk',
    level: 2,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Ki',
        description: 'Pontos de ki.',
        action: FeatureAction(
          type: CombatActionType.special,
          usesFormula: 'level.monk',
          recharge: ActionRecharge.shortRest,
        ),
      ),
    ],
  ),
  const ClassFeatureEntry(
    classId: 'sorcerer',
    level: 1,
    source: 'phb',
    features: [ClassFeature(name: 'Conjuração', description: 'Carisma.')],
  ),
];

final _subclasses = <SubclassEntry>[
  const SubclassEntry(
    id: 'barbarian_berserker',
    classId: 'barbarian',
    name: 'Caminho do Berserker',
    source: 'phb',
    features: [
      SubclassFeature(
        level: 3,
        name: 'Frenesi',
        description: 'Ataque extra como ação bônus.',
      ),
      SubclassFeature(
        level: 6,
        name: 'Fúria Irracional',
        description: 'Imune a Enfeitiçado e Amedrontado em Fúria.',
      ),
    ],
  ),
  const SubclassEntry(
    id: 'barbarian_totem',
    classId: 'barbarian',
    name: 'Caminho do Guerreiro Totêmico',
    source: 'phb',
    features: [
      SubclassFeature(
        level: 3,
        name: 'Espírito Totêmico',
        description: 'Escolha um espírito.',
        choice: FeatureChoice(
          id: 'barbarian_totem.totem_spirit',
          prompt: 'Escolha o espírito totêmico',
          options: [
            FeatureChoiceOption(id: 'bear', label: 'Urso'),
            FeatureChoiceOption(id: 'eagle', label: 'Águia'),
          ],
        ),
      ),
    ],
  ),
  const SubclassEntry(
    id: 'sorcerer_draconic',
    classId: 'sorcerer',
    name: 'Linhagem Dracônica',
    source: 'phb',
    features: [
      SubclassFeature(
        level: 1,
        name: 'Resiliência Dracônica',
        description: '13 + DES sem armadura.',
        effects: [_draconicResilience],
      ),
    ],
  ),
];

ResolvedFeatures _resolve(
  Character character, {
  List<ClassEntry> classes = const [_barbarian, _monk, _sorcerer],
}) {
  return SpecialFeatureResolver.resolve(
    character: character,
    classes: classes,
    classFeatures: _classFeatures,
    subclasses: _subclasses,
  );
}

InventoryItem _armorItem(
  String id, {
  required String name,
  bool equipped = true,
}) {
  return InventoryItem(
    itemId: id,
    name: name,
    category: ItemCategory.armor,
    equipped: equipped,
    source: GrantSource.manual,
  );
}

void main() {
  group('FeatureFormula', () {
    test('soma constante com modificadores de atributo', () {
      final character = characterFixture(
        abilityScores: scoresWith(dexterity: 16, constitution: 14),
      );

      final result = FeatureFormula.evaluate(
        '10 + mod.dexterity + mod.constitution',
        FeatureFormulaContext.fromCharacter(character),
      );

      expect(result, isNotNull);
      expect(result!.value, 15);
      expect(result.composition, '10 + DES 3 + CON 2 = 15');
    });

    test('aceita as abreviações em português do levantamento', () {
      final character = characterFixture(
        abilityScores: scoresWith(dexterity: 16, wisdom: 18),
      );

      final result = FeatureFormula.valueOf(
        '10 + mod.DES + mod.SAB',
        FeatureFormulaContext.fromCharacter(character),
      );

      expect(result, 17);
    });

    test('nível de classe é o da classe, não o total', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'monk', level: 5),
          ClassLevel(classId: 'barbarian', level: 3),
        ],
      );
      final context = FeatureFormulaContext.fromCharacter(character);

      expect(FeatureFormula.valueOf('level.monk', context), 5);
      expect(FeatureFormula.valueOf('level.total', context), 8);
    });

    test('token desconhecido devolve nulo em vez de zero', () {
      // Zero produziria uma CA silenciosamente errada; nulo faz o efeito ser
      // descartado e a descrição continua dizendo a regra.
      final context = FeatureFormulaContext.fromCharacter(characterFixture());

      expect(FeatureFormula.evaluate('10 + mod.luck', context), isNull);
      expect(FeatureFormula.evaluate('10 +', context), isNull);
      expect(FeatureFormula.evaluate('', context), isNull);
      expect(FeatureFormula.evaluate(null, context), isNull);
    });

    test('subtração entra na conta', () {
      final context = FeatureFormulaContext.fromCharacter(characterFixture());
      expect(FeatureFormula.valueOf('10 - 2', context), 8);
    });
  });

  group('concessão por nível', () {
    test('característica do nível alcançado entra na ficha', () {
      final features = _resolve(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        ),
      );

      final names = features.features.map((item) => item.name).toList();
      expect(names, contains('Fúria'));
      expect(names, contains('Defesa sem Armadura'));
    });

    test('característica de nível futuro NÃO entra', () {
      final features = _resolve(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        ),
      );

      expect(
        features.features.map((item) => item.name),
        isNot(contains('Movimento Rápido')),
        reason: 'Movimento Rápido só vem no 5º nível',
      );
    });

    test('ao chegar no nível, a característica aparece', () {
      final features = _resolve(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'barbarian', level: 5)],
        ),
      );

      expect(
        features.features.map((item) => item.name),
        contains('Movimento Rápido'),
      );
    });

    test('a ficha sabe dizer a origem e o nível', () {
      final features = _resolve(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        ),
      );

      final defense = features.features.firstWhere(
        (item) => item.name == 'Defesa sem Armadura',
      );

      expect(defense.sourceLabel, 'Bárbaro, nível 1');
      expect(defense.headline, 'Defesa sem Armadura — Bárbaro, nível 1');
    });
  });

  group('características de subclasse', () {
    test('só a subclasse escolhida concede as dela', () {
      final features = _resolve(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'barbarian',
              level: 3,
              subclassId: 'barbarian_berserker',
            ),
          ],
        ),
      );

      final names = features.features.map((item) => item.name).toList();
      expect(names, contains('Frenesi'));
      expect(
        names,
        isNot(contains('Espírito Totêmico')),
        reason: 'Espírito Totêmico é de outra subclasse',
      );
    });

    test('sem subclasse escolhida, nenhuma característica de subclasse entra', () {
      final features = _resolve(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'barbarian', level: 3)],
        ),
      );

      expect(
        features.features.where(
          (item) => item.origin == FeatureOrigin.subclassFeature,
        ),
        isEmpty,
      );
    });

    test('trocar a subclasse troca as características', () {
      final berserker = _resolve(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'barbarian',
              level: 3,
              subclassId: 'barbarian_berserker',
            ),
          ],
        ),
      );

      final totem = _resolve(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'barbarian',
              level: 3,
              subclassId: 'barbarian_totem',
            ),
          ],
        ),
      );

      expect(berserker.features.map((i) => i.name), contains('Frenesi'));
      expect(
        totem.features.map((i) => i.name),
        isNot(contains('Frenesi')),
        reason: 'a característica é derivada, então trocar a subclasse '
            'simplesmente deixa de produzi-la',
      );
      expect(
        totem.features.map((i) => i.name),
        contains('Espírito Totêmico'),
      );
    });

    test('trocar a classe troca as características', () {
      final asBarbarian = _resolve(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        ),
      );
      final asMonk = _resolve(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'monk', level: 1)],
        ),
      );

      expect(asBarbarian.features.map((i) => i.name), contains('Fúria'));
      expect(asMonk.features.map((i) => i.name), isNot(contains('Fúria')));
    });

    test('característica de subclasse de nível futuro não entra', () {
      final features = _resolve(
        characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'barbarian',
              level: 3,
              subclassId: 'barbarian_berserker',
            ),
          ],
        ),
      );

      expect(
        features.features.map((i) => i.name),
        isNot(contains('Fúria Irracional')),
        reason: 'Fúria Irracional é do 6º nível',
      );
    });
  });

  group('duplicação e multiclasse', () {
    test('a mesma característica não é concedida duas vezes', () {
      // Bárbaro 1 / Monge 1: as duas classes dão Defesa sem Armadura, e a
      // regra de multiclasse concede só a primeira.
      final features = _resolve(
        characterFixture(
          classLevels: const [
            ClassLevel(classId: 'barbarian', level: 1),
            ClassLevel(classId: 'monk', level: 1),
          ],
        ),
      );

      final defenses = features.features
          .where((item) => item.name == 'Defesa sem Armadura')
          .toList();

      expect(defenses, hasLength(2), reason: 'as duas continuam listadas');
      expect(
        defenses.where((item) => !item.isSuperseded),
        hasLength(1),
        reason: 'mas só uma está valendo',
      );
      expect(
        defenses.first.classId,
        'barbarian',
        reason: 'vale a primeira adquirida, pela ordem das classes',
      );
      expect(defenses.last.isSuperseded, isTrue);
    });

    test('a ordem das classes decide qual versão vale', () {
      final features = _resolve(
        characterFixture(
          classLevels: const [
            ClassLevel(classId: 'monk', level: 1),
            ClassLevel(classId: 'barbarian', level: 1),
          ],
        ),
      );

      final valid = features.features.firstWhere(
        (item) => item.name == 'Defesa sem Armadura' && !item.isSuperseded,
      );

      expect(valid.classId, 'monk');
    });

    test('a característica superada não produz efeito calculado', () {
      final features = _resolve(
        characterFixture(
          classLevels: const [
            ClassLevel(classId: 'barbarian', level: 1),
            ClassLevel(classId: 'monk', level: 1),
          ],
        ),
      );

      final superseded = features.features.firstWhere(
        (item) => item.isSuperseded,
      );

      expect(superseded.calculatedEffects, isEmpty);
      expect(
        superseded.effects,
        isNotEmpty,
        reason: 'o dado continua lá, só não vale',
      );
    });

    test('resolver duas vezes dá o mesmo resultado', () {
      // Idempotência: a característica é derivada, então reabrir a ficha não
      // pode acumular nada.
      final character = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'barbarian',
            level: 3,
            subclassId: 'barbarian_berserker',
          ),
        ],
      );

      final first = _resolve(character);
      final second = _resolve(character);

      expect(
        first.features.map((i) => i.id).toList(),
        second.features.map((i) => i.id).toList(),
      );
      expect(
        first.features.map((i) => i.id).toSet().length,
        first.features.length,
        reason: 'nenhum id repetido',
      );
    });
  });

  group('Defesa sem Armadura e fórmulas de CA', () {
    test('ativa sem armadura, somando os dois atributos', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        abilityScores: scoresWith(dexterity: 16, constitution: 16),
      );

      final selection = ArmorClassOptions.resolve(
        features: _resolve(character),
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      expect(selection.selectedId, 'barbarian.unarmored_defense');
      expect(selection.result.total, 16);
      expect(selection.result.baseLabel, 'Defesa sem Armadura');
      expect(selection.result.baseComposition, '10 + DES 3 + CON 3 = 16');
    });

    test('a composição do cálculo fica disponível para a ficha', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        abilityScores: scoresWith(dexterity: 14, constitution: 14),
      );

      final selection = ArmorClassOptions.resolve(
        features: _resolve(character),
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      expect(selection.result.explanation, contains('Defesa sem Armadura'));
      expect(selection.result.explanation, contains('= 14'));
    });

    test('escudo soma na fórmula do Bárbaro', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        abilityScores: scoresWith(dexterity: 14, constitution: 14),
      ).copyWith(
        inventory: [_armorItem(ShieldOption.id, name: 'Escudo')],
      );

      final selection = ArmorClassOptions.resolve(
        features: _resolve(character),
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      expect(selection.result.total, 16, reason: '14 + 2 do escudo');
      expect(selection.result.explanation, contains('escudo +2'));
    });

    test('escudo INVALIDA a fórmula do Monge', () {
      // A diferença entre as duas Defesas sem Armadura é exatamente esta, e
      // vem do dado — não de um `if` por classe.
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'monk', level: 1)],
        abilityScores: scoresWith(dexterity: 16, wisdom: 16),
      ).copyWith(
        inventory: [_armorItem(ShieldOption.id, name: 'Escudo')],
      );

      final features = _resolve(character);
      final formulas = ArmorClassOptions.formulasFor(
        features: features,
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      final monk = formulas.firstWhere(
        (item) => item.id == 'monk.unarmored_defense',
      );

      expect(monk.isAvailable, isFalse);
      expect(monk.unavailableReason, contains('escudo'));
    });

    test('armadura equipada invalida a Defesa sem Armadura', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        abilityScores: scoresWith(dexterity: 16, constitution: 16),
      ).copyWith(
        inventory: [_armorItem('chain_shirt', name: 'Camisão de malha')],
      );

      final features = _resolve(character);
      final formulas = ArmorClassOptions.formulasFor(
        features: features,
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      final defense = formulas.firstWhere(
        (item) => item.id == 'barbarian.unarmored_defense',
      );

      expect(defense.isAvailable, isFalse);
      expect(defense.unavailableReason, contains('sem armadura'));
    });

    test('com armadura, a CA cai para a fórmula do equipamento', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        abilityScores: scoresWith(dexterity: 16, constitution: 16),
      ).copyWith(
        inventory: [_armorItem('chain_shirt', name: 'Camisão de malha')],
        armorClassFormulaId: 'barbarian.unarmored_defense',
      );

      final selection = ArmorClassOptions.resolve(
        features: _resolve(character),
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
        preferredFormulaId: character.armorClassFormulaId,
      );

      expect(selection.selectedId, armorClassEquipmentFormulaId);
      // Camisão de malha 13 + DES +2 (limite de média) = 15.
      expect(selection.result.total, 15);
      expect(selection.usedFallback, isTrue);
      expect(selection.fellBackFrom, 'barbarian.unarmored_defense');
      expect(selection.fallbackNotice, isNotNull);
    });

    test('a característica não é apagada quando a armadura a invalida', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
      ).copyWith(
        inventory: [_armorItem('chain_shirt', name: 'Camisão de malha')],
      );

      final features = _resolve(character);

      expect(
        features.features.map((i) => i.name),
        contains('Defesa sem Armadura'),
      );
    });

    test('tirar a armadura devolve a fórmula preferida', () {
      final armored = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        abilityScores: scoresWith(dexterity: 16, constitution: 16),
      ).copyWith(
        inventory: [_armorItem('chain_shirt', name: 'Camisão de malha')],
        armorClassFormulaId: 'barbarian.unarmored_defense',
      );

      final unarmored = armored.copyWith(
        inventory: [
          _armorItem('chain_shirt', name: 'Camisão de malha', equipped: false),
        ],
      );

      final selection = ArmorClassOptions.resolve(
        features: _resolve(unarmored),
        abilityScores: unarmored.abilityScores,
        inventory: unarmored.inventory,
        context: FeatureFormulaContext.fromCharacter(unarmored),
        preferredFormulaId: unarmored.armorClassFormulaId,
      );

      expect(selection.selectedId, 'barbarian.unarmored_defense');
      expect(selection.usedFallback, isFalse);
    });

    test('duas fórmulas válidas: o jogador escolhe, e nunca somam', () {
      // Bárbaro 1 / Feiticeiro Dracônico 1: 10+DES+CON e 13+DES.
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'barbarian', level: 1),
          ClassLevel(
            classId: 'sorcerer',
            level: 1,
            subclassId: 'sorcerer_draconic',
          ),
        ],
        abilityScores: scoresWith(dexterity: 14, constitution: 18),
      );

      final features = _resolve(character);
      final context = FeatureFormulaContext.fromCharacter(character);

      final selection = ArmorClassOptions.resolve(
        features: features,
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: context,
      );

      expect(selection.hasChoice, isTrue);
      expect(selection.usable, hasLength(3), reason: 'equipamento + as duas');

      // 10 + 2 + 4 = 16 contra 13 + 2 = 15. Nenhuma soma com a outra.
      expect(selection.result.total, 16);

      final chosen = ArmorClassOptions.resolve(
        features: features,
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: context,
        preferredFormulaId: 'sorcerer_draconic.draconic_resilience',
      );

      expect(chosen.selectedId, 'sorcerer_draconic.draconic_resilience');
      expect(chosen.result.total, 15);
    });

    test('a CA é recalculada quando o atributo muda', () {
      final before = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        abilityScores: scoresWith(dexterity: 14, constitution: 14),
      );
      final after = before.copyWith(
        abilityScores: scoresWith(dexterity: 14, constitution: 18),
      );

      int total(Character character) => ArmorClassOptions.resolve(
            features: _resolve(character),
            abilityScores: character.abilityScores,
            inventory: character.inventory,
            context: FeatureFormulaContext.fromCharacter(character),
          ).result.total;

      expect(total(before), 14);
      expect(total(after), 16, reason: 'CON 14 → 18 sobe o modificador em 2');
    });

    test('sem característica nenhuma, a CA segue sendo a do equipamento', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'sorcerer', level: 1)],
        abilityScores: scoresWith(dexterity: 14),
      );

      final selection = ArmorClassOptions.resolve(
        features: _resolve(character),
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      expect(selection.selectedId, armorClassEquipmentFormulaId);
      expect(selection.result.total, 12, reason: '10 + DES +2');
      expect(selection.hasChoice, isFalse);
    });

    test('multiclasse não oferece a segunda Defesa sem Armadura', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'barbarian', level: 1),
          ClassLevel(classId: 'monk', level: 1),
        ],
        abilityScores: scoresWith(dexterity: 16, constitution: 16, wisdom: 20),
      );

      final formulas = ArmorClassOptions.formulasFor(
        features: _resolve(character),
        abilityScores: character.abilityScores,
        inventory: character.inventory,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      final monk = formulas.firstWhere(
        (item) => item.id == 'monk.unarmored_defense',
      );

      expect(
        monk.isAvailable,
        isFalse,
        reason: 'mesmo com Sabedoria melhor, a segunda versão não é concedida',
      );
      expect(monk.unavailableReason, contains('multiclasse'));
    });
  });

  group('teto de atributo declarado por característica', () {
    test('o padrão é 20', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 19)],
      );

      final features = _resolve(character);
      final maximums = features.abilityMaximums(
        FeatureFormulaContext.fromCharacter(character),
      );

      expect(maximums, isEmpty, reason: 'nenhuma exceção alcançada');
      expect(
        features.maximumFor(
          Ability.strength,
          FeatureFormulaContext.fromCharacter(character),
        ),
        20,
      );
    });

    test('Campeão Primal leva Força e Constituição a 24', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 20)],
      );
      final context = FeatureFormulaContext.fromCharacter(character);

      final features = _resolve(character);

      expect(features.maximumFor(Ability.strength, context), 24);
      expect(features.maximumFor(Ability.constitution, context), 24);
      expect(
        features.maximumFor(Ability.dexterity, context),
        20,
        reason: 'os outros atributos continuam em 20',
      );
    });
  });

  group('recursos de característica', () {
    test('usos fixos e usos por fórmula', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'barbarian', level: 1),
          ClassLevel(classId: 'monk', level: 5),
        ],
      );

      final resources = FeatureResources.from(
        character: character,
        features: _resolve(character),
        context: FeatureFormulaContext.fromCharacter(character),
      );

      final rage = resources.firstWhere((item) => item.label == 'Fúria');
      expect(rage.maximum, 2);
      expect(rage.remaining, 2);

      final ki = resources.firstWhere((item) => item.label == 'Ki');
      expect(ki.maximum, 5, reason: 'level.monk resolve para 5');
    });

    test('gastar e devolver respeitam zero e o máximo', () {
      var character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
      );

      FeatureResource rage(Character current) => FeatureResources.from(
            character: current,
            features: _resolve(current),
            context: FeatureFormulaContext.fromCharacter(current),
          ).firstWhere((item) => item.label == 'Fúria');

      character = FeatureResources.spend(
        character: character,
        resource: rage(character),
      );
      expect(rage(character).remaining, 1);

      character = FeatureResources.spend(
        character: character,
        resource: rage(character),
      );
      expect(rage(character).remaining, 0);

      // No limite não passa.
      final atLimit = FeatureResources.spend(
        character: character,
        resource: rage(character),
      );
      expect(rage(atLimit).remaining, 0);
      expect(rage(atLimit).spent, 2);

      character = FeatureResources.restore(
        character: character,
        resource: rage(character),
      );
      expect(rage(character).remaining, 1);

      character = FeatureResources.restore(
        character: character,
        resource: rage(character),
      );
      final atZero = FeatureResources.restore(
        character: character,
        resource: rage(character),
      );
      expect(rage(atZero).spent, 0, reason: 'nunca fica negativo');
    });

    test('descanso longo devolve os usos de descanso longo', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
      ).copyWith(
        featureStates: [
          CharacterFeatureState(
            featureId: SpecialFeatureResolver.featureId(
              origin: FeatureOrigin.classFeature,
              originId: 'barbarian',
              level: 1,
              name: 'Fúria',
            ),
            usesSpent: 2,
          ),
        ],
      );

      final features = _resolve(character);
      final ids = FeatureResources.featureIdsRestoredBy(
        features: features,
        recharges: FeatureResources.longRestRecharges,
      );

      final outcome = RestService.longRest(
        character: character,
        totalHitDice: 1,
        restoredFeatureIds: ids,
      );

      final rage = FeatureResources.from(
        character: outcome.character,
        features: features,
        context: FeatureFormulaContext.fromCharacter(outcome.character),
      ).firstWhere((item) => item.label == 'Fúria');

      expect(rage.spent, 0);
      expect(rage.remaining, 2);
      expect(outcome.summary, contains('característica'));
    });

    test('descanso curto NÃO devolve o que é de descanso longo', () {
      final rageId = SpecialFeatureResolver.featureId(
        origin: FeatureOrigin.classFeature,
        originId: 'barbarian',
        level: 1,
        name: 'Fúria',
      );

      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'barbarian', level: 1),
          ClassLevel(classId: 'monk', level: 2),
        ],
      ).copyWith(
        featureStates: [
          CharacterFeatureState(featureId: rageId, usesSpent: 2),
          CharacterFeatureState(
            featureId: SpecialFeatureResolver.featureId(
              origin: FeatureOrigin.classFeature,
              originId: 'monk',
              level: 2,
              name: 'Ki',
            ),
            usesSpent: 2,
          ),
        ],
      );

      final features = _resolve(character);

      final outcome = RestService.shortRest(
        character: character,
        pactSlotUsageKeys: const [],
        restoredFeatureIds: FeatureResources.featureIdsRestoredBy(
          features: features,
          recharges: FeatureResources.shortRestRecharges,
        ),
      );

      final resources = FeatureResources.from(
        character: outcome.character,
        features: features,
        context: FeatureFormulaContext.fromCharacter(outcome.character),
      );

      expect(
        resources.firstWhere((item) => item.label == 'Ki').spent,
        0,
        reason: 'Ki volta em descanso curto',
      );
      expect(
        resources.firstWhere((item) => item.label == 'Fúria').spent,
        2,
        reason: 'Fúria só volta em descanso longo',
      );
    });

    test('característica superada não gera recurso', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'barbarian', level: 1),
          ClassLevel(classId: 'monk', level: 1),
        ],
      );

      final resources = FeatureResources.from(
        character: character,
        features: _resolve(character),
        context: FeatureFormulaContext.fromCharacter(character),
      );

      expect(
        resources.map((item) => item.featureId).toSet().length,
        resources.length,
        reason: 'nenhum recurso duplicado',
      );
    });
  });

  group('escolhas internas de característica', () {
    test('subclasse com escolha fica pendente até o jogador decidir', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'barbarian',
            level: 3,
            subclassId: 'barbarian_totem',
          ),
        ],
      );

      final features = _resolve(character);
      final pending = features.pendingChoices(
        character.featureChoiceSelections,
      );

      expect(pending, hasLength(1));
      expect(pending.single.choice.id, 'barbarian_totem.totem_spirit');
    });

    test('escolha feita sai da lista de pendências', () {
      final base = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'barbarian',
            level: 3,
            subclassId: 'barbarian_totem',
          ),
        ],
      );

      final featureId = SpecialFeatureResolver.featureId(
        origin: FeatureOrigin.subclassFeature,
        originId: 'barbarian_totem',
        level: 3,
        name: 'Espírito Totêmico',
      );

      final character = FeatureResources.chooseOption(
        character: base,
        featureId: featureId,
        optionId: 'bear',
      );

      final features = _resolve(character);

      expect(
        features.pendingChoices(character.featureChoiceSelections),
        isEmpty,
      );
    });

    test('opção salva que saiu do compêndio volta a ser pendência', () {
      final base = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'barbarian',
            level: 3,
            subclassId: 'barbarian_totem',
          ),
        ],
      );

      final character = FeatureResources.chooseOption(
        character: base,
        featureId: SpecialFeatureResolver.featureId(
          origin: FeatureOrigin.subclassFeature,
          originId: 'barbarian_totem',
          level: 3,
          name: 'Espírito Totêmico',
        ),
        optionId: 'dragao_que_nao_existe',
      );

      expect(
        _resolve(character).pendingChoices(
          character.featureChoiceSelections,
        ),
        hasLength(1),
      );
    });
  });

  group('identificador de característica', () {
    test('é estável e sem acento', () {
      final id = SpecialFeatureResolver.featureId(
        origin: FeatureOrigin.classFeature,
        originId: 'barbarian',
        level: 1,
        name: 'Defesa sem Armadura',
      );

      expect(id, 'class.barbarian.1.defesa_sem_armadura');
    });

    test('acento não gera chave diferente', () {
      expect(SpecialFeatureResolver.slug('Fúria'), 'furia');
      expect(SpecialFeatureResolver.slug('Canalizar Divindade'),
          'canalizar_divindade');
    });
  });

  group('FeatureEffect.tryParse', () {
    test('lê o registro normalizado do levantamento', () {
      final effect = FeatureEffect.tryParse({
        'id': 'barbarian.unarmored_defense',
        'path': 'ac.base',
        'operation': 'grant',
        'formula': '10 + mod.dexterity + mod.constitution',
        'conditions': {'armor': 'none', 'shield': 'allowed'},
        'stacking': 'exclusive',
        'group': 'ac.base',
        'unique': 'unarmored_defense',
        'display': 'armor_class',
      });

      expect(effect, isNotNull);
      expect(effect!.id, 'barbarian.unarmored_defense');
      expect(effect.path, FeatureEffectPaths.armorClassBase);
      expect(effect.operation, FeatureEffectOperation.grant);
      expect(effect.conditions.armor, FeatureArmorCondition.none);
      expect(effect.conditions.shield, FeatureShieldCondition.allowed);
      expect(effect.stacking, FeatureEffectStacking.exclusive);
      expect(effect.unique, 'unarmored_defense');
      expect(effect.display, FeatureDisplaySlot.armorClass);
      expect(effect.isCalculated, isTrue);
    });

    test('descarta entrada sem id, sem caminho ou com operação inválida', () {
      expect(FeatureEffect.tryParse({'path': 'ac.base', 'operation': 'grant'}),
          isNull);
      expect(FeatureEffect.tryParse({'id': 'x', 'operation': 'grant'}), isNull);
      expect(
        FeatureEffect.tryParse({'id': 'x', 'path': 'ac.base', 'operation': '?'}),
        isNull,
      );
      expect(FeatureEffect.tryParse('texto'), isNull);
      expect(FeatureEffect.tryParse(null), isNull);
    });

    test('caminho desconhecido entra como informativo', () {
      final effect = FeatureEffect.tryParse({
        'id': 'x.y',
        'path': 'damage.resistance',
        'operation': 'grant',
        'note': 'Aplique em mesa.',
      });

      expect(effect, isNotNull);
      expect(effect!.isCalculated, isFalse);
      expect(effect.note, 'Aplique em mesa.');
    });

    test('escolha com menos de duas opções é descartada', () {
      expect(
        FeatureChoice.tryParse({
          'id': 'x',
          'prompt': 'Escolha',
          'options': [
            {'id': 'a', 'label': 'A'},
          ],
        }),
        isNull,
        reason: 'uma opção só não é escolha, e travaria a evolução sem motivo',
      );
    });
  });
}
