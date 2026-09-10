import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Tema do app: preto e vermelho, com títulos em capitulares serifadas.
///
/// Montado uma vez e guardado em `static final`: o `ThemeData` é imutável e
/// remontá-lo a cada build do MaterialApp só gastaria tempo.
///
/// Nada aqui usa sombra colorida, gradiente ou blur — o custo de pintura fica
/// igual ao de um tema padrão.
class AppTheme {
  const AppTheme._();

  static final ThemeData dark = _build();

  /// Mantido para não quebrar chamadas antigas: o app tem um só tema.
  static ThemeData light() => dark;

  static ThemeData _build() {
    const scheme = AppColors.scheme;
    final text = AppTypography.textTheme();

    // Raios usados no app inteiro, para nada ficar fora de esquadro.
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.outlineVariant),
    );
    final fieldRadius = BorderRadius.circular(12);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(11),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.onDark, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.red, size: 22),
        // Fio vermelho no rodapé da barra: dá o acento da marca sem custar
        // uma sombra.
        shape: const Border(
          bottom: BorderSide(color: AppColors.redDeep, width: 1.5),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        labelStyle: const TextStyle(color: AppColors.onDarkVariant),
        // O rótulo flutuante só fica vermelho quando o campo está em foco.
        // Vermelho fixo competia com o conteúdo e parecia mensagem de erro.
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return const TextStyle(color: AppColors.error);
          }
          if (states.contains(WidgetState.focused)) {
            return const TextStyle(color: AppColors.red);
          }
          return const TextStyle(color: AppColors.onDarkVariant);
        }),
        hintStyle: const TextStyle(color: Color(0xFF7C7570)),
        helperStyle: text.bodySmall,
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12.5),
        border: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: AppColors.red, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),

      // Preenchido em vermelho profundo com texto branco: mais legível e mais
      // parecido com a marca do que o vermelho claro que o Material usaria.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.redDeep,
          foregroundColor: AppColors.onRed,
          disabledBackgroundColor: AppColors.surfaceContainerHighest,
          disabledForegroundColor: AppColors.onDarkVariant,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: buttonShape,
          textStyle: text.labelLarge?.copyWith(letterSpacing: 0.6),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: const BorderSide(color: AppColors.outline),
          shape: buttonShape,
          textStyle: text.labelLarge?.copyWith(letterSpacing: 0.4),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.red,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.onDark),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.redDeep,
        foregroundColor: AppColors.onRed,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        selectedColor: AppColors.redContainer,
        side: const BorderSide(color: AppColors.outlineVariant),
        labelStyle: text.labelMedium?.copyWith(color: AppColors.onDark),
        secondaryLabelStyle: text.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: AppColors.onDarkVariant,
        textColor: AppColors.onDark,
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: text.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.redDeep;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.onRed),
        side: const BorderSide(color: AppColors.outline, width: 1.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.onRed;
          return AppColors.onDarkVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.redDeep;
          return AppColors.surfaceContainerHighest;
        }),
        trackOutlineColor:
            const WidgetStatePropertyAll(AppColors.outlineVariant),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.red;
          return AppColors.outline;
        }),
      ),

      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.redDeep,
        inactiveTrackColor: AppColors.surfaceContainerHighest,
        thumbColor: AppColors.red,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.red,
        linearTrackColor: AppColors.surfaceContainerHighest,
        circularTrackColor: Colors.transparent,
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor:
              const WidgetStatePropertyAll(AppColors.surfaceContainerHigh),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
        textStyle: text.bodyMedium,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleMedium,
        contentTextStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: AppColors.outline,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighest,
        contentTextStyle: text.bodyMedium,
        actionTextColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        textStyle: text.bodySmall?.copyWith(color: AppColors.onDark),
      ),

      iconTheme: const IconThemeData(color: AppColors.onDarkVariant, size: 22),
    );
  }
}
