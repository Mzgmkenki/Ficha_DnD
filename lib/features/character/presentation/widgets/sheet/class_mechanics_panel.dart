import 'package:dnd_ficha_app/core/routing/app_navigator.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/class_mechanic_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_resolver.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/mechanic_table_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Os recursos de classe e subclasse do personagem na ficha.
///
/// Lê de `resolvedClassMechanicsProvider`, o mesmo ponto de verdade da tela de
/// gerenciamento: as duas não podem divergir. Nada de regra aqui — nem o
/// limite por nível, nem a validação de pré-requisito, nem a decisão de qual
/// modo pode ficar ligado.
///
/// A organização é progressiva de propósito. Uma mecânica fechada mostra só o
/// resumo ("3 de 3 conhecidas • 4 de 4 usos"); aberta, mostra as opções, os
/// controles e o acesso à tabela. É o que mantém a ficha navegável num
/// personagem com três classes e sete mecânicas.
class ClassMechanicsPanel extends ConsumerWidget {
  const ClassMechanicsPanel({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(resolvedClassMechanicsProvider(character));

    return async.when(
      data: (resolved) => _body(context, resolved),
      loading:
          () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Carregando recursos de classe...'),
            ),
          ),
      error:
          (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Não foi possível carregar os recursos: $error'),
            ),
          ),
    );
  }

  Widget _body(BuildContext context, ResolvedClassMechanics resolved) {
    final text = Theme.of(context).textTheme;
    final visible = resolved.visible;

    if (visible.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Nenhum recurso de classe com escolha, modo ou tabela até este '
            'nível.',
            key: const ValueKey('class-mechanics-empty'),
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
        ),
      );
    }

    // Agrupa por origem para o jogador ver o que vem de cada classe e de cada
    // arquétipo. Num multiclasse as duas listas não podem se misturar.
    final groups = <String, List<ResolvedClassMechanic>>{};
    for (final mechanic in visible) {
      groups.putIfAbsent(mechanic.originLabel, () => []).add(mechanic);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resolved.hasPending)
              _Notice(
                icon: Icons.error_outline,
                color: AppColors.error,
                valueKey: const ValueKey('class-mechanics-pending'),
                message:
                    resolved.pendingPickCount == 1
                        ? 'Falta 1 escolha de classe.'
                        : 'Faltam ${resolved.pendingPickCount} escolhas de '
                            'classe.',
              ),

            if (resolved.needsReview)
              _Notice(
                icon: Icons.block,
                color: AppColors.error,
                valueKey: const ValueKey('class-mechanics-review'),
                message:
                    'Há escolha sem pré-requisito cumprido ou acima do limite '
                    'do seu nível. Ela continua registrada, não está valendo, '
                    'e precisa ser revisada.',
              ),

            for (final group in groups.entries) ...[
              Text(group.key, style: text.titleSmall),
              const SizedBox(height: 4),
              for (final mechanic in group.value)
                _MechanicCard(character: character, mechanic: mechanic),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// Um cartão minimizável por mecânica.
class _MechanicCard extends StatefulWidget {
  const _MechanicCard({required this.character, required this.mechanic});

  final Character character;
  final ResolvedClassMechanic mechanic;

  @override
  State<_MechanicCard> createState() => _MechanicCardState();
}

class _MechanicCardState extends State<_MechanicCard> {
  // Fechado por padrão: a seção é longa, e o requisito é manter aberto só o
  // conteúdo com que o jogador estiver interagindo.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final mechanic = widget.mechanic;
    final badge = mechanic.badgeLabel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            container: true,
            button: true,
            expanded: _expanded,
            label: [
              mechanic.name,
              mechanic.summaryLabel,
              if (badge != null) badge,
            ].where((item) => item.isNotEmpty).join('. '),
            hint: _expanded ? 'Recolher' : 'Expandir',
            onTap: () => setState(() => _expanded = !_expanded),
            excludeSemantics: true,
            child: InkWell(
              key: ValueKey('mechanic-header-${mechanic.id}'),
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                // 48 é o alvo de toque mínimo recomendado.
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(mechanic.name, style: text.bodyLarge),
                            Text(
                              mechanic.summaryLabel,
                              key: ValueKey('mechanic-summary-${mechanic.id}'),
                              style: text.bodySmall?.copyWith(
                                color: AppColors.onDarkVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (badge != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _Badge(
                            label: badge,
                            valueKey: ValueKey('mechanic-badge-${mechanic.id}'),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: const Icon(
                            Icons.expand_more,
                            color: AppColors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child:
                _expanded
                    ? _MechanicDetails(
                      character: widget.character,
                      mechanic: mechanic,
                    )
                    : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// O conteúdo aberto de uma mecânica: regra, opções, modos, usos e tabela.
class _MechanicDetails extends ConsumerWidget {
  const _MechanicDetails({required this.character, required this.mechanic});

  final Character character;
  final ResolvedClassMechanic mechanic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final entry = mechanic.entry;
    final owned = mechanic.owned;

    final facts = <String>[
      if (entry.kindsLabel.isNotEmpty) entry.kindsLabel,
      if (entry.activation case final value?) 'Ativação: $value',
      if (entry.duration case final value?) 'Duração: $value',
      if (entry.recovery case final value?) 'Recuperação: $value',
      if (mechanic.progressionNote case final value?) value,
      if (entry.replacement case final rule?) rule.label,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.summary case final summary?)
            Text(summary, style: text.bodySmall),

          if (facts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                facts.join(' • '),
                style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
              ),
            ),

          if (entry.note case final note?)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                note,
                style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),

          // Opções que o personagem tem, com o controle de modo quando houver.
          if (owned.isNotEmpty) ...[
            const SizedBox(height: 6),
            for (final option in owned)
              _OptionRow(
                character: character,
                mechanic: mechanic,
                option: option,
              ),
          ] else if (entry.hasPicks)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Nenhuma opção escolhida.',
                key: ValueKey('mechanic-no-options-${mechanic.id}'),
                style: text.bodySmall?.copyWith(color: AppColors.error),
              ),
            ),

          // Tabela de rolagem: resultado registrado e acesso à consulta.
          if (mechanic.table case final table?) ...[
            const SizedBox(height: 6),
            if (mechanic.rollResultRow case final row?)
              Text(
                'Resultado registrado: ${row.label} — '
                '${row.values.isEmpty ? '' : row.values.first}',
                key: ValueKey('mechanic-roll-${mechanic.id}'),
                style: text.bodySmall,
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: ValueKey('mechanic-table-button-${mechanic.id}'),
                onPressed:
                    () => showMechanicTableSheet(
                      context,
                      table: table,
                      highlightedRowId: mechanic.rollResultRowId,
                    ),
                icon: const Icon(Icons.table_chart_outlined),
                label: Text(
                  table.isRollable
                      ? 'Consultar tabela (${table.dice})'
                      : 'Consultar tabela',
                ),
              ),
            ),
          ],

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: ValueKey('mechanic-manage-${mechanic.id}'),
              onPressed:
                  () => AppNavigator.toManageClassMechanic(
                    context,
                    characterId: character.id,
                    mechanicId: mechanic.id,
                  ),
              icon: const Icon(Icons.tune),
              label: const Text('Gerenciar'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma opção que o personagem tem, com o interruptor de modo quando couber.
class _OptionRow extends ConsumerWidget {
  const _OptionRow({
    required this.character,
    required this.mechanic,
    required this.option,
  });

  final Character character;
  final ResolvedClassMechanic mechanic;
  final ResolvedMechanicOption option;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    final details = <String>[
      if (option.isGranted) 'concedida',
      if (option.option.summary case final summary?) summary,
      if (option.resource case final resource?)
        '${resource.usesLabel} usos'
            '${resource.rechargeLabel == null ? '' : ' • volta em '
                    '${resource.rechargeLabel}'}',
      if (option.replacementLabel case final label?) label,
    ];

    return Padding(
      key: ValueKey('mechanic-option-${mechanic.id}-${option.id}'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            option.isInvalid
                ? Icons.block
                : option.isActive
                ? Icons.bolt
                : Icons.check_circle_outline,
            size: 16,
            color: option.isInvalid ? AppColors.error : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.name, style: text.bodyMedium),
                if (details.isNotEmpty)
                  Text(
                    details.join(' • '),
                    style: text.bodySmall?.copyWith(
                      color: AppColors.onDarkVariant,
                    ),
                  ),
                if (option.isInvalid)
                  Text(
                    option.blockReason,
                    key: ValueKey('mechanic-block-${option.id}'),
                    style: text.bodySmall?.copyWith(color: AppColors.error),
                  ),
                if (option.option.isMode &&
                    !option.isActive &&
                    option.activationBlocks.isNotEmpty)
                  Text(
                    option.activationBlockReason,
                    style: text.bodySmall?.copyWith(
                      color: AppColors.onDarkVariant,
                    ),
                  ),
              ],
            ),
          ),

          // O interruptor só aparece em opção que é modo: o resto não liga
          // nada, e um interruptor morto só confundiria.
          if (option.option.isMode)
            Switch(
              key: ValueKey('mechanic-mode-${mechanic.id}-${option.id}'),
              value: option.isActive,
              // Desligar é sempre permitido; ligar depende da validação.
              onChanged:
                  option.isActive || option.canActivate
                      ? (value) => _toggle(context, ref, value)
                      : null,
            ),
        ],
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    bool isActive,
  ) async {
    final result = await ref.read(setClassMechanicModeProvider)(
      characterId: character.id,
      mechanicId: mechanic.id,
      optionId: option.id,
      isActive: isActive,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.valueKey});

  final String label;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.redContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        key: valueKey,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.onRedContainer),
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
