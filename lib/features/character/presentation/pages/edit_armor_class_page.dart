import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Calcula a CA a partir de armadura + escudo + bônus, em vez de exigir que
/// o jogador faça a conta de cabeça e digite um número.
class EditArmorClassPage extends ConsumerStatefulWidget {
  const EditArmorClassPage({required this.character, super.key});

  final Character character;

  @override
  ConsumerState<EditArmorClassPage> createState() =>
      _EditArmorClassPageState();
}

class _EditArmorClassPageState extends ConsumerState<EditArmorClassPage> {
  String _armorId = 'none';
  bool _hasShield = false;
  int _otherBonus = 0;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final armor = ArmorOption.fromId(_armorId) ?? ArmorOption.all.first;
    final result = ArmorClassCalculator.calculate(
      armor: armor,
      abilityScores: widget.character.abilityScores,
      hasShield: _hasShield,
      otherBonus: _otherBonus,
    );

    final failsStrength = ArmorClassCalculator.failsStrengthRequirement(
      armor: armor,
      abilityScores: widget.character.abilityScores,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Calcular CA')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'CA ${result.total}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.explanation,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _armorId,
            decoration: const InputDecoration(labelText: 'Armadura'),
            items: ArmorOption.all
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(
                      item.category == ArmorCategory.none
                          ? item.name
                          : '${item.name} (${item.category.label})',
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _armorId = value);
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _hasShield,
            onChanged: (value) => setState(() => _hasShield = value),
            title: const Text('Escudo'),
            subtitle: const Text('+2 na CA'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text('Outros bônus (anel, manto, classe...)'),
              ),
              IconButton(
                onPressed: () => setState(() => _otherBonus--),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                _otherBonus >= 0 ? '+$_otherBonus' : '$_otherBonus',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: () => setState(() => _otherBonus++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          if (armor.stealthDisadvantage) ...[
            const SizedBox(height: 12),
            _Warning(
              text: 'Esta armadura impõe desvantagem em testes de '
                  'Furtividade.',
            ),
          ],
          if (failsStrength) ...[
            const SizedBox(height: 8),
            _Warning(
              text: 'Força insuficiente (requer '
                  '${armor.strengthRequirement}): deslocamento reduzido em 3 m.',
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : () => _save(result.total),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_saving ? 'Salvando...' : 'Salvar CA ${result.total}'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(int total) async {
    setState(() => _saving = true);

    try {
      await ref.read(characterRepositoryProvider).update(
            widget.character.copyWith(
              combatStats: widget.character.combatStats.copyWith(
                armorClass: total,
              ),
              updatedAt: DateTime.now(),
            ),
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar CA: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Warning extends StatelessWidget {
  const _Warning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning_amber_outlined, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
