class SpellSlotProgressionEntry {
  const SpellSlotProgressionEntry({
    required this.tableId,
    required this.level,
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
    required this.sixth,
    required this.seventh,
    required this.eighth,
    required this.ninth,
    this.pactSlotLevel,
  });

  final String tableId;
  final int level;
  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;
  final int sixth;
  final int seventh;
  final int eighth;
  final int ninth;
  final int? pactSlotLevel;

  bool get hasAnySlots =>
      first > 0 ||
      second > 0 ||
      third > 0 ||
      fourth > 0 ||
      fifth > 0 ||
      sixth > 0 ||
      seventh > 0 ||
      eighth > 0 ||
      ninth > 0;
}