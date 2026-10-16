import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_mechanic_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_table.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/class_mechanic_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Guarda o conteúdo declarado em `class_mechanics.json`.
///
/// Os testes de regra usam catálogo sintético (ver
/// `test/domain/class_mechanics_test.dart`). Aqui o alvo é o OUTRO risco: um
/// id de subclasse errado, uma faixa de tabela com buraco ou uma fórmula de
/// usos com token que o avaliador não entende passariam em silêncio — a
/// mecânica apenas deixaria de aparecer, e ninguém notaria.
void main() {
  late List<Map<String, dynamic>> raw;
  late List<ClassMechanicEntry> entries;
  late ClassMechanicCatalog catalog;
  late Set<String> classIds;
  late Map<String, String> subclassToClass;

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
    raw = readList('assets/data/srd/class_mechanics.json');

    entries = [
      for (final item in raw)
        if (ClassMechanicEntry.tryParse(item) case final entry?) entry,
    ];

    catalog = ClassMechanicCatalog.from(entries);

    classIds = {
      for (final item in readList('assets/data/srd/classes.json'))
        item['id'] as String,
    };

    subclassToClass = {
      for (final item in readList('assets/data/srd/subclasses.json'))
        item['id'] as String: item['class_id'] as String,
    };
  });

  group('integridade do arquivo', () {
    test('toda entrada do arquivo é lida', () {
      // Entrada descartada por `tryParse` é dado incompleto: id, classe ou
      // nível faltando. Perder uma em silêncio esconderia a mecânica inteira.
      expect(
        entries,
        hasLength(raw.length),
        reason:
            'alguma entrada foi descartada por falta de id, classe ou '
            'nível',
      );
    });

    test('não há id repetido nem mecânica repetida por origem e nome', () {
      expect(catalog.duplicates.map((item) => item.description), isEmpty);
      expect(catalog.length, entries.length);
    });

    test('toda mecânica aponta para uma classe que existe', () {
      for (final entry in entries) {
        expect(
          classIds,
          contains(entry.classId),
          reason:
              '${entry.id} declara a classe "${entry.classId}", que não '
              'existe em classes.json',
        );
      }
    });

    test('toda mecânica de subclasse aponta para uma subclasse que existe '
        'na mesma classe', () {
      for (final entry in entries) {
        final subclassId = entry.subclassId;
        if (subclassId == null) continue;

        expect(
          subclassToClass.keys,
          contains(subclassId),
          reason:
              '${entry.id} declara a subclasse "$subclassId", que não '
              'existe em subclasses.json',
        );
        expect(
          subclassToClass[subclassId],
          entry.classId,
          reason:
              '${entry.id} liga a subclasse "$subclassId" à classe '
              '"${entry.classId}", mas ela pertence a '
              '"${subclassToClass[subclassId]}"',
        );
      }
    });

    test('toda mecânica declara pelo menos uma categoria', () {
      for (final entry in entries) {
        expect(
          entry.kinds,
          isNotEmpty,
          reason:
              '${entry.id} não declara `kinds`, e sem categoria a ficha '
              'não sabe se é escolha, modo, recurso ou tabela',
        );
      }
    });

    test('nenhuma mecânica mistura edições', () {
      for (final entry in entries) {
        expect(
          entry.edition,
          ClassMechanicEntry.defaultEdition,
          reason:
              '${entry.id} declara a edição "${entry.edition}"; o app '
              'adota apenas ${ClassMechanicEntry.defaultEdition}',
        );
      }
    });

    test('toda mecânica declara a fonte', () {
      for (final entry in entries) {
        expect(
          entry.source,
          isNotEmpty,
          reason: '${entry.id} não declara `source`',
        );
      }
    });

    test('o nível de aquisição é possível numa classe', () {
      for (final entry in entries) {
        expect(
          entry.level,
          inInclusiveRange(1, 20),
          reason: '${entry.id} declara nível ${entry.level}',
        );
      }
    });
  });

  group('opções', () {
    test('toda opção tem id e nome, sem id repetido na mecânica', () {
      for (final entry in entries) {
        final seen = <String>{};

        for (final option in entry.options) {
          expect(option.id, isNotEmpty, reason: 'opção sem id em ${entry.id}');
          expect(
            option.name,
            isNotEmpty,
            reason: 'opção "${option.id}" sem nome em ${entry.id}',
          );
          expect(
            seen.add(option.id),
            isTrue,
            reason: '${entry.id} repete a opção "${option.id}"',
          );
        }
      }
    });

    test('incompatibilidade aponta para opção que existe', () {
      for (final entry in entries) {
        for (final option in entry.options) {
          for (final reference in option.incompatibleWith) {
            expect(
              catalog.resolveOption(reference, withinMechanicId: entry.id),
              isNotNull,
              reason:
                  '${entry.id}/${option.id} é incompatível com '
                  '"$reference", que não existe no catálogo',
            );
          }
        }
      }
    });

    test('pré-requisito de opção aponta para opção que existe', () {
      for (final entry in entries) {
        for (final option in entry.options) {
          final references = [
            ...option.prerequisites.options,
            ...option.prerequisites.activeOptions,
          ];

          for (final reference in references) {
            expect(
              catalog.resolveOption(reference, withinMechanicId: entry.id),
              isNotNull,
              reason:
                  '${entry.id}/${option.id} exige "$reference", que não '
                  'existe no catálogo',
            );
          }
        }
      }
    });

    test('pré-requisito de nível de opção não passa de 20', () {
      for (final entry in entries) {
        for (final option in entry.options) {
          final level = option.prerequisites.classLevel;
          if (level == null) continue;

          expect(
            level,
            inInclusiveRange(1, 20),
            reason: '${entry.id}/${option.id} exige nível $level',
          );
        }
      }
    });

    test('mecânica que pede escolha tem pelo menos duas opções', () {
      for (final entry in entries) {
        if (!entry.hasPicks) continue;

        expect(
          entry.selectableOptions.length,
          greaterThanOrEqualTo(2),
          reason:
              '${entry.id} pede escolha mas oferece '
              '${entry.selectableOptions.length} opção(ões); uma opção só não '
              'é escolha, é dado mal preenchido',
        );
      }
    });

    test('mecânica sem escolha não declara progressão de vagas', () {
      for (final entry in entries) {
        if (entry.hasPicks) continue;

        expect(
          entry.picksAt(20),
          0,
          reason:
              '${entry.id} não declara categoria de escolha mas tem vagas '
              'na progressão; a ficha cobraria uma decisão que a regra não '
              'pede',
        );
      }
    });
  });

  group('progressão', () {
    test('as vagas nunca diminuem conforme o nível sobe', () {
      for (final entry in entries) {
        if (!entry.hasPicks) continue;

        var previous = 0;
        for (var level = entry.level; level <= 20; level++) {
          final picks = entry.picksAt(level);
          expect(
            picks,
            greaterThanOrEqualTo(previous),
            reason:
                '${entry.id} reduz as vagas de $previous para $picks no '
                'nível $level',
          );
          previous = picks;
        }
      }
    });

    test('a quantidade de vagas nunca passa do total de opções', () {
      for (final entry in entries) {
        if (!entry.hasPicks) continue;
        if (entry.allowDuplicateOptions) continue;

        expect(
          entry.picksAt(20),
          lessThanOrEqualTo(entry.selectableOptions.length),
          reason:
              '${entry.id} permite ${entry.picksAt(20)} escolhas no 20º '
              'nível, mas só tem ${entry.selectableOptions.length} opções',
        );
      }
    });

    test('todo passo de progressão está no nível de aquisição ou depois', () {
      for (final entry in entries) {
        for (final step in entry.progression) {
          expect(
            step.level,
            greaterThanOrEqualTo(entry.level),
            reason:
                '${entry.id} declara progressão no nível ${step.level}, '
                'antes do nível de aquisição ${entry.level}',
          );
        }
      }
    });

    test('mecânica com escolha abre pelo menos uma vaga no nível dela', () {
      for (final entry in entries) {
        if (!entry.hasPicks) continue;

        expect(
          entry.picksAt(entry.level),
          greaterThan(0),
          reason:
              '${entry.id} pede escolha mas não abre vaga no nível '
              '${entry.level}',
        );
      }
    });
  });

  group('recursos', () {
    test('a fórmula de usos é entendida pelo avaliador', () {
      final context = FeatureFormulaContext.fromCharacter(
        characterFixture(
          abilityScores: scoresWith(
            intelligence: 16,
            wisdom: 16,
            charisma: 16,
            constitution: 16,
          ),
        ),
      );

      for (final entry in entries) {
        final formula = entry.action?.usesFormula;
        if (formula == null) continue;
        if (formula.trim().toLowerCase() == 'proficiency') continue;

        expect(
          FeatureFormula.valueOf(formula, context),
          isNotNull,
          reason:
              '${entry.id} usa a fórmula de usos "$formula", que o '
              'avaliador não entende; o contador não apareceria',
        );
      }
    });

    test('a fórmula de usos de cada opção é entendida pelo avaliador', () {
      final context = FeatureFormulaContext.fromCharacter(
        characterFixture(
          abilityScores: scoresWith(intelligence: 16, wisdom: 16),
        ),
      );

      for (final entry in entries) {
        for (final option in entry.options) {
          final formula = option.action?.usesFormula;
          if (formula == null) continue;
          if (formula.trim().toLowerCase() == 'proficiency') continue;

          expect(
            FeatureFormula.valueOf(formula, context),
            isNotNull,
            reason:
                '${entry.id}/${option.id} usa a fórmula "$formula", que o '
                'avaliador não entende',
          );
        }
      }
    });

    test('mecânica com recurso declara como ele volta', () {
      for (final entry in entries) {
        final action = entry.action;
        if (action == null || !action.hasLimitedUses) continue;

        expect(
          action.recharge,
          isNotNull,
          reason:
              '${entry.id} tem usos limitados e não declara `recharge`; '
              'o descanso não saberia devolvê-los',
        );
      }
    });
  });

  group('tabelas', () {
    /// Todas as tabelas do arquivo, com a origem para a mensagem de erro.
    List<({String origin, MechanicTable table})> allTables() {
      final result = <({String origin, MechanicTable table})>[];

      for (final entry in entries) {
        if (entry.table case final table?) {
          result.add((origin: entry.id, table: table));
        }
        for (final option in entry.options) {
          if (option.table case final table?) {
            result.add((origin: '${entry.id}/${option.id}', table: table));
          }
        }
      }

      return result;
    }

    test('o arquivo traz tabelas', () {
      expect(allTables(), isNotEmpty);
    });

    test('toda linha tem id único dentro da tabela', () {
      for (final item in allTables()) {
        final seen = <String>{};

        for (final row in item.table.rows) {
          expect(
            seen.add(row.id),
            isTrue,
            reason: '${item.origin} repete a linha "${row.id}"',
          );
        }
      }
    });

    test('tabela rolável cobre todas as faces do dado, sem sobreposição', () {
      for (final item in allTables()) {
        final table = item.table;
        if (!table.isRollable) continue;

        final faces = table.faces!;

        for (var value = 1; value <= faces; value++) {
          final matches =
              table.rows.where((row) => row.matches(value)).toList();

          expect(
            matches,
            hasLength(1),
            reason:
                '${item.origin}: o resultado $value casa com '
                '${matches.length} linha(s) — a tabela precisa cobrir cada '
                'face exatamente uma vez',
          );
        }
      }
    });

    test('tabela de consulta não declara dado', () {
      for (final entry in entries) {
        if (!entry.isLookupTable) continue;
        if (entry.isRollTable) continue;

        expect(
          entry.table?.isRollable ?? false,
          isFalse,
          reason:
              '${entry.id} é tabela de consulta e declara dado; a '
              'interface ofereceria rolagem numa tabela informativa',
        );
      }
    });

    test('tabela de rolagem declara dado', () {
      for (final entry in entries) {
        if (!entry.isRollTable) continue;

        expect(
          entry.table?.isRollable ?? false,
          isTrue,
          reason: '${entry.id} é tabela de rolagem e não declara `dice`',
        );
      }
    });

    test('toda linha tem a mesma largura dos cabeçalhos declarados', () {
      for (final item in allTables()) {
        final table = item.table;
        if (table.columns.isEmpty) continue;

        for (final row in table.rows) {
          expect(
            row.cells.length,
            table.columns.length,
            reason:
                '${item.origin}: a linha "${row.id}" tem '
                '${row.cells.length} célula(s) e a tabela declara '
                '${table.columns.length} coluna(s)',
          );
        }
      }
    });

    test('linha que aponta para opção aponta para uma que existe', () {
      for (final entry in entries) {
        final table = entry.table;
        if (table == null) continue;

        for (final row in table.rows) {
          final optionId = row.optionId;
          if (optionId == null) continue;

          expect(
            entry.optionById(optionId),
            isNotNull,
            reason:
                '${entry.id}: a linha "${row.id}" aponta para a opção '
                '"$optionId", que não existe na mecânica',
          );
        }
      }
    });
  });

  group('cobertura do levantamento', () {
    test('as 45 subclasses do compêndio de mecânicas estão presentes', () {
      final covered = {
        for (final entry in entries)
          if (entry.subclassId case final id?) id,
      };

      expect(
        covered,
        hasLength(45),
        reason:
            'o levantamento cobre 45 subclasses; o arquivo cobre '
            '${covered.length}',
      );
    });

    test('as listas longas do levantamento estão completas', () {
      // Conferir a CONTAGEM das listas que o levantamento enumera é o que
      // pega uma opção perdida numa edição do arquivo. O texto de cada opção
      // não é afirmado aqui de propósito: ele é revisável.
      const expected = <String, int>{
        'fighter_battle_master.maneuvers': 23,
        'fighter_arcane_archer.arcane_shot': 8,
        'fighter_rune_knight.runes': 6,
        'monk_four_elements.disciplines': 17,
        'sorcerer_draconic.draconic_ancestor': 10,
        'druid_land.circle_terrain': 8,
        'bard_spirits.tales_from_beyond': 0,
        'sorcerer_wild_magic.wild_magic_surge': 0,
      };

      for (final item in expected.entries) {
        final entry = catalog.byId(item.key);
        expect(entry, isNotNull, reason: '${item.key} não está no arquivo');
        expect(
          entry!.options,
          hasLength(item.value),
          reason: '${item.key} deveria ter ${item.value} opção(ões)',
        );
      }
    });

    test('as tabelas de rolagem do levantamento têm o tamanho esperado', () {
      const expected = <String, ({String dice, int rows})>{
        'artificer_alchemist.experimental_elixir': (dice: 'd6', rows: 6),
        'barbarian_wild_magic.wild_surge': (dice: 'd8', rows: 8),
        'bard_spirits.tales_from_beyond': (dice: 'd12', rows: 12),
        'sorcerer_wild_magic.wild_magic_surge': (dice: 'd100', rows: 50),
      };

      for (final item in expected.entries) {
        final table = catalog.byId(item.key)?.table;
        expect(table, isNotNull, reason: '${item.key} não declara tabela');
        expect(table!.dice, item.value.dice);
        expect(table.rows, hasLength(item.value.rows));
      }
    });
  });

  group('resolução contra o conteúdo real', () {
    /// Classes e subclasses mínimas, montadas a partir dos ids do asset: o
    /// resolvedor só usa id e nome, e carregar os arquivos inteiros aqui
    /// amarraria o teste a campos que ele não exercita.
    List<ClassEntry> classesFor(Iterable<String> ids) => [
      for (final id in ids)
        ClassEntry(
          id: id,
          name: id,
          hitDie: 'd8',
          source: 'phb',
          skillOptions: const [],
          savingThrows: const [],
        ),
    ];

    List<SubclassEntry> subclassesFor(Iterable<String> ids) => [
      for (final id in ids)
        SubclassEntry(
          id: id,
          classId: subclassToClass[id] ?? '',
          name: id,
          source: 'phb',
        ),
    ];

    test('um Mestre de Batalha de 3º nível conhece três manobras', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            level: 3,
            subclassId: 'fighter_battle_master',
          ),
        ],
      );

      final resolved = ClassMechanicResolver.resolve(
        character: character,
        catalog: catalog,
        classes: classesFor(const ['fighter']),
        subclasses: subclassesFor(const ['fighter_battle_master']),
      );

      final maneuvers = resolved.byId('fighter_battle_master.maneuvers')!;

      expect(maneuvers.limit, 3);
      expect(maneuvers.resource!.maximum, 4);
      expect(maneuvers.progressionNote, contains('4d8'));
      expect(maneuvers.hasPendingPicks, isTrue);
    });

    test('um Cavaleiro Rúnico de 3º nível não alcança a Runa da Colina', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            level: 3,
            subclassId: 'fighter_rune_knight',
          ),
        ],
      );

      final resolved = ClassMechanicResolver.resolve(
        character: character,
        catalog: catalog,
        classes: classesFor(const ['fighter']),
        subclasses: subclassesFor(const ['fighter_rune_knight']),
      );

      final runes = resolved.byId('fighter_rune_knight.runes')!;

      expect(runes.limit, 2);
      expect(runes.optionById('hill')!.isBlocked, isTrue);
      expect(runes.optionById('hill')!.blockReason, contains('nível 7'));
      expect(runes.optionById('cloud')!.isAvailable, isTrue);
    });

    test('a Sintonia Elemental é concedida sem gastar vaga de disciplina', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'monk',
            level: 3,
            subclassId: 'monk_four_elements',
          ),
        ],
      );

      final resolved = ClassMechanicResolver.resolve(
        character: character,
        catalog: catalog,
        classes: classesFor(const ['monk']),
        subclasses: subclassesFor(const ['monk_four_elements']),
      );

      final disciplines = resolved.byId('monk_four_elements.disciplines')!;

      expect(disciplines.limit, 1);
      expect(disciplines.optionById('elemental_attunement')!.isGranted, isTrue);
      expect(disciplines.selectedCount, 0);
      expect(disciplines.freeSlots, 1);
    });

    test('a Forma Estelar tem uma constelação ativa por vez', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'druid', level: 2, subclassId: 'druid_stars'),
        ],
      );

      final resolved = ClassMechanicResolver.resolve(
        character: character,
        catalog: catalog,
        classes: classesFor(const ['druid']),
        subclasses: subclassesFor(const ['druid_stars']),
      );

      final form = resolved.byId('druid_stars.starry_form')!;

      expect(form.maxActive, 1);
      expect(form.modes, hasLength(3));
      expect(form.entry.hasPicks, isFalse);
      // Todas acessíveis, nenhuma ativa ainda.
      expect(form.owned, hasLength(3));
      expect(form.active, isEmpty);
    });

    test('o Artilheiro mantém um canhão até o 14º e dois a partir do 15º', () {
      ResolvedClassMechanic cannonAt(int level) {
        final character = characterFixture(
          classLevels: [
            ClassLevel(
              classId: 'artificer',
              level: level,
              subclassId: 'artificer_artillerist',
            ),
          ],
        );

        return ClassMechanicResolver.resolve(
          character: character,
          catalog: catalog,
          classes: classesFor(const ['artificer']),
          subclasses: subclassesFor(const ['artificer_artillerist']),
        ).byId('artificer_artillerist.eldritch_cannon')!;
      }

      expect(cannonAt(3).maxActive, 1);
      expect(cannonAt(14).maxActive, 1);
      expect(cannonAt(15).maxActive, 2);
    });

    test('personagem sem a subclasse não recebe a mecânica dela', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 10)],
      );

      final resolved = ClassMechanicResolver.resolve(
        character: character,
        catalog: catalog,
        classes: classesFor(const ['fighter']),
      );

      expect(resolved.byId('fighter_battle_master.maneuvers'), isNull);
      expect(resolved.visible, isEmpty);
    });
  });
}
