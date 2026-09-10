import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/routing/app_router.dart';
import 'package:dnd_ficha_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DndFichaApp extends ConsumerWidget {
  const DndFichaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp(
      title: 'Ficha D&D 5e',
      debugShowCheckedModeBanner: false,
      // Um tema só: a ficha é feita para mesa à noite, e o preto e vermelho é
      // a identidade do app. `darkTheme` também é definido para o sistema não
      // tentar clarear nada.
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.characterList,
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
