import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda a quantidade de perícias que cada classe concede.
///
/// O caso que motivou o teste: `classes.json` listava as perícias elegíveis em
/// `skill_options` mas não dizia quantas escolher, então a criação aceitava
/// marcar todas as 18 — um Clérigo saía com cinco perícias de classe.
void main() {
  /// Quantidades do PHB 2014. Ladino é o único com quatro; bardo e patrulheiro
  /// têm três; o resto tem duas.
  const expected = <String, int>{
    'barbarian': 2,
    'bard': 3,
    'cleric': 2,
    'druid': 2,
    'fighter': 2,
    'monk': 2,
    'paladin': 2,
    'ranger': 3,
    'ranger_tcoe': 3,
    'rogue': 4,
    'sorcerer': 2,
    'warlock': 2,
    'wizard': 2,
    'artificer': 2,
  };

  late List<Map<String, dynamic>> classes;

  setUpAll(() {
    final file = File('assets/data/srd/classes.json');
    expect(file.existsSync(), isTrue, reason: 'classes.json não encontrado');

    classes = (jsonDecode(file.readAsStringSync()) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  });

  test('toda classe declara skill_choices', () {
    for (final item in classes) {
      final id = item['id'];
      final choices = item['skill_choices'];

      expect(choices, isA<int>(), reason: '$id sem skill_choices');
      expect(
        choices as int,
        inInclusiveRange(1, 4),
        reason: '$id com quantidade fora de 1 a 4',
      );
    }
  });

  test('as quantidades conferem com o PHB', () {
    for (final item in classes) {
      final id = item['id'] as String;

      expect(
        expected.keys,
        contains(id),
        reason: 'classe nova sem quantidade esperada no teste: $id',
      );
      expect(
        item['skill_choices'],
        expected[id],
        reason: '$id com quantidade errada',
      );
    }

    // Nenhuma classe esperada ficou de fora do asset.
    final ids = classes.map((item) => item['id']).toSet();
    for (final id in expected.keys) {
      expect(ids, contains(id), reason: 'classe ausente do asset: $id');
    }
  });

  test('a classe oferece mais opções do que a quantidade a escolher', () {
    // Uma lista menor que a cota tornaria impossível completar a escolha, e a
    // criação nunca deixaria salvar.
    for (final item in classes) {
      final id = item['id'];
      final options = (item['skill_options'] as List<dynamic>).length;

      expect(
        options,
        greaterThanOrEqualTo(item['skill_choices'] as int),
        reason: '$id oferece $options opções para escolher '
            '${item['skill_choices']}',
      );
    }
  });

  test('a variante do patrulheiro concede o mesmo que a classe-base', () {
    final base = classes.firstWhere((item) => item['id'] == 'ranger');
    final variant = classes.firstWhere((item) => item['id'] == 'ranger_tcoe');

    expect(variant['variant_of'], 'ranger');
    expect(variant['skill_choices'], base['skill_choices']);
    expect(variant['skill_options'], base['skill_options']);
  });

  group('ClassEntry', () {
    ClassEntry entry({int choices = 2}) {
      return ClassEntry(
        id: 'rogue',
        name: 'Ladino',
        hitDie: 'd8',
        source: 'srd',
        skillOptions: const ['stealth', 'perception'],
        savingThrows: const ['dexterity'],
        skillChoices: choices,
      );
    }

    test('hasSkillChoices distingue declarado de ausente', () {
      expect(entry().hasSkillChoices, isTrue);
      expect(entry(choices: 0).hasSkillChoices, isFalse);
    });

    test('o rótulo sai no formato que a criação exibe', () {
      expect(entry().skillChoiceLabel(0), '0 de 2 selecionadas');
      expect(entry().skillChoiceLabel(1), '1 de 2 selecionadas');
      expect(entry().skillChoiceLabel(2), '2 de 2 selecionadas');
    });

    test('quantidade ausente vira zero, não erro', () {
      // O leitor devolve 0 quando o asset não declara, e a tela usa isso para
      // não impor limite nenhum.
      const withoutChoices = ClassEntry(
        id: 'homebrew',
        name: 'Caseira',
        hitDie: 'd8',
        source: 'homebrew',
        skillOptions: [],
        savingThrows: [],
      );

      expect(withoutChoices.skillChoices, 0);
      expect(withoutChoices.hasSkillChoices, isFalse);
    });
  });
}
