import 'dart:convert';

import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/death_saves.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_ability_increases.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/alignment.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/magic_item_bonus.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/spellcasting_type.dart';

/// Erro de leitura de uma ficha exportada, com mensagem pronta para a tela.
class CharacterImportException implements Exception {
  const CharacterImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Converte o personagem para JSON e de volta, para exportar e importar.
///
/// O formato é versionado: uma ficha gerada por uma versão futura do app é
/// recusada com mensagem clara em vez de ser lida pela metade.
class CharacterJsonCodec {
  const CharacterJsonCodec._();

  /// Versão do formato de arquivo (não confundir com o schema do banco).
  static const int formatVersion = 1;

  static const String _formatKey = 'format';
  static const String _versionKey = 'version';
  static const String _formatName = 'dnd_ficha_app/character';

  static String encode(Character character, {bool pretty = true}) {
    final payload = <String, dynamic>{
      _formatKey: _formatName,
      _versionKey: formatVersion,
      'character': toMap(character),
    };

    return pretty
        ? const JsonEncoder.withIndent('  ').convert(payload)
        : jsonEncode(payload);
  }

  /// Lê o JSON exportado.
  ///
  /// [newId] permite importar como um personagem novo, sem sobrescrever o
  /// original — é o comportamento usado pela tela de importação.
  static Character decode(String source, {String? newId}) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw CharacterImportException(
        'O texto não é um JSON válido: ${error.message}',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const CharacterImportException(
        'O JSON precisa ser um objeto com os dados da ficha.',
      );
    }

    final format = decoded[_formatKey];
    if (format != null && format != _formatName) {
      throw CharacterImportException(
        'Este arquivo não é uma ficha deste app (formato "$format").',
      );
    }

    final version = _asInt(decoded[_versionKey]) ?? formatVersion;
    if (version > formatVersion) {
      throw CharacterImportException(
        'A ficha foi exportada por uma versão mais nova do app '
        '(formato $version, este app lê até $formatVersion).',
      );
    }

    final raw = decoded['character'];
    if (raw is! Map<String, dynamic>) {
      throw const CharacterImportException(
        'O JSON não tem o objeto "character".',
      );
    }

    try {
      return fromMap(raw, newId: newId);
    } on CharacterImportException {
      rethrow;
    } catch (error) {
      throw CharacterImportException('Ficha inválida: $error');
    }
  }

