import 'package:dnd_ficha_app/features/character/domain/entities/background_personality_choice.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency_grant.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/background_grants.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_personality.dart';
import 'package:flutter_test/flutter_test.dart';

// --------------------------------------------------------------- fixtures

PersonalityTable _table(
  String ownerId,
  PersonalityCategory category,
  int count,
) {
  return PersonalityTable(
    category: category,
    die: 'd$count',
    options: [
      for (var roll = 1; roll <= count; roll++)
        PersonalityOption(
          id: '$ownerId.${category.id}.$roll',
          category: category,
          roll: roll,
          text: 'Opção $roll de ${category.id} ($ownerId)',
        ),
    ],
  );
}

BackgroundPersonality _personality(String ownerId) {
  return BackgroundPersonality(
    sourceId: ownerId,
    traits: _table(ownerId, PersonalityCategory.trait, 8),
    ideals: _table(ownerId, PersonalityCategory.ideal, 6),
    bonds: _table(ownerId, PersonalityCategory.bond, 6),
    flaws: _table(ownerId, PersonalityCategory.flaw, 6),
    traitChoiceCount: 2,
    idealChoiceCount: 1,
    bondChoiceCount: 1,
    flawChoiceCount: 1,
  );
}

/// Criminoso: pé de cabra, roupas e 15 po.
final _criminal = BackgroundEntry(
  id: 'criminal',
  name: 'Criminoso',
  skillIds: const ['deception', 'stealth'],
  startingCurrency: const Currency(gold: 15),
  startingEquipment: const [
    BackgroundEquipmentItem(
      id: 'crowbar',
      name: 'Pé de cabra',
      category: ItemCategory.gear,
    ),
    BackgroundEquipmentItem(
      id: 'dark_hooded_clothes',
      name: 'Roupas comuns com capuz',
      category: ItemCategory.clothing,
    ),
  ],
  personality: _personality('criminal'),
);

/// Espião: variante do Criminoso, mesma tabela de personalidade.
final _spy = BackgroundEntry(
  id: 'spy',
  name: 'Espião',
  skillIds: const ['deception', 'stealth'],
  variantOf: 'criminal',
  startingCurrency: const Currency(gold: 15),
  startingEquipment: const [
    BackgroundEquipmentItem(id: 'crowbar', name: 'Pé de cabra'),
  ],
  // Compartilha a tabela: os ids das opções são os do Criminoso.
  personality: _personality('criminal'),
);

/// Acólito: tabela própria, 15 po e cinco incensos.
final _acolyte = BackgroundEntry(
  id: 'acolyte',
  name: 'Acólito',
  skillIds: const ['insight', 'religion'],
  startingCurrency: const Currency(gold: 15),
  startingEquipment: const [
    BackgroundEquipmentItem(
      id: 'incense_stick',
      name: 'Bastão de incenso',
      quantity: 5,
    ),
  ],
  personality: _personality('acolyte'),
);

const _manualItem = InventoryItem(
  localId: 100,
  name: 'Corda de cânhamo',
  quantity: 1,
  isCustom: true,
);

const _classItem = InventoryItem(
  localId: 101,
  itemId: 'explorers_pack',
  name: 'Pacote de explorador',
  source: GrantSource.characterClass,
  sourceId: 'rogue',
  sourceLabel: 'Classe: Ladino',
  grantedQuantity: 1,
);

