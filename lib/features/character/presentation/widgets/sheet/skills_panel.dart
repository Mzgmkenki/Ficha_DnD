import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/services/skill_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/dice_roll_sheet.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/derived_value_row.dart';
import 'package:flutter/material.dart';

class SkillsPanel extends StatelessWidget {
  const SkillsPanel({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final skills = Skill.sortedByLabel;

    // Armadura equipada que impõe desvantagem em Furtividade. Só conta peça
    // equipada E válida: armadura bloqueada por Força não está sendo usada, e
    // portanto não penaliza (ver `OwnedArmor`).
    final noisyArmor = OwnedArmor.stealthDisadvantageSource(
      character.inventory,
      abilityScores: character.abilityScores,
    );
    final stealthDisadvantage =
        noisyArmor == null
            ? null
            : '${noisyArmor.name} impõe desvantagem em testes de Destreza '
                '(Furtividade). O bônus da perícia não muda: a desvantagem vale na '
                'rolagem.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título fica no cabeçalho da seção, na ficha.
            _PassiveScores(character: character),
            const SizedBox(height: 16),
            for (var i = 0; i < skills.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _SkillRow(
                character: character,
                skill: skills[i],
                // A desvantagem é resolvida UMA vez, aqui, e repassada só para
                // a perícia afetada. Resolver dentro de cada linha custaria 18
                // varreduras do inventário e abriria espaço para o aviso
                // aparecer em duas perícias.
                disadvantageReason:
                    skills[i] == Skill.stealth ? stealthDisadvantage : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.character,
    required this.skill,
    this.disadvantageReason,
  });

  final Character character;
  final Skill skill;
  final String? disadvantageReason;

  /// De onde a proficiência veio, para o jogador poder consultar.
  ///
  /// Lê o registro de origem gravado na criação (ou completado ao abrir a
  /// ficha). Vem vazio nas fichas antigas em que a origem não pôde ser
  /// determinada com segurança — nesse caso a linha simplesmente não aparece,
  /// que é melhor que exibir um palpite.
  ///
  /// Mais de uma fonte pode conceder a mesma perícia. Todas são listadas, mas
  /// a perícia aparece UMA vez e o bônus é somado uma vez: quem decide isso é
  /// o nível em `SkillProficiencies`, não a quantidade de origens.
  String? get _originLabel {
    final labels = <String>[];

    for (final grant in character.skillProficiencyGrants) {
      if (grant.skill != skill) continue;
      if (labels.contains(grant.sourceLabel)) continue;
      labels.add(grant.sourceLabel);
    }

    if (labels.isEmpty) return null;

    return 'Concedida por: ${labels.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final label = '${skill.label} (${skill.abbreviation})';
    final bonus = SkillCalculator.skillBonus(character, skill);

    final row = DerivedValueRow(
      label: label,
      value: bonus,
      level: character.skillProficiencies.levelFor(skill),
      disadvantageReason: disadvantageReason,
      onRoll: () => showDiceRollSheet(context, label: label, modifier: bonus),
    );

    // Só quem é proficiente tem origem a mostrar: numa perícia sem
    // proficiência a linha seria ruído em 18 itens.
    final origin =
        character.skillProficiencies.isProficient(skill) ? _originLabel : null;

    if (origin == null) return row;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row,
        Padding(
          padding: const EdgeInsets.only(left: 26, top: 2),
          child: Text(
            origin,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Valores passivos, obrigatórios numa ficha 5e e antes ausentes.
class _PassiveScores extends StatelessWidget {
  const _PassiveScores({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valores passivos',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _PassiveChip(
                label: 'Percepção',
                value: SkillCalculator.passivePerception(character),
              ),
              _PassiveChip(
                label: 'Investigação',
                value: SkillCalculator.passiveInvestigation(character),
              ),
              _PassiveChip(
                label: 'Intuição',
                value: SkillCalculator.passiveInsight(character),
              ),
            ],
          ),
          // A nota de exaustão saiu daqui junto com a penalidade de 5 que ela
          // explicava. Os efeitos da exaustão ficam na seção Condições.
        ],
      ),
    );
  }
}

class _PassiveChip extends StatelessWidget {
  const _PassiveChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text('$value', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
