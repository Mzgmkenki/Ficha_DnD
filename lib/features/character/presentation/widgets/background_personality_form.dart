import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/background_personality_choice.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_personality.dart';
import 'package:flutter/material.dart';

/// Seletores de traço, ideal, vínculo e defeito do antecedente.
///
/// Os campos começam vazios de propósito: pré-selecionar a primeira linha da
/// tabela decidiria a personagem pelo jogador, e seria indistinguível de uma
/// escolha real na hora de validar.
///
/// Não é um `DropdownButtonFormField` como os outros campos da criação, e isso
/// é deliberado: as opções são frases inteiras ("Eu acredito que se algo vale a
/// pena ser feito, deve ser feito bem...") e num menu de dropdown elas ficariam
/// truncadas justamente no texto que o jogador precisa ler para escolher. O
/// campo mostra a escolha com o texto completo, e abrir leva a uma folha
/// rolável com as opções inteiras.
class BackgroundPersonalityForm extends StatelessWidget {
  const BackgroundPersonalityForm({
    required this.personality,
    required this.selection,
    required this.onChanged,
    this.allowCustom = true,
    super.key,
  });

  final BackgroundPersonality personality;
  final BackgroundPersonalitySelection selection;
  final ValueChanged<BackgroundPersonalitySelection> onChanged;

  /// Libera a opção "Personalizado".
  ///
  /// Só existe porque o app já suporta conteúdo próprio no antecedente
  /// customizável; não foi criada para esta tela.
  final bool allowCustom;

  @override
  Widget build(BuildContext context) {
    // Antecedente sem tabela nenhuma não mostra seção: é o caso de dado
    // incompleto, e exibir campos obrigatórios vazios travaria a criação.
    if (personality.isEmpty) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;
    final fields = <Widget>[];

    for (final category in PersonalityCategory.values) {
      final count = personality.choiceCountFor(category);
      if (count == 0) continue;

      final table = personality.tableFor(category);

      for (var index = 0; index < count; index++) {
        final current = selection.at(category, index);

        fields.add(
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _PersonalityField(
              // A chave inclui a categoria e a posição para os dois campos de
              // traço serem alvos distintos em teste.
              key: ValueKey('personality-${category.id}-$index'),
              label: count == 1
                  ? category.label
                  : '${category.label} ${index + 1}',
              table: table,
              choice: current,
              // Impede escolher a mesma opção duas vezes na mesma categoria:
              // as já usadas nas OUTRAS posições saem da lista.
              blockedKeys: _blockedKeysFor(category, index),
              allowCustom: allowCustom,
              onChanged: (choice) => onChanged(
                selection.replaceAt(
                  category: category,
                  index: index,
                  choice: choice,
                ),
              ),
            ),
          ),
        );
      }
    }

    final error = selection.validationError(personality);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Personalidade', style: text.titleMedium),
        const SizedBox(height: 2),
        Text(
          'Escolha o que descreve a personagem. As opções vêm do antecedente '
          'selecionado.',
          style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
        ),
        ...fields,
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error,
              key: const ValueKey('personality-error'),
              style: text.bodySmall?.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  /// Chaves já usadas nas outras posições da mesma categoria.
  Set<String> _blockedKeysFor(PersonalityCategory category, int index) {
    final result = <String>{};
    final items = selection.forCategory(category);

    for (var i = 0; i < items.length; i++) {
      if (i == index) continue;
      final choice = items[i];
      if (!choice.isEmpty) result.add(choice.dedupeKey);
    }

    return result;
  }
}

/// Um campo de escolha narrativa.
class _PersonalityField extends StatelessWidget {
  const _PersonalityField({
    required this.label,
    required this.table,
    required this.choice,
    required this.blockedKeys,
    required this.allowCustom,
    required this.onChanged,
    super.key,
  });

  final String label;
  final PersonalityTable table;
  final BackgroundPersonalityChoice? choice;
  final Set<String> blockedKeys;
  final bool allowCustom;
  final ValueChanged<BackgroundPersonalityChoice?> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final selected = choice;

