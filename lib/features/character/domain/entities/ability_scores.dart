import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

class AbilityScores {
  const AbilityScores({
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
  }) : assert(strength >= 1 && strength <= 30),
       assert(dexterity >= 1 && dexterity <= 30),
       assert(constitution >= 1 && constitution <= 30),
       assert(intelligence >= 1 && intelligence <= 30),
       assert(wisdom >= 1 && wisdom <= 30),
       assert(charisma >= 1 && charisma <= 30);

  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  int valueFor(Ability ability) {
    switch (ability) {
      case Ability.strength:
        return strength;
      case Ability.dexterity:
        return dexterity;
      case Ability.constitution:
        return constitution;
      case Ability.intelligence:
        return intelligence;
      case Ability.wisdom:
        return wisdom;
      case Ability.charisma:
        return charisma;
    }
  }

  /// Cópia com [ability] valendo [value].
  ///
  /// Existe para quem trabalha com o enum em vez dos seis campos nomeados,
  /// como o serviço que aplica aumento de atributo de talento.
  AbilityScores withValue(Ability ability, int value) {
    switch (ability) {
      case Ability.strength:
        return copyWith(strength: value);
      case Ability.dexterity:
        return copyWith(dexterity: value);
      case Ability.constitution:
        return copyWith(constitution: value);
      case Ability.intelligence:
        return copyWith(intelligence: value);
      case Ability.wisdom:
        return copyWith(wisdom: value);
      case Ability.charisma:
        return copyWith(charisma: value);
    }
  }

  AbilityScores copyWith({
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
  }) {
    return AbilityScores(
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
    );
  }
}
