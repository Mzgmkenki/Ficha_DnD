import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/services/subclass_choice.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/subclass_summary.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter/material.dart';

/// Pede a subclasse e devolve o id escolhido, ou nulo se o jogador sair sem
/// escolher.
///
/// Aparece no momento em que a classe alcança o nível de escolha, nos dois
/// caminhos que mexem em nível. Nada é pré-selecionado: o arquétipo define o
/// personagem, e escolher por ele seria pior que perguntar de novo depois.
Future<String?> showSubclassChoiceDialog({
  required BuildContext context,
  required PendingSubclassChoice choice,
  required List<SubclassEntry> options,
}) {
  if (options.isEmpty) {
    // Sem opção no compêndio não há o que perguntar. Avisar é melhor que abrir
    // um diálogo vazio, porque o jogador ficaria esperando uma lista.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${choice.className}: nenhuma ${choice.label.toLowerCase()} '
          'cadastrada no compêndio ainda.',
        ),
      ),
    );
    return Future.value();
  }

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _SubclassChoiceDialog(
      choice: choice,
      options: options,
    ),
  );
}

class _SubclassChoiceDialog extends StatefulWidget {
  const _SubclassChoiceDialog({required this.choice, required this.options});

  final PendingSubclassChoice choice;
  final List<SubclassEntry> options;

  @override
  State<_SubclassChoiceDialog> createState() => _SubclassChoiceDialogState();
}

class _SubclassChoiceDialogState extends State<_SubclassChoiceDialog> {
  SubclassEntry? _selected;

  @override
  Widget build(BuildContext context) {
    final choice = widget.choice;
    final text = Theme.of(context).textTheme;
    final selected = _selected;

    return AlertDialog(
      title: Text('Escolher ${choice.label}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${choice.className} alcançou o ${choice.level}º nível e escolhe '
              'agora sua ${choice.label.toLowerCase()}.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const ValueKey('subclass-choice-dropdown'),
              initialValue: selected?.id,
              decoration: InputDecoration(
                labelText: choice.label,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final option in widget.options)
                  DropdownMenuItem(value: option.id, child: Text(option.name)),
              ],
              onChanged: (value) {
                setState(() {
                  _selected = _find(value);
                });
              },
            ),
            if (selected == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'As características da subclasse só entram na ficha depois '
                  'da escolha.',
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
              )
            else
              SubclassSummary(subclass: selected, level: choice.level),
          ],
        ),
      ),
      actions: [
        TextButton(
          // Sair sem escolher é válido: a decisão continua em aberto e volta a
          // ser oferecida, aqui e na tela de classes.
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Escolher depois'),
        ),
        FilledButton(
          onPressed: selected == null
              ? null
              : () => Navigator.of(context).pop(selected.id),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }

  SubclassEntry? _find(String? id) {
    if (id == null) return null;

    for (final option in widget.options) {
      if (option.id == id) return option;
    }

    return null;
  }
}
