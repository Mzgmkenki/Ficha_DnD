import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_requirements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/services/skill_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

/// Requisito de Força e desvantagem em Furtividade das armaduras.
///
/// A regra de produto do DragonSheet é mais restritiva que a oficial de 2014:
/// não cumprir o requisito IMPEDE equipar, em vez de reduzir o deslocamento em
/// 3 m. Estes testes fixam essa decisão.
InventoryItem _armor(
  String id, {
  bool equipped = false,
  int? localId,
  int? strengthOverride,
  bool? stealthOverride,
  int magicBonus = 0,
  String? name,
}) {
  return InventoryItem(
    localId: localId,
    itemId: id,
    name: name ?? id,
    category: ItemCategory.armor,
    equipped: equipped,
    source: GrantSource.characterClass,
    sourceId: 'fighter',
    sourceLabel: 'Equipamento inicial da classe: Guerreiro',
    armorStrengthRequirement: strengthOverride,
    armorStealthDisadvantage: stealthOverride,
    armorMagicBonus: magicBonus,
  );
}

OwnedArmorPiece _pieceOf(List<InventoryItem> inventory, String id) =>
    OwnedArmor.wearables(inventory).firstWhere((p) => p.armor?.id == id);

void main() {
  group('a tabela declara requisito e penalidade (PHB 2014)', () {
    test('só cota de malha, talas e placas exigem Força', () {
      final withRequirement = {
        for (final armor in ArmorOption.all)
          if (armor.requiresStrength) armor.id: armor.strengthRequirement,
      };

      expect(withRequirement, {'chain_mail': 13, 'splint': 15, 'plate': 15});
    });

    test('as demais têm requisito nulo, e não zero', () {
      expect(ArmorOption.fromId('leather')!.strengthRequirement, isNull);
      expect(ArmorOption.fromId('half_plate')!.strengthRequirement, isNull);
      expect(ArmorOption.fromId('breastplate')!.requiresStrength, isFalse);
    });

    test('a lista de desvantagem em Furtividade bate com o livro', () {
      final noisy = {
        for (final armor in ArmorOption.all)
          if (armor.stealthDisadvantage) armor.id,
      };

      expect(noisy, {
        'padded',
        'scale_mail',
        'half_plate',
        'ring_mail',
        'chain_mail',
        'splint',
        'plate',
      });
    });

    test('a regra não depende do nome visível da armadura', () {
      // Peça renomeada pelo jogador: o requisito continua vindo do id.
      final inventory = [
        _armor('chain_mail', name: 'Malha do vovô', localId: 1),
      ];

      final piece = _pieceOf(inventory, 'chain_mail');
      expect(piece.name, 'Malha do vovô');
      expect(piece.strengthRequirement, 13);
      expect(piece.stealthDisadvantage, isTrue);
    });
  });

  group('bloqueio por Força', () {
    test('Força 12 não equipa cota de malha', () {
      final inventory = [_armor('chain_mail', localId: 1)];
      final piece = _pieceOf(inventory, 'chain_mail');

      final result = OwnedArmor.equipWearable(
        inventory: inventory,
        piece: piece,
        abilityScores: scoresWith(strength: 12),
      );

      expect(result.wasBlocked, isTrue);
      expect(result.blockedReason, 'Requer Força 13. Força atual: 12.');
      expect(OwnedArmor.equippedWearable(result.inventory), isNull);
    });

    test('Força 13 equipa cota de malha', () {
      final inventory = [_armor('chain_mail', localId: 1)];
      final piece = _pieceOf(inventory, 'chain_mail');

      final result = OwnedArmor.equipWearable(
        inventory: inventory,
        piece: piece,
        abilityScores: scoresWith(strength: 13),
      );

      expect(result.wasBlocked, isFalse);
      expect(result.blockedReason, isNull);
      expect(
        OwnedArmor.equippedWearable(result.inventory)?.armor?.id,
        'chain_mail',
      );
    });

    test('Força 14 não equipa armadura de placas', () {
      final inventory = [_armor('plate', localId: 1)];

      final result = OwnedArmor.equipWearable(
        inventory: inventory,
        piece: _pieceOf(inventory, 'plate'),
        abilityScores: scoresWith(strength: 14),
      );

      expect(result.wasBlocked, isTrue);
      expect(result.blockedReason, 'Requer Força 15. Força atual: 14.');
    });

    test('Força 15 equipa armadura de placas', () {
      final inventory = [_armor('plate', localId: 1)];

      final result = OwnedArmor.equipWearable(
        inventory: inventory,
        piece: _pieceOf(inventory, 'plate'),
        abilityScores: scoresWith(strength: 15),
      );

      expect(result.wasBlocked, isFalse);
      expect(OwnedArmor.equippedWearable(result.inventory)?.armor?.id, 'plate');
    });

    test('armadura sem requisito equipa com qualquer Força', () {
      final inventory = [_armor('leather', localId: 1)];

      final result = OwnedArmor.equipWearable(
        inventory: inventory,
        piece: _pieceOf(inventory, 'leather'),
        abilityScores: scoresWith(strength: 3),
      );

      expect(result.wasBlocked, isFalse);
    });

    test('a armadura bloqueada continua no inventário', () {
      final inventory = [
        _armor('plate', localId: 1),
        const InventoryItem(name: 'Corda', itemId: 'rope'),
      ];

      final result = OwnedArmor.equipWearable(
        inventory: inventory,
        piece: _pieceOf(inventory, 'plate'),
        abilityScores: scoresWith(strength: 10),
      );

      expect(result.inventory, hasLength(2));
      expect(
        result.inventory.map((item) => item.itemId),
        containsAll(<String>['plate', 'rope']),
      );
      // E continua aparecendo na lista de peças possuídas.
      expect(OwnedArmor.wearables(result.inventory), hasLength(1));
    });

    test('a armadura bloqueada não entra no cálculo da CA', () {
      // Linha marcada como equipada mas sem Força: é o estado que uma base
      // antiga ou uma ficha importada podem ter.
      final inventory = [_armor('plate', equipped: true, localId: 1)];
      final scores = scoresWith(strength: 10, dexterity: 14);

      final result = OwnedArmor.armorClass(
        inventory: inventory,
        abilityScores: scores,
      );

      // Sem armadura: 10 + DES +2. As placas dariam 18.
      expect(result.total, 12);
      expect(
        OwnedArmor.equippedWearable(inventory, abilityScores: scores),
        isNull,
      );
    });

    test('canEquip responde a mesma coisa que o motivo do bloqueio', () {
      final inventory = [_armor('splint', localId: 1)];
      final piece = _pieceOf(inventory, 'splint');

      expect(
        OwnedArmor.canEquip(
          piece: piece,
          abilityScores: scoresWith(strength: 14),
        ),
        isFalse,
      );
      expect(
        OwnedArmor.canEquip(
          piece: piece,
          abilityScores: scoresWith(strength: 15),
        ),
        isTrue,
      );
    });
  });

  group('desvantagem em Furtividade', () {
    test('brunea equipada sinaliza desvantagem', () {
      final inventory = [_armor('scale_mail', equipped: true, localId: 1)];
      final scores = scoresWith(strength: 10);

      expect(
        OwnedArmor.hasStealthDisadvantage(inventory, abilityScores: scores),
        isTrue,
      );
      expect(
        OwnedArmor.stealthDisadvantageSource(
          inventory,
          abilityScores: scores,
        )?.name,
        'scale_mail',
      );
    });

    test('peitoral equipado não causa desvantagem', () {
      final inventory = [_armor('breastplate', equipped: true, localId: 1)];

      expect(OwnedArmor.hasStealthDisadvantage(inventory), isFalse);
      expect(OwnedArmor.stealthDisadvantageSource(inventory), isNull);
    });

    test('a desvantagem não altera o bônus numérico de Furtividade', () {
      final naked = characterFixture(
        abilityScores: scoresWith(dexterity: 16),
        skillProficiencies: skillsWith({
          Skill.stealth: ProficiencyLevel.proficient,
        }),
      );

      final armored = naked.copyWith(
        inventory: [_armor('scale_mail', equipped: true, localId: 1)],
      );

      final before = SkillCalculator.skillBonus(naked, Skill.stealth);
      final after = SkillCalculator.skillBonus(armored, Skill.stealth);

      expect(after, before);
      // E a desvantagem está lá, apesar do número igual.
      expect(
        OwnedArmor.hasStealthDisadvantage(
          armored.inventory,
          abilityScores: armored.abilityScores,
        ),
        isTrue,
      );
    });

    test('a desvantagem existe mesmo com proficiência na armadura', () {
      // Proficiência com armadura evita a penalidade de conjuração, não esta.
      final inventory = [_armor('plate', equipped: true, localId: 1)];

      expect(
        OwnedArmor.hasStealthDisadvantage(
          inventory,
          abilityScores: scoresWith(strength: 15),
        ),
        isTrue,
      );
    });

    test('sai sozinha ao desequipar', () {
      final inventory = [_armor('scale_mail', equipped: true, localId: 1)];

      final next =
          OwnedArmor.equipWearable(
            inventory: inventory,
            piece: null,
            abilityScores: scoresWith(strength: 10),
          ).inventory;

      expect(OwnedArmor.hasStealthDisadvantage(next), isFalse);
    });

    test('armadura bloqueada por Força não penaliza a Furtividade', () {
      // Não está sendo usada, então não atrapalha.
      final inventory = [_armor('plate', equipped: true, localId: 1)];

      expect(
        OwnedArmor.hasStealthDisadvantage(
          inventory,
          abilityScores: scoresWith(strength: 10),
        ),
        isFalse,
      );
    });

    test('só uma peça responde pela desvantagem, sem duplicar', () {
      // Duas armaduras marcadas como equipadas (base editada à mão): vale a
      // primeira, e o aviso é único.
      final inventory = [
        _armor('scale_mail', equipped: true, localId: 1),
        _armor('plate', equipped: true, localId: 2),
      ];

      final sources =
          OwnedArmor.wearables(inventory)
              .where((piece) => piece.isEquipped && piece.stealthDisadvantage)
              .length;

      expect(sources, 2, reason: 'o estado inválido existe no dado');
      expect(
        OwnedArmor.stealthDisadvantageSource(
          inventory,
          abilityScores: scoresWith(strength: 15),
        )?.name,
        'scale_mail',
        reason: 'mas a ficha mostra um aviso só',
      );
    });
  });

  group('perder a Força desequipa e recalcula', () {
    test('a armadura sai, a CA cai e o aviso explica', () {
      final character = characterFixture(
        abilityScores: scoresWith(strength: 15, dexterity: 12),
      ).copyWith(inventory: [_armor('plate', equipped: true, localId: 1)]);

      // Com Força 15: placas valendo, CA 18.
      expect(
        OwnedArmor.armorClass(
          inventory: character.inventory,
          abilityScores: character.abilityScores,
        ).total,
        18,
      );

      // A Força cai para 12.
      final weakened = character.copyWith(
        abilityScores: scoresWith(strength: 12, dexterity: 12),
        combatStats: character.combatStats.copyWith(armorClass: 18),
      );

      final outcome = ArmorRequirements.apply(weakened);

      expect(outcome.changed, isTrue);
      expect(outcome.unequipped.map((piece) => piece.armor?.id), ['plate']);
      expect(outcome.notice, contains('requer Força 15'));
      expect(outcome.notice, contains('continua no inventário'));

      // Desequipada, mas não removida.
      expect(outcome.character.inventory, hasLength(1));
      expect(outcome.character.inventory.single.equipped, isFalse);

      // CA recalculada: 10 + DES +1.
      expect(outcome.character.combatStats.armorClass, 11);
    });

    test('nada muda quando o personagem continua cumprindo o requisito', () {
      final base = characterFixture(abilityScores: scoresWith(strength: 15));
      final character = base.copyWith(
        inventory: [_armor('plate', equipped: true, localId: 1)],
        combatStats: base.combatStats.copyWith(armorClass: 18),
      );

      final outcome = ArmorRequirements.apply(character);

      expect(outcome.changed, isFalse);
      expect(outcome.notice, isNull);
      expect(outcome.character, same(character));
    });

    test('personagem sem armadura cadastrada mantém a CA digitada à mão', () {
      // Ficha antiga: CA 18 digitada, inventário vazio. Recalcular aqui jogaria
      // fora um número que o app não tem como reconstruir.
      final base = characterFixture();
      final character = base.copyWith(
        combatStats: base.combatStats.copyWith(armorClass: 18),
      );

      final outcome = ArmorRequirements.apply(character);

      expect(outcome.changed, isFalse);
      expect(outcome.character.combatStats.armorClass, 18);
    });

    test('desequipar não mexe no escudo', () {
      final character = characterFixture(
        abilityScores: scoresWith(strength: 10, dexterity: 10),
      ).copyWith(
        inventory: [
          _armor('plate', equipped: true, localId: 1),
          InventoryItem(
            localId: 2,
            itemId: 'shield',
            name: 'Escudo',
            category: ItemCategory.armor,
            equipped: true,
          ),
        ],
      );

      final outcome = ArmorRequirements.apply(character);

      expect(OwnedArmor.hasEquippedShield(outcome.character.inventory), isTrue);
      // 10 + escudo 2.
      expect(outcome.character.combatStats.armorClass, 12);
    });
  });

  group('exceções e armadura mágica', () {
    test('a peça pode dispensar o requisito de Força sem mexer na tabela', () {
      // Placas Adamantinas que não exigem Força: exceção DESTA peça.
      final inventory = [_armor('plate', localId: 1, strengthOverride: 0)];

      final result = OwnedArmor.equipWearable(
        inventory: inventory,
        piece: _pieceOf(inventory, 'plate'),
        abilityScores: scoresWith(strength: 8),
      );

      expect(result.wasBlocked, isFalse);
      // E a armadura básica continua exigindo 15 para todas as outras fichas.
      expect(ArmorOption.fromId('plate')!.strengthRequirement, 15);
    });

    test('a peça pode dispensar a desvantagem em Furtividade', () {
      // Brunea Élfica.
      final inventory = [
        _armor(
          'scale_mail',
          equipped: true,
          localId: 1,
          stealthOverride: false,
        ),
      ];

      expect(OwnedArmor.hasStealthDisadvantage(inventory), isFalse);
      expect(ArmorOption.fromId('scale_mail')!.stealthDisadvantage, isTrue);
    });

    test('a peça pode impor desvantagem que a tabela não tem', () {
      final inventory = [
        _armor('leather', equipped: true, localId: 1, stealthOverride: true),
      ];

      expect(OwnedArmor.hasStealthDisadvantage(inventory), isTrue);
    });

    test('armadura mágica preserva o bônus de CA', () {
      final inventory = [
        _armor('chain_mail', equipped: true, localId: 1, magicBonus: 2),
      ];

      final result = OwnedArmor.armorClass(
        inventory: inventory,
        abilityScores: scoresWith(strength: 13, dexterity: 18),
      );

      // Cota de malha 16 +2, pesada: Destreza não entra.
      expect(result.total, 18);
      expect(result.explanation, contains('+2'));
    });

    test('escudo mágico soma junto com o bônus fixo do escudo', () {
      final inventory = [
        _armor('leather', equipped: true, localId: 1),
        InventoryItem(
          localId: 2,
          itemId: 'shield',
          name: 'Escudo +1',
          category: ItemCategory.armor,
          equipped: true,
          armorMagicBonus: 1,
        ),
      ];

      final result = OwnedArmor.armorClass(
        inventory: inventory,
        abilityScores: scoresWith(dexterity: 10),
      );

      // Couro 11 + escudo 2 + mágico 1.
      expect(result.total, 14);
    });

    test('o bônus mágico não dispensa o requisito de Força', () {
      final inventory = [_armor('plate', localId: 1, magicBonus: 3)];

      final result = OwnedArmor.equipWearable(
        inventory: inventory,
        piece: _pieceOf(inventory, 'plate'),
        abilityScores: scoresWith(strength: 14),
      );

      expect(result.wasBlocked, isTrue);
    });
  });

  group('compatibilidade', () {
    test('item de armadura sem os campos novos usa a tabela', () {
      // É exatamente o que a migração deixa: overrides nulos, bônus zero.
      const legacy = InventoryItem(
        localId: 1,
        itemId: 'chain_mail',
        name: 'Cota de malha',
        category: ItemCategory.armor,
        equipped: true,
      );

      final piece = _pieceOf([legacy], 'chain_mail');

      expect(piece.strengthRequirement, 13);
      expect(piece.stealthDisadvantage, isTrue);
      expect(piece.magicBonus, 0);
      expect(piece.isMagical, isFalse);
    });

    test('inventário vazio continua calculando 10 + Destreza', () {
      final result = OwnedArmor.armorClass(
        inventory: const [],
        abilityScores: scoresWith(dexterity: 14),
      );

      expect(result.total, 12);
      expect(result.stealthDisadvantage, isFalse);
    });

    test('armadura desconhecida não quebra nem participa', () {
      final inventory = [
        _armor('mithril_lendaria', equipped: true, localId: 1),
      ];

      expect(OwnedArmor.wearables(inventory), isEmpty);
      expect(
        OwnedArmor.armorClass(
          inventory: inventory,
          abilityScores: scoresWith(dexterity: 10),
        ).total,
        10,
      );
    });
  });
}
