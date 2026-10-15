import 'dart:convert';

import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_catalog.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_text_import.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integridade do catálogo de idiomas e idempotência da importação.
///
/// Lê o asset de verdade: é o único teste que o faz, e existe para um erro de
/// digitação no JSON aparecer aqui em vez de na ficha de alguém.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<LanguageEntry> entries;
  late LanguageCatalog catalog;
  late List<Map<String, dynamic>> raw;

  setUpAll(() async {
    final text = await rootBundle.loadString('assets/data/srd/languages.json');
    final decoded = jsonDecode(text) as List<dynamic>;
    raw = decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    entries = LanguageEntry.parseList(decoded);
    catalog = LanguageCatalog.from(entries);
  });

  group('integridade', () {
    test('o arquivo tem os 79 idiomas do levantamento', () {
      expect(raw, hasLength(79));
      expect(
        entries,
        hasLength(79),
        reason: 'nenhum registro foi descartado por falta de campo',
      );
    });

    test('nenhuma duplicidade de id, nome, original ou alias', () {
      expect(
        catalog.duplicates,
        isEmpty,
        reason: catalog.duplicates.map((d) => d.description).join('\n'),
      );
      expect(catalog.length, 79);
    });

    test('todo idioma tem id, nome, categoria e disponibilidade', () {
      for (final item in raw) {
        final id = item['id']?.toString() ?? '';
        expect(id, isNotEmpty);
        expect(item['name']?.toString() ?? '', isNotEmpty, reason: id);
        expect(
          LanguageCategory.fromId(item['category']?.toString()),
          isNotNull,
          reason: '$id tem categoria desconhecida',
        );
        expect(
          LanguageAvailability.fromId(item['availability']?.toString()),
          isNotNull,
          reason: '$id tem disponibilidade desconhecida',
        );
      }
    });

    test('o id é minúsculo, sem acento e sem espaço', () {
      for (final entry in entries) {
        expect(
          entry.id,
          matches(RegExp(r'^[a-z0-9_]+$')),
          reason: '${entry.id} não serve como identificador estável',
        );
      }
    });

    test('a contagem por categoria bate com o levantamento', () {
      int count(LanguageCategory category) =>
          entries.where((item) => item.category == category).length;

      expect(count(LanguageCategory.standard), 8);
      expect(count(LanguageCategory.exotic), 8);
      expect(count(LanguageCategory.primordialDialect), 4);
      expect(count(LanguageCategory.secret), 2);
      expect(count(LanguageCategory.peopleSetting), 13);
      expect(count(LanguageCategory.faerunRegional), 21);
      expect(count(LanguageCategory.historical), 2);
      expect(count(LanguageCategory.creature), 21);
    });

    test('todo idioma declara a edição 2014', () {
      // O levantamento é explícito em não misturar edições.
      for (final entry in entries) {
        expect(entry.edition, '2014', reason: entry.id);
      }
    });

    test('os quatro dialetos apontam para Primordial', () {
      final dialects = entries
          .where(
            (item) => item.category == LanguageCategory.primordialDialect,
          )
          .toList();

      expect(
        dialects.map((item) => item.id).toSet(),
        {'aquan', 'auran', 'ignan', 'terran'},
      );
      for (final dialect in dialects) {
        expect(dialect.dialectOf, 'primordial', reason: dialect.id);
        expect(catalog.contains(dialect.dialectOf), isTrue);
      }
    });

    test('Druídico e Gíria dos Ladrões são secretos e só por característica',
        () {
      for (final id in ['druidic', 'thieves_cant']) {
        final entry = catalog.byId(id);
        expect(entry, isNotNull, reason: id);
        expect(entry!.category, LanguageCategory.secret);
        expect(
          entry.availability,
          LanguageAvailability.featureOnly,
          reason: '$id não pode ser escolha livre de ninguém',
        );
        expect(entry.availability.isOfferedByDefault, isFalse);
      }
    });

    test('idioma de criatura nunca é oferecido por padrão', () {
      final creatures = entries.where(
        (item) => item.category == LanguageCategory.creature,
      );

      for (final entry in creatures) {
        expect(
          entry.availability.isOfferedByDefault,
          isFalse,
          reason: '${entry.id} poluiria a lista comum',
        );
        expect(entry.availability.isOfferedWhenGatedShown, isFalse);
      }
    });

    test('os oito idiomas padrão são os do PHB', () {
      final standard = entries
          .where((item) => item.category == LanguageCategory.standard)
          .map((item) => item.id)
          .toSet();

      expect(standard, {
        'common',
        'dwarvish',
        'elvish',
        'giant',
        'gnomish',
        'goblin',
        'halfling',
        'orc',
      });
    });
  });

  group('16. reprocessamento do mesmo TXT', () {
    test('importar sobre uma base vazia cria os 79', () {
      final result = LanguageCatalog.import(
        existing: const [],
        incoming: entries,
      );

      expect(result.added, hasLength(79));
      expect(result.updated, isEmpty);
      expect(result.conflicts, isEmpty);
      expect(result.catalog.length, 79);
    });

    test('importar de novo não cria nada e não muda nada', () {
      final first = LanguageCatalog.import(
        existing: const [],
        incoming: entries,
      );

      final second = LanguageCatalog.import(
        existing: first.catalog.all,
        incoming: entries,
      );

      expect(second.added, isEmpty, reason: 'nada novo para criar');
      expect(second.updated, isEmpty, reason: 'nada vazio para preencher');
      expect(second.unchanged, hasLength(79));
      expect(second.conflicts, isEmpty);
      expect(second.changedAnything, isFalse);
      expect(second.catalog.length, 79);
    });

    test('uma terceira passada continua estável', () {
      var catalogNow = LanguageCatalog.import(
        existing: const [],
        incoming: entries,
      ).catalog;

      for (var i = 0; i < 3; i++) {
        final result = LanguageCatalog.import(
          existing: catalogNow.all,
          incoming: entries,
        );
        expect(result.changedAnything, isFalse);
        expect(result.catalog.length, 79);
        catalogNow = result.catalog;
      }
    });

    test('campo vazio é preenchido; campo divergente é mantido e relatado',
        () {
      const existing = [
        LanguageEntry(
          id: 'elvish',
          name: 'Élfico',
          category: LanguageCategory.standard,
          availability: LanguageAvailability.standard,
          // Sem escrita e sem nome original: a importação completa.
        ),
        LanguageEntry(
          id: 'common',
          name: 'Comum',
          nameOriginal: 'Nome Antigo',
          category: LanguageCategory.standard,
          availability: LanguageAvailability.standard,
        ),
      ];

      final result = LanguageCatalog.import(
        existing: existing,
        incoming: entries,
      );

      expect(result.catalog.byId('elvish')!.script, 'Élfico');
      expect(result.catalog.byId('elvish')!.nameOriginal, 'Elvish');
      expect(result.updated, contains('elvish'));

      expect(
        result.catalog.byId('common')!.nameOriginal,
        'Nome Antigo',
        reason: 'o dado existente é preservado',
      );
      expect(
        result.conflicts.any(
          (item) => item.languageId == 'common' && item.field == 'nome original',
        ),
        isTrue,
        reason: 'e a divergência é relatada',
      );
    });

    test('id existente nunca é trocado, mesmo com nome igual', () {
      // Personagens salvos guardam o id; trocá-lo perderia o idioma deles.
      const existing = [
        LanguageEntry(
          id: 'elfico_legado',
          name: 'Élfico',
          category: LanguageCategory.standard,
          availability: LanguageAvailability.standard,
        ),
      ];

      final result = LanguageCatalog.import(
        existing: existing,
        incoming: entries,
      );

      expect(result.catalog.byId('elfico_legado'), isNotNull);
      expect(
        result.catalog.byId('elvish'),
        isNull,
        reason: 'o id que já estava em uso vence',
      );
      expect(
        result.duplicates.any((item) => item.discardedId == 'elvish'),
        isTrue,
      );
      expect(
        result.catalog.resolve('Elvish')?.id,
        'elfico_legado',
        reason: 'o nome original do TXT entra como alias do id existente',
      );
    });

    test('disponibilidade divergente é conflito, não atualização', () {
      // Trocar disponibilidade em silêncio poderia liberar idioma secreto.
      const existing = [
        LanguageEntry(
          id: 'druidic',
          name: 'Druídico',
          category: LanguageCategory.secret,
          availability: LanguageAvailability.standard,
        ),
      ];

      final result = LanguageCatalog.import(
        existing: existing,
        incoming: entries,
      );

      expect(
        result.catalog.byId('druidic')!.availability,
        LanguageAvailability.standard,
        reason: 'o existente é mantido',
      );
      expect(
        result.conflicts.any(
          (item) =>
              item.languageId == 'druidic' && item.field == 'disponibilidade',
        ),
        isTrue,
      );
    });
  });

  group('importação do texto livre das raças', () {
    test('todo nome de idioma usado pelas raças é reconhecido', () async {
      final text = await rootBundle.loadString('assets/data/srd/races.json');
      final races = (jsonDecode(text) as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);

      final unresolved = <String>{};

      for (final race in races) {
        final texts = (race['languages'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(growable: false);
        if (texts.isEmpty) continue;

        final imported = LanguageTextImporter.convert(
          texts: texts,
          catalog: catalog,
          idPrefix: 'race.${race['id']}',
        );

        for (final issue in imported.issues) {
          unresolved.add('${race['id']}: ${issue.description}');
        }
      }

      expect(
        unresolved,
        isEmpty,
        reason: 'texto de idioma que o catálogo não entende:\n'
            '${unresolved.join('\n')}',
      );
    });

    test('"Leonino" das raças acha o "Leonin" do TXT por alias', () {
      // A divergência de tradução existe no projeto; o alias é o que impede
      // que ela se transforme em idioma duplicado.
      expect(catalog.resolve('Leonino')?.id, 'leonin');
      expect(catalog.resolve('Leonin')?.id, 'leonin');
    });

    test('"Gíria de Ladrão" do compêndio acha o idioma do TXT', () {
      expect(catalog.resolve('Gíria de Ladrão')?.id, 'thieves_cant');
    });
  });
}
