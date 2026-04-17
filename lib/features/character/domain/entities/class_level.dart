import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/spellcasting_type.dart';

class ClassLevel {
  const ClassLevel({
    required this.classId,
    required this.level,
    this.subclassId,
    this.spellcastingAbility,
    this.spellcastingType,
  }) : assert(level > 0 && level <= 20);

  final String classId;
  final String? subclassId;
  final int level;
  final Ability? spellcastingAbility;
  final SpellcastingType? spellcastingType;

  ClassLevel copyWith({
    String? classId,
    String? subclassId,
    int? level,
    Ability? spellcastingAbility,
    SpellcastingType? spellcastingType,
  }) {
    return ClassLevel(
      classId: classId ?? this.classId,
      subclassId: subclassId ?? this.subclassId,
      level: level ?? this.level,
      spellcastingAbility: spellcastingAbility ?? this.spellcastingAbility,
      spellcastingType: spellcastingType ?? this.spellcastingType,
    );
  }
}
