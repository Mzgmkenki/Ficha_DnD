import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_language.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_selection.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_catalog.dart';

/// Grava as decisões de idioma do personagem.
///
/// Toda a regra fica em `LanguageSelection`; aqui só se lê o personagem, se
/// aplica o resultado e se grava. É a segunda camada de validação: mesmo que
/// uma tela deixe passar, a gravação recusa.
class ManageCharacterLanguages {
  ManageCharacterLanguages(this._repository);

  final CharacterRepository _repository;

  /// Escolhe [languageId] para a vaga [slotId].
  Future<void> choose({
    required String characterId,
    required String slotId,
    required String languageId,
    required LanguageCatalog catalog,
    required List<LanguageGrantSource> sources,
    bool includeGated = false,
  }) async {
    final character = await _require(characterId);

    final resolved = LanguageResolver.resolve(
      catalog: catalog,
      sources: sources,
      selections: character.languages,
    );

    final slot = resolved.slotById(slotId);
    if (slot == null) {
      throw ArgumentError('A vaga de idioma não existe mais.');
    }

    final next = LanguageSelection.choose(
      current: character.languages,
      slot: slot,
      languageId: languageId,
      catalog: catalog,
      resolved: resolved,
      includeGated: includeGated,
    );

    await _save(character, next);
  }

  /// Libera a vaga, devolvendo a escolha.
  Future<void> clearSlot({
    required String characterId,
    required String slotId,
  }) async {
    final character = await _require(characterId);

    final next = LanguageSelection.clearSlot(
      current: character.languages,
      slotId: slotId,
    );

    await _save(character, next);
  }

  /// Acrescenta um idioma à mão, sem gastar vaga.
  Future<void> addManual({
    required String characterId,
    required String languageId,
    required LanguageCatalog catalog,
    required List<LanguageGrantSource> sources,
  }) async {
    final character = await _require(characterId);

    if (!catalog.contains(languageId)) {
      throw ArgumentError('Idioma desconhecido: $languageId');
    }

    final resolved = LanguageResolver.resolve(
      catalog: catalog,
      sources: sources,
      selections: character.languages,
    );

    final next = LanguageSelection.addManual(
      current: character.languages,
      languageId: languageId,
      resolved: resolved,
    );

    await _save(character, next);
  }

  /// Remove um idioma manual ou legado.
  Future<void> removeManual({
    required String characterId,
    required String languageId,
  }) async {
    final character = await _require(characterId);

    final next = LanguageSelection.removeLanguage(
      current: character.languages,
      languageId: languageId,
    );

    await _save(character, next);
  }

  /// Recalcula as concessões e tira as escolhas que perderam a origem.
  ///
  /// Chamado depois de uma troca de raça, classe, subclasse, antecedente ou
  /// talento. Devolve o que saiu, para a tela poder informar — o levantamento
  /// pede explicitamente que o jogador saiba o que foi removido.
  ///
  /// Idempotente: numa segunda chamada nada mais está sem apoio, nada muda e
  /// nenhuma gravação acontece.
  Future<List<CharacterLanguage>> reconcile({
    required String characterId,
    required LanguageCatalog catalog,
    required List<LanguageGrantSource> sources,
  }) async {
    final character = await _require(characterId);

    final resolved = LanguageResolver.resolve(
      catalog: catalog,
      sources: sources,
      selections: character.languages,
    );

    if (resolved.droppedSelections.isEmpty) return const [];

    final next = LanguageSelection.pruneDropped(
      current: character.languages,
      resolved: resolved,
    );

    await _save(character, next);
    return resolved.droppedSelections;
  }

  Future<void> _save(Character character, List<CharacterLanguage> languages) {
    return _repository.update(
      character.copyWith(languages: languages, updatedAt: DateTime.now()),
    );
  }

  Future<Character> _require(String id) async {
    final character = await _repository.findById(id);
    if (character == null) {
      throw StateError('Personagem $id não encontrado.');
    }
    return character;
  }
}
