import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda os assets de classe e subclasse.
///
/// O caso que motivou o teste: ao adicionar `subclass_level` nas classes, duas
/// ficaram sem o campo e nada avisou — o seletor de subclasse simplesmente não
/// apareceria para elas.
void main() {
  const abilities = {
    'strength',
    'dexterity',
    'constitution',
    'intelligence',
    'wisdom',
    'charisma',
  };

  /// Tipos de conjuração e a tabela de espaços que cada um usa.
  const castingTables = {
    'full': 'full',
    'half': 'half',
    'third': 'third',
    'pact': 'pact',
    'artificer': 'artificer',
  };

  final skillIds = Skill.values.map((skill) => skill.id).toSet();

  late List<Map<String, dynamic>> classes;
  late List<Map<String, dynamic>> subclasses;
  late List<Map<String, dynamic>> slots;

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
    classes = readList('assets/data/srd/classes.json');
    subclasses = readList('assets/data/srd/subclasses.json');
    slots = readList('assets/data/srd/spell_slots.json');
  });

  test('toda classe declara o nível e o rótulo da subclasse', () {
    expect(classes, isNotEmpty);

    for (final item in classes) {
      final id = item['id'];

      final level = item['subclass_level'];
      expect(level, isA<int>(), reason: '$id sem subclass_level');
      expect(
        level as int,
        inInclusiveRange(1, 3),
        reason: '$id com nível de subclasse fora de 1 a 3',
      );

      final label = item['subclass_label'];
      expect(label, isA<String>(), reason: '$id sem subclass_label');
      expect((label as String).trim(), isNotEmpty, reason: '$id com rótulo vazio');
    }
  });

  test('campos básicos de classe são válidos', () {
    final ids = <String>{};

    for (final item in classes) {
      final id = item['id'] as String;
      expect(ids.add(id), isTrue, reason: 'classe repetida: $id');

      expect((item['name'] as String).trim(), isNotEmpty);
      expect(item['hit_die'], matches(RegExp(r'^d\d+$')), reason: '$id hit_die');

      for (final save in item['saving_throws'] as List<dynamic>) {
        expect(abilities, contains(save), reason: '$id salvaguarda inválida');
      }

      for (final skill in item['skill_options'] as List<dynamic>) {
        expect(skillIds, contains(skill), reason: '$id perícia inválida: $skill');
      }

      final primary = item['primary_ability'];
      if (primary != null) {
        expect(abilities, contains(primary), reason: '$id atributo primário');
      }
    }
  });

  test('cada tipo de conjuração tem tabela de espaços dos níveis 1 a 20', () {
    for (final item in classes) {
      final id = item['id'];
      final type = item['spellcasting_type'] as String?;
      if (type == null) continue;

      expect(
        castingTables.keys,
        contains(type),
        reason: '$id com tipo de conjuração desconhecido: $type',
      );

      final tableId = castingTables[type];
      final rows = slots.where((row) => row['table_id'] == tableId);

      expect(rows.length, 20, reason: 'tabela $tableId incompleta');
      for (var level = 1; level <= 20; level++) {
        expect(
          rows.any((row) => row['level'] == level),
          isTrue,
          reason: 'tabela $tableId sem o nível $level',
        );
      }

      final ability = item['spellcasting_ability'];
      expect(ability, isNotNull, reason: '$id conjura sem atributo definido');
      expect(abilities, contains(ability), reason: '$id atributo de conjuração');
    }
  });

  test('artífice conjura desde o 1º nível, diferente dos outros meio-conjuradores', () {
    final artificer = classes.firstWhere((item) => item['id'] == 'artificer');
    expect(artificer['spellcasting_type'], 'artificer');

    int firstSlotsAt(String tableId) {
      for (var level = 1; level <= 20; level++) {
        final row = slots.firstWhere(
          (item) => item['table_id'] == tableId && item['level'] == level,
        );
        if ((row['1'] as int) > 0) return level;
      }
      return -1;
    }

    expect(firstSlotsAt('artificer'), 1);
    // Paladino e patrulheiro só ganham espaços no 2º nível.
    expect(firstSlotsAt('half'), 2);
  });

  test('subclasse aponta para uma classe existente e não repete id', () {
    final classIds = classes.map((item) => item['id'] as String).toSet();
    final ids = <String>{};

    for (final item in subclasses) {
      final id = item['id'] as String;
      expect(ids.add(id), isTrue, reason: 'subclasse repetida: $id');

      expect(
        classIds,
        contains(item['class_id']),
        reason: '$id aponta para classe inexistente: ${item['class_id']}',
      );

      expect((item['name'] as String).trim(), isNotEmpty, reason: '$id sem nome');
      expect(item['source'], isA<String>(), reason: '$id sem fonte');
    }
  });

  test('características da subclasse não vêm antes do nível de escolha', () {
    final subclassLevelByClass = {
      for (final item in classes)
        item['id'] as String: item['subclass_level'] as int,
    };

    for (final item in subclasses) {
      final id = item['id'];
      final classId = item['class_id'] as String;
      final unlockLevel = subclassLevelByClass[classId]!;

      final features = item['features'] as List<dynamic>;
      expect(features, isNotEmpty, reason: '$id sem características');

      for (final raw in features) {
        final feature = Map<String, dynamic>.from(raw as Map);
        final level = feature['level'];

        expect(level, isA<int>(), reason: '$id com característica sem nível');
        expect(
          level as int,
          inInclusiveRange(unlockLevel, 20),
          reason:
              '$id tem característica no nível $level, antes do nível '
              '$unlockLevel em que $classId escolhe a subclasse',
        );

        expect(
          (feature['name'] as String).trim(),
          isNotEmpty,
          reason: '$id com característica sem nome',
        );
        expect(
          (feature['description'] as String).trim(),
          isNotEmpty,
          reason: '$id com característica sem descrição',
        );
      }
    }
  });
}
