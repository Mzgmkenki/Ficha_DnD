import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

InventoryItem _armor(
  String id, {
  String? name,
  bool equipped = false,
  int? localId,
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
  );
}

/// Força suficiente para qualquer armadura da tabela, para os testes deste
/// arquivo não se misturarem com a regra de requisito (que tem arquivo próprio).
final _strong = scoresWith(strength: 20);

InventoryItem _shield({bool equipped = false, int? localId}) {
  return InventoryItem(
    localId: localId,
    itemId: ShieldOption.id,
    name: 'Escudo',
    category: ItemCategory.armor,
    equipped: equipped,
    source: GrantSource.characterClass,
    sourceId: 'fighter',
  );
}

void main() {
  group('reconhecimento no inventário', () {
    test('separa armadura vestível de escudo', () {
      final inventory = [_armor('chain_mail'), _shield()];

      expect(OwnedArmor.wearables(inventory), hasLength(1));
      expect(OwnedArmor.shields(inventory), hasLength(1));
      expect(OwnedArmor.wearables(inventory).single.armor?.id, 'chain_mail');
      expect(OwnedArmor.shields(inventory).single.isShield, isTrue);
    });

    test('ignora item que não é armadura', () {
      final inventory = [
        const InventoryItem(name: 'Corda', itemId: 'rope'),
        _armor('leather'),
      ];

      expect(OwnedArmor.from(inventory), hasLength(1));
    });

    test('ignora armadura cujo id não existe na tabela', () {
      // Não tem CA base: calcular exigiria inventar um número. O item continua
      // no inventário, só não participa da CA.
      final inventory = [_armor('mithril_lendaria')];

      expect(OwnedArmor.from(inventory), isEmpty);
      expect(inventory, hasLength(1));
    });

    test('"Sem armadura" não conta como peça possuída', () {
      expect(OwnedArmor.from([_armor('none')]), isEmpty);
    });

    test('preserva o nome próprio da peça', () {
      final inventory = [
        _armor('shield', name: 'Escudo de madeira'),
        _shield(),
      ];

      // O escudo de madeira do Druida é mecanicamente um escudo.
      expect(OwnedArmor.shields(inventory), hasLength(2));
      expect(OwnedArmor.shields(inventory).first.name, 'Escudo de madeira');
    });
  });

  group('a CA usa só o que está equipado', () {
    test('sem nada equipado é 10 + Destreza', () {
      final result = OwnedArmor.armorClass(
        inventory: [_armor('chain_mail'), _shield()],
        abilityScores: scoresWith(dexterity: 16),
      );

      expect(result.total, 13);
    });

    test('inventário vazio continua funcionando (personagem antigo)', () {
      final result = OwnedArmor.armorClass(
        inventory: const [],
        abilityScores: scoresWith(dexterity: 14),
      );

      expect(result.total, 12);
    });

    // A cota de malha exige Força 13: sem ela a armadura não entraria na conta,
    // que é a regra verificada em armor_requirements_test.dart. Aqui o assunto
    // é outro, então a Força é suficiente.
    test('conta a armadura equipada', () {
      final result = OwnedArmor.armorClass(
        inventory: [_armor('chain_mail', equipped: true)],
        abilityScores: scoresWith(strength: 13, dexterity: 16),
      );

      // Cota de malha 16, pesada: Destreza não entra.
      expect(result.total, 16);
    });

    test('possuir várias armaduras não soma as CAs', () {
      final result = OwnedArmor.armorClass(
        inventory: [
          _armor('chain_mail', equipped: true, localId: 1),
          _armor('leather', localId: 2),
          _armor('plate', localId: 3),
        ],
        abilityScores: scoresWith(strength: 15, dexterity: 10),
      );

      expect(result.total, 16);
    });

    test('escudo equipado soma o bônus dele', () {
      final result = OwnedArmor.armorClass(
        inventory: [
          _armor('chain_mail', equipped: true, localId: 1),
          _shield(equipped: true, localId: 2),
        ],
        abilityScores: scoresWith(strength: 13, dexterity: 10),
      );

      expect(result.total, 16 + ShieldOption.armorClassBonus);
    });

    test('escudo guardado não soma', () {
      final result = OwnedArmor.armorClass(
        inventory: [
          _armor('chain_mail', equipped: true, localId: 1),
          _shield(localId: 2),
        ],
        abilityScores: scoresWith(strength: 13, dexterity: 10),
      );

      expect(result.total, 16);
    });

    test('outros bônus entram no total', () {
      final result = OwnedArmor.armorClass(
        inventory: [_armor('leather', equipped: true)],
        abilityScores: scoresWith(dexterity: 12),
        otherBonus: 1,
      );

      // Couro 11 + DES +1 + outros +1.
      expect(result.total, 13);
    });

    test('a explicação cita a armadura equipada', () {
      final result = OwnedArmor.armorClass(
        inventory: [
          _armor('scale_mail', equipped: true, localId: 1),
          _shield(equipped: true, localId: 2),
        ],
        abilityScores: scoresWith(dexterity: 18),
      );

      expect(result.explanation, contains('Brunea 14'));
      expect(result.explanation, contains('limite +2'));
      expect(result.explanation, contains('escudo +2'));
      expect(result.total, 14 + 2 + 2);
    });
  });

  group('equipar', () {
    test('vestir uma armadura desequipa a anterior', () {
      final inventory = [
        _armor('chain_mail', equipped: true, localId: 1),
        _armor('leather', localId: 2),
      ];

      final next =
          OwnedArmor.equipWearable(
            inventory: inventory,
            piece: OwnedArmor.wearables(inventory)[1],
            abilityScores: _strong,
          ).inventory;

      expect(OwnedArmor.equippedWearable(next)?.armor?.id, 'leather');
      expect(
        next.where((item) => item.equipped),
        hasLength(1),
        reason: 'duas armaduras vestidas ao mesmo tempo não existem na regra',
      );
    });

    test('vestir armadura não mexe no escudo', () {
      final inventory = [
        _armor('leather', localId: 1),
        _shield(equipped: true, localId: 2),
      ];

      final next =
          OwnedArmor.equipWearable(
            inventory: inventory,
            piece: OwnedArmor.wearables(inventory).first,
            abilityScores: _strong,
          ).inventory;

      expect(OwnedArmor.hasEquippedShield(next), isTrue);
      expect(OwnedArmor.equippedWearable(next)?.armor?.id, 'leather');
    });

    test('passar nulo desequipa tudo', () {
      final inventory = [_armor('chain_mail', equipped: true, localId: 1)];

      final next =
          OwnedArmor.equipWearable(
            inventory: inventory,
            piece: null,
            abilityScores: _strong,
          ).inventory;

      expect(OwnedArmor.equippedWearable(next), isNull);
    });

    test('equipar escudo sem informar a peça usa o primeiro', () {
      final inventory = [_shield(localId: 1)];

      final next = OwnedArmor.setShieldEquipped(
        inventory: inventory,
        equipped: true,
      );

      expect(OwnedArmor.hasEquippedShield(next), isTrue);
    });

    test('sem escudo nenhum, ligar o interruptor não inventa um', () {
      final inventory = [_armor('leather', localId: 1)];

      final next = OwnedArmor.setShieldEquipped(
        inventory: inventory,
        equipped: true,
      );

      expect(OwnedArmor.hasEquippedShield(next), isFalse);
      expect(next, same(inventory));
    });

    test('não mexe em item de outra categoria', () {
      final inventory = [
        const InventoryItem(name: 'Tocha', itemId: 'torch', equipped: true),
        _armor('leather', localId: 2),
      ];

      final next =
          OwnedArmor.equipWearable(
            inventory: inventory,
            piece: OwnedArmor.wearables(inventory).single,
            abilityScores: _strong,
          ).inventory;

      expect(next.first.equipped, isTrue);
    });
  });

  group('limite de Destreza como dado', () {
    test('bate com o que o cálculo aplica', () {
      expect(ArmorCategory.none.maxDexBonus, isNull);
      expect(ArmorCategory.light.maxDexBonus, isNull);
      expect(ArmorCategory.medium.maxDexBonus, 2);
      expect(ArmorCategory.heavy.maxDexBonus, 0);
    });

    test('pesada ignora a Destreza em vez de limitá-la a zero', () {
      // Com teto de zero, Destreza negativa penalizaria. Não é o que a regra
      // diz: em armadura pesada a Destreza simplesmente não participa.
      final result = ArmorClassCalculator.calculate(
        armor: ArmorOption.fromId('plate')!,
        abilityScores: scoresWith(dexterity: 6),
      );

      expect(result.total, 18);
    });

    test('tem rótulo para a tela exibir', () {
      expect(ArmorCategory.medium.dexLimitLabel, contains('+2'));
      expect(ArmorCategory.heavy.dexLimitLabel, contains('não se aplica'));
    });
  });
}
