import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda a tabela de armas do PHB.
///
/// A tabela foi digitada à mão a partir do livro, e um dado de dano errado
/// passa despercebido na tela: a ficha mostra um número plausível. Este teste
/// fixa as 37 armas com dado, tipo de dano e propriedades.
void main() {
  /// A tabela do PHB 2014, na ordem do livro.
  ///
  /// Formato: id -> (dado, tipo, propriedades).
  const expected = <String, (String?, String, List<String>)>{
    // Corpo a corpo simples.
    'club': ('1d4', 'bludgeoning', ['light']),
    'dagger': ('1d4', 'piercing', ['finesse', 'light', 'thrown']),
    'greatclub': ('1d8', 'bludgeoning', ['twoHanded']),
    'handaxe': ('1d6', 'slashing', ['light', 'thrown']),
    'javelin': ('1d6', 'piercing', ['thrown']),
    'light_hammer': ('1d4', 'bludgeoning', ['light', 'thrown']),
    'mace': ('1d6', 'bludgeoning', <String>[]),
    'quarterstaff': ('1d6', 'bludgeoning', ['versatile']),
    'sickle': ('1d4', 'slashing', ['light']),
    'spear': ('1d6', 'piercing', ['thrown', 'versatile']),
    // À distância simples.
    'light_crossbow': ('1d8', 'piercing', [
      'ammunition',
      'loading',
      'twoHanded',
    ]),
    'dart': ('1d4', 'piercing', ['finesse', 'thrown']),
    'shortbow': ('1d6', 'piercing', ['ammunition', 'twoHanded']),
    'sling': ('1d4', 'bludgeoning', ['ammunition']),
    // Corpo a corpo marciais.
    'battleaxe': ('1d8', 'slashing', ['versatile']),
    'flail': ('1d8', 'bludgeoning', <String>[]),
    'glaive': ('1d10', 'slashing', ['heavy', 'reach', 'twoHanded']),
    'greataxe': ('1d12', 'slashing', ['heavy', 'twoHanded']),
    'greatsword': ('2d6', 'slashing', ['heavy', 'twoHanded']),
    'halberd': ('1d10', 'slashing', ['heavy', 'reach', 'twoHanded']),
    'lance': ('1d12', 'piercing', ['reach', 'special']),
    'longsword': ('1d8', 'slashing', ['versatile']),
    'maul': ('2d6', 'bludgeoning', ['heavy', 'twoHanded']),
    'morningstar': ('1d8', 'piercing', <String>[]),
    'pike': ('1d10', 'piercing', ['heavy', 'reach', 'twoHanded']),
    'rapier': ('1d8', 'piercing', ['finesse']),
    'scimitar': ('1d6', 'slashing', ['finesse', 'light']),
    'shortsword': ('1d6', 'piercing', ['finesse', 'light']),
    'trident': ('1d6', 'piercing', ['thrown', 'versatile']),
    'war_pick': ('1d8', 'piercing', <String>[]),
    'warhammer': ('1d8', 'bludgeoning', ['versatile']),
    'whip': ('1d4', 'slashing', ['finesse', 'reach']),
    // À distância marciais.
    'blowgun': ('1', 'piercing', ['ammunition', 'loading']),
    'hand_crossbow': ('1d6', 'piercing', [
      'ammunition',
      'light',
      'loading',
    ]),
    'heavy_crossbow': ('1d10', 'piercing', [
      'ammunition',
      'heavy',
      'loading',
      'twoHanded',
    ]),
    'longbow': ('1d8', 'piercing', ['ammunition', 'heavy', 'twoHanded']),
    'net': (null, 'none', ['special', 'thrown']),
  };

  /// O dado que a arma Versátil usa com as duas mãos.
  const versatile = <String, String>{
    'quarterstaff': '1d8',
    'spear': '1d8',
    'trident': '1d8',
    'battleaxe': '1d10',
    'longsword': '1d10',
    'warhammer': '1d10',
  };

  late List<Map<String, dynamic>> weapons;

  setUpAll(() {
    final file = File('assets/data/srd/weapons.json');
    expect(file.existsSync(), isTrue, reason: 'weapons.json não encontrado');

    weapons = (jsonDecode(file.readAsStringSync()) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  });

  test('a tabela tem as 37 armas do PHB, sem id repetido', () {
    expect(weapons.length, 37);

    final ids = <String>{};
    for (final item in weapons) {
      final id = item['id'] as String;
      expect(ids.add(id), isTrue, reason: 'arma repetida: $id');
    }

    expect(ids, expected.keys.toSet());
  });

  test('dado, tipo de dano e propriedades conferem com o livro', () {
    for (final item in weapons) {
      final id = item['id'] as String;
      final (damage, damageType, properties) = expected[id]!;

      expect(item['damage'], damage, reason: '$id com dado de dano errado');
      expect(
        item['damage_type'],
        damageType,
        reason: '$id com tipo de dano errado',
      );
      expect(
        (item['properties'] as List<dynamic>).cast<String>(),
        properties,
        reason: '$id com propriedades erradas',
      );
    }
  });

  test('arma Versátil declara o dado das duas mãos, e só ela', () {
    for (final item in weapons) {
      final id = item['id'] as String;
      final properties = (item['properties'] as List<dynamic>).cast<String>();

      if (properties.contains('versatile')) {
        expect(
          item['versatile_damage'],
          versatile[id],
          reason: '$id com dado versátil errado',
        );
      } else {
        expect(
          item['versatile_damage'],
          isNull,
          reason: '$id declara dado versátil sem ter a propriedade',
        );
      }
    }
  });

  test('arma com Arremesso declara o alcance de arremesso, e só ela', () {
    for (final item in weapons) {
      final id = item['id'] as String;
      final thrown =
          (item['properties'] as List<dynamic>).contains('thrown');

      expect(
        item['thrown_range'],
        thrown ? isNotNull : isNull,
        reason: '$id com alcance de arremesso inconsistente',
      );
    }
  });

  test('arma com Munição declara o alcance de tiro, e só ela', () {
    for (final item in weapons) {
      final id = item['id'] as String;
      final ammunition =
          (item['properties'] as List<dynamic>).contains('ammunition');

      expect(
        item['range'],
        ammunition ? isNotNull : isNull,
        reason: '$id com alcance de tiro inconsistente',
      );
    }
  });

  test('arma com Especial explica o que a torna especial', () {
    // Lança de Cavalaria e Rede são as duas do PHB, e sem o texto o jogador
    // não tem como saber a regra.
    final special = weapons.where(
      (item) => (item['properties'] as List<dynamic>).contains('special'),
    );

    expect(special.map((item) => item['id']), ['lance', 'net']);

    for (final item in special) {
      expect(
        (item['special'] as String).trim(),
        isNotEmpty,
        reason: '${item['id']} sem texto de Especial',
      );
    }
  });

  test('alcance vem em metros, com o longo maior que o normal', () {
    for (final item in weapons) {
      final id = item['id'];

      for (final key in const ['range', 'thrown_range']) {
        final raw = item[key];
        if (raw == null) continue;

        final parsed = WeaponRange.tryParse(raw);
        expect(parsed, isNotNull, reason: '$id com $key ilegível');
        expect(
          parsed!.long,
          greaterThan(parsed.normal),
          reason: '$id com $key invertido',
        );
        // Em metros nenhuma arma do PHB passa de 180 m.
        expect(
          parsed.long,
          inInclusiveRange(1, 180),
          reason: '$id com $key fora da escala em metros',
        );
      }
    }
  });

  test('categoria, alcance e enums são valores conhecidos', () {
    for (final item in weapons) {
      final id = item['id'];

      expect(
        WeaponCategory.fromId(item['category'] as String?),
        isNotNull,
        reason: '$id com categoria inválida',
      );
      expect(
        WeaponRangeType.fromId(item['range_type'] as String?),
        isNotNull,
        reason: '$id com tipo de alcance inválido',
      );
      expect(
        WeaponDamageType.fromId(item['damage_type'] as String?),
        isNotNull,
        reason: '$id com tipo de dano inválido',
      );

      for (final raw in item['properties'] as List<dynamic>) {
        expect(
          WeaponProperty.fromId(raw.toString()),
          isNotNull,
          reason: '$id com propriedade desconhecida: $raw',
        );
      }
    }
  });

  test('nome em português e em inglês estão preenchidos', () {
    for (final item in weapons) {
      final id = item['id'];
      expect((item['name'] as String).trim(), isNotEmpty, reason: '$id sem nome');
      expect(
        (item['name_original'] as String).trim(),
        isNotEmpty,
        reason: '$id sem nome em inglês',
      );
    }
  });

  test('as duas listas do PHB têm o tamanho certo', () {
    int count(String category, String rangeType) {
      return weapons
          .where(
            (item) =>
                item['category'] == category &&
                item['range_type'] == rangeType,
          )
          .length;
    }

    expect(count('simple', 'melee'), 10);
    expect(count('simple', 'ranged'), 4);
    expect(count('martial', 'melee'), 18);
    expect(count('martial', 'ranged'), 5);
  });

  group('WeaponEntry', () {
    WeaponEntry entry({
      WeaponRangeType rangeType = WeaponRangeType.melee,
      List<WeaponProperty> properties = const [],
    }) {
      return WeaponEntry(
        id: 'teste',
        name: 'Teste',
        category: WeaponCategory.simple,
        rangeType: rangeType,
        damageType: WeaponDamageType.slashing,
        damage: '1d6',
        properties: properties,
      );
    }

    test('corpo a corpo exige Força', () {
      final weapon = entry();
      expect(weapon.requiredAbility, Ability.strength);
      expect(weapon.allowedAbilities, [Ability.strength]);
    });

    test('à distância exige Destreza', () {
      final weapon = entry(rangeType: WeaponRangeType.ranged);
      expect(weapon.requiredAbility, Ability.dexterity);
      expect(weapon.allowedAbilities, [Ability.dexterity]);
    });

    test('Acuidade deixa escolher entre Força e Destreza', () {
      final weapon = entry(properties: const [WeaponProperty.finesse]);
      expect(weapon.requiredAbility, isNull);
      expect(weapon.allowedAbilities, [Ability.strength, Ability.dexterity]);
    });

    test('arma de corpo a corpo arremessada continua usando Força', () {
      // Azagaia arremessada não passa a usar Destreza: a propriedade Arremesso
      // não muda o atributo, só permite jogar a arma.
      final weapon = entry(properties: const [WeaponProperty.thrown]);
      expect(weapon.requiredAbility, Ability.strength);
    });

    test('o rótulo de propriedades mostra dado versátil e alcance', () {
      const weapon = WeaponEntry(
        id: 'spear',
        name: 'Lança',
        category: WeaponCategory.simple,
        rangeType: WeaponRangeType.melee,
        damageType: WeaponDamageType.piercing,
        damage: '1d6',
        properties: [WeaponProperty.thrown, WeaponProperty.versatile],
        thrownRange: WeaponRange(normal: 6, long: 18),
        versatileDamage: '1d8',
      );

      expect(weapon.propertiesLabel, 'Arremesso (6 m/18 m), Versátil (1d8)');
    });

    test('sem propriedade nenhuma o rótulo é um travessão', () {
      expect(entry().propertiesLabel, '—');
    });

    test('a Rede não causa dano', () {
      const net = WeaponEntry(
        id: 'net',
        name: 'Rede',
        category: WeaponCategory.martial,
        rangeType: WeaponRangeType.ranged,
        damageType: WeaponDamageType.none,
        properties: [WeaponProperty.special, WeaponProperty.thrown],
      );

      expect(net.dealsDamage, isFalse);
    });
  });
}
