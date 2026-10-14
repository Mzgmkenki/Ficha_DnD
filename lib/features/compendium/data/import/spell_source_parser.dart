import 'package:dnd_ficha_app/features/compendium/data/import/spell_import_report.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_normalizer.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_record.dart';

/// Registros lidos de uma fonte, separados entre válidos e recusados.
class SpellParseResult {
  const SpellParseResult({
    required this.records,
    required this.rejected,
    required this.warnings,
    required this.receivedCount,
  });

  final List<SpellRecord> records;

  /// Um item por registro recusado, com os motivos dele.
  final List<List<SpellImportIssue>> rejected;

  /// Problemas corrigidos automaticamente, por registro aceito.
  final List<SpellImportIssue> warnings;

  /// Quantos registros a fonte trouxe, válidos ou não.
  final int receivedCount;
}

/// Lê magias de uma fonte externa e valida campo por campo.
///
/// Trata a fonte só como dado. Texto que pareça instrução dentro de um campo é
/// conteúdo da magia e nada mais — nenhum campo é interpretado como comando, e
/// o único efeito possível de um campo é virar valor no asset ou virar erro.
///
/// Dois formatos são aceitos:
/// - JSON no schema do próprio app (`{"dados": [...]}`) ou lista crua;
/// - texto com rótulos por linha (`Nome: ...`, `Nível: ...`), um bloco por
///   magia, que é como os catálogos de magia costumam vir.
class SpellSourceParser {
  const SpellSourceParser({this.defaultSource, this.defaultEdition});

  /// Fonte usada quando o registro não declara `fonte`.
  final String? defaultSource;

  /// Edição usada quando o registro não declara `edicao`.
  final String? defaultEdition;

  /// Campos de texto que não podem chegar vazios ao asset.
  static const _requiredText = {
    'nome': 'nome em português',
    'escola': 'escola de magia',
    'tempo': 'tempo de conjuração',
    'alcance': 'alcance',
    'componentes': 'componentes',
    'duracao': 'duração',
    'descricao': 'descrição',
    'fonte': 'livro de origem',
  };

  /// Rótulos aceitos para cada campo no formato de texto.
  ///
  /// As chaves são comparadas sem acento e sem caixa, então "NÍVEL", "Nivel" e
  /// "nível" caem no mesmo lugar. Rótulo desconhecido não é ignorado: vira
  /// aviso, para um catálogo com um campo novo não entrar pela metade.
  static const Map<String, List<String>> textLabels = {
    'id': ['id', 'identificador', 'id oficial'],
    'nome': ['nome', 'nome em portugues', 'nome pt', 'nome traduzido'],
    'original': [
      'original',
      'nome original',
      'nome em ingles',
      'nome ingles',
      'name',
    ],
    'nivel': ['nivel', 'circulo', 'level'],
    'escola': ['escola', 'school'],
    'tempo': ['tempo', 'tempo de conjuracao', 'conjuracao', 'casting time'],
    'alcance': ['alcance', 'range', 'alcance area', 'alcance/area'],
    'componentes': ['componentes', 'components'],
    'materiaispagos': [
      'materiaispagos',
      'materiais pagos',
      'material com custo',
      'componente com custo',
    ],
    'duracao': ['duracao', 'duration'],
    'concentracao': ['concentracao', 'concentration'],
    'ritual': ['ritual'],
    'classes': ['classes', 'classe', 'class'],
    'subclasses': ['subclasses', 'subclasse', 'subclass'],
    'descricao': ['descricao', 'description', 'efeito', 'texto'],
    'upcast': [
      'upcast',
      'em niveis superiores',
      'niveis superiores',
      'at higher levels',
    ],
    'fonte': ['fonte', 'livro', 'source'],
    'pagina': ['pagina', 'page', 'pag'],
    'srd': ['srd'],
    'edicao': ['edicao', 'edition'],
    'aliases': ['aliases', 'apelidos', 'nomes alternativos', 'alias'],
  };

  SpellParseResult parseJson(dynamic decoded) {
    final rows = _rowsFromJson(decoded);

    final records = <SpellRecord>[];
    final rejected = <List<SpellImportIssue>>[];
    final warnings = <SpellImportIssue>[];

    for (var index = 0; index < rows.length; index++) {
      final outcome = _buildRecord(rows[index], index);
      if (outcome.record != null) {
        records.add(outcome.record!);
        warnings.addAll(outcome.issues.where((issue) => !issue.isFatal));
      } else {
        rejected.add(outcome.issues);
      }
    }

    return SpellParseResult(
      records: records,
      rejected: rejected,
      warnings: warnings,
      receivedCount: rows.length,
    );
  }

