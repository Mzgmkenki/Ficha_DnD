import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageCharacterMagicItemsPage extends ConsumerStatefulWidget {
  const ManageCharacterMagicItemsPage({
    required this.characterId,
    super.key,
  });

  final String characterId;

  @override
  ConsumerState<ManageCharacterMagicItemsPage> createState() =>
      _ManageCharacterMagicItemsPageState();
}

class _ManageCharacterMagicItemsPageState
    extends ConsumerState<ManageCharacterMagicItemsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _chargesController = TextEditingController();
  final _maxChargesController = TextEditingController();
  final _rechargeRuleController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _chargesController.dispose();
    _maxChargesController.dispose();
    _rechargeRuleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterAsync = ref.watch(characterByIdProvider(widget.characterId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar itens mágicos'),
      ),
      body: characterAsync.when(
        data: (character) {
          if (character == null) {
            return const Center(child: Text('Personagem não encontrado.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CurrentItemsCard(character: character),
              const SizedBox(height: 16),
              _buildAddItemCard(context, character),
            ],
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text('Erro ao carregar personagem: $error'),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildAddItemCard(BuildContext context, Character character) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar item mágico',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do item',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do item.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final useColumn = constraints.maxWidth < 560;

                  final chargesField = TextFormField(
                    controller: _chargesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cargas atuais',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final parsed = int.tryParse(value.trim());
                      if (parsed == null) {
                        return 'Número inválido';
                      }
                      if (parsed < 0) {
                        return 'Use 0 ou mais';
                      }
                      return null;
                    },
                  );

                  final maxChargesField = TextFormField(
                    controller: _maxChargesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cargas máximas',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final parsed = int.tryParse(value.trim());
                      if (parsed == null) {
                        return 'Número inválido';
                      }
                      if (parsed < 0) {
                        return 'Use 0 ou mais';
                      }
                      return null;
                    },
                  );

                  if (useColumn) {
                    return Column(
                      children: [
                        chargesField,
                        const SizedBox(height: 12),
                        maxChargesField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: chargesField),
                      const SizedBox(width: 12),
                      Expanded(child: maxChargesField),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rechargeRuleController,
                decoration: const InputDecoration(
                  labelText: 'Regra de recarga',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : () => _saveItem(character),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  _saving ? 'Salvando item...' : 'Adicionar item mágico',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem(Character character) async {
    if (!_formKey.currentState!.validate()) return;

    final currentCharges = _parseNullableInt(_chargesController.text);
    final maxCharges = _parseNullableInt(_maxChargesController.text);

    if (currentCharges != null &&
        maxCharges != null &&
        currentCharges > maxCharges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As cargas atuais não podem ser maiores que as máximas.'),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final addItem = ref.read(addCharacterMagicItemProvider);

      await addItem(
        characterId: character.id,
        item: CharacterMagicItem(
          localId: 0,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          charges: currentCharges,
          maxCharges: maxCharges,
          rechargeRule: _emptyToNull(_rechargeRuleController.text),
          spells: const [],
        ),
      );

      _nameController.clear();
      _descriptionController.clear();
      _chargesController.clear();
      _maxChargesController.clear();
      _rechargeRuleController.clear();

      ref.invalidate(characterByIdProvider(character.id));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item mágico adicionado com sucesso.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar item mágico: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  int? _parseNullableInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _CurrentItemsCard extends ConsumerWidget {
  const _CurrentItemsCard({
    required this.character,
  });

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: character.magicItems.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itens atuais',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text('Nenhum item mágico cadastrado ainda.'),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itens atuais',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...character.magicItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(item.description),
                          ],
                          const SizedBox(height: 8),
                          if (item.maxCharges != null) ...[
                            Text(
                              'Cargas: ${item.charges ?? 0}/${item.maxCharges}',
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: (item.charges ?? 0) > 0
                                      ? () async {
                                          final updateCharges = ref.read(
                                            updateCharacterMagicItemChargesProvider,
                                          );

                                          await updateCharges(
                                            magicItemId: item.localId,
                                            charges: (item.charges ?? 0) - 1,
                                          );

                                          ref.invalidate(
                                            characterByIdProvider(character.id),
                                          );
                                        }
                                      : null,
                                  icon: const Icon(Icons.remove),
                                  label: const Text('Gastar 1'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: ((item.maxCharges ?? 0) > 0 &&
                                          (item.charges ?? 0) <
                                              (item.maxCharges ?? 0))
                                      ? () async {
                                          final updateCharges = ref.read(
                                            updateCharacterMagicItemChargesProvider,
                                          );

                                          await updateCharges(
                                            magicItemId: item.localId,
                                            charges: (item.charges ?? 0) + 1,
                                          );

                                          ref.invalidate(
                                            characterByIdProvider(character.id),
                                          );
                                        }
                                      : null,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Recuperar 1'),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    final updateCharges = ref.read(
                                      updateCharacterMagicItemChargesProvider,
                                    );

                                    await updateCharges(
                                      magicItemId: item.localId,
                                      charges: 0,
                                    );

                                    ref.invalidate(
                                      characterByIdProvider(character.id),
                                    );
                                  },
                                  child: const Text('Zerar'),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    final updateCharges = ref.read(
                                      updateCharacterMagicItemChargesProvider,
                                    );

                                    await updateCharges(
                                      magicItemId: item.localId,
                                      charges: item.maxCharges,
                                    );

                                    ref.invalidate(
                                      characterByIdProvider(character.id),
                                    );
                                  },
                                  child: const Text('Restaurar tudo'),
                                ),
                              ],
                            ),
                          ] else ...[
                            const Text('Este item não usa cargas.'),
                          ],
                          if (item.rechargeRule != null &&
                              item.rechargeRule!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Recarga: ${item.rechargeRule}'),
                          ],
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () async {
                              final deleteItem =
                                  ref.read(deleteCharacterMagicItemProvider);

                              await deleteItem(
                                magicItemId: item.localId,
                              );

                              ref.invalidate(
                                characterByIdProvider(character.id),
                              );
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Excluir item'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}