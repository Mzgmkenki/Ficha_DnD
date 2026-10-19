import 'package:dnd_ficha_app/core/utils/pt_collation.dart';
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

  String get abbreviation => ability.abbreviation;

  static Skill? fromId(String? id) {
    if (id == null) return null;
    for (final skill in Skill.values) {
      if (skill.id == id) return skill;
    }
    return null;
  }

  /// Perícias ordenadas alfabeticamente pelo rótulo em português, que é a
  /// ordem esperada numa ficha brasileira.
  ///
  /// Ordenado uma vez e reaproveitado: este getter é lido dentro de `build`
  /// na ficha, na tela de proficiências e no PDF, e reordenar 18 itens a cada
  /// quadro é trabalho jogado fora.
  static List<Skill> get sortedByLabel => _skillsByLabel;
}

/// Cache da ordem alfabética das perícias.
///
/// Usa a colação do projeto em vez de `compareTo` cru: comparar ponto de
/// código trata o acento como letra diferente, e é o que colocaria "Bárbaro"
/// depois de "Bardo" numa lista de classes. Aqui nenhum rótulo começa com
/// acento hoje, mas a comparação certa é a mesma em toda lista do app.
final List<Skill> _skillsByLabel = sortedByDisplayName(
  Skill.values,
  name: (item) => item.label,
  id: (item) => item.id,
);
