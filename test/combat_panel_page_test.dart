import 'dart:async';

import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/combat_panel_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/combat_panel_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/combat_actions_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/conditions_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/rest_and_resources_panel.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Repositório que serve o personagem por stream, como o banco faz.
///
/// `watchById` é o que o `characterByIdProvider` consome, então a gravação feita
/// no painel tem que reaparecer pelo mesmo caminho — é isso que faz a ficha e o
/// painel ficarem em sincronia sem ninguém avisar ninguém.
class _FakeRepository implements CharacterRepository {
  _FakeRepository(this.stored);

  Character stored;
  final List<Character> writes = [];
  final _changes = StreamController<Character?>.broadcast();

  Character? get last => writes.isEmpty ? null : writes.last;

  @override
  Stream<Character?> watchById(String id) async* {
    // O valor atual na frente e as alterações depois, como um stream de banco.
    yield stored;
    yield* _changes.stream;
  }

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Future<void> update(Character character) async {
    writes.add(character);
    stored = character;
    _changes.add(character);
  }

  void dispose() => _changes.close();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

/// Repositório que não acha o personagem, para o caminho de erro.
class _MissingRepository implements CharacterRepository {
  @override
  Stream<Character?> watchById(String id) => Stream<Character?>.value(null);

  @override
  Future<Character?> findById(String id) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

void main() {
  const fighter = ClassEntry(
    id: 'fighter',
    name: 'Guerreiro',
    hitDie: 'd10',
    source: 'srd',
    skillOptions: [],
    savingThrows: ['strength', 'constitution'],
  );

  /// O indicador numérico fica dentro do rótulo da aba. Procurar o número solto
  /// na tela inteira pegaria qualquer outro "1" ou "2" do painel.
  Finder tabBadge(String count) => find.descendant(
        of: find.byType(TabBar),
        matching: find.text(count),
      );

  /// Monta o painel com compêndio vazio.
  ///
  /// Vazio de propósito: a aba Ações cai nas opções universais, que não
  /// dependem de asset nenhum, e o teste não fica lendo JSON do disco.
  Future<_FakeRepository> pumpPanel(
    WidgetTester tester,
    Character character, {
    CombatPanelTabMemory? memory,
  }) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeRepository(character);
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          characterRepositoryProvider.overrideWithValue(repository),
          classEntriesProvider.overrideWith((ref) => <ClassEntry>[fighter]),
          classFeaturesProvider.overrideWith((ref) => <ClassFeatureEntry>[]),
          subclassEntriesProvider.overrideWith((ref) => <SubclassEntry>[]),
          spellEntriesProvider.overrideWith((ref) => <SpellEntry>[]),
          if (memory != null)
            combatPanelTabProvider.overrideWith((ref) => memory),
        ],
        child: MaterialApp(
          // Empilhado sobre uma rota qualquer, e não como `home`: na vida real
          // o painel é empurrado por cima da ficha, e é isso que faz o
          // `AppBar` ganhar o botão de voltar.
          onGenerateRoute: (_) => null,
          onGenerateInitialRoutes: (_) => [
            MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('ficha')),
            ),
            MaterialPageRoute<void>(
              builder: (_) => const CombatPanelPage(characterId: 'c1'),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    return repository;
  }

