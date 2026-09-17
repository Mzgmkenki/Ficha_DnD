import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Se a arma é simples ou marcial.
///
/// Determina a proficiência: quem tem "armas simples" não acerta bem uma
/// espada longa, e é o que separa as duas listas do PHB.
enum WeaponCategory {
  simple('simple', 'Simples'),
  martial('martial', 'Marcial');

  const WeaponCategory(this.id, this.label);

  final String id;
  final String label;

  static WeaponCategory? fromId(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in WeaponCategory.values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}

/// Se a arma é de corpo a corpo ou à distância.
///
/// É o que decide o atributo padrão do ataque: corpo a corpo usa Força, à
/// distância usa Destreza. Uma arma de corpo a corpo com Arremesso continua
/// usando Força mesmo arremessada.
enum WeaponRangeType {
  melee('melee', 'Corpo a corpo'),
  ranged('ranged', 'À distância');

  const WeaponRangeType(this.id, this.label);

  final String id;
  final String label;

  static WeaponRangeType? fromId(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in WeaponRangeType.values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}

/// Tipo de dano físico das armas do PHB.
///
/// `none` existe para a Rede, que é uma arma sem dano.
enum WeaponDamageType {
  bludgeoning('bludgeoning', 'contundente'),
  piercing('piercing', 'perfurante'),
  slashing('slashing', 'cortante'),
  none('none', 'sem dano');

  const WeaponDamageType(this.id, this.label);

  final String id;
  final String label;

  static WeaponDamageType? fromId(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in WeaponDamageType.values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}

/// Propriedades de arma do PHB.
///
/// Só as que existem na tabela: nenhuma foi inventada. As que o cálculo de
/// ataque usa são [finesse] (deixa escolher Força ou Destreza), [thrown] e
/// [versatile] (muda o dado quando empunhada com as duas mãos).
enum WeaponProperty {
  ammunition('ammunition', 'Munição'),
  finesse('finesse', 'Acuidade'),
  heavy('heavy', 'Pesada'),
  light('light', 'Leve'),
  loading('loading', 'Recarga'),
  reach('reach', 'Alcance'),
  special('special', 'Especial'),
  thrown('thrown', 'Arremesso'),
  twoHanded('twoHanded', 'Duas mãos'),
  versatile('versatile', 'Versátil');

  const WeaponProperty(this.id, this.label);

  final String id;
  final String label;

  static WeaponProperty? fromId(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    for (final item in WeaponProperty.values) {
      if (item.id.toLowerCase() == normalized.toLowerCase()) return item;
    }
    return null;
  }
}

/// Alcance de uma arma, em metros.
class WeaponRange {
  const WeaponRange({required this.normal, required this.long});

  /// Alcance sem penalidade.
  final double normal;

  /// Alcance máximo, com desvantagem.
  final double long;

  static WeaponRange? tryParse(Object? raw) {
    if (raw is! Map) return null;

    double? number(Object? value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.replaceAll(',', '.'));
      return null;
    }

    final normal = number(raw['normal']);
    final long = number(raw['long']);
    if (normal == null || long == null) return null;

    return WeaponRange(normal: normal, long: long);
  }
}

/// Uma arma do compêndio.
///
/// Formato esperado em `assets/data/srd/weapons.json`, em snake_case como os
/// outros arquivos:
///
/// ```json
/// {
///   "id": "rapier",
///   "name": "Rapieira",
///   "name_original": "Rapier",
///   "category": "martial",
///   "range_type": "melee",
///   "damage": "1d8",
///   "damage_type": "piercing",
///   "properties": ["finesse"],
///   "thrown_range": { "normal": 6, "long": 18 },
///   "range": { "normal": 24, "long": 96 },
///   "versatile_damage": "1d10",
///   "special": "texto da propriedade Especial",
///   "source": "phb"
/// }
/// ```
///
/// Distâncias em metros, como o resto do app. Custo e peso não estão
/// cadastrados: a ficha não usa nenhum dos dois hoje, e um número inventado
/// seria pior que a ausência.
class WeaponEntry {
  const WeaponEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.rangeType,
    required this.damageType,
    this.nameOriginal,
    this.damage,
    this.properties = const [],
    this.range,
    this.thrownRange,
    this.versatileDamage,
    this.special,
    this.source = 'phb',
  });

  final String id;
  final String name;

  /// Nome em inglês, para achar a arma no livro.
  final String? nameOriginal;

  final WeaponCategory category;
  final WeaponRangeType rangeType;

  /// Dado de dano, como `1d8` ou `2d6`. Nulo na Rede, que não causa dano.
  final String? damage;

  final WeaponDamageType damageType;
  final List<WeaponProperty> properties;

  /// Alcance de tiro, nas armas à distância com Munição.
  final WeaponRange? range;

  /// Alcance de arremesso, nas armas com a propriedade Arremesso.
  final WeaponRange? thrownRange;

  /// Dado usado quando a arma Versátil é empunhada com as duas mãos.
  final String? versatileDamage;

  /// Texto da propriedade Especial, quando a arma tem uma.
  final String? special;

  final String source;

  bool has(WeaponProperty property) => properties.contains(property);

  bool get isFinesse => has(WeaponProperty.finesse);
  bool get isThrown => has(WeaponProperty.thrown);
  bool get isVersatile => has(WeaponProperty.versatile);
  bool get isTwoHanded => has(WeaponProperty.twoHanded);
  bool get isMelee => rangeType == WeaponRangeType.melee;
  bool get isRanged => rangeType == WeaponRangeType.ranged;
  bool get dealsDamage => damage != null && damageType != WeaponDamageType.none;

  /// Atributo que a arma exige, quando não há escolha.
  ///
  /// Corpo a corpo usa Força e à distância usa Destreza. Nulo quando a arma
  /// tem Acuidade, porque aí quem escolhe é o jogador — e é por isso que o
  /// atributo sai da arma, e não da classe: um ladino com maça bate com Força.
  Ability? get requiredAbility {
    if (isFinesse) return null;
    return isMelee ? Ability.strength : Ability.dexterity;
  }

  /// Atributos que a arma aceita.
  List<Ability> get allowedAbilities {
    // Acuidade deixa usar Força ou Destreza, à escolha de quem ataca.
    if (isFinesse) return const [Ability.strength, Ability.dexterity];
    return [isMelee ? Ability.strength : Ability.dexterity];
  }

  /// Propriedades em texto, como aparecem na ficha.
  String get propertiesLabel {
    if (properties.isEmpty) return '—';

    return properties.map((item) {
      if (item == WeaponProperty.versatile && versatileDamage != null) {
        return '${item.label} ($versatileDamage)';
      }
      if (item == WeaponProperty.thrown && thrownRange != null) {
        return '${item.label} '
            '(${_meters(thrownRange!.normal)}/${_meters(thrownRange!.long)})';
      }
      if (item == WeaponProperty.ammunition && range != null) {
        return '${item.label} '
            '(${_meters(range!.normal)}/${_meters(range!.long)})';
      }
      return item.label;
    }).join(', ');
  }

  static String _meters(double value) {
    if (value == value.roundToDouble()) return '${value.toInt()} m';
    return '${value.toStringAsFixed(1).replaceAll('.', ',')} m';
  }
}
