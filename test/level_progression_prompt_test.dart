import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_score_improvement.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/level_progression_flow.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// A janela de escolha entre talento e Incremento no Valor de Atributo.
///
/// O que estes testes protegem é justamente o que estava quebrado: a janela
/// NÃO abria sozinha. O domínio sabia dizer quais vagas estavam em aberto e o
/// diálogo existia, mas só a seção Talentos da ficha os ligava — subir de
/// nível apenas mostrava um aviso mandando o jogador procurar a seção.
class _FakeCharacterRepository implements CharacterRepository {
  _FakeCharacterRepository(this.stored);

  Character stored;
  int updates = 0;

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Future<void> update(Character character) async {
    stored = character;
    updates++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

const _fighter = ClassEntry(
  id: 'fighter',
  name: 'Guerreiro',
  hitDie: 'd10',
  source: 'srd',
  skillOptions: [],
  savingThrows: ['strength', 'constitution'],
  featLevels: [4, 6, 8, 12, 14, 16, 19],
);

const _wizard = ClassEntry(
  id: 'wizard',
  name: 'Mago',
  hitDie: 'd6',
  source: 'srd',
  skillOptions: [],
  savingThrows: ['intelligence', 'wisdom'],
);

/// Talento sem escolha nenhuma: selecionar já deixa o diálogo completo.
const _alert = FeatEntry(id: 'alert', name: 'Alerta');

/// Hospeda a sequência de janelas sem arrastar a ficha inteira.
///
/// É de propósito: o que está sob teste é a sequência, e montar a ficha traria
/// PDF, magias e inventário para dentro de um teste que não fala deles.
class _Host extends ConsumerStatefulWidget {
  const _Host();

  @override
  ConsumerState<_Host> createState() => _HostState();
}

class _HostState extends ConsumerState<_Host> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          key: const ValueKey('run-progression'),
          onPressed:
              () => promptPendingLevelProgression(
                context: context,
                ref: ref,
                characterId: 'c1',
              ),
          child: const Text('Subir de nível'),
        ),
      ),
    );
  }
}

Future<_FakeCharacterRepository> _pumpHost(
  WidgetTester tester,
  Character character, {
  List<ClassEntry> classes = const [_fighter],
  List<FeatEntry> feats = const [_alert],
  List<RaceEntry> races = const [],
}) async {
  final repository = _FakeCharacterRepository(character);

  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterRepositoryProvider.overrideWithValue(repository),
        classEntriesProvider.overrideWith((ref) => classes),
        featEntriesProvider.overrideWith((ref) => feats),
        raceEntriesProvider.overrideWith((ref) => races),
        // O teto de atributo resolve as características de classe. Sem estes
        // três o teste iria ao bundle de assets e o `pumpAndSettle` não
        // assentava.
        classFeaturesProvider.overrideWith(
          (ref) => const <ClassFeatureEntry>[],
        ),
        subclassEntriesProvider.overrideWith((ref) => const <SubclassEntry>[]),
      ],
      child: const MaterialApp(home: _Host()),
    ),
  );
  await tester.pumpAndSettle();

  return repository;
}

Future<void> _run(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('run-progression')));
  await tester.pumpAndSettle();
}

