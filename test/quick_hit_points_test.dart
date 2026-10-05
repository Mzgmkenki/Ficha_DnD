import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/theme/app_theme.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/combat_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

class _Repository implements CharacterRepository {
  _Repository(this.stored);

  Character stored;

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Future<void> update(Character character) async => stored = character;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

Future<void> _pump(WidgetTester tester, _Repository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [characterRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: CombatSummaryCard(character: repository.stored)),
      ),
    ),
  );
  await tester.pump();
}

IconButton _button(WidgetTester tester, IconData icon) {
  return tester.widget<IconButton>(find.widgetWithIcon(IconButton, icon));
}

void main() {
  testWidgets('dano rápido consome PV temporários e persiste', (tester) async {
    final repository = _Repository(
      characterFixture(
        hitPoints: const HitPoints(current: 8, maximum: 10, temporary: 2),
      ),
    );
    await _pump(tester, repository);

    expect(find.text('PV: 8/10'), findsOneWidget);
    expect(find.text('PV temporários: 2'), findsOneWidget);
    await tester.tap(find.widgetWithIcon(IconButton, Icons.remove));
    await tester.pump();

    expect(repository.stored.hitPoints.current, 8);
    expect(repository.stored.hitPoints.temporary, 1);

    // Reabrir a ficha usa o valor persistido no repositório.
    await _pump(tester, repository);
    expect(find.text('PV temporários: 1'), findsOneWidget);
  });

  testWidgets('cura rápida aumenta só PV atuais e persiste', (tester) async {
    final repository = _Repository(
      characterFixture(
        hitPoints: const HitPoints(current: 8, maximum: 10, temporary: 3),
      ),
    );
    await _pump(tester, repository);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
    await tester.pump();

    expect(repository.stored.hitPoints.current, 9);
    expect(repository.stored.hitPoints.temporary, 3);
  });

  testWidgets('desabilita dano em zero e cura no máximo', (tester) async {
    final zero = _Repository(
      characterFixture(hitPoints: const HitPoints(current: 0, maximum: 10)),
    );
    await _pump(tester, zero);
    expect(_button(tester, Icons.remove).onPressed, isNull);
    expect(_button(tester, Icons.add).onPressed, isNotNull);

    final full = _Repository(
      characterFixture(hitPoints: const HitPoints(current: 10, maximum: 10)),
    );
    await _pump(tester, full);
    expect(_button(tester, Icons.remove).onPressed, isNotNull);
    expect(_button(tester, Icons.add).onPressed, isNull);
  });

  testWidgets('permite dano em zero quando ainda há PV temporários', (
    tester,
  ) async {
    final repository = _Repository(
      characterFixture(
        hitPoints: const HitPoints(current: 0, maximum: 10, temporary: 1),
      ),
    );
    await _pump(tester, repository);

    expect(_button(tester, Icons.remove).onPressed, isNotNull);
    await tester.tap(find.widgetWithIcon(IconButton, Icons.remove));
    await tester.pump();
    expect(repository.stored.hitPoints.current, 0);
    expect(repository.stored.hitPoints.temporary, 0);
  });
}