  static Map<String, dynamic> toMap(Character character) {
    return <String, dynamic>{
      'id': character.id,
      'name': character.name,
      'playerName': character.playerName,
      'speciesId': character.speciesId,
      'backgroundId': character.backgroundId,
      'customBackground': <String, dynamic>{
        'name': character.customBackground.name,
        'skillIds': character.customBackground.skillIds,
        'features': character.customBackground.features,
      },
      'notes': character.notes,
      'abilityScores': <String, dynamic>{
        for (final ability in Ability.values)
          ability.name: character.abilityScores.valueFor(ability),
      },
      'classLevels': [
        for (final level in character.classLevels)
          <String, dynamic>{
            'classId': level.classId,
            'subclassId': level.subclassId,
            'level': level.level,
            'spellcastingAbility': level.spellcastingAbility?.name,
            'spellcastingType': level.spellcastingType?.name,
          },
      ],
      'hitPoints': <String, dynamic>{
        'current': character.hitPoints.current,
        'maximum': character.hitPoints.maximum,
        'temporary': character.hitPoints.temporary,
      },
      'combatStats': <String, dynamic>{
        'armorClass': character.combatStats.armorClass,
        'initiativeBonus': character.combatStats.initiativeBonus,
        'speedInMeters': character.combatStats.speedInMeters,
      },
      'savingThrows': <String, dynamic>{
        'strength': character.savingThrowProficiencies.strength,
        'dexterity': character.savingThrowProficiencies.dexterity,
        'constitution': character.savingThrowProficiencies.constitution,
        'intelligence': character.savingThrowProficiencies.intelligence,
        'wisdom': character.savingThrowProficiencies.wisdom,
        'charisma': character.savingThrowProficiencies.charisma,
      },
      // Só as perícias com algum nível, para o arquivo não encher de zeros.
      'skills': <String, dynamic>{
        for (final entry in character.skillProficiencies.activeLevels.entries)
          entry.key.id: entry.value.dbValue,
      },
      'spells': [
        for (final spell in character.spells)
          <String, dynamic>{
            'spellId': spell.spellId,
            'sourceType': spell.sourceType,
            'sourceId': spell.sourceId,
            'sourceName': spell.sourceName,
            'isPrepared': spell.isPrepared,
            'isKnown': spell.isKnown,
            'isAlwaysAvailable': spell.isAlwaysAvailable,
            'notes': spell.notes,
          },
      ],
      'weapons': [
        for (final weapon in character.weapons)
          <String, dynamic>{
            'weaponId': weapon.weaponId,
            'name': weapon.name,
            'magicBonus': weapon.magicBonus,
            'chosenAbility': weapon.chosenAbility?.name,
            'twoHanded': weapon.twoHanded,
            'proficiencyOverride': weapon.proficiencyOverride,
            'notes': weapon.notes,
          },
      ],
      'magicItems': [
        for (final item in character.magicItems)
          <String, dynamic>{
            'name': item.name,
            'description': item.description,
            'charges': item.charges,
            'maxCharges': item.maxCharges,
            'rechargeRule': item.rechargeRule,
            'castingAbility': item.castingAbility,
            'saveDc': item.saveDc,
            'attackBonus': item.attackBonus,
            // Formato controlado: o degrau e as estatísticas que ele afeta.
            'magicBonus': item.bonus.value,
            'bonusTargets': [
              for (final target in MagicItemBonusTarget.ordered)
                if (item.bonusTargets.contains(target)) target.id,
            ],
            'isEquipped': item.isEquipped,
            'requiresAttunement': item.requiresAttunement,
            'isAttuned': item.isAttuned,
            // Os quatro campos antigos continuam saindo, com o valor
            // DECLARADO: é o que uma build anterior sabe ler, e é o que
            // preserva o item marcado para revisão (bônus negativo, acima de
            // `+3` ou diferente entre estatísticas), que não tem como ser
            // representado nos campos acima.
            'weaponAttackBonus':
                item.declaredBonusFor(MagicItemBonusTarget.weaponAttack),
            'weaponDamageBonus':
                item.declaredBonusFor(MagicItemBonusTarget.weaponDamage),
            'spellAttackBonus':
                item.declaredBonusFor(MagicItemBonusTarget.spellAttack),
            'spellSaveDcBonus':
                item.declaredBonusFor(MagicItemBonusTarget.spellSaveDc),
            'spells': [
              for (final spell in item.spells)
                <String, dynamic>{
                  'spellId': spell.spellId,
                  'usesCharges': spell.usesCharges,
                  'chargeCost': spell.chargeCost,
                  'isAtWill': spell.isAtWill,
                  'isAlwaysAvailable': spell.isAlwaysAvailable,
                },
            ],
          },
      ],
      'feats': [
        for (final feat in character.feats)
          <String, dynamic>{
            'featId': feat.featId,
            'classId': feat.classId,
            'level': feat.level,
            // Arrays, não CSV: o CSV existe só porque a coluna do banco é
            // texto. Dentro do JSON a lista é o formato natural.
            'chosenSkills': feat.chosenSkillIds,
            'grantedSkills': feat.grantedSkillIds,
            'chosenAbility': feat.chosenAbility?.name,
            // Mapa, pelo mesmo motivo das perícias: o CSV é detalhe da coluna.
            'appliedAbilityIncreases': feat.appliedAbilityIncreases,
          },
      ],
      'inspiration': character.inspiration,
      'exhaustion': character.exhaustion,
      // Lista de ids, não CSV: dentro do JSON um array é o formato natural, e
      // o CSV é detalhe da coluna do banco.
      'conditions': Condition.values
          .where(character.conditions.contains)
          .map((item) => item.id)
          .toList(growable: false),
      'hitDiceUsed': character.hitDiceUsed,
      // Id do alinhamento, ou nulo para "não definido". Nulo é gravado de
      // propósito: escolher neutro na exportação inventaria uma decisão que o
      // jogador não tomou.
      'alignment': character.alignment?.id,
      'deathSaves': <String, dynamic>{
        'successes': character.deathSaves.successes,
        'failures': character.deathSaves.failures,
      },
      'currency': <String, dynamic>{
        'copper': character.currency.copper,
        'silver': character.currency.silver,
        'electrum': character.currency.electrum,
        'gold': character.currency.gold,
        'platinum': character.currency.platinum,
      },
      'createdAt': character.createdAt.toIso8601String(),
      'updatedAt': character.updatedAt.toIso8601String(),
    };
  }

