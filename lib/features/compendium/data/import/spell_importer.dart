import 'package:dnd_ficha_app/features/compendium/data/import/spell_import_report.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_normalizer.dart';
import 'package:dnd_ficha_app/features/compendium/data/import/spell_record.dart';

/// Decide o que fazer com cada magia recebida, sem tocar em arquivo.
///
/// Separar a decisão da gravação é o que permite o dry-run mostrar exatamente o
/// que a aplicação faria: os dois chamam [plan], e só a aplicação grava.
///
/// Três invariantes guiam todas as regras daqui:
///
/// 1. Id é referência de personagem. `CharacterSpell.spellId` é o id numérico
///    da magia, então um id nunca pode mudar de dono. Id igual com magia
///    diferente é conflito, não atualização.
/// 2. Nome igual não é magia igual. A base já tem três pares assim: Invocar
///    Celestial é `Conjure Celestial` no Livro do Jogador e `Summon Celestial`
///    em Tasha. Unir por nome apagaria uma das duas.
/// 3. Em dúvida, a base atual ganha. Nenhum valor existente é sobrescrito em
///    silêncio; divergência vira conflito no relatório.
class SpellImporter {
  const SpellImporter({this.idAliases = const {}});

  /// Equivalência entre id da fonte e id interno já usado pela base.
  ///
  /// Serve para o caso em que a mesma magia entrou antes com outro id: sem
  /// isso, ela seria tratada como magia nova e o personagem que já aponta para
  /// o id antigo ficaria com uma cópia órfã ao lado da nova.
  final Map<int, int> idAliases;

  /// Campos comparados para decidir conflito e atualização.
  ///
  /// `pagina` e `srd` entram porque divergência neles indica fonte de edição
  /// diferente, que é justamente o que não deve ser unido em silêncio.
  static const List<String> comparedFields = [
    'nome',
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
    'descricao',
    'upcast',
    'fonte',
    'pagina',
    'srd',
  ];

  SpellImportPlan plan({
    required List<SpellRecord> existing,
    required List<SpellRecord> incoming,
    required String sourceLabel,
    required String targetLabel,
    List<List<SpellImportIssue>> rejected = const [],
    List<SpellImportIssue> sourceWarnings = const [],
    int? receivedCount,
  }) {
    final byId = <int, SpellRecord>{};
    final byIdentity = <String, SpellRecord>{};
    final byNameAndEdition = <String, List<SpellRecord>>{};

    void indexRecord(SpellRecord record) {
      byId[record.id] = record;

      for (final key in _identityKeys(record)) {
        byIdentity.putIfAbsent(key, () => record);
      }

      for (final name in _allNames(record)) {
        final key = '${normalizeSpellName(name)}|${record.edition}';
        byNameAndEdition.putIfAbsent(key, () => []).add(record);
      }
    }

    for (final record in existing) {
      indexRecord(record);
    }

    final decisions = <SpellImportDecision>[
      for (final issues in rejected)
        SpellImportDecision(
          incoming: _placeholderFor(issues),
          outcome: SpellImportOutcome.rejected,
          matchKey: SpellMatchKey.none,
          issues: issues,
          note: 'reprovado na validação dos dados',
        ),
    ];

    for (final record in incoming) {
      final decision = _decide(record, byId, byIdentity, byNameAndEdition);
      decisions.add(decision);

      // Um registro aceito passa a valer para os seguintes: duas magias iguais
      // dentro do mesmo arquivo de origem não entram as duas.
      final applied = decision.result;
      if (applied != null) {
        indexRecord(applied);
      }
    }

    return SpellImportPlan(
      decisions: decisions,
      receivedCount: receivedCount ?? (incoming.length + rejected.length),
      sourceLabel: sourceLabel,
      targetLabel: targetLabel,
      sourceWarnings: sourceWarnings,
    );
  }

