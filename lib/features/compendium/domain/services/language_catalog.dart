import 'package:dnd_ficha_app/core/utils/pt_collation.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_grant.dart';

/// Uma duplicidade encontrada ao montar o catálogo.
class LanguageDuplicate {
  const LanguageDuplicate({
    required this.keptId,
    required this.discardedId,
    required this.matchedBy,
    required this.matchedValue,
  });

  /// Id que permaneceu. É sempre o primeiro visto.
  final String keptId;

  /// Id da entrada descartada.
  final String discardedId;

  /// Por qual campo a duplicidade foi detectada.
  final String matchedBy;

  /// O valor que coincidiu.
  final String matchedValue;

  String get description =>
      'O idioma "$discardedId" repete "$keptId" pelo $matchedBy '
      '"$matchedValue".';
}

/// Divergência entre o registro existente e o que veio na importação.
class LanguageConflict {
  const LanguageConflict({
    required this.languageId,
    required this.field,
    required this.kept,
    required this.incoming,
  });

  final String languageId;
  final String field;

  /// Valor que foi mantido (o que já existia).
  final String? kept;

  /// Valor que veio na importação e NÃO foi aplicado.
  final String? incoming;

  String get description =>
      'Em "$languageId", o campo $field já valia "$kept" e a importação '
      'trouxe "$incoming". O valor existente foi mantido.';
}

/// Resultado de reprocessar uma lista de idiomas sobre a base atual.
class LanguageImportResult {
  const LanguageImportResult({
    required this.catalog,
    required this.added,
    required this.updated,
    required this.unchanged,
    required this.duplicates,
    required this.conflicts,
  });

  final LanguageCatalog catalog;

  /// Ids criados por não existirem antes.
  final List<String> added;

  /// Ids que ganharam dado novo em campo que estava vazio.
  final List<String> updated;

  /// Ids que já estavam completos e não mudaram.
  final List<String> unchanged;

  final List<LanguageDuplicate> duplicates;
  final List<LanguageConflict> conflicts;

  bool get changedAnything => added.isNotEmpty || updated.isNotEmpty;

  String get summary =>
      '${added.length} criado(s), ${updated.length} atualizado(s), '
      '${unchanged.length} sem mudança, ${duplicates.length} duplicidade(s), '
      '${conflicts.length} conflito(s).';
}

/// O catálogo de idiomas, já sem duplicatas e pronto para consulta.
///
/// Centraliza as três perguntas que a interface e as regras fazem: "qual
/// idioma é este texto?", "quais idiomas esta vaga aceita?" e "este id ainda
/// existe?". Deixar isso espalhado faria cada tela normalizar nome do seu
/// jeito, e duas normalizações diferentes é o mesmo que nenhuma.
class LanguageCatalog {
  /// Não é `const` por causa do cache de ordenação: um campo `late final` não
  /// convive com construtor gerador constante. O catálogo é montado uma vez
  /// por carga do compêndio, então a troca não custa nada.
  LanguageCatalog._(this._byId, this.duplicates);

  /// Catálogo vazio, para estado de carregamento e falha de asset.
  factory LanguageCatalog.empty() =>
      LanguageCatalog._(const <String, LanguageEntry>{}, const []);

  /// Monta o catálogo descartando duplicatas.
  ///
  /// A primeira entrada vista vence, e a descartada é registrada em
  /// [duplicates] em vez de desaparecer em silêncio: duplicidade no asset é
  /// defeito de dado, e o relatório precisa dizer qual.
  factory LanguageCatalog.from(Iterable<LanguageEntry> entries) {
    final byId = <String, LanguageEntry>{};
    final seenNames = <String, String>{};
    final duplicates = <LanguageDuplicate>[];

    for (final entry in entries) {
      final existing = byId[entry.id];
      if (existing != null) {
        duplicates.add(
          LanguageDuplicate(
            keptId: existing.id,
            discardedId: entry.id,
            matchedBy: 'identificador',
            matchedValue: entry.id,
          ),
        );
        continue;
      }

      // Colisão por nome, original ou alias: o id é diferente, mas as duas
      // entradas se referem ao mesmo idioma, e deixar as duas no catálogo
      // faria a lista de escolha mostrar "Élfico" duas vezes.
      String? collidingName;
      String? collidingId;
      for (final candidate in entry.searchableNames) {
        final key = LanguageEntry.normalizeName(candidate);
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
          LanguageDuplicate(
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
        final key = LanguageEntry.normalizeName(candidate);
        if (key.isNotEmpty) seenNames.putIfAbsent(key, () => entry.id);
      }
    }

    return LanguageCatalog._(
      Map<String, LanguageEntry>.unmodifiable(byId),
      List<LanguageDuplicate>.unmodifiable(duplicates),
    );
  }

  final Map<String, LanguageEntry> _byId;

  /// Duplicidades descartadas ao montar o catálogo.
  final List<LanguageDuplicate> duplicates;

  /// A lista ordenada, calculada no primeiro acesso e reaproveitada.
  ///
  /// `all` é lido dentro de `build` no formulário de idiomas; sem o cache, os
  /// 100 e tantos idiomas eram reordenados a cada quadro.
  late final List<LanguageEntry> _sorted = sortedByDisplayName(
    _byId.values,
    name: (item) => item.name,
    id: (item) => item.id,
  );

  bool get isEmpty => _byId.isEmpty;

  int get length => _byId.length;

  /// Todos os idiomas, em ordem alfabética do nome exibido.
  ///
  /// Ordena pela colação do projeto, e não por `normalizeName`: aquela
  /// normalização existe para CASAR nome (ela apaga pontuação e acento para
  /// achar o registro), e usá-la para ordenar jogava fora o desempate estável
  /// por id.
  List<LanguageEntry> get all => _sorted;

  LanguageEntry? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    return _byId[id];
  }

