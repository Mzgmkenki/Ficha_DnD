import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Botão de ação que acompanha um cabeçalho de seção da ficha.
///
/// O rótulo vai na fonte dos títulos, em branco, para o botão pertencer
/// visualmente ao cabeçalho ao lado. Só o ícone fica vermelho: texto inteiro
/// em vermelho competia com o título e lembrava mensagem de erro.
///
/// Não usa o `textButtonTheme` global de propósito. Lá o vermelho no texto é
/// desejado (ações destrutivas como "Remover item", botões de diálogo), então
/// o estilo é aplicado aqui, no caso específico.
class SheetHeaderAction extends StatelessWidget {
  const SheetHeaderAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;

  /// Nulo desabilita o botão, para a ação continuar visível quando não há o que
  /// fazer (subir de nível no 20, por exemplo) em vez de desaparecer da ficha.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.onDark,
        iconColor: AppColors.red,
        textStyle: AppTypography.actionLabel,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
