import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassFeaturesPanel extends ConsumerWidget {
  const ClassFeaturesPanel({
    required this.classLevels,
    super.key,
  });

  final List<ClassLevel> classLevels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Características de Classe',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (classLevels.isEmpty)
              const Text('Nenhuma classe cadastrada para este personagem.')
            else
              ...classLevels.map(
                (classLevel) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _SingleClassFeatureBlock(classLevel: classLevel),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SingleClassFeatureBlock extends ConsumerWidget {
  const _SingleClassFeatureBlock({
    required this.classLevel,
  });

  final ClassLevel classLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(classLevel.classId));
    final featuresAsync = ref.watch(
      classFeaturesByClassAndLevelProvider(
        (classId: classLevel.classId, level: classLevel.level),
      ),
    );

    return classAsync.when(
      data: (classEntry) {
        final className = classEntry?.name ?? classLevel.classId;

        return featuresAsync.when(
          data: (entries) {
            final rows = <({String feature, int level})>[];

            for (final entry in entries) {
              for (final feature in entry.features) {
                final trimmed = feature.trim();
                if (trimmed.isNotEmpty) {
                  rows.add((feature: trimmed, level: entry.level));
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$className • Nível ${classLevel.level}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (rows.isEmpty)
                  const Text('Nenhuma característica cadastrada para este nível.')
                else
                  ...rows.map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(
                            child: Text(
                              '${row.feature} (Nível ${row.level})',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
          error: (error, stackTrace) {
            return Text('Erro ao carregar características: $error');
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stackTrace) {
        return Text('Erro ao carregar classe: $error');
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: CircularProgressIndicator(),
      ),
    );
  }
}