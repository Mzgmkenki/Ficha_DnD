import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dnd_ficha_app/features/character/data/pdf/character_sheet_pdf.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/death_saves.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/alignment.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/magic_item_bonus.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_proficiencies.dart';

import 'character_fixture.dart';

/// Fichas de exemplo para a verificação do PDF.
///
/// São cinco casos escolhidos porque cada um estressa uma coisa diferente do
/// layout: a mais simples mostra se a ficha vazia fica apresentável, a de muitas
/// características e a de conjurador testam a paginação, a de armas e itens
/// testa as tabelas, e a de textos longos testa a quebra de linha e os acentos.
class PdfSamples {
  const PdfSamples._();

  static const List<String> names = [
    'simples',
    'muitas-caracteristicas',
    'conjurador',
    'armas-e-itens',
    'textos-longos',
  ];

  static CharacterSheetPdfData byName(String name) {
    switch (name) {
      case 'simples':
        return simple();
      case 'muitas-caracteristicas':
        return manyFeatures();
      case 'conjurador':
        return caster();
      case 'armas-e-itens':
        return weaponsAndItems();
      case 'textos-longos':
        return longText();
      default:
        throw ArgumentError('Exemplo desconhecido: $name');
    }
  }

  // ------------------------------------------------------------------ exemplos

  /// Ficha mínima: uma classe, nada preenchido.
  static CharacterSheetPdfData simple() {
    return CharacterSheetPdfData(
      character: characterFixture(
        name: 'Bran',
        classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
      ),
      classes: const [_fighter],
      weapons: _weaponCatalog,
      iconBytes: markPng(),
      titleFontBytes: null,
    );
  }