  static Character fromMap(Map<String, dynamic> map, {String? newId}) {
    final name = _asString(map['name'])?.trim();
    if (name == null || name.isEmpty) {
      throw const CharacterImportException('A ficha não tem nome.');
    }

    final id = newId ?? _asString(map['id']);
    if (id == null || id.isEmpty) {
      throw const CharacterImportException('A ficha não tem id.');
    }

    final classLevels = _parseClassLevels(map['classLevels']);
    if (classLevels.isEmpty) {
      throw const CharacterImportException(
        'A ficha precisa de pelo menos uma classe.',
      );
    }

    final maximum = _asInt(_asMap(map['hitPoints'])['maximum']) ?? 1;
    final safeMaximum = maximum < 1 ? 1 : maximum;
    final current = _asInt(_asMap(map['hitPoints'])['current']) ?? safeMaximum;

    final customBackground = _asMap(map['customBackground']);
    final now = DateTime.now();

    return Character(
      id: id,
      name: name,
      playerName: _asString(map['playerName']),
      speciesId: _asString(map['speciesId']),
      backgroundId: _asString(map['backgroundId']),
      customBackground: CustomBackground(
        name: _asString(customBackground['name']),
        skillIds: _asStringList(customBackground['skillIds']),
        features: _asString(customBackground['features']) ?? '',
      ),
      notes: _asString(map['notes']) ?? '',
      abilityScores: _parseAbilityScores(map['abilityScores']),
      classLevels: classLevels,
      hitPoints: HitPoints(
        current: current.clamp(0, safeMaximum),
        maximum: safeMaximum,
        temporary: (_asInt(_asMap(map['hitPoints'])['temporary']) ?? 0)
            .clamp(0, 9999),
      ),
      combatStats: _parseCombatStats(map['combatStats']),
      savingThrowProficiencies: _parseSavingThrows(map['savingThrows']),
      skillProficiencies: _parseSkills(map['skills']),
      spells: _parseSpells(map['spells']),
      weapons: _parseWeapons(map['weapons']),
      magicItems: _parseMagicItems(map['magicItems']),
      feats: _parseFeats(map['feats']),
      inspiration: _asBool(map['inspiration']),
      exhaustion: (_asInt(map['exhaustion']) ?? 0).clamp(0, 6),
      conditions: _parseConditions(map['conditions']),
      hitDiceUsed: (_asInt(map['hitDiceUsed']) ?? 0).clamp(0, 20),
      // Campo ausente (arquivo anterior a este campo) ou id desconhecido caem
      // em nulo, que é "não definido" — nunca em neutro.
      alignment: CharacterAlignment.fromId(_asString(map['alignment'])),
      deathSaves: _parseDeathSaves(map['deathSaves']),
      currency: _parseCurrency(map['currency']),
      // Importar cria uma ficha nova: a data de criação é a de agora, mas a
      // original fica preservada se estiver no arquivo.
      createdAt: newId == null
          ? (_parseDate(map['createdAt']) ?? now)
          : now,
      updatedAt: now,
    );
  }

  static AbilityScores _parseAbilityScores(Object? raw) {
    final map = _asMap(raw);

    int score(Ability ability) {
      final value = _asInt(map[ability.name]) ?? 10;
      return value.clamp(1, 30);
    }

    return AbilityScores(
      strength: score(Ability.strength),
      dexterity: score(Ability.dexterity),
      constitution: score(Ability.constitution),
      intelligence: score(Ability.intelligence),
      wisdom: score(Ability.wisdom),
      charisma: score(Ability.charisma),
    );
  }

