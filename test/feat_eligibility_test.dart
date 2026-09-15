import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feat_eligibility.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_prerequisite.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

const _fighter = ClassEntry(
  id: 'fighter',
  name: 'Guerreiro',
  hitDie: 'd10',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
);

const _wizard = ClassEntry(
  id: 'wizard',
  name: 'Mago',
  hitDie: 'd6',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
  spellcastingType: 'full',
  spellcastingAbility: 'intelligence',
);

/// Meio-conjurador: só conjura a partir do 2º nível.
const _paladin = ClassEntry(
  id: 'paladin',
  name: 'Paladino',
  hitDie: 'd10',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
  spellcastingType: 'half',
  spellcastingAbility: 'charisma',
);

const _classes = [_fighter, _wizard, _paladin];

const _elf = RaceEntry(id: 'elf_phb', name: 'Elfo', source: 'phb', size: 'medium');

const _highElf = RaceEntry(
  id: 'elf_high_phb',
  name: 'Elfo Alto',
  source: 'phb',
  size: 'medium',
  parentRaceId: 'elf_phb',
  isSubrace: true,
);

const _halfling = RaceEntry(
  id: 'halfling_phb',
  name: 'Halfling',
  source: 'phb',
  size: 'small',
);

const _dwarf = RaceEntry(
  id: 'dwarf_phb',
  name: 'Anão',
  source: 'phb',
  size: 'medium',
);

const _races = [_elf, _highElf, _halfling, _dwarf];

FeatEntry _feat(String id, FeatPrerequisite requires) {
  return FeatEntry(id: id, name: id, requires: requires);
}

