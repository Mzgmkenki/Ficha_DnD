import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_options.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_natural_armor.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

// ---------------------------------------------------------------- compêndio
//
// Raças e classe sintéticas de propósito: estes testes são sobre a REGRA da
// Armadura Natural, não sobre o texto do asset. O asset real tem um grupo só
// para ele no fim do arquivo, e assim uma revisão de prosa no compêndio não
// derruba os testes de cálculo.

/// A carapaça do Tartaruga: CA fixa 17, atributo nenhum entra.
///
/// `formula: '17'` sem termo de atributo é o coração do bug original — o
/// levantamento é explícito em "Destreza não altera essa CA", e qualquer
/// `mod.*` aqui daria ao Tartaruga um número que a regra não dá.
/// `armor: any` porque a fórmula não exige estar sem armadura; quem proíbe
/// vestir armadura é [RaceNaturalArmor.forbidsArmor], que é outra pergunta.
const _tortleNaturalArmor = FeatureEffect(
  id: 'tortle.natural_armor',
  path: FeatureEffectPaths.armorClassBase,
  operation: FeatureEffectOperation.grant,
  formula: '17',
  conditions: FeatureEffectConditions(),
  stacking: FeatureEffectStacking.exclusive,
  group: 'ac.base',
  label: 'Armadura Natural',
  display: FeatureDisplaySlot.armorClass,
);

/// Defesa sem Armadura do Bárbaro: aceita escudo e exige estar sem armadura.
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

const _tortle = RaceEntry(
  id: 'tortle_motm',
  name: 'Tartaruga',
  source: 'motm',
  naturalArmor: RaceNaturalArmor(
    effect: _tortleNaturalArmor,
    forbidsArmor: true,
  ),
);

/// Raça sem Armadura Natural, que é o caso da esmagadora maioria.
const _human = RaceEntry(id: 'human_phb', name: 'Humano', source: 'phb');

const _barbarian = ClassEntry(
  id: 'barbarian',
  name: 'Bárbaro',
  hitDie: 'd12',
  source: 'srd',
  skillOptions: [],
  savingThrows: ['strength', 'constitution'],
  subclassLevel: 3,
);

final _classFeatures = <ClassFeatureEntry>[
  const ClassFeatureEntry(
    classId: 'barbarian',
    level: 1,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Defesa sem Armadura',
        description: '10 + DES + CON.',
        effects: [_barbarianUnarmored],
      ),
    ],
  ),
];

const _races = [_tortle, _human];

// ----------------------------------------------------------------- helpers

ResolvedFeatures _features(Character character) {
  return SpecialFeatureResolver.resolve(
    character: character,
    classes: const [_barbarian],
    classFeatures: _classFeatures,
    races: _races,
  );
}

List<ArmorClassFormulaOption> _formulas(Character character) {
  return ArmorClassOptions.formulasFor(
    features: _features(character),
    abilityScores: character.abilityScores,
    inventory: character.inventory,
    context: FeatureFormulaContext.fromCharacter(character),
  );
}

ArmorClassFormulaOption _formula(Character character, String id) {
  return _formulas(character).firstWhere((item) => item.id == id);
}

ArmorClassSelection _armorClass(
  Character character, {
  String? preferredFormulaId,
}) {
  return ArmorClassOptions.resolve(
    features: _features(character),
    abilityScores: character.abilityScores,
    inventory: character.inventory,
    context: FeatureFormulaContext.fromCharacter(character),
    preferredFormulaId: preferredFormulaId,
  );
}

InventoryItem _gear(String id, {required String name, bool equipped = true}) {
  return InventoryItem(
    itemId: id,
    name: name,
    category: ItemCategory.armor,
    equipped: equipped,
    source: GrantSource.manual,
  );
}

/// Tartaruga sem classe que conceda fórmula de CA.
///
/// Guerreiro porque o compêndio sintético não tem característica de guerreiro
/// nenhuma: é o jeito de isolar a fórmula racial.
Character _tortleOnly({
  int dexterity = 10,
  int constitution = 10,
  List<InventoryItem> inventory = const [],
}) {
  return characterFixture(
    classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
    abilityScores: scoresWith(dexterity: dexterity, constitution: constitution),
    speciesId: 'tortle_motm',
  ).copyWith(inventory: inventory);
}

