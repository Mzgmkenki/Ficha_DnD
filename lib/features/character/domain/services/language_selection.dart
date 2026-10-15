import 'package:dnd_ficha_app/features/character/domain/entities/character_language.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_resolver.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_catalog.dart';

/// Uma opção de idioma dentro de uma vaga, já com o veredito.
class LanguageOption {
  const LanguageOption({
    required this.language,
    required this.isSelected,
    this.blockReason,
  });

  final LanguageEntry language;

  /// Se é o idioma que está nesta vaga agora.
  final bool isSelected;

  /// Por que não pode ser escolhido, ou nulo quando pode.
  ///
  /// Texto pronto de propósito: a mesma frase aparece no `subtitle` da lista,
  /// no tooltip e no erro de validação. Duas redações para a mesma regra
  /// confundiriam mais que ajudariam.
  final String? blockReason;

  /// A opção já escolhida continua habilitada, para o jogador poder desmarcar.
  bool get isEnabled => isSelected || blockReason == null;

  /// Categoria e escrita numa linha, para o subtítulo.
  String get details {
    final parts = <String>[
      language.category.label,
      if (language.script case final script?) 'escrita $script',
    ];
    return parts.join(' • ');
  }
}

/// Regras de seleção de idioma.
///
/// Mora no domínio, e não na tela, porque o levantamento exige a validação nas
/// duas camadas: a interface desabilita a opção, e a gravação recusa a mesma
/// coisa. Com a regra num só lugar, as duas não podem divergir.
class LanguageSelection {
  const LanguageSelection._();

  /// As opções que uma vaga oferece, já ordenadas e com motivo de bloqueio.
  ///
  /// [query] filtra por nome, nome original e alias. [includeGated] inclui os
  /// idiomas de cenário e de fonte específica, que ficam fora por padrão
  /// porque o levantamento manda não poluir a lista com eles.
  static List<LanguageOption> optionsFor({
    required LanguageSlot slot,
    required LanguageCatalog catalog,
    required ResolvedLanguages resolved,
    bool includeGated = false,
    String query = '',
  }) {
    final currentId = resolved.filledSlots[slot.id];
    final offered = catalog.offeredFor(slot.grant, includeGated: includeGated);

    final result = <LanguageOption>[];
    for (final language in offered) {
      if (query.trim().isNotEmpty && !language.containsQuery(query)) continue;

      final isSelected = language.id == currentId;
      result.add(
        LanguageOption(
          language: language,
          isSelected: isSelected,
          blockReason: isSelected
              ? null
              : blockReasonFor(
                  language: language,
                  slot: slot,
                  resolved: resolved,
                  includeGated: includeGated,
                ),
        ),
      );
    }

    return List<LanguageOption>.unmodifiable(result);
  }

  /// Por que [language] não pode entrar em [slot], ou nulo quando pode.
  ///
  /// A ordem das checagens é a ordem em que as frases ajudam mais: primeiro o
  /// que o jogador já tem, depois o que a regra não permite.
  static String? blockReasonFor({
    required LanguageEntry language,
    required LanguageSlot slot,
    required ResolvedLanguages resolved,
    bool includeGated = false,
  }) {
    // Já conhecido: o levantamento pede bloqueio explícito tanto para
    // duplicata dentro da seleção quanto para idioma que o personagem já tem.
    final currentInSlot = resolved.filledSlots[slot.id];
    if (language.id != currentInSlot) {
      for (final known in resolved.all) {
        if (known.languageId != language.id) continue;
        return known.isAutomatic
            ? 'Já concedido por ${known.originLabel}'
            : 'Já escolhido em outra vaga';
      }
    }

    // Idioma secreto e de criatura: só por característica que os conceda.
    if (language.availability.requiresExplicitGrant &&
        !slot.grant.options.contains(language.id)) {
      return language.isSecret
          ? 'Idioma secreto: só entra por uma característica que o conceda'
          : 'Só está disponível por concessão específica';
    }

    // Restrição declarada pela vaga.
    if (!slot.grant.admits(language)) {
      return slot.grant.options.isNotEmpty
          ? 'Fora das opções desta origem'
          : 'Esta vaga aceita ${slot.grant.describeRestriction()}';
    }

    // Idioma de cenário ou de fonte específica, com o filtro desligado.
    if (!includeGated &&
        !language.availability.isOfferedByDefault &&
        !slot.grant.options.contains(language.id)) {
      return 'Depende de o cenário ou a fonte estar em uso';
    }

    return null;
  }

