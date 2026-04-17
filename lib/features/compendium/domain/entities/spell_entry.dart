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
}