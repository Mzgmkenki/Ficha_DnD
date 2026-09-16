import 'package:dnd_ficha_app/features/character/domain/entities/combat_option.dart';
import 'package:dnd_ficha_app/features/character/domain/services/combat_options_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';

/// Uma sequência que o personagem consegue executar num turno.
class TurnPossibility {
  const TurnPossibility({
    required this.title,
    required this.steps,
    required this.rationale,
  });

  final String title;

  /// Os passos, na ordem em que aconteceriam.
  final List<String> steps;

  /// Uma linha explicando por que a sequência é legal.
  final String rationale;
}

/// Monta sugestões de turno a partir do que está realmente disponível.
///
/// São sugestões, não recomendações: o gerador não tenta escolher a melhor
/// jogada, e de propósito. Ele mostra que a economia do turno permite combinar
/// certas coisas, porque é isso que costuma passar batido em mesa — sobra ação
/// bônus sem uso.
///
/// Conservador por decisão: só combina o que o resolvedor marcou como
/// disponível, e só nos encaixes que a regra garante sem depender de contexto
/// (posição, alcance, alvo). Não existe sugestão que dependa de "se o inimigo
/// estiver a 1,5 m", porque o app não sabe onde ninguém está.
class TurnPossibilities {
  const TurnPossibilities._();

  static List<TurnPossibility> from(CombatOptions options) {
    final action = _firstAvailable(options[CombatActionType.action]);
    final bonus = _firstAvailable(options[CombatActionType.bonusAction]);
    final movement = _firstAvailable(options[CombatActionType.movement]);
    final extraAction = _extraActionGrant(options);

    // Sem ação disponível não há turno a sugerir: é o caso de quem está
    // Incapacitado, e a seção de ações já explica o motivo.
    if (action == null) return const [];

    final result = <TurnPossibility>[];

    if (movement != null) {
      result.add(
        TurnPossibility(
          title: 'Movimento + ação',
          steps: [movement.name, action.name],
          rationale:
              'Movimento não gasta a ação, e pode ser dividido antes e depois '
              'dela.',
        ),
      );
    }

    if (bonus != null) {
      result.add(
        TurnPossibility(
          title: 'Ação + ação bônus',
          steps: [action.name, bonus.name],
          rationale:
              'A ação bônus é um espaço separado do turno: deixar de usá-la '
              'não devolve nada.',
        ),
      );

      if (movement != null) {
        result.add(
          TurnPossibility(
            title: 'Movimento + ação + ação bônus',
            steps: [movement.name, action.name, bonus.name],
            rationale: 'O turno cheio: os três espaços não competem entre si.',
          ),
        );
      }
    }

    if (extraAction != null) {
      result.add(
        TurnPossibility(
          title: 'Ação + ${extraAction.name}',
          steps: [action.name, extraAction.name, action.name],
          rationale:
              '${extraAction.name} concede uma ação a mais neste turno, então '
              'a mesma ação pode ser repetida.',
        ),
      );
    }

    return result;
  }

  /// O recurso da build que concede uma ação inteira a mais.
  ///
  /// Reconhecido pelo id da característica, e não pelo nome exibido, para não
  /// depender de tradução nem de o asset escrever exatamente igual.
  static CombatOption? _extraActionGrant(CombatOptions options) {
    for (final option in options[CombatActionType.special]) {
      if (!option.isAvailable) continue;
      if (option.id.endsWith('fighter.action_surge')) return option;
    }
    return null;
  }

  static CombatOption? _firstAvailable(List<CombatOption> options) {
    for (final option in options) {
      if (option.isAvailable) return option;
    }
    return null;
  }
}
