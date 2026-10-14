import 'package:dnd_ficha_app/core/database/app_database.dart' as db;
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:drift/drift.dart' as drift;

/// Converte linhas de `character_inventory_items` para [InventoryItem] e de
/// volta.
class InventoryMapper {
  const InventoryMapper._();

  static InventoryItem fromDatabase(db.CharacterInventoryItem row) {
    return InventoryItem(
      localId: row.localId,
      itemId: row.itemId,
      name: row.name,
      // Clamp na leitura, igual ao que o mapper faz com os testes contra a
      // morte: quantidade negativa vinda de base editada à mão não pode virar
      // número negativo na ficha.
      quantity: row.quantity < 0 ? 0 : row.quantity,
      description: row.description,
      weight: row.weight,
      // Categoria e origem desconhecidas caem em valores seguros em vez de
      // lançar: dado gravado por versão mais nova não pode esconder o item.
      category: ItemCategory.fromIdOrOther(row.category),
      equipped: row.isEquipped,
      note: row.note,
      isCustom: row.isCustom,
      source: GrantSource.fromIdOrManual(row.source),
      sourceId: row.sourceId,
      sourceLabel: row.sourceLabel,
      grantedAtCreation: row.grantedAtCreation,
      grantedQuantity: row.grantedQuantity,
      manuallyEdited: row.manuallyEdited,
      grantRef: row.grantRef,
      armorStrengthRequirement: row.armorStrengthRequirement,
      armorStealthDisadvantage: row.armorStealthDisadvantage,
      armorMagicBonus: row.armorMagicBonus,
      linkedWeaponLocalId: row.linkedWeaponLocalId,
      linkedMagicItemLocalId: row.linkedMagicItemLocalId,
    );
  }

  static db.CharacterInventoryItemsCompanion toInsert({
    required String characterId,
    required InventoryItem item,
  }) {
    return db.CharacterInventoryItemsCompanion.insert(
      characterId: characterId,
      name: item.name,
      itemId: drift.Value(item.itemId),
      quantity: drift.Value(item.quantity < 0 ? 0 : item.quantity),
      description: drift.Value(item.description),
      weight: drift.Value(item.weight),
      category: drift.Value(item.category.id),
      isEquipped: drift.Value(item.equipped),
      note: drift.Value(item.note),
      isCustom: drift.Value(item.isCustom),
      source: drift.Value(item.source.id),
      sourceId: drift.Value(item.sourceId),
      sourceLabel: drift.Value(item.sourceLabel),
      grantedAtCreation: drift.Value(item.grantedAtCreation),
      grantedQuantity: drift.Value(item.grantedQuantity),
      manuallyEdited: drift.Value(item.manuallyEdited),
      grantRef: drift.Value(item.grantRef),
      armorStrengthRequirement: drift.Value(item.armorStrengthRequirement),
      armorStealthDisadvantage: drift.Value(item.armorStealthDisadvantage),
      armorMagicBonus: drift.Value(item.armorMagicBonus),
      linkedWeaponLocalId: drift.Value(item.linkedWeaponLocalId),
      linkedMagicItemLocalId: drift.Value(item.linkedMagicItemLocalId),
    );
  }

  /// Companion para atualizar uma linha existente.
  ///
  /// Não inclui `characterId`: o item não troca de dono.
  static db.CharacterInventoryItemsCompanion toUpdate(InventoryItem item) {
    return db.CharacterInventoryItemsCompanion(
      itemId: drift.Value(item.itemId),
      name: drift.Value(item.name),
      quantity: drift.Value(item.quantity < 0 ? 0 : item.quantity),
      description: drift.Value(item.description),
      weight: drift.Value(item.weight),
      category: drift.Value(item.category.id),
      isEquipped: drift.Value(item.equipped),
      note: drift.Value(item.note),
      isCustom: drift.Value(item.isCustom),
      source: drift.Value(item.source.id),
      sourceId: drift.Value(item.sourceId),
      sourceLabel: drift.Value(item.sourceLabel),
      grantedAtCreation: drift.Value(item.grantedAtCreation),
      grantedQuantity: drift.Value(item.grantedQuantity),
      manuallyEdited: drift.Value(item.manuallyEdited),
      grantRef: drift.Value(item.grantRef),
      armorStrengthRequirement: drift.Value(item.armorStrengthRequirement),
      armorStealthDisadvantage: drift.Value(item.armorStealthDisadvantage),
      armorMagicBonus: drift.Value(item.armorMagicBonus),
      linkedWeaponLocalId: drift.Value(item.linkedWeaponLocalId),
      linkedMagicItemLocalId: drift.Value(item.linkedMagicItemLocalId),
    );
  }
}
