class ClassFeatureEntry {
  const ClassFeatureEntry({
    required this.classId,
    required this.level,
    required this.features,
    required this.source,
  });

  final String classId;
  final int level;
  final List<String> features;
  final String source;
}