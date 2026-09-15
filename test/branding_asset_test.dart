import 'dart:io';

import 'package:dnd_ficha_app/core/branding/app_branding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Confere se a logo atende ao que o app e o PDF precisam.
///
/// Existe porque olhar a arte não resolve: numa pré-visualização, fundo
/// transparente e fundo branco são idênticos, e a diferença estraga um dos dois
/// usos. Fundo branco viraria um retângulo claro na barra escura do app; fundo
/// preto viraria um retângulo cinza no meio da página do PDF. Só os bytes
/// respondem.
///
/// Enquanto o arquivo não existir, os testes se marcam como pulados em vez de
/// falhar: o projeto tem de continuar verde antes da arte chegar.
void main() {
  /// Alfa considerado transparente. Não exijo zero cravado porque exportador
  /// costuma deixar resíduo de 1 ou 2 na borda.
  const int transparentThreshold = 8;

  img.Image? decode(String path) {
    final file = File(path);
    if (!file.existsSync()) return null;

    final decoded = img.decodePng(file.readAsBytesSync());
    expect(decoded, isNotNull, reason: '$path não é um PNG válido');
    return decoded;
  }

  /// Alfa dos quatro cantos. Se a arte tem fundo, é ali que ele aparece.
  List<int> cornerAlphas(img.Image image) {
    final maxX = image.width - 1;
    final maxY = image.height - 1;

    return [
      image.getPixel(0, 0).a.toInt(),
      image.getPixel(maxX, 0).a.toInt(),
      image.getPixel(0, maxY).a.toInt(),
      image.getPixel(maxX, maxY).a.toInt(),
    ];
  }

  group('logo.png', () {
    test('existe e é um PNG legível', () {
      final image = decode(AppBranding.logoAsset);

      if (image == null) {
        markTestSkipped(
          'Ainda não há ${AppBranding.logoAsset}. '
          'Ver assets/branding/README.md.',
        );
        return;
      }

      expect(image.width, greaterThan(0));
      expect(image.height, greaterThan(0));
    });

    test('tem canal alfa', () {
      final image = decode(AppBranding.logoAsset);
      if (image == null) {
        markTestSkipped('Logo ausente.');
        return;
      }

      // Sem canal alfa não existe transparência possível: o exportador achatou
      // a arte contra um fundo sólido.
      expect(
        image.numChannels,
        4,
        reason: 'a logo foi exportada sem canal alfa, então tem fundo sólido',
      );
    });

    test('o fundo é transparente, não branco nem preto', () {
      final image = decode(AppBranding.logoAsset);
      if (image == null) {
        markTestSkipped('Logo ausente.');
        return;
      }

      final alphas = cornerAlphas(image);

      // O caso que este teste existe para pegar: arte bonita, fundo sólido. Na
      // marca d'água do PDF isso vira um retângulo no meio da página.
      expect(
        alphas.every((alpha) => alpha <= transparentThreshold),
        isTrue,
        reason: 'os cantos não estão transparentes (alfa $alphas). '
            'Exporte com fundo transparente.',
      );
    });

    test('é grande o bastante para a marca d\'água', () {
      final image = decode(AppBranding.logoAsset);
      if (image == null) {
        markTestSkipped('Logo ausente.');
        return;
      }

      // A marca d'água ocupa cerca de 60% da largura de uma A4; abaixo disso
      // ela serrilha ao ser ampliada.
      final longestSide =
          image.width > image.height ? image.width : image.height;

      expect(
        longestSide,
        greaterThanOrEqualTo(1024),
        reason: 'lado maior tem $longestSide px, abaixo dos 1024 pedidos',
      );
    });
  });

  group('logo_icon.png', () {
    test('quando existe, é quadrada e grande', () {
      final image = decode(AppBranding.iconAsset);

      if (image == null) {
        markTestSkipped(
          'Sem ${AppBranding.iconAsset}. A barra do app cai na logo cheia, '
          'onde o wordmark fica ilegível.',
        );
        return;
      }

      // O gerador de ícone recorta em quadrado; arte retangular sairia cortada.
      expect(
        image.width,
        image.height,
        reason: 'o ícone precisa ser quadrado',
      );
      expect(image.width, greaterThanOrEqualTo(1024));
    });

    test('quando existe, tem canal alfa', () {
      final image = decode(AppBranding.iconAsset);
      if (image == null) {
        markTestSkipped('Ícone ausente.');
        return;
      }

      expect(image.numChannels, 4);
    });
  });
}
