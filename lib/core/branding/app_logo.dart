import 'package:dnd_ficha_app/core/branding/app_branding.dart';
import 'package:flutter/material.dart';

/// Logo do app.
///
/// Enquanto os arquivos não existirem em `assets/branding/`, este widget
/// desenha o [fallback] (por padrão, nada). Isso deixa os pontos de marca já
/// posicionados no layout sem que a tela quebre nem mostre imagem faltando.
class AppLogo extends StatelessWidget {
  const AppLogo({
    required this.height,
    this.fallback,
    this.opacity = 1,
    this.preferIconOnly = false,
    super.key,
  });

  /// Altura em pixels lógicos. A largura acompanha a proporção da arte.
  final double height;

  /// O que desenhar quando a logo ainda não foi adicionada.
  final Widget? fallback;

  /// Para a logo ficar discreta atrás do conteúdo.
  final double opacity;

  /// Pede a versão sem o wordmark.
  ///
  /// A logo cheia é um conjunto vertical: dragão em cima, "DragonSheet"
  /// embaixo. Reduzida para a altura de uma barra de app, o nome fica ilegível,
  /// então lugares pequenos pedem só a marca. Se o arquivo separado não
  /// existir, cai na logo cheia em vez de não mostrar nada.
  final bool preferIconOnly;

  @override
  Widget build(BuildContext context) {
    final image = preferIconOnly
        ? _image(AppBranding.iconAsset, onError: _fullLogo)
        : _image(AppBranding.logoAsset);

    if (opacity >= 1) return image;

    return Opacity(opacity: opacity, child: image);
  }

  Widget _fullLogo() => _image(AppBranding.logoAsset);

  Widget _image(String asset, {Widget Function()? onError}) {
    return Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      // Sem isto o Flutter desenha o ícone de erro num quadro cinza, que num
      // AppBar fica pior que simplesmente não mostrar nada.
      errorBuilder: (context, error, stackTrace) =>
          onError?.call() ?? fallback ?? const SizedBox.shrink(),
      // A logo é decorativa: quem usa leitor de tela já ouve o título ao lado,
      // e anunciar "logo" duas vezes só atrapalha.
      excludeFromSemantics: true,
    );
  }
}
