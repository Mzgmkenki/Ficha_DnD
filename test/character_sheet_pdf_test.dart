import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dnd_ficha_app/features/character/data/pdf/character_sheet_pdf.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/portrait_avatar.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// PNG gerado aqui, em vez de colado em base64.
///
/// A logo de verdade não está no repositório, então o teste precisa da própria
/// imagem para exercitar a marca d'água e o retrato. Base64 escrito à mão
/// falhou no CRC do decodificador; montar os chunks com o checksum calculado é
/// a única forma de garantir um PNG que o `pdf` aceite.
Uint8List _png({int size = 8}) {
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
      raw.addAll(const [0xE0, 0x3A, 0x45, 0xFF]); // vermelho do app, opaco
    }
  }

  return Uint8List.fromList([
    137, 80, 78, 71, 13, 10, 26, 10, // assinatura
    ..._chunk('IHDR', header),
    ..._chunk('IDAT', ZLibCodec().encode(raw)),
    ..._chunk('IEND', const []),
  ]);
}

List<int> _be32(int value) => [
  (value >> 24) & 0xFF,
  (value >> 16) & 0xFF,
  (value >> 8) & 0xFF,
  value & 0xFF,
];

List<int> _chunk(String type, List<int> data) {
  final body = <int>[...ascii.encode(type), ...data];
  return [..._be32(data.length), ...body, ..._be32(_crc32(body))];
}

int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;

  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }

  return crc ^ 0xFFFFFFFF;
}

