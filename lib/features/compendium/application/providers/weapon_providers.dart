import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/utils/pt_collation.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A tabela de armas do PHB, na ordem do livro.
final weaponEntriesProvider = FutureProvider<List<WeaponEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadWeapons();
});

/// As armas indexadas por id, para quem só precisa resolver o que a ficha
/// guardou.
final weaponsByIdProvider = FutureProvider<Map<String, WeaponEntry>>((
  ref,
) async {
  final weapons = await ref.watch(weaponEntriesProvider.future);
  return {for (final weapon in weapons) weapon.id: weapon};
});

/// As armas em ordem alfabética, para as listas de seleção.
///
/// Separado de [weaponEntriesProvider] de propósito. A lista do livro é
/// agrupada por categoria e é essa ordem que o equipamento inicial de classe
/// espera ao resolver "a primeira arma marcial". Reordenar a lista base
/// mudaria o que a criação de personagem entrega; reordenar uma cópia só muda
/// o que o jogador lê.
final sortedWeaponEntriesProvider = FutureProvider<List<WeaponEntry>>((
  ref,
) async {
  final weapons = await ref.watch(weaponEntriesProvider.future);

  return sortedByDisplayName(
    weapons,
    name: (item) => item.name,
    id: (item) => item.id,
  );
});
