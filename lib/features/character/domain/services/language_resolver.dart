import 'package:dnd_ficha_app/features/character/domain/entities/character_language.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_grant.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_catalog.dart';

/// Que tipo de fonte concedeu o idioma.
enum LanguageSourceKind {
  race('race', 'raça'),
  subrace('subrace', 'sub-raça'),
  characterClass('class', 'classe'),
  subclass('subclass', 'subclasse'),
  background('background', 'antecedente'),
  feat('feat', 'talento'),
  feature('feature', 'característica');

  const LanguageSourceKind(this.id, this.label);

  final String id;
  final String label;
}

/// Uma fonte e o que ela concede em idiomas.
///
/// É a entrada do resolvedor. Montar esta lista é o único lugar que conhece
/// raça, classe e antecedente; daqui para frente tudo é id e vaga, o que é o
/// que mantém `if (classe == 'druida')` fora das telas.
class LanguageGrantSource {
  const LanguageGrantSource({
    required this.kind,
    required this.sourceId,
    required this.sourceLabel,
    required this.grants,
  });

  final LanguageSourceKind kind;

  /// Id da fonte no compêndio.
  final String sourceId;

  /// Rótulo pronto: `raça Elfo`, `antecedente Acólito`, `talento Linguista`.
  final String sourceLabel;

  final List<LanguageGrant> grants;
}

/// Uma vaga de escolha de idioma.
class LanguageSlot {
  const LanguageSlot({
    required this.id,
    required this.kind,
    required this.sourceId,
    required this.sourceLabel,
    required this.grant,
    required this.ordinal,
  });

  /// Id estável da vaga: `race.elf_phb.choice.0#1`.
  ///
  /// Composto por concessão e posição para duas vagas da mesma concessão
  /// serem distinguíveis. É o que o idioma escolhido grava como origem.
  final String id;

  final LanguageSourceKind kind;
  final String sourceId;
  final String sourceLabel;
  final LanguageGrant grant;

  /// Posição da vaga dentro da concessão, a partir de 1.
  final int ordinal;

  /// Rótulo da vaga para a interface.
  String get label {
    final declared = grant.label;
    if (declared != null) return declared;
    return 'Idioma à escolha';
  }

  /// Descrição da origem e da restrição, numa linha.
  String get description => '$sourceLabel — ${grant.describeRestriction()}';
}

/// Um idioma que o personagem tem, já resolvido contra o catálogo.
class ResolvedLanguage {
  const ResolvedLanguage({
    required this.languageId,
    required this.isAutomatic,
    required this.origins,
    this.entry,
    this.slotId,
    this.kind,
    this.selection,
  });

  final String languageId;

  /// A entrada do catálogo. Nula quando o id não existe mais no compêndio —
  /// o idioma continua listado, como dado legado, em vez de desaparecer.
  final LanguageEntry? entry;

  /// Se foi concedido automaticamente (não gasta vaga, não pode ser removido
  /// enquanto a fonte estiver ativa).
  final bool isAutomatic;

  /// TODAS as origens que concedem este idioma.
  ///
  /// Guardadas em lista porque duas fontes podem conceder o mesmo idioma: a
  /// ficha mostra o idioma UMA vez e as origens ficam aqui, que é exatamente
  /// o que o levantamento pede em "preserve as origens relevantes
  /// internamente".
  final List<String> origins;

  /// Id da vaga, quando foi escolha.
  final String? slotId;

  /// Como o registro foi gravado, quando não é automático.
  final LanguageOriginKind? kind;

  /// O registro gravado que produziu esta linha. Nulo nos automáticos.
  ///
  /// Guardado para a poda ser por identidade, e não por id de vaga: duas
  /// escolhas apontando para a mesma vaga fazem uma sobreviver e a outra cair,
  /// e podar por vaga derrubaria as duas.
  final CharacterLanguage? selection;

  /// Nome a exibir. Cai no id quando o idioma saiu do compêndio.
  String get displayName => entry?.name ?? languageId;

  String get originLabel => origins.join(', ');

  bool get isUnknown => entry == null;
}

/// Tudo o que o app sabe sobre os idiomas de um personagem.
class ResolvedLanguages {
  const ResolvedLanguages({
    required this.automatic,
    required this.chosen,
    required this.slots,
    required this.filledSlots,
    required this.droppedSelections,
  });

