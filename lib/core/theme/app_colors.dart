import 'package:flutter/material.dart';

/// Paleta preto e vermelho do app.
///
/// Os pretos não são puros: um cinza levemente quente cansa menos a vista em
/// tela grande e deixa as bordas visíveis. O branco do texto também é
/// levemente quente, pelo mesmo motivo.
class AppColors {
  const AppColors._();

  // Fundos, do mais escuro ao mais claro.
  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF121216);
  static const Color surfaceContainer = Color(0xFF17171C);
  static const Color surfaceContainerHigh = Color(0xFF1E1E24);
  static const Color surfaceContainerHighest = Color(0xFF26262E);

  static const Color outline = Color(0xFF3A3A44);
  static const Color outlineVariant = Color(0xFF2A2A32);

  /// Vermelho de destaque: claro o bastante para ler sobre o fundo preto
  /// (usado em ícones, links e valores em evidência).
  static const Color red = Color(0xFFE03A45);

  /// Vermelho profundo de preenchimento, para botões e barras onde o texto
  /// vai em branco.
  static const Color redDeep = Color(0xFFB71C24);

  /// Vinho para fundos de chip e etiqueta.
  static const Color redContainer = Color(0xFF5C0E14);
  static const Color onRedContainer = Color(0xFFFFD9D6);

  /// Vermelho vivo para erro. Mais claro e alaranjado que [red], para não
  /// virar a mesma cor do destaque.
  static const Color error = Color(0xFFFF6B6B);

  /// Ouro velho, usado com parcimônia: só no 20 natural e na etiqueta de
  /// especialista, onde precisamos de algo que não se confunda com o
  /// vermelho de erro.
  static const Color gold = Color(0xFFD4AF37);

  static const Color onDark = Color(0xFFEDE9E6);
  static const Color onDarkVariant = Color(0xFFB0A9A4);
  static const Color onRed = Color(0xFFFFF6F5);
  static const Color onGold = Color(0xFF201803);

  static const ColorScheme scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: red,
    onPrimary: Color(0xFF1A0507),
    primaryContainer: redContainer,
    onPrimaryContainer: onRedContainer,
    secondary: Color(0xFFC98A8F),
    onSecondary: Color(0xFF1A0507),
    secondaryContainer: Color(0xFF3D1114),
    onSecondaryContainer: onRedContainer,
    tertiary: gold,
    onTertiary: onGold,
    tertiaryContainer: Color(0xFF3D2F0A),
    onTertiaryContainer: Color(0xFFF3E3B0),
    error: error,
    onError: Color(0xFF2A0505),
    errorContainer: Color(0xFF6B1414),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: surface,
    onSurface: onDark,
    surfaceContainerLowest: background,
    surfaceContainerLow: surface,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurfaceVariant: onDarkVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: onDark,
    onInverseSurface: surface,
    inversePrimary: redDeep,
  );
}
