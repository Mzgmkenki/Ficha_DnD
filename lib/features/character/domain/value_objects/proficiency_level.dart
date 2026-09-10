/// Nível de proficiência aplicado a uma perícia ou salvaguarda.
///
/// Em D&D 5e o bônus não é binário:
/// - [none]: apenas o modificador do atributo.
/// - [half]: metade do bônus de proficiência, arredondada para baixo
///   (Bardo "Faz-Tudo", Sortudo do Meio-elfo em algumas variantes).
/// - [proficient]: bônus de proficiência cheio.
/// - [expertise]: bônus de proficiência dobrado (Ladino, Bardo,
///   Clérigo do domínio do Conhecimento).
enum ProficiencyLevel {
  none,
  half,
  proficient,
  expertise;

  /// Bônus a somar ao modificador do atributo, dado o bônus de
  /// proficiência [proficiencyBonus] do personagem.
  int bonus(int proficiencyBonus) {
    switch (this) {
      case ProficiencyLevel.none:
        return 0;
      case ProficiencyLevel.half:
        return proficiencyBonus ~/ 2;
      case ProficiencyLevel.proficient:
        return proficiencyBonus;
      case ProficiencyLevel.expertise:
        return proficiencyBonus * 2;
    }
  }

  bool get isProficientOrBetter =>
      this == ProficiencyLevel.proficient || this == ProficiencyLevel.expertise;

  String get label {
    switch (this) {
      case ProficiencyLevel.none:
        return 'Sem proficiência';
      case ProficiencyLevel.half:
        return 'Meia proficiência';
      case ProficiencyLevel.proficient:
        return 'Proficiente';
      case ProficiencyLevel.expertise:
        return 'Especialista';
    }
  }

  /// Sufixo curto para exibir ao lado do valor na ficha.
  String? get shortTag {
    switch (this) {
      case ProficiencyLevel.none:
        return null;
      case ProficiencyLevel.half:
        return '½';
      case ProficiencyLevel.proficient:
        return 'P';
      case ProficiencyLevel.expertise:
        return 'E';
    }
  }

  /// Valor persistido no banco. Usamos int para manter a coluna compacta
  /// e a ordem semântica (0 = nada, 3 = especialista).
  int get dbValue {
    switch (this) {
      case ProficiencyLevel.none:
        return 0;
      case ProficiencyLevel.half:
        return 1;
      case ProficiencyLevel.proficient:
        return 2;
      case ProficiencyLevel.expertise:
        return 3;
    }
  }

  static ProficiencyLevel fromDb(int? value) {
    switch (value) {
      case 1:
        return ProficiencyLevel.half;
      case 2:
        return ProficiencyLevel.proficient;
      case 3:
        return ProficiencyLevel.expertise;
      default:
        return ProficiencyLevel.none;
    }
  }
}
