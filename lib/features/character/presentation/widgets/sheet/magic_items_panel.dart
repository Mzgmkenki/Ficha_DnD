import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/character_spells_panel.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MagicItemsPanel extends ConsumerWidget {
  const MagicItemsPanel({
    required this.character,
    super.key,
  });

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spellsAsync = ref.watch(spellEntriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: spellsAsync.when(
          data: (spellEntries) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Itens Mágicos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (character.magicItems.isEmpty)
                  const Text('Nenhum item mágico cadastrado.')
                else
                  ...character.magicItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).dividerColor.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
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
                              if (item.maxCharges != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Cargas: ${item.charges ?? 0}/${item.maxCharges}',
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Gastar 1 carga',
                                      onPressed: (item.charges ?? 0) > 0
                                          ? () async {
                                              final updateCharges = ref.read(
                                                updateCharacterMagicItemChargesProvider,
                                              );

                                              await updateCharges(
                                                magicItemId: item.localId,
                                                charges:
                                                    (item.charges ?? 0) - 1,
                                              );

                                              ref.invalidate(
                                                characterByIdProvider(
                                                  character.id,
                                                ),
                                              );
                                            }
                                          : null,
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Recuperar 1 carga',
                                      onPressed: ((item.maxCharges ?? 0) > 0 &&
                                              (item.charges ?? 0) <
                                                  (item.maxCharges ?? 0))
                                          ? () async {
                                              final updateCharges = ref.read(
                                                updateCharacterMagicItemChargesProvider,
                                              );

                                              await updateCharges(
                                                magicItemId: item.localId,
                                                charges:
                                                    (item.charges ?? 0) + 1,
                                              );

                                              ref.invalidate(
                                                characterByIdProvider(
                                                  character.id,
                                                ),
                                              );
                                            }
                                          : null,
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        final updateCharges = ref.read(
                                          updateCharacterMagicItemChargesProvider,
                                        );

                                        if (value == 'zero') {
                                          await updateCharges(
                                            magicItemId: item.localId,
                                            charges: 0,
                                          );
                                        } else if (value == 'full') {
                                          await updateCharges(
                                            magicItemId: item.localId,
                                            charges: item.maxCharges,
                                          );
                                        } else if (value == 'delete') {
                                          final deleteItem = ref.read(
                                            deleteCharacterMagicItemProvider,
                                          );

                                          await deleteItem(
                                            magicItemId: item.localId,
                                          );
                                        }

                                        ref.invalidate(
                                          characterByIdProvider(character.id),
                                        );
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'zero',
                                          child: Text('Zerar cargas'),
                                        ),
                                        PopupMenuItem(
                                          value: 'full',
                                          child: Text('Restaurar ao máximo'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Excluir item'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                                const Text('Este item não usa cargas.'),
                              ],
                              if (item.rechargeRule != null &&
                                  item.rechargeRule!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('Recarga: ${item.rechargeRule}'),
                              ],
                              if (item.spells.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                ...item.spells.map(
                                  (spellLink) {
                                    final spell = spellEntries
                                        .where((s) => s.id == spellLink.spellId)
                                        .cast<SpellEntry?>()
                                        .firstWhere(
                                          (s) => s != null,
                                          orElse: () => null,
                                        );

                                    final spellName =
                                        spell?.namePt ??
                                            'Magia #${spellLink.spellId}';

                                    final subtitleParts = <String>[];
                                    if (spellLink.isAtWill) {
                                      subtitleParts.add('À vontade');
                                    }
                                    if (spellLink.usesCharges) {
                                      subtitleParts.add(
                                        '${spellLink.chargeCost} carga(s)',
                                      );
                                    }
                                    if (spellLink.isAlwaysAvailable) {
                                      subtitleParts.add('Sempre disponível');
                                    }

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: _ItemSpellCastTile(
                                        character: character,
                                        item: item,
                                        itemSpell: spellLink,
                                        spell: spell,
                                        spellName: spellName,
                                        subtitle: subtitleParts.join(' • '),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          error: (error, stackTrace) {
            return Text('Erro ao carregar itens mágicos: $error');
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _ItemSpellCastTile extends ConsumerWidget {
  const _ItemSpellCastTile({
    required this.character,
    required this.item,
    required this.itemSpell,
    required this.spell,
    required this.spellName,
    required this.subtitle,
  });

  final Character character;
  final CharacterMagicItem item;
  final CharacterMagicItemSpell itemSpell;
  final SpellEntry? spell;
  final String spellName;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useColumn = constraints.maxWidth < 520;

            final info = Expanded(
              child: InkWell(
                onTap: spell == null
                    ? null
                    : () => showSpellDetailsBottomSheet(context, spell!),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spellName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: spell == null
                              ? TextDecoration.none
                              : TextDecoration.underline,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );

            final actions = FilledButton.tonal(
              onPressed: () => _castItemSpell(context, ref),
              child: const Text('Conjurar'),
            );

            if (useColumn) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [info],
                  ),
                  const SizedBox(height: 8),
                  actions,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                info,
                const SizedBox(width: 12),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _castItemSpell(BuildContext context, WidgetRef ref) async {
    if (itemSpell.isAtWill || !itemSpell.usesCharges) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$spellName conjurada pelo item ${item.name} sem gastar cargas.',
          ),
        ),
      );
      return;
    }

    final currentCharges = item.charges ?? 0;
    final cost = itemSpell.chargeCost;

    if (currentCharges < cost) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'O item ${item.name} não possui cargas suficientes.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Conjurar $spellName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Origem'),
                subtitle: Text(item.name),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Custo'),
                subtitle: Text('$cost carga(s)'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cargas atuais'),
                subtitle: Text('${item.charges ?? 0}/${item.maxCharges ?? '-'}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Conjurar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final updateCharges = ref.read(updateCharacterMagicItemChargesProvider);

    await updateCharges(
      magicItemId: item.localId,
      charges: currentCharges - cost,
    );

    ref.invalidate(characterByIdProvider(character.id));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$spellName conjurada pelo item ${item.name}, consumindo $cost carga(s).',
        ),
      ),
    );
  }
}