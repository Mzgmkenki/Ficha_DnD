import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_options.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/edit_armor_class_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/ability_score_improvement_dialog.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Testes de interface das duas telas que o levantamento descreve com exemplo
/// de exibição: a distribuição de Incremento no Valor de Atributo e a escolha
/// de fórmula de CA.
///
/// Rodam numa viewport de celular (360x760 lógicos) de propósito: as duas
/// telas ganharam conteúdo novo, e estouro de layout em tela pequena é o tipo
/// de defeito que só aparece no tamanho real.
const Size _phone = Size(360, 760);

class _FakeCharacterRepository implements CharacterRepository {
  _FakeCharacterRepository(this.stored);

  Character stored;
  Character? updated;

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Future<void> update(Character character) async {
    updated = character;
    stored = character;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

/// Carrega o resultado do diálogo para fora do callback que o abriu.
class _DialogOutcome {
  AbilityScoreImprovementDraft? draft;
  bool finished = false;
}

Future<_DialogOutcome> _openImprovementDialog(
  WidgetTester tester, {
  required AbilityScores current,
  Map<Ability, int> maximums = const {},
}) async {
  tester.view.physicalSize = _phone;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final outcome = _DialogOutcome();

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                outcome.draft = await showAbilityScoreImprovementDialog(
                  context: context,
                  current: current,
                  slotLabel: 'Guerreiro 4',
                  maximums: maximums,
                );
                outcome.finished = true;
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();

  return outcome;
}

Future<void> _tapPlus(WidgetTester tester, Ability ability) async {
  await tester.tap(find.byKey(ValueKey('asi-plus-${ability.name}')));
  await tester.pump();
}

/// O botão de somar está ativo?
bool _plusEnabled(WidgetTester tester, Ability ability) {
  final button = tester.widget<IconButton>(
    find.byKey(ValueKey('asi-plus-${ability.name}')),
  );
  return button.onPressed != null;
}

bool _confirmEnabled(WidgetTester tester) {
  final button = tester.widget<FilledButton>(
    find.byKey(const ValueKey('asi-confirm')),
  );
  return button.onPressed != null;
}

// --- Dados do compêndio para a tela de CA --------------------------------

const _barbarian = ClassEntry(
  id: 'barbarian',
  name: 'Bárbaro',
  hitDie: 'd12',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
);

const _unarmoredDefense = ClassFeatureEntry(
  classId: 'barbarian',
  level: 1,
  source: 'srd',
  features: [
    ClassFeature(
      name: 'Defesa sem Armadura',
      description: 'Sem armadura, sua CA é 10 + DES + CON.',
      effects: [
        FeatureEffect(
          id: 'barbarian.unarmored_defense',
          path: FeatureEffectPaths.armorClassBase,
          operation: FeatureEffectOperation.grant,
          formula: '10 + mod.dexterity + mod.constitution',
          conditions: FeatureEffectConditions(
            armor: FeatureArmorCondition.none,
          ),
          stacking: FeatureEffectStacking.exclusive,
          group: 'ac.base',
          unique: 'unarmored_defense',
        ),
      ],
    ),
  ],
);

Future<_FakeCharacterRepository> _pumpArmorClassPage(
  WidgetTester tester,
  Character character,
) async {
  tester.view.physicalSize = _phone;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _FakeCharacterRepository(character);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterRepositoryProvider.overrideWithValue(repository),
        classEntriesProvider.overrideWith((ref) => <ClassEntry>[_barbarian]),
        classFeaturesProvider.overrideWith(
          (ref) => <ClassFeatureEntry>[_unarmoredDefense],
        ),
        subclassEntriesProvider.overrideWith((ref) => <SubclassEntry>[]),
      ],
      child: MaterialApp(
        // Empilhada sobre a ficha, como na vida real: o salvar faz `pop`, e
        // sem rota embaixo o teste mediria um caminho que não existe.
        onGenerateRoute: (_) => null,
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('ficha')),
          ),
          MaterialPageRoute<void>(
            builder: (_) => EditArmorClassPage(character: character),
          ),
        ],
      ),
    ),
  );

  await tester.pumpAndSettle();
  return repository;
}

