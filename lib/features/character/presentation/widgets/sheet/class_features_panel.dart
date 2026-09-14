import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/subclass_summary.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
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
            // Título fica no cabeçalho da seção, na ficha.
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
                _SubclassBlock(classLevel: classLevel, classEntry: classEntry),
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

/// Bloco da subclasse dentro do painel de características de classe.
///
/// Fica junto da classe de propósito: numa multiclasse cada classe tem o
/// próprio arquétipo, e separar em outra seção obrigaria o jogador a cruzar as
/// duas listas na cabeça.
class _SubclassBlock extends ConsumerWidget {
  const _SubclassBlock({required this.classLevel, required this.classEntry});

  final ClassLevel classLevel;
  final ClassEntry? classEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = classEntry;
    if (entry == null) return const SizedBox.shrink();

    final requiredLevel = entry.subclassLevel;
    if (requiredLevel == null) return const SizedBox.shrink();

    final label = entry.subclassLabelOrDefault;
    final text = Theme.of(context).textTheme;

    if (classLevel.level < requiredLevel) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '$label: abre no $requiredLevelº nível.',
          style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
        ),
      );
    }

    final subclassId = classLevel.subclassId;
    if (subclassId == null || subclassId.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '$label ainda não escolhido. Toque em editar classes para definir.',
          style: text.bodySmall?.copyWith(color: AppColors.error),
        ),
      );
    }

    final subclassAsync = ref.watch(subclassByIdProvider(subclassId));

    return subclassAsync.when(
      data: (subclass) {
        if (subclass == null) {
          // Acontece se o compêndio mudar e o id salvo sair da lista.
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$label "$subclassId" não está mais no compêndio.',
              style: text.bodySmall?.copyWith(color: AppColors.error),
            ),
          );
        }

        return SubclassSummary(
          subclass: subclass,
          level: classLevel.level,
        );
      },
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text('Erro ao carregar $label: $error'),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
    );
  }
}
