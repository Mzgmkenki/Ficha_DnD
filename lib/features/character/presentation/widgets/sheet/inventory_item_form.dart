import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Abre o formulário de item do inventário.
///
/// Devolve o item montado, ou `null` se o jogador cancelou. Não grava nada: a
/// gravação é de quem chamou, que é o dono da lista.
///
/// Passar [item] edita; omitir cria. Item criado aqui nasce marcado como
/// personalizado — o app não tem catálogo de equipamento geral para escolher
/// de uma lista, então todo item adicionado à mão é conteúdo do jogador.
Future<InventoryItem?> showInventoryItemForm({
  required BuildContext context,
  InventoryItem? item,
}) {
  return showDialog<InventoryItem>(
    context: context,
    builder: (dialogContext) => _InventoryItemForm(item: item),
  );
}

class _InventoryItemForm extends StatefulWidget {
  const _InventoryItemForm({this.item});

  final InventoryItem? item;

  @override
  State<_InventoryItemForm> createState() => _InventoryItemFormState();
}

class _InventoryItemFormState extends State<_InventoryItemForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _weightController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _noteController;

  late ItemCategory _category;
  late bool _equipped;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _nameController = TextEditingController(text: item?.name ?? '');
    _quantityController = TextEditingController(
      text: '${item?.quantity ?? 1}',
    );
    _weightController = TextEditingController(
      text: item?.weight == null ? '' : _formatWeight(item!.weight!),
    );
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _noteController = TextEditingController(text: item?.note ?? '');
    _category = item?.category ?? ItemCategory.gear;
    _equipped = item?.equipped ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final raw = int.tryParse(_quantityController.text.trim()) ?? 1;
    // Corta aqui também, e não só no botão de menos: aqui o número é digitado.
    final quantity = raw < 0 ? 0 : raw;

    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final weight = weightText.isEmpty ? null : double.tryParse(weightText);

    final existing = widget.item;

    final result = existing == null
        ? InventoryItem(
            name: _nameController.text.trim(),
            quantity: quantity,
            description: _descriptionController.text.trim(),
            weight: weight,
            category: _category,
            equipped: _equipped,
            note: _noteController.text.trim(),
            // Item adicionado à mão é conteúdo do jogador, e sua origem é
            // manual — o que garante que nenhum recálculo de antecedente vá
            // removê-lo.
            isCustom: true,
          )
        : existing.copyWith(
            name: _nameController.text.trim(),
            quantity: quantity,
            description: _descriptionController.text.trim(),
            weight: weight,
            category: _category,
            equipped: _equipped,
            note: _noteController.text.trim(),
          );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final item = widget.item;

    return AlertDialog(
      title: Text(_isEditing ? 'Editar item' : 'Adicionar item'),
      // `scrollable` em vez de altura fixa: com o teclado aberto numa tela
      // pequena o formulário inteiro ainda precisa ser alcançável.
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              key: const ValueKey('inventory-form-name'),
              controller: _nameController,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) {
                return (value ?? '').trim().isEmpty
                    ? 'Informe o nome do item'
                    : null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('inventory-form-quantity'),
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    // Sem o sinal de menos no teclado: quantidade negativa não
                    // é um estado que o inventário aceite.
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                    validator: (value) {
                      final parsed = int.tryParse((value ?? '').trim());
                      if (parsed == null) return 'Informe um número';
                      if (parsed < 0) return 'Não pode ser negativa';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('inventory-form-weight'),
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      hintText: 'opcional',
                    ),
                    validator: (value) {
                      final raw = (value ?? '').trim().replaceAll(',', '.');
                      if (raw.isEmpty) return null;
                      final parsed = double.tryParse(raw);
                      if (parsed == null) return 'Número inválido';
                      if (parsed < 0) return 'Não pode ser negativo';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ItemCategory>(
              key: const ValueKey('inventory-form-category'),
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: ItemCategory.values
                  .map(
                    (value) => DropdownMenuItem<ItemCategory>(
                      value: value,
                      child: Text(value.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('inventory-form-description'),
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'opcional',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('inventory-form-note'),
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: const InputDecoration(
                labelText: 'Observação',
                hintText: 'opcional',
              ),
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              key: const ValueKey('inventory-form-equipped'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Equipado'),
              value: _equipped,
              onChanged: (value) => setState(() => _equipped = value),
            ),

            // A origem é mostrada, não editável: ela é o rastro de como o item
            // entrou na ficha, e deixar o jogador reescrevê-la quebraria a
            // remoção seletiva na troca de antecedente.
            if (item != null && item.isGranted) ...[
              const Divider(),
              Text(
                'Origem: ${item.originLabel}',
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              ),
              if (item.grantedQuantity != null)
                Text(
                  'Quantidade concedida: ${item.grantedQuantity}',
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
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
          key: const ValueKey('inventory-form-save'),
          onPressed: _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  static String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}
