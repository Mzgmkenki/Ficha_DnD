class RaceTrait {
  const RaceTrait({
    required this.id,
    required this.name,
    required this.description,
    this.category,
  });

  final String id;
  final String name;
  final String description;
  final String? category;
}