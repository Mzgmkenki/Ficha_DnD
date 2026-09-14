import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda o asset de raças contra os erros que já apareceram nele: id repetido,
/// subraça apontando para pai inexistente, perícia escrita errada e chave
/// inventada em `fixed_ability_bonuses` (o `um_escolhido` antigo não aplicava
/// bônus nenhum, porque a criação procura o nome do atributo).
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
  const creatureTypes = {
    'humanoid',
    'fey',
    'construct',
    'ooze',
    'monstrosity',
  };
  const bonusModes = {'fixed', 'choice', 'flexible'};

  final skillIds = Skill.values.map((skill) => skill.id).toSet();

  late List<Map<String, dynamic>> races;

  setUpAll(() {
    final file = File('assets/data/srd/races.json');
    expect(file.existsSync(), isTrue, reason: 'asset de raças não encontrado');

    final decoded = jsonDecode(file.readAsStringSync());
    expect(decoded, isA<List<dynamic>>());

    races = (decoded as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  });

  test('tem raças e nenhum id repetido', () {
    expect(races, isNotEmpty);

    final ids = <String>{};
    for (final race in races) {
      final id = race['id'] as String;
      expect(ids.add(id), isTrue, reason: 'id repetido: $id');
    }
  });

  test('campos básicos preenchidos e dentro dos valores aceitos', () {
    for (final race in races) {
      final id = race['id'];

      expect(race['name'], isA<String>(), reason: '$id sem nome');
      expect((race['name'] as String).trim(), isNotEmpty, reason: '$id sem nome');
      expect(race['source'], isA<String>(), reason: '$id sem fonte');

      expect(sizes, contains(race['size']), reason: '$id com tamanho inválido');
      expect(
        creatureTypes,
        contains(race['creature_type']),
        reason: '$id com tipo de criatura inválido',
      );

      final speed = race['speed'];
      expect(speed, isA<num>(), reason: '$id sem deslocamento');
      expect(speed as num, greaterThan(0), reason: '$id com deslocamento zerado');

      final darkvision = race['darkvision'];
      if (darkvision != null) {
        expect(darkvision, isA<num>(), reason: '$id com visão no escuro inválida');
      }

      final traits = race['traits'] as List<dynamic>;
      expect(traits, isNotEmpty, reason: '$id sem nenhum traço');
    }
  });

  test('subraça aponta para uma raça base existente', () {
    final byId = {for (final race in races) race['id'] as String: race};

    for (final race in races) {
      final id = race['id'] as String;
      final parentId = race['parent_race_id'] as String?;
      final isSubrace = race['is_subrace'] == true;

      if (isSubrace) {
        expect(parentId, isNotNull, reason: '$id é subraça sem pai');
      }

      if (parentId == null) continue;

      final parent = byId[parentId];
      expect(parent, isNotNull, reason: '$id aponta para pai inexistente');
      expect(
        parent!['parent_race_id'],
        isNull,
        reason: '$id é subraça de outra subraça, que a criação não suporta',
      );
    }
  });

  test('bônus de atributo usam modos e chaves válidas', () {
    for (final race in races) {
      final id = race['id'];
      final mode = race['ability_bonus_mode'];

      expect(bonusModes, contains(mode), reason: '$id com modo inválido: $mode');

      final fixed = Map<String, dynamic>.from(
        race['fixed_ability_bonuses'] as Map? ?? const {},
      );
      for (final key in fixed.keys) {
        expect(
          abilities,
          contains(key),
          reason: '$id tem bônus na chave "$key", que não é atributo',
        );
        expect(fixed[key], isA<int>(), reason: '$id com bônus não inteiro');
      }

      if (mode == 'choice') {
        final choices = race['ability_bonus_choices'] as List<dynamic>?;
        expect(
          choices,
          isNotNull,
          reason: '$id é modo escolha sem ability_bonus_choices',
        );
        expect(choices, isNotEmpty, reason: '$id é modo escolha sem valores');
        for (final value in choices!) {
          expect(value, isA<int>(), reason: '$id com valor de escolha inválido');
          expect(value as int, greaterThan(0));
        }
      }

      if (mode == 'flexible') {
        expect(
          fixed,
          isEmpty,
          reason: '$id é flexível e não deveria ter bônus fixo',
        );
      }
    }
  });

  test('perícias concedidas e escolhas usam ids reais', () {
    for (final race in races) {
      final id = race['id'];

      final granted = (race['granted_skills'] as List<dynamic>? ?? const [])
          .map((e) => e.toString());
      for (final skill in granted) {
        expect(
          skillIds,
          contains(skill),
          reason: '$id concede perícia inexistente: $skill',
        );
      }

      final choice = race['skill_choice'] as Map<dynamic, dynamic>?;
      if (choice == null) continue;

      final options = (choice['options'] as List<dynamic>).map((e) => e.toString());
      for (final skill in options) {
        expect(
          skillIds,
          contains(skill),
          reason: '$id oferece perícia inexistente: $skill',
        );
      }

      final choose = choice['choose'];
      expect(choose, isA<int>(), reason: '$id sem quantidade de escolha');
      expect(
        options.length,
        greaterThanOrEqualTo(choose as int),
        reason: '$id pede mais perícias do que oferece',
      );
    }
  });

  test('grupos de escolha estão completos', () {
    for (final race in races) {
      final id = race['id'];
      final groups = race['choice_groups'] as List<dynamic>? ?? const [];

      for (final raw in groups) {
        final group = Map<String, dynamic>.from(raw as Map);

        expect(group['id'], isA<String>(), reason: '$id com grupo sem id');
        expect(group['name'], isA<String>(), reason: '$id com grupo sem nome');

        final options = group['options'] as List<dynamic>;
        expect(options, isNotEmpty, reason: '$id com grupo sem opções');

        final choose = group['choose'];
        expect(choose, isA<int>(), reason: '$id com grupo sem quantidade');
        expect(options.length, greaterThanOrEqualTo(choose as int));
      }
    }
  });
}
