import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/application/use_cases/character/sync_invocation_spells.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_eldritch_invocation.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feature_state.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_prerequisites.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_selection.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_resources.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:dnd_ficha_app/features/compendium/data/spell_assets.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/eldritch_invocation_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/pact_boon.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/eldritch_invocation_catalog.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Testes das Invocações Místicas do Bruxo (D&D 5e, edição de 2014).
///
/// Dois tipos de teste aqui, de propósito:
///
/// - os que leem o ASSET REAL, para o catálogo publicado não divergir da regra
///   (contagem, ids estáveis, pré-requisitos declarados);
/// - os que montam entradas sintéticas, para exercitar caminhos que o catálogo
///   de 2014 não usa — invocação que exige outra invocação e invocação
///   incompatível com outra. O validador tem de suportá-los mesmo sem dado que
///   os exercite, e um teste com dado inventado é a única forma de provar isso
///   sem inventar conteúdo no asset.
void main() {
  const assetPath = 'assets/data/srd/eldritch_invocations.json';

  late List<Map<String, dynamic>> raw;
  late List<EldritchInvocationEntry> entries;
  late EldritchInvocationCatalog catalog;

  setUpAll(() {
    final file = File(assetPath);
    expect(
      file.existsSync(),
      isTrue,
      reason: 'catálogo de invocações não encontrado em $assetPath',
    );

    raw = (jsonDecode(file.readAsStringSync()) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    entries = [
      for (final item in raw)
        if (EldritchInvocationEntry.tryParse(item) case final entry?) entry,
    ];

    catalog = EldritchInvocationCatalog.from(entries);
  });

  // ------------------------------------------------------------------ catálogo

  group('catálogo', () {
    test('1. o asset traz as 54 invocações de 2014 e todas são lidas', () {
      expect(raw.length, 54);
      expect(entries.length, 54, reason: 'alguma entrada foi descartada');
      expect(catalog.length, 54);
    });

    test('2. processar o mesmo catálogo de novo não duplica invocação', () {
      final again = EldritchInvocationCatalog.import(
        existing: entries,
        incoming: entries,
      );

      expect(again.catalog.length, 54);
      expect(again.added, isEmpty);
      expect(again.updated, isEmpty);
      expect(again.unchanged.length, 54);
      expect(again.changedAnything, isFalse);

      // E uma terceira passada continua estável.
      final third = EldritchInvocationCatalog.import(
        existing: again.catalog.all,
        incoming: entries,
      );
      expect(third.catalog.length, 54);
      expect(third.changedAnything, isFalse);
    });

    test('3. id repetido no arquivo é descartado e registrado', () {
      final duplicated = EldritchInvocationCatalog.from([
        ...entries,
        ...entries,
      ]);

      expect(duplicated.length, 54);
      expect(duplicated.duplicates.length, 54);
      expect(
        duplicated.duplicates.first.matchedBy,
        'identificador',
      );
    });

    test('4. os ids são estáveis, minúsculos e sem acento', () {
      for (final entry in entries) {
        expect(
          RegExp(r'^[a-z0-9_]+$').hasMatch(entry.id),
          isTrue,
          reason: 'id fora do padrão: ${entry.id}',
        );
        expect(entry.name.trim(), isNotEmpty);
        expect(entry.nameOriginal, isNotNull, reason: entry.id);
        expect(entry.hasDescription, isTrue, reason: entry.id);
      }
    });

    test('5. as fontes são só as três da edição de 2014', () {
      final bySource = <String, int>{};
      for (final entry in entries) {
        bySource[entry.source] = (bySource[entry.source] ?? 0) + 1;
      }

      expect(bySource.keys.toSet(), {'phb', 'xge', 'tcoe'});
      expect(bySource['phb'], 32);
      expect(bySource['xge'], 14);
      expect(bySource['tcoe'], 8);
    });

    test(
      '6. a dádiva exigida é id estruturado, nunca texto livre',
      () {
        final withBoon = raw.where(
          (item) => (item['prerequisites'] as Map?)?['pact_boon'] != null,
        );

        expect(withBoon, isNotEmpty);

        for (final item in withBoon) {
          final declared =
              (item['prerequisites'] as Map)['pact_boon'] as String;

          expect(
            PactBoon.fromId(declared),
            isNotNull,
            reason:
                'pact_boon "$declared" em ${item['id']} não é um id de '
                'PactBoon',
          );
        }
      },
    );

    test('7. busca por trecho de nome acha em português e em inglês', () {
      final rajada = catalog.search('rajada').map((item) => item.id).toSet();
      expect(rajada, contains('agonizing_blast'));
      expect(rajada, contains('repelling_blast'));
      expect(rajada, isNot(contains('devils_sight')));

      // Busca pelo nome em inglês: "Blast" acha as duas rajadas, e "Spear"
      // acha a Lança Mística, cujo nome em português não tem "rajada".
      final blast = catalog.search('Blast').map((item) => item.id).toSet();
      expect(blast, {'agonizing_blast', 'repelling_blast'});
      expect(
        catalog.search('Spear').map((item) => item.id),
        ['eldritch_spear'],
      );

      expect(catalog.resolve('Agonizing Blast')?.id, 'agonizing_blast');
      expect(catalog.resolve('Visão do Diabo')?.id, 'devils_sight');
      expect(catalog.search('').length, 54);
    });
  });

  // ----------------------------------------------------------------- progressão

  group('progressão por nível', () {
    test('8. a tabela de 2014 sai do asset da classe, não do código', () {
      final classes = (jsonDecode(
                File('assets/data/srd/classes.json').readAsStringSync(),
              )
              as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);

      final warlock = classes.firstWhere((item) => item['id'] == 'warlock');
      final declared = Map<String, dynamic>.from(
        warlock['invocations_known'] as Map,
      );

      expect(declared, {
        '2': 2,
        '5': 3,
        '7': 4,
        '9': 5,
        '12': 6,
        '15': 7,
        '18': 8,
      });

      // Nenhuma outra classe declara invocação.
      for (final item in classes) {
        if (item['id'] == 'warlock') continue;
        expect(item['invocations_known'], isNull, reason: '${item['id']}');
      }
    });

    test('9. o limite vale o maior degrau já alcançado', () {
      final warlock = _warlockClass();

      expect(warlock.invocationsKnownAt(1), 0);
      expect(warlock.invocationsKnownAt(2), 2);
      expect(warlock.invocationsKnownAt(4), 2);
      expect(warlock.invocationsKnownAt(5), 3);
      expect(warlock.invocationsKnownAt(6), 3);
      expect(warlock.invocationsKnownAt(7), 4);
      expect(warlock.invocationsKnownAt(9), 5);
      expect(warlock.invocationsKnownAt(11), 5);
      expect(warlock.invocationsKnownAt(12), 6);
      expect(warlock.invocationsKnownAt(15), 7);
      expect(warlock.invocationsKnownAt(18), 8);
      expect(warlock.invocationsKnownAt(20), 8);
    });

    test('10. Bruxo de 1º nível ainda não tem vaga nenhuma', () {
      final resolved = _resolve(_warlock(level: 1));

      expect(resolved.isWarlock, isTrue);
      expect(resolved.limit, 0);
      expect(resolved.freeSlots, 0);
      expect(resolved.hasPendingSlots, isFalse);
      expect(resolved.countLabel, '0 de 0 selecionadas');
    });

    test('11. multiclasse usa o nível de Bruxo, não o nível total', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'fighter', level: 10),
          ClassLevel(classId: 'warlock', level: 2),
        ],
      );

      final resolved = _resolve(character);

      expect(character.totalLevel, 12);
      expect(resolved.warlockLevel, 2);
      expect(resolved.limit, 2, reason: 'o nível 12 daria 6 invocações');
    });

    test('12. quem não é Bruxo não tem vaga e não vê seção', () {
      final resolved = _resolve(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'wizard', level: 20)],
        ),
      );

      expect(resolved.isWarlock, isFalse);
      expect(resolved.limit, 0);
      expect(resolved.options, isEmpty);
      expect(resolved.hasAny, isFalse);
    });

    test('13. a contagem aparece como "3 de 3 selecionadas"', () {
      final resolved = _resolve(
        _warlock(
          level: 5,
          invocations: const [
            'armor_of_shadows',
            'beast_speech',
            'devils_sight',
          ],
        ),
      );

      expect(resolved.limit, 3);
      expect(resolved.selectedCount, 3);
      expect(resolved.countLabel, '3 de 3 selecionadas');
      expect(resolved.freeSlots, 0);
      expect(resolved.hasAny, isTrue);
    });
  });

  // ------------------------------------------------------------- pré-requisitos

  group('pré-requisitos', () {
    test('14. nível de Bruxo insuficiente bloqueia, com o motivo', () {
      final resolved = _resolve(_warlock(level: 2));
      final item = resolved.byId('mire_the_mind')!;

      expect(item.availability, InvocationAvailability.blocked);
      expect(
        item.blocks.map((block) => block.kind),
        contains(InvocationBlockKind.warlockLevel),
      );
      expect(item.blockReason, 'Requer Bruxo de nível 5.');
    });

    test('15. dádiva do pacto errada ou ausente bloqueia, com o motivo', () {
      final withoutBoon = _resolve(_warlock(level: 5));
      final blade = withoutBoon.byId('thirsting_blade')!;

      expect(blade.availability, InvocationAvailability.blocked);
      expect(
        blade.blocks.map((block) => block.kind),
        contains(InvocationBlockKind.pactBoon),
      );
      expect(blade.blockReason, 'Requer Pacto da Lâmina.');

      final wrongBoon = _resolve(
        _warlock(level: 5, boon: PactBoon.tome),
      );
      expect(
        wrongBoon.byId('thirsting_blade')!.blockReason,
        'Requer Pacto da Lâmina.',
      );

      final rightBoon = _resolve(
        _warlock(level: 5, boon: PactBoon.blade),
      );
      expect(
        rightBoon.byId('thirsting_blade')!.availability,
        InvocationAvailability.available,
      );
    });

    test('16. truque Rajada Mística exigido bloqueia quem não o conhece', () {
      final resolved = _resolve(_warlock(level: 2));
      final item = resolved.byId('agonizing_blast')!;

      expect(item.availability, InvocationAvailability.blocked);
      expect(
        item.blocks.single.kind,
        InvocationBlockKind.cantrip,
      );
      expect(item.blockReason, 'Requer o truque Rajada Mística.');

      final withCantrip = _resolve(
        _warlock(level: 2, knownSpellIds: const [_eldritchBlastId]),
      );
      expect(
        withCantrip.byId('agonizing_blast')!.availability,
        InvocationAvailability.available,
      );
    });

    test('17. Hex OU característica que amaldiçoa libera a maldição', () {
      final neither = _resolve(_warlock(level: 7));
      expect(
        neither.byId('maddening_hex')!.blocks.single.kind,
        InvocationBlockKind.curseSource,
      );
      expect(
        neither.byId('maddening_hex')!.blockReason,
        'Requer a magia Hex ou uma característica de Bruxo que amaldiçoe '
        'um alvo.',
      );

      final withHex = _resolve(
        _warlock(level: 7, knownSpellIds: const [_hexId]),
      );
      expect(
        withHex.byId('maddening_hex')!.availability,
        InvocationAvailability.available,
      );

      final hexblade = _resolve(
        _warlock(level: 7, subclassId: 'warlock_hexblade'),
      );
      expect(
        hexblade.byId('relentless_hex')!.availability,
        InvocationAvailability.available,
      );
    });

    test('18. invocação exigida por outra bloqueia com o nome dela', () {
      final synthetic = EldritchInvocationCatalog.from([
        _syntheticEntry(id: 'base_invocation', name: 'Invocação Base'),
        _syntheticEntry(
          id: 'depends_on_base',
          name: 'Invocação Dependente',
          prerequisites: const InvocationPrerequisites(
            invocations: ['base_invocation'],
          ),
        ),
      ]);

      final blocks = EldritchInvocationPrerequisites.evaluate(
        invocation: synthetic.byId('depends_on_base')!,
        profile: const WarlockProfile(warlockLevel: 5),
        catalog: synthetic,
      );

      expect(blocks.single.kind, InvocationBlockKind.requiredInvocation);
      expect(blocks.single.message, 'Requer a invocação Invocação Base.');

      final met = EldritchInvocationPrerequisites.evaluate(
        invocation: synthetic.byId('depends_on_base')!,
        profile: const WarlockProfile(
          warlockLevel: 5,
          selectedInvocationIds: {'base_invocation'},
        ),
        catalog: synthetic,
      );
      expect(met, isEmpty);
    });

    test('19. incompatibilidade com invocação já escolhida bloqueia', () {
      final synthetic = EldritchInvocationCatalog.from([
        _syntheticEntry(id: 'first_path', name: 'Primeiro Caminho'),
        _syntheticEntry(
          id: 'second_path',
          name: 'Segundo Caminho',
          prerequisites: const InvocationPrerequisites(
            incompatibleWith: ['first_path'],
          ),
        ),
      ]);

      final blocks = EldritchInvocationPrerequisites.evaluate(
        invocation: synthetic.byId('second_path')!,
        profile: const WarlockProfile(
          warlockLevel: 5,
          selectedInvocationIds: {'first_path'},
        ),
        catalog: synthetic,
      );

      expect(blocks.single.kind, InvocationBlockKind.incompatible);
      expect(
        blocks.single.message,
        'Incompatível com uma invocação já selecionada.',
      );
    });

    test('20. quem não tem nível de Bruxo recebe um motivo só', () {
      final blocks = EldritchInvocationPrerequisites.evaluate(
        invocation: catalog.byId('thirsting_blade')!,
        profile: WarlockProfile.none,
        catalog: catalog,
      );

      expect(blocks.single.kind, InvocationBlockKind.notWarlock);
      expect(blocks.single.message, 'Requer níveis na classe Bruxo.');
    });

    test('21. invocação bloqueada continua visível na lista', () {
      final resolved = _resolve(_warlock(level: 2));

      expect(resolved.options.length, 54);
      expect(resolved.blocked, isNotEmpty);
      expect(
        resolved.options.map((item) => item.id).toSet(),
        containsAll(const [
          'thirsting_blade',
          'chains_of_carceri',
          'witch_sight',
        ]),
      );

      for (final item in resolved.blocked) {
        expect(
          item.blockReason.trim(),
          isNotEmpty,
          reason: '${item.id} bloqueada sem motivo',
        );
      }
    });

    test('22. os quatro filtros particionam a lista inteira', () {
      final resolved = _resolve(
        _warlock(
          level: 5,
          boon: PactBoon.blade,
          invocations: const ['armor_of_shadows'],
        ),
      );

      final total =
          resolved.available.length +
          resolved.blocked.length +
          resolved.selected.length;

      expect(total, resolved.options.length);
      expect(resolved.selected.map((item) => item.id), ['armor_of_shadows']);
      expect(resolved.available, isNotEmpty);
      expect(resolved.blocked, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------- seleção

  group('seleção e substituição', () {
    test('23. escolher ocupa vaga e registra o nível', () {
      final character = _warlock(level: 2);
      final outcome = EldritchInvocationSelection.select(
        character: character,
        resolved: _resolve(character),
        invocationId: 'devils_sight',
      );

      expect(outcome.isRejected, isFalse);
      expect(outcome.changed, isTrue);
      expect(outcome.character.eldritchInvocations.single.invocationId,
          'devils_sight');
      expect(outcome.character.eldritchInvocations.single.chosenAtLevel, 2);
    });

    test('24. não dá para passar do limite do nível', () {
      final character = _warlock(
        level: 2,
        invocations: const ['armor_of_shadows', 'beast_speech'],
      );

      final outcome = EldritchInvocationSelection.select(
        character: character,
        resolved: _resolve(character),
        invocationId: 'devils_sight',
      );

      expect(outcome.changed, isFalse);
      expect(outcome.isRejected, isTrue);
      expect(outcome.error, contains('2 de 2 selecionadas'));
      expect(character.eldritchInvocations.length, 2);
    });

    test('25. não dá para escolher invocação bloqueada', () {
      final character = _warlock(level: 2);

      final outcome = EldritchInvocationSelection.select(
        character: character,
        resolved: _resolve(character),
        invocationId: 'thirsting_blade',
      );

      expect(outcome.changed, isFalse);
      expect(outcome.error, 'Requer Bruxo de nível 5. Requer Pacto da Lâmina.');
    });

    test('26. substituir troca a invocação e grava o histórico', () {
      final character = _warlock(
        level: 5,
        invocations: const ['armor_of_shadows', 'beast_speech'],
      );

      final outcome = EldritchInvocationSelection.replace(
        character: character,
        resolved: _resolve(character),
        replacedId: 'beast_speech',
        invocationId: 'devils_sight',
      );

      expect(outcome.changed, isTrue);
      expect(outcome.replaced, 'beast_speech');

      final ids = outcome.character.eldritchInvocations
          .map((item) => item.invocationId)
          .toList();
      expect(ids, ['armor_of_shadows', 'devils_sight']);

      final added = outcome.character.eldritchInvocations.last;
      expect(added.replacedInvocationId, 'beast_speech');
      expect(added.replacedAtLevel, 5);
      expect(added.replacedSomething, isTrue);
    });

    test('27. substituir zera os usos gastos da que saiu', () {
      final spent = EldritchInvocationEntry.featureIdFor('tomb_of_levistus');

      final character = _warlock(
        level: 5,
        invocations: const ['tomb_of_levistus', 'armor_of_shadows'],
      ).copyWith(
        featureStates: [
          CharacterFeatureState(featureId: spent, usesSpent: 1),
          const CharacterFeatureState(
            featureId: PactBoon.featureId,
            choiceOptionId: 'pact_of_the_tome',
          ),
        ],
      );

      final outcome = EldritchInvocationSelection.replace(
        character: character,
        resolved: _resolve(character),
        replacedId: 'tomb_of_levistus',
        invocationId: 'devils_sight',
      );

      expect(outcome.changed, isTrue);
      expect(outcome.character.featureStateFor(spent), isNull);
      // A Dádiva do Pacto NÃO é apagada junto.
      expect(
        outcome.character.featureStateFor(PactBoon.featureId)?.choiceOptionId,
        'pact_of_the_tome',
      );
    });

    test('28. remover libera a vaga sem mexer nas outras', () {
      final character = _warlock(
        level: 5,
        invocations: const ['armor_of_shadows', 'beast_speech'],
      );

      final outcome = EldritchInvocationSelection.remove(
        character: character,
        invocationId: 'armor_of_shadows',
      );

      expect(outcome.changed, isTrue);
      expect(
        outcome.character.eldritchInvocations.map((i) => i.invocationId),
        ['beast_speech'],
      );
      expect(_resolve(outcome.character).freeSlots, 2);
    });

    test('29. substituta inelegível é recusada pelo domínio', () {
      final character = _warlock(
        level: 5,
        invocations: const ['armor_of_shadows'],
      );

      final outcome = EldritchInvocationSelection.replace(
        character: character,
        resolved: _resolve(character),
        replacedId: 'armor_of_shadows',
        invocationId: 'witch_sight',
      );

      expect(outcome.changed, isFalse);
      expect(outcome.error, 'Requer Bruxo de nível 15.');
      expect(character.eldritchInvocations.length, 1);
    });
  });

  // ----------------------------------------------------- perda de pré-requisito

  group('perda de pré-requisito', () {
    test(
      '30. invocação que perdeu o pré-requisito fica inválida, não apagada',
      () {
        final character = _warlock(
          level: 5,
          boon: PactBoon.tome,
          invocations: const ['thirsting_blade'],
        );

        final resolved = _resolve(character);
        final item = resolved.byId('thirsting_blade')!;

        // Continua gravada.
        expect(character.eldritchInvocations.length, 1);
        // Continua listada, e ocupa vaga.
        expect(item.isSelected, isTrue);
        expect(resolved.selectedCount, 1);
        // Mas não está valendo.
        expect(item.availability, InvocationAvailability.invalid);
        expect(item.isValid, isFalse);
        expect(item.appliesEffects, isFalse);
        expect(resolved.valid, isEmpty);
        expect(resolved.hasInvalid, isTrue);
        // E a ficha explica o motivo.
        expect(item.blockReason, 'Requer Pacto da Lâmina.');
      },
    );

    test('31. invocação inválida não aplica efeito nenhum', () {
      final character = _warlock(
        level: 12,
        boon: PactBoon.tome,
        invocations: const ['lifedrinker'],
        charisma: 18,
      );

      final resolved = _resolve(character);
      final summary = EldritchInvocationResolver.pactWeaponSummaryFor(
        character: character,
        invocations: resolved,
      );

      expect(resolved.invalid.map((item) => item.id), ['lifedrinker']);
      expect(summary.isEmpty, isTrue);
      expect(summary.damageBonus, 0);
      expect(resolved.grantedSpells, isEmpty);
      expect(resolved.asFeatures.features, isEmpty);
    });

    test('32. id que saiu do catálogo não é apagado em silêncio', () {
      final character = _warlock(level: 5).copyWith(
        eldritchInvocations: const [
          CharacterEldritchInvocation(
            invocationId: 'invocacao_que_nao_existe',
            chosenAtLevel: 2,
          ),
        ],
      );

      final resolved = _resolve(character);
      final orphan = resolved.byId('invocacao_que_nao_existe')!;

      expect(orphan.availability, InvocationAvailability.invalid);
      expect(
        orphan.blocks.single.kind,
        InvocationBlockKind.unknownInvocation,
      );
      expect(resolved.selectedCount, 1);
      expect(resolved.freeSlots, 2);
    });

    test('33. perder o nível de Bruxo deixa a seleção acima do limite', () {
      final character = _warlock(
        level: 2,
        invocations: const [
          'armor_of_shadows',
          'beast_speech',
          'devils_sight',
        ],
      );

      final resolved = _resolve(character);

      expect(resolved.limit, 2);
      expect(resolved.selectedCount, 3);
      expect(resolved.overLimit, 1);
      expect(resolved.freeSlots, 0);
      // Nenhuma é descartada por conta própria.
      expect(character.eldritchInvocations.length, 3);
    });

    test('34. tirar a classe Bruxo mantém a escolha visível e inválida', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 5)],
      ).copyWith(
        eldritchInvocations: const [
          CharacterEldritchInvocation(invocationId: 'devils_sight'),
        ],
      );

      final resolved = _resolve(character);

      expect(resolved.warlockLevel, 0);
      expect(resolved.options.length, 1);
      expect(resolved.invalid.single.id, 'devils_sight');
      expect(resolved.invalid.single.blockReason, 'Requer níveis na classe '
          'Bruxo.');
      expect(resolved.valid, isEmpty);
    });
  });

  // ------------------------------------------------------- efeitos mecânicos

  group('efeitos mecânicos', () {
    test('35. magia concedida vem com origem "Invocação Mística"', () {
      final character = _warlock(
        level: 2,
        invocations: const ['armor_of_shadows'],
      );

      final granted = _resolve(character).grantedSpells;

      expect(granted.length, 1);
      expect(granted.single.invocation.id, 'armor_of_shadows');
      expect(granted.single.grant.spellName, 'mage armor');
      expect(granted.single.grant.mode, InvocationSpellMode.atWill);
      expect(granted.single.grant.isFree, isTrue);
      expect(
        granted.single.grant.costLabel,
        'à vontade, sem gastar espaço de magia',
      );
      expect(invocationSpellSourceName, 'Invocação Mística');
      expect(invocationSpellSource, 'invocation');
    });

    test('36. magia de pacto declara o custo do espaço separadamente', () {
      final grant = catalog.byId('bewitching_whispers')!.spellGrants.single;

      expect(grant.spellName, 'compulsion');
      expect(grant.mode, InvocationSpellMode.oncePerLongRest);
      expect(grant.usesPactSlot, isTrue);
      expect(grant.isFree, isFalse);
      expect(
        grant.costLabel,
        'uma vez por descanso longo, gastando um espaço de Magia de Pacto',
      );

      // Servidão Imortal é o caso oposto: uma vez por descanso longo e SEM
      // gastar espaço.
      final free = catalog.byId('undying_servitude')!.spellGrants.single;
      expect(free.usesPactSlot, isFalse);
      expect(
        free.costLabel,
        'uma vez por descanso longo, sem gastar espaço de magia',
      );
    });

    test('37a. toda magia citada no catálogo existe no compêndio real', () {
      // Sem isso, um nome digitado errado no catálogo simplesmente não
      // entraria no livro do personagem, sem nenhum aviso: a sincronização
      // registra o nome em `unknownSpellNames` e segue.
      final spells = <SpellEntry>[];

      for (final path in spellAssetPaths) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'asset ausente: $path');

        final decoded =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        for (final row in decoded['dados'] as List<dynamic>) {
          final item = Map<String, dynamic>.from(row as Map);
          spells.add(
            _spell(
              item['id'] as int,
              item['nome'] as String? ?? '',
              item['original'] as String? ?? '',
              item['nivel'] as int? ?? 0,
            ),
          );
        }
      }

      final index = SpellNameIndex(spells);
      final missing = <String>[];

      for (final entry in entries) {
        for (final grant in entry.spellGrants) {
          if (index.find(grant.spellName) == null) {
            missing.add('${entry.id}: ${grant.spellName}');
          }
        }
      }

      expect(
        missing,
        isEmpty,
        reason: 'nomes de magia sem correspondência no compêndio',
      );
    });

    test('37. todo nome de magia do catálogo está em inglês e é único', () {
      final names = <String>{};

      for (final entry in entries) {
        for (final grant in entry.spellGrants) {
          expect(
            grant.spellName,
            grant.spellName.toLowerCase(),
            reason: '${entry.id}: nome de magia deveria ser minúsculo',
          );
          expect(
            RegExp(r'^[a-z ]+$').hasMatch(grant.spellName),
            isTrue,
            reason:
                '${entry.id}: "${grant.spellName}" não parece nome em inglês',
          );
          expect(grant.namePt, isNotNull, reason: entry.id);
          names.add(grant.spellName);
        }
      }

      expect(names, isNotEmpty);
    });

    test('38. usos limitados viram recurso e voltam no descanso certo', () {
      final character = _warlock(
        level: 5,
        invocations: const ['tomb_of_levistus', 'undying_servitude'],
      );

      final resolved = _resolve(character);
      final resources = FeatureResources.from(
        character: character,
        features: resolved.asFeatures,
        context: FeatureFormulaContext.fromCharacter(character),
      );

      expect(resources.length, 2);

      final shortRest = FeatureResources.featureIdsRestoredBy(
        features: resolved.asFeatures,
        recharges: FeatureResources.shortRestRecharges,
      );
      final longRest = FeatureResources.featureIdsRestoredBy(
        features: resolved.asFeatures,
        recharges: FeatureResources.longRestRecharges,
      );

      // Tumba de Levistus volta no curto; Servidão Imortal, só no longo.
      expect(shortRest, {
        EldritchInvocationEntry.featureIdFor('tomb_of_levistus'),
      });
      expect(longRest, {
        EldritchInvocationEntry.featureIdFor('tomb_of_levistus'),
        EldritchInvocationEntry.featureIdFor('undying_servitude'),
      });
    });

    test('39. gastar e devolver uso de invocação usa a chave estável', () {
      final character = _warlock(
        level: 5,
        invocations: const ['tomb_of_levistus'],
      );

      final resource = FeatureResources.from(
        character: character,
        features: _resolve(character).asFeatures,
        context: FeatureFormulaContext.fromCharacter(character),
      ).single;

      expect(
        resource.featureId,
        EldritchInvocationEntry.featureIdFor('tomb_of_levistus'),
      );
      expect(resource.usesLabel, '1 de 1');
      expect(resource.recharge, ActionRecharge.shortRest);

      final spent = FeatureResources.spend(
        character: character,
        resource: resource,
      );
      expect(spent.featureStateFor(resource.featureId)?.usesSpent, 1);

      final restored = FeatureResources.restoreAll(
        character: spent,
        featureIds: {resource.featureId},
      );
      expect(restored.featureStateFor(resource.featureId)?.usesSpent, 0);
    });

    test(
      '40. usos derivados do bônus de proficiência são calculados',
      () {
        final character = _warlock(
          level: 12,
          boon: PactBoon.talisman,
          invocations: const ['protection_of_the_talisman'],
        );

        final resource = FeatureResources.from(
          character: character,
          features: _resolve(character).asFeatures,
          context: FeatureFormulaContext.fromCharacter(character),
        ).single;

        // Nível 12 => bônus de proficiência 4.
        expect(character.proficiencyBonus, 4);
        expect(resource.maximum, 4);
      },
    );

    test('41. os modificadores de Rajada Mística somam', () {
      final character = _warlock(
        level: 11,
        charisma: 18,
        knownSpellIds: const [_eldritchBlastId],
        invocations: const [
          'agonizing_blast',
          'eldritch_spear',
          'repelling_blast',
          'grasp_of_hadar',
          'lance_of_lethargy',
        ],
      );

      final resolved = _resolve(character);
      final summary = EldritchInvocationResolver.blastSummaryFor(
        character: character,
        invocations: resolved,
      );

      expect(resolved.valid.length, 5);
      expect(summary.rays, 3, reason: '11º nível dispara três raios');
      expect(summary.rangeMeters, 90, reason: 'Lança Mística');
      expect(summary.damageBonus, 4, reason: 'Carisma 18 => +4');
      expect(summary.pushMeters, 3);
      expect(summary.pullMeters, 3);
      expect(summary.slowMeters, 3);
      expect(summary.sources.length, 5);
      expect(summary.hasModifiers, isTrue);
    });

    test('42. sem invocação de rajada não há resumo para mostrar', () {
      final character = _warlock(
        level: 5,
        invocations: const ['armor_of_shadows'],
      );

      final summary = EldritchInvocationResolver.blastSummaryFor(
        character: character,
        invocations: _resolve(character),
      );

      expect(summary.hasModifiers, isFalse);
      expect(summary.damageBonus, 0);
      expect(summary.rangeMeters, EldritchBlastSummary.defaultRangeMeters);
    });

    test('43. os raios seguem a tabela do truque', () {
      expect(EldritchBlastSummary.raysAt(1), 1);
      expect(EldritchBlastSummary.raysAt(4), 1);
      expect(EldritchBlastSummary.raysAt(5), 2);
      expect(EldritchBlastSummary.raysAt(10), 2);
      expect(EldritchBlastSummary.raysAt(11), 3);
      expect(EldritchBlastSummary.raysAt(16), 3);
      expect(EldritchBlastSummary.raysAt(17), 4);
      expect(EldritchBlastSummary.raysAt(20), 4);
    });

    test('44. a arma de pacto soma ataque, dano e foco', () {
      final character = _warlock(
        level: 12,
        boon: PactBoon.blade,
        charisma: 18,
        invocations: const [
          'thirsting_blade',
          'improved_pact_weapon',
          'lifedrinker',
          'eldritch_smite',
        ],
      );

      final summary = EldritchInvocationResolver.pactWeaponSummaryFor(
        character: character,
        invocations: _resolve(character),
      );

      expect(summary.attacks, 2, reason: 'Lâmina Sedenta');
      expect(summary.attackBonus, 1, reason: 'Arma de Pacto Aprimorada');
      expect(summary.damageBonusFlat, 1);
      expect(summary.damageBonus, 4, reason: 'Bebedor de Vida com Carisma 18');
      expect(summary.damageTypes, contains('necrótico'));
      expect(summary.isSpellcastingFocus, isTrue);
      expect(summary.allowsRanged, isTrue);
      expect(summary.extraDamageDice, isNotEmpty);
    });

    test('45. o piso de dano do Bebedor de Vida é 1', () {
      final character = _warlock(
        level: 12,
        boon: PactBoon.blade,
        charisma: 8,
        invocations: const ['lifedrinker'],
      );

      final summary = EldritchInvocationResolver.pactWeaponSummaryFor(
        character: character,
        invocations: _resolve(character),
      );

      // Carisma 8 dá modificador -1; a regra manda usar no mínimo 1.
      expect(summary.damageBonus, 1);
    });

    test('46. Influência Encantadora declara as perícias que concede', () {
      final entry = catalog.byId('beguiling_influence')!;

      expect(entry.skillProficiencies, ['deception', 'persuasion']);
      expect(entry.isPassive, isFalse);
      expect(entry.spellGrants, isEmpty);
    });
  });

  // ------------------------------------------------- dádiva do pacto e chaves

  group('dádiva do pacto', () {
    test('47. a dádiva é lida do estado da característica, por id', () {
      final character = _warlock(level: 3, boon: PactBoon.chain);

      expect(PactBoon.featureId, 'class.warlock.3.dadiva_do_pacto');
      expect(
        EldritchInvocationResolver.pactBoonOf(character),
        PactBoon.chain,
      );
      expect(
        character.featureStateFor(PactBoon.featureId)?.choiceOptionId,
        'pact_of_the_chain',
      );
    });

    test(
      '48. o id da característica bate com o que o resolvedor monta',
      () {
        expect(
          SpecialFeatureResolver.featureId(
            origin: FeatureOrigin.classFeature,
            originId: 'warlock',
            level: 3,
            name: 'Dádiva do Pacto',
          ),
          PactBoon.featureId,
        );
      },
    );

    test('49. o asset declara a escolha com os quatro ids estáveis', () {
      final features = (jsonDecode(
                File('assets/data/srd/class_features.json').readAsStringSync(),
              )
              as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .where((item) => item['class_id'] == 'warlock')
          .toList(growable: false);

      final level3 = features.firstWhere((item) => item['level'] == 3);
      final feature = Map<String, dynamic>.from(
        (level3['features'] as List<dynamic>).first as Map,
      );

      expect(feature['name'], 'Dádiva do Pacto');

      final choice = ClassFeature.tryParse(feature)!.choice!;
      expect(choice.id, PactBoon.choiceId);
      expect(choice.isRequired, isTrue);
      expect(
        choice.options.map((option) => option.id).toList(),
        PactBoon.values.map((boon) => boon.id).toList(),
      );
      for (final boon in PactBoon.values) {
        expect(choice.optionById(boon.id)?.label, boon.label);
      }
    });

    test('50. id de dádiva desconhecido não vira escolha válida', () {
      expect(PactBoon.fromId(null), isNull);
      expect(PactBoon.fromId(''), isNull);
      expect(PactBoon.fromId('Pacto da Lâmina'), isNull);
      expect(PactBoon.fromId('pact_of_the_blade'), PactBoon.blade);
      expect(PactBoon.fromId('  PACT_OF_THE_TOME '), PactBoon.tome);
    });

    test('51. trocar a dádiva invalida o que dependia da anterior', () {
      final blade = _warlock(
        level: 5,
        boon: PactBoon.blade,
        invocations: const ['thirsting_blade'],
      );
      expect(_resolve(blade).valid.map((i) => i.id), ['thirsting_blade']);

      final tome = blade.copyWith(
        featureStates: const [
          CharacterFeatureState(
            featureId: PactBoon.featureId,
            choiceOptionId: 'pact_of_the_tome',
          ),
        ],
      );

      final resolved = _resolve(tome);
      expect(resolved.valid, isEmpty);
      expect(resolved.invalid.map((i) => i.id), ['thirsting_blade']);
      expect(tome.eldritchInvocations.length, 1);
    });
  });

  // ------------------------------------------------------------- sincronização

  group('sincronização de magias', () {
    test('52. sincronizar duas vezes não duplica a magia concedida', () async {
      final repository = _FakeCharacterRepository(
        _warlock(level: 2, invocations: const ['armor_of_shadows']),
      );

      final useCase = SyncInvocationSpells(repository);

      Future<SyncInvocationSpellsResult> run() => useCase(
        characterId: 'c1',
        catalog: catalog,
        classes: [_warlockClass()],
        spellIndex: _spellIndex(),
        spells: _spells,
      );

      final first = await run();
      expect(first.added, 1);
      expect(first.removed, 0);
      expect(first.unknownSpellNames, isEmpty);
      expect(repository.character.spells.length, 1);

      final spell = repository.character.spells.single;
      expect(spell.sourceType, invocationSpellSource);
      expect(spell.sourceId, 'armor_of_shadows');
      expect(spell.sourceName, 'Invocação Mística');
      expect(spell.isAlwaysAvailable, isTrue);
      expect(spell.notes, contains('à vontade'));

      final second = await run();
      expect(second.added, 0);
      expect(second.removed, 0);
      expect(second.changed, isFalse);
      expect(repository.character.spells.length, 1);
    });

    test('53. a magia sai quando a invocação deixa de valer', () async {
      final repository = _FakeCharacterRepository(
        _warlock(level: 2, invocations: const ['armor_of_shadows']),
      );

      final useCase = SyncInvocationSpells(repository);

      await useCase(
        characterId: 'c1',
        catalog: catalog,
        classes: [_warlockClass()],
        spellIndex: _spellIndex(),
        spells: _spells,
      );
      expect(repository.character.spells.length, 1);

      // O jogador remove a invocação.
      repository.character = repository.character.copyWith(
        eldritchInvocations: const [],
      );

      final result = await useCase(
        characterId: 'c1',
        catalog: catalog,
        classes: [_warlockClass()],
        spellIndex: _spellIndex(),
        spells: _spells,
      );

      expect(result.removed, 1);
      expect(repository.character.spells, isEmpty);
    });

    test(
      '54. magia conhecida por outra fonte não é removida junto',
      () async {
        final repository = _FakeCharacterRepository(
          _warlock(level: 2, invocations: const ['armor_of_shadows']).copyWith(
            spells: const [
              CharacterSpell(
                spellId: _mageArmorId,
                sourceType: 'class',
                sourceId: 'warlock',
                sourceName: 'Bruxo',
                isPrepared: true,
                isKnown: true,
                isAlwaysAvailable: false,
              ),
            ],
          ),
        );

        final useCase = SyncInvocationSpells(repository);

        await useCase(
          characterId: 'c1',
          catalog: catalog,
          classes: [_warlockClass()],
          spellIndex: _spellIndex(),
          spells: _spells,
        );

        expect(repository.character.spells.length, 2);

        repository.character = repository.character.copyWith(
          eldritchInvocations: const [],
        );

        final result = await useCase(
          characterId: 'c1',
          catalog: catalog,
          classes: [_warlockClass()],
          spellIndex: _spellIndex(),
          spells: _spells,
        );

        expect(result.removed, 1);
        // A de classe fica.
        expect(repository.character.spells.length, 1);
        expect(repository.character.spells.single.sourceType, 'class');
      },
    );

    test('55. invocação inválida não coloca magia no livro', () async {
      final repository = _FakeCharacterRepository(
        // Pacto do Tomo com uma invocação de lâmina: inválida.
        _warlock(
          level: 5,
          boon: PactBoon.tome,
          invocations: const ['armor_of_shadows'],
        ).copyWith(
          eldritchInvocations: const [
            CharacterEldritchInvocation(invocationId: 'far_scribe'),
            CharacterEldritchInvocation(invocationId: 'tricksters_escape'),
          ],
        ),
      );

      final useCase = SyncInvocationSpells(repository);

      final result = await useCase(
        characterId: 'c1',
        catalog: catalog,
        classes: [_warlockClass()],
        spellIndex: _spellIndex(),
        spells: _spells,
      );

      // Escriba Distante é válida (Pacto do Tomo, nível 5) e concede Sending.
      // Fuga do Trapaceiro exige nível 7, então não concede nada.
      expect(result.added, 1);
      expect(repository.character.spells.single.sourceId, 'far_scribe');
    });
  });

  // -------------------------------------------------------------- persistência

  group('persistência', () {
    test('56. a chave de estado da invocação não colide com a de classe', () {
      expect(
        EldritchInvocationEntry.featureIdFor('agonizing_blast'),
        'invocation.agonizing_blast',
      );

      for (final entry in entries) {
        expect(entry.featureId, startsWith('invocation.'));
        expect(entry.featureId, isNot(startsWith('class.')));
        expect(entry.featureId, isNot(startsWith('subclass.')));
      }
    });

    test('57. a origem da invocação tem rótulo próprio', () {
      expect(FeatureOrigin.invocation.id, 'invocation');
      expect(FeatureOrigin.invocation.label, 'Invocação Mística');
    });

    test('58. o histórico de substituição sobrevive ao copyWith', () {
      const original = CharacterEldritchInvocation(
        invocationId: 'devils_sight',
        chosenAtLevel: 5,
        replacedInvocationId: 'beast_speech',
        replacedAtLevel: 5,
      );

      final copy = original.copyWith(chosenAtLevel: 7);

      expect(copy.invocationId, 'devils_sight');
      expect(copy.chosenAtLevel, 7);
      expect(copy.replacedInvocationId, 'beast_speech');
      expect(copy.replacedAtLevel, 5);
      expect(copy.replacedSomething, isTrue);
    });
  });
}

