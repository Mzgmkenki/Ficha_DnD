import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';

abstract class CharacterRepository {
  Stream<List<Character>> watchAll();
  Future<Character?> findById(String id);

  /// Emite o personagem completo (com magias e itens) a cada alteração no
  /// banco. Substitui o padrão de `findById` + invalidação manual do cache.
  Stream<Character?> watchById(String id);

  /// Emite os slots de magia gastos a cada alteração.
  Stream<Map<int, int>> watchUsedSpellSlots(String characterId);
  Future<void> create(Character character);
  Future<void> update(Character character);
  Future<void> delete(String id);

  Future<void> addCharacterSpell({
    required String characterId,
    required CharacterSpell spell,
  });

  Future<void> removeCharacterSpell({
    required String characterId,
    required int spellId,
    required String sourceType,
    required String sourceId,
  });

  Future<void> addWeapon({
    required String characterId,
    required CharacterWeapon weapon,
  });

  /// Grava a arma inteira. Exige [CharacterWeapon.localId] preenchido.
  Future<void> updateWeapon({
    required CharacterWeapon weapon,
  });

  Future<void> deleteWeapon({
    required int weaponLocalId,
  });

  Future<void> addMagicItem({
    required String characterId,
    required CharacterMagicItem item,
  });

  /// Grava o item inteiro, inclusive os bônus estruturados.
  ///
  /// Existe separado de [updateMagicItemCharges] porque aquele é o caminho
  /// rápido da ficha (gastar uma carga) e não pode arrastar o resto do item.
  Future<void> updateMagicItem({
    required CharacterMagicItem item,
  });

  Future<void> updateMagicItemCharges({
    required int magicItemId,
    required int? charges,
  });

  Future<void> deleteMagicItem({
    required int magicItemId,
  });

  Future<void> addMagicItemSpell({
    required int magicItemId,
    required CharacterMagicItemSpell spell,
  });

  Future<void> removeMagicItemSpell({
    required int magicItemId,
    required int spellId,
  });

  Future<Map<int, int>> getUsedSpellSlots(String characterId);

  Future<void> updateUsedSpellSlot({
    required String characterId,
    required int slotLevel,
    required int used,
  });

  /// Zera o uso de espaços de magia. Se [slotLevels] for nulo, zera todos
  /// (descanso longo); se for uma lista, zera apenas aqueles níveis
  /// (descanso curto do Bruxo).
  Future<void> resetUsedSpellSlots({
    required String characterId,
    List<int>? slotLevels,
  });
}