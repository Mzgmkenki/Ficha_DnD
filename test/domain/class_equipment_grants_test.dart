import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_equipment_selection.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_equipment_grants.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Catálogo mínimo, com o suficiente para as quatro combinações de categoria e
/// alcance que as escolhas do livro usam.
const _catalog = <WeaponEntry>[
  WeaponEntry(
    id: 'club',
    name: 'Clava',
    category: WeaponCategory.simple,
    rangeType: WeaponRangeType.melee,
    damageType: WeaponDamageType.bludgeoning,
  ),
  WeaponEntry(
    id: 'dagger',
    name: 'Adaga',
    category: WeaponCategory.simple,
    rangeType: WeaponRangeType.melee,
    damageType: WeaponDamageType.piercing,
  ),
  WeaponEntry(
    id: 'light_crossbow',
    name: 'Besta Leve',
    category: WeaponCategory.simple,
    rangeType: WeaponRangeType.ranged,
    damageType: WeaponDamageType.piercing,
  ),
  WeaponEntry(
    id: 'longsword',
    name: 'Espada Longa',
    category: WeaponCategory.martial,
    rangeType: WeaponRangeType.melee,
    damageType: WeaponDamageType.slashing,
  ),
  WeaponEntry(
    id: 'greataxe',
    name: 'Machado Grande',
    category: WeaponCategory.martial,
    rangeType: WeaponRangeType.melee,
    damageType: WeaponDamageType.slashing,
  ),
  WeaponEntry(
    id: 'longbow',
    name: 'Arco Longo',
    category: WeaponCategory.martial,
    rangeType: WeaponRangeType.ranged,
    damageType: WeaponDamageType.piercing,
  ),
];

const _chainMail = ClassEquipmentItem(
  id: 'chain_mail',
  name: 'Cota de malha',
  armorId: 'chain_mail',
  category: ItemCategory.armor,
);

const _leather = ClassEquipmentItem(
  id: 'leather',
  name: 'Armadura de couro',
  armorId: 'leather',
  category: ItemCategory.armor,
);

const _shield = ClassEquipmentItem(
  id: 'shield',
  name: 'Escudo',
  isShield: true,
  category: ItemCategory.armor,
);

const _arrows = ClassEquipmentItem(
  id: 'arrows',
  name: 'Flechas',
  quantity: 20,
  category: ItemCategory.ammunition,
);

const _longbow = ClassEquipmentItem(
  id: 'longbow',
  name: 'Arco longo',
  weaponId: 'longbow',
  category: ItemCategory.weapon,
);

const _pack = ClassEquipmentItem(
  id: 'explorers_pack',
  name: 'Pacote de explorador',
  category: ItemCategory.gear,
);

/// Só itens fixos: um pacote e uma arma com quantidade.
const _fixedOnly = ClassStartingEquipment(
  classId: 'monk',
  className: 'Monge',
  fixedItems: [
    _pack,
    ClassEquipmentItem(
      id: 'dart',
      name: 'Dardo',
      quantity: 10,
      weaponId: 'dagger',
      category: ItemCategory.weapon,
    ),
  ],
);

/// Dois itens simples como alternativa.
const _twoItems = ClassStartingEquipment(
  classId: 'rogue',
  className: 'Ladino',
  groups: [
    ClassEquipmentGroup(
      id: 'weapon',
      label: 'Arma inicial',
      options: [
        ClassEquipmentOption(
          id: 'longsword',
          label: 'Espada longa',
          items: [
            ClassEquipmentItem(
              id: 'longsword',
              name: 'Espada longa',
              weaponId: 'longsword',
              category: ItemCategory.weapon,
            ),
          ],
        ),
        ClassEquipmentOption(
          id: 'dagger',
          label: 'Adaga',
          items: [
            ClassEquipmentItem(
              id: 'dagger',
              name: 'Adaga',
              weaponId: 'dagger',
              category: ItemCategory.weapon,
            ),
          ],
        ),
      ],
    ),
  ],
);

