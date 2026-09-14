import 'package:dnd_ficha_app/core/routing/app_navigator.dart';
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
        title: const Text('Personagens'),
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
                    leading: PortraitAvatar(
                      path: character.portraitPath,
                      size: 56,
                      // Sem legenda e sem borda vermelha: em miniatura o
                      // texto fica ilegível e várias bordas destacadas
                      // brigariam entre si na lista.
                      highlightWhenFilled: false,
                    ),
                    title: Text(
                      character.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        Text(_buildClassSummary(character, classes)),
                        const SizedBox(height: 2),
                        Text('Nível total ${character.totalLevel}'),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => AppNavigator.toCharacterSheet(
                      context,
                      characterId: character.id,
                    ),
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
                          final deleteCharacter =
                              ref.read(deleteCharacterProvider);
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
                              content: Text(
                                'Erro ao apagar personagem: $error',
                              ),
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