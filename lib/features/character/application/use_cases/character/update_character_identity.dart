import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/background_skill_origins.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/alignment.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';

/// Atualiza os dados de identidade: nome, jogador, antecedente e anotações.
class UpdateCharacterIdentity {
  UpdateCharacterIdentity(this._repository);

  final CharacterRepository _repository;

  /// [grantedSkills] são as perícias do antecedente escolhido, e
  /// [backgroundName] é o nome dele, que entra no rótulo da origem.
  ///
  /// A troca de antecedente é resolvida por origem, não por força bruta: sai o
  /// que o antecedente anterior sustentava sozinho, fica o que classe, raça,
  /// talento ou escolha do jogador também concedem, e o registro de origem é
  /// reescrito para o antecedente novo. Ver [BackgroundSkillOrigins.reapply].
  Future<void> call({
    required String characterId,
    required String name,
    required String notes,
    String? playerName,
    String? backgroundId,
    String? backgroundName,
    CustomBackground customBackground = const CustomBackground(),
    List<Skill> grantedSkills = const [],
    CharacterAlignment? alignment,
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

    final reconciled = BackgroundSkillOrigins.reapply(
      grants: character.skillProficiencyGrants,
      proficiencies: character.skillProficiencies,
      grantedSkills: grantedSkills,
      backgroundId: backgroundId,
      backgroundName: backgroundName,
      isCustom: isCustom,
    );

    final updatedCharacter = character.copyWith(
      name: name,
      playerName: playerName,
      backgroundId: backgroundId,
      customBackground: effectiveCustomBackground,
      notes: notes,
      skillProficiencies: reconciled.proficiencies,
      skillProficiencyGrants: reconciled.grants,
      // Passado sem sentinela: a tela sempre manda o valor atual do campo, e
      // `null` aqui é uma escolha do jogador ("Não definido"), não omissão.
      alignment: alignment,
      updatedAt: DateTime.now(),
    );

    await _repository.update(updatedCharacter);
  }
}
