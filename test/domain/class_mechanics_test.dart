import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_class_mechanic.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feature_state.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_prerequisites.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_selection.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_mechanic_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_prerequisite.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_table.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/class_mechanic_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

/// Testes das mecânicas internas de classe e subclasse.
///
/// O catálogo é montado à mão, e não lido do asset, de propósito: aqui se
/// testa a REGRA, e amarrar cada caso ao conteúdo real faria uma revisão de
/// texto no compêndio quebrar o teste de progressão. A fidelidade do asset é
/// verificada em `test/class_mechanics_asset_test.dart`.
void main() {
  group('desbloqueio por nível', () {
    test('mecânica de nível futuro não aparece como liberada', () {
      final resolved = _resolve(_fighter(level: 3));

      final runes = resolved.byId(_runesId);
      expect(runes, isNotNull);
      expect(runes!.isUnlocked, isTrue);

      // A mecânica do 7º nível não é alcançada por um Guerreiro de 3º.
      final elite = resolved.byId(_eliteId);
      expect(elite, isNotNull);
      expect(elite!.isUnlocked, isFalse);
      expect(elite.isVisible, isFalse);
      expect(
        elite.blocks.map((item) => item.kind),
        contains(MechanicBlockKind.classLevel),
      );
    });

    test('a mecânica aparece no nível de aquisição', () {
      final resolved = _resolve(_fighter(level: 7));

      expect(resolved.byId(_eliteId)!.isUnlocked, isTrue);
      expect(resolved.visible.map((item) => item.id), contains(_eliteId));
    });

    test('mecânica de outra subclasse não entra na ficha', () {
      final resolved = _resolve(
        _fighter(level: 3, subclassId: 'fighter_champion'),
      );

      expect(resolved.byId(_runesId), isNull);
    });
  });

  group('quantidade de escolhas por nível', () {
    test('o limite acompanha o nível na classe', () {
      expect(_resolve(_fighter(level: 3)).byId(_runesId)!.limit, 2);
      expect(_resolve(_fighter(level: 7)).byId(_runesId)!.limit, 3);
      expect(_resolve(_fighter(level: 10)).byId(_runesId)!.limit, 4);
      expect(_resolve(_fighter(level: 15)).byId(_runesId)!.limit, 5);
    });

    test('a contagem e as vagas livres refletem o que foi escolhido', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'cloud', 3)],
      );

      final runes = _resolve(character).byId(_runesId)!;

      expect(runes.selectedCount, 1);
      expect(runes.freeSlots, 1);
      expect(runes.countLabel, '1 de 2 conhecidas');
      expect(runes.hasPendingPicks, isTrue);
    });

    test('novas escolhas do nível são contadas à parte do total', () {
      expect(_resolve(_fighter(level: 3)).byId(_runesId)!.newPicksAtLevel, 2);
      expect(_resolve(_fighter(level: 7)).byId(_runesId)!.newPicksAtLevel, 1);
      // O 8º nível não concede runa nova.
      expect(_resolve(_fighter(level: 8)).byId(_runesId)!.newPicksAtLevel, 0);
    });

    test('tabela de consulta não gera vaga de escolha', () {
      final table = _resolve(_fighter(level: 3)).byId(_tableId)!;

      expect(table.entry.hasPicks, isFalse);
      expect(table.limit, 0);
      expect(table.freeSlots, 0);
      expect(table.hasPendingPicks, isFalse);
      expect(table.countLabel, isNull);
    });
  });

  group('pré-requisitos', () {
    test('opção com pré-requisito atendido fica disponível', () {
      final runes = _resolve(_fighter(level: 7)).byId(_runesId)!;

      expect(runes.optionById('hill')!.isAvailable, isTrue);
      expect(runes.optionById('hill')!.blocks, isEmpty);
    });

    test('opção sem o nível exigido fica bloqueada, mas visível', () {
      final runes = _resolve(_fighter(level: 3)).byId(_runesId)!;
      final hill = runes.optionById('hill')!;

      expect(hill.isBlocked, isTrue);
      expect(runes.options.map((item) => item.id), contains('hill'));
      expect(
        hill.blocks.map((item) => item.kind),
        contains(MechanicBlockKind.classLevel),
      );
      expect(hill.blockReason, contains('nível 7'));
    });

    test('opção com atributo insuficiente fica bloqueada', () {
      final weak = _fighter(level: 7, strength: 10);
      final strong = _fighter(level: 7, strength: 15);

      expect(
        _resolve(weak).byId(_runesId)!.optionById('storm')!.isBlocked,
        isTrue,
      );
      expect(
        _resolve(
          weak,
        ).byId(_runesId)!.optionById('storm')!.blocks.map((item) => item.kind),
        contains(MechanicBlockKind.abilityMinimum),
      );
      expect(
        _resolve(strong).byId(_runesId)!.optionById('storm')!.isAvailable,
        isTrue,
      );
    });

    test('opção que exige outra opção só libera depois dela', () {
      final without = _fighter(level: 7);
      final with_ = _fighter(
        level: 7,
        mechanics: [_pick(_runesId, 'cloud', 3)],
      );

      expect(
        _resolve(without).byId(_runesId)!.optionById('cloud_master')!.isBlocked,
        isTrue,
      );
      expect(
        _resolve(with_).byId(_runesId)!.optionById('cloud_master')!.isAvailable,
        isTrue,
      );
    });

    test('opção incompatível com uma já escolhida fica bloqueada', () {
      final character = _fighter(
        level: 7,
        mechanics: [_pick(_runesId, 'fire', 3)],
      );

      final frost = _resolve(character).byId(_runesId)!.optionById('frost')!;

      expect(frost.isBlocked, isTrue);
      expect(
        frost.blocks.map((item) => item.kind),
        contains(MechanicBlockKind.incompatibleOption),
      );
    });

    test(
      'opção já escolhida não se bloqueia pela própria incompatibilidade',
      () {
        final character = _fighter(
          level: 7,
          mechanics: [_pick(_runesId, 'fire', 3)],
        );

        final fire = _resolve(character).byId(_runesId)!.optionById('fire')!;

        expect(fire.isSelected, isTrue);
        expect(fire.blocks, isEmpty);
      },
    );

    test('a validação devolve TODOS os motivos do bloqueio', () {
      final blocks = ClassMechanicPrerequisites.evaluateOption(
        entry: _runes,
        option: _runes.optionById('storm')!,
        profile: const MechanicProfile(classLevels: {'fighter': 3}),
      );

      expect(
        blocks.map((item) => item.kind),
        containsAll([
          MechanicBlockKind.classLevel,
          MechanicBlockKind.abilityMinimum,
        ]),
      );
    });
  });

  group('seleção', () {
    test('escolher ocupa a vaga e registra o nível', () {
      final character = _fighter(level: 3);
      final mechanic = _resolve(character).byId(_runesId)!;

      final outcome = ClassMechanicSelection.select(
        character: character,
        mechanic: mechanic,
        optionId: 'cloud',
      );

      expect(outcome.changed, isTrue);
      expect(outcome.character.classMechanics, hasLength(1));
      expect(outcome.character.classMechanics.single.optionId, 'cloud');
      expect(outcome.character.classMechanics.single.chosenAtLevel, 3);
    });

    test('não é possível passar do limite do nível', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'cloud', 3), _pick(_runesId, 'fire', 3)],
      );

      final mechanic = _resolve(character).byId(_runesId)!;
      expect(mechanic.freeSlots, 0);

      final outcome = ClassMechanicSelection.select(
        character: character,
        mechanic: mechanic,
        optionId: 'stone',
      );

      expect(outcome.changed, isFalse);
      expect(outcome.isRejected, isTrue);
      expect(outcome.error, contains('2 de 2'));
      expect(outcome.character.classMechanics, hasLength(2));
    });

    test('opção bloqueada não entra nem com vaga livre', () {
      final character = _fighter(level: 3);
      final mechanic = _resolve(character).byId(_runesId)!;

      final outcome = ClassMechanicSelection.select(
        character: character,
        mechanic: mechanic,
        optionId: 'hill',
      );

      expect(outcome.changed, isFalse);
      expect(outcome.error, contains('nível 7'));
    });

    test('a mesma opção não é escolhida duas vezes', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'cloud', 3)],
      );

      final outcome = ClassMechanicSelection.select(
        character: character,
        mechanic: _resolve(character).byId(_runesId)!,
        optionId: 'cloud',
      );

      expect(outcome.changed, isFalse);
      expect(outcome.error, contains('já está selecionada'));
    });

    test('mecânica que permite repetir aceita a mesma opção de novo', () {
      final character = _fighter(
        level: 6,
        mechanics: [_pick(_totemId, 'bear', 3)],
      );

      final outcome = ClassMechanicSelection.select(
        character: character,
        mechanic: _resolve(character).byId(_totemId)!,
        optionId: 'bear',
      );

      expect(outcome.changed, isTrue);
      expect(outcome.character.classMechanics, hasLength(2));
    });

    test('remover libera a vaga e apaga o contador da opção', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'fire', 3)],
        featureStates: [
          CharacterFeatureState(
            featureId: ClassMechanicEntry.mechanicFeatureId(_runesId, 'fire'),
            usesSpent: 1,
          ),
        ],
      );

      final outcome = ClassMechanicSelection.remove(
        character: character,
        mechanic: _resolve(character).byId(_runesId)!,
        optionId: 'fire',
      );

      expect(outcome.changed, isTrue);
      expect(outcome.character.classMechanics, isEmpty);
      expect(outcome.character.featureStates, isEmpty);
    });
  });

  group('substituição', () {
    test('a troca é permitida quando a regra declara', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'cloud', 3)],
      );

      final outcome = ClassMechanicSelection.replace(
        character: character,
        mechanic: _resolve(character).byId(_runesId)!,
        replacedId: 'cloud',
        optionId: 'stone',
      );

      expect(outcome.changed, isTrue);

      final records = outcome.character.classMechanics;
      expect(records, hasLength(1));
      expect(records.single.optionId, 'stone');
      expect(records.single.replacedOptionId, 'cloud');
      expect(records.single.replacedAtLevel, 3);
    });

    test('a troca é recusada quando a mecânica não declara substituição', () {
      final character = _fighter(
        level: 6,
        mechanics: [_pick(_totemId, 'bear', 6)],
      );

      final outcome = ClassMechanicSelection.replace(
        character: character,
        mechanic: _resolve(character).byId(_totemId)!,
        replacedId: 'bear',
        optionId: 'eagle',
        freeEdit: true,
      );

      expect(outcome.changed, isFalse);
      expect(outcome.error, contains('não permite substituir'));
      expect(outcome.character.classMechanics.single.optionId, 'bear');
    });

    test('a candidata é validada sem contar a opção que sai', () {
      // Fogo e Gelo são incompatíveis. Trocar Fogo por Gelo tem de funcionar,
      // porque o que bloquearia é exatamente o que está saindo.
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'fire', 3)],
      );

      final outcome = ClassMechanicSelection.replace(
        character: character,
        mechanic: _resolve(character).byId(_runesId)!,
        replacedId: 'fire',
        optionId: 'frost',
      );

      expect(outcome.changed, isTrue);
      expect(outcome.character.classMechanics.single.optionId, 'frost');
    });

    test('a substituta ainda precisa cumprir os próprios pré-requisitos', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'cloud', 3)],
      );

      final outcome = ClassMechanicSelection.replace(
        character: character,
        mechanic: _resolve(character).byId(_runesId)!,
        replacedId: 'cloud',
        optionId: 'hill',
      );

      expect(outcome.changed, isFalse);
      expect(outcome.error, contains('nível 7'));
    });

    test('fora do momento autorizado a troca é recusada sem edição livre', () {
      // A Forma Estelar só troca ao aprender opção nova; no 4º nível não há.
      final character = _fighter(
        level: 4,
        mechanics: [_pick(_newPickId, 'alpha', 3)],
      );

      final mechanic = _resolve(character).byId(_newPickId)!;

      expect(mechanic.entry.canReplaceAt(4), isFalse);
      expect(mechanic.entry.canReplaceAt(4, freeEdit: true), isTrue);

      final strict = ClassMechanicSelection.replace(
        character: character,
        mechanic: mechanic,
        replacedId: 'alpha',
        optionId: 'beta',
      );

      expect(strict.changed, isFalse);
      expect(strict.error, contains('não está disponível agora'));

      final free = ClassMechanicSelection.replace(
        character: character,
        mechanic: mechanic,
        replacedId: 'alpha',
        optionId: 'beta',
        freeEdit: true,
      );

      expect(free.changed, isTrue);
    });
  });

  group('modos ativáveis', () {
    test('ligar e desligar grava o estado', () {
      final character = _fighter(level: 3);
      final mechanic = _resolve(character).byId(_modesId)!;

      final on = ClassMechanicSelection.activate(
        character: character,
        mechanic: mechanic,
        optionId: 'archer',
      );

      expect(on.changed, isTrue);

      final afterOn = _resolve(on.character).byId(_modesId)!;
      expect(afterOn.optionById('archer')!.isActive, isTrue);
      expect(afterOn.active.map((item) => item.id), ['archer']);

      final off = ClassMechanicSelection.deactivate(
        character: on.character,
        mechanic: afterOn,
        optionId: 'archer',
      );

      expect(off.changed, isTrue);
      expect(
        _resolve(off.character).byId(_modesId)!.optionById('archer')!.isActive,
        isFalse,
      );
    });

    test('com um modo por vez, ligar outro faz a transição e avisa', () {
      final character = _fighter(
        level: 3,
        featureStates: [
          CharacterFeatureState(
            featureId: ClassMechanicEntry.mechanicFeatureId(_modesId, 'archer'),
            isActive: true,
          ),
        ],
      );

      final outcome = ClassMechanicSelection.activate(
        character: character,
        mechanic: _resolve(character).byId(_modesId)!,
        optionId: 'chalice',
      );

      expect(outcome.changed, isTrue);
      expect(outcome.deactivated, ['Arqueiro']);
      expect(outcome.transitionNotice, contains('Arqueiro'));

      final after = _resolve(outcome.character).byId(_modesId)!;
      expect(after.optionById('archer')!.isActive, isFalse);
      expect(after.optionById('chalice')!.isActive, isTrue);
      expect(after.active, hasLength(1));
    });

    test('o limite de modos simultâneos bloqueia a ativação sem conflito', () {
      final character = _fighter(
        level: 3,
        mechanics: [
          _pick(_stacksId, 'flight', 3),
          _pick(_stacksId, 'swim', 3),
          _pick(_stacksId, 'squeeze', 3),
        ],
        featureStates: [
          CharacterFeatureState(
            featureId: ClassMechanicEntry.mechanicFeatureId(
              _stacksId,
              'flight',
            ),
            isActive: true,
          ),
          CharacterFeatureState(
            featureId: ClassMechanicEntry.mechanicFeatureId(_stacksId, 'swim'),
            isActive: true,
          ),
        ],
      );

      final mechanic = _resolve(character).byId(_stacksId)!;
      expect(mechanic.maxActive, 2);
      expect(mechanic.active, hasLength(2));

      final outcome = ClassMechanicSelection.activate(
        character: character,
        mechanic: mechanic,
        optionId: 'squeeze',
      );

      expect(outcome.changed, isFalse);
      expect(outcome.error, contains('Desative uma'));
    });

    test('modo inválido não pode ser ativado', () {
      // A opção exige nível 7 e o personagem está no 3º: ela fica inválida.
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'hill', 7)],
      );

      final mechanic = _resolve(character).byId(_runesId)!;
      expect(mechanic.optionById('hill')!.isInvalid, isTrue);

      final outcome = ClassMechanicSelection.activate(
        character: character,
        mechanic: mechanic,
        optionId: 'hill',
      );

      expect(outcome.changed, isFalse);
      expect(outcome.error, contains('perdeu os pré-requisitos'));
    });

    test('desativar todos encerra os modos da mecânica', () {
      final character = _fighter(
        level: 3,
        featureStates: [
          CharacterFeatureState(
            featureId: ClassMechanicEntry.mechanicFeatureId(_modesId, 'archer'),
            isActive: true,
          ),
        ],
      );

      final updated = ClassMechanicSelection.deactivateAll(
        character: character,
        mechanic: _resolve(character).byId(_modesId)!,
      );

      expect(_resolve(updated).byId(_modesId)!.active, isEmpty);
    });
  });

  group('efeitos', () {
    test('o bônus de modo só vale enquanto o modo está ligado', () {
      final off = _fighter(level: 3);
      final context = FeatureFormulaContext.fromCharacter(off);

      expect(_resolve(off).armorClassBonus(context), 0);

      final on = off.copyWith(
        featureStates: [
          CharacterFeatureState(
            featureId: ClassMechanicEntry.mechanicFeatureId(
              _modesId,
              'chalice',
            ),
            isActive: true,
          ),
        ],
      );

      expect(_resolve(on).armorClassBonus(context), 2);

      // Desligar devolve a CA ao que era: o bônus não fica preso na ficha.
      final again = on.copyWith(featureStates: const []);
      expect(_resolve(again).armorClassBonus(context), 0);
    });

    test('opção escolhida que não é modo aplica efeito direto', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'stone', 3)],
      );

      final stone = _resolve(character).byId(_runesId)!.optionById('stone')!;

      expect(stone.appliesEffects, isTrue);
    });

    test('opção inválida não aplica efeito', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'hill', 7)],
      );

      final hill = _resolve(character).byId(_runesId)!.optionById('hill')!;

      expect(hill.isInvalid, isTrue);
      expect(hill.appliesEffects, isFalse);
      expect(hill.calculatedEffects, isEmpty);
    });
  });

  group('recursos', () {
    test('o máximo acompanha a progressão e o gasto é persistido', () {
      final atThree = _resolve(_fighter(level: 3)).byId(_diceId)!;
      expect(atThree.resource!.maximum, 4);
      expect(atThree.resource!.remaining, 4);

      final atSeven = _resolve(_fighter(level: 7)).byId(_diceId)!;
      expect(atSeven.resource!.maximum, 5);

      final spent =
          _resolve(
            _fighter(
              level: 3,
              featureStates: [
                CharacterFeatureState(
                  featureId: ClassMechanicEntry.mechanicFeatureId(_diceId),
                  usesSpent: 3,
                ),
              ],
            ),
          ).byId(_diceId)!;

      expect(spent.resource!.remaining, 1);
      expect(spent.resource!.usesLabel, '1 de 4');
    });

    test('o gasto gravado nunca passa do máximo derivado', () {
      // Perder níveis reduz o máximo; o gasto antigo não pode virar negativo.
      final resolved =
          _resolve(
            _fighter(
              level: 3,
              featureStates: [
                CharacterFeatureState(
                  featureId: ClassMechanicEntry.mechanicFeatureId(_diceId),
                  usesSpent: 9,
                ),
              ],
            ),
          ).byId(_diceId)!;

      expect(resolved.resource!.spent, 4);
      expect(resolved.resource!.remaining, 0);
    });

    test('os usos de opção seguem a progressão da mecânica', () {
      final atThree =
          _resolve(
            _fighter(level: 3, mechanics: [_pick(_runesId, 'fire', 3)]),
          ).byId(_runesId)!;

      expect(atThree.optionById('fire')!.resource!.maximum, 1);

      final atFifteen =
          _resolve(
            _fighter(level: 15, mechanics: [_pick(_runesId, 'fire', 3)]),
          ).byId(_runesId)!;

      expect(atFifteen.optionById('fire')!.resource!.maximum, 2);
    });

    test('opção não conhecida não produz contador', () {
      final resolved = _resolve(_fighter(level: 3));

      expect(resolved.byId(_runesId)!.optionById('fire')!.resource, isNull);
      expect(
        resolved.resources.map((item) => item.featureId),
        isNot(contains(ClassMechanicEntry.mechanicFeatureId(_runesId, 'fire'))),
      );
    });

    test('o descanso devolve os recursos com a recarga correspondente', () {
      final resolved = _resolve(
        _fighter(level: 3, mechanics: [_pick(_runesId, 'fire', 3)]),
      );

      final short = resolved.featureIdsRestoredBy(const {
        ActionRecharge.shortRest,
      });

      expect(short, contains(ClassMechanicEntry.mechanicFeatureId(_diceId)));
      expect(
        short,
        contains(ClassMechanicEntry.mechanicFeatureId(_runesId, 'fire')),
      );

      // O recurso de descanso longo não volta num descanso curto.
      expect(
        short,
        isNot(contains(ClassMechanicEntry.mechanicFeatureId(_longRestId))),
      );

      final long = resolved.featureIdsRestoredBy(const {
        ActionRecharge.shortRest,
        ActionRecharge.longRest,
      });

      expect(long, contains(ClassMechanicEntry.mechanicFeatureId(_longRestId)));
    });

    test('o piso de usos protege fórmula de atributo que daria zero', () {
      final resolved = _resolve(_fighter(level: 3)).byId(_longRestId)!;

      // Inteligência 10 dá modificador 0; o piso declarado é 1.
      expect(resolved.resource!.maximum, 1);
    });
  });

  group('tabelas', () {
    test('a tabela de consulta fica disponível sem virar escolha', () {
      final mechanic = _resolve(_fighter(level: 3)).byId(_tableId)!;
      final table = mechanic.table!;

      expect(table.rows, hasLength(3));
      expect(table.isRollable, isFalse);
      expect(table.effectiveColumns, ['Ambiente', 'Nível 3']);
      expect(mechanic.entry.hasPicks, isFalse);
      expect(mechanic.options, isEmpty);
    });

    test('a tabela de rolagem casa o resultado com a faixa', () {
      final table = _resolve(_fighter(level: 3)).byId(_rollId)!.table!;

      expect(table.isRollable, isTrue);
      expect(table.faces, 100);
      expect(table.rowFor(1)!.id, 'low');
      expect(table.rowFor(2)!.id, 'low');
      expect(table.rowFor(50)!.id, 'mid');
      expect(table.rowFor(100)!.id, 'high');
      expect(table.rowFor(0), isNull);
    });

    test('registrar o resultado grava a linha, sem contar como escolha', () {
      final character = _fighter(level: 3);
      final mechanic = _resolve(character).byId(_rollId)!;

      final outcome = ClassMechanicSelection.setRollResult(
        character: character,
        mechanic: mechanic,
        rowId: 'mid',
      );

      expect(outcome.changed, isTrue);

      final record = outcome.character.classMechanics.single;
      expect(record.rollResult, 'mid');
      expect(record.countsAsPick, isFalse);

      final after = _resolve(outcome.character).byId(_rollId)!;
      expect(after.rollResultRowId, 'mid');
      expect(after.rollResultRow!.label, '50');
      expect(after.selectedCount, 0);
    });

    test('resultado fora da tabela é recusado', () {
      final character = _fighter(level: 3);

      final outcome = ClassMechanicSelection.setRollResult(
        character: character,
        mechanic: _resolve(character).byId(_rollId)!,
        rowId: 'inexistente',
      );

      expect(outcome.changed, isFalse);
      expect(outcome.error, contains('não existe na tabela'));
    });

    test(
      'apagar o resultado remove a linha em vez de deixar registro vazio',
      () {
        final character = _fighter(level: 3);
        final mechanic = _resolve(character).byId(_rollId)!;

        final withResult =
            ClassMechanicSelection.setRollResult(
              character: character,
              mechanic: mechanic,
              rowId: 'high',
            ).character;

        final cleared = ClassMechanicSelection.clearRollResult(
          character: withResult,
          mechanic: _resolve(withResult).byId(_rollId)!,
        );

        expect(cleared.changed, isTrue);
        expect(cleared.character.classMechanics, isEmpty);
      },
    );

    test('a busca filtra as linhas da tabela', () {
      final table = _resolve(_fighter(level: 3)).byId(_rollId)!.table!;

      expect(table.search('bola').map((item) => item.id), ['mid']);
      expect(table.search(''), hasLength(3));
      expect(table.search('inexistente'), isEmpty);
    });
  });

  group('mudança de classe, subclasse e nível', () {
    test('trocar a subclasse esconde a mecânica e preserva o registro', () {
      final chosen = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'cloud', 3)],
      );

      final swapped = chosen.copyWith(
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            level: 3,
            subclassId: 'fighter_champion',
          ),
        ],
      );

      expect(_resolve(swapped).byId(_runesId), isNull);
      // A escolha continua gravada: voltar para a subclasse a traz de volta.
      expect(swapped.classMechanics, hasLength(1));
      expect(_resolve(chosen).byId(_runesId)!.selectedCount, 1);
    });

    test('reduzir o nível marca o excesso em vez de apagar', () {
      final high = _fighter(
        level: 7,
        mechanics: [
          _pick(_runesId, 'cloud', 3),
          _pick(_runesId, 'fire', 3),
          _pick(_runesId, 'stone', 7),
        ],
      );

      expect(_resolve(high).byId(_runesId)!.overLimit, 0);

      final reduced = high.copyWith(
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            level: 3,
            subclassId: 'fighter_rune_knight',
          ),
        ],
      );

      final mechanic = _resolve(reduced).byId(_runesId)!;

      expect(mechanic.limit, 2);
      expect(mechanic.selectedCount, 3);
      expect(mechanic.overLimit, 1);
      expect(mechanic.badgeLabel, 'acima do limite');
      expect(reduced.classMechanics, hasLength(3));
    });

    test('perder o nível da opção a marca como inválida, não a apaga', () {
      final reduced = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'hill', 7)],
      );

      final mechanic = _resolve(reduced).byId(_runesId)!;

      expect(mechanic.optionById('hill')!.isInvalid, isTrue);
      expect(mechanic.hasInvalid, isTrue);
      expect(mechanic.badgeLabel, 'revisar');
      expect(reduced.classMechanics, hasLength(1));
    });

    test('opção que saiu do catálogo aparece como inválida', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'runa_que_nao_existe', 3)],
      );

      final orphan =
          _resolve(
            character,
          ).byId(_runesId)!.optionById('runa_que_nao_existe')!;

      expect(orphan.isInvalid, isTrue);
      expect(
        orphan.blocks.map((item) => item.kind),
        contains(MechanicBlockKind.unknownOption),
      );
    });
  });

  group('multiclasse', () {
    test('o limite usa o nível da classe responsável, não o total', () {
      final multi = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            level: 3,
            subclassId: 'fighter_rune_knight',
          ),
          ClassLevel(classId: 'wizard', level: 9),
        ],
      );

      final mechanic = _resolve(multi).byId(_runesId)!;

      expect(multi.totalLevel, 12);
      expect(mechanic.classLevel, 3);
      expect(mechanic.limit, 2);
    });

    test('pré-requisito de nível também é por classe', () {
      final multi = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            level: 3,
            subclassId: 'fighter_rune_knight',
          ),
          ClassLevel(classId: 'wizard', level: 9),
        ],
      );

      expect(
        _resolve(multi).byId(_runesId)!.optionById('hill')!.isBlocked,
        isTrue,
      );
    });

    test('a mesma mecânica não é resolvida duas vezes', () {
      final multi = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            level: 3,
            subclassId: 'fighter_rune_knight',
          ),
          ClassLevel(classId: 'wizard', level: 2),
        ],
      );

      final ids = _resolve(multi).mechanics.map((item) => item.id).toList();

      expect(ids.where((id) => id == _runesId), hasLength(1));
    });
  });

  group('duplicidade', () {
    test('registro repetido do mesmo par gasta uma vaga só', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'cloud', 3), _pick(_runesId, 'cloud', 3)],
      );

      expect(_resolve(character).byId(_runesId)!.selectedCount, 1);
    });

    test('o catálogo descarta entrada com id repetido', () {
      final catalog = ClassMechanicCatalog.from([_runes, _runes]);

      expect(catalog.length, 1);
      expect(catalog.duplicates, hasLength(1));
      expect(catalog.duplicates.single.matchedBy, 'identificador');
    });

    test('o catálogo descarta a mesma mecânica com id diferente', () {
      final clone = ClassMechanicEntry(
        id: 'outro_id',
        name: _runes.name,
        classId: _runes.classId,
        subclassId: _runes.subclassId,
        level: _runes.level,
        source: _runes.source,
      );

      final catalog = ClassMechanicCatalog.from([_runes, clone]);

      expect(catalog.length, 1);
      expect(catalog.duplicates.single.matchedBy, 'origem e nome');
    });

    test('opção repetida no asset entra uma vez só', () {
      final entry = ClassMechanicEntry.tryParse({
        'id': 'x.y',
        'name': 'X',
        'class_id': 'fighter',
        'level': 3,
        'kinds': ['known_list'],
        'options': [
          {'id': 'a', 'name': 'A'},
          {'id': 'a', 'name': 'A de novo'},
        ],
      });

      expect(entry!.options, hasLength(1));
      expect(entry.options.single.name, 'A');
    });
  });

  group('pendências e revisão', () {
    test('as pendências só contam mecânica liberada com vaga em aberto', () {
      final resolved = _resolve(_fighter(level: 3));

      expect(resolved.hasPending, isTrue);
      expect(resolved.pending.map((item) => item.id), contains(_runesId));
      // Mecânica de nível futuro não é pendência.
      expect(
        resolved.pending.map((item) => item.id),
        isNot(contains(_eliteId)),
      );
      // Tabela de consulta e modo também não.
      expect(
        resolved.pending.map((item) => item.id),
        isNot(contains(_tableId)),
      );
      expect(
        resolved.pending.map((item) => item.id),
        isNot(contains(_modesId)),
      );
    });

    test('completar as vagas zera a pendência', () {
      final character = _fighter(
        level: 3,
        mechanics: [
          _pick(_runesId, 'cloud', 3),
          _pick(_runesId, 'stone', 3),
          _pick(_totemId, 'bear', 3),
          _pick(_newPickId, 'alpha', 3),
          _pick(_stacksId, 'flight', 3),
          _pick(_stacksId, 'swim', 3),
          _pick(_stacksId, 'squeeze', 3),
        ],
      );

      final resolved = _resolve(character);

      expect(resolved.byId(_runesId)!.hasPendingPicks, isFalse);
      expect(resolved.pending, isEmpty);
      expect(resolved.hasPending, isFalse);
    });

    test('reiniciar apaga as escolhas e os contadores da mecânica', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'cloud', 3), _pick(_totemId, 'bear', 3)],
        featureStates: [
          CharacterFeatureState(
            featureId: ClassMechanicEntry.mechanicFeatureId(_runesId),
            usesSpent: 2,
          ),
          CharacterFeatureState(
            featureId: ClassMechanicEntry.mechanicFeatureId(_runesId, 'cloud'),
            usesSpent: 1,
          ),
          CharacterFeatureState(
            featureId: ClassMechanicEntry.mechanicFeatureId(_totemId, 'bear'),
            usesSpent: 1,
          ),
        ],
      );

      final outcome = ClassMechanicSelection.reset(
        character: character,
        mechanic: _resolve(character).byId(_runesId)!,
      );

      expect(outcome.changed, isTrue);
      // A outra mecânica fica intacta.
      expect(outcome.character.classMechanics.map((item) => item.mechanicId), [
        _totemId,
      ]);
      expect(outcome.character.featureStates.map((item) => item.featureId), [
        ClassMechanicEntry.mechanicFeatureId(_totemId, 'bear'),
      ]);
    });
  });

  group('resumo para a interface', () {
    test('o resumo diz contagem, usos e modo ligado', () {
      final character = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'cloud', 3)],
      );

      expect(
        _resolve(character).byId(_runesId)!.summaryLabel,
        '1 de 2 conhecidas',
      );

      expect(
        _resolve(_fighter(level: 3)).byId(_diceId)!.summaryLabel,
        contains('4 de 4 usos'),
      );

      final withMode = _fighter(
        level: 3,
        featureStates: [
          CharacterFeatureState(
            featureId: ClassMechanicEntry.mechanicFeatureId(_modesId, 'archer'),
            isActive: true,
          ),
        ],
      );

      expect(
        _resolve(withMode).byId(_modesId)!.summaryLabel,
        contains('ativo: Arqueiro'),
      );
    });

    test('o indicador aponta o que precisa de ação', () {
      expect(
        _resolve(_fighter(level: 3)).byId(_runesId)!.badgeLabel,
        '2 escolhas pendentes',
      );

      final complete = _fighter(
        level: 3,
        mechanics: [_pick(_runesId, 'cloud', 3), _pick(_runesId, 'stone', 3)],
      );

      expect(_resolve(complete).byId(_runesId)!.badgeLabel, isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Catálogo de teste
// ---------------------------------------------------------------------------

const String _runesId = 'fighter_rune_knight.runes';
const String _eliteId = 'fighter_rune_knight.elite';
const String _diceId = 'fighter_rune_knight.dice';
const String _longRestId = 'fighter_rune_knight.long_rest';
const String _tableId = 'fighter_rune_knight.aura_table';
const String _rollId = 'fighter_rune_knight.surge';
const String _modesId = 'fighter_rune_knight.modes';
const String _stacksId = 'fighter_rune_knight.stacks';
const String _totemId = 'fighter_rune_knight.totem';
const String _newPickId = 'fighter_rune_knight.new_pick';

/// Lista de opções conhecidas com pré-requisito, incompatibilidade,
/// dependência entre opções, usos por opção e substituição ao subir de nível.
final ClassMechanicEntry _runes = ClassMechanicEntry(
  id: _runesId,
  name: 'Runas',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'tce',
  kinds: const {ClassMechanicKind.knownList, ClassMechanicKind.limitedResource},
  replacement: const MechanicReplacement(
    trigger: MechanicReplacementTrigger.levelUp,
  ),
  progression: const [
    MechanicProgressionStep(level: 3, picks: 2, optionUses: 1),
    MechanicProgressionStep(level: 7, picks: 3, optionUses: 1),
    MechanicProgressionStep(level: 10, picks: 4, optionUses: 1),
    MechanicProgressionStep(level: 15, picks: 5, optionUses: 2),
  ],
  options: const [
    MechanicOption(id: 'cloud', name: 'Nuvem', description: 'Redireciona.'),
    MechanicOption(
      id: 'fire',
      name: 'Fogo',
      description: 'Queima.',
      incompatibleWith: ['frost'],
      action: FeatureAction(
        type: CombatActionType.special,
        uses: 1,
        recharge: ActionRecharge.shortRest,
      ),
    ),
    MechanicOption(
      id: 'frost',
      name: 'Gelo',
      description: 'Congela.',
      incompatibleWith: ['fire'],
    ),
    MechanicOption(
      id: 'stone',
      name: 'Pedra',
      description: 'Enfeitiça.',
      effects: [
        FeatureEffect(
          id: 'rune.stone.darkvision',
          path: 'sense.darkvision',
          operation: FeatureEffectOperation.max,
          formula: '36',
        ),
      ],
    ),
    MechanicOption(
      id: 'hill',
      name: 'Colina',
      description: 'Resiste.',
      prerequisites: MechanicPrerequisite(classLevel: 7),
      isMode: true,
    ),
    MechanicOption(
      id: 'storm',
      name: 'Tempestade',
      description: 'Prevê.',
      prerequisites: MechanicPrerequisite(
        classLevel: 7,
        abilityMinimums: {Ability.strength: 13},
      ),
    ),
    MechanicOption(
      id: 'cloud_master',
      name: 'Mestre das Nuvens',
      description: 'Depende da Nuvem.',
      prerequisites: MechanicPrerequisite(options: ['cloud']),
    ),
  ],
);

/// Mecânica de nível futuro, para o corte por nível.
const ClassMechanicEntry _elite = ClassMechanicEntry(
  id: _eliteId,
  name: 'Escudo Rúnico',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 7,
  source: 'tce',
  kinds: {ClassMechanicKind.limitedResource},
);

/// Recurso compartilhado com progressão de usos.
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
  progression: [
    MechanicProgressionStep(level: 3, uses: 4),
    MechanicProgressionStep(level: 7, uses: 5),
    MechanicProgressionStep(level: 15, uses: 6),
  ],
);

/// Recurso de descanso longo com fórmula de atributo e piso declarado.
const ClassMechanicEntry _longRest = ClassMechanicEntry(
  id: _longRestId,
  name: 'Impacto Arcano',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'tce',
  kinds: {ClassMechanicKind.limitedResource},
  usesMinimum: 1,
  action: FeatureAction(
    type: CombatActionType.special,
    usesFormula: 'mod.int',
    recharge: ActionRecharge.longRest,
  ),
);

/// Tabela de consulta pura: nenhuma linha vira escolha.
const ClassMechanicEntry _lookupTable = ClassMechanicEntry(
  id: _tableId,
  name: 'Aura da Tempestade',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'tce',
  kinds: {ClassMechanicKind.lookupTable},
  table: MechanicTable(
    id: '$_tableId.table',
    title: 'Efeito por nível',
    columns: ['Ambiente', 'Nível 3'],
    rows: [
      MechanicTableRow(id: 'desert', label: 'Deserto', values: ['2 de fogo']),
      MechanicTableRow(id: 'sea', label: 'Mar', values: ['1d6 elétrico']),
      MechanicTableRow(id: 'tundra', label: 'Tundra', values: ['2 PV temp']),
    ],
  ),
);

/// Tabela de rolagem d100 com faixas.
const ClassMechanicEntry _rollTable = ClassMechanicEntry(
  id: _rollId,
  name: 'Surto de Magia Selvagem',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'tce',
  kinds: {ClassMechanicKind.rollTable},
  table: MechanicTable(
    id: '$_rollId.table',
    title: 'Surto (d100)',
    dice: 'd100',
    rows: [
      MechanicTableRow(
        id: 'low',
        label: '01–02',
        min: 1,
        max: 2,
        values: ['Role de novo nesta tabela.'],
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
        label: '99–00',
        min: 99,
        max: 100,
        values: ['Recupera todos os pontos gastos.'],
      ),
    ],
  ),
);

/// Modos mutuamente exclusivos, com um ativo por vez e bônus de CA.
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
      effects: [
        FeatureEffect(
          id: 'modes.chalice.ac',
          path: FeatureEffectPaths.armorClassBonus,
          operation: FeatureEffectOperation.add,
          formula: '2',
        ),
      ],
    ),
  ],
);