  /// Lê o formato de texto rotulado.
  ///
  /// Um bloco termina quando aparece um rótulo `Nome:`/`ID:` já visto no bloco
  /// atual, ou numa linha separadora. Linha sem rótulo é continuação do último
  /// campo, que é como a descrição vem quebrada em vários parágrafos.
  SpellParseResult parseLabeledText(String text) {
    final all = _splitBlocks(text);

    // Um catálogo tem capa, índice e notas antes das magias. Bloco sem nome,
    // sem id e sem nome original não é registro incompleto, é prosa — tratar
    // como registro geraria dezenas de rejeições falsas e esconderia as de
    // verdade. O que foi deixado de fora entra no relatório como contagem.
    final blocks = all
        .where(
          (block) =>
              block.containsKey('nome') ||
              block.containsKey('id') ||
              block.containsKey('original'),
        )
        .toList(growable: false);

    final records = <SpellRecord>[];
    final rejected = <List<SpellImportIssue>>[];
    final warnings = <SpellImportIssue>[];

    final skipped = all.length - blocks.length;
    if (skipped > 0) {
      warnings.add(
        SpellImportIssue(
          spellLabel: '(fonte)',
          field: '(blocos sem magia)',
          received: '$skipped bloco(s)',
          reason:
              'trecho sem "Nome:", "Original:" nem "ID:", tratado como texto '
              'do documento e não como magia',
          suggestion: 'confira se alguma magia ficou sem a linha de nome',
          isFatal: false,
        ),
      );
    }

    for (var index = 0; index < blocks.length; index++) {
      final outcome = _buildRecord(blocks[index], index);
      if (outcome.record != null) {
        records.add(outcome.record!);
        warnings.addAll(outcome.issues.where((issue) => !issue.isFatal));
      } else {
        rejected.add(outcome.issues);
      }
    }

    return SpellParseResult(
      records: records,
      rejected: rejected,
      warnings: warnings,
      receivedCount: blocks.length,
    );
  }

  List<Map<String, dynamic>> _rowsFromJson(dynamic decoded) {
    if (decoded is List) {
      return [
        for (final row in decoded)
          if (row is Map) Map<String, dynamic>.from(row),
      ];
    }

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      for (final key in const ['dados', 'magias', 'spells', 'data']) {
        final rows = map[key];
        if (rows is List) {
          return [
            for (final row in rows)
              if (row is Map) Map<String, dynamic>.from(row),
          ];
        }
      }
      // Objeto único também é aceito, para facilitar corrigir uma magia só.
      if (map.containsKey('nome') || map.containsKey('id')) {
        return [map];
      }
    }

