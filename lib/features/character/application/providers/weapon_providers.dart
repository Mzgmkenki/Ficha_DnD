import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/services/weapon_attack_calculator.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/weapon_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Os ataques do personagem, já calculados e explicados.
///
/// A família recebe o [Character] inteiro, como os providers de iniciativa e de
/// opções de combate: mudar de classe, subir de nível ou trocar de atributo
/// muda o ataque, e a conta se refaz sozinha.
///
/// Arma cujo id não existe no compêndio é descartada em vez de virar uma linha
/// vazia na ficha. Isso acontece quando o asset é editado depois de a ficha ter
/// sido salva.
final characterAttacksProvider =
    FutureProvider.family.autoDispose<List<WeaponAttack>, Character>(
  (ref, character) async {
    if (character.weapons.isEmpty) return const [];

    final catalog = await ref.watch(weaponsByIdProvider.future);
    final classes = await ref.watch(classEntriesProvider.future);
    final magicItems = magicItemWeaponBonuses(character);

    return [
      for (final weapon in character.weapons)
        if (catalog[weapon.weaponId] case final entry?)
          WeaponAttackCalculator.calculate(
            character: character,
            weapon: weapon,
            entry: entry,
            classes: classes,
            magicItemAttackBonus: magicItems.attack,
            magicItemDamageBonus: magicItems.damage,
          ),
    ];
  },
);

/// Quanto os itens mágicos do personagem somam em ataque e dano com arma.
///
/// Só entra o que o item declara em campo próprio. Um item cujo nome tem `+1`
/// mas que não declarou nada não soma: a descrição é que diz onde o bônus vale,
/// e o app não adivinha isso a partir do nome.
({int attack, int damage}) magicItemWeaponBonuses(Character character) {
  var attack = 0;
  var damage = 0;

  for (final item in character.magicItems) {
    attack += item.weaponAttackBonus;
    damage += item.weaponDamageBonus;
  }

  return (attack: attack, damage: damage);
}

final addCharacterWeaponProvider = Provider<
    Future<void> Function({
      required String characterId,
      required CharacterWeapon weapon,
    })>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required String characterId, required CharacterWeapon weapon}) {
    return repository.addWeapon(characterId: characterId, weapon: weapon);
  };
});

final updateCharacterWeaponProvider =
    Provider<Future<void> Function({required CharacterWeapon weapon})>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required CharacterWeapon weapon}) {
    return repository.updateWeapon(weapon: weapon);
  };
});

final deleteCharacterWeaponProvider =
    Provider<Future<void> Function({required int weaponLocalId})>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({required int weaponLocalId}) {
    return repository.deleteWeapon(weaponLocalId: weaponLocalId);
  };
});
