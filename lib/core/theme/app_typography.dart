import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Tipografia do app.
///
/// Os títulos usam Cinzel Decorative, a fonte aberta mais próxima das
/// capitulares serifadas da logo de D&D. O corpo do texto fica na fonte do
/// sistema: é mais legível em telas cheias de número e não pesa no bundle.
///
/// Cinzel Decorative só tem caixa alta desenhada com capricho e é estreita em
/// texto corrido, por isso não é usada em `body` nem em `label`.
class AppTypography {
  const AppTypography._();

  static const String display = 'CinzelDecorative';

  /// Números em destaque: CA, HP, valor de atributo, total da rolagem.
  ///
  /// Fica fora da fonte decorativa de propósito. Cinzel Decorative desenha as
  /// minúsculas como versaletes, então "9m" de deslocamento saía como "9M".
  /// `tabularFigures` mantém os dígitos com a mesma largura, para o número
  /// não "dançar" quando muda.
  static TextStyle numeric({double fontSize = 22, Color? color}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      height: 1.1,
      color: color ?? AppColors.onDark,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Rótulo dos botões de ação que acompanham um cabeçalho de seção
  /// ("Editar nível", "Calcular CA").
  ///
  /// Usa a fonte dos títulos em branco para o botão ler como parte do
  /// cabeçalho, e não como um aviso. O vermelho fica só no ícone, que é o
  /// que precisa chamar o olho.
  static const TextStyle actionLabel = TextStyle(
    fontFamily: display,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.1,
    color: AppColors.onDark,
  );

  static TextTheme textTheme() {
    const heading = TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w900,
      color: AppColors.onDark,
      height: 1.15,
    );

    const section = TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w700,
      color: AppColors.onDark,
      height: 1.2,
    );

    return TextTheme(
      // Nome do personagem e telas de destaque.
      displayLarge: heading.copyWith(fontSize: 40, letterSpacing: 1.6),
      displayMedium: heading.copyWith(fontSize: 32, letterSpacing: 1.4),
      displaySmall: heading.copyWith(fontSize: 27, letterSpacing: 1.2),

      headlineLarge: heading.copyWith(fontSize: 26, letterSpacing: 1.1),
      headlineMedium: heading.copyWith(fontSize: 23, letterSpacing: 1),
      headlineSmall: heading.copyWith(fontSize: 20, letterSpacing: 0.9),

      // Barra superior e cabeçalhos de seção. É o menor tamanho em que a
      // fonte decorativa ainda é confortável de ler.
      titleLarge: section.copyWith(fontSize: 18, letterSpacing: 1),

      // `titleMedium` fica na fonte do sistema de propósito: o Material o usa
      // como padrão em DropdownButton e em diálogos, e o app o usa para
      // valores numéricos. Fonte decorativa ali atrapalharia a leitura.
      titleMedium: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: AppColors.onDark,
      ),

      // Daqui para baixo é a fonte do sistema: nomes de itens, magias e
      // antecedentes podem ser longos e precisam de legibilidade.
      titleSmall: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.onDark,
      ),
      bodyLarge: const TextStyle(
        fontSize: 15.5,
        height: 1.42,
        color: AppColors.onDark,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.42,
        color: AppColors.onDark,
      ),
      bodySmall: const TextStyle(
        fontSize: 12.5,
        height: 1.38,
        color: AppColors.onDarkVariant,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.onDark,
      ),
      labelMedium: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.onDarkVariant,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.onDarkVariant,
      ),
    );
  }
}
