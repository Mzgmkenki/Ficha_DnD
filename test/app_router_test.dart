import 'package:dnd_ficha_app/core/routing/app_router.dart';
import 'package:dnd_ficha_app/core/routing/route_args.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_creation_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_list_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_sheet_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_transfer_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_hit_points_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_identity_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/manage_character_spells_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Constrói a rota e devolve o widget que ela geraria, sem montar a árvore.
Widget _pageOf(String name, {Object? arguments}) {
  final route = AppRouter().onGenerateRoute(
    RouteSettings(name: name, arguments: arguments),
  );

  final materialRoute = route as MaterialPageRoute;
  return materialRoute.builder(_FakeContext());
}

/// O builder das rotas deste app não usa o context, então um stub basta.
class _FakeContext extends StatelessWidget implements BuildContext {
  const _FakeContext();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('rotas sem argumento', () {
    test('lista de personagens', () {
      expect(_pageOf(AppRoutes.characterList), isA<CharacterListPage>());
    });

    test('criação de personagem', () {
      expect(
        _pageOf(AppRoutes.characterCreation),
        isA<CharacterCreationPage>(),
      );
    });

    test('exportar e importar', () {
      expect(
        _pageOf(AppRoutes.characterTransfer),
        isA<CharacterTransferPage>(),
      );
    });
  });

  group('rotas com argumento', () {
    test('ficha recebe o id do personagem', () {
      final page = _pageOf(
        AppRoutes.characterSheet,
        arguments: const CharacterIdArgs('c1'),
      );

      expect(page, isA<CharacterSheetPage>());
      expect((page as CharacterSheetPage).characterId, 'c1');
    });

    test('gerenciar magias recebe o id', () {
      final page = _pageOf(
        AppRoutes.manageSpells,
        arguments: const CharacterIdArgs('c9'),
      );

      expect((page as ManageCharacterSpellsPage).characterId, 'c9');
    });

    test('editar PV recebe os pontos de vida atuais', () {
      final character = characterFixture();
      final page = _pageOf(
        AppRoutes.editHitPoints,
        arguments: EditHitPointsArgs(
          characterId: character.id,
          hitPoints: character.hitPoints,
        ),
      );

      expect(page, isA<EditHitPointsPage>());
      expect((page as EditHitPointsPage).initialHitPoints.maximum, 10);
    });

    test('editar identidade desmonta o personagem nos campos da tela', () {
      final character = characterFixture(name: 'Vex').copyWith(
        playerName: 'Marcos',
        notes: 'Anotação',
        backgroundId: 'acolyte',
      );

      final page = _pageOf(
        AppRoutes.editIdentity,
        arguments: EditIdentityArgs(character: character),
      ) as EditIdentityPage;

      expect(page.characterId, character.id);
      expect(page.initialName, 'Vex');
      expect(page.initialPlayerName, 'Marcos');
      expect(page.initialNotes, 'Anotação');
      expect(page.initialBackgroundId, 'acolyte');
    });
  });

  group('argumento errado não derruba o app', () {
    /// Monta só a rota pedida.
    ///
    /// Com `initialRoute` o Navigator também montaria `/`, que é a lista de
    /// personagens: ela precisa de ProviderScope e abriria o banco de verdade
    /// no teste.
    Future<void> pumpRoute(
      WidgetTester tester,
      String name, {
      Object? arguments,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: AppRouter().onGenerateRoute,
          onGenerateInitialRoutes: (_) => [
            AppRouter().onGenerateRoute(
              RouteSettings(name: name, arguments: arguments),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('cai na tela de erro quando falta o argumento',
        (tester) async {
      await pumpRoute(tester, AppRoutes.characterSheet);

      expect(find.text('Erro de navegação'), findsOneWidget);
      expect(find.textContaining('esperava CharacterIdArgs'), findsOneWidget);
      expect(find.textContaining('recebeu nada'), findsOneWidget);
    });

    testWidgets('cai na tela de erro quando o tipo é outro', (tester) async {
      // Antes a ficha recebia a String crua; agora isso é rejeitado.
      await pumpRoute(tester, AppRoutes.characterSheet, arguments: 'c1');

      expect(find.text('Erro de navegação'), findsOneWidget);
      expect(find.textContaining('recebeu String'), findsOneWidget);
    });

    testWidgets('rota inexistente mostra o nome tentado', (tester) async {
      await pumpRoute(tester, '/nao/existe');

      expect(find.textContaining('/nao/existe'), findsOneWidget);
    });
  });
}
