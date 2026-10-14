import 'package:dnd_ficha_app/features/compendium/data/repositories/compendium_repository_impl.dart';
import 'package:dnd_ficha_app/features/compendium/data/sources/srd_asset_source.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_personality.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carrega os antecedentes pelo caminho real (asset + parser), e não por
/// objetos montados à mão.
///
/// Existe por dois motivos concretos:
///
/// 1. O parser resolve `personality_from`, e essa indireção só aparece lendo o
///    arquivo de verdade.
/// 2. `rootBundle.loadString` manda a decodificação para um isolate a partir de
///    50 KB, e esse isolate não roda sob `flutter test`. Quando os
///    antecedentes completos entraram, o asset passou de 50 KB e a suíte
///    travou sem mensagem de erro. `SrdAssetSource` decodifica na própria
///    isolate por isso, e este teste é o que trava de novo se alguém voltar
///    para `loadString`.
void main() {
  late List<BackgroundEntry> backgrounds;

  setUp(() async {
    backgrounds =
        await CompendiumRepositoryImpl(SrdAssetSource()).loadBackgrounds();
  });

  testWidgets('carrega os 28 antecedentes mais a opção customizável', (
    tester,
  ) async {
    expect(backgrounds, hasLength(29));
    expect(backgrounds.last.id, BackgroundEntry.customId);
    expect(
      backgrounds.where((item) => item.isCustom),
      hasLength(1),
      reason: 'a opção customizável não pode duplicar',
    );
  });

  testWidgets('os antecedentes que já existiam continuam carregando', (
    tester,
  ) async {
    final acolyte = backgrounds.firstWhere((item) => item.id == 'acolyte');

    expect(acolyte.name, 'Acólito');
    expect(acolyte.skillIds, containsAll(['insight', 'religion']));
    expect(acolyte.languages, 2);
    expect(acolyte.featureName, 'Abrigo dos Fiéis');
  });

  testWidgets('tabela própria é lida com as opções completas', (tester) async {
    final criminal = backgrounds.firstWhere((item) => item.id == 'criminal');
    final personality = criminal.personality;

    expect(personality.traits.options, hasLength(8));
    expect(personality.ideals.options, hasLength(6));
    expect(personality.bonds.options, hasLength(6));
    expect(personality.flaws.options, hasLength(6));

    // Uma escolha por categoria, inclusive no traço: decisão de produto deste
    // app, mais enxuta que os dois traços do Livro do Jogador. A tabela segue
    // com as 8 opções; o que mudou é quantas o jogador marca.
    expect(personality.choiceCountFor(PersonalityCategory.trait), 1);
    expect(personality.choiceCountFor(PersonalityCategory.ideal), 1);
    expect(personality.choiceCountFor(PersonalityCategory.bond), 1);
    expect(personality.choiceCountFor(PersonalityCategory.flaw), 1);

    // O id da opção deriva do dono da tabela, e é ele que vai para a ficha.
    expect(personality.traits.options.first.id, 'criminal.trait.1');

    // O ideal mostra o nome junto do texto; sem o rótulo a frase perde o que o
    // jogador usa para escolher.
    final ideal = personality.ideals.options.first;
    expect(ideal.name, 'Honra');
    expect(ideal.displayText, startsWith('Honra: '));
  });

  testWidgets('o far_traveler tem tabela de traços em d6, não d8', (
    tester,
  ) async {
    final farTraveler = backgrounds.firstWhere(
      (item) => item.id == 'far_traveler',
    );

    expect(farTraveler.personality.traits.die, 'd6');
    expect(farTraveler.personality.traits.options, hasLength(6));
  });

  group('antecedente que reaproveita a tabela de outro', () {
    testWidgets('recebe as opções e as contagens do dono', (tester) async {
      // O livro manda o Agente usar as tabelas do Acólito.
      final agent = backgrounds.firstWhere((item) => item.id == 'agent');
      final acolyte = backgrounds.firstWhere((item) => item.id == 'acolyte');

      expect(agent.personality.sourceId, 'acolyte');
      expect(agent.personality.traits.options, hasLength(8));
      expect(agent.personality.choiceCountFor(PersonalityCategory.trait), 1);

      // Mesmos ids dos dois lados: é o que permite trocar entre eles sem
      // invalidar a escolha já feita.
      expect(
        agent.personality.traits.options.map((o) => o.id),
        acolyte.personality.traits.options.map((o) => o.id),
      );
    });

    testWidgets('as cinco variantes apontam para o antecedente-base', (
      tester,
    ) async {
      const expected = {
        'guild_merchant': 'guild_artisan',
        'spy': 'criminal',
        'gladiator': 'entertainer',
        'pirate': 'sailor',
        'knight': 'noble',
      };

      for (final entry in expected.entries) {
        final variant = backgrounds.firstWhere((item) => item.id == entry.key);

        expect(variant.isVariant, isTrue, reason: entry.key);
        expect(variant.variantOf, entry.value, reason: entry.key);
        expect(
          variant.personality.sourceId,
          entry.value,
          reason: '${entry.key} deve herdar a tabela de ${entry.value}',
        );
        expect(
          variant.personality.choiceCountFor(PersonalityCategory.trait),
          1,
          reason: '${entry.key} precisa herdar a contagem de traços do dono',
        );
      }
    });

    testWidgets('todo antecedente carregado oferece as quatro categorias', (
      tester,
    ) async {
      for (final background in backgrounds) {
        if (background.isCustom) continue;

        expect(
          background.personality.isNotEmpty,
          isTrue,
          reason: '${background.id} ficou sem tabelas',
        );
        expect(
          background.personality.requiredCategories,
          hasLength(4),
          reason: '${background.id} não pede as quatro categorias',
        );
      }
    });
  });

  group('equipamento e dinheiro', () {
    testWidgets('o criminoso concede pé de cabra, roupas e 15 po', (
      tester,
    ) async {
      final criminal = backgrounds.firstWhere((item) => item.id == 'criminal');

      expect(criminal.grantedCurrency.gold, 15);
      expect(
        criminal.startingEquipment.map((item) => item.id),
        containsAll(['crowbar', 'dark_hooded_clothes']),
      );
    });

    testWidgets('o acólito concede cinco incensos', (tester) async {
      final acolyte = backgrounds.firstWhere((item) => item.id == 'acolyte');
      final incense = acolyte.startingEquipment.firstWhere(
        (item) => item.id == 'incense_stick',
      );

      expect(incense.quantity, 5);
    });

    testWidgets('a joia do viajante distante é item, não dinheiro', (
      tester,
    ) async {
      final farTraveler = backgrounds.firstWhere(
        (item) => item.id == 'far_traveler',
      );

      // A bolsa tem 5 po; a joia "no valor de 10 po" é um objeto e não entra
      // na carteira.
      expect(farTraveler.grantedCurrency.gold, 5);
      expect(
        farTraveler.startingEquipment.map((item) => item.id),
        contains('homeland_jewel'),
      );
    });

    testWidgets('escolha de equipamento não é concedida sozinha', (
      tester,
    ) async {
      final merchant = backgrounds.firstWhere(
        (item) => item.id == 'guild_merchant',
      );

      expect(merchant.equipmentChoices, hasLength(1));
      expect(merchant.equipmentChoices.single.options, hasLength(2));

      // A mula e a carroça são uma das alternativas, e por isso não aparecem
      // no equipamento automático: escolher pelo jogador seria inventar.
      expect(
        merchant.startingEquipment.map((item) => item.id),
        isNot(contains('mule')),
      );
    });

    testWidgets('perícias à escolha ficam estruturadas, não concedidas', (
      tester,
    ) async {
      final hunter = backgrounds.firstWhere(
        (item) => item.id == 'bounty_hunter',
      );

      expect(hunter.skillIds, isEmpty);
      expect(hunter.skillChoice, isNotNull);
      expect(hunter.skillChoice!.count, 2);
      expect(hunter.skillChoice!.skills, hasLength(4));
    });
  });

  testWidgets('características alternativas são preservadas', (tester) async {
    final noble = backgrounds.firstWhere((item) => item.id == 'noble');

    expect(noble.featureName, 'Posição de Privilégio');
    expect(noble.featureOptions, hasLength(2));
    expect(
      noble.featureOptions.map((item) => item.id),
      containsAll(['position_of_privilege', 'retainers']),
    );
  });

  testWidgets('tabelas auxiliares são carregadas', (tester) async {
    final guildArtisan = backgrounds.firstWhere(
      (item) => item.id == 'guild_artisan',
    );

    final guildType = guildArtisan.extraChoices.single;
    expect(guildType.id, 'guild_type');
    expect(guildType.die, 'd20');
    expect(guildType.options, hasLength(20));
  });
}
