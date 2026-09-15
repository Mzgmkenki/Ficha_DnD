import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_skills.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';

/// Atualiza os dados de identidade: nome, jogador, antecedente e anotações.
class UpdateCharacterIdentity {
  UpdateCharacterIdentity(this._repository);

  final CharacterRepository _repository;

  /// [grantedSkills] são as perícias do antecedente escolhido. Elas viram
  /// proficiência, mas nada é rebaixado: sem rastrear a origem de cada
  /// proficiência, remover a perícia do antecedente antigo apagaria também o
  /// que veio de classe, raça ou escolha do jogador.
  Future<void> call({
    required String characterId,
    required String name,
    required String notes,
    String? playerName,
    String? backgroundId,
    CustomBackground customBackground = const CustomBackground(),
    List<Skill> grantedSkills = const [],
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    // Trocar para um antecedente do compêndio descarta o antecedente criado
    // pelo jogador, para não deixar dados órfãos no banco.
    final isCustom = backgroundId == BackgroundEntry.customId;
    final effectiveCustomBackground =
        isCustom ? customBackground : const CustomBackground();

    final skills = GrantedSkills.apply(
      character.skillProficiencies,
      grantedSkills,
    );

    final updatedCharacter = character.copyWith(
      name: name,
      playerName: playerName,
      backgroundId: backgroundId,
      customBackground: effectiveCustomBackground,
      notes: notes,
      skillProficiencies: skills,
      updatedAt: DateTime.now(),
    );

    await _repository.update(updatedCharacter);
  }
}
