import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Retrato quadrado do personagem, sem interação.
///
/// Usado onde o retrato acompanha um formulário (criação) ou o cabeçalho da
/// ficha. Na lista, onde a imagem é o próprio cartão do personagem, use
/// [PortraitBanner].
class PortraitAvatar extends StatelessWidget {
  const PortraitAvatar({
    required this.path,
    this.bytes,
    this.size = 78,
    this.aspectRatio = 1,
    this.emptyLabel,
    this.highlightWhenFilled = true,
    super.key,
  });

  final String? path;
  final Uint8List? bytes;
  final double size;
  final double aspectRatio;

  /// Legenda sob o ícone quando não há imagem. Em miniatura fica `null`,
  /// porque não sobra espaço para texto legível.
  final String? emptyLabel;

  /// Borda vermelha quando há imagem.
  final bool highlightWhenFilled;

  @override
  Widget build(BuildContext context) {
    final filled = _hasPortrait(path, bytes) && highlightWhenFilled;

    return _PortraitFrame(
      path: path,
      bytes: bytes,
      width: size,
      height: size / aspectRatio,
      emptyLabel: emptyLabel,
      radius: BorderRadius.circular(size >= 64 ? 12 : 8),
      borderColor: filled ? AppColors.red : AppColors.outline,
      borderWidth: filled ? 1.4 : 1,
    );
  }
}

/// Retrato largo: ocupa toda a largura que o pai oferecer e tira a altura de
/// [aspectRatio].
///
/// É o formato da lista de personagens — a imagem grande é o que identifica o
/// personagem de relance, melhor que um quadradinho ao lado do nome.
class PortraitBanner extends StatelessWidget {
  const PortraitBanner({
    required this.path,
    this.aspectRatio = 4 / 3,
    this.emptyHeight,
    this.emptyLabel,
    super.key,
  });

  final String? path;

  /// Largura dividida pela altura. O padrão 4:3 é retangular sem cortar
  /// demais as fotos verticais, que é o normal em retrato de personagem.
  final double aspectRatio;

  /// Altura usada quando não há imagem.
  ///
  /// Sem foto não há o que ver, e manter a proporção cheia deixaria a lista
  /// com um vazio enorme por personagem. Nulo mantém a proporção.
  final double? emptyHeight;

  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Largura infinita acontece em Row/ListView horizontal sem limite;
        // aí não há o que preencher e um valor fixo evita crash de layout.
        final width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 240.0;

        final empty = emptyHeight;
        final height =
            !_hasPortrait(path) && empty != null ? empty : width / aspectRatio;

        return _PortraitFrame(
          path: path,
          width: width,
          height: height,
          emptyLabel: emptyLabel,
          // Sem borda e sem canto próprio: quem recorta é o card em volta, e
          // duas bordas concêntricas ficam sujas.
          radius: BorderRadius.zero,
          borderColor: null,
        );
      },
    );
  }
}

bool _hasPortrait(String? path, [Uint8List? bytes]) =>
    (bytes != null && bytes.isNotEmpty) || (path != null && path.isNotEmpty);

/// Caixa que desenha a imagem ou o placeholder.
///
/// Existe para os dois formatos não duplicarem a parte chata: limitar a
/// decodificação e não estourar quando o arquivo não abre.
class _PortraitFrame extends StatelessWidget {
  const _PortraitFrame({
    required this.path,
    this.bytes,
    required this.width,
    required this.height,
    required this.radius,
    required this.borderColor,
    this.borderWidth = 1,
    this.emptyLabel,
  });

  final String? path;
  final Uint8List? bytes;
  final double width;
  final double height;
  final BorderRadius radius;
  final Color? borderColor;
  final double borderWidth;
  final String? emptyLabel;

  /// Ícone e legenda acompanham o tamanho da caixa, senão o ícone se perde
  /// numa imagem grande ou estoura numa pequena.
  double get _shortestSide => math.min(width, height);

  @override
  Widget build(BuildContext context) {
    final border = borderColor;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: radius,
        border:
            border == null
                ? null
                : Border.all(color: border, width: borderWidth),
      ),
      clipBehavior: radius == BorderRadius.zero ? Clip.none : Clip.antiAlias,
      child:
          _hasPortrait(path, bytes)
              ? _image(context)
              : _placeholder(context, false),
    );
  }

  Widget _image(BuildContext context) {
    // `cacheWidth` limita a decodificação ao tamanho que aparece na tela: sem
    // isso, a foto de 12 MP do celular seria decodificada inteira na memória
    // só para desenhar o retrato — e numa lista isso multiplica.
    final pixels = (width * MediaQuery.devicePixelRatioOf(context)).round();

    final image =
        bytes != null ? Image.memory(bytes!) : Image.file(File(path!));

    return Image(
      image: image.image,
      fit: BoxFit.cover,
      // Retrato de personagem é quase sempre uma imagem vertical, e `cover`
      // centralizado cortava justamente a cabeça, deixando o meio do corpo.
      // Ancorar no topo preserva o rosto, que é o que identifica.
      alignment: Alignment.topCenter,
      width: width,
      height: height,
      cacheWidth: pixels,
      filterQuality: FilterQuality.medium,
      // O arquivo mora no diretório do app, mas o jogador pode ter limpado os
      // dados ou restaurado um backup sem ele. Cair no placeholder é melhor
      // que a tela inteira quebrar com exceção de render.
      errorBuilder: (context, error, stackTrace) => _placeholder(context, true),
    );
  }

  Widget _placeholder(BuildContext context, bool broken) {
    final shortest = _shortestSide;
    final icon = Icon(
      broken ? Icons.broken_image_outlined : Icons.person_outline,
      color: AppColors.onDarkVariant,
      size:
          shortest >= 140
              ? 44
              : shortest >= 64
              ? 26
              : 22,
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
