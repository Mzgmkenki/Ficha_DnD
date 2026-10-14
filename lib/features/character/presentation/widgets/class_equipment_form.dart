import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_equipment_selection.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_equipment_grants.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:flutter/material.dart';

/// Equipamentos iniciais concedidos pela classe, na criação do personagem.
///
/// Stateless de propósito, como o `BackgroundPersonalityForm`: o estado é a
/// [selection], que vive na página, e cada interação devolve a seleção inteira
/// por [onChanged]. É isso que impede o widget de guardar escolha própria e
/// duplicar equipamento quando a árvore reconstrói.
class ClassEquipmentForm extends StatelessWidget {
  const ClassEquipmentForm({
    required this.equipment,
    required this.weapons,
    required this.selection,
    required this.onChanged,
    super.key,
  });

  /// O que a classe concede. Nulo quando a classe não tem dado cadastrado.
  final ClassStartingEquipment? equipment;

  /// Catálogo de armas, para resolver as escolhas por categoria.
  final List<WeaponEntry> weapons;

  final ClassEquipmentSelection selection;
  final ValueChanged<ClassEquipmentSelection> onChanged;

  @override
  Widget build(BuildContext context) {
    final data = equipment;

    // Classe sem equipamento cadastrado não mostra seção. É o caso de dado
    // incompleto, e exibir uma seção vazia com erro travaria a criação de uma
    // classe que o compêndio ainda não descreve.
    if (data == null || data.isEmpty) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;
    final pending = selection.pendingLabels(data, weapons);

    return Column(
      key: const ValueKey('class-equipment-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Equipamentos iniciais da classe', style: text.titleMedium),
        const SizedBox(height: 2),
        Text(
          'Escolha o que a classe entrega. O equipamento do antecedente é '
          'somado a este, e nada é escolhido por você.',
          style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
        ),
        if (data.fixedItems.isNotEmpty || data.fixedPicks.isNotEmpty)
          _FixedCard(
            equipment: data,
            weapons: weapons,
            selection: selection,
            onChanged: onChanged,
          ),
        for (final group in selection.visibleGroups(data))
          _GroupCard(
            group: group,
            weapons: weapons,
            selection: selection,
            onChanged: onChanged,
          ),
        _SummaryCard(
          equipment: data,
          weapons: weapons,
          selection: selection,
        ),
        if (pending.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              pending.length == 1
                  ? 'Falta escolher: ${pending.first}.'
                  : 'Faltam ${pending.length} escolhas: ${pending.join('; ')}.',
              key: const ValueKey('class-equipment-error'),
              style: text.bodySmall?.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }
}

/// O que a classe entrega sem perguntar nada.
class _FixedCard extends StatelessWidget {
  const _FixedCard({
    required this.equipment,
    required this.weapons,
    required this.selection,
    required this.onChanged,
  });

  final ClassStartingEquipment equipment;
  final List<WeaponEntry> weapons;
  final ClassEquipmentSelection selection;
  final ValueChanged<ClassEquipmentSelection> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      key: const ValueKey('class-equipment-fixed'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Recebido automaticamente',
                    style: text.labelLarge,
                  ),
                ),
              ],
            ),
            for (final item in equipment.fixedItems)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _ItemLine(item: item),
              ),
            // Escolha que o livro concede sempre, mas sem dizer qual item: as
            // duas armas simples do Artífice e o símbolo sagrado do Clérigo.
            for (final pick in equipment.fixedPicks)
              _PickFields(
                pick: pick,
                pickKey: ClassEquipmentSelection.fixedPickKey(pick.id),
                weapons: weapons,
                selection: selection,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}

