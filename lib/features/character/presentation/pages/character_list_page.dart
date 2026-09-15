import 'package:dnd_ficha_app/core/branding/app_logo.dart';
import 'package:dnd_ficha_app/core/routing/app_navigator.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/portrait_avatar.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterListPage extends ConsumerWidget {
  const CharacterListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(charactersProvider);
    final classesAsync = ref.watch(classEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        // A logo entra ao lado do título, não no lugar dele: sozinha ela não
        // diz em que tela o jogador está.
        title: const Row(
          children: [
            // Só a marca aqui: o wordmark da logo cheia não se lê a 28 px.
            AppLogo(height: 30, preferIconOnly: true),
            SizedBox(width: 10),
            Text('Personagens'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Exportar e importar',
            onPressed: () => AppNavigator.toCharacterTransfer(context),
            icon: const Icon(Icons.swap_vert),
          ),
          IconButton(
            tooltip: 'Compêndio de magias',
            onPressed: () => AppNavigator.toSpellCompendium(context),
            icon: const Icon(Icons.menu_book),
          ),
        ],
      ),
      body: classesAsync.when(
        data: (classes) {
          return charactersAsync.when(
            data: (characters) {
              if (characters.isEmpty) {
                // Tela vazia é onde a marca respira: não há conteúdo para
                // competir com ela.
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLogo(height: 120, opacity: 0.5),
                      const SizedBox(height: 20),
                      Text(
                        'Nenhum personagem criado ainda.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Toque em Novo personagem para começar.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.onDarkVariant),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                // O espaço embaixo é para o FAB não cobrir o último cartão.
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: characters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final character = characters[index];

                  return _CharacterCard(
                    character: character,
                    classSummary: _buildClassSummary(character, classes),
                    onOpen: () => AppNavigator.toCharacterSheet(
                      context,
                      characterId: character.id,
                    ),
                    onDelete: () => _confirmAndDelete(context, ref, character),
                  );
                },
              );
            },
            error: (error, stackTrace) {
              return Center(
                child: Text('Erro ao carregar personagens: $error'),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text('Erro ao carregar classes: $error'),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppNavigator.toCharacterCreation(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo personagem'),
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    Character character,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Apagar personagem'),
          content: Text(
            'Deseja apagar "${character.name}"? Essa ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final deleteCharacter = ref.read(deleteCharacterProvider);
      await deleteCharacter(character.id);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Personagem "${character.name}" apagado.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao apagar personagem: $error'),
        ),
      );
    }
  }

  String _buildClassSummary(Character character, List<ClassEntry> classes) {
    if (character.classLevels.isEmpty) {
      return 'Sem classe';
    }

    return character.classLevels.map((classLevel) {
      final className = _classNameForId(classes, classLevel.classId);
      return '$className Nv. ${classLevel.level}';
    }).join(' • ');
  }

  String _classNameForId(List<ClassEntry> classes, String classId) {
    for (final item in classes) {
      if (item.id == classId) {
        return item.name;
      }
    }
    return classId;
  }
}

/// Cartão do personagem: retrato largo em cima, identificação embaixo.
///
/// O retrato ocupa a largura inteira do cartão de propósito — é o que o
/// jogador reconhece de relance, e no quadradinho antigo não dava para ver
/// nada da imagem.
class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.classSummary,
    required this.onOpen,
    required this.onDelete,
  });

  final Character character;
  final String classSummary;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PortraitBanner(
              path: character.portraitPath,
              // Quem tem foto ganha o retrato grande; quem não tem fica com
              // uma faixa curta, senão a lista viraria uma sequência de
              // retângulos vazios.
              emptyHeight: 96,
              emptyLabel: 'sem imagem',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(character.name, style: text.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          classSummary,
                          style: text.bodyMedium?.copyWith(
                            color: AppColors.onDarkVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Nível total ${character.totalLevel}',
                          style: text.bodySmall?.copyWith(
                            color: AppColors.onDarkVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Apagar personagem',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
