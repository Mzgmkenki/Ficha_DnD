import 'package:dnd_ficha_app/core/database/app_database.dart' as db;
import 'package:dnd_ficha_app/features/character/data/mappers/background_personality_codec.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_creation_metadata_codec.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_mapper.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/currency_grant_mapper.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/inventory_mapper.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/magic_item_mapper.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/weapon_mapper.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart'
    as domain;
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart'
    as domain_items;
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart'
    as domain_item_spells;
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart'
    as domain_spells;
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart'
    as domain_weapons;
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart'
    as domain_condition;
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart'
    as domain_skill;
import 'package:drift/drift.dart' as drift;

/// Converte o nível de proficiência de uma perícia no inteiro persistido.
int _lvl(domain.Character character, domain_skill.Skill skill) {
  return character.skillProficiencies.levelFor(skill).dbValue;
}

class CharacterRepositoryImpl implements CharacterRepository {
  CharacterRepositoryImpl(this._database);

  final db.AppDatabase _database;

  @override
  Future<void> create(domain.Character character) async {
    await _database.transaction(() async {
      await _database.into(_database.characters).insert(
            db.CharactersCompanion.insert(
              id: character.id,
              name: character.name,
              playerName: drift.Value(character.playerName),
              portraitPath: drift.Value(character.portraitPath),
              speciesId: drift.Value(character.speciesId),
              backgroundId: drift.Value(character.backgroundId),
              customBackgroundName:
                  drift.Value(character.customBackground.name),
              customBackgroundSkills:
                  drift.Value(character.customBackground.skillIdsAsCsv),
              customBackgroundFeatures:
                  drift.Value(character.customBackground.features),
              notes: drift.Value(character.notes),
              strength: drift.Value(character.abilityScores.strength),
              dexterity: drift.Value(character.abilityScores.dexterity),
              constitution: drift.Value(character.abilityScores.constitution),
              intelligence: drift.Value(character.abilityScores.intelligence),
              wisdom: drift.Value(character.abilityScores.wisdom),
              charisma: drift.Value(character.abilityScores.charisma),
              baseAbilityScores: drift.Value(
                CharacterCreationMetadataCodec.encodeBaseScores(
                  character.abilityScoreAllocation,
                ),
              ),
              originAbilityBonuses: drift.Value(
                CharacterCreationMetadataCodec.encodeOriginBonuses(
                  character.abilityScoreAllocation,
                ),
              ),
              skillProficiencyGrants: drift.Value(
                CharacterCreationMetadataCodec.encodeSkillGrants(
                  character.skillProficiencyGrants,
                ),
              ),
              backgroundPersonalityChoices: drift.Value(
                BackgroundPersonalityCodec.encode(
                  character.backgroundPersonalityChoices,
                ),
              ),
              armorClass: drift.Value(character.combatStats.armorClass),
              initiativeBonus:
                  drift.Value(character.combatStats.initiativeBonus),
              speed: drift.Value(character.combatStats.speedInMeters.round()),
              speedMeters: drift.Value(character.combatStats.speedInMeters),
              maxHitPoints: drift.Value(character.hitPoints.maximum),
              currentHitPoints: drift.Value(character.hitPoints.current),
              temporaryHitPoints: drift.Value(character.hitPoints.temporary),
              saveStrength:
                  drift.Value(character.savingThrowProficiencies.strength),
              saveDexterity:
                  drift.Value(character.savingThrowProficiencies.dexterity),
              saveConstitution:
                  drift.Value(character.savingThrowProficiencies.constitution),
              saveIntelligence:
                  drift.Value(character.savingThrowProficiencies.intelligence),
              saveWisdom:
                  drift.Value(character.savingThrowProficiencies.wisdom),
              saveCharisma:
                  drift.Value(character.savingThrowProficiencies.charisma),
              skillAcrobatics:
                  drift.Value(character.skillProficiencies.acrobatics),
              skillAnimalHandling:
                  drift.Value(character.skillProficiencies.animalHandling),
              skillArcana: drift.Value(character.skillProficiencies.arcana),
              skillAthletics:
                  drift.Value(character.skillProficiencies.athletics),
              skillDeception:
                  drift.Value(character.skillProficiencies.deception),
              skillHistory: drift.Value(character.skillProficiencies.history),
              skillInsight: drift.Value(character.skillProficiencies.insight),
              skillIntimidation:
                  drift.Value(character.skillProficiencies.intimidation),
              skillInvestigation:
                  drift.Value(character.skillProficiencies.investigation),
              skillMedicine: drift.Value(character.skillProficiencies.medicine),
              skillNature: drift.Value(character.skillProficiencies.nature),
              skillPerception:
                  drift.Value(character.skillProficiencies.perception),
              skillPerformance:
                  drift.Value(character.skillProficiencies.performance),
              skillPersuasion:
                  drift.Value(character.skillProficiencies.persuasion),
              skillReligion: drift.Value(character.skillProficiencies.religion),
              skillSleightOfHand:
                  drift.Value(character.skillProficiencies.sleightOfHand),
              skillStealth: drift.Value(character.skillProficiencies.stealth),
              skillSurvival: drift.Value(character.skillProficiencies.survival),
              lvlAcrobatics: drift.Value(_lvl(character, domain_skill.Skill.acrobatics)),
              lvlAnimalHandling:
                  drift.Value(_lvl(character, domain_skill.Skill.animalHandling)),
              lvlArcana: drift.Value(_lvl(character, domain_skill.Skill.arcana)),
              lvlAthletics: drift.Value(_lvl(character, domain_skill.Skill.athletics)),
              lvlDeception: drift.Value(_lvl(character, domain_skill.Skill.deception)),
              lvlHistory: drift.Value(_lvl(character, domain_skill.Skill.history)),
              lvlInsight: drift.Value(_lvl(character, domain_skill.Skill.insight)),
              lvlIntimidation:
                  drift.Value(_lvl(character, domain_skill.Skill.intimidation)),
              lvlInvestigation:
                  drift.Value(_lvl(character, domain_skill.Skill.investigation)),
              lvlMedicine: drift.Value(_lvl(character, domain_skill.Skill.medicine)),
              lvlNature: drift.Value(_lvl(character, domain_skill.Skill.nature)),
              lvlPerception: drift.Value(_lvl(character, domain_skill.Skill.perception)),
              lvlPerformance:
                  drift.Value(_lvl(character, domain_skill.Skill.performance)),
              lvlPersuasion: drift.Value(_lvl(character, domain_skill.Skill.persuasion)),
              lvlReligion: drift.Value(_lvl(character, domain_skill.Skill.religion)),
              lvlSleightOfHand:
                  drift.Value(_lvl(character, domain_skill.Skill.sleightOfHand)),
              lvlStealth: drift.Value(_lvl(character, domain_skill.Skill.stealth)),
              lvlSurvival: drift.Value(_lvl(character, domain_skill.Skill.survival)),
              inspiration: drift.Value(character.inspiration),
              exhaustion: drift.Value(character.exhaustion),
              conditions:
                  drift.Value(domain_condition.Condition.toCsv(character.conditions)),
              deathSaveSuccesses:
                  drift.Value(character.deathSaves.successes),
              deathSaveFailures: drift.Value(character.deathSaves.failures),
              alignment: drift.Value(character.alignment?.id),
              hitDiceUsed: drift.Value(character.hitDiceUsed),
              copperPieces: drift.Value(character.currency.copper),
              silverPieces: drift.Value(character.currency.silver),
              electrumPieces: drift.Value(character.currency.electrum),
              goldPieces: drift.Value(character.currency.gold),
              platinumPieces: drift.Value(character.currency.platinum),
              createdAt: character.createdAt,
              updatedAt: character.updatedAt,
            ),
          );

      for (final classLevel in character.classLevels) {
        await _database.into(_database.characterClassLevels).insert(
              db.CharacterClassLevelsCompanion.insert(
                characterId: character.id,
                classId: classLevel.classId,
                subclassId: drift.Value(classLevel.subclassId),
                level: classLevel.level,
                spellcastingAbility:
                    drift.Value(classLevel.spellcastingAbility?.name),
                spellcastingType:
                    drift.Value(classLevel.spellcastingType?.name),
              ),
            );
      }

      for (final spell in character.spells) {
        await _database.into(_database.characterSpells).insert(
              db.CharacterSpellsCompanion.insert(
                characterId: character.id,
                spellId: spell.spellId,
                sourceType: spell.sourceType,
                sourceId: spell.sourceId,
                sourceName: spell.sourceName,
                isPrepared: drift.Value(spell.isPrepared),
                isKnown: drift.Value(spell.isKnown),
                isAlwaysAvailable: drift.Value(spell.isAlwaysAvailable),
                notes: drift.Value(spell.notes),
              ),
            );
      }

      for (final feat in character.feats) {
        await _database.into(_database.characterFeats).insert(
              db.CharacterFeatsCompanion.insert(
                characterId: character.id,
                featId: feat.featId,
                classId: drift.Value(feat.classId),
                level: drift.Value(feat.level),
                chosenSkills: drift.Value(feat.chosenSkillsAsCsv),
                grantedSkills: drift.Value(feat.grantedSkillsAsCsv),
                chosenAbility: drift.Value(feat.chosenAbility?.name),
                appliedAbilityIncreases: drift.Value(
                  feat.appliedAbilityIncreasesAsCsv,
                ),
              ),
            );
      }

      for (final weapon in character.weapons) {
        await _database.into(_database.characterWeapons).insert(
              WeaponMapper.toInsert(
                characterId: character.id,
                weapon: weapon,
              ),
            );
      }

      // Antes os itens mágicos eram descartados silenciosamente aqui.
      for (final item in character.magicItems) {
        final insertedId =
            await _database.into(_database.characterMagicItems).insert(
                  MagicItemMapper.toInsert(
                    characterId: character.id,
                    item: item,
                  ),
                );

        for (final itemSpell in item.spells) {
          await _database.into(_database.characterMagicItemSpells).insert(
                db.CharacterMagicItemSpellsCompanion.insert(
                  magicItemId: insertedId,
                  spellId: itemSpell.spellId,
                  usesCharges: drift.Value(itemSpell.usesCharges),
                  chargeCost: drift.Value(itemSpell.chargeCost),
                  isAtWill: drift.Value(itemSpell.isAtWill),
                  isAlwaysAvailable: drift.Value(itemSpell.isAlwaysAvailable),
                ),
              );
        }
      }

      for (final item in character.inventory) {
        await _database.into(_database.characterInventoryItems).insert(
              InventoryMapper.toInsert(
                characterId: character.id,
                item: item,
              ),
            );
      }

      for (final grant in character.currencyGrants) {
        await _database.into(_database.characterCurrencyGrants).insert(
              CurrencyGrantMapper.toInsert(
                characterId: character.id,
                grant: grant,
              ),
            );
      }
    });
  }

