import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';

/// Com quais armas a classe dá proficiência.
///
/// Vem em dois formatos porque o PHB usa os dois: a maioria das classes
/// concede categorias inteiras ("armas simples e marciais"), e algumas listam
/// armas específicas — o bardo tem armas simples mais besta de mão, espada
/// longa, rapieira e espada curta.
///
/// Formato no asset:
///
/// ```json
/// "weapon_proficiencies": {
///   "categories": ["simple"],
///   "weapons": ["hand_crossbow", "longsword", "rapier", "shortsword"]
/// }
/// ```
class WeaponProficiencies {
  const WeaponProficiencies({
    this.categories = const [],
    this.weaponIds = const [],
  });

  /// Categorias inteiras: simples, marcial.
  final List<WeaponCategory> categories;

  /// Ids de armas específicas, além das categorias.
  final List<String> weaponIds;

  bool get isEmpty => categories.isEmpty && weaponIds.isEmpty;

  /// Se a classe dá proficiência com [weapon].
  bool covers(WeaponEntry weapon) {
    return categories.contains(weapon.category) ||
        weaponIds.contains(weapon.id);
  }

  /// Lê o bloco do asset. Devolve vazio quando não existe.
  ///
  /// Vazio significa "a classe não declara", e nesse caso quem resolve a
  /// proficiência não afirma que falta: é diferente de "não tem proficiência
  /// com nada".
  static WeaponProficiencies tryParse(Object? raw) {
    if (raw is! Map) return const WeaponProficiencies();

    List<String> strings(Object? value) {
      if (value is! List) return const [];
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    return WeaponProficiencies(
      categories: [
        for (final id in strings(raw['categories']))
          if (WeaponCategory.fromId(id) case final category?) category,
      ],
      weaponIds: strings(raw['weapons']),
    );
  }
}
