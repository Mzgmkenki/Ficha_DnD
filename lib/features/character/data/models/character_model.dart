class CharacterModel {
  const CharacterModel({
    required this.id,
    required this.name,
    required this.playerName,
    required this.speciesId,
    required this.backgroundId,
    required this.notes,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    required this.armorClass,
    required this.initiativeBonus,
    required this.speed,
    required this.maxHitPoints,
    required this.currentHitPoints,
    required this.temporaryHitPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? playerName;
  final String? speciesId;
  final String? backgroundId;
  final String notes;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final int armorClass;
  final int initiativeBonus;
  final int speed;
  final int maxHitPoints;
  final int currentHitPoints;
  final int temporaryHitPoints;
  final DateTime createdAt;
  final DateTime updatedAt;
}
