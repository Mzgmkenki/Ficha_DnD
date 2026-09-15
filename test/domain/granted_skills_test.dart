import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_skills.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('apply', () {
    test('marca como proficiente quem não tinha nada', () {
      final result = GrantedSkills.apply(
        const SkillProficiencies(),
        const [Skill.insight, Skill.religion],
      );

      expect(result.levelFor(Skill.insight), ProficiencyLevel.proficient);
      expect(result.levelFor(Skill.religion), ProficiencyLevel.proficient);
    });

    test('não rebaixa Especialista', () {
      // É a regra que a criação violava: ela atribuía direto, e um talento
      // pego no 8º nível transformaria um Especialista em Proficiente.
      final current = SkillProficiencies(
        levels: const {Skill.stealth: ProficiencyLevel.expertise},
      );

      final result = GrantedSkills.apply(current, const [Skill.stealth]);

      expect(result.levelFor(Skill.stealth), ProficiencyLevel.expertise);
    });

    test('sobe Meia Proficiência para Proficiente', () {
      // Meia proficiência não é "proficiente o bastante": o bardo com Talento
      // Versátil ganha metade, e o antecedente concede o valor cheio.
      final current = SkillProficiencies(
        levels: const {Skill.arcana: ProficiencyLevel.half},
      );

      final result = GrantedSkills.apply(current, const [Skill.arcana]);

      expect(result.levelFor(Skill.arcana), ProficiencyLevel.proficient);
    });

    test('não mexe em perícia que ninguém concedeu', () {
      final result = GrantedSkills.apply(
        const SkillProficiencies(),
        const [Skill.insight],
      );

      expect(result.levelFor(Skill.medicine), ProficiencyLevel.none);
    });
  });

  group('newlyGranted', () {
    test('devolve só o que a fonte realmente concedeu', () {
      // O ponto de existir: Furtividade já vinha da classe, então o talento não
      // pode registrar que concedeu — senão removê-lo tiraria a da classe.
      final current = SkillProficiencies(
        levels: const {Skill.stealth: ProficiencyLevel.proficient},
      );

      final result = GrantedSkills.newlyGranted(
        current,
        const [Skill.stealth, Skill.perception],
      );

      expect(result, const [Skill.perception]);
    });

    test('Especialista também não conta como concedido', () {
      final current = SkillProficiencies(
        levels: const {Skill.athletics: ProficiencyLevel.expertise},
      );

      expect(
        GrantedSkills.newlyGranted(current, const [Skill.athletics]),
        isEmpty,
      );
    });
  });

  group('revoke', () {
    test('tira a proficiência que a fonte havia concedido', () {
      final current = SkillProficiencies(
        levels: const {Skill.nature: ProficiencyLevel.proficient},
      );

      final result = GrantedSkills.revoke(current, const [Skill.nature]);

      expect(result.levelFor(Skill.nature), ProficiencyLevel.none);
    });

    test('não tira Especialista', () {
      // Se o jogador promoveu a perícia depois, a escolha dele vale mais que a
      // fonte que está saindo.
      final current = SkillProficiencies(
        levels: const {Skill.nature: ProficiencyLevel.expertise},
      );

      final result = GrantedSkills.revoke(current, const [Skill.nature]);

      expect(result.levelFor(Skill.nature), ProficiencyLevel.expertise);
    });

    test('aplicar e reverter volta ao estado original', () {
      const original = SkillProficiencies();
      const granted = [Skill.insight, Skill.religion];

      final applied = GrantedSkills.apply(original, granted);
      final reverted = GrantedSkills.revoke(
        applied,
        GrantedSkills.newlyGranted(original, granted),
      );

      expect(reverted.activeLevels, isEmpty);
    });
  });

  group('fromIds', () {
    test('converte ids válidos', () {
      expect(
        GrantedSkills.fromIds(const ['insight', 'religion']),
        const [Skill.insight, Skill.religion],
      );
    });

    test('descarta id que não existe em vez de lançar', () {
      // Vem de dado do compêndio escrito à mão; derrubar a ficha por causa de
      // um typo seria pior.
      expect(
        GrantedSkills.fromIds(const ['insight', 'nao_existe', '']),
        const [Skill.insight],
      );
    });
  });
}