  SpellImportDecision _decide(
    SpellRecord incoming,
    Map<int, SpellRecord> byId,
    Map<String, SpellRecord> byIdentity,
    Map<String, List<SpellRecord>> byNameAndEdition,
  ) {
    // Chave 1: id oficial estável.
    final sameId = byId[incoming.id];
    if (sameId != null) {
      return _compare(incoming, sameId, SpellMatchKey.officialId);
    }

    // Chave 2: id interno mapeado.
    final mappedId = idAliases[incoming.id];
    if (mappedId != null) {
      final mapped = byId[mappedId];
      if (mapped != null) {
        return _compare(
          incoming.copyWith(id: mapped.id),
          mapped,
          SpellMatchKey.mappedId,
        );
      }
    }

    // Chaves 3, 4 e 5: nome original, nome normalizado e apelido, sempre com
    // edição e fonte iguais.
    for (final entry in _identityCandidates(incoming)) {
      final match = byIdentity[entry.key];
      if (match == null) continue;

      final matchKey = _refineMatchKey(match, entry.key, entry.value);

      if (match.id != incoming.id) {
        // Mesma magia com id diferente. Trocar o id quebraria a ficha de quem
        // já tem a magia, então a base manda e o relatório avisa.
        return SpellImportDecision(
          incoming: incoming,
          existing: match,
          outcome: SpellImportOutcome.duplicate,
          matchKey: matchKey,
          note:
              'já existe como "${match.label}" (casou por '
              '${_keyLabel(matchKey)}); id ${incoming.id} da fonte foi '
              'ignorado para não trocar a referência das fichas. Use o mapa '
              'de ids se quiser uni-los.',
        );
      }

      return _compare(incoming, match, matchKey);
    }

    // Último filtro: mesmo nome e edição, fonte diferente.
    //
    // Duas coisas muito diferentes caem aqui. Reimpressão é a mesma magia
    // publicada em dois livros, e aí importar criaria uma segunda cópia que o
    // jogador veria duas vezes na busca. Homônimo é tradução repetida para
    // magias distintas, que a base já tem três vezes (Invocar Celestial é
    // `Conjure Celestial` no Livro do Jogador e `Summon Celestial` em Tasha).
    //
    // O nome em inglês é o que separa os dois casos: ele identifica a magia, o
    // português é só rótulo. Com nomes originais diferentes a magia entra, com
    // um aviso de que a busca vai mostrar dois resultados com o mesmo nome.
    for (final name in _allNames(incoming)) {
      final key = '${normalizeSpellName(name)}|${incoming.edition}';
      final candidates = byNameAndEdition[key] ?? const <SpellRecord>[];

      for (final candidate in candidates) {
        if (candidate.source == incoming.source) continue;

        final bothHaveOriginal =
            incoming.nameOriginal.trim().isNotEmpty &&
            candidate.nameOriginal.trim().isNotEmpty;
        final sameOriginal =
            bothHaveOriginal &&
            normalizeSpellName(incoming.nameOriginal) ==
                normalizeSpellName(candidate.nameOriginal);

        if (sameOriginal) {
          return SpellImportDecision(
            incoming: incoming,
            existing: candidate,
            outcome: SpellImportOutcome.duplicate,
            matchKey: SpellMatchKey.nameAcrossSources,
            note:
                'reimpressão: "${incoming.nameOriginal}" já está na base '
                'por "${candidate.source}" (id ${candidate.id}, pág. '
                '${candidate.page}). A base foi mantida e nada foi duplicado.',
          );
        }

        if (!bothHaveOriginal) {
          // Sem o nome em inglês dos dois lados não há como afirmar que são
          // magias diferentes, e errar aqui significa duplicar uma magia que o
          // jogador já tem. A base fica como está.
          return SpellImportDecision(
            incoming: incoming,
            existing: candidate,
            outcome: SpellImportOutcome.duplicate,
            matchKey: SpellMatchKey.nameAcrossSources,
            note:
                'nome "${candidate.namePt}" já existe em '
                '"${candidate.source}" (id ${candidate.id}) e falta o nome em '
                'inglês de um dos lados para decidir se é a mesma magia. '
                'Nada entrou; preencha "original" nos dois e reimporte.',
          );
        }

        return SpellImportDecision(
          incoming: incoming,
          outcome: SpellImportOutcome.added,
          matchKey: SpellMatchKey.none,
          result: incoming,
          issues: [
            SpellImportIssue(
              spellLabel: incoming.label,
              field: 'nome',
              received: incoming.namePt,
              reason:
                  'outra magia já usa este nome em português: '
                  '"${candidate.nameOriginal}" de "${candidate.source}" '
                  '(id ${candidate.id}). São magias diferentes, então as duas '
                  'ficam na base, mas a busca por nome vai listar as duas',
              suggestion: 'nada a corrigir se a tradução estiver certa',
              isFatal: false,
            ),
          ],
          note:
              'magia nova, com nome em português homônimo de '
              '"${candidate.nameOriginal}" (${candidate.source})',
        );
      }
    }

    return SpellImportDecision(
      incoming: incoming,
      outcome: SpellImportOutcome.added,
      matchKey: SpellMatchKey.none,
      result: incoming,
      note: 'magia nova',
    );
  }

