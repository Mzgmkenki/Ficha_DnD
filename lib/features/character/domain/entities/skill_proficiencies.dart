import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

/// Proficiências de perícia do personagem.
///
/// Antes cada perícia era um `bool`, o que impedia representar Especialista
/// (bônus dobrado) e Meia Proficiência. Agora guardamos um
/// [ProficiencyLevel] por perícia.
class SkillProficiencies {
  const SkillProficiencies({Map<Skill, ProficiencyLevel>? levels})
      : _levels = levels ?? const {};

  /// Construtor de compatibilidade: recebe os antigos booleanos e converte
  /// `true` em [ProficiencyLevel.proficient].
  factory SkillProficiencies.fromBooleans({
    bool acrobatics = false,
    bool animalHandling = false,
    bool arcana = false,
    bool athletics = false,
    bool deception = false,
    bool history = false,
    bool insight = false,
    bool intimidation = false,
    bool investigation = false,
    bool medicine = false,
    bool nature = false,
    bool perception = false,
    bool performance = false,
    bool persuasion = false,
    bool religion = false,
    bool sleightOfHand = false,
    bool stealth = false,
    bool survival = false,
  }) {
    final map = <Skill, ProficiencyLevel>{};

    void put(Skill skill, bool value) {
      if (value) map[skill] = ProficiencyLevel.proficient;
    }

    put(Skill.acrobatics, acrobatics);
    put(Skill.animalHandling, animalHandling);
    put(Skill.arcana, arcana);
    put(Skill.athletics, athletics);
    put(Skill.deception, deception);
    put(Skill.history, history);
    put(Skill.insight, insight);
    put(Skill.intimidation, intimidation);
    put(Skill.investigation, investigation);
    put(Skill.medicine, medicine);
    put(Skill.nature, nature);
    put(Skill.perception, perception);
    put(Skill.performance, performance);
    put(Skill.persuasion, persuasion);
    put(Skill.religion, religion);
    put(Skill.sleightOfHand, sleightOfHand);
    put(Skill.stealth, stealth);
    put(Skill.survival, survival);

    return SkillProficiencies(levels: map);
  }

  final Map<Skill, ProficiencyLevel> _levels;

  ProficiencyLevel levelFor(Skill skill) =>
      _levels[skill] ?? ProficiencyLevel.none;

  bool isProficient(Skill skill) => levelFor(skill).isProficientOrBetter;

  /// Todas as perícias com algum nível diferente de [ProficiencyLevel.none].
  Map<Skill, ProficiencyLevel> get activeLevels {
    final result = <Skill, ProficiencyLevel>{};
    for (final entry in _levels.entries) {
      if (entry.value != ProficiencyLevel.none) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  SkillProficiencies withLevel(Skill skill, ProficiencyLevel level) {
    final next = Map<Skill, ProficiencyLevel>.from(_levels);
    if (level == ProficiencyLevel.none) {
      next.remove(skill);
    } else {
      next[skill] = level;
    }
    return SkillProficiencies(levels: next);
  }

  SkillProficiencies copyWith({Map<Skill, ProficiencyLevel>? levels}) {
    return SkillProficiencies(levels: levels ?? _levels);
  }

  // Getters de conveniência mantidos para não quebrar chamadas existentes.
  bool get acrobatics => isProficient(Skill.acrobatics);
  bool get animalHandling => isProficient(Skill.animalHandling);
  bool get arcana => isProficient(Skill.arcana);
  bool get athletics => isProficient(Skill.athletics);
  bool get deception => isProficient(Skill.deception);
  bool get history => isProficient(Skill.history);
  bool get insight => isProficient(Skill.insight);
  bool get intimidation => isProficient(Skill.intimidation);
  bool get investigation => isProficient(Skill.investigation);
  bool get medicine => isProficient(Skill.medicine);
  bool get nature => isProficient(Skill.nature);
  bool get perception => isProficient(Skill.perception);
  bool get performance => isProficient(Skill.performance);
  bool get persuasion => isProficient(Skill.persuasion);
  bool get religion => isProficient(Skill.religion);
  bool get sleightOfHand => isProficient(Skill.sleightOfHand);
  bool get stealth => isProficient(Skill.stealth);
  bool get survival => isProficient(Skill.survival);
}