  static List<ClassLevel> _parseClassLevels(Object? raw) {
    final result = <ClassLevel>[];

    for (final item in _asList(raw)) {
      final map = _asMap(item);
      final classId = _asString(map['classId']);
      if (classId == null || classId.isEmpty) continue;

      final level = (_asInt(map['level']) ?? 1).clamp(1, 20);

      result.add(
        ClassLevel(
          classId: classId,
          subclassId: _asString(map['subclassId']),
          level: level,
          spellcastingAbility: Ability.fromName(
            _asString(map['spellcastingAbility']),
          ),
          spellcastingType: _spellcastingTypeFromName(
            _asString(map['spellcastingType']),
          ),
        ),
      );
    }

    return result;
  }

  static CombatStats _parseCombatStats(Object? raw) {
    final map = _asMap(raw);

    // `speedInSquares` é a chave antiga, de quando o deslocamento era inteiro.
    // Continua sendo lida para não invalidar arquivos já exportados.
    final speed =
        _asDouble(map['speedInMeters']) ??
        _asDouble(map['speedInSquares']) ??
        9.0;

    return CombatStats(
      armorClass: (_asInt(map['armorClass']) ?? 10).clamp(0, 99),
      initiativeBonus: _asInt(map['initiativeBonus']) ?? 0,
      speedInMeters: speed.clamp(0, 999).toDouble(),
    );
  }

  static SavingThrowProficiencies _parseSavingThrows(Object? raw) {
    final map = _asMap(raw);

    return SavingThrowProficiencies(
      strength: _asBool(map['strength']),
      dexterity: _asBool(map['dexterity']),
      constitution: _asBool(map['constitution']),
      intelligence: _asBool(map['intelligence']),
      wisdom: _asBool(map['wisdom']),
      charisma: _asBool(map['charisma']),
    );
  }

  static SkillProficiencies _parseSkills(Object? raw) {
    final map = _asMap(raw);
    final levels = <Skill, ProficiencyLevel>{};

    for (final entry in map.entries) {
      final skill = Skill.fromId(entry.key);
      if (skill == null) continue;

      final level = ProficiencyLevel.fromDb(_asInt(entry.value));
      if (level != ProficiencyLevel.none) levels[skill] = level;
    }

    return SkillProficiencies(levels: levels);
  }

  /// Ids desconhecidos são descartados, como em [_parseSkills]: arquivo de uma
  /// versão futura, ou editado à mão, não pode derrubar a importação.
  static Set<Condition> _parseConditions(Object? raw) {
    final result = <Condition>{};

    for (final id in _asStringList(raw)) {
      final condition = Condition.fromId(id);
      if (condition != null) result.add(condition);
    }

    return result;
  }

  static List<CharacterSpell> _parseSpells(Object? raw) {
    final result = <CharacterSpell>[];

    for (final item in _asList(raw)) {
      final map = _asMap(item);
      final spellId = _asInt(map['spellId']);
      if (spellId == null) continue;

      result.add(
        CharacterSpell(
          spellId: spellId,
          sourceType: _asString(map['sourceType']) ?? 'custom',
          sourceId: _asString(map['sourceId']) ?? '',
          sourceName: _asString(map['sourceName']) ?? '',
          isPrepared: _asBool(map['isPrepared']),
          isKnown: _asBool(map['isKnown'], fallback: true),
          isAlwaysAvailable: _asBool(map['isAlwaysAvailable']),
          notes: _asString(map['notes']) ?? '',
        ),
      );
    }

    return result;
  }

