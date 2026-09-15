import 'dart:convert';

import 'package:dnd_ficha_app/features/character/data/mappers/character_json_codec.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/spellcasting_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Ficha com todos os campos preenchidos, para o round-trip provar que nada
/// se perde no caminho.
Character _fullCharacter() {
  return characterFixture(
    id: 'original-1',
    name: 'Vex Vessar',
    abilityScores: scoresWith(
      strength: 8,
      dexterity: 18,
      constitution: 14,
      intelligence: 12,
      wisdom: 15,
      charisma: 16,
    ),
    classLevels: const [
      ClassLevel(
        classId: 'ranger',
        level: 5,
        subclassId: 'hunter',
        spellcastingAbility: Ability.wisdom,
        spellcastingType: SpellcastingType.half,
      ),
      ClassLevel(classId: 'rogue', level: 2),
    ],
    hitPoints: const HitPoints(current: 30, maximum: 48, temporary: 5),
    skillProficiencies: skillsWith({
      Skill.stealth: ProficiencyLevel.expertise,
      Skill.survival: ProficiencyLevel.proficient,
      Skill.arcana: ProficiencyLevel.half,
    }),
    exhaustion: 2,
    conditions: const {Condition.paralyzed, Condition.poisoned},
    hitDiceUsed: 3,
  ).copyWith(
    playerName: 'Marcos',
    speciesId: 'wood_elf',
    backgroundId: 'custom',
    customBackground: const CustomBackground(
      name: 'Caçador de Recompensas',
      skillIds: ['stealth', 'survival'],
      features: 'Mandado sempre em aberto.',
    ),
    notes: 'Devo um favor à guilda.',
    combatStats: const CombatStats(
      armorClass: 17,
      initiativeBonus: 2,
      speedInMeters: 10.5,
    ),
    savingThrowProficiencies: const SavingThrowProficiencies(
      dexterity: true,
      wisdom: true,
    ),
    spells: const [
      CharacterSpell(
        spellId: 42,
        sourceType: 'class',
        sourceId: 'ranger',
        sourceName: 'Patrulheiro',
        isPrepared: true,
        isKnown: true,
        isAlwaysAvailable: false,
        notes: 'Favorita',
      ),
    ],
    magicItems: const [
      CharacterMagicItem(
        localId: 7,
        name: 'Cajado das Chamas',
        description: 'Solta labaredas.',
        charges: 3,
        maxCharges: 10,
        rechargeRule: 'amanhecer',
        castingAbility: 'intelligence',
        saveDc: 15,
        attackBonus: 7,
        spells: [
          CharacterMagicItemSpell(
            spellId: 99,
            usesCharges: true,
            chargeCost: 2,
            isAtWill: false,
            isAlwaysAvailable: true,
          ),
        ],
      ),
    ],
    inspiration: true,
    currency: const Currency(
      copper: 5,
      silver: 4,
      electrum: 3,
      gold: 200,
      platinum: 1,
    ),
  );
}

