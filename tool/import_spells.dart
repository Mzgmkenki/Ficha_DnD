// Importador da base de magias.
//
// Roda fora do app, com o Dart puro do SDK, porque mexe em asset e não em
// banco: a base de magias é arquivo JSON lido em tempo de execução, então
// atualizar é reescrever arquivo, não migrar tabela.
//
// Uso:
//   dart run tool/import_spells.dart <fonte> [opções]
//
// Opções:
//   --apply              grava as alterações. Sem ela, só mostra a prévia.
//   --out <arquivo>      asset de destino das magias novas.
//                        (padrão: assets/data/spells/magias-fontes-adicionais.json)
//   --fonte <texto>      nome do livro, para registros que não declaram `fonte`.
//   --edicao <texto>     edição assumida (padrão: 2014).
//   --mapa-ids <a=b,...> id da fonte = id já usado na base, para unir a mesma
//                        magia que entrou antes com outro id.
//   --relatorio <saida>  grava o relatório também num arquivo.
//
// O padrão é não gravar. Importação que apaga magia referenciada por ficha não
// tem desfazer dentro do app, então a gravação é sempre explícita.
import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/compendium/data/import/spell_import_report.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_importer.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_record.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_source_parser.dart';
import 'package:dnd_ficha_app/features/compendium/data/spell_assets.dart';

const String defaultTarget = 'assets/data/spells/magias-fontes-adicionais.json';

Future<void> main(List<String> args) async {
  final options = _Options.parse(args);

  if (options.sourcePath == null) {
    stderr.writeln(_usage);
    exitCode = 64;
    return;
  }

  final sourceFile = File(options.sourcePath!);
  if (!sourceFile.existsSync()) {
    stderr.writeln('Arquivo de origem não encontrado: ${options.sourcePath}');
    exitCode = 66;
    return;
  }

  // ETAPA 1 — leitura da fonte.
  final rawText = sourceFile.readAsStringSync();
  final parser = SpellSourceParser(
    defaultSource: options.sourceName,
    defaultEdition: options.edition,
  );

  // ETAPA 2 e 3 — validação e normalização de cada registro.
  final parsed = _parseSource(parser, sourceFile, rawText);
  if (parsed == null) {
    stderr.writeln(
      'Não foi possível entender o arquivo. JSON precisa ter uma lista em '
      '"dados"; texto precisa ter uma linha "Nome: ..." por magia.',
    );
    exitCode = 65;
    return;
  }

  if (parsed.receivedCount == 0) {
    stderr.writeln('A fonte não trouxe nenhum registro de magia.');
    exitCode = 65;
    return;
  }

  // ETAPA 4 — carrega a base atual e procura correspondências.
  final existingByFile = <String, List<SpellRecord>>{};
  for (final path in spellAssetPaths) {
    final file = File(path);
    if (!file.existsSync()) {
      stderr.writeln('Asset da base ausente: $path');
      exitCode = 66;
      return;
    }
    existingByFile[path] = _readAsset(file, options.edition);
  }

  final existing = existingByFile.values.expand((item) => item).toList();

  // ETAPA 5 — decide adição, atualização, duplicidade e conflito.
  final importer = SpellImporter(idAliases: options.idAliases);
  final plan = importer.plan(
    existing: existing,
    incoming: parsed.records,
    rejected: parsed.rejected,
    sourceWarnings: parsed.warnings,
    receivedCount: parsed.receivedCount,
    sourceLabel: sourceFile.path,
    targetLabel: options.targetPath,
  );

  // ETAPA 6 — prévia.
  final report = plan.formatReport();
  stdout.write(report);

  if (options.reportPath != null) {
    File(options.reportPath!).writeAsStringSync(report);
    stdout.writeln('Relatório gravado em ${options.reportPath}');
  }

  stdout.writeln('');
  stdout.writeln(
    'Base atual: ${existing.length} magias em '
    '${spellAssetPaths.length} arquivos.',
  );

  if (!options.apply) {
    stdout.writeln('');
    stdout.writeln(
      'PRÉVIA — nada foi gravado. Rode de novo com --apply para '
      'aplicar.',
    );
    if (plan.needsReview) {
      stdout.writeln(
        'Há conflito ou registro rejeitado acima. Resolva na '
        'fonte antes de aplicar.',
      );
    }
    return;
  }

  if (!plan.hasChanges) {
    stdout.writeln('');
    stdout.writeln('Nada para gravar: nenhuma adição nem atualização.');
    return;
  }

  // ETAPA 7 — aplicação, com cópia de segurança antes.
  final backupDir = _backup(spellAssetPaths);
  stdout.writeln('');
  stdout.writeln('Cópia de segurança da base em: $backupDir');

  final written = _apply(
    plan: plan,
    existingByFile: existingByFile,
    targetPath: options.targetPath,
    edition: options.edition,
  );

  for (final path in written) {
    stdout.writeln('Gravado: $path');
  }

  // ETAPA 8 — validação final: relê o que foi gravado e confere invariantes.
  final problems = _validateBase();
  if (problems.isEmpty) {
    stdout.writeln('');
    stdout.writeln('Validação final: base consistente.');
    return;
  }

  stderr.writeln('');
  stderr.writeln('VALIDAÇÃO FINAL FALHOU. Restaure de $backupDir:');
  for (final problem in problems) {
    stderr.writeln('  ✗ $problem');
  }
  exitCode = 70;
}

