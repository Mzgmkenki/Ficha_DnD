import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/death_save_service.dart';

/// Resultado da gravação de pontos de vida.
///
/// Existe para a tela poder contar o que mudou além dos números: sair de 0 PV
/// encerra a sequência de testes contra a morte, e apagar os marcadores sem
/// avisar deixaria o jogador achando que perdeu a informação por bug.
class UpdateHitPointsOutcome {
  const UpdateHitPointsOutcome({this.clearedDeathSaves = false});

  final bool clearedDeathSaves;
}

class UpdateCharacterHitPoints {
  UpdateCharacterHitPoints(this._repository);

  final CharacterRepository _repository;

  Future<UpdateHitPointsOutcome> call({
    required String characterId,
    required HitPoints hitPoints,
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    return _save(character, hitPoints);
  }

  /// Aplica dano ao estado mais recente persistido. Pontos temporários são
  /// consumidos primeiro por [HitPoints.applyDamage].
  Future<UpdateHitPointsOutcome> applyDamage({
    required String characterId,
    int amount = 1,
  }) {
    return _transform(
      characterId,
      (hitPoints) => hitPoints.applyDamage(amount),
    );
  }

  /// Cura apenas PV atuais e respeita o máximo por [HitPoints.heal].
  Future<UpdateHitPointsOutcome> heal({
    required String characterId,
    int amount = 1,
  }) {
    return _transform(characterId, (hitPoints) => hitPoints.heal(amount));
  }

  Future<UpdateHitPointsOutcome> _transform(
    String characterId,
    HitPoints Function(HitPoints) transform,
  ) async {
    final character = await _repository.findById(characterId);
    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    return _save(character, transform(character.hitPoints));
  }

  Future<UpdateHitPointsOutcome> _save(
    Character character,
    HitPoints hitPoints,
  ) async {
    // Recuperar qualquer PV encerra a sequência de testes (regra de 5e). A
    // decisão mora no serviço de domínio, e não aqui, porque o descanso longo e
    // o gasto de dado de vida precisam da mesma regra.
    final clearedSaves = DeathSaveService.onHitPointsChanged(
      current: character.deathSaves,
      before: character.hitPoints,
      after: hitPoints,
    );

    final updatedCharacter = character.copyWith(
      hitPoints: hitPoints,
      deathSaves: clearedSaves,
      updatedAt: DateTime.now(),
    );

    await _repository.update(updatedCharacter);

    return UpdateHitPointsOutcome(clearedDeathSaves: clearedSaves != null);
  }
}
