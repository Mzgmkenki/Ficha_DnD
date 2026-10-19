import 'package:dnd_ficha_app/core/utils/pt_collation.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/eldritch_invocation_entry.dart';

/// Uma duplicidade encontrada ao montar o catálogo de invocações.
class InvocationDuplicate {
  const InvocationDuplicate({
    required this.keptId,
    required this.discardedId,
    required this.matchedBy,
    required this.matchedValue,
  });

  /// Id que permaneceu. É sempre o primeiro visto.
  final String keptId;

  /// Id da entrada descartada.
  final String discardedId;

  /// Por qual campo a duplicidade foi detectada: `identificador` ou `nome`.
  final String matchedBy;

  final String matchedValue;

  String get description =>
      'A invocação "$discardedId" repete "$keptId" pelo $matchedBy '
      '"$matchedValue".';
}

/// Divergência entre o registro existente e o que veio na importação.
class InvocationConflict {
  const InvocationConflict({
    required this.invocationId,
    required this.field,
    required this.kept,
    required this.incoming,
  });

  final String invocationId;
  final String field;

  /// Valor mantido (o que já existia).
  final String? kept;

  /// Valor que veio na importação e NÃO foi aplicado.
  final String? incoming;

  String get description =>
      'Em "$invocationId", o campo $field já valia "$kept" e a importação '
      'trouxe "$incoming". O valor existente foi mantido.';
}

/// Resultado de reprocessar uma lista de invocações sobre a base atual.
class InvocationImportResult {
  const InvocationImportResult({
    required this.catalog,
    required this.added,
    required this.updated,
    required this.unchanged,
    required this.duplicates,
    required this.conflicts,
  });

  final EldritchInvocationCatalog catalog;

  /// Ids criados por não existirem antes.
  final List<String> added;

  /// Ids que ganharam dado novo em campo que estava vazio.
  final List<String> updated;

  /// Ids que já estavam completos e não mudaram.
  final List<String> unchanged;

  final List<InvocationDuplicate> duplicates;
  final List<InvocationConflict> conflicts;

  bool get changedAnything => added.isNotEmpty || updated.isNotEmpty;

  String get summary =>
      '${added.length} criada(s), ${updated.length} atualizada(s), '
      '${unchanged.length} sem mudança, ${duplicates.length} duplicidade(s), '
      '${conflicts.length} conflito(s).';
}

/// O catálogo de Invocações Místicas, sem duplicatas e pronto para consulta.
///
/// Centraliza as perguntas que a tela de seleção e o validador fazem: "qual
/// invocação é este id?", "quais existem?" e "este id ainda existe?". É aqui,
/// e não em cada tela, que a normalização de nome para busca mora — duas
/// normalizações diferentes é o mesmo que nenhuma.
class EldritchInvocationCatalog {
  /// Não é `const` por causa do cache de ordenação: um campo `late final` não
  /// convive com construtor gerador constante.
  EldritchInvocationCatalog._(this._byId, this.duplicates);

  /// Catálogo vazio, para estado de carregamento e falha de asset.
  factory EldritchInvocationCatalog.empty() => EldritchInvocationCatalog._(
    const <String, EldritchInvocationEntry>{},
    const [],
  );

  /// Monta o catálogo descartando duplicatas.
  ///
  /// A primeira entrada vista vence, e a descartada é registrada em
  /// [duplicates] em vez de desaparecer em silêncio: duplicidade no asset é
  /// defeito de dado, e o relatório precisa dizer qual. É o que torna a
  /// leitura do catálogo idempotente — processar o mesmo arquivo de novo não
  /// pode produzir 108 invocações.
  factory EldritchInvocationCatalog.from(
    Iterable<EldritchInvocationEntry> entries,
  ) {
    final byId = <String, EldritchInvocationEntry>{};
    final seenNames = <String, String>{};
    final duplicates = <InvocationDuplicate>[];

    for (final entry in entries) {
      final existing = byId[entry.id];
      if (existing != null) {
        duplicates.add(
          InvocationDuplicate(
            keptId: existing.id,
            discardedId: entry.id,
            matchedBy: 'identificador',
            matchedValue: entry.id,
          ),
        );
        continue;
      }

      // Colisão por nome: o id é diferente, mas as duas entradas se referem à
      // mesma invocação, e deixar as duas faria a tela mostrar "Rajada
      // Agonizante" duas vezes, cada uma gastando uma vaga.
      String? collidingName;
      String? collidingId;
      for (final candidate in entry.searchableNames) {
        final key = EldritchInvocationEntry.normalizeName(candidate);
        if (key.isEmpty) continue;
        final owner = seenNames[key];
        if (owner != null && owner != entry.id) {
          collidingName = candidate;
          collidingId = owner;
          break;
        }
      }

      if (collidingId != null) {
        duplicates.add(
          InvocationDuplicate(
            keptId: collidingId,
            discardedId: entry.id,
            matchedBy: 'nome',
            matchedValue: collidingName!,
          ),
        );
        continue;
      }

      byId[entry.id] = entry;
      for (final candidate in entry.searchableNames) {
        final key = EldritchInvocationEntry.normalizeName(candidate);
        if (key.isNotEmpty) seenNames.putIfAbsent(key, () => entry.id);
      }
    }

    return EldritchInvocationCatalog._(
      Map<String, EldritchInvocationEntry>.unmodifiable(byId),
      List<InvocationDuplicate>.unmodifiable(duplicates),
    );
  }

