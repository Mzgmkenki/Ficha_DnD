import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A tabela de armas do PHB, na ordem do livro.
final weaponEntriesProvider = FutureProvider<List<WeaponEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadWeapons();
});

/// As armas indexadas por id, para quem só precisa resolver o que a ficha
/// guardou.
final weaponsByIdProvider =
    FutureProvider<Map<String, WeaponEntry>>((ref) async {
  final weapons = await ref.watch(weaponEntriesProvider.future);
  return {for (final weapon in weapons) weapon.id: weapon};
});
