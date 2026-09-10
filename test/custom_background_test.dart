import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/presentation/pages/character_creation_page.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/background_panel.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captura o personagem criado sem tocar no banco. Os demais métodos do
/// repositório são resolvidos por `noSuchMethod` e falham se usados.
class _FakeCharacterRepository implements CharacterRepository {
  Character? created;

  @override
  Future<void> create(Character character) async {
    created = character;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

// Fixtures mínimos do compêndio. Os testes de UI não leem os assets JSON:
// além de deixar o teste lento, o spinner de carregamento agenda frames sem
// parar e `pumpAndSettle` nunca assenta.
const _fighter = ClassEntry(
  id: 'fighter',
  name: 'Guerreiro',
  hitDie: 'd10',
  source: 'srd',
  skillOptions: ['athletics', 'intimidation'],
  savingThrows: ['strength', 'constitution'],
  primaryAbility: 'strength',
);

const _human = RaceEntry(
  id: 'human',
  name: 'Humano',
  source: 'srd',
  size: 'medium',
  speed: 9,
  creatureType: 'humanoid',
);

const _acolyte = BackgroundEntry(
  id: 'acolyte',
  name: 'Acólito',
  skillIds: ['insight', 'religion'],
  description: 'Serviu um templo.',
);

const _backgrounds = [_acolyte, BackgroundEntry.customOption];

/// Monta a página de criação com o compêndio já resolvido.
Future<_FakeCharacterRepository> _pumpCreationPage(WidgetTester tester) async {
  final repository = _FakeCharacterRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterRepositoryProvider.overrideWithValue(repository),
        classEntriesProvider.overrideWith((ref) => const [_fighter]),
        raceEntriesProvider.overrideWith((ref) => const [_human]),
        backgroundEntriesProvider.overrideWith((ref) => _backgrounds),
      ],
      child: MaterialApp(
        home: const CharacterCreationPage(),
        // A página faz pushReplacementNamed para a ficha depois de salvar.
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => const Text('FICHA'),
        ),
      ),
    ),
  );
  await tester.pump();

  return repository;
}

/// Traz [finder] para a viewport do formulário, que é um `ListView` e só
/// constrói o que está perto da tela.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    // A árvore tem mais de um Scrollable (o formulário e os menus), então o
    // padrão do scrollUntilVisible estoura com "Too many elements".
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

/// Seleciona [value] no dropdown identificado pelo rótulo [label].
///
/// Aciona o `onChanged` do próprio widget em vez de abrir o menu do Material:
/// o menu vive num overlay que cobre a tela e disputa o hit test com o
/// formulário rolável, o que torna o teste frágil sem cobrir nada de nosso.
/// O `initialValue` volta pelo `setState`, então o `FormFieldState` também se
/// atualiza e o `validator` enxerga o valor novo.
Future<void> _selectInDropdown(
  WidgetTester tester,
  String label,
  String value,
) async {
  final dropdown = tester.widget<DropdownButtonFormField<String>>(
    _dropdownWithLabel(label),
  );

  dropdown.onChanged!(value);
  await tester.pumpAndSettle();
}

Finder _dropdownWithLabel(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(DropdownButtonFormField<String>),
  );
}

