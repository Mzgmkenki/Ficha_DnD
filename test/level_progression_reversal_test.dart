import 'package:dnd_ficha_app/features/character/application/use_cases/character/update_character_class_levels.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_score_improvement.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/level_progression_reversal.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Reversão da escolha de progressão quando a vaga deixa de existir.
///
/// O que estes testes protegem: perder nível é o único caminho que APAGA uma
/// vaga, e um incremento órfão continuaria somando pontos nos atributos sem
/// aparecer em lugar nenhum da ficha. Força inflada em silêncio contamina CA,
/// PV, ataque e testes — e o jogador não teria onde clicar para desfazer.
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

/// Guerreiro 4 com o incremento do 4º nível já gravado.
Character _fighterWithImprovement({int level = 4, int strength = 18}) {
  return characterFixture(
    abilityScores: scoresWith(strength: strength, constitution: 14),
    classLevels: [ClassLevel(classId: 'fighter', level: level)],
    hitPoints: const HitPoints(current: 40, maximum: 40),
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
}

void main() {
  group('LevelProgressionReversal.validIdsFor', () {
    test('vem dos níveis declarados no compêndio, não de uma lista fixa', () {
      final ids = LevelProgressionReversal.validIdsFor(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 6)],
        ),
        const [_fighter],
      );

      expect(ids, {'asi.fighter.4', 'asi.fighter.6'});
    });

    test('no multiclasse usa o nível DE CADA CLASSE', () {
      final ids = LevelProgressionReversal.validIdsFor(
        characterFixture(
          classLevels: const [
            ClassLevel(classId: 'fighter', level: 4),
            ClassLevel(classId: 'wizard', level: 4),
          ],
        ),
        const [_fighter, _wizard],
      );

      // Nível total 8, mas nenhuma das duas classes chegou ao 8º: a vaga de
      // `fighter.8` não existe, e usar o total a inventaria.
      expect(ids, {'asi.fighter.4', 'asi.wizard.4'});
    });

    test('nível não alcançado não gera id de vaga', () {
      final ids = LevelProgressionReversal.validIdsFor(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
        ),
        const [_fighter],
      );

      expect(ids, isEmpty);
    });
  });

  group('LevelProgressionReversal.revokeOrphans', () {
    test('sem órfão devolve o MESMO objeto', () {
      final character = _fighterWithImprovement();

      final result = LevelProgressionReversal.revokeOrphans(
        character: character,
        validProgressionIds: LevelProgressionReversal.validIdsFor(
          character,
          const [_fighter],
        ),
      );

      expect(
        identical(result, character),
        isTrue,
        reason: 'é o sinal de "nada a fazer"; sem ele a ficha gravaria à toa',
      );
    });

    test('vaga que deixou de existir devolve os pontos', () {
      // O jogador voltou para o 3º nível: a vaga do 4º não existe mais.
      final reduced = _fighterWithImprovement().copyWith(
        classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
      );

      final result = LevelProgressionReversal.revokeOrphans(
        character: reduced,
        validProgressionIds: LevelProgressionReversal.validIdsFor(
          reduced,
          const [_fighter],
        ),
      );

      expect(result.abilityScores.strength, 16);
      expect(result.abilityImprovements, isEmpty);
    });

    test('devolve pelo REGISTRO, não pelo que o incremento pediu', () {
      // Força estava em 19 e o incremento só conseguiu aplicar +1 antes do
      // teto. Devolver 2 roubaria um ponto do jogador.
      final reduced = characterFixture(
        abilityScores: scoresWith(strength: 20),
        classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
      ).copyWith(
        abilityImprovements: const [
          AbilityScoreImprovement(
            localId: 1,
            classId: 'fighter',
            classLevel: 4,
            appliedIncreases: {'strength': 1},
          ),
        ],
      );

      final result = LevelProgressionReversal.revokeOrphans(
        character: reduced,
        validProgressionIds: const {},
      );

      expect(result.abilityScores.strength, 19);
    });

    test('mexe só na vaga que sumiu, e não nas outras', () {
      final character = characterFixture(
        abilityScores: scoresWith(strength: 18, constitution: 16),
        classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
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
            classLevel: 6,
            appliedIncreases: {'constitution': 2},
          ),
        ],
      );

      final result = LevelProgressionReversal.revokeOrphans(
        character: character,
        validProgressionIds: const {'asi.fighter.4'},
      );

      expect(result.abilityScores.strength, 18, reason: 'a vaga do 4º ficou');
      expect(result.abilityScores.constitution, 14);
      expect(result.abilityImprovements.single.classLevel, 4);
    });

    test('idempotente: a segunda chamada não muda mais nada', () {
      final reduced = _fighterWithImprovement().copyWith(
        classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
      );

      final once = LevelProgressionReversal.revokeOrphans(
        character: reduced,
        validProgressionIds: const {},
      );
      final twice = LevelProgressionReversal.revokeOrphans(
        character: once,
        validProgressionIds: const {},
      );

      expect(identical(twice, once), isTrue);
      expect(twice.abilityScores.strength, 16);
    });

    test('a vaga do talento da raça não é confundida com incremento', () {
      // `fromRace` fica fora dos ids válidos porque não aceita incremento.
      // Um incremento com classe vazia seria dado corrompido, e sai.
      final character = characterFixture(
        abilityScores: scoresWith(strength: 18),
        speciesId: 'human_variant',
      ).copyWith(
        abilityImprovements: const [
          AbilityScoreImprovement(
            localId: 1,
            classId: '',
            classLevel: 0,
            appliedIncreases: {'strength': 2},
          ),
        ],
      );

      final result = LevelProgressionReversal.revokeOrphans(
        character: character,
        validProgressionIds: LevelProgressionReversal.validIdsFor(
          character,
          const [_fighter],
        ),
      );

      expect(result.abilityImprovements, isEmpty);
      expect(result.abilityScores.strength, 16);
    });
  });

  group('UpdateCharacterClassLevels com progressionSlots', () {
    test(
      'reduzir nível devolve os pontos do incremento da vaga perdida',
      () async {
        final repository = _FakeCharacterRepository(_fighterWithImprovement());
        final useCase = UpdateCharacterClassLevels(repository);

        await useCase(
          characterId: 'c1',
          classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
          progressionSlots:
              (character) => LevelProgressionReversal.validIdsFor(
                character,
                const [_fighter],
              ),
        );

        expect(repository.stored.abilityScores.strength, 16);
        expect(repository.stored.abilityImprovements, isEmpty);
      },
    );

    test('subir de nível não desfaz nada', () async {
      final repository = _FakeCharacterRepository(_fighterWithImprovement());
      final useCase = UpdateCharacterClassLevels(repository);

      await useCase(
        characterId: 'c1',
        classLevels: const [ClassLevel(classId: 'fighter', level: 5)],
        progressionSlots:
            (character) => LevelProgressionReversal.validIdsFor(
              character,
              const [_fighter],
            ),
      );

      expect(repository.stored.abilityScores.strength, 18);
      expect(repository.stored.abilityImprovements, hasLength(1));
    });

    test('sem o resolvedor o comportamento antigo continua valendo', () async {
      final repository = _FakeCharacterRepository(_fighterWithImprovement());
      final useCase = UpdateCharacterClassLevels(repository);

      await useCase(
        characterId: 'c1',
        classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
      );

      expect(repository.stored.abilityScores.strength, 18);
      expect(repository.stored.abilityImprovements, hasLength(1));
    });

    test('o PV novo considera a Constituição JÁ devolvida', () async {
      // Constituição 16 (+3) vinda de um incremento na vaga do 4º nível. Ao
      // voltar para o 3º a Constituição cai para 14 (+2), e o PV máximo tem de
      // ser calculado com o modificador NOVO — não com o de antes.
      final character = characterFixture(
        abilityScores: scoresWith(constitution: 16),
        classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
        hitPoints: const HitPoints(current: 34, maximum: 34),
      ).copyWith(
        abilityImprovements: const [
          AbilityScoreImprovement(
            localId: 1,
            classId: 'fighter',
            classLevel: 4,
            appliedIncreases: {'constitution': 2},
          ),
        ],
      );

      final repository = _FakeCharacterRepository(character);
      final useCase = UpdateCharacterClassLevels(repository);

      await useCase(
        characterId: 'c1',
        classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
        dieSizeForClass: (_) => 10,
        progressionSlots:
            (updated) =>
                LevelProgressionReversal.validIdsFor(updated, const [_fighter]),
      );

      // d10: 10 no 1º nível + 6 por nível (média 6 arredondada) com +2 de
      // Constituição por nível. O que o teste fixa é a Constituição usada.
      expect(repository.stored.abilityScores.constitution, 14);
      expect(
        repository.stored.hitPoints.maximum,
        lessThan(34),
        reason: 'perdeu um nível e dois pontos de Constituição',
      );
    });
  });
}