Character _tortleBarbarian({
  int dexterity = 10,
  int constitution = 10,
  List<InventoryItem> inventory = const [],
}) {
  return characterFixture(
    classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
    abilityScores: scoresWith(dexterity: dexterity, constitution: constitution),
    speciesId: 'tortle_motm',
  ).copyWith(inventory: inventory);
}

void main() {
  group('Armadura Natural da raça', () {
    test('1. Tartaruga sem Bárbaro recebe a fórmula da carapaça, com 17', () {
      // O bug original: a Armadura Natural vivia só na prosa de `traits`, e o
      // sistema de CA descobre fórmulas varrendo efeitos `ac.base`. Sem o
      // campo tipado na raça, esta fórmula não existia para ninguém.
      final character = _tortleOnly();
      final natural = _formula(character, 'tortle.natural_armor');

      expect(natural.value, 17);
      expect(natural.isUsable, isTrue);
      expect(_armorClass(character).result.total, 17);
    });

    test(
      '2. Tartaruga Bárbaro tem as duas fórmulas, e nenhuma soma a outra',
      () {
        // Duas CA-base NUNCA somam: o jogador escolhe uma. 17 + 15 = 32 seria o
        // erro clássico de tratar fórmula base como bônus.
        final character = _tortleBarbarian(dexterity: 14, constitution: 16);
        final formulas = _formulas(character);

        expect(_formula(character, 'tortle.natural_armor').value, 17);
        expect(_formula(character, 'barbarian.unarmored_defense').value, 15);

        // As duas aparecem na lista, separadas, cada uma com o próprio número.
        expect(
          formulas.map((item) => item.id),
          containsAll(<String>[
            'tortle.natural_armor',
            'barbarian.unarmored_defense',
          ]),
        );
        expect(_armorClass(character).result.total, 17, reason: 'nunca 32');
      },
    );

    test('3. a carapaça NÃO soma Destreza', () {
      // "Destreza não altera essa CA" é texto do levantamento. Com um
      // `mod.dexterity` indevido na fórmula, DES 20 daria 22.
      expect(
        _formula(_tortleOnly(dexterity: 10), 'tortle.natural_armor').value,
        17,
      );
      expect(
        _formula(_tortleOnly(dexterity: 20), 'tortle.natural_armor').value,
        17,
      );
    });

    test('4. a carapaça NÃO soma Constituição', () {
      // Mesma precaução: a Defesa sem Armadura usa CON, a carapaça não, e as
      // duas conviverem no mesmo personagem é justamente o caso de risco.
      expect(
        _formula(_tortleOnly(constitution: 10), 'tortle.natural_armor').value,
        17,
      );
      expect(
        _formula(_tortleOnly(constitution: 20), 'tortle.natural_armor').value,
        17,
      );
    });

    test('5. escudo equipado soma na CA natural: 17 vira 19', () {
      // A regra da Tartaruga proíbe armadura e PERMITE escudo. O escudo é
      // bônus independente, então soma por cima da fórmula base.
      final character = _tortleOnly(
        inventory: [_gear(ShieldOption.id, name: 'Escudo')],
      );
      final selection = _armorClass(character);

      expect(selection.selectedId, 'tortle.natural_armor');
      expect(selection.result.total, 19);
      expect(selection.result.explanation, contains('escudo +2'));
    });

    test('6. desequipar o escudo volta para 17 e não remove mais nada', () {
      final character = _tortleOnly(
        inventory: [_gear(ShieldOption.id, name: 'Escudo', equipped: false)],
      );
      final selection = _armorClass(character);

      expect(selection.result.total, 17);
      // O que volta é só o +2 do escudo: a fórmula racial continua na lista,
      // continua selecionada e continua utilizável.
      expect(selection.selectedId, 'tortle.natural_armor');
      expect(_formula(character, 'tortle.natural_armor').isUsable, isTrue);
      // E o escudo segue no inventário, só desequipado.
      expect(character.inventory.single.itemId, ShieldOption.id);
    });

    test('7. a Defesa sem Armadura do Bárbaro continua 10 + DES + CON', () {
      // A fórmula racial é acrescentada, não substitui a de classe: um
      // Tartaruga Bárbaro continua tendo direito à conta do Bárbaro.
      final character = _tortleBarbarian(dexterity: 16, constitution: 18);
      final defense = _formula(character, 'barbarian.unarmored_defense');

      expect(defense.value, 17, reason: '10 + DES +3 + CON +4');
      expect(defense.isUsable, isTrue);
      expect(defense.composition, '10 + DES 3 + CON 4 = 17');
    });

    test('8. a comparação automática escolhe a maior das duas', () {
      // Sem escolha gravada, vale a maior CA válida — e as duas disputam de
      // igual para igual, sem nenhum caminho especial para a raça.
      final carapace = _armorClass(
        _tortleBarbarian(dexterity: 14, constitution: 16),
      );
      expect(carapace.selectedId, 'tortle.natural_armor');
      expect(carapace.result.total, 17, reason: 'carapaça 17 contra 15');

      final defense = _armorClass(
        _tortleBarbarian(dexterity: 20, constitution: 20),
      );
      expect(defense.selectedId, 'barbarian.unarmored_defense');
      expect(defense.result.total, 20, reason: '10 + 5 + 5 contra 17');
    });

    test('9. a escolha manual é respeitada mesmo quando não é a maior', () {
      // A preferência do jogador manda sobre a comparação: trocar a escolha
      // dele por um número maior seria decidir regra no lugar dele.
      final character = _tortleBarbarian(dexterity: 20, constitution: 20);
      final selection = _armorClass(
        character,
        preferredFormulaId: 'tortle.natural_armor',
      );

      expect(selection.selectedId, 'tortle.natural_armor');
      expect(selection.result.total, 17);
      expect(selection.usedFallback, isFalse);
    });

    test('10. raça sem Armadura Natural não ganha fórmula nenhuma', () {
      // Nulo é o estado normal: a mudança não pode ter dado carapaça a quem
      // não tem. Sobram a fórmula do equipamento e a da classe.
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        speciesId: 'human_phb',
      );

      expect(_formulas(character).map((item) => item.id), <String>[
        armorClassEquipmentFormulaId,
        'barbarian.unarmored_defense',
      ]);
      expect(
        _features(
          character,
        ).features.any((item) => item.origin == FeatureOrigin.racialTrait),
        isFalse,
      );
    });

    test(
      'a armadura vestida fica indisponível, e o item segue no inventário',
      () {
        // "Não pode usar armadura" vira fórmula do equipamento INDISPONÍVEL, com
        // o motivo à vista. Apagar a peça do inventário seria mexer no que é do
        // jogador; ela só não entra na conta.
        final character = _tortleOnly(
          inventory: [_gear('chain_shirt', name: 'Camisão de malha')],
        );
        final equipment = _formula(character, armorClassEquipmentFormulaId);

        expect(equipment.isAvailable, isFalse);
        expect(equipment.unavailableReason, isNotNull);
        expect(character.inventory.single.equipped, isTrue);
        // A carapaça não exige estar sem armadura, então continua valendo.
        expect(_armorClass(character).result.total, 17);
      },
    );
  });

  group('asset real de raças', () {
    test('11. só as quatro raças declaradas têm Armadura Natural', () {
      // Lê o arquivo como `races_asset_test.dart` e usa o MESMO parser do
      // repositório, para o teste acusar tanto dado fora de lugar quanto
      // bloco que o parser deixou de entender.
      final file = File('assets/data/srd/races.json');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'asset de raças não encontrado',
      );

      final races = (jsonDecode(file.readAsStringSync()) as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);

      final declared = <String>[];
      for (final race in races) {
        final natural = RaceNaturalArmor.tryParse(race['natural_armor']);
        if (natural != null) declared.add(race['id'] as String);
      }
      declared.sort();

      expect(declared, <String>[
        'lizardfolk_motm',
        'loxodon_ggr',
        'thri_kreen_aag',
        'tortle_motm',
      ]);

      // E a proibição de vestir armadura é só da Tartaruga: as outras três
      // vestem armadura normalmente, e a fórmula natural é só uma alternativa.
      final forbidding = <String>[];
      for (final race in races) {
        final natural = RaceNaturalArmor.tryParse(race['natural_armor']);
        if (natural?.forbidsArmor == true) forbidding.add(race['id'] as String);
      }

      expect(forbidding, <String>['tortle_motm']);
    });
  });
}