// ----------------------------------------------------------------- ferramentas

/// Id fictício, mas estável dentro deste arquivo, das magias usadas nos testes.
const int _eldritchBlastId = 9001;
const int _hexId = 9002;
const int _mageArmorId = 9003;
const int _sendingId = 9004;
const int _freedomId = 9005;
const int _animateDeadId = 9006;

final List<SpellEntry> _spells = [
  _spell(_eldritchBlastId, 'Rajada Mística', 'Eldritch Blast', 0),
  _spell(_hexId, 'Maldição', 'Hex', 1),
  _spell(_mageArmorId, 'Armadura Arcana', 'Mage Armor', 1),
  _spell(_sendingId, 'Mensagem Longa', 'Sending', 3),
  _spell(_freedomId, 'Liberdade de Movimento', 'Freedom of Movement', 4),
  _spell(_animateDeadId, 'Animar Mortos', 'Animate Dead', 3),
];

SpellEntry _spell(int id, String namePt, String nameOriginal, int level) {
  return SpellEntry(
    id: id,
    namePt: namePt,
    nameOriginal: nameOriginal,
    level: level,
    school: 'evocação',
    castingTime: '1 ação',
    range: '36 m',
    components: 'V, G',
    hasCostlyMaterials: false,
    duration: 'instantânea',
    concentration: false,
    ritual: false,
    classes: const ['warlock'],
    subclasses: const [],
    description: '',
    source: 'phb',
    page: '',
    isSrd: true,
  );
}

