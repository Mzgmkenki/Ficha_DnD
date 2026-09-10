import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// As 18 perícias de D&D 5e, cada uma com o atributo que a governa.
///
/// Centralizar isso evita o problema anterior, em que os painéis repetiam
/// 18 blocos copiados e o mapeamento perícia→atributo vivia espalhado.
enum Skill {
  acrobatics('acrobatics', 'Acrobacia', Ability.dexterity),
  animalHandling('animalHandling', 'Adestrar Animais', Ability.wisdom),
  arcana('arcana', 'Arcanismo', Ability.intelligence),
  athletics('athletics', 'Atletismo', Ability.strength),
  performance('performance', 'Atuação', Ability.charisma),
  deception('deception', 'Enganação', Ability.charisma),
  stealth('stealth', 'Furtividade', Ability.dexterity),
  history('history', 'História', Ability.intelligence),
  intimidation('intimidation', 'Intimidação', Ability.charisma),
  insight('insight', 'Intuição', Ability.wisdom),
  investigation('investigation', 'Investigação', Ability.intelligence),
  medicine('medicine', 'Medicina', Ability.wisdom),
  nature('nature', 'Natureza', Ability.intelligence),
  perception('perception', 'Percepção', Ability.wisdom),
  persuasion('persuasion', 'Persuasão', Ability.charisma),
  sleightOfHand('sleightOfHand', 'Prestidigitação', Ability.dexterity),
  religion('religion', 'Religião', Ability.intelligence),
  survival('survival', 'Sobrevivência', Ability.wisdom);

  const Skill(this.id, this.label, this.ability);

  /// Identificador estável usado no JSON do compêndio e no banco.
  final String id;
  final String label;
  final Ability ability;

  String get abbreviation {
    switch (ability) {
      case Ability.strength:
        return 'FOR';
      case Ability.dexterity:
        return 'DES';
      case Ability.constitution:
        return 'CON';
      case Ability.intelligence:
        return 'INT';
      case Ability.wisdom:
        return 'SAB';
      case Ability.charisma:
        return 'CAR';
    }
  }

  static Skill? fromId(String? id) {
    if (id == null) return null;
    for (final skill in Skill.values) {
      if (skill.id == id) return skill;
    }
    return null;
  }

  /// Perícias ordenadas alfabeticamente pelo rótulo em português, que é a
  /// ordem esperada numa ficha brasileira.
  static List<Skill> get sortedByLabel {
    final list = [...Skill.values];
    list.sort((a, b) => a.label.compareTo(b.label));
    return list;
  }
}