/// Um grupo de escolha, com as alternativas.
class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.weapons,
    required this.selection,
    required this.onChanged,
  });

  final ClassEquipmentGroup group;
  final List<WeaponEntry> weapons;
  final ClassEquipmentSelection selection;
  final ValueChanged<ClassEquipmentSelection> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final chosen = selection.optionsFor(group.id);
    final complete = chosen.length >= group.choose;

    return Card(
      key: ValueKey('class-equipment-group-${group.id}'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (group.label.isNotEmpty)
                        Text(group.label, style: text.labelLarge),
                      Text(
                        group.instructionLabel,
                        style: text.bodySmall?.copyWith(
                          color: AppColors.onDarkVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Obrigatória enquanto falta, concluída quando fecha. O estado
                // fica visível sem precisar rolar até o fim da tela.
                if (complete)
                  const Icon(Icons.check_circle, size: 18, color: AppColors.red)
                else
                  Text(
                    'Obrigatória',
                    style: text.labelSmall?.copyWith(color: AppColors.red),
                  ),
              ],
            ),
            for (final option in group.options)
              _OptionTile(
                group: group,
                option: option,
                weapons: weapons,
                selection: selection,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}

/// Uma alternativa, com o conteúdo completo do pacote.
///
/// Não usa `RadioListTile`: o conteúdo é uma lista de itens com quantidade e
/// escolhas aninhadas, e o controle precisa envolver tudo isso. O ícone de
/// rádio é desenhado à mão pelo mesmo motivo.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.group,
    required this.option,
    required this.weapons,
    required this.selection,
    required this.onChanged,
  });

  final ClassEquipmentGroup group;
  final ClassEquipmentOption option;
  final List<WeaponEntry> weapons;
  final ClassEquipmentSelection selection;
  final ValueChanged<ClassEquipmentSelection> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isSelected = selection.hasOption(group.id, option.id);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        key: ValueKey('class-equipment-option-${group.id}-${option.id}'),
        onTap: () => onChanged(
          selection.toggleOption(
            groupId: group.id,
            optionId: option.id,
            choose: group.choose,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.red : AppColors.outlineVariant,
            ),
            color: isSelected ? AppColors.surfaceContainerHigh : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: isSelected
                        ? AppColors.red
                        : AppColors.onDarkVariant,
                  ),
                  const SizedBox(width: 8),
                  // Expanded para o rótulo longo quebrar linha em tela
                  // pequena em vez de estourar a largura.
                  Expanded(
                    child: Text(option.label, style: text.bodyMedium),
                  ),
                ],
              ),
              if (option.note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 26, top: 4),
                  child: Text(
                    option.note,
                    style: text.bodySmall?.copyWith(
                      color: AppColors.onDarkVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              // Conteúdo do pacote: o jogador precisa ver que "armadura de
              // couro, arco longo e 20 flechas" são três itens antes de
              // escolher.
              if (option.items.length > 1 ||
                  (option.items.length == 1 && option.items.first.quantity > 1))
                Padding(
                  padding: const EdgeInsets.only(left: 26, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final item in option.items) _ItemLine(item: item),
                    ],
                  ),
                ),
              if (isSelected)
                for (final pick in option.picks)
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: _PickFields(
                      pick: pick,
                      pickKey: ClassEquipmentSelection.groupPickKey(
                        groupId: group.id,
                        optionId: option.id,
                        pickId: pick.id,
                      ),
                      weapons: weapons,
                      selection: selection,
                      onChanged: onChanged,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Os seletores de uma escolha complementar.
///
/// Um seletor por item pedido: "duas armas marciais" abre dois, e é isso que
/// permite escolher a mesma arma duas vezes quando o livro deixa.
class _PickFields extends StatelessWidget {
  const _PickFields({
    required this.pick,
    required this.pickKey,
    required this.weapons,
    required this.selection,
    required this.onChanged,
  });

  final ClassEquipmentPick pick;
  final String pickKey;
  final List<WeaponEntry> weapons;
  final ClassEquipmentSelection selection;
  final ValueChanged<ClassEquipmentSelection> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final options = pick.resolveOptions(weapons);
    final slots = selection.slotsFor(pickKey, pick.count);
    final filled = slots.whereType<String>().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          pick.count == 1
              ? pick.label
              : '${pick.label} — ${pick.progressLabel(filled)}',
          style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
        ),
        for (var index = 0; index < pick.count; index++)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DropdownButtonFormField<String>(
              key: ValueKey('class-equipment-pick-$pickKey-$index'),
              initialValue: slots[index],
              // Rótulos de arma e de pacote são longos; sem isto o dropdown
              // estoura a largura em tela pequena.
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                labelText: pick.count == 1
                    ? 'Selecione'
                    : 'Item ${index + 1} de ${pick.count}',
              ),
              items: [
                for (final option in _optionsFor(index, options, slots))
                  DropdownMenuItem<String>(
                    value: option.id,
                    child: Text(option.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) => onChanged(
                selection.withPick(
                  key: pickKey,
                  index: index,
                  count: pick.count,
                  itemId: value,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// As opções válidas para uma posição.
  ///
  /// Quando a mesma opção não pode repetir, o que já foi escolhido nas OUTRAS
  /// posições sai da lista — é o equivalente, em dropdown, ao bloqueio que o
  /// formulário de personalidade faz nas opções já usadas.
  List<ClassEquipmentItem> _optionsFor(
    int index,
    List<ClassEquipmentItem> options,
    List<String?> slots,
  ) {
    if (pick.allowDuplicates) return options;

    final used = <String>{};
    for (var i = 0; i < slots.length; i++) {
      if (i == index) continue;
      final value = slots[i];
      if (value != null) used.add(value);
    }

    return [
      for (final option in options)
        if (!used.contains(option.id)) option,
    ];
  }
}

/// Uma linha de item, com a quantidade e o destino na ficha.
class _ItemLine extends StatelessWidget {
  const _ItemLine({required this.item});

  final ClassEquipmentItem item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_iconFor(item.destination), size: 14, color: AppColors.onDarkVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            item.label,
            style: text.bodySmall?.copyWith(color: AppColors.onDark),
          ),
        ),
      ],
    );
  }

  static IconData _iconFor(EquipmentDestination destination) {
    switch (destination) {
      case EquipmentDestination.weapon:
        return Icons.sports_martial_arts;
      case EquipmentDestination.armor:
        return Icons.shield_outlined;
      case EquipmentDestination.inventory:
        return Icons.backpack_outlined;
    }
  }
}

