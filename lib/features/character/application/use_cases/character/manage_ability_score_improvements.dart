import 'package:dnd_ficha_app/features/character/domain/entities/ability_score_improvement.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_requirements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_skills.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Resultado de registrar, remover ou trocar um incremento.
class AbilityImprovementOutcome {
  const AbilityImprovementOutcome({
    required this.applied,
    this.unequippedArmorNotice,
  });

  /// O que de fato entrou em cada atributo, por nome de [Ability].
  ///
  /// Pode vir vazio mesmo numa operação bem-sucedida: é o que acontece quando
  /// todos os atributos escolhidos já estavam no teto. A vaga de progressão
  /// continua gasta — a decisão foi tomada —, só não rendeu ponto.
  final Map<String, int> applied;

  /// Aviso quando a mudança obrigou a desequipar armadura.
  final String? unequippedArmorNotice;

  bool get changedAnything => applied.isNotEmpty;

  /// Resumo em texto: `Força +2` ou `Constituição +1, Sabedoria +1`.
  String get appliedLabel {
    final parts = [
      for (final ability in Ability.values)
        if (applied[ability.name] case final amount? when amount > 0)
          '${ability.label} +$amount',
    ];

    return parts.isEmpty ? 'nenhum ponto (atributos no máximo)' : parts.join(', ');
  }
}

/// Registra, remove e troca o Incremento no Valor de Atributo.
///
/// Fica num caso de uso, e não na tela, porque uma escolha de incremento mexe
/// em duas partes do agregado ao mesmo tempo — a lista de incrementos e os
/// valores de atributo — e porque a troca por talento tem de desfazer os
/// efeitos do talento anterior na mesma gravação.
///
/// O que este caso de uso NÃO faz: passar pelo `UpdateCharacterAbilityScores`.
/// Aquele caminho é a edição manual e, de propósito, descarta a decomposição
/// de criação (`abilityScoreAllocation`) — o jogador assumiu os números. Um
/// incremento é o contrário: ele é um ganho rastreado, registrado junto com a
/// fonte, e a decomposição precisa continuar valendo.
class ManageAbilityScoreImprovements {
  ManageAbilityScoreImprovements(this._repository);

  final CharacterRepository _repository;

  /// Registra um incremento na vaga de [classId] / [classLevel].
  ///
  /// [maximums] é o teto por atributo, já com as exceções declaradas por
  /// característica (Campeão Primal leva Força e Constituição a 24). Omitido,
  /// vale o 20 da regra.
  Future<AbilityImprovementOutcome> choose({
    required String characterId,
    required String classId,
    required int classLevel,
    required Map<Ability, int> increases,
    Map<Ability, int> maximums = const {},
  }) async {
    final character = await _requireCharacter(characterId);

    _guardSlotIsFree(
      character: character,
      classId: classId,
      classLevel: classLevel,
    );

    final wanted = {
      for (final entry in increases.entries)
        if (entry.value > 0) entry.key.name: entry.value,
    };

    final applied = AbilityScoreImprovements.resolve(
      current: character.abilityScores,
      wanted: wanted,
      maximums: maximums,
    );

    final updated = character.copyWith(
      abilityImprovements: [
        ...character.abilityImprovements,
        AbilityScoreImprovement(
          classId: classId,
          classLevel: classLevel,
          appliedIncreases: applied,
        ),
      ],
      abilityScores: AbilityScoreImprovements.apply(
        character.abilityScores,
        applied,
      ),
      updatedAt: DateTime.now(),
    );

    await _repository.update(updated);

    return AbilityImprovementOutcome(applied: applied);
  }

