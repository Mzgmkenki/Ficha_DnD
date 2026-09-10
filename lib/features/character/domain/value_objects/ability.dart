/// Os seis atributos, com o rótulo em português e a abreviação usada na
/// ficha. Centralizar aqui evita repetir o mapa de nomes em cada tela.
enum Ability {
  strength('Força', 'FOR'),
  dexterity('Destreza', 'DES'),
  constitution('Constituição', 'CON'),
  intelligence('Inteligência', 'INT'),
  wisdom('Sabedoria', 'SAB'),
  charisma('Carisma', 'CAR');

  const Ability(this.label, this.abbreviation);

  final String label;
  final String abbreviation;

  static Ability? fromName(String? value) {
    if (value == null) return null;
    for (final ability in Ability.values) {
      if (ability.name == value) return ability;
    }
    return null;
  }
}