  static List<CharacterFeat> _parseFeats(Object? raw) {
    final result = <CharacterFeat>[];

    for (final item in _asList(raw)) {
      final map = _asMap(item);
      final featId = _asString(map['featId'])?.trim();

      // Talento sem id não tem como ser resolvido no compêndio depois.
      if (featId == null || featId.isEmpty) continue;

      result.add(
        CharacterFeat(
          featId: featId,
          classId: _asString(map['classId']),
          level: _asInt(map['level']),
          chosenSkillIds: _parseSkillIdList(map['chosenSkills']),
          grantedSkillIds: _parseSkillIdList(map['grantedSkills']),
          chosenAbility: Ability.fromName(_asString(map['chosenAbility'])),
          appliedAbilityIncreases: _parseAbilityIncreases(
            map['appliedAbilityIncreases'],
          ),
        ),
      );
    }

    return result;
  }

  /// Aceita array e também o CSV que uma ficha exportada à mão poderia trazer.
  static List<String> _parseSkillIdList(Object? raw) {
    if (raw is String) return CharacterFeat.parseSkillIdsCsv(raw);

    return [
      for (final item in _asList(raw))
        if (_asString(item)?.trim() case final id? when id.isNotEmpty) id,
    ];
  }

  /// Aceita o mapa que o export escreve e também o CSV `atributo:valor` do
  /// banco, que uma ficha montada à mão poderia trazer.
  static Map<String, int> _parseAbilityIncreases(Object? raw) {
    if (raw is String) return GrantedAbilityIncreases.parseCsv(raw);
    if (raw is! Map) return const {};

    final result = <String, int>{};

    for (final entry in raw.entries) {
      final ability = Ability.fromName(_asString(entry.key));
      final amount = _asInt(entry.value);
      if (ability == null || amount == null || amount <= 0) continue;

      result[ability.name] = amount;
    }

    return result;
  }

  static List<CharacterWeapon> _parseWeapons(Object? raw) {
    final result = <CharacterWeapon>[];

    for (final item in _asList(raw)) {
      final map = _asMap(item);
      final weaponId = _asString(map['weaponId']);

      // Sem id não há como resolver a arma no compêndio, então a linha não
      // serve para nada e é descartada.
      if (weaponId == null || weaponId.isEmpty) continue;

      result.add(
        CharacterWeapon(
          localId: null,
          weaponId: weaponId,
          name: _asString(map['name']),
          magicBonus: _asInt(map['magicBonus']) ?? 0,
          chosenAbility: Ability.fromName(_asString(map['chosenAbility'])),
          twoHanded: _asBool(map['twoHanded']),
          proficiencyOverride: map['proficiencyOverride'] is bool
              ? map['proficiencyOverride'] as bool
              : null,
          notes: _asString(map['notes']) ?? '',
        ),
      );
    }

    return result;
  }

