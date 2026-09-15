import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda o asset de talentos contra o erro que mais dói aqui: pré-requisito
/// apontando para um id que não existe.
///
/// Um `race_ids` com id errado não quebra nada visivelmente — o talento
/// simplesmente nunca aparece para ninguém, e descobrir isso jogando é caro.
void main() {
  const abilities = {
    'strength',
    'dexterity',
    'constitution',
    'intelligence',
    'wisdom',
    'charisma',
  };
  const sizes = {'small', 'medium'};

  final skillIds = Skill.values.map((skill) => skill.id).toSet();

  late List<Map<String, dynamic>> feats;
  late Set<String> featIds;
  late Set<String> raceIds;
  late Set<String> classIds;

  Set<String> idsOf(String path) {
    final decoded = jsonDecode(File(path).readAsStringSync()) as List<dynamic>;
    return {
      for (final item in decoded)
        if (Map<String, dynamic>.from(item as Map)['id'] case final String id)
          id,
    };
  }

  setUpAll(() {
    final file = File('assets/data/srd/feats.json');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'asset de talentos não encontrado; o carregamento falharia',
    );

    final decoded = jsonDecode(file.readAsStringSync());
    expect(decoded, isA<List<dynamic>>(), reason: 'o topo precisa ser um array');

    feats = (decoded as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    featIds = {for (final feat in feats) feat['id'] as String};
    raceIds = idsOf('assets/data/srd/races.json');
    classIds = idsOf('assets/data/srd/classes.json');
  });

  test('o compêndio tem talentos', () {
    expect(feats, isNotEmpty);
  });

  test('nenhum id repetido', () {
    final ids = <String>{};
    for (final feat in feats) {
      final id = feat['id'] as String;
      expect(ids.add(id), isTrue, reason: 'id repetido: $id');
    }
  });

  test('campos básicos preenchidos', () {
    for (final feat in feats) {
      final id = feat['id'];

      expect(feat['id'], isA<String>(), reason: 'talento sem id');
      expect(feat['name'], isA<String>(), reason: '$id sem nome');
      expect(
        (feat['name'] as String).trim(),
        isNotEmpty,
        reason: '$id com nome vazio',
      );

      final repeatable = feat['repeatable'];
      if (repeatable != null) {
        expect(repeatable, isA<bool>(), reason: '$id com repeatable inválido');
      }
    }
  });

  test('perícias concedidas usam ids reais', () {
    for (final feat in feats) {
      final id = feat['id'];
      final granted =
          (feat['skills'] as List<dynamic>? ?? const []).map((e) => e.toString());

      for (final skill in granted) {
        expect(
          skillIds,
          contains(skill),
          reason: '$id concede perícia inexistente: $skill',
        );
      }
    }
  });

  test('escolha de perícia é coerente', () {
    for (final feat in feats) {
      final id = feat['id'];
      final choice = feat['skill_choice'] as Map<dynamic, dynamic>?;
      if (choice == null) continue;

      final choose = choice['choose'];
      expect(choose, isA<int>(), reason: '$id sem quantidade de escolha');
      expect(choose as int, greaterThan(0), reason: '$id com escolha zerada');

      final options =
          (choice['options'] as List<dynamic>? ?? const []).map((e) => e.toString());

      for (final skill in options) {
        expect(
          skillIds,
          contains(skill),
          reason: '$id oferece perícia inexistente: $skill',
        );
      }

      // Lista vazia significa "qualquer perícia", então só faz sentido cobrar
      // o tamanho quando o talento restringe as opções.
      if (options.isNotEmpty) {
        expect(
          options.length,
          greaterThanOrEqualTo(choose),
          reason: '$id pede mais perícias do que oferece',
        );
      }
    }
  });

  test('aumentos de atributo usam nomes de atributo', () {
    for (final feat in feats) {
      final id = feat['id'];
      final increases = Map<String, dynamic>.from(
        feat['ability_increases'] as Map? ?? const {},
      );

      for (final entry in increases.entries) {
        expect(
          abilities,
          contains(entry.key),
          reason: '$id aumenta "${entry.key}", que não é atributo',
        );
        expect(
          entry.value,
          isA<int>(),
          reason: '$id com aumento não inteiro em ${entry.key}',
        );
      }

      final options = (feat['ability_increase_options'] as List<dynamic>? ??
              const [])
          .map((e) => e.toString());

      for (final option in options) {
        expect(
          abilities,
          contains(option),
          reason: '$id oferece "$option", que não é atributo',
        );
      }
    }
  });

  group('pré-requisitos', () {
    Map<String, dynamic> requiresOf(Map<String, dynamic> feat) {
      return Map<String, dynamic>.from(feat['requires'] as Map? ?? const {});
    }

    List<String> listOf(Map<String, dynamic> requires, String key) {
      return (requires[key] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false);
    }

    test('race_ids apontam para raças que existem', () {
      // O erro silencioso: id errado aqui faz o talento nunca aparecer.
      for (final feat in feats) {
        for (final race in listOf(requiresOf(feat), 'race_ids')) {
          expect(
            raceIds,
            contains(race),
            reason: '${feat['id']} exige a raça "$race", que não existe',
          );
        }
      }
    });

    test('race_sizes usam tamanhos válidos', () {
      for (final feat in feats) {
        for (final size in listOf(requiresOf(feat), 'race_sizes')) {
          expect(
            sizes,
            contains(size),
            reason: '${feat['id']} exige o tamanho "$size"',
          );
        }
      }
    });

    test('class_ids apontam para classes que existem', () {
      for (final feat in feats) {
        for (final classId in listOf(requiresOf(feat), 'class_ids')) {
          expect(
            classIds,
            contains(classId),
            reason: '${feat['id']} exige a classe "$classId", que não existe',
          );
        }
      }
    });

    test('talento exigido e talento proibido apontam para talentos reais', () {
      for (final feat in feats) {
        final requires = requiresOf(feat);

        for (final key in const ['feat_ids', 'not_feat_ids']) {
          for (final other in listOf(requires, key)) {
            expect(
              featIds,
              contains(other),
              reason: '${feat['id']} referencia o talento "$other" em $key',
            );
            expect(
              other,
              isNot(feat['id']),
              reason: '${feat['id']} referencia a si mesmo',
            );
          }
        }
      }
    });

    test('min_ability_any usa atributos e valores plausíveis', () {
      for (final feat in feats) {
        final raw = Map<String, dynamic>.from(
          requiresOf(feat)['min_ability_any'] as Map? ?? const {},
        );

        for (final entry in raw.entries) {
          expect(
            abilities,
            contains(entry.key),
            reason: '${feat['id']} exige "${entry.key}", que não é atributo',
          );
          expect(entry.value, isA<int>());
          expect(
            entry.value as int,
            inInclusiveRange(1, 20),
            reason: '${feat['id']} pede um valor fora da escala',
          );
        }
      }
    });

    test('min_level fica dentro dos 20 níveis', () {
      for (final feat in feats) {
        final level = requiresOf(feat)['min_level'];
        if (level == null) continue;

        expect(level, isA<int>());
        expect(level as int, inInclusiveRange(1, 20));
      }
    });

    test('quem exige outro talento também exige nível', () {
      // Todo talento de cadeia da linha 2014 abre no 4º nível. Sem o nível, o
      // encadeamento apareceria antes da hora.
      for (final feat in feats) {
        final requires = requiresOf(feat);
        if (listOf(requires, 'feat_ids').isEmpty) continue;

        expect(
          requires['min_level'],
          isNotNull,
          reason: '${feat['id']} encadeia talento sem exigir nível',
        );
      }
    });

    test('nenhuma chave desconhecida em requires', () {
      // Chave com typo é ignorada em silêncio pelo parser, e o pré-requisito
      // simplesmente deixa de valer.
      const known = {
        'min_level',
        'min_ability_any',
        'spellcasting',
        'race_ids',
        'race_sizes',
        'class_ids',
        'feat_ids',
        'not_feat_ids',
        'notes',
      };

      for (final feat in feats) {
        for (final key in requiresOf(feat).keys) {
          expect(
            known,
            contains(key),
            reason: '${feat['id']} usa a chave desconhecida "$key"',
          );
        }
      }
    });

    test('talento com texto de pré-requisito diferente de Nenhum tem requires',
        () {
      // Pega o caso de alguém adicionar o texto e esquecer a parte estruturada,
      // que é o que faz o filtro funcionar.
      for (final feat in feats) {
        final text = (feat['prerequisite'] as String?)?.trim() ?? '';
        if (text.isEmpty || text.toLowerCase() == 'nenhum') continue;

        expect(
          requiresOf(feat),
          isNotEmpty,
          reason: '${feat['id']} tem pré-requisito em texto mas nada em requires',
        );
      }
    });
  });
}
