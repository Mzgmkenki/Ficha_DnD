import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_character_feats.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_json_codec.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_score_improvement.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/level_progression_choices.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Incremento no Valor de Atributo como progressão PRÓPRIA.
///
/// O que estes testes protegem: a regra de distribuição (+2 em um ou +1 em
/// dois), o teto de 20 com a exceção declarada por característica, o registro
/// no nível e na classe certos, e a reversão exata — inclusive na troca por
/// talento, que é o caso em que errar custa pontos de atributo do jogador.
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
  // Guerreiro ganha níveis extras de escolha, e é o caso que mais exercita a
  // associação entre vaga e decisão.
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

const _variantHuman = RaceEntry(
  id: 'human_variant',
  name: 'Humano Variante',
  source: 'phb',
  grantsFeat: true,
);

void main() {
  group('AbilityScoreImprovementDraft', () {
    test('a regra é 2 pontos: +2 em um atributo', () {
      var draft = const AbilityScoreImprovementDraft();
      final scores = scoresWith(strength: 14);

      draft = draft.increment(Ability.strength, current: scores);
      expect(draft.isComplete, isFalse);
      expect(draft.remaining, 1);

      draft = draft.increment(Ability.strength, current: scores);
      expect(draft.isComplete, isTrue);
      expect(draft.amountFor(Ability.strength), 2);
      expect(draft.previewFor(Ability.strength, scores), 16);
      expect(draft.asIncreaseMap, {'strength': 2});
    });

    test('ou +1 em dois atributos diferentes', () {
      var draft = const AbilityScoreImprovementDraft();
      final scores = scoresWith(constitution: 13, wisdom: 12);

      draft = draft
          .increment(Ability.constitution, current: scores)
          .increment(Ability.wisdom, current: scores);

      expect(draft.isComplete, isTrue);
      expect(draft.asIncreaseMap, {'constitution': 1, 'wisdom': 1});
      expect(draft.previewFor(Ability.constitution, scores), 14);
      expect(draft.previewFor(Ability.wisdom, scores), 13);
    });

    test('não toca um terceiro atributo', () {
      var draft = const AbilityScoreImprovementDraft();
      final scores = flatScores;

      draft = draft
          .increment(Ability.strength, current: scores)
          .increment(Ability.dexterity, current: scores);

      expect(
        draft.canIncrement(Ability.wisdom, current: scores),
        isFalse,
        reason: 'os 2 pontos já foram distribuídos',
      );

      // Mesmo com ponto sobrando, três atributos não é distribuição válida.
      var partial = const AbilityScoreImprovementDraft()
          .increment(Ability.strength, current: scores);
      partial = partial.increment(Ability.dexterity, current: scores);
      expect(partial.increases.keys, hasLength(2));
    });

    test('bloqueia acima de 20, e explica o motivo', () {
      const draft = AbilityScoreImprovementDraft();
      final scores = scoresWith(strength: 20);

      expect(draft.canIncrement(Ability.strength, current: scores), isFalse);
      expect(
        draft.incrementBlockReason(Ability.strength, current: scores),
        contains('máximo de 20'),
      );
    });

    test('19 aceita +1 e para ali', () {
      final scores = scoresWith(strength: 19);
      var draft = const AbilityScoreImprovementDraft()
          .increment(Ability.strength, current: scores);

      expect(draft.amountFor(Ability.strength), 1);
      expect(
        draft.canIncrement(Ability.strength, current: scores),
        isFalse,
        reason: 'o segundo ponto passaria de 20',
      );

      // O ponto que sobrou vai para outro atributo.
      draft = draft.increment(Ability.dexterity, current: scores);
      expect(draft.isComplete, isTrue);
      expect(draft.asIncreaseMap, {'strength': 1, 'dexterity': 1});
    });

    test('teto declarado por característica permite passar de 20', () {
      final scores = scoresWith(strength: 20);
      const maximums = {Ability.strength: 24};

      var draft = const AbilityScoreImprovementDraft();
      expect(
        draft.canIncrement(Ability.strength, current: scores, maximums: maximums),
        isTrue,
      );

      draft = draft
          .increment(Ability.strength, current: scores, maximums: maximums)
          .increment(Ability.strength, current: scores, maximums: maximums);

      expect(draft.previewFor(Ability.strength, scores), 22);
    });

    test('decrementar devolve o ponto', () {
      final scores = flatScores;
      var draft = const AbilityScoreImprovementDraft()
          .increment(Ability.wisdom, current: scores)
          .increment(Ability.wisdom, current: scores);

      expect(draft.amountFor(Ability.wisdom), 2);

      draft = draft.decrement(Ability.wisdom);
      expect(draft.amountFor(Ability.wisdom), 1);
      expect(draft.remaining, 1);

      draft = draft.decrement(Ability.wisdom);
      expect(draft.increases, isEmpty);
      expect(draft.remaining, 2);

      // Em zero não fica negativo.
      expect(draft.decrement(Ability.wisdom).increases, isEmpty);
    });

    test('o rodapé diz o que falta', () {
      final scores = flatScores;
      expect(
        const AbilityScoreImprovementDraft().progressLabel,
        'Distribua 2 pontos.',
      );
      expect(
        const AbilityScoreImprovementDraft()
            .increment(Ability.strength, current: scores)
            .progressLabel,
        'Falta 1 ponto.',
      );
      expect(
        const AbilityScoreImprovementDraft()
            .increment(Ability.strength, current: scores)
            .increment(Ability.strength, current: scores)
            .progressLabel,
        'Distribuição completa.',
      );
    });
  });

  group('AbilityScoreImprovements.resolve', () {
    test('só entra o que cabe até o teto', () {
      final applied = AbilityScoreImprovements.resolve(
        current: scoresWith(strength: 19),
        wanted: const {'strength': 2},
      );

      expect(applied, {'strength': 1});
    });

    test('atributo no teto não registra nada', () {
      final applied = AbilityScoreImprovements.resolve(
        current: scoresWith(strength: 20),
        wanted: const {'strength': 2},
      );

      expect(
        applied,
        isEmpty,
        reason: 'sem registro, remover depois não rebaixa o atributo',
      );
    });

    test('o teto declarado por característica é respeitado', () {
      final applied = AbilityScoreImprovements.resolve(
        current: scoresWith(strength: 20),
        wanted: const {'strength': 2},
        maximums: const {Ability.strength: 24},
      );

      expect(applied, {'strength': 2});
    });
  });

  group('registro do incremento', () {
    test('+2 em um atributo sobe a ficha e registra a vaga', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          abilityScores: scoresWith(strength: 15),
        ),
      );

      final outcome = await ManageAbilityScoreImprovements(repository).choose(
        characterId: 'c1',
        classId: 'fighter',
        classLevel: 4,
        increases: const {Ability.strength: 2},
      );

      final saved = repository.stored;
      expect(saved.abilityScores.strength, 17);
      expect(saved.abilityImprovements, hasLength(1));

      final improvement = saved.abilityImprovements.single;
      expect(improvement.classId, 'fighter');
      expect(improvement.classLevel, 4);
      expect(improvement.progressionId, 'asi.fighter.4');
      expect(improvement.appliedIncreases, {'strength': 2});
      expect(improvement.increasesLabel, 'Força +2');
      expect(outcome.appliedLabel, 'Força +2');
    });

    test('+1 em dois atributos', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 6)],
          abilityScores: scoresWith(constitution: 14, wisdom: 12),
        ),
      );

      await ManageAbilityScoreImprovements(repository).choose(
        characterId: 'c1',
        classId: 'fighter',
        classLevel: 6,
        increases: const {Ability.constitution: 1, Ability.wisdom: 1},
      );

      final saved = repository.stored;
      expect(saved.abilityScores.constitution, 15);
      expect(saved.abilityScores.wisdom, 13);
      expect(
        saved.abilityImprovements.single.increasesLabel,
        'Constituição +1, Sabedoria +1',
      );
    });

    test('o nível gravado é o DA CLASSE, não o total', () async {
      // Guerreiro 4 / Mago 2: a escolha é do Guerreiro 4, e o nível total é 6.
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [
            ClassLevel(classId: 'fighter', level: 4),
            ClassLevel(classId: 'wizard', level: 2),
          ],
        ),
      );

      await ManageAbilityScoreImprovements(repository).choose(
        characterId: 'c1',
        classId: 'fighter',
        classLevel: 4,
        increases: const {Ability.strength: 2},
      );

      expect(repository.stored.abilityImprovements.single.classLevel, 4);
      expect(repository.stored.totalLevel, 6);
    });

    test('atributo no teto gasta a vaga mas não dá ponto', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          abilityScores: scoresWith(strength: 20),
        ),
      );

      final outcome = await ManageAbilityScoreImprovements(repository).choose(
        characterId: 'c1',
        classId: 'fighter',
        classLevel: 4,
        increases: const {Ability.strength: 2},
      );

      expect(repository.stored.abilityScores.strength, 20);
      expect(repository.stored.abilityImprovements, hasLength(1));
      expect(outcome.changedAnything, isFalse);
      expect(outcome.appliedLabel, contains('nenhum ponto'));
    });

    test('recusa dois incrementos na mesma vaga', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
        ),
      );
      final useCase = ManageAbilityScoreImprovements(repository);

      await useCase.choose(
        characterId: 'c1',
        classId: 'fighter',
        classLevel: 4,
        increases: const {Ability.strength: 2},
      );

      expect(
        () => useCase.choose(
          characterId: 'c1',
          classId: 'fighter',
          classLevel: 4,
          increases: const {Ability.dexterity: 2},
        ),
        throwsA(isA<Exception>()),
        reason: 'dois incrementos no mesmo nível dariam 4 pontos de graça',
      );
    });

    test('o incremento entra nos bônus permanentes do personagem', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
        ),
      );

      await ManageAbilityScoreImprovements(repository).choose(
        characterId: 'c1',
        classId: 'fighter',
        classLevel: 4,
        increases: const {Ability.strength: 2},
      );

      expect(
        repository.stored.otherPermanentAbilityBonuses[Ability.strength],
        2,
        reason: 'senão a tela de atributos apresentaria pontos de nível como '
            'valor base',
      );
    });
  });

  group('reversão do incremento', () {
    test('remover devolve exatamente os pontos daquele incremento', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          abilityScores: scoresWith(strength: 15),
        ),
      );
      final useCase = ManageAbilityScoreImprovements(repository);

      await useCase.choose(
        characterId: 'c1',
        classId: 'fighter',
        classLevel: 4,
        increases: const {Ability.strength: 2},
      );
      expect(repository.stored.abilityScores.strength, 17);

      // O fake não gera localId, então o teste amarra um para poder remover.
      repository.stored = repository.stored.copyWith(
        abilityImprovements: [
          repository.stored.abilityImprovements.single.copyWith(localId: 9),
        ],
      );

      await useCase.remove(characterId: 'c1', localId: 9);

      expect(repository.stored.abilityScores.strength, 15);
      expect(repository.stored.abilityImprovements, isEmpty);
    });

    test('remover um incremento não desfaz o outro', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 8)],
          abilityScores: scoresWith(strength: 17, constitution: 15),
          // Ficha já com os dois registrados e os atributos somados.
        ).copyWith(
          abilityImprovements: const [
            AbilityScoreImprovement(
              localId: 1,
              classId: 'fighter',
              classLevel: 4,
              appliedIncreases: {'strength': 2},
            ),
            AbilityScoreImprovement(
              localId: 2,
              classId: 'fighter',
              classLevel: 8,
              appliedIncreases: {'constitution': 1, 'wisdom': 1},
            ),
          ],
        ),
      );

      await ManageAbilityScoreImprovements(repository).remove(
        characterId: 'c1',
        localId: 1,
      );

      expect(repository.stored.abilityScores.strength, 15);
      expect(
        repository.stored.abilityScores.constitution,
        15,
        reason: 'o incremento do 8º nível não foi tocado',
      );
      expect(repository.stored.abilityImprovements.single.localId, 2);
    });

    test('bônus de origem e de talento ficam intactos', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          // 13 base + 1 de origem + 1 de talento + 2 do incremento = 17.
          abilityScores: scoresWith(strength: 17),
          feats: const [
            CharacterFeat(
              localId: 5,
              featId: 'athlete',
              appliedAbilityIncreases: {'strength': 1},
            ),
          ],
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

      await ManageAbilityScoreImprovements(repository).remove(
        characterId: 'c1',
        localId: 1,
      );

      expect(
        repository.stored.abilityScores.strength,
        15,
        reason: 'saem só os 2 do incremento; o +1 do talento continua',
      );
      expect(repository.stored.feats.single.appliedAbilityIncreases, {
        'strength': 1,
      });
    });

    test('remover id inexistente não mexe em nada', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(abilityScores: scoresWith(strength: 15)),
      );

      final outcome = await ManageAbilityScoreImprovements(repository).remove(
        characterId: 'c1',
        localId: 404,
      );

      expect(outcome.applied, isEmpty);
      expect(repository.stored.abilityScores.strength, 15);
    });
  });

  group('troca entre talento e incremento', () {
    test('talento vira incremento: efeitos do talento são desfeitos', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          // 14 base + 1 do talento.
          abilityScores: scoresWith(strength: 15),
          skillProficiencies: skillsWith(const {
            Skill.athletics: ProficiencyLevel.proficient,
          }),
          feats: const [
            CharacterFeat(
              localId: 7,
              featId: 'athlete',
              classId: 'fighter',
              level: 4,
              grantedSkillIds: ['athletics'],
              chosenAbility: Ability.strength,
              appliedAbilityIncreases: {'strength': 1},
            ),
          ],
        ),
      );

      final outcome = await ManageAbilityScoreImprovements(
        repository,
      ).replaceFeat(
        characterId: 'c1',
        featLocalId: 7,
        classId: 'fighter',
        classLevel: 4,
        increases: const {Ability.strength: 2},
      );

      final saved = repository.stored;

      expect(saved.feats, isEmpty, reason: 'o talento sai da ficha');
      expect(
        saved.skillProficiencies.levelFor(Skill.athletics),
        ProficiencyLevel.none,
        reason: 'a perícia que SÓ o talento concedia volta',
      );
      // 15 - 1 (talento) + 2 (incremento) = 16.
      expect(saved.abilityScores.strength, 16);
      expect(saved.abilityImprovements.single.classLevel, 4);
      expect(outcome.applied, {'strength': 2});
    });

    test('na troca, o teto é conferido já sem o talento', () async {
      // Força 20 com +1 do talento. Sem ele são 19, e o incremento tem direito
      // a 1 ponto — não a zero.
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          abilityScores: scoresWith(strength: 20),
          feats: const [
            CharacterFeat(
              localId: 7,
              featId: 'athlete',
              classId: 'fighter',
              level: 4,
              appliedAbilityIncreases: {'strength': 1},
            ),
          ],
        ),
      );

      await ManageAbilityScoreImprovements(repository).replaceFeat(
        characterId: 'c1',
        featLocalId: 7,
        classId: 'fighter',
        classLevel: 4,
        increases: const {Ability.strength: 2},
      );

      expect(repository.stored.abilityScores.strength, 20);
      expect(
        repository.stored.abilityImprovements.single.appliedIncreases,
        {'strength': 1},
        reason: 'cabia 1 ponto, e é 1 que fica registrado',
      );
    });

    test('a perícia que o personagem já tinha não é removida', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          skillProficiencies: skillsWith(const {
            Skill.athletics: ProficiencyLevel.proficient,
          }),
          feats: const [
            CharacterFeat(
              localId: 7,
              featId: 'athlete',
              classId: 'fighter',
              level: 4,
              // Vazio: a perícia já vinha da classe, então o talento não
              // registrou tê-la concedido.
              grantedSkillIds: [],
            ),
          ],
        ),
      );

      await ManageAbilityScoreImprovements(repository).replaceFeat(
        characterId: 'c1',
        featLocalId: 7,
        classId: 'fighter',
        classLevel: 4,
        increases: const {Ability.strength: 2},
      );

      expect(
        repository.stored.skillProficiencies.levelFor(Skill.athletics),
        ProficiencyLevel.proficient,
      );
    });

    test('troca numa só gravação', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          feats: const [
            CharacterFeat(localId: 7, featId: 'athlete', classId: 'fighter'),
          ],
        ),
      );

      await ManageAbilityScoreImprovements(repository).replaceFeat(
        characterId: 'c1',
        featLocalId: 7,
        classId: 'fighter',
        classLevel: 4,
        increases: const {Ability.strength: 2},
      );

      expect(
        repository.updates,
        1,
        reason: 'o estado intermediário teria atributos errados',
      );
    });

    test('incremento vira talento: a vaga volta a ficar livre', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          abilityScores: scoresWith(strength: 17),
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

      await ManageAbilityScoreImprovements(repository).remove(
        characterId: 'c1',
        localId: 1,
      );

      final slots = LevelProgressionChoices.forCharacter(
        repository.stored,
        const [_fighter],
      );

      expect(repository.stored.abilityScores.strength, 15);
      expect(slots.single.isPending, isTrue);
    });
  });

  group('vagas de progressão', () {
    test('uma vaga por nível de escolha alcançado', () {
      final slots = LevelProgressionChoices.forCharacter(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 6)],
        ),
        const [_fighter],
      );

      expect(slots.map((slot) => slot.classLevel), [4, 6]);
      expect(slots.every((slot) => slot.isPending), isTrue);
      expect(slots.first.label, 'Guerreiro 4');
      expect(slots.first.progressionId, 'asi.fighter.4');
    });

    test('nível não alcançado não gera vaga', () {
      final slots = LevelProgressionChoices.forCharacter(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
        ),
        const [_fighter],
      );

      expect(slots, isEmpty);
    });

    test('no multiclasse cada classe concede pelos níveis dela', () {
      final slots = LevelProgressionChoices.forCharacter(
        characterFixture(
          classLevels: const [
            ClassLevel(classId: 'fighter', level: 4),
            ClassLevel(classId: 'wizard', level: 4),
          ],
        ),
        const [_fighter, _wizard],
      );

      expect(slots, hasLength(2));
      expect(slots.map((slot) => slot.classId), ['fighter', 'wizard']);
    });

    test('o incremento casa com a vaga por classe e nível', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 6)],
      ).copyWith(
        abilityImprovements: const [
          AbilityScoreImprovement(
            localId: 1,
            classId: 'fighter',
            classLevel: 6,
            appliedIncreases: {'strength': 2},
          ),
        ],
      );

      final slots = LevelProgressionChoices.forCharacter(
        character,
        const [_fighter],
      );

      expect(slots.first.isPending, isTrue, reason: 'o 4º continua em aberto');
      expect(slots.last.kind, LevelProgressionKind.improvement);
      expect(slots.last.classLevel, 6);
    });

    test('talento antigo, gravado com o nível TOTAL, ainda ocupa uma vaga', () {
      // Até esta versão o talento era gravado com o nível total do
      // personagem. Casar só por igualdade deixaria a vaga livre e a ficha
      // ofereceria de novo uma escolha já gasta.
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'fighter', level: 4),
          ClassLevel(classId: 'wizard', level: 4),
        ],
        feats: const [
          CharacterFeat(
            localId: 1,
            featId: 'alert',
            classId: 'fighter',
            level: 8,
          ),
        ],
      );

      final slots = LevelProgressionChoices.forCharacter(
        character,
        const [_fighter, _wizard],
      );

      expect(
        slots.where((slot) => slot.isPending),
        hasLength(1),
        reason: 'duas vagas, uma gasta pelo talento antigo',
      );
      expect(
        slots.firstWhere((slot) => !slot.isPending).classId,
        'fighter',
        reason: 'foi para a vaga da própria classe do talento',
      );
    });

    test('talento sem classe nem nível preenche a vaga mais antiga', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 6)],
        feats: const [CharacterFeat(localId: 1, featId: 'alert')],
      );

      final slots = LevelProgressionChoices.forCharacter(
        character,
        const [_fighter],
      );

      expect(slots.first.kind, LevelProgressionKind.feat);
      expect(slots.last.isPending, isTrue);
    });

    test('a vaga da raça aceita talento, mas não incremento', () {
      final slots = LevelProgressionChoices.forCharacter(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
          speciesId: 'human_variant',
        ),
        const [_fighter],
        races: const [_variantHuman],
      );

      expect(slots, hasLength(1));
      expect(slots.single.fromRace, isTrue);
      expect(
        slots.single.allowsImprovement,
        isFalse,
        reason: 'o Humano Variante ganha um TALENTO, não a troca por atributo',
      );
      expect(slots.single.label, 'Raça');
    });
  });

  group('contagem de escolhas', () {
    test('talento e incremento gastam a MESMA escolha', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 6)],
        feats: const [CharacterFeat(localId: 1, featId: 'alert')],
      ).copyWith(
        abilityImprovements: const [
          AbilityScoreImprovement(
            localId: 1,
            classId: 'fighter',
            classLevel: 6,
            appliedIncreases: {'strength': 2},
          ),
        ],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_fighter],
      );

      expect(allowance.granted, 2);
      expect(allowance.taken, 2);
      expect(allowance.feats, 1);
      expect(allowance.improvements, 1);
      expect(
        allowance.hasPending,
        isFalse,
        reason: 'sem isso a ficha ofereceria de novo uma escolha já gasta',
      );
    });

    test('só incremento já gasta a escolha', () {
      final character = characterFixture(
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
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_fighter],
      );

      expect(allowance.remaining, 0);
    });
  });

  group('exportar e importar', () {
    test('o incremento sobrevive ao round-trip', () {
      final original = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 6)],
        abilityScores: scoresWith(strength: 17, constitution: 15),
      ).copyWith(
        abilityImprovements: const [
          AbilityScoreImprovement(
            classId: 'fighter',
            classLevel: 4,
            appliedIncreases: {'strength': 2},
          ),
          AbilityScoreImprovement(
            classId: 'fighter',
            classLevel: 6,
            appliedIncreases: {'constitution': 1, 'wisdom': 1},
          ),
        ],
      );

      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(original),
      );

      expect(restored.abilityImprovements, hasLength(2));
      expect(restored.abilityImprovements.first.classLevel, 4);
      expect(restored.abilityImprovements.first.appliedIncreases, {
        'strength': 2,
      });
      expect(restored.abilityImprovements.last.appliedIncreases, {
        'constitution': 1,
        'wisdom': 1,
      });
      expect(restored.abilityScores.strength, 17);
    });

    test('ficha antiga, sem a chave nova, entra sem incremento', () {
      final original = characterFixture(
        feats: const [CharacterFeat(featId: 'tough')],
      );

      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(original),
      );

      expect(restored.abilityImprovements, isEmpty);
      expect(restored.armorClassFormulaId, isNull);
    });

    test('a fórmula de CA escolhida sobrevive ao round-trip', () {
      final original = characterFixture().copyWith(
        armorClassFormulaId: 'barbarian.unarmored_defense',
      );

      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(original),
      );

      expect(restored.armorClassFormulaId, 'barbarian.unarmored_defense');
    });

    test('incremento sem classe ou nível é descartado na importação', () {
      // Arquivo editado à mão: um registro pela metade faria a ficha oferecer
      // a escolha de novo no mesmo nível.
      final map = CharacterJsonCodec.toMap(
        characterFixture().copyWith(
          abilityImprovements: const [
            AbilityScoreImprovement(
              classId: 'fighter',
              classLevel: 4,
              appliedIncreases: {'strength': 2},
            ),
            AbilityScoreImprovement(
              classId: 'fighter',
              classLevel: 8,
              appliedIncreases: {'wisdom': 2},
            ),
          ],
        ),
      );

      final improvements = map['abilityImprovements'] as List<dynamic>;
      (improvements.first as Map<String, dynamic>)['classId'] = '';
      (improvements.last as Map<String, dynamic>)['classLevel'] = null;

      final restored = CharacterJsonCodec.fromMap(map);

      expect(
        restored.abilityImprovements,
        isEmpty,
        reason: 'um sem classe, o outro sem nível: nenhum dos dois entra',
      );
    });
  });
}
