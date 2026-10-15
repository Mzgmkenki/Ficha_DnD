import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_selection.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_catalog.dart';
import 'package:flutter/material.dart';

/// Valor devolvido pelo seletor quando o jogador escolhe limpar a vaga.
const String languagePickerClearValue = '__clear__';

/// Seleção de idiomas: os automáticos, as vagas e as pendências.
///
/// Usado pela etapa de criação e pela tela de edição, com o mesmo
/// comportamento nas duas. O widget não decide regra nenhuma: ele recebe
/// [resolved] já calculado e devolve a intenção do jogador pelos callbacks.
class LanguageSelectionForm extends StatefulWidget {
  const LanguageSelectionForm({
    required this.catalog,
    required this.resolved,
    required this.onChoose,
    required this.onClear,
    this.margin = EdgeInsets.zero,
    this.showAutomatic = true,
    super.key,
  });

  final LanguageCatalog catalog;
  final ResolvedLanguages resolved;

  /// Chamado com a vaga e o idioma escolhido.
  final void Function(LanguageSlot slot, String languageId) onChoose;

  /// Chamado quando a vaga é liberada.
  final void Function(LanguageSlot slot) onClear;

  final EdgeInsetsGeometry margin;

  /// Se mostra o bloco de idiomas automáticos. A ficha já os lista em cima.
  final bool showAutomatic;

  @override
  State<LanguageSelectionForm> createState() => _LanguageSelectionFormState();
}

class _LanguageSelectionFormState extends State<LanguageSelectionForm> {
  /// Se os idiomas de cenário e de fonte específica entram na lista.
  ///
  /// Desligado por padrão porque o levantamento manda não poluir a lista
  /// comum com eles. Não é persistido: ligar o filtro não é uma decisão da
  /// ficha, é uma preferência de busca do momento.
  bool _includeGated = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final resolved = widget.resolved;

    return Padding(
      padding: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showAutomatic) ...[
            Text('Idiomas automáticos', style: text.titleSmall),
            const SizedBox(height: 4),
            if (resolved.automatic.isEmpty)
              Text(
                'Nenhuma das suas origens concede idioma automaticamente.',
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              )
            else ...[
              Text(
                'Concedidos pela sua origem. Não podem ser removidos enquanto '
                'a fonte estiver ativa.',
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              ),
              const SizedBox(height: 6),
              for (final language in resolved.automatic)
                _AutomaticLanguageRow(language: language),
            ],
            const SizedBox(height: 16),
          ],

          Text('Idiomas adicionais', style: text.titleSmall),
          const SizedBox(height: 4),

