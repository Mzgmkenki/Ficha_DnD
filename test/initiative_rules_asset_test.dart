import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/initiative_rule.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda os blocos `initiative` dos assets.
///
/// A iniciativa depende de metadado escrito à mão em quatro arquivos. Sem este
/// teste, apagar um bloco por descuido não daria erro nenhum: o personagem
/// simplesmente pararia de somar o bônus, calado.
void main() {
  /// Onde cada regra esperada vive, e o que ela precisa dizer.
  ///
  /// A lista é o inventário do que o compêndio cobre hoje. Regra nova entra
  /// aqui junto com o asset.
  const expected = <String, Map<String, Object?>>{
    // Características de classe.
    'Instinto Feral': {'advantage': true},
    'Pau para Toda Obra': {'proficiency': 'half'},
    // Subclasses.
    'Emboscador Terrível': {'ability': 'wisdom'},
    'Audácia Insolente': {'ability': 'charisma'},
    'Sagacidade Tática': {'ability': 'intelligence'},
    'Consciência Temporal': {'ability': 'intelligence'},
    'Mestre da Emboscada': {'advantage': true},
    'Aura da Sentinela': {'proficiency': 'full'},
  };

  Object? readJson(String path) {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'asset ausente: $path');
    return jsonDecode(file.readAsStringSync());
  }

  /// Todo bloco `initiative` do asset, indexado pelo nome de quem o declara.
  final found = <String, Map<String, dynamic>>{};

  setUpAll(() {
    for (final entry in readJson('assets/data/srd/class_features.json')
        as List<dynamic>) {
      final item = Map<String, dynamic>.from(entry as Map);

      for (final raw in item['features'] as List<dynamic>) {
        if (raw is! Map) continue;
        final feature = Map<String, dynamic>.from(raw);
        final rule = feature['initiative'];
        if (rule is! Map) continue;

        found[feature['name'] as String] = Map<String, dynamic>.from(rule);
      }
    }

    for (final entry
        in readJson('assets/data/srd/subclasses.json') as List<dynamic>) {
      final item = Map<String, dynamic>.from(entry as Map);

      for (final raw in item['features'] as List<dynamic>) {
        final feature = Map<String, dynamic>.from(raw as Map);
        final rule = feature['initiative'];
        if (rule is! Map) continue;

        found[feature['name'] as String] = Map<String, dynamic>.from(rule);
      }
    }
  });

  test('as regras de iniciativa esperadas continuam nos assets', () {
    for (final item in expected.entries) {
      final rule = found[item.key];

      expect(rule, isNotNull, reason: '${item.key} perdeu o bloco initiative');

      for (final field in item.value.entries) {
        expect(
          rule![field.key],
          field.value,
          reason: '${item.key}: ${field.key} mudou',
        );
      }
    }
  });

  test('todo bloco de característica é lido sem sobrar campo desconhecido', () {
    const known = {'ability', 'proficiency', 'bonus', 'advantage', 'note'};

    for (final item in found.entries) {
      expect(
        InitiativeRule.tryParse(item.value),
        isNotNull,
        reason: '${item.key} tem bloco initiative que não faz nada',
      );

      for (final key in item.value.keys) {
        expect(
          known,
          contains(key),
          // Campo com nome errado é o pior caso: o asset parece certo e o
          // valor é ignorado em silêncio.
          reason: '${item.key} usa campo desconhecido: $key',
        );
      }
    }
  });

  test('o talento Alerta soma +5', () {
    final feats = readJson('assets/data/srd/feats.json') as List<dynamic>;
    final alert = feats
        .map((item) => Map<String, dynamic>.from(item as Map))
        .firstWhere((item) => item['id'] == 'alert');

    final rule = InitiativeRule.tryParse(alert['initiative']);

    expect(rule, isNotNull, reason: 'Alerta perdeu o bloco initiative');
    expect(rule!.bonus, 5);
    expect(rule.ability, isNull);
    expect(rule.proficiency, isNull);
  });

  test('o harengon soma o bônus de proficiência pelo Gatilho de Lebre', () {
    final races = readJson('assets/data/srd/races.json') as List<dynamic>;
    final harengon = races
        .map((item) => Map<String, dynamic>.from(item as Map))
        .firstWhere((item) => item['name'] == 'Harengon');

    final rule = InitiativeRule.tryParse(harengon['initiative']);

    expect(rule, isNotNull, reason: 'Harengon perdeu o bloco initiative');
    expect(rule!.proficiency, InitiativeProficiencyUse.full);
    expect(rule.note, 'Gatilho de Lebre');
  });

  test('nenhuma raça declara bloco que não faz nada', () {
    final races = readJson('assets/data/srd/races.json') as List<dynamic>;

    for (final entry in races) {
      final item = Map<String, dynamic>.from(entry as Map);
      final raw = item['initiative'];
      if (raw == null) continue;

      expect(
        InitiativeRule.tryParse(raw),
        isNotNull,
        reason: '${item['name']} tem bloco initiative sem efeito',
      );
    }
  });

  test('atributo citado no bloco é um dos seis', () {
    // Um nome errado como `sabedoria` em vez de `wisdom` seria ignorado em
    // silêncio pelo leitor, e o bônus nunca apareceria na ficha.
    for (final item in found.entries) {
      final raw = item.value['ability'];
      if (raw == null) continue;

      expect(
        Ability.fromName(raw.toString()),
        isNotNull,
        reason: '${item.key} cita atributo inválido: $raw',
      );
    }
  });
}
