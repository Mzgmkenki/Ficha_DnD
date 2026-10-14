import 'package:dnd_ficha_app/features/compendium/data/import/spell_record.dart';

/// O que aconteceu com um registro recebido.
enum SpellImportOutcome {
  /// Magia que não existia na base e entra.
  added,

  /// Magia que existia e recebeu campo novo onde a base estava vazia.
  updated,

  /// Magia idêntica à que já está na base. Reimportar cai aqui.
  unchanged,

  /// Já existe na base por outro caminho (mesma magia, outra fonte ou
  /// reimpressão). A base fica como está.
  duplicate,

  /// Existente e recebida discordam num campo preenchido nos dois lados. A
  /// base fica como está e o relatório mostra os dois valores.
  conflict,

  /// Não passou na validação. Não entra e não altera nada.
  rejected,
}

/// Qual chave de identidade casou o registro recebido com o existente.
enum SpellMatchKey {
  /// Id oficial estável, igual nos dois lados.
  officialId,

  /// Id interno obtido pelo mapa de equivalência informado à importação.
  mappedId,

  /// Nome original + edição + fonte.
  originalName,

  /// Nome normalizado + edição + fonte.
  normalizedName,

  /// Apelido conhecido + edição + fonte.
  alias,

  /// Mesmo nome e edição, fonte diferente. Não é a mesma magia por definição,
  /// mas é candidata a reimpressão, então não entra como nova.
  nameAcrossSources,

  /// Nenhuma correspondência.
  none,
}

/// Problema encontrado num registro recebido.
///
/// Guarda os quatro dados que a mensagem precisa ter para ser acionável: qual
/// magia, qual campo, o que veio e por quê não serve. [suggestion] é a correção
/// quando existe uma óbvia.
class SpellImportIssue {
  const SpellImportIssue({
    required this.spellLabel,
    required this.field,
    required this.received,
    required this.reason,
    this.suggestion,
    this.isFatal = true,
  });

  final String spellLabel;
  final String field;
  final String received;
  final String reason;
  final String? suggestion;

  /// Quando falso, o registro entra e o aviso fica no relatório. Usado para
  /// correção automática (página numérica virando texto, por exemplo).
  final bool isFatal;

  @override
  String toString() {
    final fix = suggestion == null ? '' : ' | correção: $suggestion';
    return '$spellLabel | campo: $field | recebido: "$received" | '
        'motivo: $reason$fix';
  }
}

/// Divergência entre o valor da base e o valor recebido, os dois preenchidos.
class SpellFieldConflict {
  const SpellFieldConflict({
    required this.field,
    required this.currentValue,
    required this.incomingValue,
  });

  final String field;
  final String currentValue;
  final String incomingValue;

  @override
  String toString() =>
      '$field: atual "$currentValue" x recebido "$incomingValue"';
}

/// Decisão tomada para um registro recebido.
class SpellImportDecision {
  const SpellImportDecision({
    required this.incoming,
    required this.outcome,
    required this.matchKey,
    this.existing,
    this.result,
    this.conflicts = const [],
    this.issues = const [],
    this.note,
  });

  final SpellRecord incoming;
  final SpellImportOutcome outcome;
  final SpellMatchKey matchKey;

  /// Registro da base que casou, quando houve correspondência.
  final SpellRecord? existing;

  /// Como o registro fica depois da importação. Nulo quando nada é gravado.
  final SpellRecord? result;

  final List<SpellFieldConflict> conflicts;
  final List<SpellImportIssue> issues;

  /// Explicação em uma linha, para o relatório.
  final String? note;

  /// Como a magia é identificada no relatório.
  ///
  /// Um registro rejeitado não tem id nem fonte confiáveis — pode ter sido
  /// rejeitado justamente por isso —, então mostrar "[id 0, (fonte recebida)]"
  /// ao lado do nome só atrapalharia a leitura.
  String get displayLabel =>
      outcome == SpellImportOutcome.rejected ? incoming.namePt : incoming.label;
}

/// Resultado completo de um planejamento de importação.
///
/// É o mesmo objeto no dry-run e na aplicação: o dry-run imprime e para, a
/// aplicação imprime e grava. Assim a prévia não pode divergir do que é feito.
class SpellImportPlan {
  const SpellImportPlan({
    required this.decisions,
    required this.receivedCount,
    required this.sourceLabel,
    required this.targetLabel,
    this.sourceWarnings = const [],
  });

  final List<SpellImportDecision> decisions;