    return const [];
  }

  List<Map<String, dynamic>> _splitBlocks(String text) {
    final blocks = <Map<String, dynamic>>[];
    var current = <String, dynamic>{};
    String? lastKey;

    void flush() {
      if (current.isNotEmpty) blocks.add(current);
      current = <String, dynamic>{};
      lastKey = null;
    }

    final labelPattern = RegExp(r'^\s*([^:]{1,40}):\s*(.*)$');

    for (final rawLine in text.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trimRight();

      // Linha separadora fecha o bloco.
      if (RegExp(r'^\s*([-=_*]{3,}|#{1,6}\s*$)\s*$').hasMatch(line)) {
        flush();
        continue;
      }

      if (line.trim().isEmpty) {
        lastKey = null;
        continue;
      }

      final match = labelPattern.firstMatch(line);
      final label =
          match == null
              ? null
              : foldAccents(match.group(1)!.trim().toLowerCase());
      final field = label == null ? null : _fieldForLabel(label);

      if (field != null) {
        // Rótulo que já apareceu neste bloco significa magia nova.
        if (current.containsKey(field) &&
            (field == 'nome' || field == 'id' || field == 'original')) {
          flush();
        }
        final value = match!.group(2)!.trim();
        current[field] = value;
        lastKey = field;
        continue;
      }

      if (label != null && match != null && _looksLikeLabel(label)) {
        // Rótulo não reconhecido: registra para o relatório em vez de somar o
        // texto no campo anterior, onde passaria em branco.
        final unknown =
            current['__desconhecidos'] as List<String>? ?? <String>[];
        unknown.add('${match.group(1)!.trim()}: ${match.group(2)!.trim()}');
        current['__desconhecidos'] = unknown;
        lastKey = null;
        continue;
      }

      if (lastKey != null) {
        current[lastKey!] = '${current[lastKey!]}\n${line.trim()}';
      }
    }

    flush();
    return blocks;
  }

  static String? _fieldForLabel(String label) {
    for (final entry in textLabels.entries) {
      if (entry.value.contains(label)) return entry.key;
    }
    return null;
  }

  /// Heurística para separar "Rótulo: valor" de texto que só tem dois pontos.
  static bool _looksLikeLabel(String label) {
    if (label.isEmpty || label.length > 40) return false;
    if (label.contains('.')) return false;
    return RegExp(r'^[a-z0-9 ()/_-]+$').hasMatch(label);
  }

  _RecordOutcome _buildRecord(Map<String, dynamic> row, int index) {
    final issues = <SpellImportIssue>[];

    String textOf(String key) {
      final value = row[key];
      if (value == null) return '';
      return value.toString().trim();
    }

    final namePt = textOf('nome');
    final nameOriginal = textOf('original');
    final sourceText =
        textOf('fonte').isNotEmpty ? textOf('fonte') : (defaultSource ?? '');

    // Rótulo provisório: a validação precisa nomear a magia mesmo quando é o
    // nome que está faltando.
    final label =
        namePt.isNotEmpty
            ? namePt
            : (nameOriginal.isNotEmpty
                ? nameOriginal
                : 'registro #${index + 1}');

    void fatal(
      String field,
      dynamic received,
      String reason, [
      String? suggestion,
    ]) {
      issues.add(
        SpellImportIssue(
          spellLabel: label,
          field: field,
          received: received?.toString() ?? '(ausente)',
          reason: reason,
          suggestion: suggestion,
        ),
      );
    }

    void warn(
      String field,
      dynamic received,
      String reason, [
      String? suggestion,
    ]) {
      issues.add(
        SpellImportIssue(
          spellLabel: label,
          field: field,
          received: received?.toString() ?? '(ausente)',
          reason: reason,
          suggestion: suggestion,
          isFatal: false,
        ),
      );
    }

    final unknownLabels = row['__desconhecidos'] as List<String>? ?? const [];
    for (final unknown in unknownLabels) {
      warn(
        '(rótulo desconhecido)',
        unknown,
        'o importador não conhece este campo e o valor foi ignorado',
        'renomeie o rótulo para um dos aceitos ou remova a linha',
      );
    }

    // --- id -----------------------------------------------------------------
    final rawId = row['id'];
    int? id;
    if (rawId == null || rawId.toString().trim().isEmpty) {
      fatal(
        'id',
        rawId,
        'magia sem id, e o personagem referencia magia por id',
        'informe um id inteiro único e estável para esta magia',
      );
    } else {
      id = rawId is int ? rawId : int.tryParse(rawId.toString().trim());
      if (id == null) {
        fatal(
          'id',
          rawId,
          'id não é um número inteiro',
          'use apenas dígitos, sem prefixo de livro',
        );
      } else if (id <= 0) {
        fatal('id', rawId, 'id precisa ser positivo');
      }
    }

    // --- nível --------------------------------------------------------------
    final rawLevel = row['nivel'];
    final level = parseSpellLevel(rawLevel);
    if (level == null) {
      fatal(
        'nivel',
        rawLevel,
        'nível não reconhecido',
        'use 0 a 9, "Truque" ou "3º círculo"',
      );
    } else if (level < 0 || level > 9) {
      fatal('nivel', rawLevel, 'nível fora da faixa de 0 a 9 de D&D 5e');
    } else if (rawLevel is! int) {
      warn(
        'nivel',
        rawLevel,
        'nível convertido de texto para número',
        '$level',
      );
    }

    // --- página -------------------------------------------------------------
    final rawPage = row['pagina'];
    final page = parseSpellPage(rawPage) ?? '';
    if (rawPage != null && rawPage is! String) {
      warn(
        'pagina',
        rawPage,
        'o asset guarda página como texto e a leitura faz cast direto',
        'convertido para "$page"',
      );
    }

    // --- texto obrigatório --------------------------------------------------
    for (final entry in _requiredText.entries) {
      final value = entry.key == 'fonte' ? sourceText : textOf(entry.key);
      if (value.isEmpty) {
        fatal(entry.key, value, '${entry.value} está vazio');
      }
    }

    // --- resquício de HTML --------------------------------------------------
    for (final key in const [
      'nome',
      'original',
      'escola',
      'tempo',
      'alcance',
      'componentes',
      'duracao',
      'descricao',
      'upcast',
    ]) {
      final value = textOf(key);
      final match = htmlResidue.firstMatch(value);
      if (match != null) {
        fatal(
          key,
          match.group(0),
          'o campo contém HTML, que a ficha mostra '
              'literalmente porque renderiza com Text',
          'remova a tag ou entidade do texto antes de importar',
        );
      }
    }

    // --- classes ------------------------------------------------------------
    final rawClasses = coerceTextList(row['classes']);
    final classes = <String>[];
    for (final item in rawClasses) {
      final canonical = canonicalClassName(item);
      if (canonical == null) {
        fatal(
          'classes',
          item,
          'classe desconhecida, e a leitura do asset descarta classe '
              'desconhecida em silêncio, o que faria a magia sumir do filtro',
          'use uma de: ${canonicalClassNames.values.toSet().join(', ')}',
        );
        continue;
      }
      if (canonical != item.trim()) {
        warn(
          'classes',
          item,
          'grafia ajustada para a que o asset exige',
          canonical,
        );
      }
      classes.add(canonical);
    }

    final subclasses = coerceTextList(row['subclasses']);

    // Só avisa quando a fonte realmente não trouxe classe. Se trouxe e as
    // classes foram recusadas acima, o aviso seria ruído em cima de um erro
    // que já está no relatório.
    if (rawClasses.isEmpty && subclasses.isEmpty) {
      warn(
        'classes',
        row['classes'],
        'magia sem classe e sem subclasse não aparece em nenhum filtro de '
            'classe, só na lista geral',
      );
    }

    // --- booleanos ----------------------------------------------------------
    bool boolOf(String key, {bool fallback = false}) {
      final raw = row[key];
      if (raw == null || raw.toString().trim().isEmpty) return fallback;
      final parsed = parseSpellBool(raw);
      if (parsed == null) {
        warn(
          key,
          raw,
          'valor booleano não reconhecido, assumido $fallback',
          'use Sim/Não ou true/false',
        );
        return fallback;
      }
      return parsed;
    }

    final concentration = boolOf('concentracao');
    final ritual = boolOf('ritual');
    final isSrd = boolOf('srd');
    final components = textOf('componentes');
    final declaredCostly = row['materiaispagos'];
    final hasCostly =
        declaredCostly == null
            ? _inferCostlyMaterials(components)
            : boolOf('materiaispagos');

    final upcast = textOf('upcast');

    if (issues.any((issue) => issue.isFatal)) {
      return _RecordOutcome(null, issues);
    }

    return _RecordOutcome(
      SpellRecord(
        id: id!,
        namePt: namePt,
        nameOriginal: nameOriginal,
        level: level!,
        school: textOf('escola'),
        castingTime: textOf('tempo'),
        range: textOf('alcance'),
        components: components,
        hasCostlyMaterials: hasCostly,
        duration: textOf('duracao'),
        concentration: concentration,
        ritual: ritual,
        classes: classes,
        subclasses: subclasses,
        description: textOf('descricao'),
        upcast: upcast.isEmpty ? null : upcast,
        source: sourceText,
        page: page,
        isSrd: isSrd,
        edition:
            textOf('edicao').isNotEmpty
                ? textOf('edicao')
                : (defaultEdition ?? SpellRecord.defaultEdition),
        aliases: coerceTextList(row['aliases']),
      ),
      issues,
    );
  }

  /// Deduz material com custo quando a fonte não declara o campo.
  ///
  /// Os assets existentes marcam `materiaispagos` quando o componente material
  /// é consumido ou tem preço. A dedução olha o texto do componente, e erra
  /// para o lado de não marcar: só acusa quando há preço explícito.
  static bool _inferCostlyMaterials(String components) {
    final folded = foldAccents(components.toLowerCase());
    return RegExp(
      r'\b\d[\d.,]*\s*(po|pp|pc|pe|pl|gp|sp|cp)\b',
    ).hasMatch(folded);
  }
}

class _RecordOutcome {
  const _RecordOutcome(this.record, this.issues);

  final SpellRecord? record;
  final List<SpellImportIssue> issues;
}