SpellParseResult? _parseSource(
  SpellSourceParser parser,
  File file,
  String rawText,
) {
  final looksJson =
      file.path.toLowerCase().endsWith('.json') ||
      rawText.trimLeft().startsWith('{') ||
      rawText.trimLeft().startsWith('[');

  if (looksJson) {
    try {
      final result = parser.parseJson(jsonDecode(rawText));
      if (result.receivedCount > 0) return result;
    } on FormatException catch (error) {
      stderr.writeln('JSON inválido: ${error.message}');
      return null;
    }
  }

  final result = parser.parseLabeledText(rawText);
  return result.receivedCount > 0 ? result : null;
}

List<SpellRecord> _readAsset(File file, String edition) {
  final decoded = jsonDecode(file.readAsStringSync());
  final rows =
      decoded is Map
          ? (decoded['dados'] as List<dynamic>? ?? const [])
          : (decoded as List<dynamic>);

  return [
    for (final row in rows)
      if (row is Map) _recordFromAsset(Map<String, dynamic>.from(row), edition),
  ];
}

/// Lê um registro que já está num asset.
///
/// Aqui não se valida: o que está na base é a verdade com que a importação é
/// comparada. Quem guarda a sanidade da base é `test/spells_asset_test.dart`.
SpellRecord _recordFromAsset(Map<String, dynamic> row, String edition) {
  String text(String key) => row[key]?.toString().trim() ?? '';
  bool flag(String key) => row[key] == true;

  final upcast = text('upcast');

  return SpellRecord(
    id: row['id'] is int ? row['id'] as int : int.tryParse('${row['id']}') ?? 0,
    namePt: text('nome'),
    nameOriginal: text('original'),
    level: row['nivel'] is int ? row['nivel'] as int : 0,
    school: text('escola'),
    castingTime: text('tempo'),
    range: text('alcance'),
    components: text('componentes'),
    hasCostlyMaterials: flag('materiaispagos'),
    duration: text('duracao'),
    concentration: flag('concentracao'),
    ritual: flag('ritual'),
    classes: _splitCsv(text('classes')),
    subclasses: _splitCsv(text('subclasses')),
    description: text('descricao'),
    upcast: upcast.isEmpty ? null : upcast,
    source: text('fonte'),
    page: text('pagina'),
    isSrd: flag('srd'),
    edition: edition,
  );
}

List<String> _splitCsv(String raw) {
  if (raw.trim().isEmpty) return const [];
  return raw
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String _backup(List<String> paths) {
  final stamp = DateTime.now()
      .toIso8601String()
      .replaceAll(RegExp(r'[:.]'), '')
      .replaceFirst('T', '-')
      .substring(0, 15);

  final dir = Directory('backup/spells/$stamp')..createSync(recursive: true);

  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    file.copySync('${dir.path}/${file.uri.pathSegments.last}');
  }

  return dir.path;
}

/// Grava as alterações. Devolve os arquivos tocados.
///
/// Magia nova vai toda para um arquivo só, o de destino. Atualização vai para o
/// arquivo onde a magia já está, para não mover registro entre livros nem
/// reescrever os três assets inteiros por causa de um campo.
List<String> _apply({
  required SpellImportPlan plan,
  required Map<String, List<SpellRecord>> existingByFile,
  required String targetPath,
  required String edition,
}) {
  final touched = <String>{};
  final updatedById = {
    for (final decision in plan.updated)
      if (decision.result != null) decision.result!.id: decision.result!,
  };

  // Atualizações, arquivo por arquivo.
  if (updatedById.isNotEmpty) {
    for (final entry in existingByFile.entries) {
      final hits = entry.value.where(
        (item) => updatedById.containsKey(item.id),
      );
      if (hits.isEmpty) continue;

      final file = File(entry.key);
      final decoded =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final rows = List<dynamic>.from(decoded['dados'] as List<dynamic>);

      for (var index = 0; index < rows.length; index++) {
        final row = Map<String, dynamic>.from(rows[index] as Map);
        final id = row['id'];
        final replacement = id is int ? updatedById[id] : null;
        if (replacement == null) continue;
        rows[index] = replacement.toAssetJson();
      }

      decoded['dados'] = rows;
      decoded['quantidade'] = rows.length;
      _writeJsonAtomic(file, decoded);
      touched.add(entry.key);
    }
  }

  // Adições, todas no arquivo de destino.
  final additions = [
    for (final decision in plan.added)
      if (decision.result != null) decision.result!,
  ];

  if (additions.isNotEmpty) {
    final file = File(targetPath);
    final decoded =
        file.existsSync()
            ? jsonDecode(file.readAsStringSync()) as Map<String, dynamic>
            : <String, dynamic>{
              'nome': 'Fontes adicionais',
              'dados': <dynamic>[],
            };

    final rows = List<dynamic>.from(
      decoded['dados'] as List<dynamic>? ?? const [],
    );
    rows.addAll(additions.map((item) => item.toAssetJson()));

    decoded['dados'] = rows;
    decoded['quantidade'] = rows.length;
    _writeJsonAtomic(file, decoded);
    touched.add(targetPath);
  }

  return touched.toList(growable: false);
}