  static const ResolvedLanguages empty = ResolvedLanguages(
    automatic: <ResolvedLanguage>[],
    chosen: <ResolvedLanguage>[],
    slots: <LanguageSlot>[],
    filledSlots: <String, String>{},
    droppedSelections: <CharacterLanguage>[],
  );

  /// Concedidos automaticamente, sem repetição.
  final List<ResolvedLanguage> automatic;

  /// Escolhidos, manuais e legados, sem repetição.
  final List<ResolvedLanguage> chosen;

  /// Vagas abertas por todas as fontes.
  final List<LanguageSlot> slots;

  /// Qual idioma ocupa cada vaga, por id de vaga.
  final Map<String, String> filledSlots;

  /// Escolhas gravadas que perderam a vaga de origem ou deixaram de valer.
  ///
  /// Não são apagadas aqui: o resolvedor só relata. Quem grava decide, e a
  /// interface avisa o jogador — "remova somente escolhas que perderam sua
  /// origem" e "informe quais idiomas foram removidos".
  final List<CharacterLanguage> droppedSelections;

  /// Todos os idiomas do personagem, automáticos primeiro.
  List<ResolvedLanguage> get all => [...automatic, ...chosen];

  /// Ids de tudo que o personagem já conhece.
  Set<String> get knownLanguageIds => {
        for (final item in all) item.languageId,
      };

  int get totalSlots => slots.length;

  int get filledCount => filledSlots.length;

  int get pendingCount {
    final pending = totalSlots - filledCount;
    return pending < 0 ? 0 : pending;
  }

  bool get hasPendingChoices => pendingCount > 0;

  /// Vagas ainda vazias, na ordem em que aparecem.
  List<LanguageSlot> get pendingSlots => [
        for (final slot in slots)
          if (!filledSlots.containsKey(slot.id)) slot,
      ];

  /// A vaga de um id, ou nulo.
  LanguageSlot? slotById(String id) {
    for (final slot in slots) {
      if (slot.id == id) return slot;
    }
    return null;
  }

  /// Texto do contador, como o levantamento pede.
  ///
  /// "Idiomas adicionais selecionados: 1 de 2."
  String get progressLabel =>
      'Idiomas adicionais selecionados: $filledCount de $totalSlots.';

  /// Aviso sobre o que saiu, ou nulo quando nada saiu.
  String? get droppedNotice {
    if (droppedSelections.isEmpty) return null;

    final names = droppedSelections.map((item) => item.languageId).toList();
    if (names.length == 1) {
      return 'O idioma escolhido em ${names.single} perdeu a origem e foi '
          'removido.';
    }

    return '${names.length} idiomas escolhidos perderam a origem e foram '
        'removidos.';
  }
}

/// Calcula os idiomas de um personagem a partir das fontes e das escolhas.
///
/// Toda a regra de idioma mora aqui: o que é automático, quantas vagas
/// existem, que restrição cada vaga tem, o que cada idioma deve a qual fonte e
/// qual escolha deixou de valer. A interface consome o resultado e não repete
/// nenhuma dessas decisões.
class LanguageResolver {
  const LanguageResolver._();

  /// Monta o id de uma vaga. Público porque os testes e a gravação precisam
  /// montar o mesmo id sem depender de um resolvedor rodando.
  ///
  /// Inclui a fonte, e não só a concessão, para duas fontes que declarem
  /// concessões com o mesmo id (duas classes com uma característica de mesmo
  /// nome) não colidirem numa única vaga.
  static String slotId({
    required LanguageGrantSource source,
    required LanguageGrant grant,
    required int ordinal,
  }) =>
      '${source.kind.id}.${source.sourceId}.${grant.id}#$ordinal';

