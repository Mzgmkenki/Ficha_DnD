import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exibe o antecedente do personagem e o que ele concede.
class BackgroundPanel extends ConsumerWidget {
  const BackgroundPanel({
    required this.backgroundId,
    this.customBackground = const CustomBackground(),
    super.key,
  });

  final String? backgroundId;

  /// Dados do antecedente criado pelo jogador, usados quando [backgroundId]
  /// é [BackgroundEntry.customId].
  final CustomBackground customBackground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (backgroundId == null || backgroundId!.trim().isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nenhum antecedente definido.'),
        ),
      );
    }

    // O antecedente customizável não existe no compêndio: os dados vêm do
    // próprio personagem.
    if (backgroundId == BackgroundEntry.customId) {
      return _CustomBackgroundCard(customBackground: customBackground);
    }

    final backgroundAsync = ref.watch(backgroundByIdProvider(backgroundId!));

    return backgroundAsync.when(
      data: (background) {
        if (background == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Antecedente não encontrado: $backgroundId'),
            ),
          );
        }

        final skills = background.skills.map((s) => s.label).join(', ');

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  background.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (background.description != null) ...[
                  const SizedBox(height: 6),
                  Text(background.description!),
                ],
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Perícias: $skills',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (background.tools.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ferramentas: ${background.tools.join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (background.languages > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Idiomas adicionais: ${background.languages}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (background.featureName != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    background.featureName!,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  if (background.featureDescription != null) ...[
                    const SizedBox(height: 2),
                    Text(background.featureDescription!),
                  ],
                ],
              ],
            ),
          ),
        );
      },
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Erro ao carregar antecedente: $error'),
        ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

/// Antecedente montado pelo jogador, guardado na própria ficha.
class _CustomBackgroundCard extends StatelessWidget {
  const _CustomBackgroundCard({required this.customBackground});

  final CustomBackground customBackground;

  @override
  Widget build(BuildContext context) {
    final skills = customBackground.skills.map((s) => s.label).join(', ');
    final features = customBackground.features.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customBackground.displayName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Antecedente criado pelo jogador.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Perícias: $skills',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Características',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 2),
            Text(
              features.isEmpty
                  ? 'Nenhuma característica descrita.'
                  : features,
            ),
          ],
        ),
      ),
    );
  }
}
