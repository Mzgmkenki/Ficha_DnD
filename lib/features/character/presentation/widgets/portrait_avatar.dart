import 'dart:io';

import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Mostra a imagem de aparência do personagem, sem interação.
///
/// Fica num widget só porque o retrato aparece em três lugares (lista,
/// criação e cabeçalho da ficha) e a parte chata — limitar a decodificação e
/// não estourar quando o arquivo não abre — não deve ser copiada em cada um.
class PortraitAvatar extends StatelessWidget {
  const PortraitAvatar({
    required this.path,
    this.size = 78,
    this.emptyLabel,
    this.highlightWhenFilled = true,
    super.key,
  });

  final String? path;
  final double size;

  /// Legenda sob o ícone quando não há imagem. Em miniatura fica `null`,
  /// porque não sobra espaço para texto legível.
  final String? emptyLabel;

  /// Borda vermelha quando há imagem. A lista usa `false` para as miniaturas
  /// não competirem entre si.
  final bool highlightWhenFilled;

  bool get hasPortrait => path != null && path!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size >= 64 ? 12 : 8);
    final filled = hasPortrait && highlightWhenFilled;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: radius,
        border: Border.all(
          color: filled ? AppColors.red : AppColors.outline,
          width: filled ? 1.4 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPortrait ? _image(context) : _placeholder(context, false),
    );
  }

  Widget _image(BuildContext context) {
    // `cacheWidth` limita a decodificação ao tamanho que aparece na tela: sem
    // isso, a foto de 12 MP do celular seria decodificada inteira na memória
    // só para desenhar uma miniatura — e numa lista isso multiplica.
    final pixels = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return Image.file(
      File(path!),
      fit: BoxFit.cover,
      width: size,
      height: size,
      cacheWidth: pixels,
      filterQuality: FilterQuality.medium,
      // O arquivo mora no diretório do app, mas o jogador pode ter limpado os
      // dados ou restaurado um backup sem ele. Cair no placeholder é melhor
      // que a tela inteira quebrar com exceção de render.
      errorBuilder: (context, error, stackTrace) => _placeholder(context, true),
    );
  }

  Widget _placeholder(BuildContext context, bool broken) {
    final icon = Icon(
      broken ? Icons.broken_image_outlined : Icons.person_outline,
      color: AppColors.onDarkVariant,
      size: size >= 64 ? 26 : 22,
    );

    final label = emptyLabel;
    if (label == null) return Center(child: icon);

    // `FittedBox` porque a legenda pode não caber: com a fonte do sistema
    // aumentada nas configurações de acessibilidade, ícone + texto passavam da
    // altura da caixa e o Flutter desenhava a tarja de overflow. Encolher um
    // pouco a legenda é melhor que isso.
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 2),
            Text(
              broken ? 'sem arquivo' : label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
