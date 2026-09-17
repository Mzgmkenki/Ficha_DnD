import 'package:dnd_ficha_app/features/character/application/providers/weapon_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/spellcasting_service.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/magic_item_bonus.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

/// Guarda os bônus dos itens mágicos.
///
/// A regra delicada: um item `+1` só aumenta ataque mágico e CD se a descrição
/// dele disser isso. O bônus de uma arma mágica afeta as jogadas de ataque e
/// dano daquela arma, e mais nada. Por isso o item declara o degrau
/// ([MagicItemBonus]) e, separadamente, quais estatísticas ele afeta
/// ([MagicItemBonusTarget]) — em vez de um "bônus" único que valeria para tudo.
void main() {
  /// Item montado pelo caminho antigo, com um valor por estatística.
  ///
  /// Continua aqui de propósito depois da troca para o bônus controlado: é
  /// exatamente o caminho de migração, então estes casos provam que a ficha
  /// gravada antes continua somando o mesmo.
  CharacterMagicItem item({
    String name = 'Item',
    int weaponAttack = 0,
    int weaponDamage = 0,
    int spellAttack = 0,
    int spellSaveDc = 0,
    int? saveDc,
    int? attackBonus,
  }) {
    return CharacterMagicItem.fromLegacyBonuses(
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

  /// Item montado no formato controlado.
  CharacterMagicItem controlled({
    String name = 'Item',
    MagicItemBonus bonus = MagicItemBonus.none,
    Set<MagicItemBonusTarget> targets = const {},
    bool isEquipped = true,
    bool requiresAttunement = false,
    bool isAttuned = false,
  }) {
    return CharacterMagicItem(
      localId: 1,
      name: name,
      description: '',
      spells: const [],
      bonus: bonus,
      bonusTargets: targets,
      isEquipped: isEquipped,
      requiresAttunement: requiresAttunement,
      isAttuned: isAttuned,
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

    test('consegue limpar as cargas, que a sentinela permite', () {
      final original = controlled().copyWith(charges: 3, maxCharges: 5);
      expect(original.charges, 3);

      final zeroed = original.copyWith(charges: null);
      expect(zeroed.charges, isNull);
      // Sem sentinela isto era impossível: `?? this.charges` tratava null como
      // omissão e devolvia 3.
      expect(zeroed.maxCharges, 5);
    });
  });

  group('bônus controlado', () {
    test('sem bônus não soma nada, mesmo com estatísticas marcadas', () {
      final none = controlled(
        targets: MagicItemBonusTarget.values.toSet(),
      );

      expect(none.hasBonuses, isFalse);
      expect(none.declaresBonuses, isFalse);
      expect(none.weaponAttackBonus, 0);
      expect(none.spellSaveDcBonus, 0);
    });

    test('bônus escolhido sem estatística marcada não soma nada', () {
      // O jogador escolheu +2 e não disse onde. Somar em tudo seria justamente
      // o erro que a escolha explícita existe para evitar.
      final orphan = controlled(bonus: MagicItemBonus.plusTwo);

      expect(orphan.hasBonuses, isFalse);
      expect(orphan.weaponAttackBonus, 0);
      expect(orphan.spellAttackBonus, 0);
    });

    test('+1, +2 e +3 somam o valor do degrau', () {
      for (final entry in const {
        MagicItemBonus.plusOne: 1,
        MagicItemBonus.plusTwo: 2,
        MagicItemBonus.plusThree: 3,
      }.entries) {
        final blade = controlled(
          bonus: entry.key,
          targets: const {
            MagicItemBonusTarget.weaponAttack,
            MagicItemBonusTarget.weaponDamage,
          },
        );

        expect(blade.weaponAttackBonus, entry.value);
        expect(blade.weaponDamageBonus, entry.value);
        expect(blade.spellAttackBonus, 0);
        expect(blade.spellSaveDcBonus, 0);
      }
    });

    test('item pode afetar uma única estatística', () {
      final gloves = controlled(
        name: 'Luvas de Precisão',
        bonus: MagicItemBonus.plusOne,
        targets: const {MagicItemBonusTarget.weaponAttack},
      );

      expect(gloves.weaponAttackBonus, 1);
      expect(gloves.weaponDamageBonus, 0);
      expect(gloves.affectsWeapons, isTrue);
      expect(gloves.affectsSpellcasting, isFalse);
    });

    test('item pode afetar várias estatísticas com o mesmo degrau', () {
      // O exemplo do enunciado: +1 no ataque mágico e +1 na CD, sem tocar em
      // arma.
      final focus = controlled(
        name: 'Foco Arcano +1',
        bonus: MagicItemBonus.plusOne,
        targets: const {
          MagicItemBonusTarget.spellAttack,
          MagicItemBonusTarget.spellSaveDc,
        },
      );

      expect(focus.spellAttackBonus, 1);
      expect(focus.spellSaveDcBonus, 1);
      expect(focus.weaponAttackBonus, 0);
      expect(focus.weaponDamageBonus, 0);

      final spell = SpellcastingService.itemBonuses([focus]);
      expect(spell.attack, 1);
      expect(spell.saveDc, 1);

      final weapon = magicItemWeaponBonuses(
        characterFixture(magicItems: [focus]),
      );
      expect(weapon.attack, 0);
      expect(weapon.damage, 0);
    });

    test('arma mágica +1 não aumenta a CD das magias', () {
      // O caso mais fácil de errar, e o que o par degrau + estatísticas existe
      // para impedir.
      final sword = controlled(
        name: 'Espada Longa +1',
        bonus: MagicItemBonus.plusOne,
        targets: const {
          MagicItemBonusTarget.weaponAttack,
          MagicItemBonusTarget.weaponDamage,
        },
      );

      final spell = SpellcastingService.itemBonuses([sword]);

      expect(spell.saveDc, 0);
      expect(spell.attack, 0);
      expect(spell.isEmpty, isTrue);
    });

    test('foco mágico não aumenta ataque com arma', () {
      final focus = controlled(
        name: 'Cetro do Conjurador',
        bonus: MagicItemBonus.plusTwo,
        targets: const {
          MagicItemBonusTarget.spellAttack,
          MagicItemBonusTarget.spellSaveDc,
        },
      );

      final weapon = magicItemWeaponBonuses(
        characterFixture(magicItems: [focus]),
      );

      expect(weapon.attack, 0);
      expect(weapon.damage, 0);
    });

    test('degrau fora de 0..3 não é aceito', () {
      expect(MagicItemBonus.tryFromValue(7), isNull);
      expect(MagicItemBonus.tryFromValue(-1), isNull);
      expect(MagicItemBonus.tryFromValue(4), isNull);
      // Cai em "sem bônus" em vez de virar um +7.
      expect(MagicItemBonus.fromValue(7), MagicItemBonus.none);
    });

    test('só existem quatro opções de bônus', () {
      expect(
        MagicItemBonus.values.map((option) => option.value),
        [0, 1, 2, 3],
      );
    });
  });

  group('equipado e sintonia', () {
    test('item guardado declara o bônus mas não soma', () {
      final stowed = controlled(
        name: 'Espada Longa +2',
        bonus: MagicItemBonus.plusTwo,
        targets: const {MagicItemBonusTarget.weaponAttack},
        isEquipped: false,
      );

      expect(stowed.isActive, isFalse);
      expect(stowed.declaredBonusFor(MagicItemBonusTarget.weaponAttack), 2);
      expect(stowed.weaponAttackBonus, 0);
      expect(stowed.hasBonuses, isFalse);
      // O que o item concede continua visível na ficha.
      expect(stowed.describeDeclaredBonuses(), '+2 no ataque com arma');
    });

    test('item que exige sintonia sem estar sintonizado não soma', () {
      final unattuned = controlled(
        name: 'Manto Arcano',
        bonus: MagicItemBonus.plusOne,
        targets: const {MagicItemBonusTarget.spellSaveDc},
        requiresAttunement: true,
      );

      expect(unattuned.isActive, isFalse);
      expect(unattuned.spellSaveDcBonus, 0);
      expect(SpellcastingService.itemBonuses([unattuned]).isEmpty, isTrue);
    });

    test('sintonizado volta a somar', () {
      final attuned = controlled(
        name: 'Manto Arcano',
        bonus: MagicItemBonus.plusOne,
        targets: const {MagicItemBonusTarget.spellSaveDc},
        requiresAttunement: true,
        isAttuned: true,
      );

      expect(attuned.isActive, isTrue);
      expect(attuned.spellSaveDcBonus, 1);
      expect(SpellcastingService.itemBonuses([attuned]).saveDc, 1);
    });

    test('sintonia marcada em item que não exige não muda nada', () {
      final odd = controlled(
        bonus: MagicItemBonus.plusOne,
        targets: const {MagicItemBonusTarget.weaponAttack},
        isAttuned: true,
      );

      expect(odd.isActive, isTrue);
      expect(odd.weaponAttackBonus, 1);
    });

    test('item novo entra equipado, para a ficha migrada não mudar', () {
      expect(controlled().isEquipped, isTrue);
      expect(controlled().requiresAttunement, isFalse);
      expect(controlled().isActive, isTrue);
    });
  });

  group('conversão do formato antigo', () {
    test('valores iguais e válidos viram o degrau com as estatísticas', () {
      final converted = convertLegacyMagicItemBonuses(
        weaponAttack: 2,
        weaponDamage: 2,
        spellAttack: 0,
        spellSaveDc: 0,
      );

      expect(converted.bonus, MagicItemBonus.plusTwo);
      expect(converted.targets, {
        MagicItemBonusTarget.weaponAttack,
        MagicItemBonusTarget.weaponDamage,
      });
      expect(converted.needsReview, isFalse);
    });

    test('item sem bônus converte para sem bônus', () {
      final converted = convertLegacyMagicItemBonuses(
        weaponAttack: 0,
        weaponDamage: 0,
        spellAttack: 0,
        spellSaveDc: 0,
      );

      expect(converted.bonus, MagicItemBonus.none);
      expect(converted.targets, isEmpty);
      expect(converted.needsReview, isFalse);
    });

    test('valor negativo é preservado para revisão e continua valendo', () {
      // Item amaldiçoado não tem representação em +1..+3. Arredondar mudaria a
      // ficha do jogador sem avisar; descartar tiraria o efeito.
      final cursed = item(name: 'Varinha Rachada', spellAttack: -1);

      expect(cursed.needsBonusReview, isTrue);
      expect(cursed.spellAttackBonus, -1);
      expect(cursed.describeDeclaredBonuses(), '-1 no ataque mágico');
      expect(SpellcastingService.itemBonuses([cursed]).attack, -1);
    });

    test('valor acima de +3 é preservado para revisão', () {
      final overpowered = item(name: 'Lâmina Quebrada', weaponAttack: 7);

      expect(overpowered.needsBonusReview, isTrue);
      expect(overpowered.weaponAttackBonus, 7);
      expect(overpowered.bonus, MagicItemBonus.none);
    });

    test('valores diferentes entre estatísticas ficam para revisão', () {
      final mixed = item(
        name: 'Lâmina Estranha',
        weaponAttack: 1,
        weaponDamage: 2,
      );

      expect(mixed.needsBonusReview, isTrue);
      expect(mixed.weaponAttackBonus, 1);
      expect(mixed.weaponDamageBonus, 2);
      expect(mixed.declaredTargets, {
        MagicItemBonusTarget.weaponAttack,
        MagicItemBonusTarget.weaponDamage,
      });
    });

    test('item para revisão respeita equipado e sintonia como os outros', () {
      final cursed = CharacterMagicItem.fromLegacyBonuses(
        localId: 1,
        name: 'Varinha Rachada',
        description: '',
        spells: const [],
        spellAttackBonus: -1,
        isEquipped: false,
      );

      expect(cursed.needsBonusReview, isTrue);
      expect(cursed.declaredBonusFor(MagicItemBonusTarget.spellAttack), -1);
      expect(cursed.spellAttackBonus, 0);
    });

    test('revisar o item troca o valor antigo pelo escolhido', () {
      final mixed = item(weaponAttack: 1, weaponDamage: 2);

      final reviewed = mixed.copyWith(
        bonus: MagicItemBonus.plusOne,
        bonusTargets: const {
          MagicItemBonusTarget.weaponAttack,
          MagicItemBonusTarget.weaponDamage,
        },
        legacyBonuses: null,
      );

      expect(reviewed.needsBonusReview, isFalse);
      expect(reviewed.weaponAttackBonus, 1);
      expect(reviewed.weaponDamageBonus, 1);
    });
  });

  group('CSV das estatísticas afetadas', () {
    test('mantém a ordem do enum, não a ordem de marcação', () {
      final csv = MagicItemBonusTarget.toCsv(const {
        MagicItemBonusTarget.spellSaveDc,
        MagicItemBonusTarget.weaponAttack,
      });

      expect(csv, 'weaponAttack,spellSaveDc');
    });

    test('vai e volta', () {
      const targets = {
        MagicItemBonusTarget.weaponDamage,
        MagicItemBonusTarget.spellAttack,
      };

      expect(
        MagicItemBonusTarget.parseCsv(MagicItemBonusTarget.toCsv(targets)),
        targets,
      );
    });

    test('vazio e nulo viram conjunto vazio', () {
      expect(MagicItemBonusTarget.parseCsv(''), isEmpty);
      expect(MagicItemBonusTarget.parseCsv(null), isEmpty);
    });

    test('id desconhecido é descartado sem derrubar o resto', () {
      expect(
        MagicItemBonusTarget.parseCsv('weaponAttack,inventado,spellSaveDc'),
        {
          MagicItemBonusTarget.weaponAttack,
          MagicItemBonusTarget.spellSaveDc,
        },
      );
    });
  });
}