          if (resolved.totalSlots == 0)
            Text(
              'Suas origens não dão idiomas à escolha.',
              style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
            )
          else ...[
            Text(
              resolved.progressLabel,
              key: const ValueKey('language-progress'),
              style: text.bodyMedium?.copyWith(
                // Mesma régua do resto da criação: vermelho enquanto falta,
                // neutro quando fecha.
                color: resolved.hasPendingChoices
                    ? AppColors.error
                    : AppColors.onDarkVariant,
              ),
            ),
            if (resolved.hasPendingChoices) ...[
              const SizedBox(height: 2),
              Text(
                'Faltam ${resolved.pendingCount}. A criação não conclui com '
                'escolha pendente.',
                style: text.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 8),
            for (final slot in resolved.slots)
              _SlotTile(
                slot: slot,
                catalog: widget.catalog,
                resolved: resolved,
                includeGated: _includeGated,
                onPick: () => _pick(slot),
                onClear: () => widget.onClear(slot),
              ),
            const SizedBox(height: 4),
            SwitchListTile(
              key: const ValueKey('language-include-gated'),
              value: _includeGated,
              onChanged: (value) => setState(() => _includeGated = value),
              title: const Text('Incluir idiomas de cenário'),
              subtitle: const Text(
                'Regionais de Faerûn, Eberron, Ravnica e Wildemount. Combine '
                'com o seu Mestre.',
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pick(LanguageSlot slot) async {
    final picked = await showLanguagePickerSheet(
      context: context,
      slot: slot,
      catalog: widget.catalog,
      resolved: widget.resolved,
      includeGated: _includeGated,
    );

    if (picked == null || !mounted) return;

    if (picked == languagePickerClearValue) {
      widget.onClear(slot);
      return;
    }

    widget.onChoose(slot, picked);
  }
}

/// Um idioma concedido automaticamente.
class _AutomaticLanguageRow extends StatelessWidget {
  const _AutomaticLanguageRow({required this.language});

  final ResolvedLanguage language;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final entry = language.entry;

    return Padding(
      key: ValueKey('language-automatic-${language.languageId}'),
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.displayName, style: text.bodyMedium),
                Text(
                  // A origem é o que o levantamento pede exibir: "Comum —
                  // concedido pela raça".
                  'concedido por ${language.originLabel}',
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
                if (entry != null)
                  Text(
                    _detailsOf(entry),
                    style: text.bodySmall?.copyWith(
                      color: AppColors.onDarkVariant,
                    ),
                  )
                else
                  Text(
                    'Este idioma não está mais no compêndio e ficou como dado '
                    'da ficha.',
                    style: text.bodySmall?.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Categoria e escrita numa linha. Escrita ausente simplesmente não aparece:
/// "não especificado na fonte" é informação de catálogo, não de ficha.
String _detailsOf(LanguageEntry entry) {
  final parts = <String>[
    entry.category.label,
    if (entry.script case final script?) 'escrita $script',
  ];
  return parts.join(' • ');
}

/// Uma vaga: mostra o que está nela e abre o seletor.
class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.catalog,
    required this.resolved,
    required this.includeGated,
    required this.onPick,
    required this.onClear,
  });

  final LanguageSlot slot;
  final LanguageCatalog catalog;
  final ResolvedLanguages resolved;
  final bool includeGated;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final chosenId = resolved.filledSlots[slot.id];
    final chosen = catalog.byId(chosenId);

    final options = LanguageSelection.optionsFor(
      slot: slot,
      catalog: catalog,
      resolved: resolved,
      includeGated: includeGated,
    );
    final available = options.where((item) => item.isEnabled).length;

    return Card(
      key: ValueKey('language-slot-${slot.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        title: Text(
          chosen?.name ?? slot.label,
          style: text.bodyLarge?.copyWith(
            color: chosen == null ? AppColors.onDarkVariant : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(slot.description, style: text.bodySmall),
            if (chosen == null)
              Text(
                available == 0
                    ? 'Nenhuma opção disponível para esta vaga.'
                    : '$available opção(ões) disponível(is).',
                style: text.bodySmall?.copyWith(
                  color: available == 0
                      ? AppColors.error
                      : AppColors.onDarkVariant,
                ),
              ),
          ],
        ),
        trailing: chosen == null
            ? const Icon(Icons.add_circle_outline)
            : IconButton(
                key: ValueKey('language-clear-${slot.id}'),
                tooltip: 'Liberar a vaga',
                onPressed: onClear,
                icon: const Icon(Icons.close),
              ),
        onTap: available == 0 && chosen == null ? null : onPick,
      ),
    );
  }
}

/// Abre o seletor de idioma de uma vaga.
///
/// Folha inferior em vez de diálogo porque a lista é longa e o campo de busca
/// convive com o teclado: num celular, um diálogo com 60 itens e teclado
/// aberto fica sem espaço para nada.
///
/// Devolve o id escolhido, [languagePickerClearValue] para liberar a vaga, ou
/// nulo se o jogador desistir.
Future<String?> showLanguagePickerSheet({
  required BuildContext context,
  required LanguageSlot slot,
  required LanguageCatalog catalog,
  required ResolvedLanguages resolved,
  bool includeGated = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _LanguagePickerSheet(
      slot: slot,
      catalog: catalog,
      resolved: resolved,
      includeGated: includeGated,
    ),
  );
}

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet({
    required this.slot,
    required this.catalog,
    required this.resolved,
    required this.includeGated,
  });

  final LanguageSlot slot;
  final LanguageCatalog catalog;
  final ResolvedLanguages resolved;
  final bool includeGated;

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final chosenId = widget.resolved.filledSlots[widget.slot.id];

    final options = LanguageSelection.optionsFor(
      slot: widget.slot,
      catalog: widget.catalog,
      resolved: widget.resolved,
      includeGated: widget.includeGated,
      query: _query,
    );

    return Padding(
      // A folga do teclado entra aqui: sem ela o campo de busca fica atrás
      // dele assim que recebe foco.
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.slot.label, style: text.titleMedium),
          const SizedBox(height: 2),
          Text(
            widget.slot.description,
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('language-search'),
            controller: _searchController,
            autofocus: false,
            decoration: const InputDecoration(
              labelText: 'Buscar idioma',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: options.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Nenhum idioma corresponde à busca.',
                      style: text.bodySmall,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];

                      return ListTile(
                        key: ValueKey(
                          'language-option-${option.language.id}',
                        ),
                        enabled: option.isEnabled,
                        selected: option.isSelected,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(option.language.displayName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(option.details, style: text.bodySmall),
                            // O motivo do bloqueio aparece junto da opção, e
                            // não num aviso solto: é onde o jogador está
                            // olhando quando a opção não responde.
                            if (option.blockReason case final reason?)
                              Text(
                                reason,
                                style: text.bodySmall?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                          ],
                        ),
                        trailing: option.isSelected
                            ? const Icon(Icons.check)
                            : null,
                        onTap: option.isEnabled
                            ? () => Navigator.of(context).pop(
                                  option.language.id,
                                )
                            : null,
                      );
                    },
                  ),
          ),
          if (chosenId != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              key: const ValueKey('language-picker-clear'),
              onPressed: () => Navigator.of(context).pop(
                languagePickerClearValue,
              ),
              icon: const Icon(Icons.close),
              label: const Text('Liberar esta vaga'),
            ),
          ],
        ],
      ),
    );
  }
}
