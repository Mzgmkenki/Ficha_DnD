class RaceChoiceGroup {
  const RaceChoiceGroup({
    required this.id,
    required this.name,
    required this.options,
    required this.choose,
  });

  final String id;
  final String name;
  final List<String> options;
  final int choose;
}