  final Map<String, EldritchInvocationEntry> _byId;

  /// Duplicidades descartadas ao montar o catálogo.
  final List<InvocationDuplicate> duplicates;

  /// A lista ordenada, calculada no primeiro acesso e reaproveitada.
  late final List<EldritchInvocationEntry> _sorted = sortedByDisplayName(
    _byId.values,
    name: (item) => item.name,
    id: (item) => item.id,
  );

  bool get isEmpty => _byId.isEmpty;

  int get length => _byId.length;

  /// Todas as invocações, em ordem alfabética do nome exibido.
  ///
  /// Ordena pela colação do projeto, e não por `normalizeName`: aquela
  /// normalização serve para CASAR nome na busca, não para ordenar.
  List<EldritchInvocationEntry> get all => _sorted;

  EldritchInvocationEntry? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    return _byId[id];
  }

  bool contains(String? id) => byId(id) != null;

  /// Converte uma lista de ids em entradas, descartando id desconhecido.
  List<EldritchInvocationEntry> resolveIds(Iterable<String> ids) {
    return [
      for (final id in ids)
        if (byId(id) case final entry?) entry,
    ];
  }

  /// Acha a invocação a partir de texto livre: id, nome ou nome em inglês.
  EldritchInvocationEntry? resolve(String? text) {
    if (text == null) return null;
    final needle = EldritchInvocationEntry.normalizeName(text);
    if (needle.isEmpty) return null;

    final direct = _byId[text.trim()];
    if (direct != null) return direct;

    for (final entry in _byId.values) {
      for (final candidate in entry.searchableNames) {
        if (EldritchInvocationEntry.normalizeName(candidate) == needle) {
          return entry;
        }
      }
    }
    return null;
  }

  /// Filtra por texto digitado na busca, por nome ou nome em inglês.
  ///
  /// Busca por trecho, não por igualdade: digitar "rajada" tem de achar
  /// Rajada Agonizante e Rajada Repelente.
  List<EldritchInvocationEntry> search(String? query) {
    final needle = EldritchInvocationEntry.normalizeName(query ?? '');
    if (needle.isEmpty) return all;

    return [
      for (final entry in all)
        if (entry.searchableNames.any(
          (name) =>
              EldritchInvocationEntry.normalizeName(name).contains(needle),
        ))
          entry,
    ];
  }

  /// Reprocessa [incoming] sobre [existing], sem perder dado.
  ///
  /// Regras, nesta ordem de prioridade:
  /// - id já existente NUNCA é trocado nem removido, porque personagens
  ///   salvos guardam o id;
  /// - campo de texto vazio no existente é preenchido pelo que vem;
  /// - campo preenchido e divergente é MANTIDO, e a divergência vai para
  ///   [InvocationImportResult.conflicts];
  /// - invocação que só existe no destino continua lá.
  ///
  /// Isso dá idempotência de graça: rodar duas vezes, na segunda nada está
  /// vazio e nada divergiu, então nada muda — e o catálogo continua com 54
  /// entradas, não 108.
  static InvocationImportResult import({
    required Iterable<EldritchInvocationEntry> existing,
    required Iterable<EldritchInvocationEntry> incoming,
  }) {
    final base = EldritchInvocationCatalog.from(existing);
    final merged = <String, EldritchInvocationEntry>{
      for (final entry in base.all) entry.id: entry,
    };

    final added = <String>[];
    final updated = <String>[];
    final unchanged = <String>[];
    final conflicts = <InvocationConflict>[];
    final duplicates = <InvocationDuplicate>[...base.duplicates];

    for (final entry in incoming) {
      final current = merged[entry.id];

      if (current == null) {
        // Pode ser invocação nova de verdade, ou a mesma com id diferente. No
        // segundo caso o id existente vence, porque é o que está persistido.
        final sameInvocation = base.resolve(entry.name);
        if (sameInvocation != null) {
          duplicates.add(
            InvocationDuplicate(
              keptId: sameInvocation.id,
              discardedId: entry.id,
              matchedBy: 'nome',
              matchedValue: entry.name,
            ),
          );
          unchanged.add(sameInvocation.id);
          continue;
        }

        merged[entry.id] = entry;
        added.add(entry.id);
        continue;
      }

      final outcome = _mergeEntry(current, entry);
      conflicts.addAll(outcome.conflicts);

      if (outcome.changed) {
        merged[entry.id] = outcome.entry;
        updated.add(entry.id);
      } else {
        unchanged.add(entry.id);
      }
    }

    return InvocationImportResult(
      catalog: EldritchInvocationCatalog.from(merged.values),
      added: List<String>.unmodifiable(added),
      updated: List<String>.unmodifiable(updated),
      unchanged: List<String>.unmodifiable(unchanged),
      duplicates: List<InvocationDuplicate>.unmodifiable(duplicates),
      conflicts: List<InvocationConflict>.unmodifiable(conflicts),
    );
  }

  static _MergeOutcome _mergeEntry(
    EldritchInvocationEntry current,
    EldritchInvocationEntry incoming,
  ) {
    final conflicts = <InvocationConflict>[];
    var changed = false;

    String? pickText(String field, String? mine, String? theirs) {
      if (theirs == null || theirs.isEmpty) return mine;
      if (mine == null || mine.isEmpty) {
        changed = true;
        return theirs;
      }
      if (EldritchInvocationEntry.normalizeName(mine) !=
          EldritchInvocationEntry.normalizeName(theirs)) {
        conflicts.add(
          InvocationConflict(
            invocationId: current.id,
            field: field,
            kept: mine,
            incoming: theirs,
          ),
        );
      }
      return mine;
    }

    final nameOriginal = pickText(
      'nome original',
      current.nameOriginal,
      incoming.nameOriginal,
    );
    final description = pickText(
      'descrição',
      current.description,
      incoming.description,
    );

    // Pré-requisito é REGRA, não texto: divergência é conflito e o existente é
    // mantido, sem exceção. Trocar em silêncio poderia liberar uma invocação
    // de 15º nível para um Bruxo de 2º.
    final mineLevel = current.prerequisites.warlockLevel;
    final theirsLevel = incoming.prerequisites.warlockLevel;
    if (mineLevel != theirsLevel) {
      conflicts.add(
        InvocationConflict(
          invocationId: current.id,
          field: 'nível de Bruxo exigido',
          kept: mineLevel?.toString(),
          incoming: theirsLevel?.toString(),
        ),
      );
    }

    final mineBoon = current.prerequisites.pactBoon;
    final theirsBoon = incoming.prerequisites.pactBoon;
    if (mineBoon != theirsBoon) {
      conflicts.add(
        InvocationConflict(
          invocationId: current.id,
          field: 'Dádiva do Pacto exigida',
          kept: mineBoon?.id,
          incoming: theirsBoon?.id,
        ),
      );
    }

    if (current.source.trim().toLowerCase() !=
        incoming.source.trim().toLowerCase()) {
      conflicts.add(
        InvocationConflict(
          invocationId: current.id,
          field: 'fonte',
          kept: current.source,
          incoming: incoming.source,
        ),
      );
    }

    if (!changed) {
      return _MergeOutcome(
        entry: current,
        changed: false,
        conflicts: conflicts,
      );
    }

    return _MergeOutcome(
      entry: EldritchInvocationEntry(
        id: current.id,
        name: current.name,
        nameOriginal: nameOriginal,
        description: description,
        source: current.source,
        prerequisites: current.prerequisites,
        spellGrants: current.spellGrants,
        action: current.action,
        blast: current.blast,
        pactWeapon: current.pactWeapon,
        skillProficiencies: current.skillProficiencies,
        tags: current.tags,
      ),
      changed: true,
      conflicts: conflicts,
    );
  }
}

class _MergeOutcome {
  const _MergeOutcome({
    required this.entry,
    required this.changed,
    required this.conflicts,
  });

  final EldritchInvocationEntry entry;
  final bool changed;
  final List<InvocationConflict> conflicts;
}
