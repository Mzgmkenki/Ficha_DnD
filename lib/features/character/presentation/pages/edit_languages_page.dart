import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/language_providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_character_languages.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_resolver.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/language_selection_form.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Edição de idiomas depois da criação.
///
/// Grava a cada toque, em vez de ter um botão "salvar": a escolha é uma só
/// decisão, e o resto da ficha já funciona assim. Cada gravação passa pelo
/// caso de uso, que revalida — a tela não é a única barreira.
class EditLanguagesPage extends ConsumerStatefulWidget {
  const EditLanguagesPage({required this.character, super.key});

  final Character character;

  @override
  ConsumerState<EditLanguagesPage> createState() => _EditLanguagesPageState();
}

class _EditLanguagesPageState extends ConsumerState<EditLanguagesPage> {
  bool _busy = false;

  /// Se a conciliação pós-troca de origem já foi feita nesta visita.
  ///
  /// Uma vez por abertura: a conciliação grava, a gravação reemite o
  /// personagem, e sem esta trava o recálculo entraria em laço.
  bool _reconciled = false;

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(languageCatalogProvider);
    final resolvedAsync = ref.watch(
      resolvedLanguagesProvider(widget.character),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Idiomas')),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Erro ao carregar o catálogo de idiomas: $error'),
          ),
        ),
        data: (catalog) => resolvedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Erro ao resolver os idiomas: $error'),
            ),
          ),
          data: (resolved) => _body(catalog, resolved),
        ),
      ),
    );
  }

  Widget _body(LanguageCatalog catalog, ResolvedLanguages resolved) {
    final text = Theme.of(context).textTheme;

    // Trocou raça, classe ou antecedente desde a última visita: as escolhas
    // sem vaga saem agora, e o jogador é avisado do que saiu.
    if (!_reconciled && resolved.droppedSelections.isNotEmpty) {
      _reconciled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reconcile();
      });
    }

    return ListView(
      padding: context.scrollContentPadding(),
      children: [
        Text(
          'Idiomas vêm da raça, da sub-raça, do antecedente, da classe, da '
          'subclasse e de talentos. O que é automático não pode ser removido '
          'enquanto a fonte estiver ativa.',
          style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
        ),
        const SizedBox(height: 16),
        if (_busy) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
        ],
        LanguageSelectionForm(
          catalog: catalog,
          resolved: resolved,
          onChoose: (slot, languageId) => _choose(slot.id, languageId),
          onClear: (slot) => _clear(slot.id),
        ),
      ],
    );
  }

  Future<void> _choose(String slotId, String languageId) async {
    await _run((manager, catalog, sources) {
      return manager.choose(
        characterId: widget.character.id,
        slotId: slotId,
        languageId: languageId,
        catalog: catalog,
        sources: sources,
      );
    });
  }

  Future<void> _clear(String slotId) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(manageCharacterLanguagesProvider).clearSlot(
            characterId: widget.character.id,
            slotId: slotId,
          );
    } catch (error) {
      _notify('Não deu para liberar a vaga: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reconcile() async {
    try {
      final catalog = await ref.read(languageCatalogProvider.future);
      final bundle = await ref.read(
        languageSourcesProvider(widget.character).future,
      );

      final removed = await ref.read(manageCharacterLanguagesProvider).reconcile(
            characterId: widget.character.id,
            catalog: catalog,
            sources: bundle.sources,
          );

      if (removed.isEmpty || !mounted) return;

      final names = removed
          .map((item) => catalog.byId(item.languageId)?.name ?? item.languageId)
          .join(', ');

      _notify(
        removed.length == 1
            ? 'O idioma $names perdeu a origem e foi removido.'
            : 'Estes idiomas perderam a origem e foram removidos: $names.',
      );
    } catch (error) {
      _notify('Não deu para recalcular os idiomas: $error');
    }
  }

  Future<void> _run(
    Future<void> Function(
      ManageCharacterLanguages manager,
      LanguageCatalog catalog,
      List<LanguageGrantSource> sources,
    ) action,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final catalog = await ref.read(languageCatalogProvider.future);
      final bundle = await ref.read(
        languageSourcesProvider(widget.character).future,
      );

      await action(
        ref.read(manageCharacterLanguagesProvider),
        catalog,
        bundle.sources,
      );
    } catch (error) {
      // `ArgumentError` traz a frase do domínio pronta; mostrar só ela evita
      // despejar o nome da classe de exceção na cara do jogador.
      final message = error is ArgumentError
          ? '${error.message}'
          : 'Não deu para gravar o idioma: $error';
      _notify(message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
