import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/death_save_service.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_resources.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';

/// Cargas a gravar num item mágico depois do descanso.
///
/// Itens ficam em tabela própria, então o `update` do personagem não os
/// alcança: o repositório precisa gravar cada um à parte.
class MagicItemRecharge {
  const MagicItemRecharge({
    required this.magicItemId,
    required this.charges,
  });

  final int magicItemId;
  final int charges;
}

/// Resultado de um descanso, pronto para ser persistido.
class RestOutcome {
  const RestOutcome({
    required this.character,
    required this.clearedSpellSlotLevels,
    required this.summary,
    this.magicItemRecharges = const [],
  });

  /// Personagem já com PV, exaustão e dados de vida atualizados.
  final Character character;

  /// Níveis de slot cujo uso deve ser zerado no banco.
  /// Vazio significa "nenhum"; `null` significa "todos".
  final List<int>? clearedSpellSlotLevels;

  /// Itens mágicos que voltam a ficar cheios.
  final List<MagicItemRecharge> magicItemRecharges;

  /// Texto curto para mostrar ao usuário.
  final String summary;
}

/// Aplica as regras de descanso de D&D 5e.
class RestService {
  const RestService._();

  /// Descanso longo (PHB):
  /// - recupera todos os PV;
  /// - recupera metade dos dados de vida totais (mínimo 1);
  /// - recupera todos os espaços de magia (incluindo os de pacto);
  /// - recarrega as cargas dos itens mágicos (ver [rechargesOnLongRest]);
  /// - reduz a exaustão em 1 nível;
  /// - PV temporários não sobrevivem ao descanso.
  /// [restoredFeatureIds] são as características cujos usos voltam neste
  /// descanso. A lista vem pronta de fora, por `FeatureResources`, para este
  /// serviço continuar sem depender do compêndio: quem sabe quais
  /// características o personagem tem é a camada que as carregou.
  static RestOutcome longRest({
    required Character character,
    required int totalHitDice,
    Set<String> restoredFeatureIds = const {},
  }) {
    final recovered =
        HitPointsCalculator.hitDiceRecoveredOnLongRest(totalHitDice);
    final remainingUsed = (character.hitDiceUsed - recovered).clamp(0, totalHitDice);

    final restoredHitPoints = character.hitPoints.copyWith(
      current: character.hitPoints.maximum,
      temporary: 0,
    );

    // Voltar a ter PV encerra a sequência de testes contra a morte. Quem estava
    // morrendo e descansou não continua com falhas penduradas.
    final clearedSaves = DeathSaveService.onHitPointsChanged(
      current: character.deathSaves,
      before: character.hitPoints,
      after: restoredHitPoints,
    );

    final withFeatures = FeatureResources.restoreAll(
      character: character,
      featureIds: restoredFeatureIds,
    );

    final updated = withFeatures.copyWith(
      hitPoints: restoredHitPoints,
      deathSaves: clearedSaves,
      hitDiceUsed: remainingUsed,
      exhaustion: (character.exhaustion - 1).clamp(0, 6),
      updatedAt: DateTime.now(),
    );

    final recharges = magicItemRecharges(character);

    final itemsNote = recharges.isEmpty
        ? ''
        : ', ${recharges.length} item(ns) mágico(s) recarregado(s)';

    // Mesma régua das outras notas: avisa só o que mudou de fato. Quem não
    // tinha uso gasto não precisa ler que algo foi renovado.
    final featuresNote = _clearedAnyUse(character, restoredFeatureIds)
        ? ' Usos de característica renovados.'
        : '';

    // Dito no resumo de propósito: os marcadores desaparecem da ficha, e o
    // jogador precisa saber que foi a regra, não um apagamento acidental.
    final savesNote =
        clearedSaves == null ? '' : ' Testes contra a morte zerados.';

    return RestOutcome(
      character: updated,
      clearedSpellSlotLevels: null, // todos
      magicItemRecharges: recharges,
      summary: 'Descanso longo: PV restaurados, espaços de magia renovados'
          '$itemsNote e $recovered dado(s) de vida recuperado(s).'
          '$savesNote$featuresNote',
    );
  }

