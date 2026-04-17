import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
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
                            const SizedBox(height: 4),
                            Text(
                              'Cargas: ${item.charges ?? 0}/${item.maxCharges}',
                            ),
                          ],
                          if (item.rechargeRule != null &&
                              item.rechargeRule!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Recarga: ${item.rechargeRule}'),
                          ],
                          if (item.spells.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ...item.spells.map(
                              (spellLink) {
                                final spell = spellEntries
                                    .where((s) => s.id == spellLink.spellId)
                                    .cast<dynamic>()
                                    .firstWhere(
                                      (s) => s != null,
                                      orElse: () => null,
                                    );

                                final spellName =
                                    spell?.namePt ?? 'Magia #${spellLink.spellId}';

                                final extra = spellLink.isAtWill
                                    ? 'À vontade'
                                    : spellLink.usesCharges
                                        ? '${spellLink.chargeCost} carga(s)'
                                        : 'Disponível';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• '),
                                      Expanded(
                                        child: Text('$spellName • $extra'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
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