  bool contains(String? id) => byId(id) != null;

  /// Acha o idioma a partir de texto livre.
  ///
  /// É o que converte `"Comum"`, `"ELFICO"` e `"Leonino"` nos ids do
  /// catálogo. Devolve nulo em vez de adivinhar: texto que não é idioma
  /// (`"um idioma à escolha"`) tem de ser tratado por quem chamou, não
  /// virar um registro inventado.
  LanguageEntry? resolve(String? text) {
    if (text == null) return null;
    final needle = LanguageEntry.normalizeName(text);
    if (needle.isEmpty) return null;

    final direct = _byId[text.trim()];
    if (direct != null) return direct;

    for (final entry in _byId.values) {
      if (entry.matchesName(text)) return entry;
    }
    return null;
  }

  /// Converte uma lista de ids em entradas, descartando id desconhecido.
  List<LanguageEntry> resolveIds(Iterable<String> ids) {
    return [
      for (final id in ids)
        if (byId(id) case final entry?) entry,
    ];
  }

  /// Os idiomas que uma vaga pode oferecer.
  ///
  /// Três filtros, nesta ordem:
  /// 1. a restrição declarada pela concessão ([LanguageGrant.admits]);
  /// 2. a disponibilidade do idioma — secreto e de criatura nunca entram em
  ///    escolha livre, mesmo que a categoria passe;
  /// 3. [includeGated], que o jogador liga para ver idiomas de cenário.
  ///
  /// Uma vaga com lista explícita de opções ignora o filtro 3: se a regra
  /// nomeou o idioma, ele está autorizado por aquela regra.
  List<LanguageEntry> offeredFor(
    LanguageGrant grant, {
    bool includeGated = false,
  }) {
    final explicit = grant.options.isNotEmpty;

    final result = <LanguageEntry>[
      for (final entry in all)
        if (grant.admits(entry) &&
            (explicit
                ? !entry.availability.requiresExplicitGrant ||
                    grant.options.contains(entry.id)
                : includeGated
                ? entry.availability.isOfferedWhenGatedShown
                : entry.availability.isOfferedByDefault))
          entry,
    ];

    return List<LanguageEntry>.unmodifiable(result);
  }

  /// Reprocessa [incoming] sobre [existing], sem perder dado.
  ///
  /// Regras, nesta ordem de prioridade:
  /// - id já existente NUNCA é trocado nem removido, porque personagens
  ///   salvos guardam o id;
  /// - campo vazio no existente é preenchido pelo que vem na importação;
  /// - campo preenchido e divergente é MANTIDO, e a divergência vai para
  ///   [LanguageImportResult.conflicts];
  /// - aliases são unidos, nunca substituídos;
  /// - idioma que só existe no destino continua lá.
  ///
  /// Isso dá idempotência de graça: rodar duas vezes, na segunda nada está
  /// vazio e nada divergiu, então nada muda.
  static LanguageImportResult import({
    required Iterable<LanguageEntry> existing,
    required Iterable<LanguageEntry> incoming,
  }) {
    final base = LanguageCatalog.from(existing);
    final merged = <String, LanguageEntry>{
      for (final entry in base.all) entry.id: entry,
    };

    final added = <String>[];
    final updated = <String>[];
    final unchanged = <String>[];
    final conflicts = <LanguageConflict>[];
    final duplicates = <LanguageDuplicate>[...base.duplicates];

    for (final entry in incoming) {
      final current = merged[entry.id];

      if (current == null) {
        // Pode ser idioma novo de verdade, ou o mesmo idioma com id diferente.
        // No segundo caso o id existente vence e o novo nome entra como alias.
        final sameLanguage = base.resolve(entry.name);
        if (sameLanguage != null) {
          duplicates.add(
            LanguageDuplicate(
              keptId: sameLanguage.id,
              discardedId: entry.id,
              matchedBy: 'nome',
              matchedValue: entry.name,
            ),
          );

          final host = merged[sameLanguage.id]!;
          final mergedAliases = _mergeAliases(host, [
            entry.name,
            entry.nameOriginal,
            ...entry.aliases,
          ]);
          if (mergedAliases.length != host.aliases.length) {
            merged[host.id] = _copy(host, aliases: mergedAliases);
            updated.add(host.id);
          } else {
            unchanged.add(host.id);
          }
          continue;
        }

        merged[entry.id] = entry;
        added.add(entry.id);
        continue;
      }

      final result = _mergeEntry(current, entry);
      conflicts.addAll(result.conflicts);

      if (result.changed) {
        merged[entry.id] = result.entry;
        updated.add(entry.id);
      } else {
        unchanged.add(entry.id);
      }
    }

    return LanguageImportResult(
      catalog: LanguageCatalog.from(merged.values),
      added: List<String>.unmodifiable(added),
      updated: List<String>.unmodifiable(updated),
      unchanged: List<String>.unmodifiable(unchanged),
      duplicates: List<LanguageDuplicate>.unmodifiable(duplicates),
      conflicts: List<LanguageConflict>.unmodifiable(conflicts),
    );
  }