  @override
  Future<void> delete(String id) async {
    // Sem esta limpeza explícita as tabelas filhas ficam com registros órfãos
    // (não há ON DELETE CASCADE nem enforcement de foreign keys ativo).
    await _database.transaction(() async {
      final itemIds = await (_database.select(_database.characterMagicItems)
            ..where((tbl) => tbl.characterId.equals(id)))
          .map((row) => row.localId)
          .get();

      if (itemIds.isNotEmpty) {
        await (_database.delete(_database.characterMagicItemSpells)
              ..where((tbl) => tbl.magicItemId.isIn(itemIds)))
            .go();
      }

      await (_database.delete(_database.characterMagicItems)
            ..where((tbl) => tbl.characterId.equals(id)))
          .go();

      await (_database.delete(_database.characterSpells)
            ..where((tbl) => tbl.characterId.equals(id)))
          .go();

      await (_database.delete(_database.characterWeapons)
            ..where((tbl) => tbl.characterId.equals(id)))
          .go();

      await (_database.delete(_database.characterSpellSlotsUsage)
            ..where((tbl) => tbl.characterId.equals(id)))
          .go();

      await (_database.delete(_database.characterFeats)
            ..where((tbl) => tbl.characterId.equals(id)))
          .go();

      await (_database.delete(_database.characterInventoryItems)
            ..where((tbl) => tbl.characterId.equals(id)))
          .go();

      await (_database.delete(_database.characterCurrencyGrants)
            ..where((tbl) => tbl.characterId.equals(id)))
          .go();

      await (_database.delete(_database.characterClassLevels)
            ..where((tbl) => tbl.characterId.equals(id)))
          .go();

      await (_database.delete(_database.characters)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
    });
  }

  @override
  Future<domain.Character?> findById(String id) async {
    final characterRow = await (_database.select(_database.characters)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    if (characterRow == null) return null;

    final classLevelRows =
        await (_database.select(_database.characterClassLevels)
              ..where((tbl) => tbl.characterId.equals(id)))
            .get();

    final spellRows = await (_database.select(_database.characterSpells)
          ..where((tbl) => tbl.characterId.equals(id)))
        .get();

    final weaponRows = await (_database.select(_database.characterWeapons)
          ..where((tbl) => tbl.characterId.equals(id)))
        .get();

    final itemRows = await (_database.select(_database.characterMagicItems)
          ..where((tbl) => tbl.characterId.equals(id)))
        .get();

    final featRows = await (_database.select(_database.characterFeats)
          ..where((tbl) => tbl.characterId.equals(id)))
        .get();

    final inventoryRows =
        await (_database.select(_database.characterInventoryItems)
              ..where((tbl) => tbl.characterId.equals(id)))
            .get();

    final currencyGrantRows =
        await (_database.select(_database.characterCurrencyGrants)
              ..where((tbl) => tbl.characterId.equals(id)))
            .get();

    final magicItems = <domain_items.CharacterMagicItem>[];
    for (final itemRow in itemRows) {
      final itemSpellRows =
          await (_database.select(_database.characterMagicItemSpells)
                ..where((tbl) => tbl.magicItemId.equals(itemRow.localId)))
              .get();

      magicItems.add(
        MagicItemMapper.fromDatabase(
          row: itemRow,
          spells: itemSpellRows
              .map(
                (row) => domain_item_spells.CharacterMagicItemSpell(
                  spellId: row.spellId,
                  usesCharges: row.usesCharges,
                  chargeCost: row.chargeCost,
                  isAtWill: row.isAtWill,
                  isAlwaysAvailable: row.isAlwaysAvailable,
                ),
              )
              .toList(growable: false),
        ),
      );
    }

    final mapped = CharacterMapper.fromDatabase(
      character: characterRow,
      classLevels: classLevelRows,
      feats: featRows,
    );

    return mapped.copyWith(
      spells: spellRows
          .map(
            (row) => domain_spells.CharacterSpell(
              spellId: row.spellId,
              sourceType: row.sourceType,
              sourceId: row.sourceId,
              sourceName: row.sourceName,
              isPrepared: row.isPrepared,
              isKnown: row.isKnown,
              isAlwaysAvailable: row.isAlwaysAvailable,
              notes: row.notes,
            ),
          )
          .toList(growable: false),
      weapons: weaponRows.map(_weaponFromRow).toList(growable: false),
      magicItems: magicItems,
      inventory: inventoryRows
          .map(InventoryMapper.fromDatabase)
          .toList(growable: false),
      currencyGrants: currencyGrantRows
          .map(CurrencyGrantMapper.fromDatabase)
          .toList(growable: false),
    );
  }

  /// Converte a linha da tabela na arma de domínio.
  domain_weapons.CharacterWeapon _weaponFromRow(db.CharacterWeapon row) =>
      WeaponMapper.fromDatabase(row);

  @override
  Future<void> resetUsedSpellSlots({
    required String characterId,
    List<int>? slotLevels,
  }) async {
    if (slotLevels != null && slotLevels.isEmpty) return;

    // Condição montada de uma só vez: chamar `where` duas vezes poderia
    // sobrescrever o filtro anterior em vez de combiná-lo.
    await (_database.delete(_database.characterSpellSlotsUsage)
          ..where((tbl) {
            final sameCharacter = tbl.characterId.equals(characterId);
            if (slotLevels == null) return sameCharacter;
            return sameCharacter & tbl.slotLevel.isIn(slotLevels);
          }))
        .go();
  }

  /// Reemite a cada mudança nas tabelas que compõem o agregado. O `findById`
  /// remonta o personagem inteiro (níveis, magias, itens e magias de item),
  /// então basta reexecutá-lo quando uma delas muda.
  ///
  /// O filtro por tabela importa: sem ele, escrever em qualquer tabela do
  /// banco — inclusive as de uso de espaços de magia, que mudam a cada
  /// clique — disparava a remontagem completa do agregado.
  @override
  Stream<domain.Character?> watchById(String id) async* {
    yield await findById(id);

    await for (final _ in _database.tableUpdates(_aggregateTables)) {
      yield await findById(id);
    }
  }

  /// Tabelas lidas por [findById].
  drift.TableUpdateQuery get _aggregateTables {
    return drift.TableUpdateQuery.onAllTables([
      _database.characters,
      _database.characterClassLevels,
      _database.characterSpells,
      _database.characterWeapons,
      _database.characterMagicItems,
      _database.characterMagicItemSpells,
      _database.characterFeats,
      _database.characterInventoryItems,
      _database.characterCurrencyGrants,
    ]);
  }

  @override
  Stream<Map<int, int>> watchUsedSpellSlots(String characterId) async* {
    yield await getUsedSpellSlots(characterId);

    await for (final _ in _database.tableUpdates(
      drift.TableUpdateQuery.onTable(_database.characterSpellSlotsUsage),
    )) {
      yield await getUsedSpellSlots(characterId);
    }
  }

  @override
  Future<void> update(domain.Character character) async {
    await _database.transaction(() async {
      await (_database.update(_database.characters)
            ..where((tbl) => tbl.id.equals(character.id)))
          .write(
        db.CharactersCompanion(
          name: drift.Value(character.name),
          playerName: drift.Value(character.playerName),
          portraitPath: drift.Value(character.portraitPath),
          speciesId: drift.Value(character.speciesId),
          backgroundId: drift.Value(character.backgroundId),
          customBackgroundName: drift.Value(character.customBackground.name),
          customBackgroundSkills:
              drift.Value(character.customBackground.skillIdsAsCsv),
          customBackgroundFeatures:
              drift.Value(character.customBackground.features),
          notes: drift.Value(character.notes),
          strength: drift.Value(character.abilityScores.strength),
          dexterity: drift.Value(character.abilityScores.dexterity),
          constitution: drift.Value(character.abilityScores.constitution),
          intelligence: drift.Value(character.abilityScores.intelligence),
          wisdom: drift.Value(character.abilityScores.wisdom),
          charisma: drift.Value(character.abilityScores.charisma),
          baseAbilityScores: drift.Value(
            CharacterCreationMetadataCodec.encodeBaseScores(
              character.abilityScoreAllocation,
            ),
          ),
          originAbilityBonuses: drift.Value(
            CharacterCreationMetadataCodec.encodeOriginBonuses(
              character.abilityScoreAllocation,
            ),
          ),
          skillProficiencyGrants: drift.Value(
            CharacterCreationMetadataCodec.encodeSkillGrants(
              character.skillProficiencyGrants,
            ),
          ),
          backgroundPersonalityChoices: drift.Value(
            BackgroundPersonalityCodec.encode(
              character.backgroundPersonalityChoices,
            ),
          ),
          armorClass: drift.Value(character.combatStats.armorClass),
          initiativeBonus:
              drift.Value(character.combatStats.initiativeBonus),
          speed: drift.Value(character.combatStats.speedInMeters.round()),
          speedMeters: drift.Value(character.combatStats.speedInMeters),
          maxHitPoints: drift.Value(character.hitPoints.maximum),
          currentHitPoints: drift.Value(character.hitPoints.current),
          temporaryHitPoints: drift.Value(character.hitPoints.temporary),
          saveStrength:
              drift.Value(character.savingThrowProficiencies.strength),
          saveDexterity:
              drift.Value(character.savingThrowProficiencies.dexterity),
          saveConstitution:
              drift.Value(character.savingThrowProficiencies.constitution),
          saveIntelligence:
              drift.Value(character.savingThrowProficiencies.intelligence),
          saveWisdom:
              drift.Value(character.savingThrowProficiencies.wisdom),
          saveCharisma:
              drift.Value(character.savingThrowProficiencies.charisma),
          skillAcrobatics:
              drift.Value(character.skillProficiencies.acrobatics),
          skillAnimalHandling:
              drift.Value(character.skillProficiencies.animalHandling),
          skillArcana: drift.Value(character.skillProficiencies.arcana),
          skillAthletics:
              drift.Value(character.skillProficiencies.athletics),
          skillDeception:
              drift.Value(character.skillProficiencies.deception),
          skillHistory: drift.Value(character.skillProficiencies.history),
          skillInsight: drift.Value(character.skillProficiencies.insight),
          skillIntimidation:
              drift.Value(character.skillProficiencies.intimidation),
          skillInvestigation:
              drift.Value(character.skillProficiencies.investigation),
          skillMedicine: drift.Value(character.skillProficiencies.medicine),
          skillNature: drift.Value(character.skillProficiencies.nature),
          skillPerception:
              drift.Value(character.skillProficiencies.perception),
          skillPerformance:
              drift.Value(character.skillProficiencies.performance),
          skillPersuasion:
              drift.Value(character.skillProficiencies.persuasion),
          skillReligion: drift.Value(character.skillProficiencies.religion),
          skillSleightOfHand:
              drift.Value(character.skillProficiencies.sleightOfHand),
          skillStealth: drift.Value(character.skillProficiencies.stealth),
          skillSurvival: drift.Value(character.skillProficiencies.survival),
          lvlAcrobatics: drift.Value(_lvl(character, domain_skill.Skill.acrobatics)),
          lvlAnimalHandling:
              drift.Value(_lvl(character, domain_skill.Skill.animalHandling)),
          lvlArcana: drift.Value(_lvl(character, domain_skill.Skill.arcana)),
          lvlAthletics: drift.Value(_lvl(character, domain_skill.Skill.athletics)),
          lvlDeception: drift.Value(_lvl(character, domain_skill.Skill.deception)),
          lvlHistory: drift.Value(_lvl(character, domain_skill.Skill.history)),
          lvlInsight: drift.Value(_lvl(character, domain_skill.Skill.insight)),
          lvlIntimidation:
              drift.Value(_lvl(character, domain_skill.Skill.intimidation)),
          lvlInvestigation:
              drift.Value(_lvl(character, domain_skill.Skill.investigation)),
          lvlMedicine: drift.Value(_lvl(character, domain_skill.Skill.medicine)),
          lvlNature: drift.Value(_lvl(character, domain_skill.Skill.nature)),
          lvlPerception: drift.Value(_lvl(character, domain_skill.Skill.perception)),
          lvlPerformance: drift.Value(_lvl(character, domain_skill.Skill.performance)),
          lvlPersuasion: drift.Value(_lvl(character, domain_skill.Skill.persuasion)),
          lvlReligion: drift.Value(_lvl(character, domain_skill.Skill.religion)),
          lvlSleightOfHand:
              drift.Value(_lvl(character, domain_skill.Skill.sleightOfHand)),
          lvlStealth: drift.Value(_lvl(character, domain_skill.Skill.stealth)),
          lvlSurvival: drift.Value(_lvl(character, domain_skill.Skill.survival)),
          inspiration: drift.Value(character.inspiration),
          exhaustion: drift.Value(character.exhaustion),
          conditions:
              drift.Value(domain_condition.Condition.toCsv(character.conditions)),
          deathSaveSuccesses: drift.Value(character.deathSaves.successes),
          deathSaveFailures: drift.Value(character.deathSaves.failures),
          alignment: drift.Value(character.alignment?.id),
          hitDiceUsed: drift.Value(character.hitDiceUsed),
          copperPieces: drift.Value(character.currency.copper),
          silverPieces: drift.Value(character.currency.silver),
          electrumPieces: drift.Value(character.currency.electrum),
          goldPieces: drift.Value(character.currency.gold),
          platinumPieces: drift.Value(character.currency.platinum),
          updatedAt: drift.Value(character.updatedAt),
        ),
      );

      if (character.classLevels.isEmpty) {
        throw Exception('Personagem precisa ter pelo menos 1 classe');
      }

      // Inventário e concessões de moeda: apaga e reinsere, igual aos
      // talentos. A lista vem inteira no agregado, e é o próprio domínio que
      // já resolveu o que entra e o que sai (ver `BackgroundGrants`), então
      // reconciliar linha a linha aqui só acrescentaria caminho para errar.
      //
      // O `localId` muda a cada gravação por causa disso. Não é problema: a
      // tela sempre relê pelo `watchById` depois de gravar, e nada guarda o id
      // entre sessões.
      await (_database.delete(_database.characterInventoryItems)
            ..where((tbl) => tbl.characterId.equals(character.id)))
          .go();

      for (final item in character.inventory) {
        await _database.into(_database.characterInventoryItems).insert(
              InventoryMapper.toInsert(
                characterId: character.id,
                item: item,
              ),
            );
      }

      await (_database.delete(_database.characterCurrencyGrants)
            ..where((tbl) => tbl.characterId.equals(character.id)))
          .go();

      for (final grant in character.currencyGrants) {
        await _database.into(_database.characterCurrencyGrants).insert(
              CurrencyGrantMapper.toInsert(
                characterId: character.id,
                grant: grant,
              ),
            );
      }

      // Talentos: apaga e reinsere, igual aos níveis de classe. A lista é
      // curta e vem inteira no agregado, então reconciliar linha a linha só
      // acrescentaria caminho para errar.
      await (_database.delete(_database.characterFeats)
            ..where((tbl) => tbl.characterId.equals(character.id)))
          .go();

      for (final feat in character.feats) {
        await _database.into(_database.characterFeats).insert(
              db.CharacterFeatsCompanion.insert(
                characterId: character.id,
                featId: feat.featId,
                classId: drift.Value(feat.classId),
                level: drift.Value(feat.level),
                chosenSkills: drift.Value(feat.chosenSkillsAsCsv),
                grantedSkills: drift.Value(feat.grantedSkillsAsCsv),
                chosenAbility: drift.Value(feat.chosenAbility?.name),
                appliedAbilityIncreases: drift.Value(
                  feat.appliedAbilityIncreasesAsCsv,
                ),
              ),
            );
      }

      await (_database.delete(_database.characterClassLevels)
            ..where((tbl) => tbl.characterId.equals(character.id)))
          .go();

      for (final classLevel in character.classLevels) {
        await _database.into(_database.characterClassLevels).insert(
              db.CharacterClassLevelsCompanion.insert(
                characterId: character.id,
                classId: classLevel.classId,
                subclassId: drift.Value(classLevel.subclassId),
                level: classLevel.level,
                spellcastingAbility:
                    drift.Value(classLevel.spellcastingAbility?.name),
                spellcastingType:
                    drift.Value(classLevel.spellcastingType?.name),
              ),
            );
      }

      // Se o usuário removeu uma classe, as magias concedidas por ela ficariam
      // listadas na ficha para sempre. Remove magias cuja origem é uma classe
      // que o personagem não possui mais.
      final currentClassIds =
          character.classLevels.map((item) => item.classId).toSet();

      final classSpellRows = await (_database.select(_database.characterSpells)
            ..where((tbl) =>
                tbl.characterId.equals(character.id) &
                tbl.sourceType.equals('class')))
          .get();

      final staleSpellIds = classSpellRows
          .where((row) => !currentClassIds.contains(row.sourceId))
          .map((row) => row.localId)
          .toList();

      if (staleSpellIds.isNotEmpty) {
        await (_database.delete(_database.characterSpells)
              ..where((tbl) => tbl.localId.isIn(staleSpellIds)))
            .go();
      }
    });
  }

  @override
  Future<void> addCharacterSpell({
    required String characterId,
    required domain_spells.CharacterSpell spell,
  }) async {
    await _database.into(_database.characterSpells).insert(
          db.CharacterSpellsCompanion.insert(
            characterId: characterId,
            spellId: spell.spellId,
            sourceType: spell.sourceType,
            sourceId: spell.sourceId,
            sourceName: spell.sourceName,
            isPrepared: drift.Value(spell.isPrepared),
            isKnown: drift.Value(spell.isKnown),
            isAlwaysAvailable: drift.Value(spell.isAlwaysAvailable),
            notes: drift.Value(spell.notes),
          ),
        );
  }

  @override
  Future<void> removeCharacterSpell({
    required String characterId,
    required int spellId,
    required String sourceType,
    required String sourceId,
  }) async {
    await (_database.delete(_database.characterSpells)
          ..where((tbl) =>
              tbl.characterId.equals(characterId) &
              tbl.spellId.equals(spellId) &
              tbl.sourceType.equals(sourceType) &
              tbl.sourceId.equals(sourceId)))
        .go();
  }

  @override
  Future<void> addWeapon({
    required String characterId,
    required domain_weapons.CharacterWeapon weapon,
  }) async {
    await _database.into(_database.characterWeapons).insert(
          WeaponMapper.toInsert(characterId: characterId, weapon: weapon),
        );
  }

  @override
  Future<void> updateWeapon({
    required domain_weapons.CharacterWeapon weapon,
  }) async {
    final localId = weapon.localId;
    if (localId == null) {
      throw ArgumentError('Arma sem localId não pode ser atualizada.');
    }

    await (_database.update(_database.characterWeapons)
          ..where((tbl) => tbl.localId.equals(localId)))
        .write(WeaponMapper.toUpdate(weapon));
  }

  @override
  Future<void> deleteWeapon({required int weaponLocalId}) async {
    await (_database.delete(_database.characterWeapons)
          ..where((tbl) => tbl.localId.equals(weaponLocalId)))
        .go();
  }

  @override
  Future<void> updateMagicItem({
    required domain_items.CharacterMagicItem item,
  }) async {
    await (_database.update(_database.characterMagicItems)
          ..where((tbl) => tbl.localId.equals(item.localId)))
        .write(MagicItemMapper.toUpdate(item));
  }

  @override
  Future<void> addMagicItem({
    required String characterId,
    required domain_items.CharacterMagicItem item,
  }) async {
    final insertedId =
        await _database.into(_database.characterMagicItems).insert(
              MagicItemMapper.toInsert(characterId: characterId, item: item),
            );

    for (final spell in item.spells) {
      await _database.into(_database.characterMagicItemSpells).insert(
            db.CharacterMagicItemSpellsCompanion.insert(
              magicItemId: insertedId,
              spellId: spell.spellId,
              usesCharges: drift.Value(spell.usesCharges),
              chargeCost: drift.Value(spell.chargeCost),
              isAtWill: drift.Value(spell.isAtWill),
              isAlwaysAvailable: drift.Value(spell.isAlwaysAvailable),
            ),
          );
    }
  }

  @override
  Future<void> updateMagicItemCharges({
    required int magicItemId,
    required int? charges,
  }) async {
    await (_database.update(_database.characterMagicItems)
          ..where((tbl) => tbl.localId.equals(magicItemId)))
        .write(
      db.CharacterMagicItemsCompanion(
        charges: drift.Value(charges),
      ),
    );
  }

  @override
  Future<void> deleteMagicItem({
    required int magicItemId,
  }) async {
    await _database.transaction(() async {
      await (_database.delete(_database.characterMagicItemSpells)
            ..where((tbl) => tbl.magicItemId.equals(magicItemId)))
          .go();

      await (_database.delete(_database.characterMagicItems)
            ..where((tbl) => tbl.localId.equals(magicItemId)))
          .go();
    });
  }

  @override
  Future<void> addMagicItemSpell({
    required int magicItemId,
    required domain_item_spells.CharacterMagicItemSpell spell,
  }) async {
    await _database.into(_database.characterMagicItemSpells).insert(
          db.CharacterMagicItemSpellsCompanion.insert(
            magicItemId: magicItemId,
            spellId: spell.spellId,
            usesCharges: drift.Value(spell.usesCharges),
            chargeCost: drift.Value(spell.chargeCost),
            isAtWill: drift.Value(spell.isAtWill),
            isAlwaysAvailable: drift.Value(spell.isAlwaysAvailable),
          ),
        );
  }

  @override
  Future<void> removeMagicItemSpell({
    required int magicItemId,
    required int spellId,
  }) async {
    await (_database.delete(_database.characterMagicItemSpells)
          ..where((tbl) =>
              tbl.magicItemId.equals(magicItemId) &
              tbl.spellId.equals(spellId)))
        .go();
  }

  @override
  Future<Map<int, int>> getUsedSpellSlots(String characterId) async {
    final rows = await (_database.select(_database.characterSpellSlotsUsage)
          ..where((tbl) => tbl.characterId.equals(characterId)))
        .get();

    final map = <int, int>{};

    for (final row in rows) {
      map[row.slotLevel] = row.used;
    }

    return map;
  }

  @override
  Future<void> updateUsedSpellSlot({
    required String characterId,
    required int slotLevel,
    required int used,
  }) async {
    // Nunca deixa o contador negativo e serializa o read-then-write numa
    // transação: dois toques rápidos no botão criavam linhas duplicadas e
    // travavam todo acesso posterior a este personagem.
    final safeUsed = used < 0 ? 0 : used;

    await _database.transaction(() async {
      final existing =
          await (_database.select(_database.characterSpellSlotsUsage)
                ..where((tbl) =>
                    tbl.characterId.equals(characterId) &
                    tbl.slotLevel.equals(slotLevel))
                ..limit(1))
              .getSingleOrNull();

      if (existing == null) {
        await _database.into(_database.characterSpellSlotsUsage).insert(
              db.CharacterSpellSlotsUsageCompanion.insert(
                characterId: characterId,
                slotLevel: slotLevel,
                used: drift.Value(safeUsed),
              ),
              mode: drift.InsertMode.insertOrReplace,
            );
      } else {
        await (_database.update(_database.characterSpellSlotsUsage)
              ..where((tbl) => tbl.localId.equals(existing.localId)))
            .write(
          db.CharacterSpellSlotsUsageCompanion(
            used: drift.Value(safeUsed),
          ),
        );
      }
    });
  }

  @override
  Stream<List<domain.Character>> watchAll() {
    return _database
        .select(_database.characters)
        .watch()
        .asyncMap((rows) async {
      final items = <domain.Character>[];
      for (final row in rows) {
        final classLevels =
            await (_database.select(_database.characterClassLevels)
                  ..where((tbl) => tbl.characterId.equals(row.id)))
                .get();

        final mapped = CharacterMapper.fromDatabase(
          character: row,
          classLevels: classLevels,
        );

        items.add(mapped);
      }
      return items;
    });
  }
}