/// Modos que se acumulam, com teto maior que um.
const ClassMechanicEntry _stacks = ClassMechanicEntry(
  id: _stacksId,
  name: 'Revelação da Carne',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'tce',
  kinds: {ClassMechanicKind.knownList, ClassMechanicKind.activatableMode},
  maxActiveOptions: 2,
  progression: [MechanicProgressionStep(level: 3, picks: 3)],
  options: [
    MechanicOption(
      id: 'flight',
      name: 'Voo',
      description: 'Voa.',
      isMode: true,
    ),
    MechanicOption(
      id: 'swim',
      name: 'Natação',
      description: 'Nada.',
      isMode: true,
    ),
    MechanicOption(
      id: 'squeeze',
      name: 'Corpo Maleável',
      description: 'Passa.',
      isMode: true,
    ),
  ],
);

/// Escolha permanente que aceita repetir a opção e não permite troca.
const ClassMechanicEntry _totem = ClassMechanicEntry(
  id: _totemId,
  name: 'Aspecto da Besta',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'phb',
  kinds: {ClassMechanicKind.permanentChoice},
  allowDuplicateOptions: true,
  progression: [
    MechanicProgressionStep(level: 3, picks: 1),
    MechanicProgressionStep(level: 6, picks: 2),
  ],
  options: [
    MechanicOption(id: 'bear', name: 'Urso', description: 'Carrega.'),
    MechanicOption(id: 'eagle', name: 'Águia', description: 'Vê.'),
  ],
);

