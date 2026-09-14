import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';

/// Origem usada nas magias que vêm da subclasse.
///
/// Serve para separá-las das que o jogador escolheu: a sincronização só mexe
/// nas suas, nunca nas de classe, item ou grimório.
const String subclassSpellSource = 'subclass';

class SyncSubclassSpellsResult {
  const SyncSubclassSpellsResult({
    required this.added,
    required this.removed,
    required this.unknownSpellNames,
  });

  final int added;
  final int removed;

  /// Nomes que não existem no compêndio. Indica erro de digitação no asset.
  final List<String> unknownSpellNames;

  bool get changed => added > 0 || removed > 0;
}

/// Deixa o livro de magias do personagem coerente com as subclasses dele.
///
/// Magias de domínio, juramento e patrono são sempre preparadas e não contam
/// no limite de preparação, então entram como preparadas, conhecidas e sempre
/// disponíveis. Rodar de novo não duplica nada: a função compara o que deveria
/// existir com o que existe e só aplica a diferença.
class SyncSubclassSpells {
  SyncSubclassSpells(this._repository);

  final CharacterRepository _repository;

  Future<SyncSubclassSpellsResult> call({
    required String characterId,
    required List<SubclassEntry> subclasses,
    required SpellNameIndex spellIndex,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final byId = {for (final item in subclasses) item.id: item};
    final unknown = <String>[];

    // O que deveria estar no livro: chave (id da magia + id da subclasse),
    // porque duas subclasses podem conceder a mesma magia numa multiclasse.
    final desired = <String, CharacterSpell>{};

    for (final classLevel in character.classLevels) {
      final subclassId = classLevel.subclassId;
      if (subclassId == null || subclassId.isEmpty) continue;

      final subclass = byId[subclassId];
      if (subclass == null) continue;

      for (final name in subclass.spellNamesUpTo(classLevel.level)) {
        final spell = spellIndex.find(name);

        if (spell == null) {
          unknown.add(name);
          continue;
        }

        desired['${spell.id}|$subclassId'] = CharacterSpell(
          spellId: spell.id,
          sourceType: subclassSpellSource,
          sourceId: subclassId,
          sourceName: subclass.name,
          isPrepared: true,
          isKnown: true,
          isAlwaysAvailable: true,
        );
      }
    }

    final current = <String, CharacterSpell>{};
    for (final spell in character.spells) {
      if (spell.sourceType != subclassSpellSource) continue;
      current['${spell.spellId}|${spell.sourceId}'] = spell;
    }

    var removed = 0;
    for (final entry in current.entries) {
      if (desired.containsKey(entry.key)) continue;

      // Sai de cena quando a subclasse muda, quando o nível cai abaixo do que
      // libera a magia ou quando o asset deixa de conceder.
      await _repository.removeCharacterSpell(
        characterId: characterId,
        spellId: entry.value.spellId,
        sourceType: subclassSpellSource,
        sourceId: entry.value.sourceId,
      );
      removed++;
    }

    var added = 0;
    for (final entry in desired.entries) {
      if (current.containsKey(entry.key)) continue;

      await _repository.addCharacterSpell(
        characterId: characterId,
        spell: entry.value,
      );
      added++;
    }

    return SyncSubclassSpellsResult(
      added: added,
      removed: removed,
      unknownSpellNames: unknown,
    );
  }
}
