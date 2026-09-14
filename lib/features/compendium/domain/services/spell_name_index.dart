import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';

/// Encontra a magia do compêndio a partir do nome escrito à mão.
///
/// As listas de magia das subclasses vêm em texto, com os nomes em inglês. O
/// compêndio é em português e guarda o nome original num campo separado, então
/// a busca precisa aceitar os dois, além de tolerar diferenças de caixa,
/// acentuação e pontuação.
class SpellNameIndex {
  SpellNameIndex(Iterable<SpellEntry> spells) {
    for (final spell in spells) {
      _register(spell.nameOriginal, spell);
      _register(spell.namePt, spell);
    }

    // Variantes sem o nome do autor entram depois das exatas, para nunca
    // sobrescrever uma correspondência direta.
    for (final spell in spells) {
      _registerFallback(_withoutAuthor(spell.nameOriginal), spell);
      _registerFallback(_withoutAuthor(spell.namePt), spell);
    }
  }

  final Map<String, SpellEntry> _byName = {};
  final Map<String, SpellEntry> _byNameWithoutAuthor = {};

  /// Devolve a magia correspondente a [name], ou nulo se não houver.
  SpellEntry? find(String name) {
    final key = _normalize(name);
    if (key.isEmpty) return null;

    final direct = _byName[key];
    if (direct != null) return direct;

    // "Melf's Acid Arrow" no documento contra "Acid Arrow" no compêndio, e o
    // caso inverso.
    final stripped = _withoutAuthor(name);
    return _byName[_normalize(stripped)] ??
        _byNameWithoutAuthor[key] ??
        _byNameWithoutAuthor[_normalize(stripped)];
  }

  void _register(String name, SpellEntry spell) {
    final key = _normalize(name);
    if (key.isEmpty) return;
    _byName.putIfAbsent(key, () => spell);
  }

  void _registerFallback(String name, SpellEntry spell) {
    final key = _normalize(name);
    if (key.isEmpty) return;
    _byNameWithoutAuthor.putIfAbsent(key, () => spell);
  }

  /// Remove o possessivo do autor: "Melf's Acid Arrow" e "Flecha Ácida de
  /// Melf" viram "acid arrow" e "flecha acida".
  String _withoutAuthor(String name) {
    final apostrophe = RegExp(r"^[\p{L}]+['’]s\s+", unicode: true);
    if (apostrophe.hasMatch(name)) {
      return name.replaceFirst(apostrophe, '');
    }

    final ofAuthor = RegExp(r'\s+d[eo]\s+[\p{L}]+$', unicode: true);
    if (ofAuthor.hasMatch(name)) {
      return name.replaceFirst(ofAuthor, '');
    }

    return name;
  }

  static String _normalize(String value) {
    final lower = value.trim().toLowerCase();

    final withoutAccents = lower
        .replaceAll(RegExp('[áàâãä]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[íìîï]'), 'i')
        .replaceAll(RegExp('[óòôõö]'), 'o')
        .replaceAll(RegExp('[úùûü]'), 'u')
        .replaceAll('ç', 'c');

    return withoutAccents
        // Pontuação e hífen não distinguem magia: "Green-flame Blade" e
        // "Green Flame Blade" são a mesma.
        .replaceAll(RegExp(r"['’\.,\-/]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
