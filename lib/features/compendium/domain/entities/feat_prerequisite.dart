/// Condições que o personagem precisa cumprir para pegar um talento.
///
/// Cada condição preenchida é obrigatória (E), mas dentro de uma condição a
/// lista é alternativa (OU): `raceIds` com anão e halfling significa "anão ou
/// halfling", enquanto ter `raceIds` e `minLevel` juntos exige as duas coisas.
///
/// [notes] é o que o app não consegue verificar — proficiência com armadura,
/// cenário de campanha, antecedente de outro livro. Isso aparece na tela como
/// aviso e **nunca** esconde o talento: esconder o Mestre de Armadura Pesada de
/// todo guerreiro, porque o app não guarda proficiência de armadura, seria pior
/// que mostrar e deixar o jogador conferir.
class FeatPrerequisite {
  const FeatPrerequisite({
    this.minLevel = 0,
    this.minAbilityAny = const {},
    this.requiresSpellcasting = false,
    this.raceIds = const [],
    this.raceSizes = const [],
    this.classIds = const [],
    this.requiredFeatIds = const [],
    this.forbiddenFeatIds = const [],
    this.notes = const [],
  });

  /// Nível total mínimo do personagem.
  final int minLevel;

  /// Valor mínimo por atributo, satisfeito quando QUALQUER um dos listados
  /// alcança o valor. É o caso do Conjurador Ritual, que aceita Inteligência 13
  /// ou Sabedoria 13.
  final Map<String, int> minAbilityAny;

  /// Se exige poder conjurar pelo menos uma magia.
  final bool requiresSpellcasting;

  /// Raças aceitas, por id. Sub-raça conta pela raça mãe: quem é Elfo Alto
  /// cumpre um pré-requisito de Elfo.
  final List<String> raceIds;

  /// Tamanhos aceitos, alternativa a [raceIds] na mesma condição de raça — a
  /// Agilidade Compacta pede "anão ou raça Pequena".
  final List<String> raceSizes;

  /// Classes aceitas, por id.
  final List<String> classIds;

  /// Talentos que já precisam estar na ficha, todos eles.
  final List<String> requiredFeatIds;

  /// Talentos que impedem este. A Marca Dracônica Aberrante exige não ter
  /// outra marca dracônica.
  final List<String> forbiddenFeatIds;

  /// Exigências que o app não tem como conferir. Informativas.
  final List<String> notes;

  /// Se não há nada a verificar automaticamente.
  bool get isOpen =>
      minLevel <= 0 &&
      minAbilityAny.isEmpty &&
      !requiresSpellcasting &&
      raceIds.isEmpty &&
      raceSizes.isEmpty &&
      classIds.isEmpty &&
      requiredFeatIds.isEmpty &&
      forbiddenFeatIds.isEmpty;

  bool get hasRaceCondition => raceIds.isNotEmpty || raceSizes.isNotEmpty;
}
