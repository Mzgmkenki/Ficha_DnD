import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/background_skill_origins.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';

/// Aplica as perícias do antecedente que estiverem faltando num personagem já
/// salvo, e registra a origem quando ela puder ser determinada com segurança.
///
/// Existe por causa das fichas criadas antes de a origem passar a ser gravada:
/// a coluna `skill_proficiency_grants` nasce vazia nelas, e a perícia do
/// antecedente pode nunca ter entrado.
///
/// Roda ao abrir a ficha e grava SÓ quando há mudança, então abrir o mesmo
/// personagem várias vezes não acrescenta nada depois da primeira.
class BackfillBackgroundSkills {
  BackfillBackgroundSkills(this._repository);

  final CharacterRepository _repository;

  /// Devolve `true` quando o personagem foi alterado e gravado.
  Future<bool> call({
    required String characterId,
    required List<BackgroundEntry> backgrounds,
    required List<ClassEntry> classes,
    required List<RaceEntry> races,
  }) async {
    final character = await _repository.findById(characterId);
    if (character == null) return false;

    final backgroundId = character.backgroundId?.trim();
    if (backgroundId == null || backgroundId.isEmpty) return false;

    final isCustom = backgroundId == BackgroundEntry.customId;

    final List<Skill> granted;
    String? backgroundName;

    if (isCustom) {
      granted = character.customBackground.skills;
    } else {
      final entry = _backgroundById(backgrounds, backgroundId);
      // Antecedente salvo que saiu do compêndio: não há o que aplicar, e
      // inventar perícia a partir de um id desconhecido seria pior.
      if (entry == null) return false;
      granted = entry.skills;
      backgroundName = entry.name;
    }

    if (granted.isEmpty) return false;

    final result = BackgroundSkillOrigins.backfill(
      grants: character.skillProficiencyGrants,
      proficiencies: character.skillProficiencies,
      grantedSkills: granted,
      backgroundId: backgroundId,
      backgroundName: backgroundName,
      isCustom: isCustom,
      ambiguousSkills: _ambiguousSkills(character, classes, races),
    );

    if (!result.changed) return false;

    await _repository.update(
      character.copyWith(
        skillProficiencies: result.proficiencies,
        skillProficiencyGrants: result.grants,
        updatedAt: DateTime.now(),
      ),
    );

    return true;
  }

  /// Perícias que a classe ou a raça do personagem também poderiam ter
  /// concedido.
  ///
  /// Uma perícia que já está proficiente e aparece aqui não recebe origem de
  /// antecedente: sem o registro antigo não há como saber de qual das fontes
  /// ela veio, e atribuir ao antecedente seria palpite. A proficiência é
  /// preservada; só o rótulo de origem fica em branco.
  Set<Skill> _ambiguousSkills(
    Character character,
    List<ClassEntry> classes,
    List<RaceEntry> races,
  ) {
    final ids = <String>{};

    for (final classLevel in character.classLevels) {
      final entry = _classById(classes, classLevel.classId);
      if (entry == null) continue;
      ids.addAll(entry.skillOptions);
    }

    final speciesId = character.speciesId;
    if (speciesId != null) {
      final race = _raceById(races, speciesId);
      if (race != null) {
        ids.addAll(race.grantedSkills);
        ids.addAll(race.skillChoice?.options ?? const <String>[]);
      }
    }

    return {
      for (final id in ids)
        if (Skill.fromId(id) case final skill?) skill,
    };
  }

  BackgroundEntry? _backgroundById(List<BackgroundEntry> items, String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  ClassEntry? _classById(List<ClassEntry> items, String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  RaceEntry? _raceById(List<RaceEntry> items, String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
