import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/compendium/data/import/spell_normalizer.dart';
import 'package:dnd_ficha_app/features/compendium/data/spell_assets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guarda a base de magias.
///
/// Armas, talentos, raças e equipamento de classe já tinham um teste assim; as
/// magias não, e são o único asset que a leitura abre com cast direto
/// (`spell['id'] as int`, `spell['pagina'] as String?`). Um registro novo com o
/// tipo errado não quebra só a própria magia: derruba a leitura dos quatro
/// arquivos e o compêndio inteiro mostra "erro ao carregar magias".
void main() {
  final records = <_SpellRow>[];

  setUpAll(() {
    for (final path in spellAssetPaths) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'asset ausente: $path');

      final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final rows = raw['dados'] as List<dynamic>? ?? const [];

      for (final row in rows) {
        records.add(_SpellRow(path, Map<String, dynamic>.from(row as Map)));
      }
    }
  });

  test('a base tem magia em todos os arquivos declarados', () {
    expect(records, isNotEmpty);

    // O arquivo das fontes adicionais pode estar vazio enquanto não houver
    // importação, mas os três livros precisam ter conteúdo.
    for (final path in spellAssetPaths.take(3)) {
      expect(
        records.where((item) => item.path == path),
        isNotEmpty,
        reason: '$path ficou sem nenhuma magia',
      );
    }
  });

  test('nenhum id de magia se repete', () {
    // `CharacterSpell.spellId` é esse id. Com id repetido, a ficha resolve a
    // magia pela primeira ocorrência e o painel de combate pela última, então o
    // personagem mostra uma magia em uma tela e outra na seguinte.
    final owners = <int, String>{};
    final duplicates = <String>[];

    for (final item in records) {
      final id = item.row['id'];
      if (id is! int) continue;

      final owner = owners[id];
      if (owner != null) {
        duplicates.add('id $id: "$owner" e "${item.name}" (${item.path})');
      } else {
        owners[id] = item.name;
      }
    }

    expect(duplicates, isEmpty, reason: duplicates.join('\n'));
  });

  test('id é inteiro positivo e pagina é texto', () {
    final problems = <String>[];

    for (final item in records) {
      final id = item.row['id'];
      if (id is! int) {
        problems.add('${item.name} (${item.path}): id "$id" não é int');
      } else if (id <= 0) {
        problems.add('${item.name} (${item.path}): id $id não é positivo');
      }

      final page = item.row['pagina'];
      if (page is! String) {
        problems.add(
          '${item.name} (${item.path}): pagina "$page" não é String',
        );
      }
    }

    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('nivel é inteiro de 0 a 9', () {
    // A tela do compêndio monta o filtro de nível com 0..9 fixo: magia fora
    // dessa faixa aparece na lista mas nenhum filtro a alcança.
    final problems = <String>[];

    for (final item in records) {
      final level = item.row['nivel'];
      if (level is! int || level < 0 || level > 9) {
        problems.add('${item.name} (${item.path}): nivel "$level"');
      }
    }

    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('campos obrigatórios não estão vazios', () {
    final problems = <String>[];

    for (final item in records) {
      for (final field in const [
        'nome',
        'escola',
        'tempo',
        'alcance',
        'componentes',
        'duracao',
        'descricao',
        'fonte',
      ]) {
        final value = item.row[field];
        if (value is! String || value.trim().isEmpty) {
          problems.add('${item.name} (${item.path}): $field vazio');
        }
      }
    }

    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('os campos de sim ou não são booleanos de verdade', () {
    final problems = <String>[];

    for (final item in records) {
      for (final field in const [
        'materiaispagos',
        'concentracao',
        'ritual',
        'srd',
      ]) {
        if (item.row[field] is! bool) {
          problems.add(
            '${item.name} (${item.path}): $field = "${item.row[field]}"',
          );
        }
      }
    }

    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('toda classe citada é uma que a leitura reconhece', () {
    // `_mapClassName` descarta nome de classe desconhecido em silêncio. Com
    // "Patrulheiro" em vez de "Guardião", a magia simplesmente não aparece no
    // filtro de patrulheiro e nada avisa.
    final problems = <String>[];

    for (final item in records) {
      final raw = item.row['classes'];
      if (raw == null) continue;
      if (raw is! String) {
        problems.add('${item.name} (${item.path}): classes não é texto');
        continue;
      }

      for (final name in raw.split(',')) {
        final trimmed = name.trim();
        if (trimmed.isEmpty) continue;

        final canonical = canonicalClassName(trimmed);
        if (canonical == null) {
          problems.add(
            '${item.name} (${item.path}): classe "$trimmed" é desconhecida',
          );
        } else if (canonical != trimmed) {
          problems.add(
            '${item.name} (${item.path}): classe "$trimmed" deveria ser '
            '"$canonical" para a leitura reconhecer',
          );
        }
      }
    }

    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('"quantidade" do envelope bate com o número de registros', () {
    final problems = <String>[];

    for (final path in spellAssetPaths) {
      final raw =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      final rows = raw['dados'] as List<dynamic>? ?? const [];
      final declared = raw['quantidade'];

      if (declared != rows.length) {
        problems.add('$path: quantidade=$declared, registros=${rows.length}');
      }
    }

    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('magias distintas que repetem o nome em português são conhecidas', () {
    // Não é erro: o nome em inglês é que identifica a magia. Mas repetir o nome
    // em português faz a busca listar as duas, e `SpellNameIndex` resolve o
    // nome para a primeira. Esta lista existe para que um par novo apareça numa
    // revisão em vez de passar batido.
    const known = {'invocar celestial', 'invocar elemental', 'invocar feerico'};

    final byName = <String, List<_SpellRow>>{};
    for (final item in records) {
      final key = normalizeSpellName(item.name);
      byName.putIfAbsent(key, () => []).add(item);
    }

    final unexpected = <String>[];
    byName.forEach((key, items) {
      if (items.length < 2 || known.contains(key)) return;
      unexpected.add(
        '"$key": ${items.map((item) => '${item.row['original']} '
        '(${item.row['fonte']}, id ${item.row['id']})').join(' x ')}',
      );
    });

    expect(
      unexpected,
      isEmpty,
      reason:
          'nome em português repetido sem registro prévio:\n'
          '${unexpected.join('\n')}',
    );
  });

  test('nome em inglês não se repete dentro da mesma fonte', () {
    // Mesma magia duas vezes no mesmo livro é duplicata de verdade.
    final seen = <String, String>{};
    final duplicates = <String>[];

    for (final item in records) {
      final original = item.row['original'];
      if (original is! String || original.trim().isEmpty) continue;

      final key = '${normalizeSpellName(original)}|${item.row['fonte']}';
      final owner = seen[key];
      if (owner != null) {
        duplicates.add(
          '"$original" em "${item.row['fonte']}": $owner e '
          'id ${item.row['id']}',
        );
      } else {
        seen[key] = 'id ${item.row['id']}';
      }
    }

    expect(duplicates, isEmpty, reason: duplicates.join('\n'));
  });
}

class _SpellRow {
  _SpellRow(this.path, this.row);

  final String path;
  final Map<String, dynamic> row;

  String get name => row['nome']?.toString() ?? '(sem nome)';
}
