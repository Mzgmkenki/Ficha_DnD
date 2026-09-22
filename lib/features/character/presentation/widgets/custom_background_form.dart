import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter/material.dart';

/// Formulário do "Antecedente Customizável": nome opcional, as duas perícias
/// concedidas e o texto de características.
///
/// Compartilhado entre a criação e a edição do personagem. O estado mora no
/// pai (controllers e ids das perícias), mas a regra de não repetir a mesma
/// perícia nos dois campos fica aqui, num lugar só.
class CustomBackgroundForm extends StatelessWidget {
  const CustomBackgroundForm({
    required this.nameController,
    required this.featuresController,
    required this.skillOneId,
    required this.skillTwoId,
    required this.onSkillsChanged,
    this.margin = const EdgeInsets.only(top: 8),
    this.footnote,
    this.blockedSkillReasons = const {},
    super.key,
  });

  final TextEditingController nameController;
  final TextEditingController featuresController;
  final String? skillOneId;
  final String? skillTwoId;

  /// Recebe o par já resolvido, sem perícias repetidas.
  final void Function(String? skillOneId, String? skillTwoId) onSkillsChanged;

  final EdgeInsetsGeometry margin;

  /// Texto extra no fim do card, para avisos específicos de cada tela.
  final String? footnote;

  /// Perícias já adquiridas em outra etapa, com a origem que as bloqueia.
  final Map<String, String> blockedSkillReasons;

  List<DropdownMenuItem<String>> _itemsExcept(String? excludedId) {
    return Skill.sortedByLabel.where((skill) => skill.id != excludedId).map((
      skill,
    ) {
      final reason = blockedSkillReasons[skill.id];
      return DropdownMenuItem<String>(
        value: skill.id,
        enabled: reason == null,
        child: Text(
          reason == null
              ? '${skill.label} (${skill.abbreviation})'
              : '${skill.label} — já adquirida por $reason',
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monte o seu antecedente',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Um antecedente concede proficiência em duas perícias.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do antecedente (opcional)',
                hintText: 'Ex.: Caçador de Recompensas',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: skillOneId,
              decoration: const InputDecoration(labelText: 'Primeira perícia'),
              items: _itemsExcept(null),
              onChanged: (value) {
                // Evita as duas perícias iguais: troca com a anterior em vez
                // de limpar, para o segundo dropdown nunca ficar com um valor
                // que saiu da lista de opções.
                final nextTwo = skillTwoId == value ? skillOneId : skillTwoId;
                onSkillsChanged(value, nextTwo);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Escolha a primeira perícia.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: skillTwoId,
              decoration: const InputDecoration(labelText: 'Segunda perícia'),
              items: _itemsExcept(skillOneId),
              onChanged: (value) => onSkillsChanged(skillOneId, value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Escolha a segunda perícia.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: featuresController,
              decoration: const InputDecoration(
                labelText: 'Características do antecedente',
                hintText:
                    'Descreva o que o antecedente concede, sua história, '
                    'contatos, ferramentas...',
                alignLabelWithHint: true,
              ),
              minLines: 4,
              maxLines: 10,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            if (footnote != null) ...[
              const SizedBox(height: 12),
              Text(footnote!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
