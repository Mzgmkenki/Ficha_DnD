import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';

abstract class CharacterRepository {
  Stream<List<Character>> watchAll();
  Future<Character?> findById(String id);
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

  Future<void> addMagicItem({
    required String characterId,
    required CharacterMagicItem item,
  });
}