/// Grava num arquivo temporário e troca, para uma falha no meio da escrita não
/// deixar o asset pela metade — um JSON truncado derruba a leitura das magias
/// inteira, não só da magia afetada.
void _writeJsonAtomic(File file, Map<String, dynamic> content) {
  const encoder = JsonEncoder.withIndent('   ');
  final temp = File('${file.path}.tmp');

  temp.writeAsStringSync('${encoder.convert(content)}\n');

  if (file.existsSync()) file.deleteSync();
  temp.renameSync(file.path);
}

/// Confere as invariantes que o app assume ao ler a base.
List<String> _validateBase() {
  final problems = <String>[];
  final owners = <int, String>{};

  for (final path in spellAssetPaths) {
    final file = File(path);
    if (!file.existsSync()) {
      problems.add('asset ausente: $path');
      continue;
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } on FormatException catch (error) {
      problems.add('$path: JSON inválido (${error.message})');
      continue;
    }

    final rows = decoded['dados'] as List<dynamic>? ?? const [];

    if (decoded['quantidade'] != rows.length) {
      problems.add(
        '$path: "quantidade" (${decoded['quantidade']}) diferente '
        'do número de registros (${rows.length})',
      );
    }

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final name = row['nome'] ?? '(sem nome)';

      final id = row['id'];
      if (id is! int) {
        problems.add(
          '$path: "$name" tem id "$id", e a leitura faz cast para '
          'int',
        );
        continue;
      }

      final owner = owners[id];
      if (owner != null) {
        problems.add(
          'id $id repetido: "$owner" e "$name" — o personagem '
          'referencia magia por id',
        );
      } else {
        owners[id] = '$name';
      }

      if (row['pagina'] is! String) {
        problems.add(
          '$path: "$name" tem pagina ${row['pagina']}, e a leitura '
          'faz cast para String',
        );
      }

      final level = row['nivel'];
      if (level is! int || level < 0 || level > 9) {
        problems.add('$path: "$name" tem nivel "$level"');
      }
    }
  }

  return problems;
}

class _Options {
  _Options({
    required this.sourcePath,
    required this.apply,
    required this.targetPath,
    required this.sourceName,
    required this.edition,
    required this.idAliases,
    required this.reportPath,
  });

  final String? sourcePath;
  final bool apply;
  final String targetPath;
  final String? sourceName;
  final String edition;
  final Map<int, int> idAliases;
  final String? reportPath;

  static _Options parse(List<String> args) {
    String? source;
    var apply = false;
    var target = defaultTarget;
    String? sourceName;
    var edition = SpellRecord.defaultEdition;
    final aliases = <int, int>{};
    String? reportPath;

    var index = 0;

    while (index < args.length) {
      final arg = args[index];
      index++;

      String next() {
        if (index >= args.length) {
          throw ArgumentError('Falta o valor de $arg');
        }
        return args[index++];
      }

      switch (arg) {
        case '--apply':
          apply = true;
        case '--out':
          target = next();
        case '--fonte':
          sourceName = next();
        case '--edicao':
          edition = next();
        case '--relatorio':
          reportPath = next();
        case '--mapa-ids':
          for (final pair in next().split(',')) {
            final parts = pair.split('=');
            if (parts.length != 2) continue;
            final from = int.tryParse(parts[0].trim());
            final to = int.tryParse(parts[1].trim());
            if (from != null && to != null) aliases[from] = to;
          }
        default:
          if (!arg.startsWith('--')) source ??= arg;
      }
    }

    return _Options(
      sourcePath: source,
      apply: apply,
      targetPath: target,
      sourceName: sourceName,
      edition: edition,
      idAliases: aliases,
      reportPath: reportPath,
    );
  }
}

const String _usage = '''
Importa magias para a base do DragonSheet.

  dart run tool/import_spells.dart <fonte> [opções]

A fonte pode ser JSON no schema do app (objeto com lista em "dados") ou texto
com uma linha por campo ("Nome: ...", "Nível: ...", "Fonte: ..."), com os
blocos separados por linha vazia ou por uma linha de tracejado.

  --apply              grava. Sem isso, apenas mostra a prévia.
  --out <arquivo>      asset de destino (padrão: $defaultTarget)
  --fonte <texto>      livro assumido para registro sem campo "fonte"
  --edicao <texto>     edição assumida (padrão: 2014)
  --mapa-ids <a=b>     id da fonte = id já usado na base, separados por vírgula
  --relatorio <saida>  grava o relatório num arquivo além da tela
''';