/// O Guerreiro reduzido ao essencial: pacote contra item único, arma por
/// categoria com escudo, e duas armas marciais.
const _fighter = ClassStartingEquipment(
  classId: 'fighter',
  className: 'Guerreiro',
  groups: [
    ClassEquipmentGroup(
      id: 'armor',
      label: 'Armadura inicial',
      options: [
        ClassEquipmentOption(
          id: 'chain_mail',
          label: 'Cota de malha',
          items: [_chainMail],
        ),
        ClassEquipmentOption(
          id: 'leather_longbow',
          label: 'Armadura de couro, arco longo e 20 flechas',
          items: [_leather, _longbow, _arrows],
        ),
      ],
    ),
    ClassEquipmentGroup(
      id: 'martial',
      label: 'Armas marciais',
      options: [
        ClassEquipmentOption(
          id: 'martial_and_shield',
          label: 'Uma arma marcial e um escudo',
          items: [_shield],
          picks: [
            ClassEquipmentPick(
              id: 'martial',
              label: 'Escolha uma arma marcial',
              weaponCategory: WeaponCategory.martial,
            ),
          ],
        ),
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
      ],
    ),
  ],
);

/// Escolha complementar com lista própria, como o foco arcano.
const _withExplicitPick = ClassStartingEquipment(
  classId: 'wizard',
  className: 'Mago',
  fixedPicks: [
    ClassEquipmentPick(
      id: 'arcane_focus',
      label: 'Escolha um foco arcano',
      explicitOptions: [
        ClassEquipmentItem(id: 'wand', name: 'Varinha'),
        ClassEquipmentItem(id: 'orb', name: 'Orbe'),
      ],
    ),
  ],
);

/// Grupo que só existe depois de uma alternativa de outro grupo.
const _dependent = ClassStartingEquipment(
  classId: 'dependent',
  className: 'Dependente',
  groups: [
    ClassEquipmentGroup(
      id: 'base',
      label: 'Base',
      options: [
        ClassEquipmentOption(
          id: 'with_extra',
          label: 'Com extra',
          items: [_pack],
        ),
        ClassEquipmentOption(id: 'plain', label: 'Simples', items: [_leather]),
      ],
    ),
    ClassEquipmentGroup(
      id: 'extra',
      label: 'Extra',
      requiresOptionId: 'with_extra',
      options: [
        ClassEquipmentOption(id: 'shield', label: 'Escudo', items: [_shield]),
        ClassEquipmentOption(id: 'arrows', label: 'Flechas', items: [_arrows]),
      ],
    ),
  ],
);

InventoryItem _manualItem() =>
    const InventoryItem(name: 'Corda de 15 m', itemId: 'rope', quantity: 1);

InventoryItem _backgroundItem() => const InventoryItem(
  name: 'Pé de cabra',
  itemId: 'crowbar',
  source: GrantSource.background,
  sourceId: 'criminal',
  sourceLabel: 'Antecedente: Criminoso',
  grantedAtCreation: true,
  grantedQuantity: 1,
);

CharacterWeapon _manualWeapon() => const CharacterWeapon(
  localId: 9,
  weaponId: 'club',
  notes: 'herança do pai',
);

/// Força suficiente para qualquer armadura: o requisito de Força tem arquivo
/// de teste próprio, e aqui ele só atrapalharia o que está sendo verificado.
final _strong = AbilityScores(
  strength: 20,
  dexterity: 10,
  constitution: 10,
  intelligence: 10,
  wisdom: 10,
  charisma: 10,
);

ClassEquipmentGrantResult _apply({
  required ClassStartingEquipment? equipment,
  required ClassEquipmentSelection selection,
  List<InventoryItem> inventory = const [],
  List<CharacterWeapon> weapons = const [],
  String className = '',
}) {
  return ClassEquipmentGrants.apply(
    equipment: equipment,
    selection: selection,
    weaponCatalog: _catalog,
    inventory: inventory,
    weapons: weapons,
    className: className.isEmpty ? (equipment?.className ?? '') : className,
    // Com atributos informados, o serviço veste a armadura concedida quando
    // pode — é o comportamento que estes testes verificam.
    abilityScores: _strong,
  );
}

