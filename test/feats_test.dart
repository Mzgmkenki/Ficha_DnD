import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_character_feats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Repositório em memória: `findById` alimenta o caso de uso e `update` guarda
/// o resultado para as asserções.
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

const _fighter = ClassEntry(
  id: 'fighter',
  name: 'Guerreiro',
  hitDie: 'd10',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
  // Guerreiro ganha dois níveis extras de talento além do padrão.
  featLevels: [4, 6, 8, 12, 14, 16, 19],
);

const _wizard = ClassEntry(
  id: 'wizard',
  name: 'Mago',
  hitDie: 'd6',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
);

/// Talento que concede perícia fixa.
const _observant = FeatEntry(
  id: 'observant',
  name: 'Observador',
  skillIds: ['perception'],
);

/// Humano Variante concede um talento no 1º nível; o Humano comum não.
const _races = [
  RaceEntry(
    id: 'human_variant_phb',
    name: 'Humano Variante',
    source: 'phb',
    grantsFeat: true,
  ),
  RaceEntry(id: 'human_phb', name: 'Humano', source: 'phb'),
];

/// Talento em que o jogador escolhe, como o Versátil.
const _skilled = FeatEntry(
  id: 'skilled',
  name: 'Versátil',
  skillChoice: FeatSkillChoice(
    choose: 2,
    options: ['nature', 'medicine', 'survival'],
  ),
);

