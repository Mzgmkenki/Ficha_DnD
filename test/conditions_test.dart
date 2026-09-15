import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/active_effects.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/conditions_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

class _FakeRepository implements CharacterRepository {
  _FakeRepository(this.stored);

  Character stored;
  final List<Character> writes = [];

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Future<void> update(Character character) async {
    writes.add(character);
    stored = character;
  }

  Character? get last => writes.isEmpty ? null : writes.last;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

void main() {
  group('Condition', () {
    test('todo id é único e não vazio', () {
      final ids = Condition.values.map((item) => item.id).toSet();
      expect(ids, hasLength(Condition.values.length));
      expect(ids.any((id) => id.trim().isEmpty), isFalse);
    });

    test('toda condição tem rótulo e ao menos um efeito', () {
      for (final condition in Condition.values) {
        expect(condition.label.trim(), isNotEmpty, reason: condition.id);
        expect(condition.effects, isNotEmpty, reason: condition.id);
      }
    });

    test('fromId acha pelo id e devolve nulo para o que não existe', () {
      expect(Condition.fromId('paralyzed'), Condition.paralyzed);
      expect(Condition.fromId('inventada'), isNull);
      expect(Condition.fromId(null), isNull);
    });

    test('CSV vai e volta preservando o conjunto', () {
      const original = {Condition.paralyzed, Condition.poisoned};
      final csv = Condition.toCsv(original);

      expect(Condition.parseCsv(csv), original);
    });

    test('CSV sai na ordem do enum, não na ordem de marcação', () {
      // Duas gravações do mesmo conjunto precisam gerar a mesma string, senão
      // o banco registra mudança onde não houve.
      final a = Condition.toCsv({Condition.poisoned, Condition.blinded});
      final b = Condition.toCsv({Condition.blinded, Condition.poisoned});

      expect(a, b);
    });

    test('CSV vazio e nulo viram conjunto vazio', () {
      expect(Condition.toCsv(const {}), '');
      expect(Condition.parseCsv(''), isEmpty);
      expect(Condition.parseCsv(null), isEmpty);
    });

    test('id desconhecido no CSV é descartado sem derrubar o resto', () {
      // Cenário real: base gravada por uma versão mais nova do app.
      expect(
        Condition.parseCsv('paralyzed,teleportado,poisoned'),
        {Condition.paralyzed, Condition.poisoned},
      );
    });

    test('CSV tolera espaço sobrando', () {
      expect(Condition.parseCsv(' paralyzed , poisoned '), {
        Condition.paralyzed,
        Condition.poisoned,
      });
    });

    test('paralisado, atordoado e petrificado implicam incapacitado', () {
      for (final condition in const [
        Condition.paralyzed,
        Condition.stunned,
        Condition.petrified,
      ]) {
        expect(
          condition.implies,
          contains(Condition.incapacitated),
          reason: condition.id,
        );
      }
    });

    test('inconsciente implica incapacitado e caído', () {
      expect(Condition.unconscious.implies, {
        Condition.incapacitated,
        Condition.prone,
      });
    });

    test('expand acrescenta as implicadas sem perder as originais', () {
      expect(Condition.expand(const {Condition.unconscious}), {
        Condition.unconscious,
        Condition.incapacitated,
        Condition.prone,
      });
    });

    test('condição sem implicação não muda no expand', () {
      expect(
        Condition.expand(const {Condition.poisoned}),
        {Condition.poisoned},
      );
    });
  });

  group('ActiveEffects, exaustão', () {
    test('nível 0 não tem efeito', () {
      expect(ActiveEffects.exhaustionEffectsUpTo(0), isEmpty);
    });

    test('os efeitos acumulam do nível 1 até o atual', () {
      // O bug antigo mostrava só o efeito do nível corrente.
      final level3 = ActiveEffects.exhaustionEffectsUpTo(3);

      expect(level3, hasLength(3));
      expect(level3.first, contains('testes de atributo'));
      expect(level3[1], contains('metade'));
      expect(level3.last, contains('salvaguardas'));
    });

    test('cada nível acrescenta exatamente um efeito', () {
      for (var level = 1; level <= ActiveEffects.maxExhaustion; level++) {
        expect(
          ActiveEffects.exhaustionEffectsUpTo(level),
          hasLength(level),
          reason: 'nivel $level',
        );
      }
    });

    test('nível 6 chega em morte', () {
      expect(ActiveEffects.exhaustionEffectsUpTo(6).last, 'Morte.');
    });

    test('nível fora da faixa é limitado em vez de estourar', () {
      expect(ActiveEffects.exhaustionEffectsUpTo(42), hasLength(6));
      expect(ActiveEffects.exhaustionEffectsUpTo(-3), isEmpty);
      expect(ActiveEffects.exhaustionEffectAt(0), isNull);
      expect(ActiveEffects.exhaustionEffectAt(7), isNull);
    });
  });

  group('ActiveEffects.from', () {
    test('sem condição e sem exaustão, nada é listado', () {
      expect(
        ActiveEffects.from(conditions: const {}, exhaustion: 0),
        isEmpty,
      );
    });

    test('junta condições e exaustão na mesma lista', () {
      final result = ActiveEffects.from(
        conditions: const {Condition.poisoned},
        exhaustion: 2,
      );

      expect(result.map((item) => item.source), [
        'Envenenado',
        'Exaustão (nível 2)',
      ]);
      // A entrada da exaustão traz os dois níveis, não só o segundo.
      expect(result.last.effects, hasLength(2));
    });

    test('a condição implicada entra marcada com a origem', () {
      final result = ActiveEffects.from(
        conditions: const {Condition.paralyzed},
        exhaustion: 0,
      );

      expect(result.map((item) => item.source), ['Paralisado', 'Incapacitado']);

      final implied = result.last;
      expect(implied.isImplied, isTrue);
      expect(implied.impliedBy, 'Paralisado');
      expect(result.first.isImplied, isFalse);
    });

    test('condição marcada à mão não é duplicada pela implicação', () {
      final result = ActiveEffects.from(
        conditions: const {Condition.paralyzed, Condition.incapacitated},
        exhaustion: 0,
      );

      expect(result, hasLength(2));
      expect(result.every((item) => !item.isImplied), isTrue);
    });

    test('a ordem não depende da ordem de marcação', () {
      List<String> sources(Set<Condition> input) {
        return ActiveEffects.from(conditions: input, exhaustion: 0)
            .map((item) => item.source)
            .toList();
      }

      expect(
        sources({Condition.poisoned, Condition.blinded}),
        sources({Condition.blinded, Condition.poisoned}),
      );
    });
  });

  group('providers de condição', () {
    test('toggle marca quem não estava marcado', () async {
      final repository = _FakeRepository(characterFixture());
      final container = ProviderContainer(
        overrides: [characterRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(toggleConditionProvider)(
        repository.stored,
        Condition.stunned,
      );

      expect(repository.last!.conditions, {Condition.stunned});
    });

    test('toggle desmarca quem já estava marcado', () async {
      final repository = _FakeRepository(
        characterFixture(conditions: const {Condition.stunned}),
      );
      final container = ProviderContainer(
        overrides: [characterRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(toggleConditionProvider)(
        repository.stored,
        Condition.stunned,
      );

      expect(repository.last!.conditions, isEmpty);
    });

    test('toggle não mexe nas outras condições já marcadas', () async {
      final repository = _FakeRepository(
        characterFixture(
          conditions: const {Condition.poisoned, Condition.prone},
        ),
      );
      final container = ProviderContainer(
        overrides: [characterRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(toggleConditionProvider)(
        repository.stored,
        Condition.blinded,
      );

      expect(repository.last!.conditions, {
        Condition.poisoned,
        Condition.prone,
        Condition.blinded,
      });
    });

    test('toggle grava só o escolhido, sem a implicada', () async {
      // A implicação é derivada na leitura. Gravar Incapacitado junto faria
      // ele sobrar quando o jogador desmarcasse Paralisado.
      final repository = _FakeRepository(characterFixture());
      final container = ProviderContainer(
        overrides: [characterRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(toggleConditionProvider)(
        repository.stored,
        Condition.paralyzed,
      );

      expect(repository.last!.conditions, {Condition.paralyzed});
    });

    test('limpar remove todas de uma vez', () async {
      final repository = _FakeRepository(
        characterFixture(
          conditions: const {Condition.poisoned, Condition.prone},
        ),
      );
      final container = ProviderContainer(
        overrides: [characterRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(clearConditionsProvider)(repository.stored);

      expect(repository.last!.conditions, isEmpty);
    });
  });

  group('ConditionsPanel', () {
    Future<_FakeRepository> pumpPanel(
      WidgetTester tester,
      Character character,
    ) async {
      final repository = _FakeRepository(character);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            characterRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ConditionsPanel(character: character),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      return repository;
    }

    testWidgets('mostra um chip para cada condição', (tester) async {
      tester.view.physicalSize = const Size(1200, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpPanel(tester, characterFixture());

      expect(
        find.byType(FilterChip),
        findsNWidgets(Condition.values.length),
      );
      expect(find.text('Paralisado'), findsOneWidget);
      expect(find.text('Atordoado'), findsOneWidget);
      expect(find.text('Incapacitado'), findsOneWidget);
    });

    testWidgets('tocar o chip grava a condição', (tester) async {
      tester.view.physicalSize = const Size(1200, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final repository = await pumpPanel(tester, characterFixture());

      await tester.tap(find.widgetWithText(FilterChip, 'Envenenado'));
      await tester.pumpAndSettle();

      expect(repository.last!.conditions, {Condition.poisoned});
    });

    testWidgets('sem nada ativo, avisa em vez de deixar vazio', (tester) async {
      tester.view.physicalSize = const Size(1200, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpPanel(tester, characterFixture());

      expect(find.text('Nenhum efeito ativo.'), findsOneWidget);
      expect(find.text('Sem exaustão.'), findsOneWidget);
      // O botão de limpar só aparece quando há o que limpar.
      expect(find.text('Limpar condições'), findsNothing);
    });

    testWidgets('lista os efeitos da condição e da implicada', (tester) async {
      tester.view.physicalSize = const Size(1200, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpPanel(
        tester,
        characterFixture(conditions: const {Condition.paralyzed}),
      );

      expect(find.text('Efeitos ativos (2)'), findsOneWidget);
      expect(find.text('por Paralisado'), findsOneWidget);
      expect(
        find.text('• Não pode realizar ações nem reações.'),
        findsOneWidget,
      );
      expect(find.text('Limpar condições'), findsOneWidget);
    });

    testWidgets('exaustão mostra a escada inteira, não só o nível',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpPanel(tester, characterFixture(exhaustion: 3));

      expect(find.text('3 / 6'), findsOneWidget);
      expect(find.text('Sem exaustão.'), findsNothing);

      // Os três degraus aparecem numerados, e não apenas o terceiro.
      expect(find.text('1. Desvantagem em testes de atributo.'), findsOneWidget);
      expect(
        find.text('2. Deslocamento reduzido à metade.'),
        findsOneWidget,
      );
      expect(
        find.text('3. Desvantagem em ataques e em salvaguardas.'),
        findsOneWidget,
      );

      expect(find.text('Efeitos ativos (1)'), findsOneWidget);
    });

    testWidgets('o stepper de exaustão grava o novo nível', (tester) async {
      tester.view.physicalSize = const Size(1200, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final repository = await pumpPanel(tester, characterFixture());

      await tester.tap(find.byTooltip('Aumentar exaustão'));
      await tester.pumpAndSettle();

      expect(repository.last!.exhaustion, 1);
    });
  });
}
