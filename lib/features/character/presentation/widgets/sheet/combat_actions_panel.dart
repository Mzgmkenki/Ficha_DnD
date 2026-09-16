import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/combat_options_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_option.dart';
import 'package:dnd_ficha_app/features/character/domain/services/combat_options_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/turn_possibilities.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A economia do turno traduzida na build atual.
///
/// Informativa por ora: mostra usos máximos e a regra de recarga em vez de um
/// contador de usos restantes, porque o app só persiste consumo de espaço de
/// magia e de carga de item. Marcar como gasto sem ter onde gravar daria a
/// impressão de controle que não existe.
class CombatActionsPanel extends ConsumerWidget {
  const CombatActionsPanel({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(combatOptionsProvider(character));

    return async.when(
      data: (options) => _Content(options: options),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Erro ao montar as ações: $error'),
        ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.options});

  final CombatOptions options;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final possibilities = TurnPossibilities.from(options);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (options.attacksPerAction > 1) ...[
              Text(
                'A ação de Atacar rende ${options.attacksPerAction} ataques.',
                style: text.labelLarge,
              ),
              const SizedBox(height: 12),
            ],

            for (final type in CombatActionType.values)
              if (options[type].isNotEmpty)
                _ActionGroup(type: type, options: options[type]),

            if (possibilities.isNotEmpty) ...[
              const Divider(height: 24),
              Text('Possibilidades para este turno', style: text.titleSmall),
              const SizedBox(height: 4),
              Text(
                'Sugestões do que a economia de ações permite combinar. Não há '
                'uma jogada certa.',
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              ),
              const SizedBox(height: 8),
              for (final item in possibilities)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: text.labelLarge),
                      Text(item.steps.join('  →  ')),
                      Text(
                        item.rationale,
                        style: text.bodySmall?.copyWith(
                          color: AppColors.onDarkVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Um grupo de opções do mesmo tipo de ação.
class _ActionGroup extends StatelessWidget {
  const _ActionGroup({required this.type, required this.options});

  final CombatActionType type;
  final List<CombatOption> options;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final blocked = options.where((item) => !item.isAvailable).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(type.label, style: text.titleSmall)),
              Text(
                '${options.length - blocked} de ${options.length}',
                style: text.labelSmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              ),
            ],
          ),
          Text(
            type.economyNote,
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
          const SizedBox(height: 4),
          for (final option in options) _OptionTile(option: option),
        ],
      ),
    );
  }
}

/// Uma opção: resumo numa linha, detalhe ao abrir.
///
/// Abrir o detalhe não muda estado nenhum — o requisito era explícito de que
/// consultar não pode marcar a habilidade como usada.
class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.option});

  final CombatOption option;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final unavailable = !option.isAvailable;

    final titleColor = unavailable
        ? AppColors.onDarkVariant
        : option.isExhausted
            ? AppColors.error
            : null;

    return ExpansionTile(
      key: ValueKey('combat-option-${option.id}'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 8, bottom: 8),
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Row(
        children: [
          Expanded(
            child: Text(
              option.name,
              style: text.bodyMedium?.copyWith(
                color: titleColor,
                decoration: unavailable ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (option.usesLabel case final label?)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                label,
                style: text.labelSmall?.copyWith(
                  color: option.isExhausted
                      ? AppColors.error
                      : AppColors.onDarkVariant,
                ),
              ),
            ),
        ],
      ),
      subtitle: unavailable
          ? Text(
              option.unavailableReason ?? 'Indisponível.',
              style: text.bodySmall?.copyWith(color: AppColors.error),
            )
          : option.sourceLabel == null
              ? null
              : Text(
                  '${option.source.label} • ${option.sourceLabel}',
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
      children: [
        if (option.summary case final summary?)
          _DetailLine(label: 'O que faz', value: summary),
        if (option.trigger case final trigger?)
          _DetailLine(label: 'Gatilho', value: trigger),
        if (option.cost case final cost?)
          _DetailLine(label: 'Custo', value: cost),
        if (option.requirement case final requirement?)
          _DetailLine(label: 'Condição', value: requirement),
        if (option.origins.length > 1)
          _DetailLine(
            label: 'Concedida por',
            value: option.origins.join(', '),
          ),
        if (option.ruleReference case final reference?)
          _DetailLine(label: 'Referência', value: reference),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.labelSmall?.copyWith(color: AppColors.onDarkVariant),
          ),
          Text(value, style: text.bodySmall),
        ],
      ),
    );
  }
}