SpellNameIndex _spellIndex() => SpellNameIndex(_spells);

/// Uma invocação inventada, para exercitar caminho que o catálogo de 2014 não
/// usa: exigir outra invocação e ser incompatível com outra.
///
/// É dado de teste, e não conteúdo: o validador precisa suportar as duas
/// chaves porque elas existem no modelo, e acrescentá-las ao asset inventaria
/// regra que o livro não tem.
EldritchInvocationEntry _syntheticEntry({
  required String id,
  required String name,
  InvocationPrerequisites prerequisites = InvocationPrerequisites.none,
}) {
  return EldritchInvocationEntry(
    id: id,
    name: name,
    nameOriginal: name,
    description: 'Entrada de teste.',
    source: 'phb',
    prerequisites: prerequisites,
  );
}

/// Repositório em memória, só com o que a sincronização de magias usa.
///
/// Os demais métodos caem em `noSuchMethod` e falham se alguém os chamar — é o
/// que mantém o teste honesto sobre o que o caso de uso realmente toca.
class _FakeCharacterRepository implements CharacterRepository {
  _FakeCharacterRepository(this.character);

  Character character;

  @override
  Future<Character?> findById(String id) async => character;

  @override
  Future<void> addCharacterSpell({
    required String characterId,
    required CharacterSpell spell,
  }) async {
    character = character.copyWith(spells: [...character.spells, spell]);
  }