  /// Itens que voltam a ficar cheios num descanso longo.
  ///
  /// Só entram itens que usam cargas e que ainda não estão cheios, para o
  /// descanso não gerar escrita inútil no banco.
  static List<MagicItemRecharge> magicItemRecharges(Character character) {
    final recharges = <MagicItemRecharge>[];

    for (final item in character.magicItems) {
      final max = item.maxCharges ?? 0;
      if (max <= 0) continue;
      if ((item.charges ?? 0) >= max) continue;
      if (!rechargesOnLongRest(item.rechargeRule)) continue;

      recharges.add(
        MagicItemRecharge(magicItemId: item.localId, charges: max),
      );
    }

    return recharges;
  }

  /// Decide se a regra de recarga digitada pelo jogador vale num descanso
  /// longo.
  ///
  /// O campo é texto livre, então a leitura é por palavra-chave. As escolhas:
  /// - **em branco recarrega**: no PHB o padrão de item com carga é "recupera
  ///   ao amanhecer", e é o caso da maioria;
  /// - regra de descanso curto também entra, porque quem recupera no curto
  ///   está cheio depois de um longo;
  /// - regra com condição própria ("ao matar uma criatura") fica de fora, e o
  ///   jogador ajusta à mão na tela de itens.
  static bool rechargesOnLongRest(String? rule) {
    final text = rule?.trim().toLowerCase() ?? '';
    if (text.isEmpty) return true;

    const nunca = [
      'não recarrega',
      'nao recarrega',
      'não recupera',
      'nao recupera',
      'never',
      'não recarregável',
      'nao recarregavel',
    ];
    if (nunca.any(text.contains)) return false;

    const gatilhos = [
      'amanhecer',
      'alvorada',
      'aurora',
      'dawn',
      'anoitecer',
      'dusk',
      'descanso',
      'rest',
      'diária',
      'diaria',
      'diário',
      'diario',
      'diariamente',
      'daily',
    ];
    return gatilhos.any(text.contains);
  }

  /// Descanso curto (PHB): não recupera PV automaticamente (o jogador gasta
  /// dados de vida) nem espaços normais. O Bruxo recupera os espaços de pacto.
  static RestOutcome shortRest({
    required Character character,
    required List<int> pactSlotUsageKeys,
    Set<String> restoredFeatureIds = const {},
  }) {
    final hasPact = pactSlotUsageKeys.isNotEmpty;

    final restored = FeatureResources.restoreAll(
      character: character,
      featureIds: restoredFeatureIds,
    );

    final featuresNote = _clearedAnyUse(character, restoredFeatureIds)
        ? ' Usos de característica de descanso curto renovados.'
        : '';

    return RestOutcome(
      character: restored.copyWith(updatedAt: DateTime.now()),
      clearedSpellSlotLevels: pactSlotUsageKeys,
      summary: hasPact
          ? 'Descanso curto: espaços de Magia de Pacto renovados. '
              'Gaste dados de vida para recuperar PV.$featuresNote'
          : 'Descanso curto: gaste dados de vida para recuperar PV.'
              '$featuresNote',
    );
  }

  /// Gasta um dado de vida, curando o valor rolado + modificador de CON.
  /// O valor da rolagem vem de fora para permitir rolagem manual ou aleatória.
  static Character spendHitDie({
    required Character character,
    required int rolled,
    required int constitutionModifier,
    required int totalHitDice,
  }) {
    if (character.hitDiceUsed >= totalHitDice) return character;

    final healed = rolled + constitutionModifier;
    final safeHeal = healed < 1 ? 1 : healed;
    final healedHitPoints = character.hitPoints.heal(safeHeal);

    // Mesma regra do descanso longo: sair de 0 PV encerra os testes.
    final clearedSaves = DeathSaveService.onHitPointsChanged(
      current: character.deathSaves,
      before: character.hitPoints,
      after: healedHitPoints,
    );

    return character.copyWith(
      hitPoints: healedHitPoints,
      deathSaves: clearedSaves,
      hitDiceUsed: character.hitDiceUsed + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// Se alguma das características recarregadas tinha uso gasto.
  ///
  /// Olha o estado antes do descanso: depois dele todos estão em zero e não
  /// dá mais para saber se a renovação mudou algo.
  static bool _clearedAnyUse(Character character, Set<String> featureIds) {
    if (featureIds.isEmpty) return false;

    return character.featureStates.any(
      (state) => featureIds.contains(state.featureId) && state.usesSpent > 0,
    );
  }
}
