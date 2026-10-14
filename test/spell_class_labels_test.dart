import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/compendium/data/import/spell_normalizer.dart';
import 'package:dnd_ficha_app/features/compendium/data/spell_assets.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/presentation/pages/spell_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda a tradução da lista de classes da magia.
///
/// O caso que motivou o teste: a tela de detalhe mostrava
/// "warlock, sorcerer, wizard". `SpellEntry.classes` guarda o id em inglês,
/// que é o que os filtros comparam, e a tela imprimia o id direto.
void main() {
  SpellEntry spell({List<String> classes = const ['warlock']}) {
    return SpellEntry(
      id: 1,
      namePt: 'Magia de Teste',
      nameOriginal: 'Test Spell',
      level: 2,
      school: 'Evocação',
      castingTime: 'Uma ação',
      range: '18m [60 ft.]',
      components: 'V S',
      hasCostlyMaterials: false,
      duration: 'Instantânea',
      concentration: false,
      ritual: false,
      classes: classes,
      subclasses: const [],
      description: 'Faz algo.',
      source: 'Livro de Teste',
      page: '1',
      isSrd: false,
    );
  }

  group('spellClassLabel', () {
    test('traduz os ids que a leitura do asset produz', () {
      expect(spellClassLabel('warlock'), 'Bruxo');
      expect(spellClassLabel('sorcerer'), 'Feiticeiro');
      expect(spellClassLabel('wizard'), 'Mago');
      expect(spellClassLabel('ranger'), 'Patrulheiro');
      expect(spellClassLabel('artificer'), 'Artífice');
    });

    test('id desconhecido aparece como está, em vez de desaparecer', () {
      expect(spellClassLabel('necromancer'), 'necromancer');
    });

    test('classLabels preserva a ordem do asset', () {
      final entry = spell(classes: const ['warlock', 'sorcerer', 'wizard']);
      expect(entry.classLabels, ['Bruxo', 'Feiticeiro', 'Mago']);
    });

    test('magia sem classe devolve lista vazia', () {
      expect(spell(classes: const []).classLabels, isEmpty);
    });

    test('há rótulo para as 13 classes conjuradoras', () {
      expect(spellClassLabels, hasLength(13));
    });
  });

  group('SpellDetailPage', () {
    testWidgets('mostra as classes em português', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpellDetailPage(
            spell: spell(classes: const ['warlock', 'sorcerer', 'wizard']),
          ),
        ),
      );

      expect(find.text('Bruxo, Feiticeiro, Mago'), findsOneWidget);
      expect(find.text('warlock, sorcerer, wizard'), findsNothing);
    });

    testWidgets('avisa quando a magia não tem classe', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SpellDetailPage(spell: spell(classes: const []))),
      );

      expect(find.text('Nenhuma classe cadastrada.'), findsOneWidget);
    });
  });

  test('toda classe citada nos assets tem rótulo em português', () {
    // A leitura do asset converte o nome português para um id em inglês, e a
    // tela de detalhe traduz o id de volta. Se as duas tabelas divergirem, uma
    // classe nova volta a aparecer em inglês na tela.
    //
    // "Guardião" é a exceção conhecida: é a grafia que os assets usam para o
    // patrulheiro, e a interface o chama de "Patrulheiro".
    const knownDifferentLabel = {'guardiao'};

    final labelByFolded = {
      for (final label in spellClassLabels.values)
        foldAccents(label.toLowerCase()): label,
    };

    final missing = <String>{};

    for (final path in spellAssetPaths) {
      final raw =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      final rows = raw['dados'] as List<dynamic>? ?? const [];

      for (final row in rows) {
        final classes = (row as Map)['classes'];
        if (classes is! String) continue;

        for (final name in classes.split(',')) {
          final trimmed = name.trim();
          if (trimmed.isEmpty) continue;

          final folded = foldAccents(trimmed.toLowerCase());
          if (knownDifferentLabel.contains(folded)) continue;
          if (labelByFolded.containsKey(folded)) continue;

          missing.add(trimmed);
        }
      }
    }

    expect(
      missing,
      isEmpty,
      reason: 'classes nos assets sem rótulo correspondente: $missing',
    );
  });
}