/// Substituição permitida apenas nos níveis que concedem escolha nova.
const ClassMechanicEntry _newPick = ClassMechanicEntry(
  id: _newPickId,
  name: 'Manobras',
  classId: 'fighter',
  subclassId: 'fighter_rune_knight',
  level: 3,
  source: 'phb',
  kinds: {ClassMechanicKind.knownList},
  replacement: MechanicReplacement(trigger: MechanicReplacementTrigger.newPick),
  progression: [
    MechanicProgressionStep(level: 3, picks: 1),
    MechanicProgressionStep(level: 7, picks: 2),
  ],
  options: [
    MechanicOption(id: 'alpha', name: 'Alfa', description: 'A.'),
    MechanicOption(id: 'beta', name: 'Beta', description: 'B.'),
  ],
);

final ClassMechanicCatalog _catalog = ClassMechanicCatalog.from([
  _runes,
  _elite,
  _dice,
  _longRest,
  _lookupTable,
  _rollTable,
  _modes,
  _stacks,
  _totem,
  _newPick,
]);

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
  ClassEntry(
    id: 'wizard',
    name: 'Mago',
    hitDie: 'd6',
    source: 'phb',
    skillOptions: [],
    savingThrows: [],
    subclassLevel: 2,
  ),
];

const List<SubclassEntry> _subclasses = [
  SubclassEntry(
    id: 'fighter_rune_knight',
    classId: 'fighter',
    name: 'Cavaleiro Rúnico',
    source: 'tce',
  ),
  SubclassEntry(
    id: 'fighter_champion',
    classId: 'fighter',
    name: 'Campeão',
    source: 'phb',
  ),
];

ResolvedClassMechanics _resolve(Character character) {
  return ClassMechanicResolver.resolve(
    character: character,
    catalog: _catalog,
    classes: _classes,
    subclasses: _subclasses,
  );
}

Character _fighter({
  required int level,
  String subclassId = 'fighter_rune_knight',
  int strength = 10,
  List<CharacterClassMechanic> mechanics = const [],
  List<CharacterFeatureState> featureStates = const [],
}) {
  return characterFixture(
    abilityScores: scoresWith(strength: strength),
    classLevels: [
      ClassLevel(classId: 'fighter', level: level, subclassId: subclassId),
    ],
    classMechanics: mechanics,
    featureStates: featureStates,
  );
}

CharacterClassMechanic _pick(String mechanicId, String optionId, int level) {
  return CharacterClassMechanic(
    mechanicId: mechanicId,
    optionId: optionId,
    chosenAtLevel: level,
  );
}