const _cleric = ClassEntry(
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

const _lifeDomain = SubclassEntry(
  id: 'cleric_life_domain',
  classId: 'cleric',
  name: 'Domínio da Vida',
  source: 'phb',
  features: [
    SubclassFeature(
      level: 1,
      name: 'Discípulo da Vida',
      description: 'Cura mais com magias de cura.',
    ),
  ],
);

const _bless = SpellEntry(
  id: 42,
  namePt: 'Bênção',
  nameOriginal: 'Bless',
  level: 1,
  school: 'Encantamento',
  castingTime: 'Uma ação',
  range: '9 m',
  components: 'V S M',
  hasCostlyMaterials: false,
  duration: '1 minuto',
  concentration: true,
  ritual: false,
  classes: ['cleric'],
  subclasses: [],
  description: '',
  source: 'phb',
  page: '1',
  isSrd: true,
);

const _slotRow = SpellSlotProgressionEntry(
  tableId: 'full',
  level: 3,
  first: 4,
  second: 2,
  third: 0,
  fourth: 0,
  fifth: 0,
  sixth: 0,
  seventh: 0,
  eighth: 0,
  ninth: 0,
);

CharacterSheetPdfData _data({bool rich = true}) {
  var character = characterFixture(
    name: 'Aelar Cantovento',
    classLevels: const [
      ClassLevel(classId: 'cleric', subclassId: 'cleric_life_domain', level: 3),
    ],
    hitPoints: const HitPoints(current: 18, maximum: 24, temporary: 4),
    skillProficiencies: skillsWith({
      Skill.religion: ProficiencyLevel.proficient,
      Skill.medicine: ProficiencyLevel.expertise,
      Skill.arcana: ProficiencyLevel.half,
    }),
    exhaustion: 2,
    conditions: const {Condition.paralyzed},
    spells: const [
      CharacterSpell(
        spellId: 42,
        sourceType: 'subclass',
        sourceId: 'cleric_life_domain',
        sourceName: 'Domínio da Vida',
        isPrepared: true,
        isKnown: true,
        isAlwaysAvailable: true,
      ),
    ],
  );

  if (rich) {
    character = character.copyWith(
      playerName: 'Marcos',
      speciesId: 'high_elf',
      backgroundId: 'acolyte',
      notes: 'Procura o irmão desaparecido.',
      currency: const Currency(gold: 120, silver: 8, copper: 3),
      magicItems: const [
        CharacterMagicItem(
          localId: 1,
          name: 'Cajado da Chama',
          description: 'Solta uma labarada por carga.',
          spells: [],
          charges: 3,
          maxCharges: 5,
        ),
      ],
    );
  }

  return CharacterSheetPdfData(
    character: character,
    classes: const [_cleric],
    subclasses: const [_lifeDomain],
    races: const [
      RaceEntry(
        id: 'high_elf',
        name: 'Elfo Alto',
        source: 'phb',
        size: 'Médio',
        speed: 9,
        darkvision: 18,
        traits: ['Ancestralidade Feérica', 'Transe'],
        languages: ['Comum', 'Élfico'],
      ),
    ],
    backgrounds: const [
      BackgroundEntry(
        id: 'acolyte',
        name: 'Acólito',
        skillIds: ['insight', 'religion'],
        featureName: 'Abrigo dos Fiéis',
        featureDescription: 'Recebe cura e abrigo em templos.',
      ),
    ],
    classFeatures: const [
      ClassFeatureEntry(
        classId: 'cleric',
        level: 1,
        features: [
          ClassFeature(
            name: 'Conjuração',
            description: 'Conjura magias de clérigo usando Sabedoria.',
          ),
          // Sem descrição de propósito: cobre o caminho em que o PDF imprime
          // só o nome.
          ClassFeature(name: 'Divindade'),
        ],
        source: 'srd',
      ),
      ClassFeatureEntry(
        classId: 'cleric',
        level: 2,
        features: [
          ClassFeature(
            name: 'Canalizar Divindade',
            description: 'Canaliza energia divina uma vez por descanso.',
          ),
        ],
        source: 'srd',
      ),
    ],
    spells: const [_bless],
    spellSlots: const [_slotRow],
  );
}

void main() {
  group('CharacterSheetPdf.fileName', () {
    test('usa o nome do personagem', () {
      final character = characterFixture(name: 'Aelar');
      expect(CharacterSheetPdf.fileName(character), 'ficha-Aelar.pdf');
    });

    test('troca espaço por hífen', () {
      final character = characterFixture(name: 'Aelar Cantovento');
      expect(
        CharacterSheetPdf.fileName(character),
        'ficha-Aelar-Cantovento.pdf',
      );
    });

    test('descarta o que atrapalharia no sistema de arquivos', () {
      // Barra e dois-pontos viram caminho ou nome inválido no Windows.
      final character = characterFixture(
        name: 'Thorin / Filho de Thráin: o 2º',
      );
      final name = CharacterSheetPdf.fileName(character);

      expect(name.endsWith('.pdf'), isTrue);
      expect(name.contains('/'), isFalse);
      expect(name.contains(':'), isFalse);
    });

    test('nome só de símbolos cai num rótulo genérico', () {
      final character = characterFixture(name: '///');
      expect(CharacterSheetPdf.fileName(character), 'ficha-personagem.pdf');
    });

    test('mantém acento, que o sistema aceita', () {
      final character = characterFixture(name: 'Gimli Ançäo');
      expect(CharacterSheetPdf.fileName(character), contains('Ançäo'));
    });
  });

  group('CharacterSheetPdf.build', () {
    test('gera um PDF válido com a ficha cheia', () async {
      final bytes = await CharacterSheetPdf.build(_data());

      expect(bytes, isNotEmpty);
      // Assinatura do formato: se o cabeçalho não sai, nenhum leitor abre.
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      // Um PDF com todas as seções não cabe em poucos bytes; um documento
      // vazio por erro de montagem cairia bem abaixo disso.
      expect(bytes.length, greaterThan(3000));
    });

    test('gera PDF mesmo sem logo, retrato nem fonte', () async {
      // É o estado real do projeto antes da arte chegar: precisa exportar.
      final bytes = await CharacterSheetPdf.build(_data());
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('a marca d\'água não quebra a geração quando a logo existe', () async {
      final base = _data();
      final withLogo = CharacterSheetPdfData(
        character: base.character,
        classes: base.classes,
        subclasses: base.subclasses,
        races: base.races,
        backgrounds: base.backgrounds,
        classFeatures: base.classFeatures,
        spells: base.spells,
        spellSlots: base.spellSlots,
        logoBytes: _png(),
      );

      final bytes = await CharacterSheetPdf.build(withLogo);

      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      // A imagem entra no documento, então ele cresce em relação ao sem logo.
      final plain = await CharacterSheetPdf.build(base);
      expect(bytes.length, greaterThan(plain.length));
    });

    test('a moldura do retrato tem a proporção do painel de personagens', () {
      // Amarrado no widget de propósito: "igual ao painel" só continua verdade
      // se as duas proporções andarem juntas. Antes o PDF usava um quadrado, e
      // num retrato vertical o quadrado mostra o corpo inteiro em miniatura.
      const painel = PortraitBanner(path: null);

      expect(
        CharacterSheetPdf.portraitWidth / CharacterSheetPdf.portraitHeight,
        closeTo(painel.aspectRatio, 0.001),
      );
    });

    test(
      'a moldura do retrato tem o dobro da largura e da altura anteriores',
      () {
        expect(CharacterSheetPdf.portraitWidth, 168);
        expect(CharacterSheetPdf.portraitHeight, 126);
      },
    );

    test('o retrato entra sem derrubar a geração', () async {
      final base = _data();
      final withPortrait = CharacterSheetPdfData(
        character: base.character,
        classes: base.classes,
        spells: base.spells,
        portraitBytes: _png(),
      );

      final bytes = await CharacterSheetPdf.build(withPortrait);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('ficha mínima e sem compêndio ainda exporta', () async {
      // Compêndio vazio é o pior caso: nomes viram ids e tudo fica sem
      // correspondência. Ainda assim não pode lançar.
      final bytes = await CharacterSheetPdf.build(
        CharacterSheetPdfData(character: characterFixture()),
      );

      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('personagem sem magia, item, condição nem anotação exporta', () async {
      final bytes = await CharacterSheetPdf.build(
        CharacterSheetPdfData(
          character: characterFixture(name: 'Vazio'),
          classes: const [_cleric],
        ),
      );

      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}
