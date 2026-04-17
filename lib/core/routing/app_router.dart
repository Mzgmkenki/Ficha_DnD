import 'package:dnd_ficha_app/features/character/presentation/pages/character_creation_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_list_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_sheet_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String characterList = '/';
  static const String characterCreation = '/character/create';
  static const String characterSheet = '/character/sheet';
}

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.characterList:
        return MaterialPageRoute<void>(builder: (_) => const CharacterListPage());
      case AppRoutes.characterCreation:
        return MaterialPageRoute<void>(builder: (_) => const CharacterCreationPage());
      case AppRoutes.characterSheet:
        final args = settings.arguments;
        if (args is! String) {
          return _errorRoute('Character ID inválido.');
        }
        return MaterialPageRoute<void>(
          builder: (_) => CharacterSheetPage(characterId: args),
        );
      default:
        return _errorRoute('Rota não encontrada: ${settings.name}');
    }
  }

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erro de navegação')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
