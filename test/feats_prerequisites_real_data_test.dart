import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feat_eligibility.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_prerequisite.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Roda o filtro de pré-requisito contra os dados REAIS do compêndio.
///
/// Os outros testes usam talentos e raças inventados, o que prova a mecânica
/// mas não o conteúdo. Aqui o que está sob teste é o `feats.json` de verdade:
/// um id de raça errado ou um pré-requisito esquecido aparece como um talento
/// visível para quem não deveria vê-lo, e é isso que se pega aqui.
void main() {
  late List<FeatEntry> feats;
  late List<ClassEntry> classes;
  late List<RaceEntry> races;

  /// Lê os assets do jeito mais simples possível: o objetivo é testar a regra
  /// contra o conteúdo, não exercitar o parser do repositório.
  List<Map<String, dynamic>> readList(String path) {
    final decoded = jsonDecode(File(path).readAsStringSync()) as List<dynamic>;
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  List<String> strings(Map<String, dynamic> map, String key) {
    return (map[key] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(growable: false);
  }

  setUpAll(() {
    feats = readList('assets/data/srd/feats.json').map((item) {
      final requires = Map<String, dynamic>.from(
        item['requires'] as Map? ?? const {},
      );
      final abilities = Map<String, dynamic>.from(
        requires['min_ability_any'] as Map? ?? const {},
      );

      return FeatEntry(
        id: item['id'] as String,
        name: item['name'] as String,
        prerequisite: item['prerequisite'] as String?,
        repeatable: item['repeatable'] == true,
        requires: FeatPrerequisite(
          minLevel: (requires['min_level'] as int?) ?? 0,
          minAbilityAny: {
            for (final entry in abilities.entries)
              entry.key: entry.value as int,
          },
          requiresSpellcasting: requires['spellcasting'] == true,
          raceIds: strings(requires, 'race_ids'),
          raceSizes: strings(requires, 'race_sizes'),
          classIds: strings(requires, 'class_ids'),
          requiredFeatIds: strings(requires, 'feat_ids'),
          forbiddenFeatIds: strings(requires, 'not_feat_ids'),
          notes: strings(requires, 'notes'),
        ),
      );
    }).toList(growable: false);

    classes = readList('assets/data/srd/classes.json').map((item) {
      return ClassEntry(
        id: item['id'] as String,
        name: item['name'] as String,
        hitDie: item['hit_die'] as String,
        source: item['source'] as String? ?? 'srd',
        skillOptions: const [],
        savingThrows: const [],
        spellcastingType: item['spellcasting_type'] as String?,
      );
    }).toList(growable: false);

    races = readList('assets/data/srd/races.json').map((item) {
      return RaceEntry(
        id: item['id'] as String,
        name: item['name'] as String,
        source: item['source'] as String? ?? 'srd',
        size: item['size'] as String?,
        parentRaceId: item['parent_race_id'] as String?,
        isSubrace: item['is_subrace'] == true,
      );
    }).toList(growable: false);
  });

  Set<String> availableFor(Character character) {
    return FeatEligibility.available(
      feats: feats,
      character: character,
      classes: classes,
      races: races,
    ).map((item) => item.id).toSet();
  }

  test('o compêndio carregado tem os 105 talentos', () {
    expect(feats, hasLength(105));
  });

  group('guerreiro humano de 4º nível, Força 16 e Destreza 12', () {
    late Set<String> available;

    setUpAll(() {
      available = availableFor(
        characterFixture(
          speciesId: 'human_phb',
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          abilityScores: scoresWith(strength: 16, dexterity: 12, charisma: 10),
        ),
      );
    });

    test('vê o que não pede nada', () {
      expect(available, contains('alert'));
      expect(available, contains('tough'));
      expect(available, contains('skilled'));
    });

    test('vê o de Força 13, não o de Destreza 13', () {
      expect(available, contains('grappler'), reason: 'Força 16');
      expect(
        available,
        isNot(contains('defensive_duelist')),
        reason: 'Destreza 12 não alcança 13',
      );
      expect(available, isNot(contains('skulker')), reason: 'pede Destreza 13');
    });

    test('não vê o de Carisma 13', () {
      expect(available, isNot(contains('inspiring_leader')));
    });

    test('não vê talento de conjurador', () {
      expect(available, isNot(contains('war_caster')));
      expect(available, isNot(contains('elemental_adept')));
      expect(available, isNot(contains('spell_sniper')));
      expect(available, isNot(contains('cartomancer')));
    });

    test('não vê talento de outra raça', () {
      expect(available, isNot(contains('elven_accuracy')));
      expect(available, isNot(contains('dwarven_fortitude')));
      expect(available, isNot(contains('second_chance')));
      expect(available, isNot(contains('flames_of_phlegethos')));
    });

    test('vê o de humano', () {
      expect(available, contains('prodigy'));
    });

    test('não vê talento que exige outro talento antes', () {
      expect(available, isNot(contains('knight_of_the_crown')));
      expect(available, isNot(contains('ember_of_the_fire_giant')));
      expect(available, isNot(contains('strixhaven_mascot')));
      expect(available, isNot(contains('adept_of_the_black_robes')));
      expect(available, isNot(contains('agent_of_order')));
    });

    test('vê o talento base das correntes, que não exige nada antes', () {
      // É o caso do que apareceu na tela: Golpe dos Gigantes só pede
      // proficiência com arma marcial, que o app não guarda, então entra com
      // aviso em vez de ficar escondido.
      expect(available, contains('strike_of_the_giants'));
      expect(available, contains('squire_of_solamnia'));
      expect(available, contains('scion_of_the_outer_planes'));
    });
  });

  group('mago elfo alto de 4º nível, Inteligência 16', () {
    late Set<String> available;

    setUpAll(() {
      available = availableFor(
        characterFixture(
          speciesId: 'elf_high_phb',
          classLevels: const [ClassLevel(classId: 'wizard', level: 4)],
          abilityScores: scoresWith(intelligence: 16, dexterity: 14),
        ),
      );
    });

    test('vê talento de conjurador', () {
      expect(available, contains('war_caster'));
      expect(available, contains('spell_sniper'));
      expect(available, contains('elemental_adept'));
      expect(available, contains('cartomancer'));
    });

    test('vê o de Elfo pela sub-raça', () {
      // Elfo Alto é sub-raça de Elfo: precisa cumprir o pré-requisito da mãe.
      expect(available, contains('elven_accuracy'));
      expect(available, contains('revenant_blade'));
    });

    test('vê o exclusivo de Elfo Alto', () {
      expect(available, contains('fey_teleportation'));
    });

    test('não vê o de Elfo da Floresta nem o de Drow', () {
      expect(available, isNot(contains('wood_elf_magic')));
      expect(available, isNot(contains('drow_high_magic')));
    });

    test('vê o Conjurador Ritual por Inteligência 13', () {
      expect(available, contains('ritual_caster'));
    });
  });

  group('nível baixo', () {
    test('personagem de 1º nível não vê nada que exija 4º nível', () {
      final available = availableFor(
        characterFixture(
          speciesId: 'human_phb',
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
      );

      // Todos os talentos com min_level: 4 no compêndio.
      final gatedByLevel = feats
          .where((feat) => feat.requires.minLevel >= 4)
          .map((feat) => feat.id);

      expect(gatedByLevel, isNotEmpty, reason: 'o compêndio deve ter correntes');

      for (final id in gatedByLevel) {
        expect(available, isNot(contains(id)), reason: '$id exige 4º nível');
      }
    });
  });

  group('correntes de talento', () {
    test('pegar o talento base libera o seguinte', () {
      final antes = availableFor(
        characterFixture(
          speciesId: 'human_phb',
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
        ),
      );

      final depois = availableFor(
        characterFixture(
          speciesId: 'human_phb',
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          feats: const [CharacterFeat(featId: 'strike_of_the_giants')],
        ),
      );

      expect(antes, isNot(contains('ember_of_the_fire_giant')));
      expect(depois, contains('ember_of_the_fire_giant'));
      expect(depois, contains('vigor_of_the_hill_giant'));

      // E o talento base sai da lista, porque não é repetível.
      expect(depois, isNot(contains('strike_of_the_giants')));
    });

    test('o repetível continua na lista depois de pego', () {
      final available = availableFor(
        characterFixture(
          speciesId: 'human_phb',
          classLevels: const [ClassLevel(classId: 'wizard', level: 4)],
          feats: const [CharacterFeat(featId: 'elemental_adept')],
        ),
      );

      expect(available, contains('elemental_adept'));
    });
  });

  group('exigência que o app não confere', () {
    test('todo talento com nota e sem regra verificável fica visível', () {
      // A decisão registrada: esconder por falta de dado tiraria da lista
      // talentos que o personagem realmente pode ter. Este teste trava essa
      // decisão, para ninguém "consertar" o filtro sem perceber.
      final available = availableFor(
        characterFixture(
          speciesId: 'human_phb',
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
        ),
      );

      final onlyNotes = feats.where(
        (feat) =>
            feat.requires.notes.isNotEmpty &&
            feat.requires.isOpen &&
            feat.requires.minLevel == 0,
      );

      expect(onlyNotes, isNotEmpty);

      for (final feat in onlyNotes) {
        expect(
          available,
          contains(feat.id),
          reason: '${feat.id} só tem exigência não verificável',
        );
      }
    });

    test('as de armadura aparecem, com o aviso', () {
      final available = availableFor(
        characterFixture(
          speciesId: 'human_phb',
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
        ),
      );

      for (final id in const [
        'heavily_armored',
        'heavy_armor_master',
        'moderately_armored',
        'medium_armor_master',
      ]) {
        expect(available, contains(id));

        final feat = feats.firstWhere((item) => item.id == id);
        expect(
          feat.requires.notes,
          isNotEmpty,
          reason: '$id precisa avisar o que o app não confere',
        );
      }
    });
  });

  group('cobertura do filtro', () {
    test('nenhum personagem vê o compêndio inteiro', () {
      // Se ninguém for filtrado, o filtro não está agindo.
      final available = availableFor(
        characterFixture(
          speciesId: 'human_phb',
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
        ),
      );

      expect(available.length, lessThan(feats.length));
    });

    test('quem tem tudo em 8 e nenhuma raça vê menos que um herói montado', () {
      final fraco = availableFor(
        characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 4)],
          abilityScores: scoresWith(
            strength: 8,
            dexterity: 8,
            constitution: 8,
            intelligence: 8,
            wisdom: 8,
            charisma: 8,
          ),
        ),
      );

      final forte = availableFor(
        characterFixture(
          speciesId: 'elf_high_phb',
          classLevels: const [ClassLevel(classId: 'wizard', level: 4)],
          abilityScores: scoresWith(
            strength: 14,
            dexterity: 14,
            constitution: 14,
            intelligence: 16,
            wisdom: 14,
            charisma: 14,
          ),
        ),
      );

      expect(fraco.length, lessThan(forte.length));
    });
  });
}
