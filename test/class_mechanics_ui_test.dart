import 'dart:async';

import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_class_mechanic.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feature_state.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/manage_class_mechanic_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/mechanic_table_view.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/class_mechanics_panel.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_mechanic_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_prerequisite.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_table.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Testes de interface dos recursos de classe.
///
/// Rodam numa viewport de celular (360x760 lógicos) de propósito: as telas
/// ganharam listas longas e tabelas largas, e estouro de layout em tela
/// pequena é o tipo de defeito que só aparece no tamanho real.
const Size _phone = Size(360, 760);

void main() {
  group('painel da ficha', () {
    testWidgets('a mecânica aparece fechada, com o resumo e a pendência', (
      tester,
    ) async {
      await _pumpPanel(tester, character: _fighter(level: 3));

      expect(find.byKey(const ValueKey('mechanic-header-$_runesId')), findsOne);
      expect(
        find.byKey(const ValueKey('mechanic-summary-$_runesId')),
        findsOne,
      );
      expect(find.text('0 de 2 conhecidas'), findsOne);
      expect(find.byKey(const ValueKey('mechanic-badge-$_runesId')), findsOne);
      expect(find.text('2 escolhas pendentes'), findsOne);
      expect(find.byKey(const ValueKey('class-mechanics-pending')), findsOne);

      // Fechada: o botão de gerenciar e as opções só aparecem ao abrir.
      expect(
        find.byKey(const ValueKey('mechanic-manage-$_runesId')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('abrir mostra as opções conhecidas e o controle de modo', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        character: _fighter(
          level: 3,
          mechanics: const [
            CharacterClassMechanic(
              mechanicId: _runesId,
              optionId: 'cloud',
              chosenAtLevel: 3,
            ),
          ],
        ),
      );

      await _tap(tester, const ValueKey('mechanic-header-$_runesId'));

      expect(
        find.byKey(const ValueKey('mechanic-option-$_runesId-cloud')),
        findsOne,
      );
      expect(find.byKey(const ValueKey('mechanic-manage-$_runesId')), findsOne);
      expect(tester.takeException(), isNull);
    });

    testWidgets('o modo tem interruptor e o resumo diz que está ligado', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        character: _fighter(
          level: 3,
          featureStates: [
            CharacterFeatureState(
              featureId: ClassMechanicEntry.mechanicFeatureId(
                _modesId,
                'archer',
              ),
              isActive: true,
            ),
          ],
        ),
      );

      expect(find.textContaining('ativo: Arqueiro'), findsOne);

      await _tap(tester, const ValueKey('mechanic-header-$_modesId'));

      const switchKey = ValueKey('mechanic-mode-$_modesId-archer');
      expect(find.byKey(switchKey), findsOne);
      expect(tester.widget<Switch>(find.byKey(switchKey)).value, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tabela abre numa folha, sem crescer a ficha', (
      tester,
    ) async {
      await _pumpPanel(tester, character: _fighter(level: 3));

      await _tap(tester, const ValueKey('mechanic-header-$_rollId'));

      expect(find.byType(MechanicTableView), findsNothing);

      await _tap(tester, const ValueKey('mechanic-table-button-$_rollId'));

      expect(find.byType(MechanicTableView), findsOne);
      expect(find.text('Surto (d100)'), findsOne);
      expect(tester.takeException(), isNull);
    });

    testWidgets('personagem sem mecânica vê a mensagem de vazio', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
      );

      expect(find.byKey(const ValueKey('class-mechanics-empty')), findsOne);
      expect(tester.takeException(), isNull);
    });
  });

  group('tela de gerenciamento', () {
    testWidgets('mostra a contagem, as vagas e as opções', (tester) async {
      await _pumpManage(tester, character: _fighter(level: 3));

      expect(find.byKey(const ValueKey('manage-mechanic-count')), findsOne);
      expect(find.text('0 de 2 conhecidas'), findsOne);
      expect(
        find.byKey(const ValueKey('manage-mechanic-free-slots')),
        findsOne,
      );
      expect(find.text('Novas escolhas disponíveis: 2'), findsOne);

      // As opções saem em ordem alfabética do nome em português, e não na
      // ordem do asset. "Céu" é a primeira, então é ela que está visível sem
      // rolar — no asset a primeira era "Nuvem".
      expect(find.byKey(const ValueKey('manage-option-sky')), findsOne);

      // "Nuvem" continua lá, agora na sexta posição: a lista é construída por
      // demanda, então ela só existe depois de rolar até perto dela.
      await _reveal(tester, const ValueKey('manage-option-cloud'));
      expect(find.byKey(const ValueKey('manage-option-cloud')), findsOne);

      expect(tester.takeException(), isNull);
    });

    testWidgets('a opção bloqueada fica visível com o motivo e sem botão', (
      tester,
    ) async {
      await _pumpManage(tester, character: _fighter(level: 3));

      await _reveal(tester, const ValueKey('manage-option-hill'));

      expect(find.byKey(const ValueKey('manage-option-hill')), findsOne);
      expect(
        find.byKey(const ValueKey('manage-option-block-hill-class_level')),
        findsOne,
      );
      // Duas opções exigem o 7º nível, então a frase aparece mais de uma vez.
      expect(find.text('Requer nível 7 nesta classe.'), findsWidgets);
      expect(
        tester
            .widget<Text>(
              find.byKey(
                const ValueKey('manage-option-block-hill-class_level'),
              ),
            )
            .data,
        'Requer nível 7 nesta classe.',
      );

      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('manage-option-select-hill')),
      );
      expect(button.onPressed, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('escolher grava e a contagem muda', (tester) async {
      final repository = _FakeCharacterRepository(_fighter(level: 3));

      await _pumpManage(tester, repository: repository);

      await _tap(tester, const ValueKey('manage-option-select-cloud'));

      expect(repository.stored.classMechanics, hasLength(1));
      expect(repository.stored.classMechanics.single.optionId, 'cloud');
      expect(find.text('Nuvem escolhida.'), findsOne);
      expect(tester.takeException(), isNull);
    });

    testWidgets('o limite recusa a escolha e explica', (tester) async {
      final repository = _FakeCharacterRepository(
        _fighter(
          level: 3,
          mechanics: const [
            CharacterClassMechanic(
              mechanicId: _runesId,
              optionId: 'cloud',
              chosenAtLevel: 3,
            ),
            CharacterClassMechanic(
              mechanicId: _runesId,
              optionId: 'stone',
              chosenAtLevel: 3,
            ),
          ],
        ),
      );

      await _pumpManage(tester, repository: repository);

      // Sem vaga, o botão de escolher fica desabilitado.
      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('manage-option-select-frost')),
      );
      expect(button.onPressed, isNull);

      expect(find.text('2 de 2 conhecidas'), findsOne);
      expect(
        find.byKey(const ValueKey('manage-mechanic-free-slots')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a substituição acontece em dois passos', (tester) async {
      final repository = _FakeCharacterRepository(
        _fighter(
          level: 3,
          mechanics: const [
            CharacterClassMechanic(
              mechanicId: _runesId,
              optionId: 'cloud',
              chosenAtLevel: 3,
            ),
            CharacterClassMechanic(
              mechanicId: _runesId,
              optionId: 'stone',
              chosenAtLevel: 3,
            ),
          ],
        ),
      );

      await _pumpManage(tester, repository: repository);

      await _tap(tester, const ValueKey('manage-option-start-replace-cloud'));

      // O aviso fica no topo da lista; depois de rolar até o botão ele saiu
      // de tela, então a lista é trazida de volta antes de conferir.
      await _reveal(
        tester,
        const ValueKey('manage-mechanic-replacing'),
        delta: -120,
      );

      expect(find.byKey(const ValueKey('manage-mechanic-replacing')), findsOne);

      await _tap(tester, const ValueKey('manage-option-replace-frost'));

      final records = repository.stored.classMechanics;
      expect(
        records.map((item) => item.optionId),
        containsAll(['stone', 'frost']),
      );
      expect(
        records.firstWhere((item) => item.optionId == 'frost').replacedOptionId,
        'cloud',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a mecânica sem substituição não oferece o botão', (
      tester,
    ) async {
      await _pumpManage(
        tester,
        character: _fighter(
          level: 3,
          mechanics: const [
            CharacterClassMechanic(
              mechanicId: _fixedId,
              optionId: 'black',
              chosenAtLevel: 3,
            ),
          ],
        ),
        mechanicId: _fixedId,
      );

      expect(find.byKey(const ValueKey('manage-option-black')), findsOne);
      expect(
        find.byKey(const ValueKey('manage-option-start-replace-black')),
        findsNothing,
      );
      expect(
        find.textContaining(
          'As escolhas são permanentes: a regra não permite trocá-las.',
        ),
        findsOne,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tabela de consulta não oferece rolagem nem registro', (
      tester,
    ) async {
      await _pumpManage(
        tester,
        character: _fighter(level: 3),
        mechanicId: _tableId,
      );

      expect(
        find.byKey(const ValueKey('manage-mechanic-open-table')),
        findsOne,
      );
      expect(find.byKey(const ValueKey('manage-mechanic-roll')), findsNothing);
      expect(
        find.byKey(const ValueKey('manage-mechanic-pick-row')),
        findsNothing,
      );
      expect(
        find.textContaining('Tabela de consulta: as linhas não viram escolha.'),
        findsOne,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tabela de rolagem registra o resultado informado', (
      tester,
    ) async {
      final repository = _FakeCharacterRepository(_fighter(level: 3));

      await _pumpManage(tester, repository: repository, mechanicId: _rollId);

      await _tap(tester, const ValueKey('manage-mechanic-pick-row'));
      await _tap(tester, const ValueKey('mechanic-table-row-mid'));

      final record = repository.stored.classMechanics.single;
      expect(record.rollResult, 'mid');
      expect(record.countsAsPick, isFalse);
      expect(
        find.byKey(const ValueKey('manage-mechanic-roll-result')),
        findsOne,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('o contador de usos tem os dois botões e o número', (
      tester,
    ) async {
      await _pumpManage(
        tester,
        character: _fighter(level: 3),
        mechanicId: _diceId,
      );

      final featureId = ClassMechanicEntry.mechanicFeatureId(_diceId);

      expect(find.byKey(ValueKey('mechanic-uses-$featureId')), findsOne);
      expect(find.text('4 de 4'), findsOne);

      // Cheio: devolver fica desabilitado e gastar fica ativo.
      final restore = tester.widget<IconButton>(
        find.byKey(ValueKey('mechanic-restore-$featureId')),
      );
      final spend = tester.widget<IconButton>(
        find.byKey(ValueKey('mechanic-spend-$featureId')),
      );

      expect(restore.onPressed, isNull);
      expect(spend.onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('gastar um uso grava o contador', (tester) async {
      final repository = _FakeCharacterRepository(_fighter(level: 3));
      final featureId = ClassMechanicEntry.mechanicFeatureId(_diceId);

      await _pumpManage(tester, repository: repository, mechanicId: _diceId);

      await _tap(tester, ValueKey('mechanic-spend-$featureId'));

      expect(repository.stored.featureStateFor(featureId)?.usesSpent, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a busca filtra a lista de opções longas', (tester) async {
      await _pumpManage(tester, character: _fighter(level: 7));

      expect(find.byKey(const ValueKey('manage-mechanic-search')), findsOne);

      await tester.enterText(
        find.byKey(const ValueKey('manage-mechanic-search')),
        'nuvem',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('manage-option-cloud')), findsOne);
      expect(find.byKey(const ValueKey('manage-option-stone')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mecânica que o personagem não tem mostra a mensagem', (
      tester,
    ) async {
      await _pumpManage(
        tester,
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
      );

      expect(
        find.textContaining('não está disponível para este personagem'),
        findsOne,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('visualizador de tabela', () {
    testWidgets('a tabela larga rola na horizontal sem estourar', (
      tester,
    ) async {
      await _pumpTable(tester, table: _wideTable);

      expect(find.byType(DataTable), findsOne);
      expect(
        find.descendant(
          of: find.byType(MechanicTableView),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOne,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tabela longa mostra a busca e filtra', (tester) async {
      await _pumpTable(tester, table: _longTable);

      expect(find.byKey(const ValueKey('mechanic-table-search')), findsOne);

      await tester.enterText(
        find.byKey(const ValueKey('mechanic-table-search')),
        'linha 7',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('mechanic-table-row-7')), findsOne);
      expect(find.byKey(const ValueKey('mechanic-table-row-1')), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('mechanic-table-search')),
        'inexistente',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('mechanic-table-empty')), findsOne);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tabela curta não mostra a busca', (tester) async {
      await _pumpTable(tester, table: _wideTable);

      expect(find.byKey(const ValueKey('mechanic-table-search')), findsNothing);
    });

    testWidgets('a linha destacada é marcada por cor e por ícone', (
      tester,
    ) async {
      await _pumpTable(tester, table: _longTable, highlightedRowId: '3');

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('mechanic-table-row-3')),
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOne,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Infraestrutura
// ---------------------------------------------------------------------------

/// Repositório falso que REEMITE depois de gravar.
///
/// O stream importa: a tela lê `characterByIdProvider`, que é um
/// `StreamProvider`. Um `Stream.value` responderia a primeira leitura e nunca
/// mais, e a tela ficaria mostrando o estado anterior depois de cada escrita —
/// que é justamente o que estes testes precisam verificar.
class _FakeCharacterRepository implements CharacterRepository {
  _FakeCharacterRepository(this.stored);

  Character stored;

  final StreamController<Character?> _changes =
      StreamController<Character?>.broadcast();

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Stream<Character?> watchById(String id) async* {
    yield stored;
    yield* _changes.stream;
  }

  @override
  Future<void> update(Character character) async {
    stored = character;
    _changes.add(character);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

void _configureView(WidgetTester tester) {
  tester.view.physicalSize = _phone;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Rola até o alvo e toca nele.
///
/// Numa viewport de celular a maior parte das listas nasce fora de tela, e um
/// `tap` direto bateria no vazio — é o aviso de "would not hit test" do
/// `flutter_test`. As listas usadas aqui são `ListView(children:)` e
/// `SingleChildScrollView`, que constroem tudo, então `ensureVisible` basta.
Future<void> _tap(WidgetTester tester, Key key) async {
  await _reveal(tester, key);

  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

/// Rola a lista até o alvo existir e estar na tela.
///
/// `ensureVisible` sozinho não resolve: a `ListView` da tela de gerenciamento
/// não cria os elementos das opções que estão fora da viewport, e o `finder`
/// devolve zero antes de a rolagem acontecer. O `scrollable` é informado
/// explicitamente porque um `TextField` também é `Scrollable`, e o padrão de
/// `scrollUntilVisible` exige um único.
/// [delta] negativo rola de volta para o topo, que é o que o aviso de
/// substituição exige depois de a lista ter descido até o botão.
Future<void> _reveal(WidgetTester tester, Key key, {double delta = 120}) async {
  final finder = find.byKey(key);

  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  required Character character,
}) async {
  _configureView(tester);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterRepositoryProvider.overrideWithValue(
          _FakeCharacterRepository(character),
        ),
        classMechanicEntriesProvider.overrideWith((ref) => _entries),
        classEntriesProvider.overrideWith((ref) => _classes),
        subclassEntriesProvider.overrideWith((ref) => _subclasses),
        spellEntriesProvider.overrideWith((ref) => const <SpellEntry>[]),
        classFeaturesProvider.overrideWith(
          (ref) => const <ClassFeatureEntry>[],
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ClassMechanicsPanel(character: character),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> _pumpManage(
  WidgetTester tester, {
  Character? character,
  _FakeCharacterRepository? repository,
  String mechanicId = _runesId,
}) async {
  _configureView(tester);

  final store = repository ?? _FakeCharacterRepository(character!);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterRepositoryProvider.overrideWithValue(store),
        classMechanicEntriesProvider.overrideWith((ref) => _entries),
        classEntriesProvider.overrideWith((ref) => _classes),
        subclassEntriesProvider.overrideWith((ref) => _subclasses),
        spellEntriesProvider.overrideWith((ref) => const <SpellEntry>[]),
        classFeaturesProvider.overrideWith(
          (ref) => const <ClassFeatureEntry>[],
        ),
      ],
      child: MaterialApp(
        home: ManageClassMechanicPage(
          characterId: store.stored.id,
          mechanicId: mechanicId,
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> _pumpTable(
  WidgetTester tester, {
  required MechanicTable table,
  String? highlightedRowId,
}) async {
  _configureView(tester);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MechanicTableView(
            table: table,
            highlightedRowId: highlightedRowId,
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Catálogo de teste
// ---------------------------------------------------------------------------

const String _runesId = 'fighter_rune_knight.runes';
const String _diceId = 'fighter_rune_knight.dice';
const String _modesId = 'fighter_rune_knight.modes';
const String _tableId = 'fighter_rune_knight.aura';
const String _rollId = 'fighter_rune_knight.surge';
const String _fixedId = 'fighter_rune_knight.fixed';

const ClassMechanicEntry _runes = ClassMechanicEntry(
  id: _runesId,
  name: 'Runas',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'tce',
  kinds: {ClassMechanicKind.knownList},
  replacement: MechanicReplacement(trigger: MechanicReplacementTrigger.levelUp),
  progression: [
    MechanicProgressionStep(level: 3, picks: 2),
    MechanicProgressionStep(level: 7, picks: 3),
  ],
  options: [
    MechanicOption(id: 'cloud', name: 'Nuvem', description: 'Redireciona.'),
    MechanicOption(
      id: 'fire',
      name: 'Fogo',
      description: 'Queima.',
      incompatibleWith: ['frost'],
    ),
    MechanicOption(
      id: 'frost',
      name: 'Gelo',
      description: 'Congela.',
      incompatibleWith: ['fire'],
    ),
    MechanicOption(id: 'stone', name: 'Pedra', description: 'Enfeitiça.'),
    MechanicOption(
      id: 'hill',
      name: 'Colina',
      description: 'Resiste.',
      prerequisites: MechanicPrerequisite(classLevel: 7),
    ),
    MechanicOption(
      id: 'storm',
      name: 'Tempestade',
      description: 'Prevê.',
      prerequisites: MechanicPrerequisite(classLevel: 7),
    ),
    MechanicOption(id: 'sea', name: 'Mar', description: 'Afoga.'),
    MechanicOption(id: 'sky', name: 'Céu', description: 'Voa.'),
  ],
);

const ClassMechanicEntry _dice = ClassMechanicEntry(
  id: _diceId,
  name: 'Dados de Superioridade',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'tce',
  kinds: {ClassMechanicKind.limitedResource},
  action: FeatureAction(
    type: CombatActionType.special,
    uses: 4,
    recharge: ActionRecharge.shortRest,
  ),
);

const ClassMechanicEntry _modes = ClassMechanicEntry(
  id: _modesId,
  name: 'Forma Estelar',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'tce',
  kinds: {ClassMechanicKind.activatableMode},
  maxActiveOptions: 1,
  options: [
    MechanicOption(
      id: 'archer',
      name: 'Arqueiro',
      description: 'Atira.',
      isMode: true,
    ),
    MechanicOption(
      id: 'chalice',
      name: 'Cálice',
      description: 'Cura.',
      isMode: true,
    ),
  ],
);

const MechanicTable _wideTable = MechanicTable(
  id: 'aura.table',
  title: 'Aura por nível',
  columns: [
    'Ambiente',
    'Nível 3',
    'Nível 5',
    'Nível 10',
    'Nível 15',
    'Nível 20',
  ],
  rows: [
    MechanicTableRow(
      id: 'desert',
      label: 'Deserto',
      values: ['2 fogo', '3 fogo', '4 fogo', '5 fogo', '6 fogo'],
    ),
    MechanicTableRow(
      id: 'sea',
      label: 'Mar',
      values: ['1d6', '1d6', '2d6', '3d6', '4d6'],
    ),
  ],
);

const ClassMechanicEntry _lookup = ClassMechanicEntry(
  id: _tableId,
  name: 'Aura da Tempestade',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'tce',
  kinds: {ClassMechanicKind.lookupTable},
  table: _wideTable,
);

const MechanicTable _rollTable = MechanicTable(
  id: 'surge.table',
  title: 'Surto (d100)',
  dice: 'd100',
  rows: [
    MechanicTableRow(
      id: 'low',
      label: '01–49',
      min: 1,
      max: 49,
      values: ['Nada acontece.'],
    ),
    MechanicTableRow(
      id: 'mid',
      label: '50',
      min: 50,
      max: 50,
      values: ['Conjura bola de fogo centrada em si.'],
    ),
    MechanicTableRow(
      id: 'high',
      label: '51–00',
      min: 51,
      max: 100,
      values: ['Recupera os pontos gastos.'],
    ),
  ],
);

const ClassMechanicEntry _roll = ClassMechanicEntry(
  id: _rollId,
  name: 'Surto de Magia Selvagem',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'tce',
  kinds: {ClassMechanicKind.rollTable},
  table: _rollTable,
);

/// Escolha permanente sem regra de substituição.
const ClassMechanicEntry _fixed = ClassMechanicEntry(
  id: _fixedId,
  name: 'Ancestral Dracônico',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'phb',
  kinds: {ClassMechanicKind.permanentChoice},
  progression: [MechanicProgressionStep(level: 3, picks: 1)],
  options: [
    MechanicOption(id: 'black', name: 'Negro', description: 'Ácido.'),
    MechanicOption(id: 'blue', name: 'Azul', description: 'Elétrico.'),
  ],
);

/// Tabela longa, para exercitar a busca.
final MechanicTable _longTable = MechanicTable(
  id: 'long.table',
  title: 'Tabela longa',
  dice: 'd20',
  rows: [
    for (var index = 1; index <= 20; index++)
      MechanicTableRow(
        id: '$index',
        label: '$index',
        min: index,
        max: index,
        values: ['Efeito da linha $index.'],
      ),
  ],
);

const List<ClassMechanicEntry> _entries = [
  _runes,
  _dice,
  _modes,
  _lookup,
  _roll,
  _fixed,
];

const List<ClassEntry> _classes = [
  ClassEntry(
    id: 'fighter',
    name: 'Guerreiro',
    hitDie: 'd10',
    source: 'phb',
    skillOptions: [],
    savingThrows: [],
    subclassLevel: 3,
  ),
];

const List<SubclassEntry> _subclasses = [
  SubclassEntry(
    id: 'fighter_rune_knight',
    classId: 'fighter',
    name: 'Cavaleiro Rúnico',
    source: 'tce',
  ),
];

Character _fighter({
  required int level,
  List<CharacterClassMechanic> mechanics = const [],
  List<CharacterFeatureState> featureStates = const [],
}) {
  return characterFixture(
    classLevels: [
      ClassLevel(
        classId: 'fighter',
        level: level,
        subclassId: 'fighter_rune_knight',
      ),
    ],
    classMechanics: mechanics,
    featureStates: featureStates,
  );
}
