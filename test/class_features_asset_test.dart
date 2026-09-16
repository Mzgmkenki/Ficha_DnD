import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda o asset de características de classe e o parser que o lê.
///
/// O que motivou o teste: as características só tinham título. Ao encher o
/// arquivo com mais de 200 descrições, um `class_id` digitado errado ou uma
/// entrada sem texto passaria em silêncio — o painel simplesmente mostraria
/// menos coisa do que devia.
void main() {
  late List<Map<String, dynamic>> features;
  late Set<String> classIds;

  List<Map<String, dynamic>> readList(String path) {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'asset não encontrado: $path');

    final decoded = jsonDecode(file.readAsStringSync());
    expect(decoded, isA<List<dynamic>>(), reason: '$path não é uma lista');

    return (decoded as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  setUpAll(() {
    features = readList('assets/data/srd/class_features.json');
    classIds = readList('assets/data/srd/classes.json')
        .map((item) => item['id'] as String)
        .toSet();
  });

  group('asset de características de classe', () {
    test('toda entrada aponta para uma classe existente', () {
      expect(features, isNotEmpty);

      for (final entry in features) {
        final classId = entry['class_id'];
        expect(classId, isA<String>(), reason: 'entrada sem class_id: $entry');
        expect(
          classIds,
          contains(classId),
          reason: 'class_id fora de classes.json: $classId',
        );
      }
    });

    test('nível fica entre 1 e 20 e não repete na mesma classe', () {
      final seen = <String>{};

      for (final entry in features) {
        final classId = entry['class_id'] as String;
        final level = entry['level'];

        expect(level, isA<int>(), reason: '$classId com nível não inteiro');
        expect(
          level as int,
          inInclusiveRange(1, 20),
          reason: '$classId com nível fora de 1 a 20: $level',
        );

        expect(
          seen.add('$classId-$level'),
          isTrue,
          reason: 'entrada repetida para $classId no nível $level',
        );
      }
    });

    test('toda característica tem nome e descrição', () {
      for (final entry in features) {
        final classId = entry['class_id'];
        final level = entry['level'];
        final list = entry['features'];

        expect(list, isA<List<dynamic>>(), reason: '$classId/$level sem lista');
        expect(
          list as List<dynamic>,
          isNotEmpty,
          reason: '$classId/$level com lista vazia',
        );

        for (final raw in list) {
          // O parser tolera texto simples, mas o asset deve estar migrado por
          // inteiro: uma string aqui significa característica sem descrição.
          expect(
            raw,
            isA<Map<dynamic, dynamic>>(),
            reason: '$classId/$level tem característica sem objeto: $raw',
          );

          final feature = Map<String, dynamic>.from(raw as Map);

          final name = feature['name'];
          expect(name, isA<String>(), reason: '$classId/$level sem nome');
          expect(
            (name as String).trim(),
            isNotEmpty,
            reason: '$classId/$level com nome vazio',
          );

          final description = feature['description'];
          expect(
            description,
            isA<String>(),
            reason: '$classId/$level: "$name" sem descrição',
          );
          expect(
            (description as String).trim(),
            isNotEmpty,
            reason: '$classId/$level: "$name" com descrição vazia',
          );
        }
      }
    });

    test('nome de característica não repete dentro do mesmo nível', () {
      for (final entry in features) {
        final classId = entry['class_id'];
        final level = entry['level'];
        final seen = <String>{};

        for (final raw in entry['features'] as List<dynamic>) {
          final name = (raw as Map)['name'] as String;
          expect(
            seen.add(name),
            isTrue,
            reason: '$classId/$level repete "$name"',
          );
        }
      }
    });

    test('toda entrada declara a fonte', () {
      for (final entry in features) {
        final source = entry['source'];
        expect(
          source,
          isA<String>(),
          reason: '${entry['class_id']}/${entry['level']} sem fonte',
        );
        expect((source as String).trim(), isNotEmpty);
      }
    });

    test('as 13 classes têm características cadastradas', () {
      final levelsByClass = <String, Set<int>>{};

      for (final entry in features) {
        levelsByClass
            .putIfAbsent(entry['class_id'] as String, () => <int>{})
            .add(entry['level'] as int);
      }

      expect(
        levelsByClass.keys.toSet(),
        classIds,
        reason: 'classe sem nenhuma característica cadastrada',
      );

      for (final classId in classIds) {
        expect(
          levelsByClass[classId],
          contains(1),
          reason: '$classId sem características de 1º nível',
        );
      }
    });

    test('todo nível de aumento de atributo aparece na lista', () {
      // Este é o cruzamento que importa: `feat_levels` (ou o padrão
      // 4/8/12/16/19) decide quando a ficha abre a escolha de talento. Se o
      // asset não tiver a linha correspondente, o jogador ganha o talento sem
      // nada explicando de onde ele veio.
      //
      // Níveis que só rendem característica de subclasse ficam de fora do
      // arquivo de propósito: o bloco da subclasse na ficha já os lista com o
      // texto concreto, e repetir "sua subclasse concede algo" aqui seria só
      // ruído.
      const defaultFeatLevels = [4, 8, 12, 16, 19];
      const asiName = 'Aumento no Valor de Habilidade';

      final asiLevelsByClass = <String, Set<int>>{};

      for (final entry in features) {
        final hasAsi = (entry['features'] as List<dynamic>).any(
          (raw) => (raw as Map)['name'] == asiName,
        );
        if (!hasAsi) continue;

        asiLevelsByClass
            .putIfAbsent(entry['class_id'] as String, () => <int>{})
            .add(entry['level'] as int);
      }

      final problems = <String>[];

      for (final item in readList('assets/data/srd/classes.json')) {
        final classId = item['id'] as String;
        final declared = (item['feat_levels'] as List<dynamic>?)
                ?.map((level) => level as int)
                .toSet() ??
            defaultFeatLevels.toSet();
        final found = asiLevelsByClass[classId] ?? const <int>{};

        final missing = declared.difference(found).toList()..sort();
        final extra = found.difference(declared).toList()..sort();

        if (missing.isNotEmpty) problems.add('$classId sem ASI em $missing');
        if (extra.isNotEmpty) problems.add('$classId com ASI extra em $extra');
      }

      expect(problems, isEmpty, reason: problems.join('; '));
    });
  });

  group('ClassFeature.tryParse', () {
    test('aceita texto simples como nome, sem descrição', () {
      final feature = ClassFeature.tryParse('  Fúria  ');

      expect(feature, isNotNull);
      expect(feature!.name, 'Fúria');
      expect(feature.description, isNull);
      expect(feature.hasDescription, isFalse);
    });

    test('aceita objeto com nome e descrição', () {
      final feature = ClassFeature.tryParse({
        'name': '  Fúria  ',
        'description': '  Ação bônus, dura até 1 minuto.  ',
      });

      expect(feature, isNotNull);
      expect(feature!.name, 'Fúria');
      expect(feature.description, 'Ação bônus, dura até 1 minuto.');
      expect(feature.hasDescription, isTrue);
    });

    test('objeto só com nome vira característica sem descrição', () {
      final feature = ClassFeature.tryParse({'name': 'Fúria'});

      expect(feature, isNotNull);
      expect(feature!.description, isNull);
      expect(feature.hasDescription, isFalse);
    });

    test('descrição em branco conta como ausente', () {
      final feature = ClassFeature.tryParse({
        'name': 'Fúria',
        'description': '   ',
      });

      expect(feature, isNotNull);
      expect(feature!.description, isNull);
      expect(feature.hasDescription, isFalse);
    });

    test('descarta entrada sem nome utilizável', () {
      // Sem nome não há o que mostrar na ficha, então a entrada sai da lista em
      // vez de virar uma linha vazia.
      expect(ClassFeature.tryParse(''), isNull);
      expect(ClassFeature.tryParse('   '), isNull);
      expect(ClassFeature.tryParse({'description': 'sem nome'}), isNull);
      expect(ClassFeature.tryParse({'name': '  '}), isNull);
    });

    test('descarta tipo inesperado em vez de estourar', () {
      expect(ClassFeature.tryParse(null), isNull);
      expect(ClassFeature.tryParse(7), isNull);
      expect(ClassFeature.tryParse(const ['Fúria']), isNull);
    });
  });
}
