import 'dart:io';

import 'package:dnd_ficha_app/core/storage/portrait_storage.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
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
    const radius = BorderRadius.all(Radius.circular(12));

    return Semantics(
      label: _hasPortrait
          ? 'Imagem do personagem. Toque para trocar ou remover.'
          : 'Sem imagem do personagem. Toque para escolher uma.',
      button: true,
      child: Tooltip(
        message: _hasPortrait ? 'Trocar imagem' : 'Adicionar imagem',
        // A borda vem do `shape` do Material, não de um Container por cima:
        // fundo opaco dentro do InkWell esconderia o efeito de toque.
        child: Material(
          color: AppColors.surfaceContainerHigh,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: _hasPortrait ? AppColors.red : AppColors.outline,
              width: _hasPortrait ? 1.4 : 1,
            ),
          ),
          child: InkWell(
            onTap: _busy ? null : _openOptions,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: _busy ? const _Loading() : _content(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (!_hasPortrait) return const _Placeholder();

    // `cacheWidth` limita a decodificação ao tamanho que aparece na tela:
    // sem isso, a foto de 12 MP do celular seria decodificada inteira na
    // memória só para desenhar um quadrado de 78 px.
    final pixels =
        (widget.size * MediaQuery.devicePixelRatioOf(context)).round();

    return Image.file(
      File(widget.portraitPath!),
      fit: BoxFit.cover,
      width: widget.size,
      height: widget.size,
      cacheWidth: pixels,
      filterQuality: FilterQuality.medium,
      // O arquivo mora no diretório do app, mas o jogador pode ter limpado
      // os dados ou restaurado um backup sem ele. Cair no placeholder é
      // melhor que a ficha inteira quebrar com exceção de render.
      errorBuilder: (context, error, stackTrace) => const _Placeholder(
        broken: true,
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
                leading: const Icon(
                  Icons.folder_open,
                  color: AppColors.red,
                ),
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

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.broken = false});

  /// Havia um caminho salvo, mas o arquivo não abriu.
  final bool broken;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          broken ? Icons.broken_image_outlined : Icons.person_outline,
          color: AppColors.onDarkVariant,
          size: 26,
        ),
        const SizedBox(height: 2),
        Text(
          broken ? 'sem arquivo' : 'imagem',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}