void main() {
  group('níveis de talento da classe', () {
    test('o padrão é 4, 8, 12, 16 e 19', () {
      expect(_wizard.featLevels, ClassEntry.defaultFeatLevels);
      expect(_wizard.grantsFeatAt(4), isTrue);
      expect(_wizard.grantsFeatAt(8), isTrue);
      expect(_wizard.grantsFeatAt(5), isFalse);
      expect(_wizard.grantsFeatAt(1), isFalse);
    });

    test('a classe pode declarar níveis extras', () {
      expect(_fighter.grantsFeatAt(6), isTrue);
      expect(_fighter.grantsFeatAt(14), isTrue);
      expect(_wizard.grantsFeatAt(6), isFalse);
    });

    test('conta quantos talentos a classe já concedeu', () {
      expect(_wizard.featsGrantedUpTo(3), 0);
      expect(_wizard.featsGrantedUpTo(4), 1);
      expect(_wizard.featsGrantedUpTo(11), 2);
      expect(_fighter.featsGrantedUpTo(6), 2);
    });
  });

  group('escolhas disponíveis', () {
    test('soma por classe no multiclasse', () {
      // Cada classe concede nos níveis dela: Guerreiro 4 + Mago 4 dá duas
      // escolhas, uma de cada, e não uma escolha pelo nível total 8.
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'fighter', level: 4),
          ClassLevel(classId: 'wizard', level: 4),
        ],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_fighter, _wizard],
      );

      expect(allowance.granted, 2);
      expect(allowance.taken, 0);
      expect(allowance.hasPending, isTrue);
    });

    test('nível baixo não concede nada', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'wizard', level: 3)],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_wizard],
      );

      expect(allowance.granted, 0);
      expect(allowance.hasPending, isFalse);
    });

    test('talento já escolhido consome a vaga', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'wizard', level: 4)],
        feats: const [CharacterFeat(featId: 'observant')],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_wizard],
      );

      expect(allowance.remaining, 0);
      expect(allowance.hasPending, isFalse);
    });

    test('classe fora do compêndio não concede nem quebra', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'homebrew', level: 20)],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_wizard],
      );

      expect(allowance.granted, 0);
    });
  });

  group('talento concedido pela raça', () {
    test('o Humano Variante escolhe um talento já no 1º nível', () {
      // A exceção da raça: ela troca o +1 nos seis atributos por perícia e
      // talento, então a escolha existe antes de qualquer nível de classe.
      final character = characterFixture(
        speciesId: 'human_variant_phb',
        classLevels: const [ClassLevel(classId: 'wizard', level: 1)],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_wizard],
        races: _races,
      );

      expect(allowance.granted, 1);
      expect(allowance.fromRace, isTrue);
      expect(allowance.hasPending, isTrue);
    });

    test('o Humano comum não recebe nada', () {
      final character = characterFixture(
        speciesId: 'human_phb',
        classLevels: const [ClassLevel(classId: 'wizard', level: 1)],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_wizard],
        races: _races,
      );

      expect(allowance.granted, 0);
      expect(allowance.fromRace, isFalse);
    });

    test('a concessão da raça soma com a da classe', () {
      // Humano Variante no 4º nível tem duas: a da raça e a do nível.
      final character = characterFixture(
        speciesId: 'human_variant_phb',
        classLevels: const [ClassLevel(classId: 'wizard', level: 4)],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_wizard],
        races: _races,
      );

      expect(allowance.granted, 2);
    });

    test('pegar o talento da raça consome a vaga', () {
      final character = characterFixture(
        speciesId: 'human_variant_phb',
        classLevels: const [ClassLevel(classId: 'wizard', level: 1)],
        feats: const [CharacterFeat(featId: 'observant')],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_wizard],
        races: _races,
      );

      expect(allowance.remaining, 0);
      expect(allowance.hasPending, isFalse);
    });

    test('sem a lista de raças a concessão racial não entra', () {
      // O parâmetro é opcional: quem só quer a conta das classes não é
      // obrigado a carregar o compêndio de raças.
      final character = characterFixture(
        speciesId: 'human_variant_phb',
        classLevels: const [ClassLevel(classId: 'wizard', level: 1)],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_wizard],
      );

      expect(allowance.granted, 0);
    });

    test('personagem sem raça não recebe nada', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'wizard', level: 1)],
      );

      final allowance = ManageCharacterFeats.allowanceFor(
        character,
        const [_wizard],
        races: _races,
      );

      expect(allowance.granted, 0);
    });
  });

  group('adicionar talento', () {
    test('a perícia fixa do talento vira proficiência', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'wizard', level: 4)],
        ),
      );

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _observant,
      );

      final saved = repository.updated!;
      expect(
        saved.skillProficiencies.levelFor(Skill.perception),
        ProficiencyLevel.proficient,
      );
      expect(saved.feats, hasLength(1));
      expect(saved.feats.single.featId, 'observant');
    });

    test('a perícia escolhida pelo jogador entra', () async {
      final repository = _FakeCharacterRepository(characterFixture());

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _skilled,
        chosenSkills: const [Skill.nature, Skill.medicine],
      );

      final saved = repository.updated!;
      expect(
        saved.skillProficiencies.levelFor(Skill.nature),
        ProficiencyLevel.proficient,
      );
      expect(
        saved.skillProficiencies.levelFor(Skill.medicine),
        ProficiencyLevel.proficient,
      );
      expect(saved.feats.single.chosenSkillIds, ['nature', 'medicine']);
    });

    test('escolha fora das opções do talento é descartada', () async {
      final repository = _FakeCharacterRepository(characterFixture());

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _skilled,
        chosenSkills: const [Skill.nature, Skill.stealth],
      );

      final saved = repository.updated!;
      expect(
        saved.skillProficiencies.levelFor(Skill.stealth),
        ProficiencyLevel.none,
        reason: 'Furtividade não está entre as opções do Versátil',
      );
    });

    test('não registra como concedida a perícia que já era proficiência',
        () async {
      // O ponto mais delicado: sem isso, remover o talento tiraria uma
      // proficiência que veio da classe.
      final repository = _FakeCharacterRepository(
        characterFixture(
          skillProficiencies: skillsWith({
            Skill.perception: ProficiencyLevel.proficient,
          }),
        ),
      );

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _observant,
      );

      expect(repository.updated!.feats.single.grantedSkillIds, isEmpty);
    });

    test('não rebaixa Especialista', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          skillProficiencies: skillsWith({
            Skill.perception: ProficiencyLevel.expertise,
          }),
        ),
      );

      await ManageCharacterFeats(repository).addFeat(
        characterId: 'c1',
        feat: _observant,
      );

      expect(
        repository.updated!.skillProficiencies.levelFor(Skill.perception),
        ProficiencyLevel.expertise,
      );
    });

    test('talento não repetível recusa a segunda vez', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(feats: const [CharacterFeat(featId: 'observant')]),
      );

      await expectLater(
        ManageCharacterFeats(repository).addFeat(
          characterId: 'c1',
          feat: _observant,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('remover talento', () {
    test('devolve só o que o talento havia concedido', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          skillProficiencies: skillsWith({
            Skill.perception: ProficiencyLevel.proficient,
            Skill.stealth: ProficiencyLevel.proficient,
          }),
          feats: const [
            CharacterFeat(
              localId: 7,
              featId: 'observant',
              grantedSkillIds: ['perception'],
            ),
          ],
        ),
      );

      await ManageCharacterFeats(repository).removeFeat(
        characterId: 'c1',
        localId: 7,
      );

      final saved = repository.updated!;
      expect(saved.feats, isEmpty);
      expect(
        saved.skillProficiencies.levelFor(Skill.perception),
        ProficiencyLevel.none,
      );
      expect(
        saved.skillProficiencies.levelFor(Skill.stealth),
        ProficiencyLevel.proficient,
        reason: 'Furtividade não veio do talento',
      );
    });

    test('perícia que o talento não concedeu fica intacta', () async {
      final repository = _FakeCharacterRepository(
        characterFixture(
          skillProficiencies: skillsWith({
            Skill.perception: ProficiencyLevel.proficient,
          }),
          // Lista vazia: a perícia já era da classe quando o talento entrou.
          feats: const [CharacterFeat(localId: 7, featId: 'observant')],
        ),
      );

      await ManageCharacterFeats(repository).removeFeat(
        characterId: 'c1',
        localId: 7,
      );

      expect(
        repository.updated!.skillProficiencies.levelFor(Skill.perception),
        ProficiencyLevel.proficient,
      );
    });

    test('talento inexistente não faz nada', () async {
      final repository = _FakeCharacterRepository(characterFixture());

      await ManageCharacterFeats(repository).removeFeat(
        characterId: 'c1',
        localId: 999,
      );

      expect(repository.updated, isNull);
    });
  });

  group('FeatEntry', () {
    test('resolve as perícias fixas e ignora id inválido', () {
      const feat = FeatEntry(
        id: 'x',
        name: 'X',
        skillIds: ['perception', 'nao_existe'],
      );

      expect(feat.skills, const [Skill.perception]);
      expect(feat.touchesSkills, isTrue);
    });

    test('escolha sem opções significa qualquer perícia', () {
      // É o caso do Versátil, que deixa escolher entre todas.
      const choice = FeatSkillChoice(choose: 3);

      expect(choice.skills, hasLength(Skill.values.length));
    });

    test('talento que não mexe em perícia se declara como tal', () {
      const feat = FeatEntry(id: 'tough', name: 'Resistente');

      expect(feat.touchesSkills, isFalse);
      expect(feat.skillsToChoose, 0);
    });
  });
}
