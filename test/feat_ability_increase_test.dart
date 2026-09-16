import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_character_feats.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_json_codec.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_ability_increases.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Aumento de atributo concedido por talento.
///
/// O dado já existia no compêndio, mas não chegava à ficha: o talento era
/// gravado e o atributo continuava igual. O que estes testes protegem é o
/// caminho todo — o teto de 20, o registro do que de fato entrou, e a
/// devolução exata quando o talento sai.
class _FakeCharacterRepository implements CharacterRepository {
  _FakeCharacterRepository(this.stored);

  Character stored;

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Future<void> update(Character character) async {
    stored = character;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

/// Durável: +1 de Constituição, sem escolha.
const _tough = FeatEntry(
  id: 'tough',
  name: 'Durável',
  abilityIncreases: {'constitution': 1},
);

/// Resiliente: escolhe o atributo, e pode ser pego mais de uma vez.
const _resilient = FeatEntry(
  id: 'resilient',
  name: 'Resiliente',
  repeatable: true,
  abilityIncreaseOptions: [
    'strength',
    'dexterity',
    'constitution',
    'intelligence',
    'wisdom',
    'charisma',
  ],
);

/// Atleta: escolhe entre dois atributos.
const _athlete = FeatEntry(
  id: 'athlete',
  name: 'Atleta',
  abilityIncreaseOptions: ['strength', 'dexterity'],
);

/// Talento inventado só para o teste: +1 fixo e mais uma escolha no mesmo
/// atributo, para conferir que os dois se somam.
const _double = FeatEntry(
  id: 'double',
  name: 'Dobrado',
  abilityIncreases: {'strength': 1},
  abilityIncreaseOptions: ['strength', 'dexterity'],
);

void main() {
  group('GrantedAbilityIncreases.wanted', () {
    test('junta o aumento fixo com o atributo escolhido', () {
      final wanted = GrantedAbilityIncreases.wanted(
        fixed: const {'constitution': 1},
        chosen: Ability.strength,
      );

      expect(wanted, {'constitution': 1, 'strength': 1});
    });

    test('escolha no mesmo atributo do fixo vale +2', () {
      final wanted = GrantedAbilityIncreases.wanted(
        fixed: const {'strength': 1},
        chosen: Ability.strength,
      );

      expect(wanted, {'strength': 2});
    });

    test('sem escolha devolve só o fixo', () {
      final wanted = GrantedAbilityIncreases.wanted(
        fixed: const {'wisdom': 1},
      );

      expect(wanted, {'wisdom': 1});
    });
  });

  group('GrantedAbilityIncreases.resolve', () {
    test('aumento cabe inteiro quando há folga até 20', () {
      final applied = GrantedAbilityIncreases.resolve(
        scoresWith(constitution: 14),
        const {'constitution': 1},
      );

      expect(applied, {'constitution': 1});
    });

    test('19 mais 1 chega exatamente em 20', () {
      final applied = GrantedAbilityIncreases.resolve(
        scoresWith(strength: 19),
        const {'strength': 1},
      );

      expect(applied, {'strength': 1});
    });

    test('atributo no teto de 20 não rende nada, e nada é registrado', () {
      // Não registrar é o que impede a remoção de tirar um ponto que o talento
      // nunca deu.
      final applied = GrantedAbilityIncreases.resolve(
        scoresWith(constitution: 20),
        const {'constitution': 1},
      );

      expect(applied, isEmpty);
    });

    test('aumento que passaria de 20 é aparado no que cabe', () {
      final applied = GrantedAbilityIncreases.resolve(
        scoresWith(strength: 19),
        const {'strength': 2},
      );

      expect(applied, {'strength': 1});
    });

    test('atributo acima de 20 também não rende aumento', () {
      // A entidade aceita até 30 porque magia e monstro passam de 20; quem
      // sobe atributo, não.
      final applied = GrantedAbilityIncreases.resolve(
        scoresWith(strength: 22),
        const {'strength': 1},
      );

      expect(applied, isEmpty);
    });

    test('nome fora dos seis atributos é ignorado', () {
      final applied = GrantedAbilityIncreases.resolve(
        flatScores,
        const {'luck': 1, 'wisdom': 1},
      );

      expect(applied, {'wisdom': 1});
    });

    test('valor zero ou negativo não entra', () {
      final applied = GrantedAbilityIncreases.resolve(
        flatScores,
        const {'wisdom': 0, 'charisma': -2},
      );

      expect(applied, isEmpty);
    });
  });

  group('GrantedAbilityIncreases apply e revoke', () {
    test('apply soma e revoke devolve, voltando ao valor original', () {
      const increases = {'strength': 1, 'wisdom': 1};
      final original = scoresWith(strength: 15, wisdom: 12);

      final applied = GrantedAbilityIncreases.apply(original, increases);
      expect(applied.strength, 16);
      expect(applied.wisdom, 13);
      expect(applied.dexterity, 10, reason: 'atributo intocado não muda');

      final reverted = GrantedAbilityIncreases.revoke(applied, increases);
      expect(reverted.strength, 15);
      expect(reverted.wisdom, 12);
    });

    test('revoke não desce abaixo de 1', () {
      // Só acontece com ficha importada trazendo um mapa incoerente, mas o
      // value object tem assert de mínimo 1 e não pode estourar.
      final reverted = GrantedAbilityIncreases.revoke(
        scoresWith(strength: 2),
        const {'strength': 9},
      );

      expect(reverted.strength, 1);
    });
  });

  group('CSV do aumento aplicado', () {
    test('vai e volta pelo CSV', () {
      const increases = {'constitution': 1, 'strength': 2};
      final csv = GrantedAbilityIncreases.toCsv(increases);

      expect(GrantedAbilityIncreases.parseCsv(csv), increases);
    });

    test('mapa vazio vira string vazia, e string vazia vira mapa vazio', () {
      expect(GrantedAbilityIncreases.toCsv(const {}), '');
      expect(GrantedAbilityIncreases.parseCsv(''), isEmpty);
      expect(GrantedAbilityIncreases.parseCsv(null), isEmpty);
    });

    test('descarta par malformado, atributo desconhecido e valor inválido', () {
      final parsed = GrantedAbilityIncreases.parseCsv(
        ' wisdom : 1 ,solto,luck:2,strength:abc,charisma:0,dexterity:1',
      );

      expect(parsed, {'wisdom': 1, 'dexterity': 1});
    });
  });

  group('ManageCharacterFeats aplica o aumento', () {
    test('talento com aumento fixo sobe o atributo e registra o que entrou',
        () async {
      final repository = _FakeCharacterRepository(
        characterFixture(abilityScores: scoresWith(constitution: 14)),
      );

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _tough,
      );

      final saved = repository.stored;
      expect(saved.abilityScores.constitution, 15);
      expect(saved.feats.single.appliedAbilityIncreases, {'constitution': 1});
      expect(saved.feats.single.chosenAbility, isNull);
    });

    test('talento com escolha sobe o atributo escolhido', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(abilityScores: scoresWith(dexterity: 13)),
      );

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _athlete,
        chosenAbility: Ability.dexterity,
      );

      final saved = repository.stored;
      expect(saved.abilityScores.dexterity, 14);
      expect(saved.abilityScores.strength, 10);
      expect(saved.feats.single.chosenAbility, Ability.dexterity);
      expect(saved.feats.single.appliedAbilityIncreases, {'dexterity': 1});
    });

