import 'package:dnd_ficha_app/features/character/domain/services/ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/level_progression_choices.dart';
import 'package:flutter/material.dart';

/// O que o jogador decidiu fazer com a escolha do nível.
enum LevelProgressionDecision { feat, improvement }

/// Pergunta o que fazer com a escolha de nível: talento ou incremento.
///
/// As duas opções são mutuamente exclusivas por definição — o nível concede
/// "um incremento OU um talento", e é isso que o diálogo deixa explícito em
/// vez de abrir direto a lista de talentos, como fazia antes.
///
/// Devolve `null` quando o jogador fecha sem decidir. Isso NÃO gasta a
/// escolha: ela continua pendente e volta a ser oferecida na ficha.
///
/// [barrierDismissible] fica falso quando a janela foi aberta pelo app, e não
/// pelo jogador: na subida de nível a decisão é obrigatória, então sair dela
/// exige o "Decidir depois" explícito em vez de um toque fora do diálogo. O
/// requisito é não permitir concluir a evolução com a escolha em aberto sem o
/// jogador ter visto que ela existe.
Future<LevelProgressionDecision?> showLevelProgressionChoiceDialog({
  required BuildContext context,
  required LevelProgressionSlot slot,
  bool canChooseFeat = true,
  String? featUnavailableReason,
  bool barrierDismissible = true,
}) {
  final allowsImprovement = slot.allowsImprovement;

  return showDialog<LevelProgressionDecision>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      final text = Theme.of(dialogContext).textTheme;

      return AlertDialog(
        title: Text(
          slot.fromRace
              ? 'Escolha do nível'
              // Classe e nível no título, e não só no corpo: num multiclasse
              // com duas pendências em sequência é o título que diz de qual
              // das duas se trata.
              : '${slot.className} — nível ${slot.classLevel}',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                slot.fromRace
                    ? 'A raça concede um talento no 1º nível.'
                    : 'Escolha um benefício de progressão. '
                        '${slot.label} concede um Incremento no Valor de '
                        'Atributo, que você pode trocar por um talento.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: 12),
              if (allowsImprovement)
                ListTile(
                  key: const ValueKey('progression-improvement'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.trending_up),
                  title: const Text('Incremento no Valor de Atributo'),
                  subtitle: Text(
                    '+${AbilityScoreImprovementDraft.points} em um atributo, '
                    'ou +1 em dois.',
                  ),
                  onTap:
                      () => Navigator.of(
                        dialogContext,
                      ).pop(LevelProgressionDecision.improvement),
                ),
              ListTile(
                key: const ValueKey('progression-feat'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Talento'),
                subtitle: Text(
                  canChooseFeat
                      ? 'Escolha um talento cujos pré-requisitos você cumpra.'
                      // Bloqueio explicado, e não opção escondida: o jogador
                      // precisa saber que o talento existe e por que não está
                      // disponível agora.
                      : (featUnavailableReason ??
                          'Nenhum talento disponível agora.'),
                ),
                enabled: canChooseFeat,
                onTap:
                    canChooseFeat
                        ? () => Navigator.of(
                          dialogContext,
                        ).pop(LevelProgressionDecision.feat)
                        : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Decidir depois'),
          ),
        ],
      );
    },
  );
}