void main() {
  group('equipamento do antecedente', () {
    test('adiciona os itens concedidos com a origem registrada', () {
      final result = BackgroundGrants.apply(
        background: _criminal,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
      );

      expect(result.inventory, hasLength(2));
      expect(result.addedItems, hasLength(2));

      final crowbar = result.inventory.firstWhere(
        (item) => item.itemId == 'crowbar',
      );
      expect(crowbar.name, 'Pé de cabra');
      expect(crowbar.source, GrantSource.background);
      expect(crowbar.sourceId, 'criminal');
      expect(crowbar.sourceLabel, 'Antecedente: Criminoso');
      expect(crowbar.grantedAtCreation, isTrue);
      expect(crowbar.grantedQuantity, 1);
    });

    test('respeita a quantidade concedida', () {
      final result = BackgroundGrants.apply(
        background: _acolyte,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
      );

      final incense = result.inventory.single;
      expect(incense.quantity, 5);
      expect(incense.grantedQuantity, 5);
    });

    test('reaplicar o mesmo antecedente nao duplica', () {
      final first = BackgroundGrants.apply(
        background: _criminal,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
      );

      final second = BackgroundGrants.apply(
        background: _criminal,
        inventory: first.inventory,
        wallet: first.wallet,
        currencyGrants: first.currencyGrants,
      );

      expect(second.inventory, hasLength(2));
      expect(second.addedItems, isEmpty);
      expect(second.removedItems, isEmpty);
      expect(second.isUnchanged, isTrue);
    });

    test('reaplicar preserva a quantidade que o jogador mudou', () {
      final first = BackgroundGrants.apply(
        background: _criminal,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
      );

      // O jogador gastou o pé de cabra.
      final spent = first.inventory
          .map(
            (item) =>
                item.itemId == 'crowbar' ? item.withQuantity(0) : item,
          )
          .toList();

      final second = BackgroundGrants.apply(
        background: _criminal,
        inventory: spent,
        wallet: first.wallet,
        currencyGrants: first.currencyGrants,
      );

      final crowbar = second.inventory.firstWhere(
        (item) => item.itemId == 'crowbar',
      );
      expect(crowbar.quantity, 0, reason: 'nao pode voltar a 1');
      expect(second.addedItems, isEmpty);
    });
  });

  group('troca de antecedente', () {
    test('remove so os itens do antecedente anterior', () {
      final withCriminal = BackgroundGrants.apply(
        background: _criminal,
        inventory: const [_manualItem, _classItem],
        wallet: const Currency(),
        currencyGrants: const [],
      );
      expect(withCriminal.inventory, hasLength(4));

      final swapped = BackgroundGrants.apply(
        background: _acolyte,
        inventory: withCriminal.inventory,
        wallet: withCriminal.wallet,
        currencyGrants: withCriminal.currencyGrants,
      );

      final ids = swapped.inventory.map((item) => item.itemId).toList();
      expect(ids, contains('incense_stick'));
      expect(ids, isNot(contains('crowbar')));
      expect(ids, isNot(contains('dark_hooded_clothes')));

      // Manual e de classe seguem intactos.
      expect(
        swapped.inventory.any((item) => item.name == 'Corda de cânhamo'),
        isTrue,
      );
      expect(
        swapped.inventory.any((item) => item.itemId == 'explorers_pack'),
        isTrue,
      );
      expect(swapped.removedItems, hasLength(2));
    });

    test('mantem o item concedido que o jogador editou, e avisa', () {
      final withCriminal = BackgroundGrants.apply(
        background: _criminal,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
      );

      // Renomeou o pé de cabra.
      final edited = withCriminal.inventory
          .map(
            (item) => item.itemId == 'crowbar'
                ? item.copyWith(name: 'Pé de cabra dobrável').markEdited()
                : item,
          )
          .toList();

      final swapped = BackgroundGrants.apply(
        background: _acolyte,
        inventory: edited,
        wallet: withCriminal.wallet,
        currencyGrants: withCriminal.currencyGrants,
      );

      expect(
        swapped.inventory.any((item) => item.name == 'Pé de cabra dobrável'),
        isTrue,
        reason: 'item editado nao pode ser apagado em silencio',
      );
      expect(swapped.keptDivergedItems, hasLength(1));
      expect(swapped.needsPlayerAttention, isTrue);
      expect(
        BackgroundGrants.changeNotice(swapped),
        contains('porque você'),
      );

      // E a origem continua consultavel.
      final kept = swapped.inventory.firstWhere(
        (item) => item.name == 'Pé de cabra dobrável',
      );
      expect(kept.originLabel, 'Antecedente: Criminoso');
    });

    test('limpar o antecedente remove o que ele concedeu', () {
      final withCriminal = BackgroundGrants.apply(
        background: _criminal,
        inventory: const [_manualItem],
        wallet: const Currency(),
        currencyGrants: const [],
      );

      final cleared = BackgroundGrants.apply(
        background: null,
        inventory: withCriminal.inventory,
        wallet: withCriminal.wallet,
        currencyGrants: withCriminal.currencyGrants,
      );

      expect(cleared.inventory, hasLength(1));
      expect(cleared.inventory.single.name, 'Corda de cânhamo');
      expect(cleared.wallet.gold, 0);
      expect(cleared.currencyGrants, isEmpty);
    });

    test('o antecedente customizavel nao concede nada', () {
      final result = BackgroundGrants.apply(
        background: BackgroundEntry.customOption,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
      );

      expect(result.inventory, isEmpty);
      expect(result.wallet.isEmpty, isTrue);
    });
  });

  group('dinheiro do antecedente', () {
    test('soma o valor inicial e registra a origem', () {
      final result = BackgroundGrants.apply(
        background: _criminal,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
      );

      expect(result.wallet.gold, 15);
      expect(result.currencyGrants, hasLength(1));
      expect(result.currencyGrants.single.sourceId, 'criminal');
      expect(
        result.currencyGrants.single.sourceLabel,
        'Antecedente: Criminoso',
      );
    });

    test('nao aplica duas vezes', () {
      final first = BackgroundGrants.apply(
        background: _criminal,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
      );
      final second = BackgroundGrants.apply(
        background: _criminal,
        inventory: first.inventory,
        wallet: first.wallet,
        currencyGrants: first.currencyGrants,
      );

      expect(second.wallet.gold, 15, reason: 'nao pode virar 30');
      expect(second.currencyGrants, hasLength(1));
    });

    test('preserva dinheiro manual e de outra fonte na troca', () {
      const classGrant = CurrencyGrant(
        source: GrantSource.characterClass,
        currency: Currency(gold: 10),
        sourceId: 'rogue',
        sourceLabel: 'Classe: Ladino',
      );

      // 40 po: 15 do antecedente, 10 da classe e 15 que o jogador somou.
      final start = BackgroundGrants.apply(
        background: _criminal,
        inventory: const [],
        wallet: const Currency(gold: 25),
        currencyGrants: const [classGrant],
      );
      expect(start.wallet.gold, 40);

      final swapped = BackgroundGrants.apply(
        background: _acolyte,
        inventory: start.inventory,
        wallet: start.wallet,
        currencyGrants: start.currencyGrants,
      );

      // Sai o 15 do Criminoso, entra o 15 do Acólito: o total não muda, mas a
      // origem registrada muda.
      expect(swapped.wallet.gold, 40);
      expect(
        swapped.currencyGrants.where(
          (g) => g.source == GrantSource.background,
        ),
        hasLength(1),
      );
      expect(
        swapped.currencyGrants
            .firstWhere((g) => g.source == GrantSource.background)
            .sourceId,
        'acolyte',
      );
      // O registro da classe sobreviveu.
      expect(
        swapped.currencyGrants.any(
          (g) => g.source == GrantSource.characterClass,
        ),
        isTrue,
      );
    });

    test('nao deixa a carteira negativa quando o dinheiro ja foi gasto', () {
      final start = BackgroundGrants.apply(
        background: _criminal,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
      );
      expect(start.wallet.gold, 15);

      // O jogador gastou tudo.
      final spent = start.copyWalletTo(const Currency(gold: 2));

      final cleared = BackgroundGrants.apply(
        background: null,
        inventory: spent.inventory,
        wallet: spent.wallet,
        currencyGrants: spent.currencyGrants,
      );

      expect(cleared.wallet.gold, 0, reason: 'cortado em zero, nunca negativo');
    });

    test('suporta moedas diferentes sem converter', () {
      final mixed = BackgroundEntry(
        id: 'mixed',
        name: 'Misto',
        skillIds: const [],
        startingCurrency: const Currency(
          copper: 7,
          silver: 3,
          electrum: 1,
          gold: 2,
          platinum: 1,
        ),
      );

      final result = BackgroundGrants.apply(
        background: mixed,
        inventory: const [],
        wallet: const Currency(silver: 1),
        currencyGrants: const [],
      );

      expect(result.wallet.copper, 7);
      expect(result.wallet.silver, 4);
      expect(result.wallet.electrum, 1);
      expect(result.wallet.gold, 2);
      expect(result.wallet.platinum, 1);
    });
  });

  group('escolhas de personalidade na troca', () {
    BackgroundPersonalitySelection selectionFor(String ownerId) {
      return BackgroundPersonalitySelection([
        BackgroundPersonalityChoice(
          category: PersonalityCategory.trait,
          optionId: '$ownerId.trait.1',
        ),
        BackgroundPersonalityChoice(
          category: PersonalityCategory.ideal,
          optionId: '$ownerId.ideal.2',
        ),
      ]);
    }

    test('descarta as escolhas que nao existem no antecedente novo', () {
      final result = BackgroundGrants.apply(
        background: _acolyte,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
        personality: selectionFor('criminal'),
      );

      expect(result.personality.isEmpty, isTrue);
      expect(result.droppedChoices, hasLength(2));
      expect(
        BackgroundGrants.changeNotice(result),
        contains('personalidade'),
      );
    });

    test('mantem as escolhas quando os dois compartilham a tabela', () {
      // Criminoso -> Espião: o livro manda a variante usar as mesmas tabelas,
      // então nada precisa ser refeito.
      final result = BackgroundGrants.apply(
        background: _spy,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
        personality: selectionFor('criminal'),
      );

      expect(result.personality.choices, hasLength(2));
      expect(result.droppedChoices, isEmpty);
      expect(BackgroundGrants.changeNotice(result), isNull);
    });

    test('texto proprio do jogador sobrevive a troca', () {
      final custom = BackgroundPersonalitySelection([
        BackgroundPersonalityChoice.custom(
          category: PersonalityCategory.flaw,
          text: 'Tenho medo de pombos.',
        ),
      ]);

      final result = BackgroundGrants.apply(
        background: _acolyte,
        inventory: const [],
        wallet: const Currency(),
        currencyGrants: const [],
        personality: custom,
      );

      expect(result.personality.choices, hasLength(1));
      expect(result.droppedChoices, isEmpty);
    });
  });
}

/// Atalho de teste: troca só a carteira, mantendo o resto do resultado.
extension on BackgroundGrantResult {
  BackgroundGrantResult copyWalletTo(Currency wallet) {
    return BackgroundGrantResult(
      inventory: inventory,
      wallet: wallet,
      currencyGrants: currencyGrants,
      personality: personality,
    );
  }
}