    test('escolha fora das opções do talento é descartada', () async {
      // A tela só oferece o que o talento permite, mas uma ficha importada
      // poderia trazer qualquer atributo.
      final repository = _FakeCharacterRepository(
        characterFixture(abilityScores: flatScores),
      );

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _athlete,
        chosenAbility: Ability.charisma,
      );

      final saved = repository.stored;
      expect(saved.abilityScores.charisma, 10);
      expect(saved.feats.single.chosenAbility, isNull);
      expect(saved.feats.single.appliedAbilityIncreases, isEmpty);
    });

    test('escolha em talento sem opção de atributo é ignorada', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(abilityScores: scoresWith(constitution: 14)),
      );

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _tough,
        chosenAbility: Ability.strength,
      );

      final saved = repository.stored;
      expect(saved.abilityScores.strength, 10);
      expect(saved.abilityScores.constitution, 15);
      expect(saved.feats.single.appliedAbilityIncreases, {'constitution': 1});
    });

    test('fixo e escolha no mesmo atributo somam +2', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(abilityScores: scoresWith(strength: 12)),
      );

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _double,
        chosenAbility: Ability.strength,
      );

      final saved = repository.stored;
      expect(saved.abilityScores.strength, 14);
      expect(saved.feats.single.appliedAbilityIncreases, {'strength': 2});
    });

    test('atributo no teto de 20 fica igual, mas a escolha é lembrada',
        () async {
      // A escolha continua gravada para a ficha poder dizer
      // "Resiliente (Constituição)" mesmo sem aumento.
      final repository = _FakeCharacterRepository(
        characterFixture(abilityScores: scoresWith(constitution: 20)),
      );

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _resilient,
        chosenAbility: Ability.constitution,
      );

      final saved = repository.stored;
      expect(saved.abilityScores.constitution, 20);
      expect(saved.feats.single.chosenAbility, Ability.constitution);
      expect(saved.feats.single.appliedAbilityIncreases, isEmpty);
    });

    test('talento repetível soma nos dois atributos escolhidos', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(abilityScores: flatScores),
      );
      final useCase = ManageCharacterFeats(repository);

      await useCase.addFeat(
        characterId: 'c1',
        feat: _resilient,
        chosenAbility: Ability.constitution,
      );
      await useCase.addFeat(
        characterId: 'c1',
        feat: _resilient,
        chosenAbility: Ability.wisdom,
      );

      final saved = repository.stored;
      expect(saved.feats, hasLength(2));
      expect(saved.abilityScores.constitution, 11);
      expect(saved.abilityScores.wisdom, 11);
    });
  });

  group('ManageCharacterFeats reverte o aumento', () {
    test('remover o talento devolve exatamente o que ele somou', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(abilityScores: scoresWith(constitution: 14)),
      );
      final useCase = ManageCharacterFeats(repository);

      await useCase.addFeat(characterId: 'c1', feat: _tough);
      expect(repository.stored.abilityScores.constitution, 15);

      // O fake não gera localId, então o teste amarra um para poder remover.
      repository.stored = repository.stored.copyWith(
        feats: [repository.stored.feats.single.copyWith(localId: 7)],
      );

      await useCase.removeFeat(characterId: 'c1', localId: 7);

      expect(repository.stored.feats, isEmpty);
      expect(repository.stored.abilityScores.constitution, 14);
    });

    test('remover talento que não aumentou nada não mexe no atributo',
        () async {
      // Pego com o atributo já em 20: nada foi somado, então nada sai.
      final repository = _FakeCharacterRepository(
        characterFixture(
          abilityScores: scoresWith(constitution: 20),
          feats: const [
            CharacterFeat(
              localId: 3,
              featId: 'resilient',
              chosenAbility: Ability.constitution,
            ),
          ],
        ),
      );

      await ManageCharacterFeats(repository).removeFeat(
        characterId: 'c1',
        localId: 3,
      );

      expect(repository.stored.abilityScores.constitution, 20);
      expect(repository.stored.feats, isEmpty);
    });

    test('remover um talento não desfaz o aumento do outro', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          abilityScores: scoresWith(constitution: 11, wisdom: 11),
          feats: const [
            CharacterFeat(
              localId: 1,
              featId: 'resilient',
              chosenAbility: Ability.constitution,
              appliedAbilityIncreases: {'constitution': 1},
            ),
            CharacterFeat(
              localId: 2,
              featId: 'resilient',
              chosenAbility: Ability.wisdom,
              appliedAbilityIncreases: {'wisdom': 1},
            ),
          ],
        ),
      );

      await ManageCharacterFeats(repository).removeFeat(
        characterId: 'c1',
        localId: 1,
      );

      expect(repository.stored.abilityScores.constitution, 10);
      expect(repository.stored.abilityScores.wisdom, 11);
      expect(repository.stored.feats.single.localId, 2);
    });
  });

  group('import e export da ficha', () {
    test('o atributo escolhido e o aumento aplicado sobrevivem ao round-trip',
        () {
      final original = characterFixture(
        abilityScores: scoresWith(constitution: 15),
        feats: const [
          CharacterFeat(
            featId: 'resilient',
            classId: 'fighter',
            level: 4,
            chosenAbility: Ability.constitution,
            appliedAbilityIncreases: {'constitution': 1},
          ),
        ],
      );

      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(original),
      );

      final feat = restored.feats.single;
      expect(feat.featId, 'resilient');
      expect(feat.chosenAbility, Ability.constitution);
      expect(feat.appliedAbilityIncreases, {'constitution': 1});
      expect(restored.abilityScores.constitution, 15);
    });

    test('ficha antiga, sem os campos novos, entra sem aumento', () {
      // Compatibilidade com o que foi exportado antes desta versão.
      final original = characterFixture(
        feats: const [CharacterFeat(featId: 'tough')],
      );

      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(original),
      );

      expect(restored.feats.single.chosenAbility, isNull);
      expect(restored.feats.single.appliedAbilityIncreases, isEmpty);
      expect(restored.feats.single.increasesAbility, isFalse);
    });
  });
}
