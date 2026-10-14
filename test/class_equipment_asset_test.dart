import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/services/armor_class_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda o asset de equipamento inicial de classe contra os erros que o
/// formato permite: id de arma que não existe no compêndio, armadura fora da
/// tabela, classe desconhecida, escolha sem opção válida e quantidade zerada.
///
/// Lê os arquivos direto do disco, como os outros testes de asset, para não
/// depender do bundle nem do binding de widgets.
void main() {
  final categoryIds = ItemCategory.values.map((item) => item.id).toSet();
  final armorIds = ArmorOption.all.map((item) => item.id).toSet();

  late List<Map<String, dynamic>> entries;
  late Map<String, Map<String, dynamic>> weapons;
  late Set<String> classIds;

  /// Todos os itens declarados em qualquer lugar de uma classe.
  List<Map<String, dynamic>> itemsOf(Map<String, dynamic> entry) {
    final result = <Map<String, dynamic>>[];

    void addAll(dynamic raw) {
      for (final item in (raw as List<dynamic>? ?? const [])) {
        result.add(Map<String, dynamic>.from(item as Map));
      }
    }

    void addPicks(dynamic raw) {
      for (final pick in (raw as List<dynamic>? ?? const [])) {
        addAll((pick as Map)['options']);
      }
    }

    addAll(entry['fixed_items']);
    addPicks(entry['fixed_picks']);

    for (final group in (entry['groups'] as List<dynamic>? ?? const [])) {
      for (final option in ((group as Map)['options'] as List<dynamic>)) {
        addAll((option as Map)['items']);
        addPicks(option['picks']);
      }
    }

    return result;
  }

  List<Map<String, dynamic>> picksOf(Map<String, dynamic> entry) {
    final result = <Map<String, dynamic>>[];

    for (final pick in (entry['fixed_picks'] as List<dynamic>? ?? const [])) {
      result.add(Map<String, dynamic>.from(pick as Map));
    }

    for (final group in (entry['groups'] as List<dynamic>? ?? const [])) {
      for (final option in ((group as Map)['options'] as List<dynamic>)) {
        for (final pick
            in ((option as Map)['picks'] as List<dynamic>? ?? const [])) {
          result.add(Map<String, dynamic>.from(pick as Map));
        }
      }
    }

    return result;
  }

  setUpAll(() {
    final file = File('assets/data/srd/class_equipment.json');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'asset de equipamento de classe não encontrado',
    );

    final decoded = jsonDecode(file.readAsStringSync());
    expect(decoded, isA<List<dynamic>>());

    entries = (decoded as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final weaponsFile = File('assets/data/srd/weapons.json');
    weapons = {
      for (final item
          in jsonDecode(weaponsFile.readAsStringSync()) as List<dynamic>)
        (item as Map)['id'] as String: Map<String, dynamic>.from(item),
    };

    final classesFile = File('assets/data/srd/classes.json');
    classIds = {
      for (final item
          in jsonDecode(classesFile.readAsStringSync()) as List<dynamic>)
        (item as Map)['id'] as String,
    };
  });

  group('cobertura das classes', () {
    test('toda classe do compêndio declara equipamento inicial', () {
      final declared = entries.map((item) => item['class_id']).toSet();

      for (final id in classIds) {
        expect(
          declared,
          contains(id),
          reason: 'classe sem equipamento cadastrado: $id',
        );
      }
    });

    test('nenhuma entrada aponta para classe inexistente', () {
      for (final entry in entries) {
        expect(
          classIds,
          contains(entry['class_id']),
          reason: 'class_id fora de classes.json: ${entry['class_id']}',
        );
      }
    });

    test('class_id é único', () {
      final ids = entries.map((item) => item['class_id']).toList();
      expect(ids.length, ids.toSet().length, reason: 'há class_id repetido');
    });

    test('same_as aponta para uma classe declarada no próprio asset', () {
      final withData = entries
          .where((item) => item['same_as'] == null)
          .map((item) => item['class_id'])
          .toSet();

      for (final entry in entries) {
        final sameAs = entry['same_as'];
        if (sameAs == null) continue;

        expect(
          withData,
          contains(sameAs),
          reason: '${entry['class_id']} aponta para $sameAs, que não tem dado',
        );
      }
    });
  });

  group('vínculo com os catálogos', () {
    test('todo weapon_id existe no compêndio de armas', () {
      for (final entry in entries) {
        for (final item in itemsOf(entry)) {
          final weaponId = item['weapon_id'];
          if (weaponId == null) continue;

          expect(
            weapons.keys,
            contains(weaponId),
            reason: '${entry['class_id']}: arma "$weaponId" não existe em '
                'weapons.json',
          );
        }
      }
    });

    test('todo armor_id existe na tabela de armaduras', () {
      for (final entry in entries) {
        for (final item in itemsOf(entry)) {
          final armorId = item['armor_id'];
          if (armorId == null) continue;

          expect(
            armorIds,
            contains(armorId),
            reason: '${entry['class_id']}: armadura "$armorId" não existe em '
                'ArmorOption',
          );
        }
      }
    });

    test('escudo usa o id reconhecido pelo gerenciamento de CA', () {
      var found = 0;

      for (final entry in entries) {
        for (final item in itemsOf(entry)) {
          if (item['shield'] != true) continue;
          found++;

          expect(
            item['id'],
            ShieldOption.id,
            reason: '${entry['class_id']}: escudo com id diferente de '
                '"${ShieldOption.id}" não seria reconhecido na CA',
          );
          expect(item['category'], ItemCategory.armor.id);
        }
      }

      // Guerreiro, Paladino, Clérigo e Druida concedem escudo.
      expect(found, greaterThanOrEqualTo(4));
    });

    test('item de arma não acumula armadura, e vice-versa', () {
      for (final entry in entries) {
        for (final item in itemsOf(entry)) {
          final isWeapon = item['weapon_id'] != null;
          final isArmor = item['armor_id'] != null || item['shield'] == true;

          expect(
            isWeapon && isArmor,
            isFalse,
            reason: '${entry['class_id']}: "${item['id']}" declara arma e '
                'armadura ao mesmo tempo, e o destino ficaria ambíguo',
          );
        }
      }
    });
  });

  group('forma dos itens', () {
    test('todo item tem id, nome e categoria conhecida', () {
      for (final entry in entries) {
        for (final item in itemsOf(entry)) {
          final id = item['id'];
          expect(id, isA<String>());
          expect((id as String).trim(), isNotEmpty);

          final name = item['name'];
          expect(name, isA<String>());
          expect((name as String).trim(), isNotEmpty);

          expect(
            categoryIds,
            contains(item['category']),
            reason: '${entry['class_id']}: categoria desconhecida em "$id"',
          );
        }
      }
    });

    test('quantidade, quando declarada, é pelo menos 1', () {
      for (final entry in entries) {
        for (final item in itemsOf(entry)) {
          final quantity = item['quantity'];
          if (quantity == null) continue;

          expect(
            quantity,
            isA<int>(),
            reason: '${entry['class_id']}: quantidade não inteira em '
                '"${item['id']}"',
          );
          expect(quantity as int, greaterThanOrEqualTo(1));
        }
      }
    });

    test('munição é categoria própria, e não arma', () {
      for (final entry in entries) {
        for (final item in itemsOf(entry)) {
          if (!const ['arrows', 'crossbow_bolts'].contains(item['id'])) {
            continue;
          }

          expect(
            item['category'],
            ItemCategory.ammunition.id,
            reason: '${entry['class_id']}: munição fora da categoria própria',
          );
          expect(
            item['weapon_id'],
            isNull,
            reason: 'munição não pode virar arma na seção de Armas',
          );
          expect(item['quantity'], 20);
        }
      }
    });
  });

  group('forma das escolhas', () {
    test('todo grupo tem ao menos duas alternativas', () {
      for (final entry in entries) {
        for (final group in (entry['groups'] as List<dynamic>? ?? const [])) {
          final options = (group as Map)['options'] as List<dynamic>;

          expect(
            options.length,
            greaterThanOrEqualTo(2),
            reason: '${entry['class_id']}/${group['id']}: grupo com uma '
                'alternativa só não é escolha',
          );
        }
      }
    });

    test('toda alternativa entrega item ou pede escolha', () {
      for (final entry in entries) {
        for (final group in (entry['groups'] as List<dynamic>? ?? const [])) {
          for (final option in ((group as Map)['options'] as List<dynamic>)) {
            final items = (option as Map)['items'] as List<dynamic>?;
            final picks = option['picks'] as List<dynamic>?;

            expect(
              (items?.isNotEmpty ?? false) || (picks?.isNotEmpty ?? false),
              isTrue,
              reason: '${entry['class_id']}/${group['id']}/${option['id']}: '
                  'alternativa vazia',
            );
          }
        }
      }
    });

    test('toda escolha complementar tem categoria de arma ou lista própria',
        () {
      for (final entry in entries) {
        for (final pick in picksOf(entry)) {
          final hasCategory = pick['weapon_category'] != null;
          final hasOptions =
              (pick['options'] as List<dynamic>? ?? const []).isNotEmpty;

          expect(
            hasCategory || hasOptions,
            isTrue,
            reason: '${entry['class_id']}: escolha "${pick['id']}" não tem o '
                'que oferecer e travaria a criação',
          );
          expect(
            hasCategory && hasOptions,
            isFalse,
            reason: '${entry['class_id']}: escolha "${pick['id']}" declara '
                'categoria e lista, e as duas fontes poderiam divergir',
          );

          final count = pick['count'];
          if (count != null) expect(count as int, greaterThanOrEqualTo(1));

          expect(
            (pick['label'] as String?)?.trim() ?? '',
            isNotEmpty,
            reason: '${entry['class_id']}: escolha sem rótulo não diz ao '
                'jogador o que escolher',
          );
        }
      }
    });

    test('categoria de arma usada existe no compêndio', () {
      final categories = {
        for (final item in weapons.values) item['category'] as String,
      };
      final ranges = {
        for (final item in weapons.values) item['range_type'] as String,
      };

      for (final entry in entries) {
        for (final pick in picksOf(entry)) {
          final category = pick['weapon_category'];
          if (category == null) continue;

          expect(categories, contains(category));

          final range = pick['range_type'];
          if (range != null) expect(ranges, contains(range));
        }
      }
    });

    test('ids de grupo e de alternativa são únicos dentro da classe', () {
      for (final entry in entries) {
        final groupIds = <String>{};

        for (final group in (entry['groups'] as List<dynamic>? ?? const [])) {
          final groupId = (group as Map)['id'] as String;
          expect(
            groupIds.add(groupId),
            isTrue,
            reason: '${entry['class_id']}: grupo repetido "$groupId"',
          );

          final optionIds = <String>{};
          for (final option in (group['options'] as List<dynamic>)) {
            final optionId = (option as Map)['id'] as String;
            expect(
              optionIds.add(optionId),
              isTrue,
              reason: '${entry['class_id']}/$groupId: alternativa repetida '
                  '"$optionId"',
            );
          }
        }
      }
    });
  });

  group('o dado bate com o livro', () {
    Map<String, dynamic> byId(String id) =>
        entries.firstWhere((item) => item['class_id'] == id);

    test('Guerreiro tem os quatro grupos e nenhum item fixo', () {
      final fighter = byId('fighter');

      expect((fighter['groups'] as List<dynamic>).length, 4);
      expect(fighter['fixed_items'], isNull);
      expect(fighter['fixed_picks'], isNull);

      final groups = {
        for (final group in (fighter['groups'] as List<dynamic>))
          (group as Map)['id'] as String: group,
      };

      // Grupo 2: uma arma marcial e um escudo, ou duas armas marciais.
      final martial = groups['martial']!;
      final options = {
        for (final option in (martial['options'] as List<dynamic>))
          (option as Map)['id'] as String: option,
      };

      expect(
        ((options['martial_and_shield']!['picks'] as List<dynamic>).first
            as Map)['count'],
        1,
      );
      final twoMartial =
          (options['two_martial']!['picks'] as List<dynamic>).first as Map;
      expect(twoMartial['count'], 2);
      expect(
        twoMartial['allow_duplicates'],
        isTrue,
        reason: 'o livro permite levar duas armas marciais iguais',
      );
    });

    test('Monge recebe dez dardos como arma', () {
      final monk = byId('monk');
      final dart = (monk['fixed_items'] as List<dynamic>).first as Map;

      expect(dart['weapon_id'], 'dart');
      expect(dart['quantity'], 10);
    });

    test('Artífice tem duas armas simples como escolha sem alternativa', () {
      final artificer = byId('artificer');
      final pick = (artificer['fixed_picks'] as List<dynamic>).first as Map;

      expect(pick['count'], 2);
      expect(pick['weapon_category'], 'simple');
      expect(artificer['source'], 'tcoe');
    });

    test('Bruxo tem duas escolhas independentes de arma simples', () {
      final warlock = byId('warlock');

      final fixedPick = (warlock['fixed_picks'] as List<dynamic>).first as Map;
      expect(fixedPick['weapon_category'], 'simple');

      final groups = warlock['groups'] as List<dynamic>;
      final weaponGroup = groups.firstWhere(
        (group) => (group as Map)['id'] == 'weapon',
      ) as Map;
      final anySimple = (weaponGroup['options'] as List<dynamic>).firstWhere(
        (option) => (option as Map)['id'] == 'any_simple',
      ) as Map;

      // A segunda seleção vive numa alternativa, então as chaves das duas
      // escolhas são diferentes e uma não sobrescreve a outra.
      expect(
        ((anySimple['picks'] as List<dynamic>).first as Map)['weapon_category'],
        'simple',
      );
    });

    test('Patrulheiro Revisado herda o equipamento do Patrulheiro', () {
      expect(byId('ranger_tcoe')['same_as'], 'ranger');
    });

    test('a acentuação em português foi preservada', () {
      final names = <String>[
        for (final entry in entries)
          for (final item in itemsOf(entry)) item['name'] as String,
      ];

      expect(names, contains('Ferramentas de ladrão'));
      expect(names, contains('Grimório'));
      expect(names, contains('Bastão'));
      expect(names, contains('Relicário'));
      expect(names, contains('Alaúde'));
      expect(names, contains('Machado de mão'));
    });
  });
}