void main() {
  group('diálogo de Incremento no Valor de Atributo', () {
    testWidgets('+2 em um atributo fecha a distribuição', (tester) async {
      final outcome = await _openImprovementDialog(
        tester,
        current: scoresWith(strength: 15),
      );

      expect(_confirmEnabled(tester), isFalse, reason: 'nada distribuído');

      await _tapPlus(tester, Ability.strength);
      expect(
        _confirmEnabled(tester),
        isFalse,
        reason: 'confirmar com ponto sobrando perderia o ponto em silêncio',
      );

      await _tapPlus(tester, Ability.strength);

      // A prévia é o que o levantamento pede: o jogador vê o resultado antes
      // de confirmar.
      expect(find.text('15 → 17 (máx. 20)'), findsOneWidget);
      expect(find.text('Distribuição completa.'), findsOneWidget);
      expect(_confirmEnabled(tester), isTrue);

      await tester.tap(find.byKey(const ValueKey('asi-confirm')));
      await tester.pumpAndSettle();

      expect(outcome.finished, isTrue);
      expect(outcome.draft?.asIncreaseMap, {'strength': 2});
    });

    testWidgets('+1 em dois atributos diferentes', (tester) async {
      final outcome = await _openImprovementDialog(
        tester,
        current: scoresWith(strength: 15, constitution: 14),
      );

      await _tapPlus(tester, Ability.strength);
      await _tapPlus(tester, Ability.constitution);

      expect(find.text('15 → 16 (máx. 20)'), findsOneWidget);
      expect(find.text('14 → 15 (máx. 20)'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('asi-confirm')));
      await tester.pumpAndSettle();

      expect(outcome.draft?.asIncreaseMap, {
        'strength': 1,
        'constitution': 1,
      });
    });

    testWidgets('o terceiro atributo não aceita ponto', (tester) async {
      await _openImprovementDialog(tester, current: flatScores);

      await _tapPlus(tester, Ability.strength);
      await _tapPlus(tester, Ability.constitution);

      expect(
        _plusEnabled(tester, Ability.dexterity),
        isFalse,
        reason: 'são 2 pontos em no máximo 2 atributos',
      );
    });

    testWidgets('o botão de somar some no teto de 20', (tester) async {
      await _openImprovementDialog(
        tester,
        current: scoresWith(strength: 20, dexterity: 19),
      );

      expect(_plusEnabled(tester, Ability.strength), isFalse);

      // 19 ainda aceita o primeiro ponto, e o segundo já não.
      await _tapPlus(tester, Ability.dexterity);
      expect(_plusEnabled(tester, Ability.dexterity), isFalse);
      expect(find.text('19 → 20 (máx. 20)'), findsOneWidget);
    });

    testWidgets('teto declarado por característica libera acima de 20', (
      tester,
    ) async {
      await _openImprovementDialog(
        tester,
        current: scoresWith(strength: 20),
        maximums: const {Ability.strength: 24},
      );

      expect(
        _plusEnabled(tester, Ability.strength),
        isTrue,
        reason: 'Campeão Primal declara teto 24',
      );

      await _tapPlus(tester, Ability.strength);
      expect(find.text('20 → 21 (máx. 24)'), findsOneWidget);
    });

    testWidgets('cancelar não devolve rascunho', (tester) async {
      final outcome = await _openImprovementDialog(
        tester,
        current: flatScores,
      );

      await _tapPlus(tester, Ability.strength);
      await _tapPlus(tester, Ability.strength);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(outcome.finished, isTrue);
      expect(
        outcome.draft,
        isNull,
        reason: 'desistir mantém a escolha pendente',
      );
    });
  });

  group('escolha de fórmula de CA', () {
    /// Bárbaro de 1º nível, DES 14 (+2) e CON 16 (+3), sem armadura.
    /// Equipamento: 10 + 2 = 12. Defesa sem Armadura: 10 + 2 + 3 = 15.
    Character barbarian({String? formulaId}) {
      return characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 1)],
        abilityScores: scoresWith(dexterity: 14, constitution: 16),
      ).copyWith(armorClassFormulaId: formulaId);
    }

    testWidgets('as duas fórmulas aparecem, com a conta de cada uma', (
      tester,
    ) async {
      await _pumpArmorClassPage(tester, barbarian());

      expect(
        find.byKey(const ValueKey('ac-formula-equipment')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ac-formula-barbarian.unarmored_defense')),
        findsOneWidget,
      );

      // A origem fica visível: "Defesa sem Armadura — Bárbaro, nível 1".
      expect(find.text('Bárbaro, nível 1'), findsOneWidget);
      expect(find.text('Defesa sem Armadura — CA base 15'), findsOneWidget);
      expect(
        find.textContaining('Elas não se somam'),
        findsOneWidget,
        reason: 'a regra de não somar duas bases é dita na tela',
      );
    });

    testWidgets('sem preferência gravada, a melhor fórmula fica marcada', (
      tester,
    ) async {
      await _pumpArmorClassPage(tester, barbarian());

      final group = tester.widget<RadioGroup<String>>(
        find.byType(RadioGroup<String>),
      );
      expect(group.groupValue, 'barbarian.unarmored_defense');
      expect(find.text('CA 15'), findsOneWidget);
    });

    testWidgets('a preferência gravada vence a melhor fórmula', (tester) async {
      await _pumpArmorClassPage(
        tester,
        barbarian(formulaId: armorClassEquipmentFormulaId),
      );

      final group = tester.widget<RadioGroup<String>>(
        find.byType(RadioGroup<String>),
      );
      expect(group.groupValue, armorClassEquipmentFormulaId);
      expect(find.text('CA 12'), findsOneWidget);
    });

    testWidgets('trocar a fórmula muda a CA e o salvar grava a escolha', (
      tester,
    ) async {
      final repository = await _pumpArmorClassPage(tester, barbarian());

      expect(find.text('CA 15'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('ac-formula-equipment')));
      await tester.pumpAndSettle();

      expect(find.text('CA 12'), findsOneWidget);

      // O botão de salvar fica abaixo da dobra num celular: a tela rola, e o
      // teste tem de rolar junto em vez de tocar no vazio.
      await tester.ensureVisible(find.text('Salvar CA 12'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar CA 12'));
      await tester.pumpAndSettle();

      expect(
        repository.updated?.armorClassFormulaId,
        armorClassEquipmentFormulaId,
      );
      expect(repository.updated?.combatStats.armorClass, 12);
    });

    testWidgets('com escudo, o bônus entra por cima da fórmula escolhida', (
      tester,
    ) async {
      await _pumpArmorClassPage(tester, barbarian());

      await tester.tap(find.byKey(const ValueKey('armor-shield')));
      await tester.pumpAndSettle();

      // 10 + DES +2 + CON +3 = 15, mais 2 de escudo.
      expect(find.text('CA 17'), findsOneWidget);
    });

    testWidgets('personagem sem a característica não vê o seletor', (
      tester,
    ) async {
      await _pumpArmorClassPage(
        tester,
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
          abilityScores: scoresWith(dexterity: 14, constitution: 16),
        ),
      );

      expect(find.byType(RadioGroup<String>), findsNothing);
      expect(find.text('Fórmula de CA'), findsNothing);
    });
  });
}
