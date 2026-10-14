import 'package:dnd_ficha_app/core/database/app_database.dart' as db;
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:drift/drift.dart' as drift;

/// Converte linhas de `character_weapons` para [CharacterWeapon] e de volta.
///
/// Existe pelo mesmo motivo do `InventoryMapper`: a arma é gravada em três
/// caminhos diferentes (criação, adição e edição), e com os companions montados
/// à mão em cada um deles acrescentar uma coluna significava lembrar de três
/// lugares — foi assim que o rastro de origem quase nasceu pela metade.
class WeaponMapper {
  const WeaponMapper._();

  /// Lê a linha do banco.
  ///
  /// Degrada em vez de estourar: atributo escolhido ilegível vira nulo (e o
  /// cálculo volta a escolher o melhor entre Força e Destreza), origem
  /// desconhecida vira `manual` (que nenhum recálculo apaga) e quantidade
  /// inválida vira 1. Abrir a ficha é mais importante que o campo.
  static CharacterWeapon fromDatabase(db.CharacterWeapon row) {
    return CharacterWeapon(
      localId: row.localId,
      weaponId: row.weaponId,
      name: row.name,
      quantity: row.quantity < 1 ? 1 : row.quantity,
      magicBonus: row.magicBonus,
      chosenAbility: Ability.fromName(row.chosenAbility),
      twoHanded: row.twoHanded,
      proficiencyOverride: row.proficiencyOverride,
      notes: row.notes,
      source: GrantSource.fromIdOrManual(row.source),
      sourceId: row.sourceId,
      sourceLabel: row.sourceLabel,
      grantedAtCreation: row.grantedAtCreation,
      grantedQuantity: row.grantedQuantity,
      manuallyEdited: row.manuallyEdited,
      grantRef: row.grantRef,
    );
  }

  static db.CharacterWeaponsCompanion toInsert({
    required String characterId,
    required CharacterWeapon weapon,
  }) {
    return db.CharacterWeaponsCompanion.insert(
      characterId: characterId,
      weaponId: weapon.weaponId,
      name: drift.Value(weapon.name),
      quantity: drift.Value(weapon.quantity < 1 ? 1 : weapon.quantity),
      magicBonus: drift.Value(weapon.magicBonus),
      chosenAbility: drift.Value(weapon.chosenAbility?.name),
      twoHanded: drift.Value(weapon.twoHanded),
      proficiencyOverride: drift.Value(weapon.proficiencyOverride),
      notes: drift.Value(weapon.notes),
      source: drift.Value(weapon.source.id),
      sourceId: drift.Value(weapon.sourceId),
      sourceLabel: drift.Value(weapon.sourceLabel),
      grantedAtCreation: drift.Value(weapon.grantedAtCreation),
      grantedQuantity: drift.Value(weapon.grantedQuantity),
      manuallyEdited: drift.Value(weapon.manuallyEdited),
      grantRef: drift.Value(weapon.grantRef),
    );
  }

  /// Companion para atualizar uma linha existente.
  ///
  /// Não inclui `characterId`: a arma não troca de dono.
  static db.CharacterWeaponsCompanion toUpdate(CharacterWeapon weapon) {
    return db.CharacterWeaponsCompanion(
      weaponId: drift.Value(weapon.weaponId),
      name: drift.Value(weapon.name),
      quantity: drift.Value(weapon.quantity < 1 ? 1 : weapon.quantity),
      magicBonus: drift.Value(weapon.magicBonus),
      chosenAbility: drift.Value(weapon.chosenAbility?.name),
      twoHanded: drift.Value(weapon.twoHanded),
      proficiencyOverride: drift.Value(weapon.proficiencyOverride),
      notes: drift.Value(weapon.notes),
      source: drift.Value(weapon.source.id),
      sourceId: drift.Value(weapon.sourceId),
      sourceLabel: drift.Value(weapon.sourceLabel),
      grantedAtCreation: drift.Value(weapon.grantedAtCreation),
      grantedQuantity: drift.Value(weapon.grantedQuantity),
      manuallyEdited: drift.Value(weapon.manuallyEdited),
      grantRef: drift.Value(weapon.grantRef),
    );
  }
}
