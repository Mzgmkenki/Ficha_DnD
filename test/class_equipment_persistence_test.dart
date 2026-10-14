import 'package:dnd_ficha_app/core/database/app_database.dart' as db;
import 'package:dnd_ficha_app/features/character/data/repositories/character_repository_impl.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_equipment_selection.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_equipment_grants.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// O equipamento inicial da classe, do fim da criação até reabrir a ficha.
///
/// Usa banco de verdade (em memória) e o repositório real: é o único jeito de
/// provar que quantidade, origem e estado de equipado sobrevivem à gravação, e
/// que reabrir ou salvar de novo não duplica item.
void main() {
  const catalog = <WeaponEntry>[
    WeaponEntry(
      id: 'longsword',
      name: 'Espada Longa',
      category: WeaponCategory.martial,
      rangeType: WeaponRangeType.melee,
      damageType: WeaponDamageType.slashing,
    ),
  ];

  const equipment = ClassStartingEquipment(
    classId: 'fighter',
    className: 'Guerreiro',
    fixedItems: [
      ClassEquipmentItem(id: 'explorers_pack', name: 'Pacote de explorador'),
      ClassEquipmentItem(
        id: 'arrows',
        name: 'Flechas',
        quantity: 20,
        category: ItemCategory.ammunition,
      ),
    ],
    groups: [
      ClassEquipmentGroup(
        id: 'armor',
        label: 'Armadura inicial',
        options: [
          ClassEquipmentOption(
            id: 'chain_mail',
            label: 'Cota de malha',
            items: [
              ClassEquipmentItem(
                id: 'chain_mail',
                name: 'Cota de malha',
                armorId: 'chain_mail',
                category: ItemCategory.armor,
              ),
            ],
          ),
          ClassEquipmentOption(
            id: 'leather',
            label: 'Armadura de couro',
            items: [
              ClassEquipmentItem(
                id: 'leather',
                name: 'Armadura de couro',
                armorId: 'leather',
                category: ItemCategory.armor,
              ),
            ],
          ),
        ],
      ),
      ClassEquipmentGroup(
        id: 'martial',
        label: 'Armas marciais',
        options: [
          ClassEquipmentOption(
            id: 'two_martial',
            label: 'Duas armas marciais',
            picks: [
              ClassEquipmentPick(
                id: 'martial',
                label: 'Escolha duas armas marciais',
                count: 2,
                allowDuplicates: true,
                weaponCategory: WeaponCategory.martial,
              ),
            ],
          ),
          ClassEquipmentOption(
            id: 'single',
            label: 'Uma arma marcial',
            picks: [
              ClassEquipmentPick(
                id: 'martial',
                label: 'Escolha uma arma marcial',
                weaponCategory: WeaponCategory.martial,
              ),
            ],
          ),
        ],
      ),
    ],
  );

  late db.AppDatabase database;
  late CharacterRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = CharacterRepositoryImpl(database);
  });

  tearDown(() => database.close());

  /// A seleção completa de um Guerreiro: cota de malha e duas espadas longas.
  ClassEquipmentSelection fullSelection() {
    final key = ClassEquipmentSelection.groupPickKey(
      groupId: 'martial',
      optionId: 'two_martial',
      pickId: 'martial',
    );

    return ClassEquipmentSelection.empty
        .forClass('fighter')
        .toggleOption(groupId: 'armor', optionId: 'chain_mail')
        .toggleOption(groupId: 'martial', optionId: 'two_martial')
        .withPick(key: key, index: 0, count: 2, itemId: 'longsword')
        .withPick(key: key, index: 1, count: 2, itemId: 'longsword');
  }

  ClassEquipmentGrantResult grantsFor(ClassEquipmentSelection selection) {
    return ClassEquipmentGrants.apply(
      equipment: equipment,
      selection: selection,
      weaponCatalog: catalog,
      inventory: const [],
      weapons: const [],
      className: 'Guerreiro',
      // Força suficiente para a cota de malha (13): é o que permite ao serviço
      // vesti-la, e é o estado que este teste grava e relê.
      abilityScores: scoresWith(strength: 15),
    );
  }

  Character characterWith(ClassEquipmentGrantResult grants) {
    // Força 15: a cota de malha exige 13, e sem isso a armadura não contaria na
    // CA nem ficaria equipada (ver `OwnedArmor`).
    return characterFixture(
      id: 'novo',
      abilityScores: scoresWith(strength: 15),
    ).copyWith(inventory: grants.inventory, weapons: grants.weapons);
  }

  test('o equipamento concedido chega inteiro ao banco', () async {
    final grants = grantsFor(fullSelection());
    await repository.create(characterWith(grants));

    final saved = await repository.findById('novo');
    expect(saved, isNotNull);

    // Armas: uma linha com quantidade 2, não duas linhas iguais.
    expect(saved!.weapons, hasLength(1));
    final weapon = saved.weapons.single;
    expect(weapon.weaponId, 'longsword');
    expect(weapon.quantity, 2);
    expect(weapon.grantedQuantity, 2);
    expect(weapon.source, GrantSource.characterClass);
    expect(weapon.sourceId, 'fighter');
    expect(weapon.sourceLabel, 'Equipamento inicial da classe: Guerreiro');
    expect(weapon.grantedAtCreation, isTrue);
    expect(weapon.grantRef, 'martial|two_martial');
    expect(weapon.localId, isNotNull);

    // Inventário: pacote, munição e armadura.
    final ids = saved.inventory.map((item) => item.itemId);
    expect(
      ids,
      containsAll(<String>['explorers_pack', 'arrows', 'chain_mail']),
    );

    final arrows = saved.inventory.firstWhere(
      (item) => item.itemId == 'arrows',
    );
    expect(arrows.quantity, 20);
    expect(arrows.category, ItemCategory.ammunition);
    expect(arrows.grantRef, ClassEquipmentGrants.fixedRef);

    final armor = saved.inventory.firstWhere(
      (item) => item.itemId == 'chain_mail',
    );
    expect(armor.grantRef, 'armor|chain_mail');
  });

  test('a armadura equipada continua equipada ao reabrir', () async {
    final grants = grantsFor(fullSelection());
    await repository.create(characterWith(grants));

    final saved = await repository.findById('novo');

    final equipped = OwnedArmor.equippedWearable(saved!.inventory);
    expect(equipped, isNotNull);
    expect(equipped!.armor?.id, 'chain_mail');
    expect(
      OwnedArmor.armorClass(
        inventory: saved.inventory,
        abilityScores: saved.abilityScores,
      ).total,
      16,
    );
  });

  test(
    'reabrir e salvar de novo não duplica nem altera o equipamento',
    () async {
      final grants = grantsFor(fullSelection());
      await repository.create(characterWith(grants));

      final first = await repository.findById('novo');

      // Salva o que foi lido, como qualquer tela faz depois de uma edição
      // qualquer. O inventário é apagado e reinserido pelo repositório.
      await repository.update(first!);
      final second = await repository.findById('novo');

      expect(second!.inventory, hasLength(first.inventory.length));
      expect(second.weapons, hasLength(first.weapons.length));
      expect(
        second.inventory.map((item) => item.itemId).toSet(),
        first.inventory.map((item) => item.itemId).toSet(),
      );
      expect(second.weapons.single.quantity, 2);
      expect(second.weapons.single.grantRef, 'martial|two_martial');
    },
  );

  test(
    'reaplicar a classe sobre o que foi lido do banco não duplica',
    () async {
      final grants = grantsFor(fullSelection());
      await repository.create(characterWith(grants));

      final saved = await repository.findById('novo');

      // É o que aconteceria se a criação fosse reaberta: aplica a mesma seleção
      // sobre o estado já gravado.
      final again = ClassEquipmentGrants.apply(
        equipment: equipment,
        selection: fullSelection(),
        weaponCatalog: catalog,
        inventory: saved!.inventory,
        weapons: saved.weapons,
        className: 'Guerreiro',
      );

      expect(again.isUnchanged, isTrue);
      expect(again.inventory, hasLength(saved.inventory.length));
      expect(again.weapons, hasLength(saved.weapons.length));
      // O localId do banco é preservado, então a gravação atualiza em vez de
      // criar linha nova.
      expect(again.weapons.single.localId, saved.weapons.single.localId);
    },
  );

  test(
    'trocar a alternativa depois de gravado troca só os itens dela',
    () async {
      final grants = grantsFor(fullSelection());
      await repository.create(characterWith(grants));

      final saved = await repository.findById('novo');

      final changed = ClassEquipmentGrants.apply(
        equipment: equipment,
        selection: fullSelection().toggleOption(
          groupId: 'armor',
          optionId: 'leather',
        ),
        weaponCatalog: catalog,
        inventory: saved!.inventory,
        weapons: saved.weapons,
        className: 'Guerreiro',
      );

      await repository.update(saved.copyWith(inventory: changed.inventory));
      final reread = await repository.findById('novo');

      final ids = reread!.inventory.map((item) => item.itemId);
      expect(ids, contains('leather'));
      expect(ids, isNot(contains('chain_mail')));
      // O resto do que a classe deu continua lá.
      expect(ids, containsAll(<String>['explorers_pack', 'arrows']));
    },
  );

  test(
    'personagem antigo, sem equipamento de classe, continua abrindo',
    () async {
      // Nenhum item, nenhuma arma: é o estado de toda ficha criada antes desta
      // funcionalidade existir.
      await repository.create(characterFixture(id: 'antigo'));

      final saved = await repository.findById('antigo');

      expect(saved, isNotNull);
      expect(saved!.inventory, isEmpty);
      expect(saved.weapons, isEmpty);
      expect(OwnedArmor.from(saved.inventory), isEmpty);
      expect(
        OwnedArmor.armorClass(
          inventory: saved.inventory,
          abilityScores: saved.abilityScores,
        ).total,
        10,
      );
    },
  );

  test('arma cadastrada à mão sobrevive à troca de classe', () async {
    final grants = grantsFor(fullSelection());

    const manual = CharacterWeapon(
      localId: null,
      weaponId: 'longsword',
      name: 'Lâmina do avô',
    );

    await repository.create(
      characterWith(grants).copyWith(
        weapons: [...grants.weapons, manual],
        inventory: [
          ...grants.inventory,
          const InventoryItem(name: 'Corda de 15 m', itemId: 'rope'),
        ],
      ),
    );

    final saved = await repository.findById('novo');

    final cleared = ClassEquipmentGrants.apply(
      equipment: null,
      selection: ClassEquipmentSelection.empty.forClass('bard'),
      weaponCatalog: catalog,
      inventory: saved!.inventory,
      weapons: saved.weapons,
      className: 'Bardo',
    );

    expect(cleared.weapons, hasLength(1));
    expect(cleared.weapons.single.name, 'Lâmina do avô');
    expect(cleared.weapons.single.source, GrantSource.manual);
    expect(cleared.inventory.map((item) => item.itemId), ['rope']);
  });
}
