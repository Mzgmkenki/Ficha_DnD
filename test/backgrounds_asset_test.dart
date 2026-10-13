import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda o asset de antecedentes contra os erros que o formato novo permite:
/// id repetido, `personality_from` apontando para quem não tem tabela, tabela
/// com menos linhas que o dado declara, moeda desconhecida e quantidade de
/// item inválida.
///
/// Lê o arquivo direto do disco, como os outros testes de asset, para não
/// depender do bundle nem do binding de widgets.
void main() {
  const coins = {'copper', 'silver', 'electrum', 'gold', 'platinum'};

  /// Os 13 ids que já existiam antes da importação. Nenhum pode desaparecer:
  /// personagem salvo aponta para eles por id.
  const legacyIds = {
    'acolyte',
    'charlatan',
    'criminal',
    'entertainer',
    'folk_hero',
    'guild_artisan',
    'hermit',
    'noble',
    'outlander',
    'sage',
    'sailor',
    'soldier',
    'urchin',
  };

  final skillIds = Skill.values.map((skill) => skill.id).toSet();
  final categoryIds = ItemCategory.values.map((item) => item.id).toSet();

  late List<Map<String, dynamic>> backgrounds;
  late Set<String> ids;
  late Set<String> tableOwners;

  setUpAll(() {
    final file = File('assets/data/srd/backgrounds.json');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'asset de antecedentes não encontrado',
    );

    final decoded = jsonDecode(file.readAsStringSync());
    expect(decoded, isA<List<dynamic>>());

    backgrounds = (decoded as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    ids = backgrounds.map((item) => item['id'] as String).toSet();
    tableOwners = backgrounds
        .where((item) => item.containsKey('personality_traits'))
        .map((item) => item['id'] as String)
        .toSet();
  });

  test('ids são únicos', () {
    expect(ids.length, backgrounds.length, reason: 'há id repetido');
  });

  test('nenhum antecedente que já existia foi removido', () {
    for (final id in legacyIds) {
      expect(ids, contains(id), reason: 'id legado ausente: $id');
    }
  });

  test('não existe entrada com o id reservado do customizável', () {
    // A opção customizável é sintética, montada no repositório. Se aparecesse
    // no asset, o compêndio teria duas.
    expect(ids, isNot(contains('custom')));
  });

  test('todo antecedente tem nome e perícias válidas', () {
    for (final item in backgrounds) {
      final id = item['id'] as String;

      expect(
        (item['name'] as String?)?.trim().isNotEmpty,
        isTrue,
        reason: '$id sem nome',
      );

      for (final raw in (item['skills'] as List<dynamic>? ?? const [])) {
        expect(
          skillIds,
          contains(raw),
          reason: '$id declara perícia desconhecida: $raw',
        );
      }

      final choice = item['skill_choices'];
      if (choice != null) {
        final map = Map<String, dynamic>.from(choice as Map);
        expect(map['count'], isA<int>(), reason: '$id: count inválido');
        for (final raw in (map['options'] as List<dynamic>)) {
          expect(
            skillIds,
            contains(raw),
            reason: '$id: escolha de perícia desconhecida: $raw',
          );
        }
      }
    }
  });

  test('variant_of e personality_from apontam para entradas existentes', () {
    for (final item in backgrounds) {
      final id = item['id'] as String;

      final variantOf = item['variant_of'] as String?;
      if (variantOf != null) {
        expect(
          ids,
          contains(variantOf),
          reason: '$id: variant_of desconhecido ($variantOf)',
        );
      }

      final from = item['personality_from'] as String?;
      if (from != null) {
        expect(
          tableOwners,
          contains(from),
          reason: '$id: personality_from aponta para quem não tem tabela',
        );
        expect(
          item.containsKey('personality_traits'),
          isFalse,
          reason: '$id: tem personality_from E tabelas próprias',
        );
      }

      // Todo antecedente precisa de uma das duas coisas, senão a criação
      // mostraria uma seção de personalidade vazia.
      if (from == null) {
        expect(
          tableOwners,
          contains(id),
          reason: '$id: sem tabelas próprias e sem personality_from',
        );
      }
    }
  });

  test('as tabelas narrativas batem com o dado declarado', () {
    const tables = ['personality_traits', 'ideals', 'bonds', 'flaws'];

    for (final item in backgrounds) {
      final id = item['id'] as String;

      for (final key in tables) {
        final raw = item[key];
        if (raw == null) continue;

        final table = Map<String, dynamic>.from(raw as Map);
        final die = table['die'] as String;
        final options = (table['options'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        final faces = int.parse(die.substring(1));
        expect(
          options.length,
          faces,
          reason: '$id.$key: $die com ${options.length} opções',
        );

        final rolls = options.map((o) => o['roll'] as int).toSet();
        for (var face = 1; face <= faces; face++) {
          expect(rolls, contains(face), reason: '$id.$key: falta o $face');
        }

        for (final option in options) {
          expect(
            (option['text'] as String?)?.trim().isNotEmpty,
            isTrue,
            reason: '$id.$key: opção com texto vazio',
          );
        }
      }
    }
  });

  test('o padrão 2014 pede dois traços, um ideal, um vínculo e um defeito', () {
    // Quem é dono das tabelas declara as contagens. Quem reaproveita as
    // tabelas de outro herda as contagens do dono no carregamento, então não
    // precisa repeti-las — mas se repetir, tem que bater com o padrão.
    for (final item in backgrounds) {
      final id = item['id'] as String;
      final owns = item.containsKey('personality_traits');
      final inherits = item['personality_from'] != null;
      if (!owns && !inherits) continue;

      if (owns) {
        expect(item['personality_trait_choices'], 2, reason: '$id: traços');
        expect(item['ideal_choices'], 1, reason: '$id: ideal');
        expect(item['bond_choices'], 1, reason: '$id: vínculo');
        expect(item['flaw_choices'], 1, reason: '$id: defeito');
        continue;
      }

      for (final entry in const {
        'personality_trait_choices': 2,
        'ideal_choices': 1,
        'bond_choices': 1,
        'flaw_choices': 1,
      }.entries) {
        final declared = item[entry.key];
        if (declared == null) continue;
        expect(declared, entry.value, reason: '$id: ${entry.key}');
      }
    }
  });

  test('dinheiro inicial usa moedas conhecidas e não é negativo', () {
    for (final item in backgrounds) {
      final id = item['id'] as String;
      final raw = item['starting_currency'];
      if (raw == null) continue;

      final map = Map<String, dynamic>.from(raw as Map);
      expect(map, isNotEmpty, reason: '$id: starting_currency vazio');

      for (final entry in map.entries) {
        expect(
          coins,
          contains(entry.key),
          reason: '$id: moeda desconhecida (${entry.key})',
        );
        expect(entry.value, isA<int>(), reason: '$id: ${entry.key} não é int');
        expect(
          entry.value as int,
          greaterThanOrEqualTo(0),
          reason: '$id: ${entry.key} negativo',
        );
      }
    }
  });

  test('equipamento inicial tem id, nome, quantidade e categoria válidos', () {
    for (final item in backgrounds) {
      final id = item['id'] as String;
      final equipment = item['starting_equipment'] as List<dynamic>?;
      if (equipment == null) continue;

      final seen = <String>{};

      for (final raw in equipment) {
        final entry = Map<String, dynamic>.from(raw as Map);
        final itemId = (entry['id'] as String?)?.trim();

        expect(
          itemId?.isNotEmpty,
          isTrue,
          reason: '$id: item sem id (o rastro de origem depende dele)',
        );
        expect(
          (entry['name'] as String?)?.trim().isNotEmpty,
          isTrue,
          reason: '$id: item sem nome',
        );

        // Id repetido dentro do mesmo antecedente colidiria na chave de
        // concessão e um dos dois itens seria perdido.
        expect(
          seen.add(itemId!),
          isTrue,
          reason: '$id: item com id repetido ($itemId)',
        );

        final quantity = entry['quantity'];
        expect(quantity, isA<int>(), reason: '$id/$itemId: quantidade não int');
        expect(
          quantity as int,
          greaterThanOrEqualTo(1),
          reason: '$id/$itemId: quantidade menor que 1',
        );

        final category = entry['category'] as String?;
        if (category != null) {
          expect(
            categoryIds,
            contains(category),
            reason: '$id/$itemId: categoria desconhecida ($category)',
          );
        }
      }
    }
  });

  test('tabelas auxiliares e características alternativas são coerentes', () {
    for (final item in backgrounds) {
      final id = item['id'] as String;

      for (final raw in (item['extra_choices'] as List<dynamic>? ?? const [])) {
        final choice = Map<String, dynamic>.from(raw as Map);
        expect(
          (choice['id'] as String?)?.trim().isNotEmpty,
          isTrue,
          reason: '$id: extra_choice sem id',
        );
        expect(
          (choice['options'] as List<dynamic>),
          isNotEmpty,
          reason: '$id: extra_choice sem opções',
        );
      }

      for (final raw
          in (item['feature_options'] as List<dynamic>? ?? const [])) {
        final option = Map<String, dynamic>.from(raw as Map);
        expect(
          (option['id'] as String?)?.trim().isNotEmpty,
          isTrue,
          reason: '$id: feature_option sem id',
        );
        expect(
          (option['name'] as String?)?.trim().isNotEmpty,
          isTrue,
          reason: '$id: feature_option sem nome',
        );
      }
    }
  });

  test('a acentuação em português foi preservada', () {
    final byId = {for (final item in backgrounds) item['id']: item};

    expect(byId['acolyte']!['name'], 'Acólito');
    expect(byId['urchin']!['name'], 'Órfão');
    expect(byId['charlatan']!['name'], 'Charlatão');
    expect(byId['far_traveler']!['name'], 'Viajante Distante');

    final criminalFlaws = Map<String, dynamic>.from(
      byId['criminal']!['flaws'] as Map,
    );
    final first = Map<String, dynamic>.from(
      (criminalFlaws['options'] as List<dynamic>).first as Map,
    );
    expect(first['text'], contains('roubá-lo'));
  });
}