  /// Correções que a leitura da fonte aplicou sozinha, como página numérica
  /// virando texto ou "Patrulheiro" virando "Guardião".
  ///
  /// Chegam aqui separadas das decisões porque acontecem antes de existir
  /// decisão, e precisam aparecer no relatório: o dado gravado não é
  /// exatamente o que a fonte mandou.
  final List<SpellImportIssue> sourceWarnings;

  /// Quantos registros a fonte trouxe, incluindo os que nem viraram registro.
  final int receivedCount;

  final String sourceLabel;
  final String targetLabel;

  List<SpellImportDecision> _of(SpellImportOutcome outcome) => decisions
      .where((item) => item.outcome == outcome)
      .toList(growable: false);

  List<SpellImportDecision> get added => _of(SpellImportOutcome.added);
  List<SpellImportDecision> get updated => _of(SpellImportOutcome.updated);
  List<SpellImportDecision> get unchanged => _of(SpellImportOutcome.unchanged);
  List<SpellImportDecision> get duplicates => _of(SpellImportOutcome.duplicate);
  List<SpellImportDecision> get conflicted => _of(SpellImportOutcome.conflict);
  List<SpellImportDecision> get rejected => _of(SpellImportOutcome.rejected);

  int get validCount =>
      decisions
          .where((item) => item.outcome != SpellImportOutcome.rejected)
          .length;

  /// Avisos que não impediram a entrada do registro.
  List<SpellImportIssue> get warnings => [
    ...sourceWarnings,
    for (final decision in decisions)
      if (decision.outcome != SpellImportOutcome.rejected)
        ...decision.issues.where((issue) => !issue.isFatal),
  ];

  /// Verdadeiro quando aplicar o plano mudaria algum arquivo.
  bool get hasChanges => added.isNotEmpty || updated.isNotEmpty;

  /// Verdadeiro quando há algo que exige decisão humana.
  bool get needsReview => conflicted.isNotEmpty || rejected.isNotEmpty;

  String formatReport() {
    final buffer =
        StringBuffer()
          ..writeln('=' * 72)
          ..writeln('RELATÓRIO DE IMPORTAÇÃO DE MAGIAS')
          ..writeln('=' * 72)
          ..writeln('Fonte processada: $sourceLabel')
          ..writeln('Arquivo de destino: $targetLabel')
          ..writeln('')
          ..writeln('Registros recebidos ........ $receivedCount')
          ..writeln('Registros válidos .......... $validCount')
          ..writeln('Magias adicionadas ......... ${added.length}')
          ..writeln('Magias atualizadas ......... ${updated.length}')
          ..writeln('Magias inalteradas ......... ${unchanged.length}')
          ..writeln('Duplicidades evitadas ...... ${duplicates.length}')
          ..writeln('Conflitos .................. ${conflicted.length}')
          ..writeln('Registros rejeitados ....... ${rejected.length}');

    void section(String title, List<SpellImportDecision> items) {
      if (items.isEmpty) return;
      buffer
        ..writeln('')
        ..writeln('-' * 72)
        ..writeln('$title (${items.length})')
        ..writeln('-' * 72);
      for (final item in items) {
        buffer.writeln('• ${item.displayLabel}');
        if (item.note != null) {
          buffer.writeln('    ${item.note}');
        }
        for (final conflict in item.conflicts) {
          buffer.writeln('    ⚠ $conflict');
        }
        for (final issue in item.issues) {
          buffer.writeln('    ✗ ${issue.field}: ${issue.reason}');
          buffer.writeln('      recebido: "${issue.received}"');
          if (issue.suggestion != null) {
            buffer.writeln('      correção: ${issue.suggestion}');
          }
        }
      }
    }

    section('ADICIONADAS', added);
    section('ATUALIZADAS', updated);
    section('DUPLICIDADES EVITADAS (base mantida)', duplicates);
    section('CONFLITOS (base mantida, exigem decisão)', conflicted);
    section('REJEITADAS (não entraram)', rejected);

    final softWarnings = warnings;
    if (softWarnings.isNotEmpty) {
      buffer
        ..writeln('')
        ..writeln('-' * 72)
        ..writeln('AVISOS E CORREÇÕES APLICADAS (${softWarnings.length})')
        ..writeln('-' * 72);
      for (final issue in softWarnings) {
        buffer.writeln('• $issue');
      }
    }

    if (unchanged.isNotEmpty && added.isEmpty && updated.isEmpty) {
      buffer
        ..writeln('')
        ..writeln('Nada a fazer: a base já contém todos os registros válidos.');
    }

    return buffer.toString();
  }
}
