import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_skills.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';

/// Quantas escolhas de talento o personagem tem e quantas já gastou.
class FeatAllowance {
  const FeatAllowance({required this.granted, required this.taken});

  /// Escolhas que as classes já concederam, somando o multiclasse.
  final int granted;

  /// Talentos já escolhidos.
  final int taken;

  int get remaining {
    final left = granted - taken;
    return left < 0 ? 0 : left;
  }

  bool get hasPending => remaining > 0;
}

/// Adiciona e remove talentos, aplicando o efeito nas perícias.
///
/// Fica num caso de uso, e não na tela, porque a escolha do talento mexe em
/// dois lugares do agregado ao mesmo tempo: a lista de talentos e as
/// proficiências. Deixar isso na tela faria cada ponto de entrada repetir a
/// regra — e a regra tem uma sutileza que é fácil errar (ver [addFeat]).
class ManageCharacterFeats {
  ManageCharacterFeats(this._repository);

  final CharacterRepository _repository;

  /// Escolhas de talento que as classes do personagem já concederam.
  ///
  /// Soma por classe, porque no multiclasse cada classe concede nos níveis
  /// dela: Guerreiro 4 / Mago 4 dá duas escolhas, uma de cada.
  static FeatAllowance allowanceFor(
    Character character,
    List<ClassEntry> classes,
  ) {
    var granted = 0;

    for (final classLevel in character.classLevels) {
      for (final entry in classes) {
        if (entry.id != classLevel.classId) continue;
        granted += entry.featsGrantedUpTo(classLevel.level);
        break;
      }
    }

    return FeatAllowance(granted: granted, taken: character.feats.length);
  }

  /// Registra o talento e marca as perícias que ele concede.
  ///
  /// [chosenSkills] são as perícias que o jogador escolheu dentro das opções do
  /// talento; as fixas vêm do próprio [feat].
  ///
  /// Só as perícias que o personagem ainda NÃO tinha são gravadas em
  /// `grantedSkillIds`. Essa é a sutileza: se o talento concede Furtividade e o
  /// Ladino já era proficiente nela, o talento não pode registrar que concedeu
  /// — senão removê-lo depois tiraria uma proficiência de classe.
  Future<void> addFeat({
    required String characterId,
    required FeatEntry feat,
    List<Skill> chosenSkills = const [],
    String? classId,
    int? level,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    if (!feat.repeatable &&
        character.feats.any((item) => item.featId == feat.id)) {
      throw Exception('${feat.name} já foi escolhido.');
    }

    // Escolha fora das opções do talento é descartada: a tela já filtra, mas
    // um import de ficha poderia trazer qualquer coisa.
    final allowed = feat.skillChoice?.skills ?? const <Skill>[];
    final picks = chosenSkills.where(allowed.contains).toList(growable: false);

    final offered = <Skill>[...feat.skills, ...picks];
    final newlyGranted = GrantedSkills.newlyGranted(
      character.skillProficiencies,
      offered,
    );

    final updated = character.copyWith(
      feats: [
        ...character.feats,
        CharacterFeat(
          featId: feat.id,
          classId: classId,
          level: level,
          chosenSkillIds: picks.map((skill) => skill.id).toList(growable: false),
          grantedSkillIds:
              newlyGranted.map((skill) => skill.id).toList(growable: false),
        ),
      ],
      skillProficiencies: GrantedSkills.apply(
        character.skillProficiencies,
        offered,
      ),
      updatedAt: DateTime.now(),
    );

    await _repository.update(updated);
  }

  /// Remove o talento e devolve só as perícias que ele havia concedido.
  Future<void> removeFeat({
    required String characterId,
    required int localId,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final target = character.feats
        .where((item) => item.localId == localId)
        .cast<CharacterFeat?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (target == null) return;

    final updated = character.copyWith(
      feats: character.feats
          .where((item) => item.localId != localId)
          .toList(growable: false),
      skillProficiencies: GrantedSkills.revoke(
        character.skillProficiencies,
        target.grantedSkills,
      ),
      updatedAt: DateTime.now(),
    );

    await _repository.update(updated);
  }
}
