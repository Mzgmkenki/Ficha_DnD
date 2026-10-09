import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/combat_panel_summary.dart';
import 'package:flutter/material.dart';

/// Acesso ao Painel de combate, com o resumo do que há por lá.
///
/// Não é um botão flutuante de propósito: ele cobriria o conteúdo da ficha, que
/// é longa e rolada com o polegar. Fica em linha, logo abaixo do resumo de
/// combate, onde o jogador já está olhando quando precisa de ação, condição ou
/// descanso.
///
/// O resumo sai de [CombatPanelSummary], o mesmo objeto que alimenta os
/// indicadores das abas — a ficha não recalcula nada por conta própria.
class CombatPanelButton extends StatelessWidget {
  const CombatPanelButton({
    required this.character,
    required this.onPressed,
    super.key,
  });

  final Character character;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final summary = CombatPanelSummary.of(character);
    final badge = summary.badgeLabel;

    return Card(
      // Margem zero para alinhar com os outros cartões da ficha, que vêm de
      // `Card` sem margem dentro do `ListView`.
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        // Mesmo arranjo do cabeçalho de `CollapsibleSection`: um nó só com o
        // rótulo inteiro. Sem `container` e `excludeSemantics` o leitor de tela
        // receberia título, resumo, indicador e a lista de abas como quatro
        // fragmentos soltos.
        container: true,
        button: true,
        // O rótulo acessível junta destino e estado: quem usa leitor de tela
        // ouve o que há no painel sem precisar abrir.
        label: 'Painel de combate. ${summary.compactLine}',
        hint: 'Abrir',
        // `excludeSemantics` tira a ação de toque do InkWell junto, então ela
        // precisa ser redeclarada aqui — senão o nó seria um botão que o leitor
        // de tela anuncia e não consegue ativar.
        onTap: onPressed,
        excludeSemantics: true,
        child: InkWell(
          // `InkWell` dentro do `Card` dá o estado pressionado (ripple) que um
          // `Container` com `GestureDetector` não daria.
          onTap: onPressed,
          child: ConstrainedBox(
            // 56 passa o mínimo de 48 recomendado, com folga para o dedo numa
            // tela pequena.
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sports_martial_arts,
                    color: AppColors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Painel de combate',
                                style: text.titleLarge,
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(width: 8),
                              _Badge(label: badge),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary.compactLine,
                          style: text.bodySmall?.copyWith(
                            color: AppColors.onDarkVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ações • Condições • Recursos',
                          style: text.labelSmall?.copyWith(
                            color: AppColors.onDarkVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.onDarkVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicador do botão. Texto, não só cor, pelo mesmo motivo do indicador das
/// abas: em preto e branco um ponto vermelho desaparece.
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.redContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onRedContainer,
            ),
      ),
    );
  }
}
