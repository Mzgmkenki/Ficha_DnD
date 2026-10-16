import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:flutter/material.dart';

/// O que o jogador decidiu no seletor de talentos.
class FeatChoice {
  const FeatChoice({required this.feat, required this.skills, this.ability});

  final FeatEntry feat;
  final List<Skill> skills;

  /// Atributo escolhido, nos talentos que oferecem "+1 em X ou Y".
  final Ability? ability;
}

/// Escolhe um talento entre os disponíveis, com as escolhas que ele exige.
///
/// Mora fora do painel de talentos porque dois caminhos abrem o MESMO seletor:
/// a seção da ficha e a janela automática da subida de nível. Com uma cópia em
/// cada lugar os dois divergiriam, e é exatamente essa divergência que fazia a
/// escolha do nível ser registrada sem a classe e o nível corretos.
///
/// [slotLabel] identifica a vaga no título (`Guerreiro 4`). Nulo mantém o
/// título genérico, para quem abre o seletor sem uma vaga definida.
Future<FeatChoice?> showFeatPickerDialog({
  required BuildContext context,
  required List<FeatEntry> available,
  String? slotLabel,
  bool barrierDismissible = true,
}) {
  return showDialog<FeatChoice>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder:
        (dialogContext) =>
            _FeatPickerDialog(available: available, slotLabel: slotLabel),
  );
}

class _FeatPickerDialog extends StatefulWidget {
  const _FeatPickerDialog({required this.available, this.slotLabel});

  final List<FeatEntry> available;
  final String? slotLabel;

  @override
  State<_FeatPickerDialog> createState() => _FeatPickerDialogState();
}

class _FeatPickerDialogState extends State<_FeatPickerDialog> {
  FeatEntry? _selected;
  final Set<Skill> _skills = {};
  Ability? _ability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;
    final choice = selected?.skillChoice;
    final toChoose = selected?.skillsToChoose ?? 0;
    final abilityOptions = selected?.abilityOptions ?? const <Ability>[];

    // Talento com escolha de atributo só fica completo depois de escolher: sem
    // essa trava o jogador confirmaria e perderia o +1 sem perceber.
    final complete =
        selected != null &&
        _skills.length == toChoose &&
        (abilityOptions.isEmpty || _ability != null);

    return AlertDialog(
      title: Text(
        widget.slotLabel == null
            ? 'Escolher talento'
            : '${widget.slotLabel} — Escolher talento',
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              key: const ValueKey('feat-dropdown'),
              initialValue: selected?.id,
              decoration: const InputDecoration(labelText: 'Talento'),
              // Sem `isExpanded` o dropdown se dimensiona pelo item mais largo.
              // Com 105 talentos, nomes como "Descendente dos Planos
              // Exteriores" passam da largura do diálogo, o texto quebra em
              // duas linhas e estoura a altura fixa do campo.
              isExpanded: true,
              items: [
                for (final feat in widget.available)
                  DropdownMenuItem(
                    value: feat.id,
                    child: Text(
                      feat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (id) {
                setState(() {
                  _selected = _find(id);
                  // Trocar de talento zera as escolhas: as opções do anterior
                  // não valem para o novo.
                  _skills.clear();
                  _ability = null;
                });
              },
            ),

            if (selected?.description case final text? when text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(text, style: theme.textTheme.bodySmall),
              ),

            // Só o que o app não confere. O que ele confere já filtrou a lista,
            // então repetir aqui seria ruído.
            if (selected != null && selected.requires.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Confirme à mão: ${selected.requires.notes.join('; ')}.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            if (abilityOptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Escolha o atributo que recebe +1:'),
              // O grupo vive num ancestral, e não em cada item: `groupValue` e
              // `onChanged` do RadioListTile foram depreciados depois do
              // Flutter 3.32 em favor do RadioGroup.
              RadioGroup<Ability>(
                groupValue: _ability,
                onChanged: (picked) => setState(() => _ability = picked),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final ability in abilityOptions)
                      RadioListTile<Ability>(
                        key: ValueKey('feat-ability-${ability.name}'),
                        value: ability,
                        title: Text(ability.label),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                  ],
                ),
              ),
            ],

            if (choice != null) ...[
              const SizedBox(height: 12),
              Text(
                toChoose == 1
                    ? 'Escolha 1 perícia:'
                    : 'Escolha $toChoose perícias:',
              ),
              for (final skill in choice.skills)
                CheckboxListTile(
                  key: ValueKey('feat-skill-${skill.id}'),
                  value: _skills.contains(skill),
                  title: Text(skill.label),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) {
                    setState(() {
                      if (checked ?? false) {
                        // Trava no limite em vez de desmarcar outra: desmarcar
                        // escondido faria o jogador perder a escolha anterior
                        // sem entender por quê.
                        if (_skills.length < toChoose) _skills.add(skill);
                      } else {
                        _skills.remove(skill);
                      }
                    });
                  },
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed:
              !complete
                  ? null
                  : () => Navigator.of(context).pop(
                    FeatChoice(
                      feat: selected,
                      skills: _skills.toList(growable: false),
                      ability: _ability,
                    ),
                  ),
          child: const Text('Adicionar'),
        ),
      ],
    );
  }

  FeatEntry? _find(String? id) {
    if (id == null) return null;
    for (final feat in widget.available) {
      if (feat.id == id) return feat;
    }
    return null;
  }
}