  group('estrutura', () {
    testWidgets('tem título, nome do personagem e três abas', (tester) async {
      await pumpPanel(tester, characterFixture(name: 'Bruenor'));

      expect(find.text('Painel de combate'), findsOneWidget);
      expect(find.text('Bruenor'), findsOneWidget);

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Ações'), findsOneWidget);
      expect(find.text('Condições'), findsOneWidget);
      expect(find.text('Recursos'), findsOneWidget);
    });

    testWidgets('abre na aba Ações e mostra as opções universais',
        (tester) async {
      await pumpPanel(tester, characterFixture());

      expect(find.byType(CombatActionsPanel), findsOneWidget);
      expect(find.text('Atacar'), findsOneWidget);
      expect(find.text('Esquivar'), findsOneWidget);
    });

    testWidgets('tem botão de voltar para a ficha', (tester) async {
      await pumpPanel(tester, characterFixture());

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('personagem inexistente avisa em vez de quebrar',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            characterRepositoryProvider.overrideWithValue(_MissingRepository()),
            classEntriesProvider.overrideWith((ref) => <ClassEntry>[]),
          ],
          child: const MaterialApp(
            home: CombatPanelPage(characterId: 'inexistente'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Personagem não encontrado.'), findsOneWidget);
      // As abas continuam na tela: sem personagem elas ficam vazias, mas a
      // barra desaparecendo faria a tela parecer outra.
      expect(find.byType(TabBar), findsOneWidget);
    });
  });

  group('navegação entre abas', () {
    testWidgets('trocar de aba mostra o painel daquela aba', (tester) async {
      await pumpPanel(tester, characterFixture());

      expect(find.byType(ConditionsPanel), findsNothing);

      await tester.tap(find.text('Condições'));
      await tester.pumpAndSettle();

      expect(find.byType(ConditionsPanel), findsOneWidget);

      await tester.tap(find.text('Recursos'));
      await tester.pumpAndSettle();

      expect(find.byType(RestAndResourcesPanel), findsOneWidget);
      expect(find.text('Descanso curto'), findsOneWidget);
      expect(find.text('Descanso longo'), findsOneWidget);
    });

    testWidgets('trocar de aba não grava nada no personagem', (tester) async {
      // O requisito é explícito: navegar não pode consumir recurso nem
      // desmarcar condição.
      final repository = await pumpPanel(
        tester,
        characterFixture(conditions: const {Condition.poisoned}),
      );

      await tester.tap(find.text('Condições'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recursos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ações'));
      await tester.pumpAndSettle();

      expect(repository.writes, isEmpty);
      expect(repository.stored.conditions, {Condition.poisoned});
      expect(repository.stored.hitDiceUsed, 0);
    });

    testWidgets('o que estava aberto em Ações continua aberto na volta',
        (tester) async {
      // É o que o `AutomaticKeepAliveClientMixin` garante: sem ele o
      // `TabBarView` descarta a aba que sai de tela e o detalhe volta fechado.
      await pumpPanel(tester, characterFixture());

      expect(find.text('PHB, cap. 9'), findsNothing);

      await tester.tap(find.text('Atacar'));
      await tester.pumpAndSettle();

      expect(find.text('PHB, cap. 9'), findsWidgets);

      await tester.tap(find.text('Condições'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ações'));
      await tester.pumpAndSettle();

      // Ainda expandido: o detalhe da opção continua na árvore.
      expect(find.text('PHB, cap. 9'), findsWidgets);
    });

    testWidgets('guarda a aba aberta para a próxima vez', (tester) async {
      final memory = CombatPanelTabMemory();
      await pumpPanel(tester, characterFixture(), memory: memory);

      await tester.tap(find.text('Recursos'));
      await tester.pumpAndSettle();

      expect(memory.index, 2);
    });

    testWidgets('restaura a última aba da sessão ao reabrir', (tester) async {
      await pumpPanel(
        tester,
        characterFixture(),
        memory: CombatPanelTabMemory()..remember(1),
      );

      expect(find.byType(ConditionsPanel), findsOneWidget);
      expect(find.byType(CombatActionsPanel), findsNothing);
    });

    testWidgets('índice guardado fora da faixa não quebra o painel',
        (tester) async {
      // Defesa contra o painel perder uma aba numa versão futura com o índice
      // antigo ainda em memória.
      final memory = CombatPanelTabMemory()..remember(99);

      await pumpPanel(tester, characterFixture(), memory: memory);

      expect(find.byType(CombatActionsPanel), findsOneWidget);
    });
  });

  group('indicador de condições ativas', () {
    testWidgets('sem condição, a aba não mostra contagem', (tester) async {
      await pumpPanel(tester, characterFixture());

      expect(tabBadge('1'), findsNothing);
      expect(tabBadge('2'), findsNothing);
    });

    testWidgets('com condições, a aba mostra quantas', (tester) async {
      await pumpPanel(
        tester,
        characterFixture(
          conditions: const {Condition.poisoned, Condition.prone},
        ),
      );

      expect(tabBadge('2'), findsOneWidget);
    });

    testWidgets('a exaustão também conta no indicador', (tester) async {
      await pumpPanel(tester, characterFixture(exhaustion: 3));

      expect(tabBadge('1'), findsOneWidget);
    });

    testWidgets('o indicador é anunciado junto com o rótulo da aba',
        (tester) async {
      // Não depende de cor: o leitor de tela recebe "Condições, 2 ativas".
      // `RegExp` porque o `TabBar` prefixa o nó com a posição da aba.
      final handle = tester.ensureSemantics();

      await pumpPanel(
        tester,
        characterFixture(
          conditions: const {Condition.poisoned, Condition.prone},
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp('Condições, 2 ativas')),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('recurso gasto aparece no indicador da aba Recursos',
        (tester) async {
      final handle = tester.ensureSemantics();

      await pumpPanel(
        tester,
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
          hitDiceUsed: 1,
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp('Recursos, 1 gasto')),
        findsOneWidget,
      );
      expect(tabBadge('1'), findsOneWidget);

      handle.dispose();
    });
  });

  group('reflexo imediato da mudança', () {
    testWidgets('marcar condição atualiza o indicador da aba', (tester) async {
      final repository = await pumpPanel(tester, characterFixture());

      await tester.tap(find.text('Condições'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, 'Envenenado'));
      await tester.pumpAndSettle();

      expect(repository.last!.conditions, {Condition.poisoned});
      // O indicador vem do mesmo estado, então aparece sem ninguém recarregar.
      expect(tabBadge('1'), findsOneWidget);
    });
  });
}
