import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Moedas do personagem, com ajuste rápido e total convertido em ouro.
class CurrencyPanel extends ConsumerWidget {
  const CurrencyPanel({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = character.currency;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Moedas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '${currency.totalInGold.toStringAsFixed(2)} PO',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _CoinRow(
              label: 'Platina (PL)',
              value: currency.platinum,
              onChanged: (v) => _save(ref, currency.copyWith(platinum: v)),
            ),
            _CoinRow(
              label: 'Ouro (PO)',
              value: currency.gold,
              onChanged: (v) => _save(ref, currency.copyWith(gold: v)),
            ),
            _CoinRow(
              label: 'Electro (PE)',
              value: currency.electrum,
              onChanged: (v) => _save(ref, currency.copyWith(electrum: v)),
            ),
            _CoinRow(
              label: 'Prata (PP)',
              value: currency.silver,
              onChanged: (v) => _save(ref, currency.copyWith(silver: v)),
            ),
            _CoinRow(
              label: 'Cobre (PC)',
              value: currency.copper,
              onChanged: (v) => _save(ref, currency.copyWith(copper: v)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(WidgetRef ref, Currency next) {
    return ref.read(characterRepositoryProvider).update(
          character.copyWith(currency: next, updatedAt: DateTime.now()),
        );
  }
}

class _CoinRow extends StatelessWidget {
  const _CoinRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          tooltip: 'Remover 1',
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline, size: 20),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: 'Adicionar 1',
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_circle_outline, size: 20),
        ),
        IconButton(
          tooltip: 'Definir valor',
          onPressed: () => _promptValue(context),
          icon: const Icon(Icons.edit_outlined, size: 20),
        ),
      ],
    );
  }

  Future<void> _promptValue(BuildContext context) async {
    final controller = TextEditingController(text: '$value');

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Quantidade'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              Navigator.of(dialogContext).pop(parsed);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null && result >= 0) onChanged(result);
  }
}