  /// Acrescenta aos aliases de [host] os nomes de [candidates] que ele ainda
  /// não reconhece.
  ///
  /// Quem chama escolhe os candidatos, e a escolha importa: ao descartar um
  /// registro duplicado, o nome E o nome original dele têm de virar alias,
  /// senão o texto livre que usava aquele nome deixa de ser reconhecido. Já no
  /// merge de um mesmo id, o nome original é tratado como campo (por
  /// `pickText`) e não deve entrar duas vezes.
  static List<String> _mergeAliases(
    LanguageEntry host,
    Iterable<String?> candidates,
  ) {
    final known = <String>{
      for (final item in host.searchableNames)
        LanguageEntry.normalizeName(item),
    };

    final result = <String>[...host.aliases];
    for (final candidate in candidates) {
      if (candidate == null) continue;
      final key = LanguageEntry.normalizeName(candidate);
      if (key.isEmpty || known.contains(key)) continue;
      known.add(key);
      result.add(candidate);
    }

    return result;
  }

  static _MergeOutcome _mergeEntry(
    LanguageEntry current,
    LanguageEntry incoming,
  ) {
    final conflicts = <LanguageConflict>[];
    var changed = false;

    String? pickText(String field, String? mine, String? theirs) {
      if (theirs == null || theirs.isEmpty) return mine;
      if (mine == null || mine.isEmpty) {
        changed = true;
        return theirs;
      }
      if (LanguageEntry.normalizeName(mine) !=
          LanguageEntry.normalizeName(theirs)) {
        conflicts.add(
          LanguageConflict(
            languageId: current.id,
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
    final script = pickText('escrita', current.script, incoming.script);
    final speakers = pickText('falantes', current.speakers, incoming.speakers);
    final notes = pickText('observações', current.notes, incoming.notes);
    final dialectOf = pickText(
      'dialeto de',
      current.dialectOf,
      incoming.dialectOf,
    );

    // Categoria, disponibilidade, fonte e edição são regra, não texto: valor
    // divergente é conflito e o existente é mantido, sem exceção. Trocar a
    // disponibilidade em silêncio poderia liberar um idioma secreto.
    if (current.category != incoming.category) {
      conflicts.add(
        LanguageConflict(
          languageId: current.id,
          field: 'categoria',
          kept: current.category.id,
          incoming: incoming.category.id,
        ),
      );
    }
    if (current.availability != incoming.availability) {
      conflicts.add(
        LanguageConflict(
          languageId: current.id,
          field: 'disponibilidade',
          kept: current.availability.id,
          incoming: incoming.availability.id,
        ),
      );
    }
    if (current.edition != incoming.edition) {
      conflicts.add(
        LanguageConflict(
          languageId: current.id,
          field: 'edição',
          kept: current.edition,
          incoming: incoming.edition,
        ),
      );
    }

    final aliases = _mergeAliases(current, incoming.aliases);
    if (aliases.length != current.aliases.length) changed = true;

    if (!changed) {
      return _MergeOutcome(
        entry: current,
        changed: false,
        conflicts: conflicts,
      );
    }

    return _MergeOutcome(
      entry: _copy(
        current,
        nameOriginal: nameOriginal,
        script: script,
        speakers: speakers,
        notes: notes,
        dialectOf: dialectOf,
        aliases: aliases,
      ),
      changed: true,
      conflicts: conflicts,
    );
  }

  static LanguageEntry _copy(
    LanguageEntry source, {
    String? nameOriginal,
    String? script,
    String? speakers,
    String? notes,
    String? dialectOf,
    List<String>? aliases,
  }) {
    return LanguageEntry(
      id: source.id,
      name: source.name,
      nameOriginal: nameOriginal ?? source.nameOriginal,
      category: source.category,
      availability: source.availability,
      script: script ?? source.script,
      speakers: speakers ?? source.speakers,
      source: source.source,
      edition: source.edition,
      aliases: aliases ?? source.aliases,
      dialectOf: dialectOf ?? source.dialectOf,
      notes: notes ?? source.notes,
    );
  }
}

class _MergeOutcome {
  const _MergeOutcome({
    required this.entry,
    required this.changed,
    required this.conflicts,
  });

  final LanguageEntry entry;
  final bool changed;
  final List<LanguageConflict> conflicts;
}
