import 'package:dnd_ficha_app/features/character/application/providers/weapon_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/spellcasting_service.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

/// Guarda os bônus estruturados dos itens mágicos.
///
/// A regra delicada: um item `+1` só aumenta ataque mágico e CD se a descrição
/// dele disser isso. O bônus de uma arma mágica afeta as jogadas de ataque e
/// dano daquela arma, e mais nada. Por isso cada efeito tem campo próprio, e
/// um campo em branco vale zero em vez de ser deduzido do nome do item.
void main() {
  CharacterMagicItem item({
    String name = 'Item',
    int weaponAttack = 0,
    int weaponDamage = 0,
    int spellAttack = 0,
    int spellSaveDc = 0,
    int? saveDc,
    int? attackBonus,
  }) {
    return CharacterMagicItem(
      localId: 1,
      name: name,
      description: '',
      spells: const [],
      saveDc: saveDc,
      attackBonus: attackBonus,
      weaponAttackBonus: weaponAttack,
      weaponDamageBonus: weaponDamage,
      spellAttackBonus: spellAttack,
      spellSaveDcBonus: spellSaveDc,
    );
  }

  group('separação dos efeitos', () {
    test('item sem bônus declarado não afeta nada', () {
      final plain = item(name: 'Escudo +1');

      expect(plain.hasBonuses, isFalse);
      expect(plain.affectsWeapons, isFalse);
      expect(plain.affectsSpellcasting, isFalse);
    });

    test('bônus de arma não vaza para conjuração', () {
      // O caso que o campo separado existe para impedir: uma arma +1 não
      // aumenta a CD das magias do personagem.
      final weapon = item(
        name: 'Espada Longa +1',
        weaponAttack: 1,
        weaponDamage: 1,
      );

      expect(weapon.affectsWeapons, isTrue);
      expect(weapon.affectsSpellcasting, isFalse);

      final bonus = SpellcastingService.itemBonuses([weapon]);
      expect(bonus.isEmpty, isTrue);
      expect(bonus.attack, 0);
      expect(bonus.saveDc, 0);
    });

    test('bônus de conjuração não vaza para arma', () {
      final rod = item(
        name: 'Bastão do Pacto +2',
        spellAttack: 2,
        spellSaveDc: 2,
      );

      expect(rod.affectsSpellcasting, isTrue);
      expect(rod.affectsWeapons, isFalse);

      final character = characterFixture(magicItems: [rod]);
      final weaponBonus = magicItemWeaponBonuses(character);

      expect(weaponBonus.attack, 0);
      expect(weaponBonus.damage, 0);
    });

    test('item pode declarar os dois lados quando a descrição manda', () {
      final both = item(
        name: 'Lâmina Arcana',
        weaponAttack: 1,
        weaponDamage: 1,
        spellAttack: 1,
        spellSaveDc: 1,
      );

      expect(both.affectsWeapons, isTrue);
      expect(both.affectsSpellcasting, isTrue);
    });
  });

  group('soma na conjuração', () {
    test('o bônus entra na CD e no ataque mágico', () {
      final scores = scoresWith(intelligence: 16);

      final sem = SpellcastingService.spellSaveDc(
        proficiencyBonus: 2,
        castingAbility: Ability.intelligence,
        scores: scores,
      );
      final com = SpellcastingService.spellSaveDc(
        proficiencyBonus: 2,
        castingAbility: Ability.intelligence,
        scores: scores,
        itemBonus: 2,
      );

      // 8 + 2 de proficiência + 3 de INT.
      expect(sem, 13);
      expect(com, 15);

      expect(
        SpellcastingService.spellAttackBonus(
          proficiencyBonus: 2,
          castingAbility: Ability.intelligence,
          scores: scores,
          itemBonus: 2,
        ),
        7,
      );
    });

    test('vários itens se acumulam e as origens ficam registradas', () {
      final bonus = SpellcastingService.itemBonuses([
        item(name: 'Bastão do Pacto +1', spellAttack: 1, spellSaveDc: 1),
        item(name: 'Manto Arcano', spellSaveDc: 1),
        // Este não conta: não declara efeito de conjuração.
        item(name: 'Espada Longa +2', weaponAttack: 2, weaponDamage: 2),
      ]);

      expect(bonus.attack, 1);
      expect(bonus.saveDc, 2);
      expect(bonus.sources, ['Bastão do Pacto +1', 'Manto Arcano']);
    });

    test('lista vazia devolve bônus vazio', () {
      final bonus = SpellcastingService.itemBonuses(const []);

      expect(bonus.isEmpty, isTrue);
      expect(bonus.sources, isEmpty);
    });

    test('bônus negativo é respeitado', () {
      // Item amaldiçoado existe; a soma não pode assumir que é sempre positiva.
      final bonus = SpellcastingService.itemBonuses([
        item(name: 'Varinha Rachada', spellAttack: -1),
      ]);

      expect(bonus.attack, -1);
      expect(bonus.isEmpty, isFalse);
    });
  });

  group('soma no ataque com arma', () {
    test('acumula os itens que declaram efeito de arma', () {
      final character = characterFixture(
        magicItems: [
          item(name: 'Luvas de Precisão', weaponAttack: 1),
          item(name: 'Anel do Impacto', weaponDamage: 2),
          // Não conta: só afeta conjuração.
          item(name: 'Manto Arcano', spellSaveDc: 1),
        ],
      );

      final bonus = magicItemWeaponBonuses(character);

      expect(bonus.attack, 1);
      expect(bonus.damage, 2);
    });

    test('personagem sem item não recebe bônus', () {
      final bonus = magicItemWeaponBonuses(characterFixture());

      expect(bonus.attack, 0);
      expect(bonus.damage, 0);
    });
  });

  group('valores absolutos continuam separados', () {
    test('CD fixa do item não é bônus', () {
      // "CD 15" impresso numa varinha não depende dos atributos de quem usa, e
      // não pode somar na CD do conjurador.
      final wand = item(name: 'Varinha de Bolas de Fogo', saveDc: 15);

      expect(wand.saveDc, 15);
      expect(wand.hasBonuses, isFalse);
      expect(SpellcastingService.itemBonuses([wand]).isEmpty, isTrue);
    });

    test('ataque fixo do item não é bônus', () {
      final staff = item(name: 'Cajado de Ataque', attackBonus: 8);

      expect(staff.attackBonus, 8);
      expect(staff.affectsWeapons, isFalse);
      expect(magicItemWeaponBonuses(characterFixture(magicItems: [staff])).attack, 0);
    });
  });

  group('copyWith', () {
    test('preserva os bônus não informados', () {
      final original = item(weaponAttack: 1, spellSaveDc: 2);
      final copy = original.copyWith(name: 'Outro');

      expect(copy.weaponAttackBonus, 1);
      expect(copy.spellSaveDcBonus, 2);
      expect(copy.name, 'Outro');
    });
  });
}