  @override
  Future<void> removeCharacterSpell({
    required String characterId,
    required int spellId,
    required String sourceType,
    required String sourceId,
  }) async {
    character = character.copyWith(
      spells: character.spells
          .where(
            (item) => !(item.spellId == spellId &&
                item.sourceType == sourceType &&
                item.sourceId == sourceId),
          )
          .toList(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

/// A entrada de classe do Bruxo com a progressão de 2014.
ClassEntry _warlockClass() {
  return const ClassEntry(
    id: 'warlock',
    name: 'Bruxo',
    hitDie: 'd8',
    source: 'srd',
    skillOptions: [],
    savingThrows: ['wisdom', 'charisma'],
    spellcastingType: 'pact',
    spellcastingAbility: 'charisma',
    subclassLevel: 1,
    invocationsKnown: {2: 2, 5: 3, 7: 4, 9: 5, 12: 6, 15: 7, 18: 8},
  );
}

/// A subclasse de A Lâmina Maldita, marcada como fonte de maldição.
const SubclassEntry _hexblade = SubclassEntry(
  id: 'warlock_hexblade',
  classId: 'warlock',
  name: 'A Lâmina Maldita',
  source: 'xge',
  tags: ['xge', 'maldicao'],
);

/// Um Bruxo pronto para teste, com o que a regra consulta.
Character _warlock({
  required int level,
  PactBoon? boon,
  List<String> invocations = const [],
  List<int> knownSpellIds = const [],
  String? subclassId,
  int charisma = 10,
}) {
  return characterFixture(
    abilityScores: scoresWith(charisma: charisma),
    classLevels: [
      ClassLevel(classId: 'warlock', level: level, subclassId: subclassId),
    ],
    spells: [
      for (final id in knownSpellIds)
        CharacterSpell(
          spellId: id,
          sourceType: 'class',
          sourceId: 'warlock',
          sourceName: 'Bruxo',
          isPrepared: true,
          isKnown: true,
          isAlwaysAvailable: false,
        ),
    ],
  ).copyWith(
    eldritchInvocations: [
      for (final id in invocations)
        CharacterEldritchInvocation(invocationId: id, chosenAtLevel: level),
    ],
    featureStates: [
      if (boon != null)
        CharacterFeatureState(
          featureId: PactBoon.featureId,
          choiceOptionId: boon.id,
        ),
    ],
  );
}

/// Atalho de resolução com o catálogo real e a classe de teste.
ResolvedInvocations _resolve(Character character) {
  return EldritchInvocationResolver.resolve(
    character: character,
    catalog: _catalogCache ??= EldritchInvocationCatalog.from([
      for (final item
          in (jsonDecode(
                    File(
                      'assets/data/srd/eldritch_invocations.json',
                    ).readAsStringSync(),
                  )
                  as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item as Map)))
        if (EldritchInvocationEntry.tryParse(item) case final entry?) entry,
    ]),
    classes: [_warlockClass()],
    subclasses: const [_hexblade],
    spells: _spells,
  );
}

EldritchInvocationCatalog? _catalogCache;
