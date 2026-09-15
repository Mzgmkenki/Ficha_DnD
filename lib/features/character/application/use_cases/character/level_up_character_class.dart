import 'package:dnd_ficha_app/features/character/application/use_cases/character/sync_subclass_spells.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_class_levels.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';

/// Teto de nível de personagem no PHB.
const int maxCharacterLevel = 20;

/// O que a subida de nível produziu, para a ficha dar o retorno certo sem
/// precisar reler o personagem.
class LevelUpOutcome {
  const LevelUpOutcome({
    required this.classId,
    required this.className,
    required this.newLevel,
    required this.totalLevel,
    this.pendingSubclassLabel,
    this.grantsFeat = false,
    this.spellSyncError,
  });

  final String classId;
  final String className;

  /// Nível da classe escolhida depois da subida.
  final int newLevel;

  /// Nível total do personagem depois da subida.
  final int totalLevel;

  /// Como a classe chama a subclasse, quando o novo nível acabou de abrir a
  /// escolha e ela ainda está vazia. Nulo quando não há nada a decidir.
  ///
  /// Subir de nível não escolhe o arquétipo no lugar do jogador, então a ficha
  /// precisa avisar que essa decisão ficou pendente.
  final String? pendingSubclassLabel;

  /// Se o nível alcançado abre escolha de talento (ou incremento de atributo).
  ///
  /// Mesma ideia de [pendingSubclassLabel]: subir de nível não escolhe o
  /// talento pelo jogador, só avisa que a decisão apareceu. Aqui a comparação é
  /// por igualdade e não por "já passou", porque o talento é concedido POR
  /// nível alcançado — quem chega ao 8º ganha um, independente do que fez no 4º.
  final bool grantsFeat;

  /// O nível foi gravado, mas a reconciliação das magias de subclasse falhou.
  ///
  /// Fica aqui em vez de virar exceção porque a subida em si deu certo: perder
  /// o nível por causa das magias seria pior que avisar.
  final Object? spellSyncError;

  bool get needsSubclassChoice => pendingSubclassLabel != null;
}

/// Sobe um nível numa das classes que o personagem já tem.
///
/// É o atalho da ficha. A tela de multiclasse continua sendo o lugar de mexer
/// em várias classes de uma vez, escolher subclasse ou descer de nível; aqui a
/// operação é só "mais um nível nesta classe", com os efeitos que ela arrasta:
/// PV máximo recalculado e magias de subclasse reconciliadas.
class LevelUpCharacterClass {
  LevelUpCharacterClass(
    this._repository,
    this._updateClassLevels,
    this._syncSubclassSpells,
  );

  final CharacterRepository _repository;
  final UpdateCharacterClassLevels _updateClassLevels;
  final SyncSubclassSpells _syncSubclassSpells;

  Future<LevelUpOutcome> call({
    required String characterId,
    required String classId,
    required List<ClassEntry> classes,
    required List<SubclassEntry> subclasses,
    required SpellNameIndex spellIndex,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    if (character.totalLevel >= maxCharacterLevel) {
      throw Exception('O nível total já está em $maxCharacterLevel.');
    }

    final index = character.classLevels.indexWhere(
      (item) => item.classId == classId,
    );

    if (index < 0) {
      throw Exception('O personagem não tem a classe $classId.');
    }

    // Substitui no lugar, sem reordenar: o cálculo de PV trata a primeira
    // classe da lista como a inicial, que é a única a ganhar o dado cheio.
    final updatedLevels = [...character.classLevels];
    final target = updatedLevels[index];
    final newLevel = target.level + 1;

    // Subir nunca limpa a subclasse, então `copyWith` serve aqui. Descer é que
    // exigiria reconstruir a entrada, porque `copyWith` não zera `subclassId`.
    updatedLevels[index] = target.copyWith(level: newLevel);

    final classEntry = _classEntryFor(classes, classId);

    await _updateClassLevels(
      characterId: characterId,
      classLevels: updatedLevels,
      dieSizeForClass: (id) {
        final entry = _classEntryFor(classes, id);
        if (entry == null) return 8;
        return HitPointsCalculator.parseDieSize(entry.hitDie);
      },
    );

    Object? syncError;
    try {
      await _syncSubclassSpells(
        characterId: characterId,
        subclasses: subclasses,
        spellIndex: spellIndex,
      );
    } catch (error) {
      syncError = error;
    }

    return LevelUpOutcome(
      classId: classId,
      className: classEntry?.name ?? classId,
      newLevel: newLevel,
      totalLevel: character.totalLevel + 1,
      pendingSubclassLabel: _pendingSubclassLabel(
        classEntry: classEntry,
        newLevel: newLevel,
        currentSubclassId: target.subclassId,
      ),
      grantsFeat: classEntry?.grantsFeatAt(newLevel) ?? false,
      spellSyncError: syncError,
    );
  }

  /// Rótulo da subclasse quando o novo nível abre a escolha e ela está vazia.
  ///
  /// Só avisa na transição: quem já passou do nível de escolha e segue sem
  /// subclasse veria o mesmo aviso a cada subida, o que viraria ruído.
  String? _pendingSubclassLabel({
    required ClassEntry? classEntry,
    required int newLevel,
    required String? currentSubclassId,
  }) {
    if (classEntry == null) return null;
    if (currentSubclassId != null && currentSubclassId.isNotEmpty) return null;
    if (classEntry.subclassLevel != newLevel) return null;

    return classEntry.subclassLabelOrDefault;
  }

  ClassEntry? _classEntryFor(List<ClassEntry> classes, String classId) {
    for (final item in classes) {
      if (item.id == classId) return item;
    }
    return null;
  }
}
