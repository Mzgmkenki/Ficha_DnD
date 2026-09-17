import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/magic_item_bonus.dart';
import 'package:flutter/material.dart';

/// Configuração do bônus de um item mágico.
///
/// O bônus é um degrau fechado, no mesmo componente que a arma mágica usa
/// (`DropdownButtonFormField`), e as estatísticas afetadas são escolha
/// explícita. Antes eram quatro campos numéricos livres, e nada impedia um
/// `+7` — nem impedia marcar ataque mágico num escudo por distração.
///
/// Widget separado porque a mesma configuração aparece em dois lugares: no
/// formulário de adicionar item e na folha de editar item existente.
class MagicItemBonusEditor extends StatelessWidget {
  const MagicItemBonusEditor({
    required this.bonus,
    required this.targets,
    required this.isEquipped,
    required this.requiresAttunement,
    required this.isAttuned,
    required this.onBonusChanged,
    required this.onTargetToggled,
    required this.onEquippedChanged,
    required this.onRequiresAttunementChanged,
    required this.onAttunedChanged,
    this.legacyBonuses,
    this.onClearLegacy,
    super.key,
  });

  final MagicItemBonus bonus;
  final Set<MagicItemBonusTarget> targets;
  final bool isEquipped;
  final bool requiresAttunement;
  final bool isAttuned;

  final ValueChanged<MagicItemBonus> onBonusChanged;
  final void Function(MagicItemBonusTarget target, bool selected)
      onTargetToggled;
  final ValueChanged<bool> onEquippedChanged;
  final ValueChanged<bool> onRequiresAttunementChanged;
  final ValueChanged<bool> onAttunedChanged;

  /// Valores livres antigos que não couberam no formato controlado.
  ///
  /// Quando presente, o editor avisa que o item precisa de revisão e explica
  /// que o número original continua valendo — em vez de mostrar "Sem bônus" e
  /// dar a impressão de que o efeito foi perdido.
  final LegacyMagicItemBonuses? legacyBonuses;

  /// Descarta os valores antigos e assume o que está selecionado aqui.
  final VoidCallback? onClearLegacy;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final legacy = legacyBonuses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bônus do item', style: text.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Escolha o bônus e marque só as estatísticas que a descrição do item '
          'citar. Uma arma +1 soma no ataque e no dano dela; um foco mágico '
          'soma no ataque mágico e na CD. Nenhum dos dois afeta o do outro.',
          style: text.bodySmall,
        ),
        if (legacy != null) ...[
          const SizedBox(height: 8),
          _LegacyWarning(legacy: legacy, onClear: onClearLegacy),
        ],
        const SizedBox(height: 12),
        DropdownButtonFormField<MagicItemBonus>(
          initialValue: bonus,
          decoration: const InputDecoration(
            labelText: 'Bônus mágico do item',
            helperText: 'Só entra nas estatísticas marcadas abaixo.',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final option in MagicItemBonus.values)
              DropdownMenuItem(value: option, child: Text(option.label)),
          ],
          onChanged: (value) =>
              onBonusChanged(value ?? MagicItemBonus.none),
        ),
        const SizedBox(height: 12),
        Text('Estatísticas afetadas', style: text.labelLarge),
        const SizedBox(height: 2),
        Text(
          'Pode marcar mais de uma. Um item que dá +1 no ataque mágico e +1 na '
          'CD marca as duas.',
          style: text.bodySmall,
        ),
        for (final target in MagicItemBonusTarget.ordered)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            value: targets.contains(target),
            title: Text(target.label),
            onChanged: (value) => onTargetToggled(target, value ?? false),
          ),
        // Bônus escolhido sem nenhuma estatística marcada não soma nada. Dizer
        // isso evita o jogador achar que salvou um `+1` que a ficha ignora.
        if (!bonus.isNone && targets.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Marque ao menos uma estatística, senão o bônus não entra em '
              'nenhuma conta.',
              style: text.bodySmall?.copyWith(color: AppColors.gold),
            ),
          ),
        const Divider(height: 24),
        Text('Uso do item', style: text.labelLarge),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isEquipped,
          title: const Text('Equipado'),
          subtitle: const Text('Item guardado não soma nada na ficha.'),
          onChanged: onEquippedChanged,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: requiresAttunement,
          title: const Text('Exige sintonia'),
          subtitle: const Text('Como diz a descrição do item.'),
          onChanged: onRequiresAttunementChanged,
        ),
        // Só aparece quando faz diferença: perguntar sobre sintonia num item
        // que não exige sintonia é uma escolha sem efeito.
        if (requiresAttunement)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: isAttuned,
            title: const Text('Sintonizado'),
            subtitle: const Text(
              'Sem sintonia o item não concede o bônus.',
            ),
            onChanged: onAttunedChanged,
          ),
      ],
    );
  }
}

/// Aviso do item cujo bônus antigo não cabe nas opções.
class _LegacyWarning extends StatelessWidget {
  const _LegacyWarning({required this.legacy, this.onClear});

  final LegacyMagicItemBonuses legacy;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bônus antigo para revisar',
            style: text.labelLarge?.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 4),
          Text(
            'Este item foi cadastrado com ${legacy.describe()}, que não cabe '
            'em +1, +2 ou +3. O valor original continua valendo na ficha até '
            'você escolher um bônus aqui.',
            style: text.bodySmall,
          ),
          if (onClear != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Usar o que escolhi acima'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Resumo do que o item declara e se aquilo está valendo.
///
/// Fica junto do editor porque as duas telas que configuram bônus (a de
/// gerenciar itens e o painel da ficha) mostram o mesmo resumo, e ele precisa
/// dizer as quatro coisas de uma vez: bônus, estatísticas, equipado e sintonia.
class MagicItemConfigSummary extends StatelessWidget {
  const MagicItemConfigSummary({
    required this.bonusDescription,
    required this.isEquipped,
    required this.requiresAttunement,
    required this.isAttuned,
    required this.isActive,
    required this.needsReview,
    super.key,
  });

  final String bonusDescription;
  final bool isEquipped;
  final bool requiresAttunement;
  final bool isAttuned;
  final bool isActive;
  final bool needsReview;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            MagicItemStateChip(
              label: isEquipped ? 'Equipado' : 'Guardado',
              active: isEquipped,
            ),
            if (requiresAttunement)
              MagicItemStateChip(
                label: isAttuned ? 'Sintonizado' : 'Sem sintonia',
                active: isAttuned,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          bonusDescription.isEmpty
              ? 'Sem bônus declarado.'
              : 'Bônus: $bonusDescription',
          style: text.bodySmall,
        ),
        // Sem esta linha o jogador somaria um bônus que a ficha não está
        // usando, e concluiria que a conta do app está errada.
        if (bonusDescription.isNotEmpty && !isActive)
          Text(
            isEquipped
                ? 'Não está somando: o item exige sintonia.'
                : 'Não está somando: o item não está equipado.',
            style: text.bodySmall?.copyWith(color: AppColors.error),
          ),
        if (needsReview)
          Text(
            'Revise o bônus deste item.',
            style: text.bodySmall?.copyWith(color: AppColors.gold),
          ),
      ],
    );
  }
}

/// Etiqueta curta de estado: destacada quando ligada, apagada quando não.
class MagicItemStateChip extends StatelessWidget {
  const MagicItemStateChip({
    required this.label,
    required this.active,
    super.key,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: active ? scheme.onPrimaryContainer : null,
            ),
      ),
    );
  }
}