  /// Compara campo a campo uma recebida com a existente correspondente.
  SpellImportDecision _compare(
    SpellRecord incoming,
    SpellRecord existing,
    SpellMatchKey matchKey,
  ) {
    final current = existing.toAssetJson();
    final received = incoming.toAssetJson();

    final conflicts = <SpellFieldConflict>[];
    final filled = <String, dynamic>{};

    for (final field in comparedFields) {
      final currentValue = current[field];
      final incomingValue = received[field];

      if (currentValue is bool || incomingValue is bool) {
        if (currentValue != incomingValue) {
          conflicts.add(
            SpellFieldConflict(
              field: field,
              currentValue: '$currentValue',
              incomingValue: '$incomingValue',
            ),
          );
        }
        continue;
      }

      final currentText = currentValue?.toString() ?? '';
      final incomingText = incomingValue?.toString() ?? '';

      if (incomingText.trim().isEmpty) {
        // Campo vazio na fonte nunca apaga o que a base tem.
        continue;
      }

      if (currentText.trim().isEmpty) {
        filled[field] = incomingValue;
        continue;
      }

      if (_sameText(field, currentText, incomingText)) continue;

      conflicts.add(
        SpellFieldConflict(
          field: field,
          currentValue: currentText,
          incomingValue: incomingText,
        ),
      );
    }

    final mergedClasses = mergeTextLists(existing.classes, incoming.classes);
    final mergedSubclasses = mergeTextLists(
      existing.subclasses,
      incoming.subclasses,
    );
    final mergedAliases = mergeTextLists(existing.aliases, incoming.aliases);

    final listsChanged =
        mergedClasses.length != existing.classes.length ||
        mergedSubclasses.length != existing.subclasses.length ||
        mergedAliases.length != existing.aliases.length;

    if (conflicts.isNotEmpty) {
      return SpellImportDecision(
        incoming: incoming,
        existing: existing,
        outcome: SpellImportOutcome.conflict,
        matchKey: matchKey,
        conflicts: conflicts,
        note:
            'casou por ${_keyLabel(matchKey)} com "${existing.label}". '
            'O registro atual foi mantido; nenhum campo foi sobrescrito.',
      );
    }

    if (filled.isEmpty && !listsChanged) {
      return SpellImportDecision(
        incoming: incoming,
        existing: existing,
        outcome: SpellImportOutcome.unchanged,
        matchKey: matchKey,
        result: existing,
        note:
            'idêntica à que já está na base (casou por '
            '${_keyLabel(matchKey)})',
      );
    }

    final merged = _applyFilled(
      existing,
      filled,
      classes: mergedClasses,
      subclasses: mergedSubclasses,
      aliases: mergedAliases,
    );

    final changed = <String>[
      ...filled.keys,
      if (mergedClasses.length != existing.classes.length) 'classes',
      if (mergedSubclasses.length != existing.subclasses.length) 'subclasses',
      if (mergedAliases.length != existing.aliases.length) 'aliases',
    ];

    return SpellImportDecision(
      incoming: incoming,
      existing: existing,
      outcome: SpellImportOutcome.updated,
      matchKey: matchKey,
      result: merged,
      note: 'completou campo que estava vazio na base: ${changed.join(', ')}',
    );
  }

  SpellRecord _applyFilled(
    SpellRecord existing,
    Map<String, dynamic> filled, {
    required List<String> classes,
    required List<String> subclasses,
    required List<String> aliases,
  }) {
    String? text(String field) =>
        filled.containsKey(field) ? (filled[field]?.toString() ?? '') : null;

    final level =
        filled.containsKey('nivel') ? int.tryParse('${filled['nivel']}') : null;

    return existing.copyWith(
      namePt: text('nome'),
      nameOriginal: text('original'),
      level: level,
      school: text('escola'),
      castingTime: text('tempo'),
      range: text('alcance'),
      components: text('componentes'),
      duration: text('duracao'),
      description: text('descricao'),
      upcast: text('upcast'),
      source: text('fonte'),
      page: text('pagina'),
      classes: classes,
      subclasses: subclasses,
      aliases: aliases,
    );
  }

  /// Compara dois valores do mesmo campo.
  ///
  /// Nome, escola e fonte toleram diferença de acento, caixa e pontuação,
  /// porque isso não muda a magia. Nos dois campos de nome o possessivo do
  /// autor também é tolerado: "Flecha Ácida" e "Flecha Ácida de Melf" são a
  /// mesma magia, e acusar conflito aí só geraria ruído no relatório.
  ///
  /// Descrição, número e página exigem igualdade literal, porque aí a diferença
  /// é de conteúdo e precisa de decisão humana.
  static bool _sameText(String field, String current, String incoming) {
    const lenient = {'nome', 'original', 'escola', 'fonte'};
    if (!lenient.contains(field)) {
      return current.trim() == incoming.trim();
    }

    final currentName = normalizeSpellName(current);
    final incomingName = normalizeSpellName(incoming);
    if (currentName == incomingName) return true;

    if (field != 'nome' && field != 'original') return false;

    return normalizeSpellName(withoutAuthor(current)) == incomingName ||
        currentName == normalizeSpellName(withoutAuthor(incoming)) ||
        normalizeSpellName(withoutAuthor(current)) ==
            normalizeSpellName(withoutAuthor(incoming));
  }