  /// Remove um incremento, devolvendo exatamente os pontos que ele havia dado.
  ///
  /// Bônus de origem, item e os outros incrementos ficam intactos: o que sai é
  /// só o que está registrado nesta linha.
  Future<AbilityImprovementOutcome> remove({
    required String characterId,
    required int localId,
  }) async {
    final character = await _requireCharacter(characterId);

    final target = character.abilityImprovements
        .where((item) => item.localId == localId)
        .cast<AbilityScoreImprovement?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (target == null) {
      return const AbilityImprovementOutcome(applied: {});
    }

    final reverted = character.copyWith(
      abilityImprovements: character.abilityImprovements
          .where((item) => item.localId != localId)
          .toList(growable: false),
      abilityScores: AbilityScoreImprovements.revoke(
        character.abilityScores,
        target.appliedIncreases,
      ),
      updatedAt: DateTime.now(),
    );

    // Tirar pontos pode DERRUBAR a Força, e com ela o direito de usar a
    // armadura vestida. Mesma regra da remoção de talento, pelo mesmo serviço.
    final armor = ArmorRequirements.apply(reverted);
    await _repository.update(armor.character);

    return AbilityImprovementOutcome(
      applied: target.appliedIncreases,
      unequippedArmorNotice: armor.notice,
    );
  }

  /// Troca um talento já escolhido por um incremento, numa só gravação.
  ///
  /// Faz as duas pontas: desfaz o que o talento havia concedido — as perícias
  /// que ELE passou a dar e o aumento que ELE aplicou — e registra o
  /// incremento na vaga que o talento ocupava. Numa gravação só porque o
  /// estado intermediário ("sem o talento e sem o incremento") teria atributos
  /// errados se a segunda metade falhasse.
  Future<AbilityImprovementOutcome> replaceFeat({
    required String characterId,
    required int featLocalId,
    required String classId,
    required int classLevel,
    required Map<Ability, int> increases,
    Map<Ability, int> maximums = const {},
  }) async {
    final character = await _requireCharacter(characterId);

    final feat = character.feats
        .where((item) => item.localId == featLocalId)
        .cast<CharacterFeat?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (feat == null) {
      throw Exception('Talento não encontrado para substituir.');
    }

    _guardSlotIsFree(
      character: character,
      classId: classId,
      classLevel: classLevel,
    );

    // Primeiro desfaz o talento. O teto do incremento é conferido contra os
    // atributos JÁ sem o talento: um talento que dava +1 de Força liberou um
    // ponto de folga, e o incremento tem direito a usá-lo.
    final withoutFeat = AbilityScoreImprovements.revoke(
      character.abilityScores,
      feat.appliedAbilityIncreases,
    );

    final wanted = {
      for (final entry in increases.entries)
        if (entry.value > 0) entry.key.name: entry.value,
    };

    final applied = AbilityScoreImprovements.resolve(
      current: withoutFeat,
      wanted: wanted,
      maximums: maximums,
    );

    final updated = character.copyWith(
      feats: character.feats
          .where((item) => item.localId != featLocalId)
          .toList(growable: false),
      skillProficiencies: GrantedSkills.revoke(
        character.skillProficiencies,
        feat.grantedSkills,
      ),
      abilityImprovements: [
        ...character.abilityImprovements,
        AbilityScoreImprovement(
          classId: classId,
          classLevel: classLevel,
          appliedIncreases: applied,
        ),
      ],
      abilityScores: AbilityScoreImprovements.apply(withoutFeat, applied),
      updatedAt: DateTime.now(),
    );

    final armor = ArmorRequirements.apply(updated);
    await _repository.update(armor.character);

    return AbilityImprovementOutcome(
      applied: applied,
      unequippedArmorNotice: armor.notice,
    );
  }

  /// Recusa gravar dois incrementos na mesma vaga.
  ///
  /// A tela já não oferece, mas uma ficha importada ou um toque duplo
  /// chegariam aqui — e dois incrementos no mesmo nível dariam quatro pontos
  /// de atributo de graça.
  void _guardSlotIsFree({
    required Character character,
    required String classId,
    required int classLevel,
  }) {
    final taken = character.abilityImprovements.any(
      (item) => item.classId == classId && item.classLevel == classLevel,
    );

    if (!taken) return;

    throw Exception(
      'Este nível já tem um Incremento no Valor de Atributo registrado.',
    );
  }

  Future<Character> _requireCharacter(String characterId) async {
    final character = await _repository.findById(characterId);
    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }
    return character;
  }
}