  /// Ficha carregada de características: força o documento a virar página.
  static CharacterSheetPdfData manyFeatures() {
    final features = <ClassFeatureEntry>[
      for (var level = 1; level <= 12; level++)
        ClassFeatureEntry(
          classId: 'fighter',
          level: level,
          features: [
            ClassFeature(
              name: 'Característica de nível $level',
              description:
                  'Descrição longa o bastante para ocupar mais de uma linha na '
                  'ficha impressa, com acentuação em português: ação, coração, '
                  'ímpeto, sanguessuga e três reticências.',
            ),
            ClassFeature(name: 'Marco sem texto do nível $level'),
          ],
          source: 'srd',
        ),
    ];

    return CharacterSheetPdfData(
      character: characterFixture(
        name: 'Gundren Pedrarrocha',
        abilityScores: scoresWith(
          strength: 18,
          dexterity: 14,
          constitution: 16,
          intelligence: 10,
          wisdom: 12,
          charisma: 8,
        ),
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            subclassId: 'fighter_champion',
            level: 12,
          ),
        ],
        hitPoints: const HitPoints(current: 74, maximum: 110, temporary: 8),
        skillProficiencies: skillsWith({
          for (final skill in Skill.values) skill: ProficiencyLevel.proficient,
        }),
        speciesId: 'high_elf',
        backgroundId: 'acolyte',
        feats: const [],
      ).copyWith(
        playerName: 'Marcos',
        inspiration: true,
        currency: const Currency(gold: 1450, silver: 22, copper: 9),
        notes: 'Procura o irmão desaparecido nas Montanhas da Espada.',
      ),
      classes: const [_fighter],
      subclasses: const [_champion],
      races: const [_highElf],
      backgrounds: const [_acolyte],
      classFeatures: features,
      weapons: _weaponCatalog,
      iconBytes: markPng(),
    );
  }

  /// Conjurador com muitas magias, em vários círculos.
  static CharacterSheetPdfData caster() {
    final spells = <SpellEntry>[];
    final links = <CharacterSpell>[];

    var id = 1;
    for (var level = 0; level <= 5; level++) {
      for (var index = 0; index < 8; index++) {
        spells.add(
          SpellEntry(
            id: id,
            namePt: 'Magia $id de ${level == 0 ? 'truque' : '$levelº'}',
            nameOriginal: 'Spell $id',
            level: level,
            school: 'Evocação',
            castingTime: 'Uma ação',
            range: '18 m',
            components: 'V S',
            hasCostlyMaterials: false,
            duration: 'Instantânea',
            concentration: index.isEven,
            ritual: index % 3 == 0,
            classes: const ['wizard'],
            subclasses: const [],
            description: '',
            source: 'phb',
            page: '1',
            isSrd: true,
          ),
        );

        links.add(
          CharacterSpell(
            spellId: id,
            sourceType: 'class',
            sourceId: 'wizard',
            sourceName: 'Mago',
            isPrepared: index.isEven,
            isKnown: true,
            isAlwaysAvailable: level == 0,
          ),
        );

        id++;
      }
    }

    return CharacterSheetPdfData(
      character: characterFixture(
        name: 'Elaria Sussurrafolha',
        abilityScores: scoresWith(
          dexterity: 14,
          constitution: 14,
          intelligence: 20,
          wisdom: 12,
          charisma: 10,
        ),
        classLevels: const [ClassLevel(classId: 'wizard', level: 9)],
        hitPoints: const HitPoints(current: 41, maximum: 54),
        spells: links,
      ),
      classes: const [_wizard],
      spells: spells,
      spellSlots: const [_slotRow],
      weapons: _weaponCatalog,
      iconBytes: markPng(),
    );
  }

  /// Armas e itens mágicos, cobrindo os quatro casos de bônus.
  static CharacterSheetPdfData weaponsAndItems() {
    return CharacterSheetPdfData(
      character: characterFixture(
        name: 'Thorin Mãodeferro',
        abilityScores: scoresWith(strength: 18, dexterity: 16, constitution: 15),
        classLevels: const [ClassLevel(classId: 'fighter', level: 8)],
        hitPoints: const HitPoints(current: 60, maximum: 76),
        combatStats: const CombatStats(
          armorClass: 18,
          initiativeBonus: 2,
          speedInMeters: 9,
        ),
        magicItems: [
          // Arma mágica: só ataque e dano com arma.
          CharacterMagicItem(
            localId: 1,
            name: 'Machado da Alvorada',
            description: 'Brilha ao amanhecer.',
            spells: const [],
            bonus: MagicItemBonus.plusOne,
            bonusTargets: const {
              MagicItemBonusTarget.weaponAttack,
              MagicItemBonusTarget.weaponDamage,
            },
          ),
          // Foco mágico: ataque mágico e CD, sem tocar em arma.
          CharacterMagicItem(
            localId: 2,
            name: 'Amuleto do Verbo',
            description: 'Sussurra em élfico antigo.',
            spells: const [],
            bonus: MagicItemBonus.plusTwo,
            bonusTargets: const {
              MagicItemBonusTarget.spellAttack,
              MagicItemBonusTarget.spellSaveDc,
            },
            requiresAttunement: true,
            isAttuned: true,
          ),
          // Exige sintonia e não está sintonizado: declara o bônus, não soma.
          CharacterMagicItem(
            localId: 3,
            name: 'Bracelete Adormecido',
            description: 'Ainda não respondeu ao portador.',
            spells: const [],
            bonus: MagicItemBonus.plusThree,
            bonusTargets: const {MagicItemBonusTarget.weaponAttack},
            requiresAttunement: true,
          ),
          // Guardado: também não soma.
          CharacterMagicItem(
            localId: 4,
            name: 'Escudo de Reserva +1',
            description: 'Está no lombo da mula.',
            spells: const [],
            bonus: MagicItemBonus.plusOne,
            bonusTargets: const {MagicItemBonusTarget.weaponAttack},
            isEquipped: false,
          ),
          // Sem bônus, com cargas e CD fixa.
          const CharacterMagicItem(
            localId: 5,
            name: 'Varinha de Bolas de Fogo',
            description: 'Sete cargas ao amanhecer.',
            spells: [],
            charges: 5,
            maxCharges: 7,
            rechargeRule: 'amanhecer',
            saveDc: 15,
          ),
          // Valor legado fora das opções: preservado e marcado para revisão.
          CharacterMagicItem.fromLegacyBonuses(
            localId: 6,
            name: 'Adaga Rachada',
            description: 'Item antigo, cadastrado à mão.',
            spells: const [],
            weaponAttackBonus: -1,
          ),
        ],
      ).copyWith(
        alignment: CharacterAlignment.lawfulGood,
        // Sequência de testes em andamento, para o PDF sair com marcadores.
        deathSaves: const DeathSaves(successes: 2, failures: 1),
        weapons: const [
          CharacterWeapon(
            localId: 1,
            weaponId: 'battleaxe',
            name: 'Machado da Alvorada',
            magicBonus: 1,
          ),
          CharacterWeapon(localId: 2, weaponId: 'longbow'),
          CharacterWeapon(
            localId: 3,
            weaponId: 'rapier',
            chosenAbility: Ability.dexterity,
          ),
          CharacterWeapon(localId: 4, weaponId: 'longsword', twoHanded: true),
          // Id que não existe no compêndio: precisa ser avisado, não sumir.
          CharacterWeapon(localId: 5, weaponId: 'arma_inventada'),
        ],
        currency: const Currency(platinum: 3, gold: 210, silver: 5),
      ),
      classes: const [_fighter],
      weapons: _weaponCatalog,
      iconBytes: markPng(),
    );
  }

  /// Textos longos e acentuação, para conferir quebra de linha e encoding.
  static CharacterSheetPdfData longText() {
    const long =
        'Ação, coração, órgão, ímã, você, avó, avô, três, à, ãos, çedilha, '
        'püngüim, Ñandu, Àgua, êxito, ôtimo, úmido, ünico. '
        'Este parágrafo existe para forçar quebra de linha em várias linhas '
        'seguidas e conferir que nada é cortado no meio nem escapa da margem '
        'direita da página, mesmo quando a descrição não tem espaço em branco '
        'conveniente perto do fim da linha.';

    return CharacterSheetPdfData(
      character: characterFixture(
        name: 'Anaïs de Sant\'Ana do Coração Ardente da Serra Acima',
        abilityScores: scoresWith(charisma: 18, wisdom: 16),
        classLevels: const [
          ClassLevel(
            classId: 'cleric',
            subclassId: 'cleric_life',
            level: 6,
          ),
        ],
        hitPoints: const HitPoints(current: 38, maximum: 45, temporary: 5),
        conditions: const {
          Condition.paralyzed,
          Condition.frightened,
          Condition.poisoned,
        },
        exhaustion: 3,
        speciesId: 'high_elf',
        feats: const [
          CharacterFeat(featId: 'alert', chosenAbility: Ability.wisdom),
        ],
      ).copyWith(
        playerName: 'Uma jogadora com um nome bastante comprido também',
        notes: '$long $long',
      ),
      classes: const [_cleric],
      subclasses: const [
        SubclassEntry(
          id: 'cleric_life',
          classId: 'cleric',
          name: 'Domínio da Vida e da Recuperação Prolongada',
          source: 'phb',
          features: [
            SubclassFeature(level: 1, name: 'Discípulo da Vida', description: long),
            SubclassFeature(level: 2, name: 'Preservar a Vida', description: long),
          ],
        ),
      ],
      races: const [_highElf],
      backgrounds: const [
        BackgroundEntry(
          id: 'acolyte',
          name: 'Acólito',
          skillIds: ['insight', 'religion'],
          featureName: 'Abrigo dos Fiéis',
          featureDescription: long,
          description: long,
        ),
      ],
      classFeatures: const [
        ClassFeatureEntry(
          classId: 'cleric',
          level: 1,
          features: [ClassFeature(name: 'Conjuração', description: long)],
          source: 'srd',
        ),
      ],
      feats: const [
        FeatEntry(id: 'alert', name: 'Alerta', description: long, source: 'phb'),
      ],
      weapons: _weaponCatalog,
      iconBytes: markPng(),
    );
  }

  // ------------------------------------------------------------------ compêndio

  static const _fighter = ClassEntry(
    id: 'fighter',
    name: 'Guerreiro',
    hitDie: 'd10',
    source: 'srd',
    skillOptions: [],
    savingThrows: ['strength', 'constitution'],
    subclassLevel: 3,
    subclassLabel: 'Arquétipo Marcial',
    weaponProficiencies: WeaponProficiencies(
      categories: [WeaponCategory.simple, WeaponCategory.martial],
    ),
  );

  static const _wizard = ClassEntry(
    id: 'wizard',
    name: 'Mago',
    hitDie: 'd6',
    source: 'srd',
    skillOptions: [],
    savingThrows: ['intelligence', 'wisdom'],
    spellcastingType: 'full',
    spellcastingAbility: 'intelligence',
    subclassLevel: 2,
    subclassLabel: 'Tradição Arcana',
  );

  static const _cleric = ClassEntry(
    id: 'cleric',
    name: 'Clérigo',
    hitDie: 'd8',
    source: 'srd',
    skillOptions: [],
    savingThrows: ['wisdom', 'charisma'],
    spellcastingType: 'full',
    spellcastingAbility: 'wisdom',
    subclassLevel: 1,
    subclassLabel: 'Domínio Divino',
  );

  static const _champion = SubclassEntry(
    id: 'fighter_champion',
    classId: 'fighter',
    name: 'Campeão',
    source: 'phb',
    features: [
      SubclassFeature(
        level: 3,
        name: 'Crítico Aprimorado',
        description: 'Acerto crítico em 19 ou 20.',
      ),
      SubclassFeature(
        level: 7,
        name: 'Atleta Notável',
        description: 'Metade da proficiência em testes sem proficiência.',
      ),
    ],
  );

  static const _highElf = RaceEntry(
    id: 'high_elf',
    name: 'Elfo Alto',
    source: 'phb',
    size: 'Médio',
    speed: 9,
    darkvision: 18,
    traits: ['Ancestralidade Feérica', 'Transe', 'Treinamento com Armas Élficas'],
    languages: ['Comum', 'Élfico'],
  );

  static const _acolyte = BackgroundEntry(
    id: 'acolyte',
    name: 'Acólito',
    skillIds: ['insight', 'religion'],
    featureName: 'Abrigo dos Fiéis',
    featureDescription: 'Recebe cura e abrigo em templos.',
  );

  static const _slotRow = SpellSlotProgressionEntry(
    tableId: 'full',
    level: 9,
    first: 4,
    second: 3,
    third: 3,
    fourth: 3,
    fifth: 1,
    sixth: 0,
    seventh: 0,
    eighth: 0,
    ninth: 0,
  );

  /// Só as armas que os exemplos usam.
  static const List<WeaponEntry> _weaponCatalog = [
    WeaponEntry(
      id: 'battleaxe',
      name: 'Machado de Batalha',
      category: WeaponCategory.martial,
      rangeType: WeaponRangeType.melee,
      damage: '1d8',
      damageType: WeaponDamageType.slashing,
      properties: [WeaponProperty.versatile],
      versatileDamage: '1d10',
    ),
    WeaponEntry(
      id: 'longbow',
      name: 'Arco Longo',
      category: WeaponCategory.martial,
      rangeType: WeaponRangeType.ranged,
      damage: '1d8',
      damageType: WeaponDamageType.piercing,
      properties: [
        WeaponProperty.ammunition,
        WeaponProperty.heavy,
        WeaponProperty.twoHanded,
      ],
      range: WeaponRange(normal: 45, long: 180),
    ),
    WeaponEntry(
      id: 'rapier',
      name: 'Rapieira',
      category: WeaponCategory.martial,
      rangeType: WeaponRangeType.melee,
      damage: '1d8',
      damageType: WeaponDamageType.piercing,
      properties: [WeaponProperty.finesse],
    ),
    WeaponEntry(
      id: 'longsword',
      name: 'Espada Longa',
      category: WeaponCategory.martial,
      rangeType: WeaponRangeType.melee,
      damage: '1d8',
      damageType: WeaponDamageType.slashing,
      properties: [WeaponProperty.versatile],
      versatileDamage: '1d10',
    ),
  ];

  // ----------------------------------------------------------------- imagem

  /// PNG pequeno para exercitar marca d'água e selo.
  ///
  /// Gerado aqui em vez de colado em base64: base64 escrito à mão falhou no CRC
  /// do decodificador, e montar os chunks com o checksum calculado é a única
  /// forma de garantir uma imagem que o `pdf` aceite.
  static Uint8List markPng({int size = 16}) {
    final header = <int>[
      ..._be32(size),
      ..._be32(size),
      8, // 8 bits por canal
      6, // RGBA
      0, 0, 0, // compressão, filtro e entrelaçamento padrão
    ];

    final raw = <int>[];
    for (var y = 0; y < size; y++) {
      raw.add(0); // filtro da linha
      for (var x = 0; x < size; x++) {
        raw.addAll(const [0xB7, 0x1C, 0x24, 0xFF]); // vermelho DragonSheet
      }
    }

    return Uint8List.fromList([
      137, 80, 78, 71, 13, 10, 26, 10, // assinatura
      ..._chunk('IHDR', header),
      ..._chunk('IDAT', ZLibCodec().encode(raw)),
      ..._chunk('IEND', const []),
    ]);
  }

  static List<int> _be32(int value) => [
        (value >> 24) & 0xFF,
        (value >> 16) & 0xFF,
        (value >> 8) & 0xFF,
        value & 0xFF,
      ];

  static List<int> _chunk(String type, List<int> data) {
    final body = <int>[...ascii.encode(type), ...data];
    return [..._be32(data.length), ...body, ..._be32(_crc32(body))];
  }

  static int _crc32(List<int> bytes) {
    var crc = 0xFFFFFFFF;

    for (final byte in bytes) {
      crc ^= byte;
      for (var bit = 0; bit < 8; bit++) {
        crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
      }
    }

    return crc ^ 0xFFFFFFFF;
  }
}