Future<void> _selectCustomBackground(WidgetTester tester) async {
  await _selectInDropdown(tester, 'Antecedente', BackgroundEntry.customId);
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.widgetWithText(FilledButton, 'Criar personagem');
  await _reveal(tester, saveButton);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'compêndio expõe a opção Antecedente Customizável no fim da lista',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final backgrounds =
          await container.read(backgroundEntriesProvider.future);

      expect(backgrounds.length, greaterThan(1));
      expect(backgrounds.last.id, BackgroundEntry.customId);
      expect(backgrounds.last.name, 'Antecedente Customizável');
      expect(backgrounds.last.isCustom, isTrue);
      // Os antecedentes do compêndio seguem intactos.
      expect(backgrounds.any((item) => item.id == 'acolyte'), isTrue);
      expect(
        backgrounds.where((item) => item.isCustom).length,
        1,
        reason: 'a opção customizável não pode duplicar',
      );
    },
  );

  testWidgets(
    'escolher o antecedente customizável revela perícias e características, '
    'e salva o que foi preenchido',
    (tester) async {
      final repository = await _pumpCreationPage(tester);

      // Antes de escolher o customizável, o formulário extra não existe.
      expect(find.text('Monte o seu antecedente'), findsNothing);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do personagem'),
        'Vex',
      );

      await _selectCustomBackground(tester);

      // Agora o formulário do antecedente customizável está na tela.
      expect(find.text('Monte o seu antecedente'), findsOneWidget);
      expect(find.text('Nome do antecedente (opcional)'), findsOneWidget);
      expect(find.text('Primeira perícia'), findsOneWidget);
      expect(find.text('Segunda perícia'), findsOneWidget);
      expect(find.text('Características do antecedente'), findsOneWidget);

      await _selectInDropdown(tester, 'Primeira perícia', Skill.insight.id);
      await _selectInDropdown(tester, 'Segunda perícia', Skill.survival.id);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do antecedente (opcional)'),
        'Caçador de Recompensas',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Características do antecedente'),
        'Contatos na guilda de caçadores e um mandado sempre em aberto.',
      );
      await tester.pumpAndSettle();

      await _tapSave(tester);

      final saved = repository.created;
      expect(saved, isNotNull, reason: 'o personagem deveria ter sido salvo');
      expect(saved!.backgroundId, BackgroundEntry.customId);
      expect(saved.customBackground.name, 'Caçador de Recompensas');
      expect(saved.customBackground.displayName, 'Caçador de Recompensas');
      expect(
        saved.customBackground.skillIds,
        [Skill.insight.id, Skill.survival.id],
      );
      expect(
        saved.customBackground.features,
        'Contatos na guilda de caçadores e um mandado sempre em aberto.',
      );

      // As duas perícias do antecedente viram proficiência na ficha.
      expect(
        saved.skillProficiencies.levelFor(Skill.insight),
        ProficiencyLevel.proficient,
      );
      expect(
        saved.skillProficiencies.levelFor(Skill.survival),
        ProficiencyLevel.proficient,
      );
      expect(
        saved.skillProficiencies.levelFor(Skill.arcana),
        ProficiencyLevel.none,
      );

      // O CSV persistido no banco.
      expect(saved.customBackground.skillIdsAsCsv, 'insight,survival');
    },
  );

  testWidgets(
    'escolher um antecedente do compêndio não grava dados customizados',
    (tester) async {
      final repository = await _pumpCreationPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do personagem'),
        'Pike',
      );

      await _selectInDropdown(tester, 'Antecedente', _acolyte.id);

      expect(find.text('Monte o seu antecedente'), findsNothing);

      await _tapSave(tester);

      final saved = repository.created;
      expect(saved!.backgroundId, 'acolyte');
      expect(saved.customBackground.isEmpty, isTrue);
      expect(saved.customBackground.skillIdsAsCsv, '');
      // Acólito concede Intuição e Religião.
      expect(
        saved.skillProficiencies.levelFor(Skill.insight),
        ProficiencyLevel.proficient,
      );
      expect(
        saved.skillProficiencies.levelFor(Skill.religion),
        ProficiencyLevel.proficient,
      );
    },
  );

  testWidgets(
    'trocar a primeira perícia para a que já estava na segunda faz a troca '
    'em vez de duplicar',
    (tester) async {
      final repository = await _pumpCreationPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do personagem'),
        'Vex',
      );

      await _selectCustomBackground(tester);

      await _selectInDropdown(tester, 'Primeira perícia', Skill.athletics.id);
      await _selectInDropdown(tester, 'Segunda perícia', Skill.stealth.id);
      // Colide com a segunda perícia: deve trocar, sem quebrar o dropdown.
      await _selectInDropdown(tester, 'Primeira perícia', Skill.stealth.id);

      expect(tester.takeException(), isNull);

      await _tapSave(tester);

      expect(
        repository.created!.customBackground.skillIds,
        [Skill.stealth.id, Skill.athletics.id],
      );
    },
  );

  testWidgets(
    'não deixa salvar o antecedente customizável sem escolher as perícias',
    (tester) async {
      final repository = await _pumpCreationPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do personagem'),
        'Vex',
      );

      await _selectCustomBackground(tester);
      await _tapSave(tester);

      expect(
        repository.created,
        isNull,
        reason: 'as perícias do antecedente são obrigatórias',
      );
      // O ListView desmonta os dropdowns quando rolamos até o botão salvar,
      // então a checagem tem de vir do estado, não do validator do widget.
      expect(
        find.textContaining('as duas perícias do antecedente'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'a ficha mostra o antecedente customizado do personagem',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BackgroundPanel(
                backgroundId: BackgroundEntry.customId,
                customBackground: CustomBackground(
                  name: 'Caçador de Recompensas',
                  skillIds: ['insight', 'survival'],
                  features: 'Contatos na guilda.',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Caçador de Recompensas'), findsOneWidget);
      expect(find.text('Antecedente criado pelo jogador.'), findsOneWidget);
      expect(find.text('Perícias: Intuição, Sobrevivência'), findsOneWidget);
      expect(find.text('Características'), findsOneWidget);
      expect(find.text('Contatos na guilda.'), findsOneWidget);
    },
  );

  testWidgets(
    'sem nome, a ficha cai no rótulo padrão do antecedente customizado',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BackgroundPanel(
                backgroundId: BackgroundEntry.customId,
                customBackground: CustomBackground(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Antecedente Customizável'), findsOneWidget);
      expect(find.text('Nenhuma característica descrita.'), findsOneWidget);
    },
  );
}