  /// Chaves de identidade de um registro, na ordem de prioridade 3, 4 e 5.
  List<String> _identityKeys(SpellRecord record) {
    return [for (final entry in _identityCandidates(record)) entry.key];
  }

  /// Nome original, nome normalizado e apelidos, sempre presos a edição e
  /// fonte. A fonte entra na chave de propósito: sem ela, "Invocar Celestial"
  /// do Livro do Jogador casaria com a de Tasha, que é outra magia.
  ///
  /// Os três tipos de nome vão para o mesmo espaço de chaves, sem prefixo de
  /// campo. É o que permite o apelido de um lado casar com o nome do outro — a
  /// mesma escolha que o `SpellNameIndex` do app faz ao registrar nome
  /// português e nome original no mesmo mapa.
  List<MapEntry<String, SpellMatchKey>> _identityCandidates(
    SpellRecord record,
  ) {
    final scope = '${record.edition}|${normalizeSpellName(record.source)}';
    final candidates = <MapEntry<String, SpellMatchKey>>[];
    final seen = <String>{};

    void add(String name, SpellMatchKey key) {
      if (name.trim().isEmpty) return;
      final candidate = '${normalizeSpellName(name)}|$scope';
      if (!seen.add(candidate)) return;
      candidates.add(MapEntry(candidate, key));
    }

    add(record.nameOriginal, SpellMatchKey.originalName);
    add(record.namePt, SpellMatchKey.normalizedName);
    add(withoutAuthor(record.namePt), SpellMatchKey.normalizedName);
    add(withoutAuthor(record.nameOriginal), SpellMatchKey.originalName);

    for (final alias in record.aliases) {
      add(alias, SpellMatchKey.alias);
      add(withoutAuthor(alias), SpellMatchKey.alias);
    }

    return candidates;
  }

  /// Ajusta o rótulo da correspondência olhando por qual campo do registro da
  /// base ela entrou.
  ///
  /// Sem isso, uma magia que casou com o apelido de um registro existente
  /// apareceria no relatório como "nome normalizado", escondendo justamente a
  /// informação de que foi o apelido que salvou a importação de duplicar.
  SpellMatchKey _refineMatchKey(
    SpellRecord match,
    String key,
    SpellMatchKey fallback,
  ) {
    final name = key.split('|').first;

    if (match.nameOriginal.trim().isNotEmpty &&
        normalizeSpellName(match.nameOriginal) == name) {
      return SpellMatchKey.originalName;
    }

    if (match.namePt.trim().isNotEmpty &&
        normalizeSpellName(match.namePt) == name) {
      return SpellMatchKey.normalizedName;
    }

    for (final alias in match.aliases) {
      if (normalizeSpellName(alias) == name ||
          normalizeSpellName(withoutAuthor(alias)) == name) {
        return SpellMatchKey.alias;
      }
    }

    return fallback;
  }

  Iterable<String> _allNames(SpellRecord record) => [
    record.namePt,
    record.nameOriginal,
    ...record.aliases,
  ].where((name) => name.trim().isNotEmpty);

  static String _keyLabel(SpellMatchKey key) {
    switch (key) {
      case SpellMatchKey.officialId:
        return 'id oficial';
      case SpellMatchKey.mappedId:
        return 'id interno mapeado';
      case SpellMatchKey.originalName:
        return 'nome original + edição + fonte';
      case SpellMatchKey.normalizedName:
        return 'nome normalizado + edição + fonte';
      case SpellMatchKey.alias:
        return 'apelido + edição + fonte';
      case SpellMatchKey.nameAcrossSources:
        return 'nome igual em outra fonte';
      case SpellMatchKey.none:
        return 'nenhuma correspondência';
    }
  }

  /// Registro de fachada para um recusado, que nem chegou a virar magia.
  static SpellRecord _placeholderFor(List<SpellImportIssue> issues) {
    final label =
        issues.isEmpty ? '(registro inválido)' : issues.first.spellLabel;

    return SpellRecord(
      id: 0,
      namePt: label,
      nameOriginal: '',
      level: 0,
      school: '',
      castingTime: '',
      range: '',
      components: '',
      hasCostlyMaterials: false,
      duration: '',
      concentration: false,
      ritual: false,
      classes: const [],
      subclasses: const [],
      description: '',
      upcast: null,
      source: '(fonte recebida)',
      page: '',
      isSrd: false,
    );
  }
}