  static ResolvedLanguages resolve({
    required LanguageCatalog catalog,
    required List<LanguageGrantSource> sources,
    List<CharacterLanguage> selections = const [],
  }) {
    // --- 1. Automáticos, com as origens acumuladas por idioma.
    final automaticOrigins = <String, List<String>>{};
    final slots = <LanguageSlot>[];

    for (final source in sources) {
      for (final grant in source.grants) {
        for (final id in grant.fixed) {
          // Id que não existe no catálogo é descartado em silêncio: conceder
          // um idioma inexistente colocaria lixo na ficha. O relatório de
          // dado incompleto é problema do teste de asset, não da ficha.
          if (!catalog.contains(id)) continue;
          automaticOrigins.putIfAbsent(id, () => <String>[]);
          if (!automaticOrigins[id]!.contains(source.sourceLabel)) {
            automaticOrigins[id]!.add(source.sourceLabel);
          }
        }

        for (var index = 1; index <= grant.choose; index++) {
          slots.add(
            LanguageSlot(
              id: slotId(source: source, grant: grant, ordinal: index),
              kind: source.kind,
              sourceId: source.sourceId,
              sourceLabel: source.sourceLabel,
              grant: grant,
              ordinal: index,
            ),
          );
        }
      }
    }

    final automatic = <ResolvedLanguage>[
      for (final entry in automaticOrigins.entries)
        ResolvedLanguage(
          languageId: entry.key,
          entry: catalog.byId(entry.key),
          isAutomatic: true,
          origins: List<String>.unmodifiable(entry.value),
        ),
    ];

    // --- 2. Escolhas gravadas, validadas contra as vagas que ainda existem.
    final slotsById = <String, LanguageSlot>{
      for (final slot in slots) slot.id: slot,
    };

    final filledSlots = <String, String>{};
    final chosen = <ResolvedLanguage>[];
    final dropped = <CharacterLanguage>[];
    final taken = <String>{...automaticOrigins.keys};

    for (final selection in selections) {
      final language = catalog.byId(selection.languageId);

      // Idioma automático também concedido por escolha: a escolha é
      // redundante e sai, devolvendo a vaga. É o caso de duas fontes darem o
      // mesmo idioma depois de o jogador já ter escolhido uma delas.
      if (automaticOrigins.containsKey(selection.languageId)) {
        if (selection.needsSlot) {
          dropped.add(selection);
          continue;
        }
      }

      if (selection.needsSlot) {
        final slot = slotsById[selection.slotId];

        // Vaga que não existe mais: trocou a raça, soltou o talento.
        if (slot == null) {
          dropped.add(selection);
          continue;
        }

        // Vaga já ocupada por outra escolha: a primeira vence.
        if (filledSlots.containsKey(slot.id)) {
          dropped.add(selection);
          continue;
        }

        // Idioma desconhecido ou que a vaga não admite mais.
        if (language == null || !slot.grant.admits(language)) {
          dropped.add(selection);
          continue;
        }

        // Já conhecido por outra via: não pode ocupar duas vagas.
        if (taken.contains(language.id)) {
          dropped.add(selection);
          continue;
        }

        filledSlots[slot.id] = language.id;
        taken.add(language.id);
        chosen.add(
          ResolvedLanguage(
            languageId: language.id,
            entry: language,
            isAutomatic: false,
            origins: [slot.sourceLabel],
            slotId: slot.id,
            kind: selection.kind,
            selection: selection,
          ),
        );
        continue;
      }

      // Manual e legado: ficam, mesmo sem vaga e mesmo com id desconhecido.
      // Apagá-los perderia informação que ninguém mais tem.
      if (taken.contains(selection.languageId)) continue;
      taken.add(selection.languageId);
      chosen.add(
        ResolvedLanguage(
          languageId: selection.languageId,
          entry: language,
          isAutomatic: false,
          origins: [
            selection.sourceLabel ?? selection.kind.label,
          ],
          kind: selection.kind,
          selection: selection,
        ),
      );
    }

    automatic.sort(_byName);
    chosen.sort(_byName);

    return ResolvedLanguages(
      automatic: List<ResolvedLanguage>.unmodifiable(automatic),
      chosen: List<ResolvedLanguage>.unmodifiable(chosen),
      slots: List<LanguageSlot>.unmodifiable(slots),
      filledSlots: Map<String, String>.unmodifiable(filledSlots),
      droppedSelections: List<CharacterLanguage>.unmodifiable(dropped),
    );
  }

  static int _byName(ResolvedLanguage a, ResolvedLanguage b) =>
      LanguageEntry.normalizeName(a.displayName)
          .compareTo(LanguageEntry.normalizeName(b.displayName));
}
