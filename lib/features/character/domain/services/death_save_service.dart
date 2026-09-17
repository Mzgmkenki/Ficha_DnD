import 'package:dnd_ficha_app/core/utils/dice_roller.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/death_saves.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';

/// O que uma rolagem de teste contra a morte produziu.
class DeathSaveOutcome {
  const DeathSaveOutcome({
    required this.saves,
    required this.summary,
    this.regainsHitPoint = false,
  });

  /// Os marcadores depois da rolagem.
  final DeathSaves saves;

  /// Frase pronta para a tela: o que o dado deu e o que isso causou.
  final String summary;

  /// Se o resultado devolve 1 ponto de vida (o `20` natural).
  final bool regainsHitPoint;
}

/// Regras do teste contra a morte.
///
/// Edição de referência: D&D 5e, Livro do Jogador de 2014, capítulo 9. O teste
/// não é um teste de atributo nem uma salvaguarda de verdade — não leva
/// modificador, não leva bônus de proficiência e não é afetado por Constituição.
/// Por isso este serviço nunca soma nada ao dado: se um talento ou item
/// mandasse somar, o modificador viria de quem chamou, explicitamente.
class DeathSaveService {
  const DeathSaveService._();

  /// A faixa em que o teste passa.
  static const int successThreshold = 10;

  /// Interpreta o dado rolado e devolve os marcadores atualizados.
  ///
  /// As quatro faixas da regra:
  /// - `1` natural: duas falhas;
  /// - `2` a `9`: uma falha;
  /// - `10` a `19`: um sucesso;
  /// - `20` natural: recupera 1 ponto de vida e a sequência zera.
  static DeathSaveOutcome applyRoll({
    required DeathSaves current,
    required DiceRollResult roll,
  }) {
    // O `20` natural não é "três sucessos de uma vez": o personagem volta a ter
    // 1 PV, deixa de estar morrendo e os marcadores perdem sentido.
    if (roll.isNaturalTwenty) {
      return DeathSaveOutcome(
        saves: current.cleared(),
        summary: '20 natural: recupera 1 ponto de vida e volta à consciência. '
            'Os marcadores foram zerados.',
        regainsHitPoint: true,
      );
    }

    if (roll.isNaturalOne) {
      final updated = current.withFailure(amount: 2);
      return DeathSaveOutcome(
        saves: updated,
        summary: '1 natural: conta como duas falhas. ${_stateSuffix(updated)}',
      );
    }

    if (roll.keptValue >= successThreshold) {
      final updated = current.withSuccess();
      return DeathSaveOutcome(
        saves: updated,
        summary: '${roll.keptValue}: sucesso. ${_stateSuffix(updated)}',
      );
    }

    final updated = current.withFailure();
    return DeathSaveOutcome(
      saves: updated,
      summary: '${roll.keptValue}: falha. ${_stateSuffix(updated)}',
    );
  }

  /// Como os marcadores reagem a uma mudança de pontos de vida.
  ///
  /// Recuperar qualquer ponto de vida encerra a sequência de testes, então os
  /// marcadores são zerados. Devolve `null` quando não há nada a mudar, para
  /// quem chama não gravar o personagem sem motivo.
  ///
  /// Não zera ao CHEGAR a zero: quem cai a 0 PV começa a sequência, e um
  /// personagem que já tinha marcadores de um desmaio anterior no mesmo combate
  /// os perderia sem que nenhuma regra mandasse.
  static DeathSaves? onHitPointsChanged({
    required DeathSaves current,
    required HitPoints before,
    required HitPoints after,
  }) {
    if (current.isEmpty) return null;

    final recovered = before.current <= 0 && after.current > 0;
    if (!recovered) return null;

    return current.cleared();
  }

  /// Frase curta que descreve o estado alcançado, para o fim do resumo.
  static String _stateSuffix(DeathSaves saves) {
    if (saves.isDead) return 'Terceira falha: o personagem morreu.';
    if (saves.isStable) {
      return 'Terceiro sucesso: o personagem está estável a 0 pontos de vida.';
    }

    return '${saves.describe()}.';
  }
}
