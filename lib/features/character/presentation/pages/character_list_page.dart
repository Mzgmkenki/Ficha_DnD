import 'package:dnd_ficha_app/core/routing/app_router.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/compendium/presentation/pages/spell_compendium_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterListPage extends ConsumerWidget {
  const CharacterListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(charactersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personagens'),
        actions: [
          IconButton(
            tooltip: 'Compêndio de magias',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SpellCompendiumPage(),
                ),
              );
            },
            icon: const Icon(Icons.menu_book),
          ),
        ],
      ),
      body: charactersAsync.when(
        data: (characters) {
          if (characters.isEmpty) {
            return const Center(
              child: Text('Nenhum personagem criado ainda.'),
            );
          }

          return ListView.separated(
            itemCount: characters.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final character = characters[index];

              return ListTile(
                title: Text(character.name),
                subtitle: Text(
                  'Nível ${character.totalLevel} • Proficiência +${character.proficiencyBonus}',
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.characterSheet,
                    arguments: character.id,
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Apagar personagem',
                  onPressed: () async {
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
                          content: Text(
                            'Personagem "${character.name}" apagado.',
                          ),
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
                  },
                ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.characterCreation);
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo personagem'),
      ),
    );
  }
}