InventoryItem _itemById(List<InventoryItem> list, String id) =>
    list.firstWhere((item) => item.itemId == id);

CharacterWeapon _weaponById(List<CharacterWeapon> list, String id) =>
    list.firstWhere((item) => item.weaponId == id);

void main() {
  group('classe só com itens fixos', () {
    test('concede tudo sem exigir escolha', () {
      final selection = ClassEquipmentSelection.empty.forClass('monk');

      expect(selection.pendingLabels(_fixedOnly, _catalog), isEmpty);
      expect(selection.isComplete(_fixedOnly, _catalog), isTrue);

      final result = _apply(equipment: _fixedOnly, selection: selection);

      expect(result.inventory, hasLength(1));
      expect(result.weapons, hasLength(1));
      expect(
        _itemById(result.inventory, 'explorers_pack').name,
        'Pacote de explorador',
      );
    });

    test('registra origem, classe e referência do que é automático', () {
      final result = _apply(
        equipment: _fixedOnly,
        selection: ClassEquipmentSelection.empty.forClass('monk'),
      );

      final pack = _itemById(result.inventory, 'explorers_pack');
      expect(pack.source, GrantSource.characterClass);
      expect(pack.sourceId, 'monk');
      expect(pack.sourceLabel, 'Equipamento inicial da classe: Monge');
      expect(pack.grantedAtCreation, isTrue);
      expect(pack.grantRef, ClassEquipmentGrants.fixedRef);
      expect(pack.isGranted, isTrue);
    });

    test(
      'item com quantidade maior que um preserva a quantidade concedida',
      () {
        final result = _apply(
          equipment: _fixedOnly,
          selection: ClassEquipmentSelection.empty.forClass('monk'),
        );

        final darts = result.weapons.single;
        expect(darts.quantity, 10);
        expect(darts.grantedQuantity, 10);
        expect(darts.divergedFromGrant, isFalse);
      },
    );
  });

  group('escolha entre dois itens', () {
    test('nada é concedido antes de escolher', () {
      final selection = ClassEquipmentSelection.empty.forClass('rogue');

      expect(selection.pendingLabels(_twoItems, _catalog), hasLength(1));

      final result = _apply(equipment: _twoItems, selection: selection);
      expect(result.inventory, isEmpty);
      expect(result.weapons, isEmpty);
    });

    test('a alternativa escolhida é a única concedida', () {
      final selection = ClassEquipmentSelection.empty
          .forClass('rogue')
          .toggleOption(groupId: 'weapon', optionId: 'dagger');

      final result = _apply(equipment: _twoItems, selection: selection);

      expect(result.weapons, hasLength(1));
      expect(result.weapons.single.weaponId, 'dagger');
      expect(result.weapons.single.grantRef, 'weapon|dagger');
    });

    test('escolha pendente impede concluir, e a mensagem diz o que falta', () {
      final error = ClassEquipmentSelection.empty
          .forClass('rogue')
          .validationError(_twoItems, _catalog);

      expect(error, isNotNull);
      expect(error, contains('Arma inicial'));
    });
  });

  group('escolha entre pacotes', () {
    test('o pacote concede todos os itens dele, com os destinos certos', () {
      final selection = ClassEquipmentSelection.empty
          .forClass('fighter')
          .toggleOption(groupId: 'armor', optionId: 'leather_longbow');

      final result = _apply(equipment: _fighter, selection: selection);

      // Arco longo vai para Armas; couro e flechas para o inventário.
      expect(result.weapons.map((item) => item.weaponId), ['longbow']);
      expect(
        result.inventory.map((item) => item.itemId),
        containsAll(<String>['leather', 'arrows']),
      );
    });

    test('munição vai para o inventário com a quantidade, não para Armas', () {
      final result = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'armor', optionId: 'leather_longbow'),
      );

      final arrows = _itemById(result.inventory, 'arrows');
      expect(arrows.quantity, 20);
      expect(arrows.category, ItemCategory.ammunition);
      expect(result.weapons.any((item) => item.weaponId == 'arrows'), isFalse);
    });

    test('armadura do pacote é reconhecida pelo gerenciamento de CA', () {
      final result = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'armor', optionId: 'chain_mail'),
      );

      final pieces = OwnedArmor.wearables(result.inventory);
      expect(pieces, hasLength(1));
      expect(pieces.single.armor?.id, 'chain_mail');
      expect(pieces.single.armor?.baseArmorClass, 16);
      expect(pieces.single.originLabel, contains('Guerreiro'));
    });

    test('escudo do pacote é reconhecido como escudo, e não como armadura', () {
      final result = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'martial', optionId: 'martial_and_shield')
            .withPick(
              key: ClassEquipmentSelection.groupPickKey(
                groupId: 'martial',
                optionId: 'martial_and_shield',
                pickId: 'martial',
              ),
              index: 0,
              count: 1,
              itemId: 'longsword',
            ),
      );

      expect(OwnedArmor.shields(result.inventory), hasLength(1));
      expect(OwnedArmor.wearables(result.inventory), isEmpty);
      expect(OwnedArmor.hasEquippedShield(result.inventory), isTrue);
    });

    test('item comum do pacote vai para o inventário', () {
      final result = _apply(
        equipment: _fixedOnly,
        selection: ClassEquipmentSelection.empty.forClass('monk'),
      );

      final pack = _itemById(result.inventory, 'explorers_pack');
      expect(pack.category, ItemCategory.gear);
    });
  });

  group('escolha por categoria', () {
    test('as opções saem do catálogo, filtradas pela categoria', () {
      final pick = _fighter.groups[1].options[1].picks.single;
      final options = pick.resolveOptions(_catalog).map((item) => item.id);

      expect(
        options,
        containsAll(<String>['longsword', 'greataxe', 'longbow']),
      );
      expect(options, isNot(contains('club')));
    });

    test(
      'filtra também por alcance quando a alternativa pede corpo a corpo',
      () {
        const melee = ClassEquipmentPick(
          id: 'martial_melee',
          label: 'Escolha uma arma marcial corpo a corpo',
          weaponCategory: WeaponCategory.martial,
          rangeType: WeaponRangeType.melee,
        );

        final options = melee.resolveOptions(_catalog).map((item) => item.id);

        expect(options, containsAll(<String>['longsword', 'greataxe']));
        expect(options, isNot(contains('longbow')));
      },
    );

    test('a arma escolhida entra em Armas com a origem da classe', () {
      final result = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'martial', optionId: 'martial_and_shield')
            .withPick(
              key: ClassEquipmentSelection.groupPickKey(
                groupId: 'martial',
                optionId: 'martial_and_shield',
                pickId: 'martial',
              ),
              index: 0,
              count: 1,
              itemId: 'greataxe',
            ),
      );

      final axe = _weaponById(result.weapons, 'greataxe');
      expect(axe.source, GrantSource.characterClass);
      expect(axe.sourceId, 'fighter');
      expect(axe.originLabel, 'Equipamento inicial da classe: Guerreiro');
      expect(axe.grantRef, 'martial|martial_and_shield');
    });

    test('escolha por lista própria concede o item escolhido', () {
      final selection = ClassEquipmentSelection.empty
          .forClass('wizard')
          .withPick(
            key: ClassEquipmentSelection.fixedPickKey('arcane_focus'),
            index: 0,
            count: 1,
            itemId: 'orb',
          );

      final result = _apply(equipment: _withExplicitPick, selection: selection);

      expect(result.inventory.single.itemId, 'orb');
      expect(result.inventory.single.name, 'Orbe');
    });
  });

  group('escolha de duas armas', () {
    String pickKey() => ClassEquipmentSelection.groupPickKey(
      groupId: 'martial',
      optionId: 'two_martial',
      pickId: 'martial',
    );

    ClassEquipmentSelection twoMartial({String? first, String? second}) {
      // A armadura entra resolvida: sem isso o grupo dela também ficaria
      // pendente, e a contagem de pendências não diria nada sobre as armas.
      var selection = ClassEquipmentSelection.empty
          .forClass('fighter')
          .toggleOption(groupId: 'armor', optionId: 'chain_mail')
          .toggleOption(groupId: 'martial', optionId: 'two_martial');

      if (first != null) {
        selection = selection.withPick(
          key: pickKey(),
          index: 0,
          count: 2,
          itemId: first,
        );
      }
      if (second != null) {
        selection = selection.withPick(
          key: pickKey(),
          index: 1,
          count: 2,
          itemId: second,
        );
      }

      return selection;
    }

    test('não deixa concluir com apenas uma escolhida', () {
      final selection = twoMartial(first: 'longsword');

      final pending = selection.pendingLabels(_fighter, _catalog);
      expect(pending, hasLength(1));
      expect(pending.single, contains('1 de 2 selecionadas'));
      expect(selection.isComplete(_fighter, _catalog), isFalse);
    });

    test('duas armas diferentes viram duas linhas', () {
      final result = _apply(
        equipment: _fighter,
        selection: twoMartial(first: 'longsword', second: 'greataxe'),
      );

      expect(result.weapons, hasLength(2));
      expect(_weaponById(result.weapons, 'longsword').quantity, 1);
      expect(_weaponById(result.weapons, 'greataxe').quantity, 1);
    });

    test('a mesma arma duas vezes vira uma linha com quantidade 2', () {
      final result = _apply(
        equipment: _fighter,
        selection: twoMartial(first: 'longsword', second: 'longsword'),
      );

      expect(result.weapons, hasLength(1));
      expect(result.weapons.single.quantity, 2);
      expect(result.weapons.single.grantedQuantity, 2);
    });

    test('a escolha fica completa com as duas posições preenchidas', () {
      final selection = twoMartial(first: 'longsword', second: 'greataxe');
      expect(selection.isComplete(_fighter, _catalog), isTrue);
      expect(selection.validationError(_fighter, _catalog), isNull);
    });
  });

  group('troca de alternativa', () {
    test(
      'remove os itens da alternativa anterior e mantém os outros grupos',
      () {
        final first = ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'armor', optionId: 'chain_mail')
            .toggleOption(groupId: 'martial', optionId: 'two_martial')
            .withPick(
              key: ClassEquipmentSelection.groupPickKey(
                groupId: 'martial',
                optionId: 'two_martial',
                pickId: 'martial',
              ),
              index: 0,
              count: 2,
              itemId: 'longsword',
            )
            .withPick(
              key: ClassEquipmentSelection.groupPickKey(
                groupId: 'martial',
                optionId: 'two_martial',
                pickId: 'martial',
              ),
              index: 1,
              count: 2,
              itemId: 'greataxe',
            );

        final before = _apply(equipment: _fighter, selection: first);
        expect(
          before.inventory.map((item) => item.itemId),
          contains('chain_mail'),
        );

        // Troca só a armadura.
        final second = first.toggleOption(
          groupId: 'armor',
          optionId: 'leather_longbow',
        );

        final after = _apply(
          equipment: _fighter,
          selection: second,
          inventory: before.inventory,
          weapons: before.weapons,
        );

        expect(
          after.inventory.map((item) => item.itemId),
          isNot(contains('chain_mail')),
        );
        expect(after.inventory.map((item) => item.itemId), contains('leather'));
        // As duas armas marciais do outro grupo continuam lá.
        expect(
          after.weapons.map((item) => item.weaponId),
          containsAll(<String>['longsword', 'greataxe', 'longbow']),
        );
        expect(after.removedItems.map((item) => item.itemId), ['chain_mail']);
      },
    );

    test('limpa a escolha complementar da alternativa abandonada', () {
      final selection = ClassEquipmentSelection.empty
          .forClass('fighter')
          .toggleOption(groupId: 'armor', optionId: 'chain_mail')
          .toggleOption(groupId: 'martial', optionId: 'martial_and_shield')
          .withPick(
            key: ClassEquipmentSelection.groupPickKey(
              groupId: 'martial',
              optionId: 'martial_and_shield',
              pickId: 'martial',
            ),
            index: 0,
            count: 1,
            itemId: 'longsword',
          )
          .toggleOption(groupId: 'martial', optionId: 'two_martial');

      // A espada escolhida para a outra alternativa não pode continuar
      // valendo: a escolha nova pede duas armas e começa vazia.
      expect(selection.picks, isEmpty);
      expect(
        selection.pendingLabels(_fighter, _catalog).single,
        contains('0 de 2'),
      );
    });

    test('quantidade acompanha quando duas alternativas dão a mesma arma', () {
      // Primeiro uma espada.
      final one = _apply(
        equipment: _twoItems,
        selection: ClassEquipmentSelection.empty
            .forClass('rogue')
            .toggleOption(groupId: 'weapon', optionId: 'dagger'),
      );
      expect(one.weapons.single.quantity, 1);

      // Agora a mesma arma declarada duas vezes na mesma seleção.
      final result = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'martial', optionId: 'two_martial')
            .withPick(
              key: ClassEquipmentSelection.groupPickKey(
                groupId: 'martial',
                optionId: 'two_martial',
                pickId: 'martial',
              ),
              index: 0,
              count: 2,
              itemId: 'longsword',
            )
            .withPick(
              key: ClassEquipmentSelection.groupPickKey(
                groupId: 'martial',
                optionId: 'two_martial',
                pickId: 'martial',
              ),
              index: 1,
              count: 2,
              itemId: 'longsword',
            ),
        weapons: one.weapons,
      );

      expect(_weaponById(result.weapons, 'longsword').quantity, 2);
    });
  });

  group('troca de classe', () {
    test('remove só o equipamento da classe anterior', () {
      final fighter = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'armor', optionId: 'chain_mail'),
        inventory: [_manualItem(), _backgroundItem()],
        weapons: [_manualWeapon()],
      );

      expect(fighter.inventory, hasLength(3));

      final monk = _apply(
        equipment: _fixedOnly,
        selection: fighter.selection.forClass('monk'),
        inventory: fighter.inventory,
        weapons: fighter.weapons,
      );

      final ids = monk.inventory.map((item) => item.itemId);
      expect(ids, isNot(contains('chain_mail')));
      expect(ids, contains('explorers_pack'));

      // Preservados: manual e antecedente.
      expect(ids, contains('rope'));
      expect(ids, contains('crowbar'));
      expect(monk.weapons.map((item) => item.weaponId), contains('club'));
    });

    test(
      'preserva o item da classe anterior que o jogador editou, e avisa',
      () {
        final fighter = _apply(
          equipment: _fighter,
          selection: ClassEquipmentSelection.empty
              .forClass('fighter')
              .toggleOption(groupId: 'armor', optionId: 'leather_longbow'),
        );

        // O jogador gastou flechas.
        final edited = [
          for (final item in fighter.inventory)
            if (item.itemId == 'arrows') item.withQuantity(12) else item,
        ];

        final monk = _apply(
          equipment: _fixedOnly,
          selection: fighter.selection.forClass('monk'),
          inventory: edited,
          weapons: fighter.weapons,
        );

        final arrows = _itemById(monk.inventory, 'arrows');
        expect(arrows.quantity, 12);
        expect(monk.keptDivergedItems.map((item) => item.itemId), ['arrows']);
        expect(monk.needsPlayerAttention, isTrue);
        expect(ClassEquipmentGrants.changeNotice(monk), isNotNull);

        // O que ele não mexeu saiu.
        expect(
          monk.inventory.map((item) => item.itemId),
          isNot(contains('leather')),
        );
      },
    );

    test('classe sem equipamento cadastrado limpa o que a anterior deu', () {
      final fighter = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'armor', optionId: 'chain_mail'),
        inventory: [_manualItem()],
      );

      final none = _apply(
        equipment: null,
        selection: fighter.selection.forClass('bard'),
        inventory: fighter.inventory,
        weapons: fighter.weapons,
      );

      expect(none.inventory.map((item) => item.itemId), ['rope']);
      expect(none.weapons, isEmpty);
    });

    test('a seleção da classe anterior não sobrevive à troca', () {
      final fighter = ClassEquipmentSelection.empty
          .forClass('fighter')
          .toggleOption(groupId: 'armor', optionId: 'chain_mail');

      final monk = fighter.forClass('monk');

      expect(monk.chosenOptions, isEmpty);
      expect(monk.classId, 'monk');
    });

    test('a seleção sobrevive quando a classe é reaplicada', () {
      final fighter = ClassEquipmentSelection.empty
          .forClass('fighter')
          .toggleOption(groupId: 'armor', optionId: 'chain_mail');

      expect(fighter.forClass('fighter'), same(fighter));
    });
  });

  group('prevenção de duplicação', () {
    test('aplicar duas vezes a mesma seleção não muda nada', () {
      final selection = ClassEquipmentSelection.empty
          .forClass('fighter')
          .toggleOption(groupId: 'armor', optionId: 'leather_longbow');

      final first = _apply(equipment: _fighter, selection: selection);
      final second = _apply(
        equipment: _fighter,
        selection: selection,
        inventory: first.inventory,
        weapons: first.weapons,
      );

      expect(second.inventory, hasLength(first.inventory.length));
      expect(second.weapons, hasLength(first.weapons.length));
      expect(second.isUnchanged, isTrue);
      expect(second.addedItems, isEmpty);
      expect(second.removedItems, isEmpty);
    });

    test('ir e voltar entre etapas não acumula equipamento', () {
      final selection = ClassEquipmentSelection.empty
          .forClass('monk')
          .withClassId('monk');

      var inventory = <InventoryItem>[];
      var weapons = <CharacterWeapon>[];

      // Cinco reconstruções seguidas, como rolar a tela para baixo e voltar.
      for (var i = 0; i < 5; i++) {
        final result = _apply(
          equipment: _fixedOnly,
          selection: selection,
          inventory: inventory,
          weapons: weapons,
        );
        inventory = List<InventoryItem>.from(result.inventory);
        weapons = List<CharacterWeapon>.from(result.weapons);
      }

      expect(inventory, hasLength(1));
      expect(weapons, hasLength(1));
      expect(weapons.single.quantity, 10);
    });

    test('reaplicar preserva a quantidade que o jogador mudou', () {
      final first = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'armor', optionId: 'leather_longbow'),
      );

      final edited = [
        for (final item in first.inventory)
          if (item.itemId == 'arrows') item.withQuantity(5) else item,
      ];

      final second = _apply(
        equipment: _fighter,
        selection: first.selection,
        inventory: edited,
        weapons: first.weapons,
      );

      expect(_itemById(second.inventory, 'arrows').quantity, 5);
    });

    test('preserva o estado de equipado entre aplicações', () {
      final first = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'armor', optionId: 'chain_mail'),
      );

      expect(OwnedArmor.equippedWearable(first.inventory), isNotNull);

      // O jogador desequipou a armadura.
      final unequipped =
          OwnedArmor.equipWearable(
            inventory: first.inventory,
            piece: null,
            abilityScores: _strong,
          ).inventory;

      final second = _apply(
        equipment: _fighter,
        selection: first.selection,
        inventory: unequipped,
        weapons: first.weapons,
      );

      expect(
        OwnedArmor.equippedWearable(second.inventory),
        isNull,
        reason: 'reaplicar não pode vestir de novo o que o jogador tirou',
      );
    });
  });

  group('equipar automaticamente', () {
    test('veste a única armadura concedida', () {
      final result = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'armor', optionId: 'chain_mail'),
      );

      expect(
        OwnedArmor.equippedWearable(result.inventory)?.armor?.id,
        'chain_mail',
      );
    });

    test('não troca a armadura que o personagem já vestia', () {
      final existing = const InventoryItem(
        name: 'Peitoral',
        itemId: 'breastplate',
        category: ItemCategory.armor,
        equipped: true,
        source: GrantSource.background,
        sourceId: 'noble',
      );

      final result = _apply(
        equipment: _fighter,
        selection: ClassEquipmentSelection.empty
            .forClass('fighter')
            .toggleOption(groupId: 'armor', optionId: 'chain_mail'),
        inventory: [existing],
      );

      expect(
        OwnedArmor.equippedWearable(result.inventory)?.armor?.id,
        'breastplate',
      );
      // A cota de malha fica disponível, só não vestida.
      expect(
        OwnedArmor.wearables(result.inventory).map((item) => item.armor?.id),
        containsAll(<String>['breastplate', 'chain_mail']),
      );
    });
  });

  group('grupo dependente de escolha anterior', () {
    test('só aparece depois da alternativa que o habilita', () {
      final plain = ClassEquipmentSelection.empty
          .forClass('dependent')
          .toggleOption(groupId: 'base', optionId: 'plain');

      expect(plain.visibleGroups(_dependent).map((group) => group.id), [
        'base',
      ]);
      expect(plain.pendingLabels(_dependent, _catalog), isEmpty);

      final withExtra = ClassEquipmentSelection.empty
          .forClass('dependent')
          .toggleOption(groupId: 'base', optionId: 'with_extra');

      expect(withExtra.visibleGroups(_dependent).map((group) => group.id), [
        'base',
        'extra',
      ]);
      expect(withExtra.pendingLabels(_dependent, _catalog), hasLength(1));
    });

    test('o grupo escondido não concede nada', () {
      final selection = ClassEquipmentSelection.empty
          .forClass('dependent')
          .toggleOption(groupId: 'base', optionId: 'with_extra')
          .toggleOption(groupId: 'extra', optionId: 'arrows')
          .toggleOption(groupId: 'base', optionId: 'with_extra')
          .toggleOption(groupId: 'base', optionId: 'plain');

      final result = _apply(equipment: _dependent, selection: selection);

      expect(result.inventory.map((item) => item.itemId), ['leather']);
    });
  });

  group('dado incompleto e compatibilidade', () {
    test('seleção que aponta para alternativa inexistente é descartada', () {
      final stale = ClassEquipmentSelection.empty
          .forClass('fighter')
          .toggleOption(groupId: 'armor', optionId: 'armadura_que_sumiu');

      final retained = stale.retainValidFor(_fighter, _catalog);

      expect(retained.chosenOptions, isEmpty);
      expect(retained.pendingLabels(_fighter, _catalog), isNotEmpty);
    });

    test('escolha que aponta para arma fora do catálogo é descartada', () {
      final stale = ClassEquipmentSelection.empty
          .forClass('fighter')
          .toggleOption(groupId: 'martial', optionId: 'martial_and_shield')
          .withPick(
            key: ClassEquipmentSelection.groupPickKey(
              groupId: 'martial',
              optionId: 'martial_and_shield',
              pickId: 'martial',
            ),
            index: 0,
            count: 1,
            itemId: 'espada_inventada',
          );

      final result = _apply(equipment: _fighter, selection: stale);

      expect(result.weapons, isEmpty);
      expect(result.selection.picks, isEmpty);
    });

    test('classe sem equipamento não gera pendência nem item', () {
      final selection = ClassEquipmentSelection.empty.forClass('bard');

      expect(selection.pendingLabels(null, _catalog), isEmpty);
      expect(selection.validationError(null, _catalog), isNull);

      final result = _apply(
        equipment: null,
        selection: selection,
        inventory: [_manualItem()],
      );

      expect(result.inventory, hasLength(1));
    });
  });
}
