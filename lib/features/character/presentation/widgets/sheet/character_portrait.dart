import 'package:dnd_ficha_app/core/storage/portrait_storage.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/portrait_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _PortraitAction { pick, remove }

/// Imagem de aparência do personagem, no cabeçalho da ficha.
///
/// Sem imagem, mostra um espaço convidando ao upload. Tocar abre as opções
/// de escolher (pelo gerenciador de arquivos) e remover.
class CharacterPortrait extends ConsumerStatefulWidget {
  const CharacterPortrait({
    required this.characterId,
    required this.portraitPath,
    this.size = 78,
    super.key,
  });

  final String characterId;
  final String? portraitPath;
  final double size;

  @override
  ConsumerState<CharacterPortrait> createState() => _CharacterPortraitState();
}

class _CharacterPortraitState extends ConsumerState<CharacterPortrait> {
  bool _busy = false;

  bool get _hasPortrait =>
      widget.portraitPath != null && widget.portraitPath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _hasPortrait
          ? 'Imagem do personagem. Toque para trocar ou remover.'
          : 'Sem imagem do personagem. Toque para escolher uma.',
      button: true,
      child: Tooltip(
        message: _hasPortrait ? 'Trocar imagem' : 'Adicionar imagem',
        child: InkWell(
          onTap: _busy ? null : _openOptions,
          borderRadius: BorderRadius.circular(12),
          child: _busy
              ? _Loading(size: widget.size)
              : PortraitAvatar(
                  path: widget.portraitPath,
                  size: widget.size,
                  emptyLabel: 'imagem',
                ),
        ),
      ),
    );
  }

  Future<void> _openOptions() async {
    final action = await showModalBottomSheet<_PortraitAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_open, color: AppColors.red),
                title: Text(
                  _hasPortrait ? 'Trocar imagem' : 'Escolher imagem',
                ),
                subtitle: const Text('Abre o gerenciador de arquivos'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PortraitAction.pick),
              ),
              if (_hasPortrait)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.red,
                  ),
                  title: const Text('Remover imagem'),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_PortraitAction.remove),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (action == null || !mounted) return;

    switch (action) {
      case _PortraitAction.pick:
        await _pick();
      case _PortraitAction.remove:
        await _remove();
    }
  }

  Future<void> _pick() async {
    setState(() => _busy = true);

    try {
      final useCase = ref.read(updateCharacterPortraitProvider);
      final saved = await useCase.pick(characterId: widget.characterId);

      if (!mounted || !saved) return;
      _notify('Imagem atualizada.');
    } on PortraitException catch (error) {
      if (!mounted) return;
      _notify(error.message);
    } catch (error) {
      if (!mounted) return;
      _notify('Erro ao salvar a imagem: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    setState(() => _busy = true);

    try {
      final useCase = ref.read(updateCharacterPortraitProvider);
      await useCase.remove(characterId: widget.characterId);

      if (!mounted) return;
      _notify('Imagem removida.');
    } catch (error) {
      if (!mounted) return;
      _notify('Erro ao remover a imagem: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}