void main() {
  group('sem pré-requisito', () {
    test('talento aberto serve para qualquer personagem', () {
      final feat = _feat('actor', const FeatPrerequisite());

      expect(
        FeatEligibility.meets(feat, character: characterFixture()),
        isTrue,
      );
    });
  });

  group('valor de atributo', () {
    test('cumpre quando alcança o mínimo', () {
      final feat = _feat(
        'grappler',
        const FeatPrerequisite(minAbilityAny: {'strength': 13}),
      );

      expect(
        FeatEligibility.meets(
          feat,
          character: characterFixture(abilityScores: scoresWith(strength: 13)),
        ),
        isTrue,
      );
    });

    test('não cumpre quando falta um ponto', () {
      final feat = _feat(
        'grappler',
        const FeatPrerequisite(minAbilityAny: {'strength': 13}),
      );

      expect(
        FeatEligibility.meets(
          feat,
          character: characterFixture(abilityScores: scoresWith(strength: 12)),
        ),
        isFalse,
      );
    });

    test('dois atributos são alternativa, não exigência dupla', () {
      // Conjurador Ritual aceita Inteligência 13 OU Sabedoria 13.
      final feat = _feat(
        'ritual_caster',
        const FeatPrerequisite(
          minAbilityAny: {'intelligence': 13, 'wisdom': 13},
        ),
      );

      expect(
        FeatEligibility.meets(
          feat,
          character: characterFixture(abilityScores: scoresWith(wisdom: 14)),
        ),
        isTrue,
        reason: 'Sabedoria 14 já basta',
      );

      expect(
        FeatEligibility.meets(
          feat,
          character: characterFixture(
            abilityScores: scoresWith(intelligence: 12, wisdom: 12),
          ),
        ),
        isFalse,
      );
    });

    test('o que falta é dito com os dois atributos', () {
      final feat = _feat(
        'ritual_caster',
        const FeatPrerequisite(
          minAbilityAny: {'intelligence': 13, 'wisdom': 13},
        ),
      );

      final missing = FeatEligibility.missingRequirements(
        feat,
        character: characterFixture(),
      );

      expect(missing.single, 'Inteligência 13 ou Sabedoria 13');
    });
  });

  group('nível', () {
    test('nível baixo não alcança', () {
      final feat = _feat('cartomancer', const FeatPrerequisite(minLevel: 4));
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
      );

      expect(FeatEligibility.meets(feat, character: character), isFalse);
    });

    test('o nível total conta, não o da classe', () {
      // Multiclasse 2/2 alcança um pré-requisito de 4º nível.
      final feat = _feat('cartomancer', const FeatPrerequisite(minLevel: 4));
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'fighter', level: 2),
          ClassLevel(classId: 'wizard', level: 2),
        ],
      );

      expect(FeatEligibility.meets(feat, character: character), isTrue);
    });
  });

  group('conjuração', () {
    test('mago de 1º nível já conjura', () {
      final feat = _feat('war_caster', const FeatPrerequisite(requiresSpellcasting: true));
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'wizard', level: 1)],
      );

      expect(
        FeatEligibility.meets(feat, character: character, classes: _classes),
        isTrue,
      );
    });

    test('guerreiro não conjura', () {
      final feat = _feat('war_caster', const FeatPrerequisite(requiresSpellcasting: true));
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 20)],
      );

      expect(
        FeatEligibility.meets(feat, character: character, classes: _classes),
        isFalse,
      );
    });

    test('paladino de 1º nível ainda não conjura', () {
      // O pré-requisito é "capacidade de conjurar", e meio-conjurador só
      // conjura no 2º nível. Aceitar aqui seria errado pela regra.
      final feat = _feat('war_caster', const FeatPrerequisite(requiresSpellcasting: true));

      final level1 = characterFixture(
        classLevels: const [ClassLevel(classId: 'paladin', level: 1)],
      );
      final level2 = characterFixture(
        classLevels: const [ClassLevel(classId: 'paladin', level: 2)],
      );

      expect(
        FeatEligibility.meets(feat, character: level1, classes: _classes),
        isFalse,
      );
      expect(
        FeatEligibility.meets(feat, character: level2, classes: _classes),
        isTrue,
      );
    });
  });

  group('raça', () {
    test('a raça exata cumpre', () {
      final feat = _feat(
        'second_chance',
        const FeatPrerequisite(raceIds: ['halfling_phb']),
      );

      expect(
        FeatEligibility.meets(
          feat,
          character: characterFixture(speciesId: 'halfling_phb'),
          races: _races,
        ),
        isTrue,
      );
    });

    test('sub-raça cumpre o pré-requisito da raça mãe', () {
      // Precisão Élfica pede Elfo; quem é Elfo Alto é elfo.
      final feat = _feat(
        'elven_accuracy',
        const FeatPrerequisite(raceIds: ['elf_phb']),
      );

      expect(
        FeatEligibility.meets(
          feat,
          character: characterFixture(speciesId: 'elf_high_phb'),
          races: _races,
        ),
        isTrue,
      );
    });

    test('outra raça não cumpre', () {
      final feat = _feat(
        'elven_accuracy',
        const FeatPrerequisite(raceIds: ['elf_phb']),
      );

      expect(
        FeatEligibility.meets(
          feat,
          character: characterFixture(speciesId: 'dwarf_phb'),
          races: _races,
        ),
        isFalse,
      );
    });

    test('personagem sem raça não cumpre pré-requisito de raça', () {
      final feat = _feat(
        'elven_accuracy',
        const FeatPrerequisite(raceIds: ['elf_phb']),
      );

      expect(
        FeatEligibility.meets(feat, character: characterFixture(), races: _races),
        isFalse,
      );
    });

    test('tamanho é alternativa à raça na mesma condição', () {
      // Agilidade Compacta pede anão OU raça Pequena.
      final feat = _feat(
        'squat_nimbleness',
        const FeatPrerequisite(raceIds: ['dwarf_phb'], raceSizes: ['small']),
      );

      expect(
        FeatEligibility.meets(
          feat,
          character: characterFixture(speciesId: 'dwarf_phb'),
          races: _races,
        ),
        isTrue,
        reason: 'anão, mesmo sendo Médio',
      );

      expect(
        FeatEligibility.meets(
          feat,
          character: characterFixture(speciesId: 'halfling_phb'),
          races: _races,
        ),
        isTrue,
        reason: 'halfling é Pequeno',
      );

      expect(
        FeatEligibility.meets(
          feat,
          character: characterFixture(speciesId: 'elf_phb'),
          races: _races,
        ),
        isFalse,
      );
    });
  });

  group('talento exigido', () {
    test('exige o talento anterior', () {
      final feat = _feat(
        'knight_of_the_crown',
        const FeatPrerequisite(
          minLevel: 4,
          requiredFeatIds: ['squire_of_solamnia'],
        ),
      );

      final semTalento = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
      );
      final comTalento = characterFixture(
        classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
        feats: const [CharacterFeat(featId: 'squire_of_solamnia')],
      );

      expect(FeatEligibility.meets(feat, character: semTalento), isFalse);
      expect(FeatEligibility.meets(feat, character: comTalento), isTrue);
    });

    test('talento proibido bloqueia', () {
      final feat = _feat(
        'x',
        const FeatPrerequisite(forbiddenFeatIds: ['aberrant_dragonmark']),
      );

      final character = characterFixture(
        feats: const [CharacterFeat(featId: 'aberrant_dragonmark')],
      );

      expect(FeatEligibility.meets(feat, character: character), isFalse);
      expect(FeatEligibility.meets(feat, character: characterFixture()), isTrue);
    });
  });

  group('exigência não verificável', () {
    test('nota não esconde o talento', () {
      // Proficiência com armadura não existe na ficha. Esconder o Mestre de
      // Armadura Pesada de todo guerreiro seria pior que mostrar e avisar.
      final feat = _feat(
        'heavy_armor_master',
        const FeatPrerequisite(notes: ['proficiência com armaduras pesadas']),
      );

      expect(
        FeatEligibility.meets(feat, character: characterFixture()),
        isTrue,
      );
    });
  });

  group('available', () {
    test('filtra o que o personagem não alcança', () {
      final feats = [
        _feat('aberto', const FeatPrerequisite()),
        _feat('forte', const FeatPrerequisite(minAbilityAny: {'strength': 13})),
        _feat('alto', const FeatPrerequisite(minLevel: 8)),
      ];

      final available = FeatEligibility.available(
        feats: feats,
        character: characterFixture(
          abilityScores: scoresWith(strength: 15),
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
        ),
        classes: _classes,
      );

      expect(available.map((item) => item.id), ['aberto', 'forte']);
    });

    test('tira o talento não repetível que já foi pego', () {
      final feats = [
        _feat('uma_vez', const FeatPrerequisite()),
        const FeatEntry(id: 'de_novo', name: 'de_novo', repeatable: true),
      ];

      final available = FeatEligibility.available(
        feats: feats,
        character: characterFixture(
          feats: const [
            CharacterFeat(featId: 'uma_vez'),
            CharacterFeat(featId: 'de_novo'),
          ],
        ),
      );

      expect(available.map((item) => item.id), ['de_novo']);
    });
  });
}
