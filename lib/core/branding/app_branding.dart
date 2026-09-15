import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Caminhos e carregamento da identidade visual do app.
///
/// Tudo aqui tolera a logo não existir: enquanto o arquivo não é copiado para
/// `assets/branding/`, o app roda e o PDF sai sem marca d'água em vez de
/// quebrar. Isso mantém o projeto compilando e testável antes da arte chegar.
class AppBranding {
  const AppBranding._();

  /// Nome do app, num só lugar para não divergir entre tela, PDF e lojas.
  static const String appName = 'DragonSheet';

  /// Frase curta usada em metadados (web, lojas).
  static const String tagline =
      'Ficha de personagem de D&D 5e, com compêndio, magias e exportação em '
      'PDF.';

  /// Logo cheia, com o wordmark. Usada onde há espaço para ler o nome: tela
  /// vazia, cabeçalho da tela de exportar e marca d'água do PDF.
  static const String logoAsset = 'assets/branding/logo.png';

  /// Só a marca, sem o nome. Usada onde a logo aparece pequena, como a barra
  /// do app, e para gerar o ícone.
  ///
  /// Num espaço de 28 px de altura o wordmark viraria um borrão, então quem
  /// desenha pequeno pede este arquivo e cai no [logoAsset] se ele não existir.
  static const String iconAsset = 'assets/branding/logo_icon.png';

  /// Memoriza o resultado, inclusive a ausência.
  ///
  /// Sem isso cada página do PDF e cada rebuild da lista tentaria ler o asset
  /// de novo, e a tentativa que falha não é barata: o `rootBundle` percorre o
  /// manifest antes de lançar.
  static Future<Uint8List?>? _logoBytes;

  /// Bytes da logo, ou nulo se ela ainda não foi adicionada ao projeto.
  static Future<Uint8List?> loadLogoBytes() {
    return _logoBytes ??= _read(logoAsset);
  }

  /// Esquece o que foi memorizado. Existe para os testes não vazarem estado
  /// de um caso para o outro.
  @visibleForTesting
  static void resetCache() {
    _logoBytes = null;
  }

  static Future<Uint8List?> _read(String asset) async {
    try {
      final data = await rootBundle.load(asset);
      return data.buffer.asUint8List();
    } catch (error) {
      // Asset ausente é o caso esperado até a arte chegar, então não vale um
      // erro ruidoso. Qualquer outra falha de leitura também cai aqui, e o
      // efeito é o mesmo: segue sem logo.
      debugPrint('Logo não encontrada em $asset: sigo sem ela.');
      return null;
    }
  }
}