/// Resumo do que vai para a ficha, separado por área de destino.
///
/// Existe para o jogador conferir antes de concluir, e usa a MESMA resolução
/// que a gravação (`ClassEquipmentGrants.resolve`): um resumo calculado por
/// outro caminho poderia mostrar algo diferente do que seria salvo.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.equipment,
    required this.weapons,
    required this.selection,
  });

  final ClassStartingEquipment equipment;
  final List<WeaponEntry> weapons;
  final ClassEquipmentSelection selection;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final resolved = ClassEquipmentGrants.resolve(
      equipment: equipment,
      selection: selection,
      weaponCatalog: weapons,
    );

    if (resolved.isEmpty) return const SizedBox.shrink();

    final byDestination = <EquipmentDestination, List<ClassEquipmentItem>>{};
    for (final entry in resolved) {
      byDestination.putIfAbsent(entry.destination, () => []).add(entry.item);
    }

    return Card(
      key: const ValueKey('class-equipment-summary'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo dos equipamentos', style: text.labelLarge),
            const SizedBox(height: 2),
            Text(
              'Já contando o que foi escolhido até agora.',
              style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
            ),
            for (final destination in EquipmentDestination.values)
              if (byDestination[destination]?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  _titleFor(destination),
                  style: text.bodySmall?.copyWith(color: AppColors.red),
                ),
                for (final item in byDestination[destination]!)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _ItemLine(item: item),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  static String _titleFor(EquipmentDestination destination) {
    switch (destination) {
      case EquipmentDestination.weapon:
        return 'Armas';
      case EquipmentDestination.armor:
        return 'Classe de Armadura';
      case EquipmentDestination.inventory:
        return 'Inventário';
    }
  }
}
