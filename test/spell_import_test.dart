import 'dart:convert';

import 'package:dnd_ficha_app/features/compendium/data/import/spell_import_report.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_importer.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_normalizer.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_record.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_source_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cobre a importação da base de magias.
///
/// O que estes testes protegem, em uma frase: nenhuma magia entra duas vezes,
/// nenhum id troca de dono (porque a ficha referencia magia por id) e nenhum
/// valor da base é sobrescrito em silêncio.
void main() {
  SpellRecord record({
    required int id,
    required String namePt,
    String nameOriginal = '',
    int level = 1,
    String school = 'Evocação',
    String castingTime = '1 ação',
    String range = '18 m',
    String components = 'V, G',
    String duration = 'Instantânea',
    bool concentration = false,
    bool ritual = false,
    bool hasCostlyMaterials = false,
    List<String> classes = const ['Mago'],
    List<String> subclasses = const [],
    String description = 'Descrição de teste.',
    String? upcast,
    String source = 'Livro de Teste',
    String page = '100',
    bool isSrd = false,
    String edition = '2014',
    List<String> aliases = const [],
  }) {
    return SpellRecord(
      id: id,
      namePt: namePt,
      nameOriginal: nameOriginal,
      level: level,
      school: school,
      castingTime: castingTime,
      range: range,
      components: components,
      hasCostlyMaterials: hasCostlyMaterials,
      duration: duration,
      concentration: concentration,
      ritual: ritual,
      classes: classes,
      subclasses: subclasses,
      description: description,
      upcast: upcast,
      source: source,
      page: page,
      isSrd: isSrd,
      edition: edition,
      aliases: aliases,
    );
  }

  SpellImportPlan planFor({
    required List<SpellRecord> existing,
    required List<SpellRecord> incoming,
    Map<int, int> idAliases = const {},
  }) {
    return SpellImporter(idAliases: idAliases).plan(
      existing: existing,
      incoming: incoming,
      sourceLabel: 'fonte-de-teste',
      targetLabel: 'destino-de-teste',
    );
  }

  group('normalização de nome', () {
    test('ignora caixa, espaço repetido e espaço nas pontas', () {
      expect(normalizeSpellName('  BOLA   de   Fogo '), 'bola de fogo');
    });

    test('ignora acento e cedilha', () {
      expect(
        normalizeSpellName('Ilusão Menor'),
        normalizeSpellName('ilusao menor'),
      );
      expect(normalizeSpellName('Bênção'), 'bencao');
    });

    test('hífen vira espaço', () {
      expect(
        normalizeSpellName('Green-Flame Blade'),
        normalizeSpellName('Green Flame Blade'),
      );
      expect(normalizeSpellName('Green–Flame  Blade'), 'green flame blade');
    });

    test('apóstrofo desaparece em vez de virar espaço', () {
      // Trocar por espaço, como o `SpellNameIndex` do app faz, deixaria
      // "melf s acid arrow" de um lado e "melfs acid arrow" do outro, e a
      // mesma magia entraria duas vezes.
      expect(normalizeSpellName("Melf's Acid Arrow"), 'melfs acid arrow');
      expect(
        normalizeSpellName("Melf's Acid Arrow"),
        normalizeSpellName('Melfs Acid Arrow'),
      );
      expect(
        normalizeSpellName('Mordenkainen’s Sword'),
        normalizeSpellName('Mordenkainens Sword'),
      );
    });

    test('ignora o resto da pontuação', () {
      expect(normalizeSpellName('Toque Vampírico!'), 'toque vampirico');
      expect(
        normalizeSpellName('Nuvem Mortal (área)'),
        normalizeSpellName('Nuvem Mortal area'),
      );
    });

    test('remove o possessivo do autor', () {
      expect(
        normalizeSpellName(withoutAuthor("Melf's Acid Arrow")),
        'acid arrow',
      );
      expect(
        normalizeSpellName(withoutAuthor('Flecha Ácida de Melf')),
        'flecha acida',
      );
    });

    test('mantém nomes diferentes diferentes', () {
      expect(
        normalizeSpellName('Invocar Celestial'),
        isNot(normalizeSpellName('Invocar Elemental')),
      );
    });
  });

  group('identidade e duplicidade', () {
    test('magia inédita entra como adicionada', () {
      final plan = planFor(
        existing: [
          record(id: 1, namePt: 'Bola de Fogo', nameOriginal: 'Fireball'),
        ],
        incoming: [
          record(id: 2, namePt: 'Raio Solar', nameOriginal: 'Sunbeam'),
        ],
      );

      expect(plan.added, hasLength(1));
      expect(plan.added.single.incoming.id, 2);
      expect(plan.duplicates, isEmpty);
      expect(plan.conflicted, isEmpty);
    });

    test('reimportar a mesma fonte não duplica nada', () {
      final base = [
        record(id: 1, namePt: 'Bola de Fogo', nameOriginal: 'Fireball'),
        record(id: 2, namePt: 'Raio Solar', nameOriginal: 'Sunbeam'),
      ];

      final plan = planFor(existing: base, incoming: base);

      expect(plan.unchanged, hasLength(2));
      expect(plan.added, isEmpty);
      expect(plan.updated, isEmpty);
      expect(plan.hasChanges, isFalse);
    });

    test('casa por id oficial mesmo com o nome escrito diferente', () {
      final plan = planFor(
        existing: [record(id: 7, namePt: 'Bênção', nameOriginal: 'Bless')],
        incoming: [record(id: 7, namePt: 'bencao', nameOriginal: 'bless')],
      );

      expect(plan.unchanged, hasLength(1));
      expect(plan.unchanged.single.matchKey, SpellMatchKey.officialId);
    });

    test('casa por nome normalizado quando o id da fonte é outro', () {
      final plan = planFor(
        existing: [record(id: 7, namePt: 'Bênção', nameOriginal: 'Bless')],
        incoming: [record(id: 999, namePt: 'BENCAO', nameOriginal: 'Bless')],
      );

      // Não entra como nova e o id da base não muda: a ficha do personagem
      // aponta para o 7.
      expect(plan.added, isEmpty);
      expect(plan.duplicates, hasLength(1));
      expect(plan.duplicates.single.existing!.id, 7);
      expect(plan.duplicates.single.note, contains('não trocar a referência'));
    });

    test('casa pelo apelido registrado na base, não pelo nome', () {
      // O apelido é a quinta chave: nome e nome original são diferentes dos
      // dois lados, e só o apelido impede a magia de entrar de novo.
      final plan = planFor(
        existing: [
          record(
            id: 5,
            namePt: 'Flecha Ácida',
            nameOriginal: 'Acid Arrow',
            aliases: const ['Seta Ácida'],
          ),
        ],
        incoming: [
          record(id: 888, namePt: 'Seta Ácida', nameOriginal: 'Acid Dart'),
        ],
      );

      expect(plan.added, isEmpty);
      expect(plan.duplicates, hasLength(1));
      expect(plan.duplicates.single.matchKey, SpellMatchKey.alias);
      expect(plan.duplicates.single.existing!.id, 5);
    });

    test('tolera o possessivo do autor no nome', () {
      final plan = planFor(
        existing: [
          record(id: 5, namePt: 'Flecha Ácida', nameOriginal: 'Acid Arrow'),
        ],
        incoming: [
          record(
            id: 5,
            namePt: 'Flecha Ácida de Melf',
            nameOriginal: "Melf's Acid Arrow",
          ),
        ],
      );

      expect(plan.conflicted, isEmpty);
      expect(plan.unchanged, hasLength(1));
      // A base manda: o nome gravado continua o que já estava lá.
      expect(plan.unchanged.single.result!.namePt, 'Flecha Ácida');
    });

    test('mapa de ids une a magia que entrou antes com outro id', () {
      final plan = planFor(
        existing: [record(id: 10050, namePt: 'Bênção', nameOriginal: 'Bless')],
        incoming: [
          record(
            id: 40001,
            namePt: 'Bênção',
            nameOriginal: 'Bless',
            source: 'Outro Livro',
          ),
        ],
        idAliases: const {40001: 10050},
      );

      expect(plan.added, isEmpty);
      final decision = plan.decisions.single;
      expect(decision.matchKey, SpellMatchKey.mappedId);
      expect(decision.existing!.id, 10050);
    });

    test('mesma magia em outra fonte é reimpressão e não entra de novo', () {
      final plan = planFor(
        existing: [
          record(
            id: 10500,
            namePt: 'Lâmina Estrondosa',
            nameOriginal: 'Booming Blade',
            source: "Tasha's Cauldron to Everything",
          ),
        ],
        incoming: [
          record(
            id: 40010,
            namePt: 'Lâmina Estrondosa',
            nameOriginal: 'Booming Blade',
            source: 'Strixhaven: A Curriculum of Chaos',
          ),
        ],
      );

      expect(plan.added, isEmpty);
      expect(plan.duplicates, hasLength(1));
      expect(plan.duplicates.single.matchKey, SpellMatchKey.nameAcrossSources);
      expect(plan.duplicates.single.note, contains('reimpressão'));
    });

    test('homônimo com nome em inglês diferente entra, com aviso', () {
      // O caso real da base: Invocar Celestial é `Conjure Celestial` no Livro
      // do Jogador e `Summon Celestial` em Tasha. São magias diferentes.
      final plan = planFor(
        existing: [
          record(
            id: 10082,
            namePt: 'Invocar Celestial',
            nameOriginal: 'Conjure Celestial',
            source: 'Livro do Jogador (PHB)',
          ),
        ],
        incoming: [
          record(
            id: 10512,
            namePt: 'Invocar Celestial',
            nameOriginal: 'Summon Celestial',
            source: "Tasha's Cauldron to Everything",
          ),
        ],
      );

      expect(plan.added, hasLength(1));
      expect(plan.duplicates, isEmpty);
      expect(plan.warnings, hasLength(1));
      expect(plan.warnings.single.reason, contains('nome em português'));
    });

    test('sem nome em inglês dos dois lados, nada entra', () {
      final plan = planFor(
        existing: [
          record(id: 1, namePt: 'Chama Sagrada', source: 'Livro do Jogador'),
        ],
        incoming: [
          record(id: 2, namePt: 'Chama Sagrada', source: 'Outro Livro'),
        ],
      );

      expect(plan.added, isEmpty);
      expect(plan.duplicates, hasLength(1));
      expect(plan.duplicates.single.note, contains('falta o nome em inglês'));
    });

    test('duas magias iguais no mesmo arquivo de origem entram uma vez', () {
      final duplicated = record(id: 300, namePt: 'Teia', nameOriginal: 'Web');

      final plan = planFor(
        existing: const [],
        incoming: [duplicated, duplicated],
      );

      expect(plan.added, hasLength(1));
      expect(plan.unchanged, hasLength(1));
    });
  });

  group('conflito e atualização', () {
    test(
      'campo divergente nos dois lados vira conflito e a base é mantida',
      () {
        final plan = planFor(
          existing: [
            record(
              id: 1,
              namePt: 'Bola de Fogo',
              nameOriginal: 'Fireball',
              level: 3,
              description: 'Dano 8d6 de fogo.',
            ),
          ],
          incoming: [
            record(
              id: 1,
              namePt: 'Bola de Fogo',
              nameOriginal: 'Fireball',
              level: 3,
              description: 'Dano 10d6 de fogo.',
            ),
          ],
        );

        expect(plan.conflicted, hasLength(1));
        expect(plan.hasChanges, isFalse);

        final conflict = plan.conflicted.single.conflicts.single;
        expect(conflict.field, 'descricao');
        expect(conflict.currentValue, 'Dano 8d6 de fogo.');
        expect(conflict.incomingValue, 'Dano 10d6 de fogo.');
        expect(plan.formatReport(), contains('Dano 8d6 de fogo.'));
        expect(plan.formatReport(), contains('Dano 10d6 de fogo.'));
      },
    );

    test('nível diferente no mesmo id é conflito, não atualização', () {
      final plan = planFor(
        existing: [
          record(id: 1, namePt: 'Teia', nameOriginal: 'Web', level: 2),
        ],
        incoming: [
          record(id: 1, namePt: 'Teia', nameOriginal: 'Web', level: 3),
        ],
      );

      expect(plan.conflicted, hasLength(1));
      expect(
        plan.conflicted.single.conflicts.map((item) => item.field),
        contains('nivel'),
      );
    });

    test('concentração divergente aparece como conflito', () {
      final plan = planFor(
        existing: [record(id: 1, namePt: 'Teia', nameOriginal: 'Web')],
        incoming: [
          record(
            id: 1,
            namePt: 'Teia',
            nameOriginal: 'Web',
            concentration: true,
          ),
        ],
      );

      expect(
        plan.conflicted.single.conflicts.map((item) => item.field),
        contains('concentracao'),
      );
    });

    test('campo vazio na fonte não apaga o que a base tem', () {
      final plan = planFor(
        existing: [
          record(
            id: 1,
            namePt: 'Bola de Fogo',
            nameOriginal: 'Fireball',
            upcast: 'Aumenta 1d6 por círculo acima do 3º.',
          ),
        ],
        incoming: [
          record(id: 1, namePt: 'Bola de Fogo', nameOriginal: 'Fireball'),
        ],
      );

      expect(plan.conflicted, isEmpty);
      expect(plan.unchanged, hasLength(1));
      expect(
        plan.unchanged.single.result!.upcast,
        'Aumenta 1d6 por círculo acima do 3º.',
      );
    });

    test('campo vazio na base é completado pela fonte', () {
      final plan = planFor(
        existing: [record(id: 1, namePt: 'Bola de Fogo', nameOriginal: '')],
        incoming: [
          record(id: 1, namePt: 'Bola de Fogo', nameOriginal: 'Fireball'),
        ],
      );

      expect(plan.updated, hasLength(1));
      expect(plan.updated.single.result!.nameOriginal, 'Fireball');
      expect(plan.hasChanges, isTrue);
    });

    test('listas de classe são unidas sem repetir', () {
      final plan = planFor(
        existing: [
          record(
            id: 1,
            namePt: 'Bola de Fogo',
            nameOriginal: 'Fireball',
            classes: const ['Mago'],
          ),
        ],
        incoming: [
          record(
            id: 1,
            namePt: 'Bola de Fogo',
            nameOriginal: 'Fireball',
            classes: const ['Mago', 'Feiticeiro'],
          ),
        ],
      );

      expect(plan.updated, hasLength(1));
      expect(plan.updated.single.result!.classes, ['Mago', 'Feiticeiro']);
    });

    test('união de classe ignora diferença de acento', () {
      final plan = planFor(
        existing: [
          record(
            id: 1,
            namePt: 'Bola de Fogo',
            nameOriginal: 'Fireball',
            classes: const ['Clérigo'],
          ),
        ],
        incoming: [
          record(
            id: 1,
            namePt: 'Bola de Fogo',
            nameOriginal: 'Fireball',
            classes: const ['Clerigo'],
          ),
        ],
      );

      expect(plan.unchanged, hasLength(1));
      expect(plan.unchanged.single.result!.classes, ['Clérigo']);
    });

    test('aplicar duas vezes seguidas não muda nada na segunda', () {
      final existing = [record(id: 1, namePt: 'Teia', nameOriginal: '')];
      final incoming = [record(id: 1, namePt: 'Teia', nameOriginal: 'Web')];

      final first = planFor(existing: existing, incoming: incoming);
      expect(first.updated, hasLength(1));

      final second = planFor(
        existing: [first.updated.single.result!],
        incoming: incoming,
      );

      expect(second.updated, isEmpty);
      expect(second.unchanged, hasLength(1));
      expect(second.hasChanges, isFalse);
    });
  });

  group('validação da fonte', () {
    const parser = SpellSourceParser();

    SpellParseResult parse(Map<String, dynamic> row) => parser.parseJson({
      'dados': [row],
    });

    Map<String, dynamic> validRow() => {
      'id': 40001,
      'nome': 'Teste',
      'original': 'Test',
      'nivel': 1,
      'escola': 'Evocação',
      'tempo': '1 ação',
      'alcance': '18 m',
      'componentes': 'V, G',
      'duracao': 'Instantânea',
      'descricao': 'Faz algo.',
      'classes': 'Mago',
      'fonte': 'Livro de Teste',
      'pagina': '10',
    };

    test('registro completo é aceito', () {
      final result = parse(validRow());

      expect(result.rejected, isEmpty);
      expect(result.records, hasLength(1));
      expect(result.records.single.namePt, 'Teste');
      expect(result.records.single.edition, '2014');
    });

    test('magia sem id é rejeitada com motivo e correção', () {
      final row = validRow()..remove('id');
      final result = parse(row);

      expect(result.records, isEmpty);
      final issue = result.rejected.single.firstWhere(
        (item) => item.field == 'id',
      );
      expect(issue.spellLabel, 'Teste');
      expect(issue.reason, contains('referencia magia por id'));
      expect(issue.suggestion, isNotNull);
    });

    test('id não numérico é rejeitado', () {
      final result = parse(validRow()..['id'] = 'SCC-1');

      expect(result.records, isEmpty);
      expect(result.rejected.single.map((item) => item.field), contains('id'));
    });

    test('nível fora de 0 a 9 é rejeitado', () {
      final result = parse(validRow()..['nivel'] = 12);

      expect(result.records, isEmpty);
      final issue = result.rejected.single.firstWhere(
        (item) => item.field == 'nivel',
      );
      expect(issue.received, '12');
      expect(issue.reason, contains('0 a 9'));
    });

    test('"Truque" vira nível 0 e avisa a conversão', () {
      final result = parse(validRow()..['nivel'] = 'Truque');

      expect(result.records.single.level, 0);
      expect(result.warnings.map((item) => item.field), contains('nivel'));
    });

    test('"3º círculo" vira nível 3', () {
      expect(
        parse(validRow()..['nivel'] = '3º círculo').records.single.level,
        3,
      );
      expect(
        parse(validRow()..['nivel'] = '3o circulo').records.single.level,
        3,
      );
    });

    test('nível em texto sem número é rejeitado', () {
      final result = parse(validRow()..['nivel'] = 'altíssimo');

      expect(result.records, isEmpty);
      expect(
        result.rejected.single.map((item) => item.field),
        contains('nivel'),
      );
    });

    test('página numérica é convertida para texto, com aviso', () {
      // `loadSpells` faz `spell['pagina'] as String?`: um número aqui derruba a
      // leitura de todos os arquivos de magia.
      final result = parse(validRow()..['pagina'] = 213);

      expect(result.records.single.page, '213');
      final warning = result.warnings.firstWhere(
        (item) => item.field == 'pagina',
      );
      expect(warning.suggestion, contains('213'));
    });

    test('campo obrigatório vazio é rejeitado nomeando o campo', () {
      final result = parse(validRow()..['descricao'] = '   ');

      expect(result.records, isEmpty);
      final issue = result.rejected.single.firstWhere(
        (item) => item.field == 'descricao',
      );
      expect(issue.reason, contains('descrição'));
    });

    test('classe desconhecida é rejeitada em vez de sumir calada', () {
      final result = parse(validRow()..['classes'] = 'Necromante');

      expect(result.records, isEmpty);
      final issue = result.rejected.single.firstWhere(
        (item) => item.field == 'classes',
      );
      expect(issue.received, 'Necromante');
      expect(issue.reason, contains('descarta classe desconhecida'));
      expect(issue.suggestion, contains('Mago'));
    });

    test('"Patrulheiro" é corrigido para a grafia que o asset exige', () {
      // O asset precisa de "Guardião"; "Patrulheiro" é só o rótulo da UI e
      // faria a magia sumir do filtro.
      final result = parse(validRow()..['classes'] = 'Patrulheiro, Druida');

      expect(result.records.single.classes, ['Guardião', 'Druida']);
      final warning = result.warnings.firstWhere(
        (item) => item.field == 'classes',
      );
      expect(warning.suggestion, 'Guardião');
    });

    test('classe sem acento é corrigida', () {
      final result = parse(validRow()..['classes'] = 'clerigo, artifice');

      expect(result.records.single.classes, ['Clérigo', 'Artífice']);
    });

    test('HTML no texto é rejeitado', () {
      final result = parse(
        validRow()..['descricao'] = 'Linha um.<br>Linha dois.',
      );

      expect(result.records, isEmpty);
      final issue = result.rejected.single.firstWhere(
        (item) => item.field == 'descricao',
      );
      expect(issue.reason, contains('HTML'));
    });

    test('entidade HTML também é rejeitada', () {
      final result = parse(validRow()..['descricao'] = '&emsp;Recuado.');

      expect(result.records, isEmpty);
    });

    test('classes vazias viram lista vazia com aviso, sem rejeitar', () {
      // O caso de Codificar Pensamentos, que é só de subclasse.
      final result = parse(
        validRow()
          ..['classes'] = '—'
          ..['subclasses'] = 'Magias da Guilda: Casa Dimir',
      );

      expect(result.records, hasLength(1));
      expect(result.records.single.classes, isEmpty);
      expect(result.records.single.subclasses, [
        'Magias da Guilda: Casa Dimir',
      ]);
    });

    test(
      'magia sem classe e sem subclasse avisa que fica fora dos filtros',
      () {
        final result = parse(validRow()..['classes'] = '');

        expect(result.records, hasLength(1));
        expect(
          result.warnings.map((item) => item.reason).join(),
          contains('não aparece em nenhum filtro'),
        );
      },
    );

    test('"Sim" e "Não" são aceitos como booleano', () {
      final result = parse(
        validRow()
          ..['concentracao'] = 'Sim'
          ..['ritual'] = 'Não'
          ..['srd'] = 'não',
      );

      final spell = result.records.single;
      expect(spell.concentration, isTrue);
      expect(spell.ritual, isFalse);
      expect(spell.isSrd, isFalse);
    });

    test('classes em lista JSON também são aceitas', () {
      final result = parse(validRow()..['classes'] = ['Mago', 'Bardo']);

      expect(result.records.single.classes, ['Mago', 'Bardo']);
    });

    test('registro inválido não impede os válidos de entrarem', () {
      final result = parser.parseJson({
        'dados': [
          validRow(),
          validRow()
            ..['id'] = 40002
            ..['nome'] = 'Quebrada'
            ..['nivel'] = 42,
          validRow()
            ..['id'] = 40003
            ..['nome'] = 'Boa',
        ],
      });

      expect(result.receivedCount, 3);
      expect(result.records, hasLength(2));
      expect(result.rejected, hasLength(1));
      expect(result.rejected.single.first.spellLabel, 'Quebrada');
    });

    test('envelope do asset e lista crua são lidos igual', () {
      final envelope = parser.parseJson({
        'dados': [validRow()],
      });
      final list = parser.parseJson([validRow()]);

      expect(envelope.records.single.id, list.records.single.id);
    });

    test('material com custo é deduzido do texto do componente', () {
      final withCost = parse(
        validRow()..['componentes'] = 'V, G, M (um rubi de 50 po)',
      );
      final withoutCost = parse(
        validRow()..['componentes'] = 'V, G, M (areia)',
      );

      expect(withCost.records.single.hasCostlyMaterials, isTrue);
      expect(withoutCost.records.single.hasCostlyMaterials, isFalse);
    });

    test('materiaispagos declarado vence a dedução', () {
      final result = parse(
        validRow()
          ..['componentes'] = 'V, G, M (um rubi de 50 po)'
          ..['materiaispagos'] = false,
      );

      expect(result.records.single.hasCostlyMaterials, isFalse);
    });
  });

  group('fonte em texto rotulado', () {
    const parser = SpellSourceParser(defaultSource: 'Livro de Teste');

    test('lê um bloco com rótulos por linha', () {
      final result = parser.parseLabeledText('''
Nome: Mãos Flamejantes
Original: Burning Hands
Nível: 1º círculo
Escola: Evocação
Tempo: 1 ação
Alcance: Cone de 4,5 m
Componentes: V, G
Duração: Instantânea
Concentração: Não
Ritual: Não
Classes: Mago, Feiticeiro
Descrição: Um leque de chamas se abre das suas mãos.
Upcast: Mais 1d6 por círculo acima do 1º.
Fonte: Livro do Jogador (PHB)
Página: 258
ID: 12345
SRD: Sim
''');

      expect(result.rejected, isEmpty);
      final spell = result.records.single;
      expect(spell.id, 12345);
      expect(spell.namePt, 'Mãos Flamejantes');
      expect(spell.nameOriginal, 'Burning Hands');
      expect(spell.level, 1);
      expect(spell.classes, ['Mago', 'Feiticeiro']);
      expect(spell.upcast, 'Mais 1d6 por círculo acima do 1º.');
      expect(spell.source, 'Livro do Jogador (PHB)');
      expect(spell.page, '258');
      expect(spell.isSrd, isTrue);
    });

    test('separa magias por linha de tracejado e por repetição do rótulo', () {
      final result = parser.parseLabeledText('''
ID: 1
Nome: Primeira
Original: First
Nível: Truque
Escola: Evocação
Tempo: 1 ação
Alcance: Toque
Componentes: V
Duração: Instantânea
Descrição: Faz algo.
Fonte: Livro de Teste
Página: 1
--------
ID: 2
Nome: Segunda
Original: Second
Nível: 2
Escola: Evocação
Tempo: 1 ação
Alcance: Toque
Componentes: V
Duração: Instantânea
Descrição: Faz outra coisa.
Fonte: Livro de Teste
Página: 2
''');

      expect(result.receivedCount, 2);
      expect(result.records.map((item) => item.namePt), [
        'Primeira',
        'Segunda',
      ]);
    });

    test('linha sem rótulo continua a descrição', () {
      final result = parser.parseLabeledText('''
ID: 3
Nome: Longa
Original: Long
Nível: 1
Escola: Evocação
Tempo: 1 ação
Alcance: Toque
Componentes: V
Duração: Instantânea
Descrição: Primeiro parágrafo.
Segundo parágrafo da mesma magia.
Fonte: Livro de Teste
Página: 3
''');

      expect(
        result.records.single.description,
        'Primeiro parágrafo.\nSegundo parágrafo da mesma magia.',
      );
    });

    test('rótulo desconhecido vira aviso em vez de sumir', () {
      final result = parser.parseLabeledText('''
ID: 4
Nome: Com Extra
Original: With Extra
Nível: 1
Escola: Evocação
Tempo: 1 ação
Alcance: Toque
Componentes: V
Duração: Instantânea
Descrição: Faz algo.
Salvaguarda: Destreza
Fonte: Livro de Teste
Página: 4
''');

      expect(result.records, hasLength(1));
      final warning = result.warnings.firstWhere(
        (item) => item.field == '(rótulo desconhecido)',
      );
      expect(warning.received, contains('Salvaguarda'));
    });

    test('lê o formato de catálogo, com título e cabeçalho de seção', () {
      // Formato real dos catálogos de magia: o nome e o nome original vêm na
      // linha de título, o tracejado separa o título dos campos, e a descrição
      // e o upcast vêm sob cabeçalhos em linha própria.
      final result = parser.parseLabeledText('''
CATÁLOGO DE MAGIAS
Total de magias: 2

##############################################################################

FONTE DE EXEMPLO
Quantidade de magias: 2
==============================================================================
1. Dobra do Vórtice (Vortex Warp)
------------------------------------------------------------------------------
ID: 40004
Nível: 2º círculo
Escola: Invocação
Tempo de conjuração: Uma ação
Alcance: 27m [90 ft.]
Componentes: V S
Possui componente material com custo: Não
Duração: Instantânea
Concentração: Não
Ritual: Não
Classes: Artífice, Feiticeiro, Mago
Subclasses ou disponibilidade especial: —
Fonte: Strixhaven: A Curriculum of Chaos (SCC)
Página: 38
SRD: Não

DESCRIÇÃO
Você distorce o espaço ao redor de uma criatura.
    O alvo deve fazer uma salvaguarda de Constituição.

EM CÍRCULOS SUPERIORES
Ao conjurar com um espaço de 3º círculo ou superior, o alcance aumenta.

==============================================================================
2. Codificar Pensamentos (Encode Thoughts)
------------------------------------------------------------------------------
ID: 41001
Nível: Truque
Escola: Encantamento
Tempo de conjuração: Uma ação
Alcance: Pessoal
Componentes: S
Possui componente material com custo: Não
Duração: 8 horas
Concentração: Não
Ritual: Não
Classes: —
Subclasses ou disponibilidade especial: Magias da Guilda: Casa Dimir
Fonte: Guildmasters' Guide to Ravnica (GGR)
Página: 47
SRD: Não

DESCRIÇÃO
Você extrai de sua mente uma lembrança e a transforma em um filamento.
''');

      expect(result.rejected, isEmpty);
      expect(result.records, hasLength(2));

      final warp = result.records.first;
      expect(warp.namePt, 'Dobra do Vórtice');
      expect(warp.nameOriginal, 'Vortex Warp');
      expect(warp.id, 40004);
      expect(warp.level, 2);
      expect(warp.hasCostlyMaterials, isFalse);
      expect(warp.subclasses, isEmpty);
      // A fonte tem dois-pontos no meio e precisa chegar inteira.
      expect(warp.source, 'Strixhaven: A Curriculum of Chaos (SCC)');
      expect(
        warp.description,
        'Você distorce o espaço ao redor de uma criatura.\n'
        'O alvo deve fazer uma salvaguarda de Constituição.',
      );
      expect(warp.upcast, contains('o alcance aumenta'));
      // O cabeçalho da fonte não pode ter grudado no texto da magia.
      expect(warp.upcast, isNot(contains('FONTE DE EXEMPLO')));
      expect(warp.description, isNot(contains('Quantidade de magias')));

      final encode = result.records.last;
      expect(encode.level, 0);
      expect(encode.classes, isEmpty);
      expect(encode.subclasses, ['Magias da Guilda: Casa Dimir']);
      expect(encode.namePt, 'Codificar Pensamentos');
    });

    test('capa e cabeçalho de fonte não viram registro rejeitado', () {
      final result = parser.parseLabeledText('''
CATÁLOGO DE MAGIAS
Total de magias: 1

##############################################################################

FONTE DE EXEMPLO
Quantidade de magias: 1
==============================================================================
1. Teste (Test)
------------------------------------------------------------------------------
ID: 1
Nível: 1
Escola: Evocação
Tempo de conjuração: Uma ação
Alcance: Toque
Componentes: V
Duração: Instantânea
Classes: Mago
Fonte: Livro de Teste
Página: 1

DESCRIÇÃO
Faz algo.
''');

      expect(result.records, hasLength(1));
      expect(result.rejected, isEmpty);
      expect(result.receivedCount, 1);

      final warning = result.warnings.firstWhere(
        (item) => item.field == '(blocos sem magia)',
      );
      expect(warning.received, contains('bloco'));
    });

    test('linha de descrição terminada em parênteses não vira título', () {
      final result = parser.parseLabeledText('''
==============================================================================
1. Teste (Test)
------------------------------------------------------------------------------
ID: 1
Nível: 1
Escola: Evocação
Tempo de conjuração: Uma ação
Alcance: Toque
Componentes: V
Duração: Instantânea
Classes: Mago
Fonte: Livro de Teste
Página: 1

DESCRIÇÃO
O alvo sofre dano energético (nenhum outro efeito)
''');

      expect(result.records, hasLength(1));
      expect(result.records.single.namePt, 'Teste');
      expect(
        result.records.single.description,
        'O alvo sofre dano energético (nenhum outro efeito)',
      );
    });

    test('usa a fonte padrão quando o bloco não declara', () {
      final result = parser.parseLabeledText('''
ID: 5
Nome: Sem Fonte
Original: No Source
Nível: 1
Escola: Evocação
Tempo: 1 ação
Alcance: Toque
Componentes: V
Duração: Instantânea
Descrição: Faz algo.
Página: 5
''');

      expect(result.records.single.source, 'Livro de Teste');
    });
  });

  group('serialização', () {
    test('o registro sai no formato que a leitura do app espera', () {
      final json =
          record(
            id: 40001,
            namePt: 'Teste',
            nameOriginal: 'Test',
            classes: const ['Mago', 'Bardo'],
            subclasses: const ['Guerreiro (Cavaleiro Arcano)'],
          ).toAssetJson();

      expect(json['id'], isA<int>());
      expect(json['nivel'], isA<int>());
      expect(json['pagina'], isA<String>());
      expect(json['classes'], 'Mago, Bardo');
      expect(json['subclasses'], 'Guerreiro (Cavaleiro Arcano)');
      expect(json['srd'], isA<bool>());
      expect(json['upcast'], '');

      // Mesmas chaves dos assets que já existem, nem mais nem menos.
      expect(json.keys.toSet(), {
        'nome',
        'id',
        'original',
        'nivel',
        'escola',
        'tempo',
        'alcance',
        'componentes',
        'materiaispagos',
        'duracao',
        'concentracao',
        'ritual',
        'classes',
        'subclasses',
        'descricao',
        'upcast',
        'fonte',
        'pagina',
        'srd',
      });
    });

    test('o que é serializado volta igual pelo leitor', () {
      const original = SpellRecord(
        id: 40002,
        namePt: 'Ida e Volta',
        nameOriginal: 'Round Trip',
        level: 4,
        school: 'Transmutação',
        castingTime: '1 ação bônus',
        range: 'Pessoal',
        components: 'V, G, M (uma pena)',
        hasCostlyMaterials: false,
        duration: '1 minuto',
        concentration: true,
        ritual: false,
        classes: ['Mago'],
        subclasses: [],
        description: 'Vai e volta.',
        upcast: null,
        source: 'Livro de Teste',
        page: '42',
        isSrd: false,
      );

      final decoded =
          jsonDecode(jsonEncode(original.toAssetJson()))
              as Map<String, dynamic>;
      final result = const SpellSourceParser().parseJson({
        'dados': [decoded],
      });

      expect(result.rejected, isEmpty);
      final back = result.records.single;
      expect(back.id, original.id);
      expect(back.namePt, original.namePt);
      expect(back.level, original.level);
      expect(back.concentration, isTrue);
      expect(back.upcast, isNull);
      expect(back.classes, original.classes);
    });
  });

  group('relatório', () {
    test('traz todos os contadores pedidos', () {
      final plan = planFor(
        existing: [
          record(id: 1, namePt: 'Igual', nameOriginal: 'Same'),
          record(id: 2, namePt: 'Conflitante', nameOriginal: 'Clash'),
        ],
        incoming: [
          record(id: 1, namePt: 'Igual', nameOriginal: 'Same'),
          record(
            id: 2,
            namePt: 'Conflitante',
            nameOriginal: 'Clash',
            description: 'Outra descrição.',
          ),
          record(id: 3, namePt: 'Nova', nameOriginal: 'New'),
        ],
      );

      final report = plan.formatReport();

      expect(report, contains('Registros recebidos ........ 3'));
      expect(report, contains('Magias adicionadas ......... 1'));
      expect(report, contains('Magias inalteradas ......... 1'));
      expect(report, contains('Conflitos .................. 1'));
      expect(report, contains('Duplicidades evitadas ...... 0'));
      expect(report, contains('Registros rejeitados ....... 0'));
      expect(report, contains('fonte-de-teste'));
      expect(report, contains('destino-de-teste'));
    });

    test('registro rejeitado aparece com campo, valor e motivo', () {
      final parsed = const SpellSourceParser().parseJson({
        'dados': [
          {'nome': 'Sem Id', 'nivel': 1},
        ],
      });

      final plan = SpellImporter().plan(
        existing: const [],
        incoming: parsed.records,
        rejected: parsed.rejected,
        receivedCount: parsed.receivedCount,
        sourceLabel: 'fonte',
        targetLabel: 'destino',
      );

      final report = plan.formatReport();

      expect(plan.rejected, hasLength(1));
      expect(report, contains('REJEITADAS'));
      expect(report, contains('Sem Id'));
      expect(report, contains('id'));
    });

    test('plano sem mudança diz que não há o que fazer', () {
      final base = [record(id: 1, namePt: 'Igual', nameOriginal: 'Same')];
      final plan = planFor(existing: base, incoming: base);

      expect(plan.hasChanges, isFalse);
      expect(plan.formatReport(), contains('Nada a fazer'));
    });
  });
}