  static List<CharacterMagicItem> _parseMagicItems(Object? raw) {
    final result = <CharacterMagicItem>[];

    for (final item in _asList(raw)) {
      final map = _asMap(item);
      final name = _asString(map['name'])?.trim();
      if (name == null || name.isEmpty) continue;

      final spells = <CharacterMagicItemSpell>[];
      for (final spellRaw in _asList(map['spells'])) {
        final spellMap = _asMap(spellRaw);
        final spellId = _asInt(spellMap['spellId']);
        if (spellId == null) continue;

        spells.add(
          CharacterMagicItemSpell(
            spellId: spellId,
            usesCharges: _asBool(spellMap['usesCharges']),
            chargeCost: _asInt(spellMap['chargeCost']) ?? 1,
            isAtWill: _asBool(spellMap['isAtWill']),
            isAlwaysAvailable:
                _asBool(spellMap['isAlwaysAvailable'], fallback: true),
          ),
        );
      }

      // Estado de uso. Sem os campos (arquivo anterior à mudança) o item entra
      // equipado e sem exigir sintonia, que é como ele se comportava antes:
      // importar não pode desligar um bônus que o jogador já usava.
      final isEquipped = _asBool(map['isEquipped'], fallback: true);
      final requiresAttunement = _asBool(map['requiresAttunement']);
      final isAttuned = _asBool(map['isAttuned']);

      final targetsRaw = map['bonusTargets'];
      final hasControlledBonus =
          map.containsKey('magicBonus') || targetsRaw != null;

      if (hasControlledBonus) {
        final targets = <MagicItemBonusTarget>{};
        for (final entry in _asList(targetsRaw)) {
          final target = MagicItemBonusTarget.fromId(_asString(entry)?.trim());
          if (target != null) targets.add(target);
        }

        // Degrau fora de 0..3 num arquivo editado à mão não vira um `+7`: cai
        // para o caminho de conversão abaixo, que preserva o número original
        // e marca o item para revisão.
        final declared = _asInt(map['magicBonus']);
        final bonus = MagicItemBonus.tryFromValue(declared);

        if (bonus != null) {
          result.add(
            CharacterMagicItem(
              // O localId é do banco: quem grava é o repositório.
              localId: 0,
              name: name,
              description: _asString(map['description']) ?? '',
              charges: _asInt(map['charges']),
              maxCharges: _asInt(map['maxCharges']),
              rechargeRule: _asString(map['rechargeRule']),
              castingAbility: _asString(map['castingAbility']),
              saveDc: _asInt(map['saveDc']),
              attackBonus: _asInt(map['attackBonus']),
              bonus: bonus,
              bonusTargets: targets,
              isEquipped: isEquipped,
              requiresAttunement: requiresAttunement,
              isAttuned: isAttuned,
              spells: spells,
            ),
          );
          continue;
        }
      }

      // Arquivo exportado antes do bônus controlado, ou com degrau inválido.
      // A conversão aproveita só o que é representável e guarda o resto para
      // revisão. Campo ausente vale zero: o app não deduz um `+1` do nome do
      // item, porque não sabe se ele valia para arma, para magia ou para os
      // dois.
      result.add(
        CharacterMagicItem.fromLegacyBonuses(
          localId: 0,
          name: name,
          description: _asString(map['description']) ?? '',
          charges: _asInt(map['charges']),
          maxCharges: _asInt(map['maxCharges']),
          rechargeRule: _asString(map['rechargeRule']),
          castingAbility: _asString(map['castingAbility']),
          saveDc: _asInt(map['saveDc']),
          attackBonus: _asInt(map['attackBonus']),
          weaponAttackBonus: _asInt(map['weaponAttackBonus']) ?? 0,
          weaponDamageBonus: _asInt(map['weaponDamageBonus']) ?? 0,
          spellAttackBonus: _asInt(map['spellAttackBonus']) ?? 0,
          spellSaveDcBonus: _asInt(map['spellSaveDcBonus']) ?? 0,
          isEquipped: isEquipped,
          requiresAttunement: requiresAttunement,
          isAttuned: isAttuned,
          spells: spells,
        ),
      );
    }

    return result;
  }

  /// Marcadores dos testes contra a morte, presos entre 0 e 3.
  ///
  /// Arquivo sem o campo devolve zerado: um personagem importado não está no
  /// meio de uma sequência de testes.
  static DeathSaves _parseDeathSaves(Object? raw) {
    final map = _asMap(raw);

    return DeathSaves(
      successes:
          (_asInt(map['successes']) ?? 0).clamp(0, DeathSaves.maxMarks),
      failures: (_asInt(map['failures']) ?? 0).clamp(0, DeathSaves.maxMarks),
    );
  }

  static Currency _parseCurrency(Object? raw) {
    final map = _asMap(raw);

    int coin(String key) => (_asInt(map[key]) ?? 0).clamp(0, 999999999);

    return Currency(
      copper: coin('copper'),
      silver: coin('silver'),
      electrum: coin('electrum'),
      gold: coin('gold'),
      platinum: coin('platinum'),
    );
  }

  static SpellcastingType? _spellcastingTypeFromName(String? value) {
    if (value == null) return null;
    for (final type in SpellcastingType.values) {
      if (type.name == value) return type;
    }
    return null;
  }

  static DateTime? _parseDate(Object? raw) {
    final value = _asString(raw);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static List<dynamic> _asList(Object? value) {
    if (value is List) return value;
    return const [];
  }

  static List<String> _asStringList(Object? value) {
    return _asList(value)
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String? _asString(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.'));
    return null;
  }

  static bool _asBool(Object? value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return fallback;
  }
}
