import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/language_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Os idiomas do personagem na ficha.
///
/// Lê de `resolvedLanguagesProvider`, que é o mesmo ponto de verdade da tela
/// de edição: as duas não podem divergir. Nada de regra aqui — nem contagem
/// de vaga, nem decisão de o que é automático.
class LanguagesPanel extends ConsumerWidget {
  const LanguagesPanel({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(resolvedLanguagesProvider(character));

    return async.when(
      data: (resolved) => _body(context, resolved),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Carregando idiomas...'),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Não foi possível carregar os idiomas: $error'),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ResolvedLanguages resolved) {
    final text = Theme.of(context).textTheme;
    final all = resolved.all;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (all.isEmpty)
              Text(
                'Nenhum idioma registrado. Raça, antecedente e classe podem '
                'conceder idiomas.',
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              )
            else
              // Cada idioma aparece UMA vez, mesmo concedido por duas fontes:
              // as origens vêm todas na mesma linha.
              for (final language in all) _LanguageRow(language: language),

            if (resolved.hasPendingChoices) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      resolved.pendingCount == 1
                          ? 'Falta escolher 1 idioma adicional.'
                          : 'Faltam escolher ${resolved.pendingCount} '
                              'idiomas adicionais.',
                      key: const ValueKey('languages-pending'),
                      style: text.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],

            if (resolved.totalSlots > 0) ...[
              const SizedBox(height: 8),
              Text(
                resolved.progressLabel,
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Uma linha de idioma: nome, tipo, origem e escrita.
class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.language});

  final ResolvedLanguage language;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final entry = language.entry;

    final details = <String>[
      if (entry != null) entry.category.label,
      if (entry?.script case final script?) 'escrita $script',
    ];

    return Padding(
      key: ValueKey('language-row-${language.languageId}'),
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cadeado no automático, lápis no escolhido: a diferença importa
          // porque um pode ser trocado e o outro não.
          Icon(
            language.isAutomatic ? Icons.lock_outline : Icons.edit_outlined,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.displayName, style: text.bodyMedium),
                Text(
                  language.isAutomatic
                      ? 'automático — ${language.originLabel}'
                      : 'escolhido — ${language.originLabel}',
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
                if (details.isNotEmpty)
                  Text(
                    details.join(' • '),
                    style: text.bodySmall?.copyWith(
                      color: AppColors.onDarkVariant,
                    ),
                  ),
                if (entry == null)
                  Text(
                    'Id "${language.languageId}" não está no compêndio atual. '
                    'Mantido como dado da ficha.',
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
