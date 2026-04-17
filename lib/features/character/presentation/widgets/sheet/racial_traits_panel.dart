import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RacialTraitsPanel extends ConsumerWidget {
  const RacialTraitsPanel({
    required this.speciesId,
    super.key,
  });

  final String? speciesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (speciesId == null || speciesId!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Nenhuma raça vinculada ao personagem.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final raceAsync = ref.watch(raceByIdProvider(speciesId!));

    return raceAsync.when(
      data: (race) {
        if (race == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Raça não encontrada no compêndio.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Características Raciais',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  race.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                if (race.traits.isEmpty)
                  const Text('Nenhuma característica racial cadastrada.')
                else
                  ...race.traits.map(
                    (trait) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(trait)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Erro ao carregar características raciais: $error'),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}