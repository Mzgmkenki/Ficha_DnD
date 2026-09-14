import 'package:dnd_ficha_app/features/character/application/use_cases/character/level_up_character_class.dart';
import 'package:flutter/material.dart';

/// Uma classe do personagem como opção de subida de nível.
class LevelUpClassOption {
  const LevelUpClassOption({
    required this.classId,
    required this.className,
    required this.level,
  });

  final String classId;
  final String className;

  /// Nível atual nessa classe.
  final int level;
}

/// Pergunta em qual classe o nível vai entrar e devolve o `classId` escolhido,
/// ou nulo se o jogador desistir.
///
/// Só faz sentido no multiclasse. Com uma classe só não há o que perguntar, e a
/// ficha sobe direto.
Future<String?> showLevelUpClassDialog({
  required BuildContext context,
  required List<LevelUpClassOption> options,
  required int totalLevel,
}) {
  // Com o total no teto nenhuma opção é válida, então mostrar a lista só
  // levaria a um toque que não faz nada.
  final remaining = maxCharacterLevel - totalLevel;

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Subir de nível'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              remaining > 0
                  ? 'Qual classe recebe o nível? Faltam $remaining para o teto de $maxCharacterLevel.'
                  : 'O nível total já está em $maxCharacterLevel.',
            ),
            const SizedBox(height: 8),
            for (final option in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option.className),
                subtitle: Text(
                  option.level >= maxCharacterLevel
                      ? 'Nível ${option.level} (no teto)'
                      : 'Nível ${option.level} → ${option.level + 1}',
                ),
                // Escolher já executa: um passo de confirmação a mais para
                // decisão reversível pela tela de multiclasse seria atrito.
                onTap: remaining > 0 && option.level < maxCharacterLevel
                    ? () => Navigator.of(dialogContext).pop(option.classId)
                    : null,
                enabled: remaining > 0 && option.level < maxCharacterLevel,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      );
    },
  );
}
