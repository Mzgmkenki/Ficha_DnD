import 'package:dnd_ficha_app/features/character/application/use_cases/character/sync_subclass_spells.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';

/// Grava a subclasse escolhida para uma das classes do personagem.
///
/// Fica num caso de uso porque a escolha arrasta a reconciliação das magias:
/// domínio, juramento e patrono concedem magias, e escolher o arquétipo sem
/// sincronizá-las deixaria o livro de magias incompleto.
class ChooseSubclass {
  ChooseSubclass(this._repository, this._syncSubclassSpells);

  final CharacterRepository _repository;
  final SyncSubclassSpells _syncSubclassSpells;

  /// Define [subclassId] na classe [classId].
  ///
  /// Devolve o erro da sincronização de magias em vez de lançar: a subclasse já
  /// foi gravada, e desfazer a escolha por causa das magias seria pior que
  /// avisar. Nulo quando tudo deu certo.
  Future<Object?> call({
    required String characterId,
    required String classId,
    required String subclassId,
    required List<SubclassEntry> subclasses,
    required SpellNameIndex spellIndex,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final index = character.classLevels.indexWhere(
      (item) => item.classId == classId,
    );

    if (index < 0) {
      throw Exception('O personagem não tem a classe $classId.');
    }

    // A subclasse precisa pertencer à classe: um id de outra classe deixaria a
    // ficha com um arquétipo que nunca libera característica nenhuma.
    final belongs = subclasses.any(
      (item) => item.id == subclassId && item.classId == classId,
    );

    if (!belongs) {
      throw Exception('$subclassId não é uma subclasse de $classId.');
    }

    // Substitui no lugar, sem reordenar: o cálculo de PV trata a primeira
    // classe da lista como a inicial, que é a única a ganhar o dado cheio.
    final updatedLevels = [...character.classLevels];
    updatedLevels[index] = updatedLevels[index].copyWith(
      subclassId: subclassId,
    );

    await _repository.update(
      character.copyWith(
        classLevels: updatedLevels,
        updatedAt: DateTime.now(),
      ),
    );

    try {
      await _syncSubclassSpells(
        characterId: characterId,
        subclasses: subclasses,
        spellIndex: spellIndex,
      );
    } catch (error) {
      return error;
    }

    return null;
  }
}
