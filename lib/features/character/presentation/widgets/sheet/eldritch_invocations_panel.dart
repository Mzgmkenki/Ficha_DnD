import 'package:dnd_ficha_app/core/routing/app_navigator.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/invocation_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// As Invocações Místicas do personagem na ficha.
///
/// Lê de `resolvedInvocationsProvider`, o mesmo ponto de verdade da tela de
/// seleção: as duas não podem divergir. Nada de regra aqui — nem o limite por
/// nível, nem a validação de pré-requisito.
class EldritchInvocationsPanel extends ConsumerWidget {
  const EldritchInvocationsPanel({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(resolvedInvocationsProvider(character));

    return async.when(
      data: (resolved) => _body(context, resolved),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Carregando invocações...'),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Não foi possível carregar as invocações: $error'),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ResolvedInvocations resolved) {
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Invocações Místicas: ${resolved.countLabel}',
                    key: const ValueKey('invocations-count'),
                    style: text.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => AppNavigator.toManageEldritchInvocations(
                    context,
                    characterId: character.id,
                  ),
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Gerenciar'),
                ),
              ],
            ),
            const SizedBox(height: 4),

            if (resolved.hasPendingSlots)
              _Notice(
                icon: Icons.error_outline,
                color: AppColors.error,
                valueKey: const ValueKey('invocations-pending'),
                message: resolved.freeSlots == 1
                    ? 'Falta escolher 1 invocação.'
                    : 'Faltam escolher ${resolved.freeSlots} invocações.',
              ),

            if (resolved.overLimit > 0)
              _Notice(
                icon: Icons.warning_amber_outlined,
                color: AppColors.error,
                valueKey: const ValueKey('invocations-over-limit'),
                message:
                    'Você tem ${resolved.overLimit} invocação(ões) além do '
                    'limite do seu nível de Bruxo. Remova as que sobraram.',
              ),

            if (resolved.hasInvalid)
              _Notice(
                icon: Icons.block,
                color: AppColors.error,
                valueKey: const ValueKey('invocations-invalid'),
                message:
                    'Há invocação sem pré-requisito cumprido. Ela continua '
                    'registrada, não está valendo, e precisa ser substituída.',
              ),

            if (resolved.selected.isEmpty)
              Text(
                'Nenhuma invocação selecionada.',
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              )
            else
              for (final item in resolved.selected)
                _InvocationRow(item: item, resolved: resolved),

            _BlastSummary(character: character),
            _PactWeapon(character: character),
          ],
        ),
      ),
    );
  }
}

/// Uma linha de invocação selecionada: nome, fonte, efeito e validade.
class _InvocationRow extends StatelessWidget {
  const _InvocationRow({required this.item, required this.resolved});

  final ResolvedInvocation item;
  final ResolvedInvocations resolved;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final entry = item.entry;

    final details = <String>[
      if (entry.source.isNotEmpty) entry.sourceLabel,
      for (final grant in entry.spellGrants)
        '${grant.namePt ?? grant.spellName} — ${grant.costLabel}',
      if (entry.skillProficiencies.isNotEmpty)
        'Concede proficiência em perícia; marque na seção de perícias.',
    ];

    final replaced = item.replacedInvocationId;

    return Padding(
      key: ValueKey('invocation-row-${item.id}'),
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bloqueio no inválido, estrela no válido: a diferença importa
          // porque um está valendo e o outro não.
          Icon(
            item.isValid ? Icons.auto_awesome : Icons.block,
            size: 16,
            color: item.isValid ? null : AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: text.bodyMedium),
                if (entry.hasDescription)
                  Text(
                    entry.description!,
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
                if (replaced != null)
                  Text(
                    'Substituiu ${resolved.byId(replaced)?.name ?? replaced}'
                    '${item.replacedAtLevel == null ? '' : ' no nível '
                        '${item.replacedAtLevel}'}.',
                    style: text.bodySmall?.copyWith(
                      color: AppColors.onDarkVariant,
                    ),
                  ),
                if (!item.isValid)
                  Text(
                    item.blockReason,
                    key: ValueKey('invocation-block-${item.id}'),
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

/// O resumo de Rajada Mística, quando alguma invocação mexe nela.
class _BlastSummary extends ConsumerWidget {
  const _BlastSummary({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(eldritchBlastSummaryProvider(character)).value;

    if (summary == null || !summary.hasModifiers) {
      return const SizedBox.shrink();
    }

    final text = Theme.of(context).textTheme;

    final parts = <String>[
      summary.rays == 1 ? '1 raio' : '${summary.rays} raios',
      'alcance ${summary.rangeMeters} m',
      if (summary.damageBonus != 0)
        '+${summary.damageBonus} de dano por acerto',
      if (summary.pushMeters != null)
        'empurra até ${summary.pushMeters} m',
      if (summary.pullMeters != null) 'puxa até ${summary.pullMeters} m',
      if (summary.slowMeters != null)
        'reduz o deslocamento em ${summary.slowMeters} m',
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            'Rajada Mística',
            key: const ValueKey('invocations-blast'),
            style: text.bodyMedium,
          ),
          Text(
            parts.join(' • '),
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
          Text(
            'De: ${summary.sources.join(', ')}.',
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
        ],
      ),
    );
  }
}

/// O resumo da arma de pacto, quando alguma invocação mexe nela.
class _PactWeapon extends ConsumerWidget {
  const _PactWeapon({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(pactWeaponSummaryProvider(character)).value;

    if (summary == null || summary.isEmpty) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;

    final parts = <String>[
      if (summary.attacks > 1) '${summary.attacks} ataques por ação',
      if (summary.attackBonus != 0) '+${summary.attackBonus} no ataque',
      if (summary.damageBonusFlat != 0)
        '+${summary.damageBonusFlat} no dano',
      if (summary.damageBonus != 0)
        '+${summary.damageBonus} de dano'
            '${summary.damageTypes.isEmpty ? '' : ' '
                '${summary.damageTypes.first}'}',
      for (final dice in summary.extraDamageDice) dice,
      if (summary.isSpellcastingFocus) 'serve de foco de conjuração',
      if (summary.allowsRanged) 'pode invocar arma à distância',
    ];

    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            'Arma de pacto',
            key: const ValueKey('invocations-pact-weapon'),
            style: text.bodyMedium,
          ),
          Text(
            parts.join(' • '),
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
          Text(
            'De: ${summary.sources.join(', ')}.',
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.color,
    required this.message,
    required this.valueKey,
  });

  final IconData icon;
  final Color color;
  final String message;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              key: valueKey,
              style: text.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
