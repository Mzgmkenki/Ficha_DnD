import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/class_mechanic_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/feature_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_condition_state.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/weapon_attack_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/weapon_style_bonuses.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/weapon_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:flutter/foundation.dart';
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
final characterAttacksProvider = FutureProvider.family
    .autoDispose<List<WeaponAttack>, Character>((ref, character) async {
      if (character.weapons.isEmpty) return const [];

      final catalog = await ref.watch(weaponsByIdProvider.future);
      final classes = await ref.watch(classEntriesProvider.future);
      final magicItems = magicItemWeaponBonuses(character);

      // Os Estilos de Combate entram aqui. A lista é montada uma vez e filtrada
      // arma por arma, porque a condição é da ARMA: a Arquearia vale no arco e
      // não na espada.
      final styleEffects = await weaponStyleEffectsFor(ref, character);
      final context = FeatureFormulaContext.fromCharacter(character);

      return [
        for (final weapon in character.weapons)
          if (catalog[weapon.weaponId] case final entry?)
            () {
              final style = WeaponStyleBonuses.resolve(
                effects: styleEffects,
                weapon: weapon,
                entry: entry,
                context: context,
              );

              return WeaponAttackCalculator.calculate(
                character: character,
                weapon: weapon,
                entry: entry,
                classes: classes,
                magicItemAttackBonus: magicItems.attack,
                magicItemDamageBonus: magicItems.damage,
                extraAttackParts: style.attack,
                extraDamageParts: style.damage,
              );
            }(),
      ];
    });

/// Os efeitos de ataque e de dano com arma que o personagem tem valendo.
///
/// Junta características e mecânicas de classe, já filtrados pelo equipamento
/// vestido. Falha de leitura de asset devolve lista vazia em vez de derrubar a
/// ficha: o ataque continua aparecendo, só sem o bônus do estilo.
Future<List<FeatureEffect>> weaponStyleEffectsFor(
  Ref ref,
  Character character,
) async {
  try {
    final features = await ref.watch(
      resolvedFeaturesProvider(character).future,
    );
    final mechanics = await ref.watch(
      resolvedClassMechanicsProvider(character).future,
    );

    final equipment = FeatureConditionState.from(
      inventory: character.inventory,
      abilityScores: character.abilityScores,
    );

    return [
      ...features.weaponBonusEffects(equipment: equipment),
      ...mechanics.weaponBonusEffects(equipment: equipment),
    ];
  } catch (error, stackTrace) {
    debugPrint('Falha ao resolver bônus de estilo de combate: $error');
    debugPrintStack(stackTrace: stackTrace);
    return const [];
  }
}

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
  })
>((ref) {
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
