import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_resolver.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/eldritch_invocation_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/eldritch_invocation_catalog.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';

/// Origem usada nas magias que vêm de Invocação Mística.
///
/// Irmã de `subclassSpellSource`, e pelo mesmo motivo: a sincronização só mexe
/// nas magias que ELA colocou no livro, nunca nas de classe, subclasse, item
/// ou grimório. É o que garante que perder uma invocação não apague uma magia
/// que o personagem também conhece por outra fonte.
const String invocationSpellSource = 'invocation';

/// Rótulo da origem, como a ficha mostra.
const String invocationSpellSourceName = 'Invocação Mística';

class SyncInvocationSpellsResult {
  const SyncInvocationSpellsResult({
    required this.added,
    required this.removed,
    required this.unknownSpellNames,
  });

  static const SyncInvocationSpellsResult none = SyncInvocationSpellsResult(
    added: 0,
    removed: 0,
    unknownSpellNames: [],
  );

  final int added;
  final int removed;

  /// Nomes que não existem no compêndio. Indica erro de digitação no catálogo.
  final List<String> unknownSpellNames;

  bool get changed => added > 0 || removed > 0;
}

/// Deixa o livro de magias coerente com as Invocações Místicas do personagem.
///
/// As magias de invocação são sempre conhecidas e sempre disponíveis: a regra
/// não as faz contar no limite de magias conhecidas nem no de preparação, e
/// várias delas são conjuradas à vontade. O que elas custam fica registrado na
/// própria invocação (ver `InvocationSpellGrant.costLabel`) e, quando há
/// limite de usos, no contador de recurso.
///
/// Rodar de novo não duplica nada: a função compara o que DEVERIA existir com
/// o que existe e aplica só a diferença — mesma mecânica de
/// `SyncSubclassSpells`.
///
/// Só mexe em magia de `sourceType == invocationSpellSource`. Uma magia que o
/// personagem também conhece pela classe continua no livro quando a invocação
/// sai, porque aquela linha tem outra origem e esta sincronização não a vê.
class SyncInvocationSpells {
  SyncInvocationSpells(this._repository);

  final CharacterRepository _repository;

  Future<SyncInvocationSpellsResult> call({
    required String characterId,
    required EldritchInvocationCatalog catalog,
    required List<ClassEntry> classes,
    required SpellNameIndex spellIndex,
    List<SubclassEntry> subclasses = const [],
    List<SpellEntry> spells = const [],
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final resolved = EldritchInvocationResolver.resolve(
      character: character,
      catalog: catalog,
      classes: classes,
      subclasses: subclasses,
      spells: spells,
    );

    final unknown = <String>[];

    // O que deveria estar no livro: chave (id da magia + id da invocação),
    // porque duas invocações diferentes poderiam conceder a mesma magia.
    final desired = <String, CharacterSpell>{};

    // Só as VÁLIDAS concedem magia. Invocação que perdeu o pré-requisito
    // continua na ficha, marcada, mas sem aplicar efeito — e a magia dela sai
    // do livro, que é justamente o efeito não aplicado.
    for (final item in resolved.valid) {
      for (final grant in item.entry.spellGrants) {
        final spell = spellIndex.find(grant.spellName);

        if (spell == null) {
          unknown.add(grant.spellName);
          continue;
        }

        desired['${spell.id}|${item.id}'] = CharacterSpell(
          spellId: spell.id,
          sourceType: invocationSpellSource,
          sourceId: item.id,
          sourceName: invocationSpellSourceName,
          isPrepared: true,
          isKnown: true,
          isAlwaysAvailable: true,
          notes: _noteFor(item.name, grant),
        );
      }
    }

    final current = <String, CharacterSpell>{};
    for (final spell in character.spells) {
      if (spell.sourceType != invocationSpellSource) continue;
      current['${spell.spellId}|${spell.sourceId}'] = spell;
    }

    var removed = 0;
    for (final entry in current.entries) {
      if (desired.containsKey(entry.key)) continue;

      // Sai quando a invocação é substituída, quando ela perde o
      // pré-requisito ou quando o catálogo deixa de conceder a magia.
      await _repository.removeCharacterSpell(
        characterId: characterId,
        spellId: entry.value.spellId,
        sourceType: invocationSpellSource,
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

    return SyncInvocationSpellsResult(
      added: added,
      removed: removed,
      unknownSpellNames: unknown,
    );
  }

  /// Observação gravada na magia, dizendo de qual invocação ela veio e o que
  /// custa.
  ///
  /// Vai para a linha da magia porque é ali que o jogador lê na hora de
  /// conjurar: o painel de magias não tem como saber que "à vontade, sem
  /// gastar espaço" vale só para esta linha.
  static String _noteFor(String invocationName, InvocationSpellGrant grant) {
    final parts = <String>['$invocationName: ${grant.costLabel}'];

    if (grant.selfOnly) parts.add('Apenas em você mesmo.');

    final note = grant.note;
    if (note != null) parts.add(note);

    return parts.join(' ');
  }
}