    final display = selected == null
        ? null
        : (selected.isCustom
            ? selected.customText
            : table.optionById(selected.optionId)?.displayText);

    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          // `alignLabelWithHint` mantém o rótulo no topo quando o conteúdo tem
          // várias linhas, em vez de centralizá-lo ao lado do parágrafo.
          alignLabelWithHint: true,
          suffixIcon: selected == null
              ? const Icon(Icons.arrow_drop_down)
              : IconButton(
                  tooltip: 'Limpar',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => onChanged(null),
                ),
        ),
        isEmpty: selected == null,
        child: display == null
            ? null
            // Sem `maxLines`: o texto completo é o que o jogador precisa ver, e
            // truncar aqui esconderia metade da escolha.
            : Text(
                display,
                style: text.bodyMedium,
              ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final result = await showModalBottomSheet<_FieldResult>(
      context: context,
      isScrollControlled: true,
      // Folha rolável em vez de menu: a lista tem até 20 parágrafos, e com
      // `isScrollControlled` ela aproveita a altura toda em tela pequena.
      builder: (sheetContext) => _PersonalitySheet(
        label: label,
        table: table,
        choice: choice,
        blockedKeys: blockedKeys,
        allowCustom: allowCustom,
      ),
    );

    if (result == null) return;
    onChanged(result.choice);
  }
}

/// Embrulho para distinguir "fechou sem escolher" de "escolheu limpar".
class _FieldResult {
  const _FieldResult(this.choice);
  final BackgroundPersonalityChoice? choice;
}

class _PersonalitySheet extends StatefulWidget {
  const _PersonalitySheet({
    required this.label,
    required this.table,
    required this.choice,
    required this.blockedKeys,
    required this.allowCustom,
  });

  final String label;
  final PersonalityTable table;
  final BackgroundPersonalityChoice? choice;
  final Set<String> blockedKeys;
  final bool allowCustom;

  @override
  State<_PersonalitySheet> createState() => _PersonalitySheetState();
}

class _PersonalitySheetState extends State<_PersonalitySheet> {
  late final TextEditingController _customController;
  late bool _writingCustom;

  @override
  void initState() {
    super.initState();
    final choice = widget.choice;
    _writingCustom = choice?.isCustom ?? false;
    _customController = TextEditingController(text: choice?.customText ?? '');
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _pick(PersonalityOption option) {
    Navigator.of(context).pop(
      _FieldResult(BackgroundPersonalityChoice.fromOption(option)),
    );
  }

  void _saveCustom() {
    final value = _customController.text.trim();
    if (value.isEmpty) return;

    Navigator.of(context).pop(
      _FieldResult(
        BackgroundPersonalityChoice.custom(
          category: widget.table.category,
          text: value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final selectedId = widget.choice?.optionId;

    return SafeArea(
      // SafeArea garante que a lista não fique sob a barra de gestos do
      // Android, e o padding inferior acompanha o teclado quando o jogador
      // está escrevendo a opção própria.
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(widget.label, style: text.titleLarge),
                      ),
                      IconButton(
                        tooltip: 'Fechar',
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                if (widget.table.die.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tabela ${widget.table.die} — role ou escolha',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.onDarkVariant,
                        ),
                      ),
                    ),
                  ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      for (final option in widget.table.options)
                        _OptionTile(
                          option: option,
                          selected: option.id == selectedId,
                          // Opção já usada no outro campo da mesma categoria
                          // aparece desabilitada, e não escondida: o jogador
                          // entende por que não pode escolhê-la.
                          blocked: widget.blockedKeys.contains(
                            'option:${option.id}',
                          ),
                          onTap: () => _pick(option),
                        ),

                      if (widget.allowCustom) ...[
                        const Divider(),
                        if (!_writingCustom)
                          ListTile(
                            key: const ValueKey('personality-custom-open'),
                            leading: const Icon(Icons.edit_outlined),
                            title: const Text('Personalizado'),
                            subtitle: const Text(
                              'Escrever o meu próprio texto',
                            ),
                            onTap: () => setState(() => _writingCustom = true),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  key: const ValueKey('personality-custom'),
                                  controller: _customController,
                                  autofocus: true,
                                  minLines: 2,
                                  maxLines: 5,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    labelText: widget.label,
                                    hintText: 'Escreva com suas palavras',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton(
                                    key: const ValueKey(
                                      'personality-custom-save',
                                    ),
                                    onPressed: _saveCustom,
                                    child: const Text('Usar este texto'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.selected,
    required this.blocked,
    required this.onTap,
  });

  final PersonalityOption option;
  final bool selected;
  final bool blocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListTile(
      key: ValueKey('personality-option-${option.id}'),
      enabled: !blocked,
      selected: selected,
      leading: SizedBox(
        width: 24,
        child: Text(
          '${option.roll}',
          textAlign: TextAlign.center,
          style: text.labelLarge?.copyWith(color: AppColors.onDarkVariant),
        ),
      ),
      // O texto inteiro, sem corte: é o conteúdo da escolha.
      title: Text(option.displayText),
      subtitle: blocked ? const Text('Já escolhido no outro campo') : null,
      trailing: selected ? const Icon(Icons.check, size: 18) : null,
      onTap: blocked ? null : onTap,
    );
  }
}