/// Distribui +2 num atributo e confirma.
Future<void> _takeImprovement(WidgetTester tester, String ability) async {
  await tester.tap(find.byKey(const ValueKey('progression-improvement')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(ValueKey('asi-plus-$ability')));
  await tester.pump();
  await tester.tap(find.byKey(ValueKey('asi-plus-$ability')));
  await tester.pump();

  await tester.tap(find.byKey(const ValueKey('asi-confirm')));
  await tester.pumpAndSettle();
}

/// Escolhe um talento e confirma.
Future<void> _takeFeat(WidgetTester tester, String featId) async {
  await tester.tap(find.byKey(const ValueKey('progression-feat')));
  await tester.pumpAndSettle();

  final dropdown = tester.widget<DropdownButtonFormField<String>>(
    find.byKey(const ValueKey('feat-dropdown')),
  );
  dropdown.onChanged!(featId);
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('abre sozinha no nível que concede a escolha', (tester) async {
    await _pumpHost(
      tester,
      characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
      ),
    );

    await _run(tester);

    // Classe e nível no título: num multiclasse é o que diz de qual pendência
    // se trata.
    expect(find.text('Guerreiro — nível 4'), findsOneWidget);
    expect(find.text('Incremento no Valor de Atributo'), findsOneWidget);
    expect(find.text('Talento'), findsOneWidget);
  });

  testWidgets('nível sem a escolha não abre janela nenhuma', (tester) async {
    await _pumpHost(
      tester,
      characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
      ),
    );

    await _run(tester);

    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: 'quem decide é a vaga em aberto, não uma lista fixa de níveis',
    );
  });

  testWidgets('escolha já registrada não reabre a janela', (tester) async {
    await _pumpHost(
      tester,
      characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
      ).copyWith(
        abilityImprovements: const [
          AbilityScoreImprovement(
            localId: 1,
            classId: 'fighter',
            classLevel: 4,
            appliedIncreases: {'strength': 2},
          ),
        ],
      ),
    );

    await _run(tester);

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('ficha antiga com talento já escolhido não reabre', (
    tester,
  ) async {
    // O talento antigo foi gravado com o nível TOTAL do personagem. Sem a
    // associação por vaga, a ficha ofereceria de novo uma escolha já gasta.
    await _pumpHost(
      tester,
      characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
        feats: const [
          CharacterFeat(
            localId: 1,
            featId: 'alert',
            classId: 'fighter',
            level: 4,
          ),
        ],
      ),
    );

    await _run(tester);

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('o incremento grava a classe e o nível DA CLASSE', (
    tester,
  ) async {
    final repository = await _pumpHost(
      tester,
      characterFixture(
        abilityScores: scoresWith(strength: 14),
        classLevels: const [
          ClassLevel(classId: 'fighter', level: 4),
          ClassLevel(classId: 'wizard', level: 2),
        ],
      ),
      classes: const [_fighter, _wizard],
    );

    await _run(tester);
    await _takeImprovement(tester, 'strength');

    final improvement = repository.stored.abilityImprovements.single;

    expect(improvement.classId, 'fighter');
    expect(
      improvement.classLevel,
      4,
      reason: 'nível total é 6; usar o total não corresponderia a vaga alguma',
    );
    expect(improvement.appliedIncreases, {'strength': 2});
    expect(repository.stored.abilityScores.strength, 16);
  });

  testWidgets('o talento também grava a vaga, e não o nível total', (
    tester,
  ) async {
    final repository = await _pumpHost(
      tester,
      characterFixture(
        classLevels: const [
          ClassLevel(classId: 'fighter', level: 4),
          ClassLevel(classId: 'wizard', level: 2),
        ],
      ),
      classes: const [_fighter, _wizard],
    );

    await _run(tester);
    await _takeFeat(tester, 'alert');

    final feat = repository.stored.feats.single;

    expect(feat.featId, 'alert');
    expect(feat.classId, 'fighter');
    expect(feat.level, 4);
    expect(
      repository.stored.abilityImprovements,
      isEmpty,
      reason:
          'o talento não pode virar um incremento de mentira, nem o inverso',
    );
  });

  testWidgets('duas pendências vêm em sequência, uma por vez', (tester) async {
    final repository = await _pumpHost(
      tester,
      characterFixture(
        abilityScores: scoresWith(strength: 12, constitution: 12),
        classLevels: const [ClassLevel(classId: 'fighter', level: 6)],
      ),
    );

    await _run(tester);

    expect(find.text('Guerreiro — nível 4'), findsOneWidget);
    expect(find.text('Guerreiro — nível 6'), findsNothing);

    await _takeImprovement(tester, 'strength');

    // A segunda janela abre sozinha depois de a primeira ser gravada.
    expect(find.text('Guerreiro — nível 6'), findsOneWidget);

    await _takeImprovement(tester, 'constitution');

    expect(find.byType(AlertDialog), findsNothing);
    expect(repository.stored.abilityImprovements, hasLength(2));
    expect(
      repository.stored.abilityImprovements.map((item) => item.classLevel),
      [4, 6],
    );
  });

  testWidgets('"Decidir depois" não aplica nada e encerra a sequência', (
    tester,
  ) async {
    final repository = await _pumpHost(
      tester,
      characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 6)],
      ),
    );

    await _run(tester);
    await tester.tap(find.text('Decidir depois'));
    await tester.pumpAndSettle();

    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: 'insistir prenderia o jogador num laço de janelas',
    );
    expect(repository.stored.abilityImprovements, isEmpty);
    expect(repository.stored.feats, isEmpty);
    expect(repository.updates, 0, reason: 'nem escolha parcial foi gravada');
  });

  testWidgets('cancelar a distribuição mantém a vaga em aberto', (
    tester,
  ) async {
    final repository = await _pumpHost(
      tester,
      characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
      ),
    );

    await _run(tester);
    await tester.tap(find.byKey(const ValueKey('progression-improvement')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('asi-plus-strength')));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();

    expect(repository.updates, 0);
    expect(repository.stored.abilityImprovements, isEmpty);

    // E a escolha volta a ser oferecida na próxima tentativa de concluir.
    await _run(tester);
    expect(find.text('Guerreiro — nível 4'), findsOneWidget);
  });

  testWidgets('a vaga da raça oferece talento, mas não incremento', (
    tester,
  ) async {
    await _pumpHost(
      tester,
      characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        speciesId: 'human_variant',
      ),
      races: const [
        RaceEntry(
          id: 'human_variant',
          name: 'Humano Variante',
          source: 'phb',
          grantsFeat: true,
        ),
      ],
    );

    await _run(tester);

    expect(find.byKey(const ValueKey('progression-feat')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('progression-improvement')),
      findsNothing,
      reason: 'o Humano Variante ganha um TALENTO, não a troca por atributo',
    );
  });
}
