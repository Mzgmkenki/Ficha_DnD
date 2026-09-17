import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/weapon_attack_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_proficiencies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

/// Guarda o cálculo de ataque com arma.
///
/// A regra que o teste protege: o atributo sai da ARMA, não da classe. Um
/// ladino com maça bate com Força; um guerreiro com arco longo usa Destreza.
/// E o bônus de uma arma mágica entra no ataque e no dano dela, nunca em
/// ataque de magia ou CD.
void main() {
  const longsword = WeaponEntry(
    id: 'longsword',
    name: 'Espada Longa',
    category: WeaponCategory.martial,
    rangeType: WeaponRangeType.melee,
    damageType: WeaponDamageType.slashing,
    damage: '1d8',
    properties: [WeaponProperty.versatile],
    versatileDamage: '1d10',
  );

  const mace = WeaponEntry(
    id: 'mace',
    name: 'Maça',
    category: WeaponCategory.simple,
    rangeType: WeaponRangeType.melee,
    damageType: WeaponDamageType.bludgeoning,
    damage: '1d6',
  );

  const rapier = WeaponEntry(
    id: 'rapier',
    name: 'Rapieira',
    category: WeaponCategory.martial,
    rangeType: WeaponRangeType.melee,
    damageType: WeaponDamageType.piercing,
    damage: '1d8',
    properties: [WeaponProperty.finesse],
  );

  const longbow = WeaponEntry(
    id: 'longbow',
    name: 'Arco Longo',
    category: WeaponCategory.martial,
    rangeType: WeaponRangeType.ranged,
    damageType: WeaponDamageType.piercing,
    damage: '1d8',
    properties: [
      WeaponProperty.ammunition,
      WeaponProperty.heavy,
      WeaponProperty.twoHanded,
    ],
  );

  const javelin = WeaponEntry(
    id: 'javelin',
    name: 'Azagaia',
    category: WeaponCategory.simple,
    rangeType: WeaponRangeType.melee,
    damageType: WeaponDamageType.piercing,
    damage: '1d6',
    properties: [WeaponProperty.thrown],
    thrownRange: WeaponRange(normal: 9, long: 36),
  );

  const net = WeaponEntry(
    id: 'net',
    name: 'Rede',
    category: WeaponCategory.martial,
    rangeType: WeaponRangeType.ranged,
    damageType: WeaponDamageType.none,
    properties: [WeaponProperty.special, WeaponProperty.thrown],
  );

  const fighter = ClassEntry(
    id: 'fighter',
    name: 'Guerreiro',
    hitDie: 'd10',
    source: 'srd',
    skillOptions: [],
    savingThrows: [],
    weaponProficiencies: WeaponProficiencies(
      categories: [WeaponCategory.simple, WeaponCategory.martial],
    ),
  );

  const wizard = ClassEntry(
    id: 'wizard',
    name: 'Mago',
    hitDie: 'd6',
    source: 'srd',
    skillOptions: [],
    savingThrows: [],
    weaponProficiencies: WeaponProficiencies(categories: [WeaponCategory.simple]),
  );

  const rogue = ClassEntry(
    id: 'rogue',
    name: 'Ladino',
    hitDie: 'd8',
    source: 'srd',
    skillOptions: [],
    savingThrows: [],
    weaponProficiencies: WeaponProficiencies(
      categories: [WeaponCategory.simple],
      weaponIds: ['hand_crossbow', 'longsword', 'rapier', 'shortsword'],
    ),
  );

  group('atributo vem da arma', () {
    test('corpo a corpo sem Acuidade usa Força mesmo num ladino', () {
      // A maça não tem Acuidade: nem um ladino com Destreza 20 bate com ela
      // usando Destreza.
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 12, dexterity: 20),
          classLevels: const [ClassLevel(classId: 'rogue', level: 5)],
        ),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'mace'),
        entry: mace,
        classes: const [rogue],
      );

      expect(attack.ability, Ability.strength);
      // FOR +1 e proficiência +3 (maça é simples, e o ladino tem simples).
      expect(attack.attackBonus, 4);
    });

    test('à distância usa Destreza mesmo num guerreiro forte', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 20, dexterity: 14),
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longbow'),
        entry: longbow,
        classes: const [fighter],
      );

      expect(attack.ability, Ability.dexterity);
      // DES +2 e proficiência +2.
      expect(attack.attackBonus, 4);
    });

    test('Acuidade usa o melhor entre Força e Destreza', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 10, dexterity: 18),
          classLevels: const [ClassLevel(classId: 'rogue', level: 1)],
        ),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'rapier'),
        entry: rapier,
        classes: const [rogue],
      );

      expect(attack.ability, Ability.dexterity);
    });

    test('Acuidade respeita a escolha explícita do jogador', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 10, dexterity: 18),
        ),
        weapon: const CharacterWeapon(
          localId: 1,
          weaponId: 'rapier',
          chosenAbility: Ability.strength,
        ),
        entry: rapier,
      );

      expect(attack.ability, Ability.strength);
    });

    test('escolha impossível é ignorada e volta para a regra', () {
      // Sabedoria não é opção de nenhuma arma; guardar isso no banco não pode
      // fazer o ataque usar Sabedoria.
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 10, dexterity: 18, wisdom: 20),
        ),
        weapon: const CharacterWeapon(
          localId: 1,
          weaponId: 'rapier',
          chosenAbility: Ability.wisdom,
        ),
        entry: rapier,
      );

      expect(attack.ability, Ability.dexterity);
    });

    test('arma de corpo a corpo com Arremesso continua usando Força', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 16, dexterity: 20),
        ),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'javelin'),
        entry: javelin,
      );

      expect(attack.ability, Ability.strength);
    });
  });

  group('proficiência vem da classe', () {
    test('guerreiro é proficiente com arma marcial', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longsword'),
        entry: longsword,
        classes: const [fighter],
      );

      expect(attack.isProficient, isTrue);
    });

    test('mago não é proficiente com espada longa', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 14),
          classLevels: const [ClassLevel(classId: 'wizard', level: 5)],
        ),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longsword'),
        entry: longsword,
        classes: const [wizard],
      );

      expect(attack.isProficient, isFalse);
      // Só o modificador de Força: sem proficiência não entra o bônus.
      expect(attack.attackBonus, 2);
    });

    test('arma listada nominalmente conta, mesmo fora da categoria', () {
      // O ladino não tem armas marciais, mas tem rapieira por nome.
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'rogue', level: 1)],
        ),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'rapier'),
        entry: rapier,
        classes: const [rogue],
      );

      expect(attack.isProficient, isTrue);
    });

    test('em multiclasse as proficiências se somam', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          classLevels: const [
            ClassLevel(classId: 'wizard', level: 3),
            ClassLevel(classId: 'fighter', level: 1),
          ],
        ),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longsword'),
        entry: longsword,
        classes: const [wizard, fighter],
      );

      expect(attack.isProficient, isTrue);
    });

    test('classe do compêndio que o personagem não tem não conta', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'wizard', level: 3)],
        ),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longsword'),
        entry: longsword,
        // O guerreiro está na lista do compêndio, mas o personagem é mago.
        classes: const [wizard, fighter],
      );

      expect(attack.isProficient, isFalse);
    });

    test('override marcado na ficha vence a classe', () {
      // Existe para raça, antecedente e talento, que não estão cadastrados.
      final proficient = WeaponAttackCalculator.calculate(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'wizard', level: 1)],
        ),
        weapon: const CharacterWeapon(
          localId: 1,
          weaponId: 'longsword',
          proficiencyOverride: true,
        ),
        entry: longsword,
        classes: const [wizard],
      );

      final notProficient = WeaponAttackCalculator.calculate(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
        weapon: const CharacterWeapon(
          localId: 1,
          weaponId: 'longsword',
          proficiencyOverride: false,
        ),
        entry: longsword,
        classes: const [fighter],
      );

      expect(proficient.isProficient, isTrue);
      expect(notProficient.isProficient, isFalse);
    });

    test('sem lista de classes, só o override concede proficiência', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longsword'),
        entry: longsword,
      );

      expect(attack.isProficient, isFalse);
    });
  });

  group('arma mágica', () {
    test('o bônus entra no ataque e no dano', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 16),
          classLevels: const [ClassLevel(classId: 'fighter', level: 5)],
        ),
        weapon: const CharacterWeapon(
          localId: 1,
          weaponId: 'longsword',
          magicBonus: 1,
        ),
        entry: longsword,
        classes: const [fighter],
      );

      // FOR +3, proficiência +3, arma +1.
      expect(attack.attackBonus, 7);
      // O dano não leva proficiência: FOR +3 e arma +1.
      expect(attack.damageBonus, 4);
    });

    test('a composição sai no formato que a ficha exibe', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 16),
          classLevels: const [ClassLevel(classId: 'fighter', level: 5)],
        ),
        weapon: const CharacterWeapon(
          localId: 1,
          weaponId: 'longsword',
          magicBonus: 1,
        ),
        entry: longsword,
        classes: const [fighter],
      );

      expect(
        attack.attackExplanation,
        '+7 = +3 do atributo +3 de proficiência +1 da arma mágica',
      );
      expect(attack.damageExplanation, '1d8 + 4 de dano cortante');
    });

    test('bônus de item mágico entra separado do da arma', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 16),
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
        weapon: const CharacterWeapon(
          localId: 1,
          weaponId: 'longsword',
          magicBonus: 1,
        ),
        entry: longsword,
        classes: const [fighter],
        magicItemAttackBonus: 2,
        magicItemDamageBonus: 1,
      );

      // FOR +3, proficiência +2, arma +1, item +2.
      expect(attack.attackBonus, 8);
      expect(attack.attackExplanation, contains('+2 de item mágico'));
      // FOR +3, arma +1, item +1.
      expect(attack.damageBonus, 5);
    });

    test('sem bônus mágico a composição não cita arma mágica', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(
          abilityScores: scoresWith(strength: 16),
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longsword'),
        entry: longsword,
        classes: const [fighter],
      );

      expect(attack.attackExplanation, isNot(contains('arma mágica')));
      expect(attack.attackExplanation, isNot(contains('item mágico')));
    });
  });

  group('dado de dano', () {
    test('arma Versátil troca o dado com as duas mãos', () {
      final oneHanded = WeaponAttackCalculator.damageDiceFor(
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longsword'),
        entry: longsword,
      );
      final twoHanded = WeaponAttackCalculator.damageDiceFor(
        weapon: const CharacterWeapon(
          localId: 1,
          weaponId: 'longsword',
          twoHanded: true,
        ),
        entry: longsword,
      );

      expect(oneHanded, '1d8');
      expect(twoHanded, '1d10');
    });

    test('duas mãos numa arma sem Versátil não muda o dado', () {
      expect(
        WeaponAttackCalculator.damageDiceFor(
          weapon: const CharacterWeapon(
            localId: 1,
            weaponId: 'mace',
            twoHanded: true,
          ),
          entry: mace,
        ),
        '1d6',
      );
    });

    test('a Rede não tem dado nem linha de dano', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'net'),
        entry: net,
      );

      expect(attack.damageDice, isNull);
      expect(attack.damageExplanation, isNull);
    });

    test('modificador negativo aparece como subtração', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(abilityScores: scoresWith(strength: 6)),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longsword'),
        entry: longsword,
      );

      expect(attack.damageExplanation, '1d8 - 2 de dano cortante');
    });

    test('modificador zero não escreve "+ 0"', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longsword'),
        entry: longsword,
      );

      expect(attack.damageExplanation, '1d8 de dano cortante');
    });
  });

  group('nome exibido', () {
    test('sem apelido usa o nome do compêndio', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(),
        weapon: const CharacterWeapon(localId: 1, weaponId: 'longsword'),
        entry: longsword,
      );

      expect(attack.name, 'Espada Longa');
    });

    test('apelido do jogador vence', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(),
        weapon: const CharacterWeapon(
          localId: 1,
          weaponId: 'longsword',
          name: 'Lâmina do Alvorecer',
          magicBonus: 2,
        ),
        entry: longsword,
      );

      expect(attack.name, 'Lâmina do Alvorecer');
    });

    test('apelido em branco cai no nome do compêndio', () {
      final attack = WeaponAttackCalculator.calculate(
        character: characterFixture(),
        weapon: const CharacterWeapon(
          localId: 1,
          weaponId: 'longsword',
          name: '   ',
        ),
        entry: longsword,
      );

      expect(attack.name, 'Espada Longa');
    });
  });
}
