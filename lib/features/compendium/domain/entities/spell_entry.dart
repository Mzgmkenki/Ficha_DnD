/// Rótulo em português de cada classe conjuradora, pelo id interno.
///
/// [SpellEntry.classes] guarda o id em inglês, que é o que os filtros comparam
/// e o que `CompendiumRepositoryImpl._mapClassName` produz ao ler o asset. O id
/// serve para comparar, não para mostrar: a tela de detalhe exibia
/// "warlock, sorcerer, wizard" num app inteiro em português.
const Map<String, String> spellClassLabels = {
  'artificer': 'Artífice',
  'barbarian': 'Bárbaro',
  'bard': 'Bardo',
  'cleric': 'Clérigo',
  'druid': 'Druida',
  'fighter': 'Guerreiro',
  'monk': 'Monge',
  'paladin': 'Paladino',
  'ranger': 'Patrulheiro',
  'rogue': 'Ladino',
  'sorcerer': 'Feiticeiro',
  'warlock': 'Bruxo',
  'wizard': 'Mago',
};

/// Traduz um id de classe. Devolve o próprio id quando não conhece, para um id
/// novo aparecer na tela em vez de desaparecer sem aviso.
String spellClassLabel(String id) => spellClassLabels[id] ?? id;

class SpellEntry {
  const SpellEntry({
    required this.id,
    required this.namePt,
    required this.nameOriginal,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.components,
    required this.hasCostlyMaterials,
    required this.duration,
    required this.concentration,
    required this.ritual,
    required this.classes,
    required this.subclasses,
    required this.description,
    required this.source,
    required this.page,
    required this.isSrd,
    this.upcast,
  });

  final int id;
  final String namePt;
  final String nameOriginal;
  final int level;
  final String school;
  final String castingTime;
  final String range;
  final String components;
  final bool hasCostlyMaterials;
  final String duration;
  final bool concentration;
  final bool ritual;
  final List<String> classes;
  final List<String> subclasses;
  final String description;
  final String? upcast;
  final String source;
  final String page;
  final bool isSrd;

  /// As classes em português, na ordem em que o asset as declara.
  List<String> get classLabels =>
      classes.map(spellClassLabel).toList(growable: false);
}