  /// O que impede a criação de ser concluída, ou nulo quando nada impede.
  ///
  /// Só pendência de ESCOLHA conta. Idioma automático não gera pendência, e
  /// vaga sem opção disponível também não: travar a criação por falta de dado
  /// no compêndio deixaria o jogador sem saída.
  static String? validationError(ResolvedLanguages resolved) {
    final pending = resolved.pendingSlots;
    if (pending.isEmpty) return null;

    if (pending.length == 1) {
      return 'Falta escolher 1 idioma (${pending.single.sourceLabel}).';
    }

    return 'Faltam escolher ${pending.length} idiomas.';
  }

  /// Aplica a escolha de [languageId] na vaga [slot].
  ///
  /// Devolve a lista de idiomas do personagem já atualizada. Recusa em vez de
  /// gravar quando a regra não permite: é a segunda camada de validação, a que
  /// vale mesmo se a interface deixar passar.
  static List<CharacterLanguage> choose({
    required List<CharacterLanguage> current,
    required LanguageSlot slot,
    required String languageId,
    required LanguageCatalog catalog,
    required ResolvedLanguages resolved,
    bool includeGated = false,
  }) {
    final language = catalog.byId(languageId);
    if (language == null) {
      throw ArgumentError('Idioma desconhecido: $languageId');
    }

    final reason = blockReasonFor(
      language: language,
      slot: slot,
      resolved: resolved,
      includeGated: includeGated,
    );
    if (reason != null) throw ArgumentError(reason);

    // A vaga aceita um idioma só: trocar substitui o que estava nela.
    final next = <CharacterLanguage>[
      for (final item in current)
        if (item.slotId != slot.id) item,
    ];

    next.add(
      CharacterLanguage(
        languageId: language.id,
        kind: LanguageOriginKind.choice,
        slotId: slot.id,
        sourceId: slot.sourceId,
        sourceLabel: slot.sourceLabel,
      ),
    );

    return List<CharacterLanguage>.unmodifiable(next);
  }

  /// Libera a vaga, como o levantamento pede em "uma escolha anterior deve
  /// liberar sua vaga".
  static List<CharacterLanguage> clearSlot({
    required List<CharacterLanguage> current,
    required String slotId,
  }) {
    return List<CharacterLanguage>.unmodifiable([
      for (final item in current)
        if (item.slotId != slotId) item,
    ]);
  }

  /// Remove um idioma manual ou legado pelo id.
  ///
  /// Não serve para automático: enquanto a fonte estiver ativa, o idioma não
  /// sai — e nem está nesta lista, porque automático é derivado.
  static List<CharacterLanguage> removeLanguage({
    required List<CharacterLanguage> current,
    required String languageId,
  }) {
    return List<CharacterLanguage>.unmodifiable([
      for (final item in current)
        if (!(item.languageId == languageId && !item.isChoice)) item,
    ]);
  }

  /// Acrescenta um idioma à mão, sem vaga.
  ///
  /// Existe porque o Mestre concede idioma em mesa e a ficha tem de permitir.
  /// Não inventa vaga nem consome nenhuma.
  static List<CharacterLanguage> addManual({
    required List<CharacterLanguage> current,
    required String languageId,
    required ResolvedLanguages resolved,
  }) {
    if (resolved.knownLanguageIds.contains(languageId)) {
      throw ArgumentError('O personagem já conhece este idioma.');
    }

    return List<CharacterLanguage>.unmodifiable([
      ...current,
      CharacterLanguage(
        languageId: languageId,
        kind: LanguageOriginKind.manual,
        sourceLabel: 'acrescentado à mão',
      ),
    ]);
  }

  /// Tira da lista as escolhas que o resolvedor marcou como sem apoio.
  ///
  /// Chamado na gravação, depois de uma troca de raça, classe ou antecedente.
  /// Separado do resolvedor de propósito: resolver é só ler, e quem decide
  /// apagar é quem grava.
  static List<CharacterLanguage> pruneDropped({
    required List<CharacterLanguage> current,
    required ResolvedLanguages resolved,
  }) {
    if (resolved.droppedSelections.isEmpty) return current;

    // Mantém exatamente os registros que o resolvedor aprovou, por
    // identidade. Filtrar pelos descartados daria o resultado errado quando
    // duas escolhas disputam a mesma vaga: uma sobrevive, e um filtro por id
    // de vaga removeria as duas.
    final kept = <CharacterLanguage>{
      for (final item in resolved.chosen)
        if (item.selection case final selection?) selection,
    };

    return List<CharacterLanguage>.unmodifiable([
      for (final item in current)
        if (kept.contains(item)) item,
    ]);
  }
}