void main() {
  group('round-trip', () {
    test('preserva os dados de identidade e antecedente', () {
      final original = _fullCharacter();
      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(original),
      );

      expect(restored.id, original.id);
      expect(restored.name, 'Vex Vessar');
      expect(restored.playerName, 'Marcos');
      expect(restored.speciesId, 'wood_elf');
      expect(restored.backgroundId, 'custom');
      expect(restored.customBackground.name, 'Caçador de Recompensas');
      expect(restored.customBackground.skillIds, ['stealth', 'survival']);
      expect(
        restored.customBackground.features,
        'Mandado sempre em aberto.',
      );
      expect(restored.notes, 'Devo um favor à guilda.');
    });

    test('preserva atributos e estatísticas de combate', () {
      final original = _fullCharacter();
      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(original),
      );

      for (final ability in Ability.values) {
        expect(
          restored.abilityScores.valueFor(ability),
          original.abilityScores.valueFor(ability),
          reason: 'atributo ${ability.name}',
        );
      }

      expect(restored.combatStats.armorClass, 17);
      expect(restored.combatStats.initiativeBonus, 2);
      expect(restored.combatStats.speedInMeters, 10.5);
      expect(restored.hitPoints.current, 30);
      expect(restored.hitPoints.maximum, 48);
      expect(restored.hitPoints.temporary, 5);
    });

    test('preserva multiclasse com subclasse e conjuração', () {
      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(_fullCharacter()),
      );

      expect(restored.classLevels.length, 2);
      expect(restored.classLevels.first.classId, 'ranger');
      expect(restored.classLevels.first.level, 5);
      expect(restored.classLevels.first.subclassId, 'hunter');
      expect(
        restored.classLevels.first.spellcastingAbility,
        Ability.wisdom,
      );
      expect(
        restored.classLevels.first.spellcastingType,
        SpellcastingType.half,
      );
      // A ordem importa: define a classe inicial no cálculo de PV.
      expect(restored.classLevels.last.classId, 'rogue');
      expect(restored.classLevels.last.spellcastingType, isNull);
    });

    test('preserva os níveis de proficiência, não só quem é proficiente', () {
      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(_fullCharacter()),
      );

      expect(
        restored.skillProficiencies.levelFor(Skill.stealth),
        ProficiencyLevel.expertise,
      );
      expect(
        restored.skillProficiencies.levelFor(Skill.survival),
        ProficiencyLevel.proficient,
      );
      expect(
        restored.skillProficiencies.levelFor(Skill.arcana),
        ProficiencyLevel.half,
      );
      expect(
        restored.skillProficiencies.levelFor(Skill.athletics),
        ProficiencyLevel.none,
      );

      expect(restored.savingThrowProficiencies.dexterity, isTrue);
      expect(restored.savingThrowProficiencies.wisdom, isTrue);
      expect(restored.savingThrowProficiencies.strength, isFalse);
    });

    test('preserva magias, itens mágicos e as magias do item', () {
      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(_fullCharacter()),
      );

      expect(restored.spells.length, 1);
      expect(restored.spells.first.spellId, 42);
      expect(restored.spells.first.sourceName, 'Patrulheiro');
      expect(restored.spells.first.isPrepared, isTrue);
      expect(restored.spells.first.notes, 'Favorita');

      expect(restored.magicItems.length, 1);
      final item = restored.magicItems.first;
      expect(item.name, 'Cajado das Chamas');
      expect(item.charges, 3);
      expect(item.maxCharges, 10);
      expect(item.rechargeRule, 'amanhecer');
      expect(item.saveDc, 15);
      expect(item.attackBonus, 7);
      expect(item.spells.length, 1);
      expect(item.spells.first.spellId, 99);
      expect(item.spells.first.chargeCost, 2);
      expect(item.spells.first.usesCharges, isTrue);
    });

    test('preserva recursos de mesa e moedas', () {
      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(_fullCharacter()),
      );

      expect(restored.inspiration, isTrue);
      expect(restored.exhaustion, 2);
      expect(restored.conditions, {Condition.paralyzed, Condition.poisoned});
      expect(restored.hitDiceUsed, 3);
      expect(restored.currency.copper, 5);
      expect(restored.currency.silver, 4);
      expect(restored.currency.electrum, 3);
      expect(restored.currency.gold, 200);
      expect(restored.currency.platinum, 1);
    });
  });

  group('formato do arquivo', () {
    test('declara formato e versão', () {
      final json = jsonDecode(CharacterJsonCodec.encode(_fullCharacter()))
          as Map<String, dynamic>;

      expect(json['format'], 'dnd_ficha_app/character');
      expect(json['version'], CharacterJsonCodec.formatVersion);
      expect(json['character'], isA<Map<String, dynamic>>());
    });

    test('não grava as perícias sem proficiência', () {
      final json = jsonDecode(CharacterJsonCodec.encode(_fullCharacter()))
          as Map<String, dynamic>;
      final skills =
          (json['character'] as Map<String, dynamic>)['skills'] as Map;

      expect(skills.keys.toSet(), {'stealth', 'survival', 'arcana'});
    });

    test('importar com newId gera outro personagem', () {
      final original = _fullCharacter();
      final restored = CharacterJsonCodec.decode(
        CharacterJsonCodec.encode(original),
        newId: 'novo-99',
      );

      expect(restored.id, 'novo-99');
      expect(restored.name, original.name);
    });
  });

  group('entrada inválida', () {
    test('texto que não é JSON', () {
      expect(
        () => CharacterJsonCodec.decode('isso não é json'),
        throwsA(isA<CharacterImportException>()),
      );
    });

    test('JSON que não é objeto', () {
      expect(
        () => CharacterJsonCodec.decode('[1, 2, 3]'),
        throwsA(isA<CharacterImportException>()),
      );
    });

    test('arquivo de outro formato', () {
      final json = jsonEncode({'format': 'outro/app', 'character': {}});

      expect(
        () => CharacterJsonCodec.decode(json),
        throwsA(
          isA<CharacterImportException>().having(
            (e) => e.message,
            'message',
            contains('não é uma ficha deste app'),
          ),
        ),
      );
    });

    test('versão futura é recusada em vez de lida pela metade', () {
      final json = jsonEncode({
        'format': 'dnd_ficha_app/character',
        'version': CharacterJsonCodec.formatVersion + 1,
        'character': {'name': 'X'},
      });

      expect(
        () => CharacterJsonCodec.decode(json),
        throwsA(
          isA<CharacterImportException>().having(
            (e) => e.message,
            'message',
            contains('versão mais nova'),
          ),
        ),
      );
    });

    test('sem o objeto character', () {
      final json = jsonEncode({
        'format': 'dnd_ficha_app/character',
        'version': 1,
      });

      expect(
        () => CharacterJsonCodec.decode(json),
        throwsA(isA<CharacterImportException>()),
      );
    });

    test('ficha sem nome', () {
      final json = jsonEncode({
        'format': 'dnd_ficha_app/character',
        'version': 1,
        'character': {
          'id': 'x',
          'name': '   ',
          'classLevels': [
            {'classId': 'fighter', 'level': 1},
          ],
        },
      });

      expect(
        () => CharacterJsonCodec.decode(json),
        throwsA(
          isA<CharacterImportException>().having(
            (e) => e.message,
            'message',
            contains('não tem nome'),
          ),
        ),
      );
    });

    test('ficha sem classe', () {
      final json = jsonEncode({
        'format': 'dnd_ficha_app/character',
        'version': 1,
        'character': {'id': 'x', 'name': 'Vex', 'classLevels': []},
      });

      expect(
        () => CharacterJsonCodec.decode(json),
        throwsA(
          isA<CharacterImportException>().having(
            (e) => e.message,
            'message',
            contains('pelo menos uma classe'),
          ),
        ),
      );
    });
  });

  group('tolerância a dados incompletos ou fora de faixa', () {
    Character decodeMinimal(Map<String, dynamic> character) {
      return CharacterJsonCodec.decode(
        jsonEncode({
          'format': 'dnd_ficha_app/character',
          'version': 1,
          'character': character,
        }),
      );
    }

    test('campos ausentes caem em padrões seguros', () {
      final restored = decodeMinimal({
        'id': 'x',
        'name': 'Vex',
        'classLevels': [
          {'classId': 'fighter', 'level': 1},
        ],
      });

      expect(restored.notes, '');
      expect(restored.playerName, isNull);
      expect(restored.hitPoints.maximum, 1);
      expect(restored.combatStats.armorClass, 10);
      expect(restored.combatStats.speedInMeters, 9);
      expect(restored.currency.isEmpty, isTrue);
      expect(restored.spells, isEmpty);
      expect(restored.magicItems, isEmpty);
      expect(restored.abilityScores.strength, 10);
    });

    test('atributo fora de 1..30 é ajustado, sem estourar o assert', () {
      final restored = decodeMinimal({
        'id': 'x',
        'name': 'Vex',
        'classLevels': [
          {'classId': 'fighter', 'level': 1},
        ],
        'abilityScores': {'strength': 99, 'dexterity': 0},
      });

      expect(restored.abilityScores.strength, 30);
      expect(restored.abilityScores.dexterity, 1);
    });

    test('PV atual maior que o máximo é limitado', () {
      final restored = decodeMinimal({
        'id': 'x',
        'name': 'Vex',
        'classLevels': [
          {'classId': 'fighter', 'level': 1},
        ],
        'hitPoints': {'current': 500, 'maximum': 20},
      });

      expect(restored.hitPoints.current, 20);
    });

    test('exaustão fora de 0..6 é ajustada', () {
      final restored = decodeMinimal({
        'id': 'x',
        'name': 'Vex',
        'classLevels': [
          {'classId': 'fighter', 'level': 1},
        ],
        'exhaustion': 42,
      });

      expect(restored.exhaustion, 6);
    });

    test('condição desconhecida no arquivo é ignorada', () {
      // Arquivo de uma versão mais nova do app não pode travar a importação.
      final restored = decodeMinimal({
        'id': 'x',
        'name': 'Vex',
        'classLevels': [
          {'classId': 'fighter', 'level': 1},
        ],
        'conditions': ['poisoned', 'enfeitiçado_de_lua'],
      });

      expect(restored.conditions, {Condition.poisoned});
    });

    test('arquivo antigo sem conditions abre sem condição', () {
      final restored = decodeMinimal({
        'id': 'x',
        'name': 'Vex',
        'classLevels': [
          {'classId': 'fighter', 'level': 1},
        ],
      });

      expect(restored.conditions, isEmpty);
    });

    test('nível de classe fora de 1..20 é ajustado', () {
      final restored = decodeMinimal({
        'id': 'x',
        'name': 'Vex',
        'classLevels': [
          {'classId': 'fighter', 'level': 99},
        ],
      });

      expect(restored.classLevels.first.level, 20);
    });

    test('classe sem id é descartada, mas a válida entra', () {
      final restored = decodeMinimal({
        'id': 'x',
        'name': 'Vex',
        'classLevels': [
          {'level': 3},
          {'classId': 'wizard', 'level': 2},
        ],
      });

      expect(restored.classLevels.length, 1);
      expect(restored.classLevels.first.classId, 'wizard');
    });

    test('perícia desconhecida no arquivo é ignorada', () {
      final restored = decodeMinimal({
        'id': 'x',
        'name': 'Vex',
        'classLevels': [
          {'classId': 'fighter', 'level': 1},
        ],
        'skills': {'stealth': 2, 'dancing': 3},
      });

      expect(
        restored.skillProficiencies.activeLevels.keys,
        [Skill.stealth],
      );
    });

    test('item mágico sem nome é descartado', () {
      final restored = decodeMinimal({
        'id': 'x',
        'name': 'Vex',
        'classLevels': [
          {'classId': 'fighter', 'level': 1},
        ],
        'magicItems': [
          {'description': 'sem nome'},
          {'name': 'Adaga +1'},
        ],
      });

      expect(restored.magicItems.length, 1);
      expect(restored.magicItems.first.name, 'Adaga +1');
    });
  });
}
