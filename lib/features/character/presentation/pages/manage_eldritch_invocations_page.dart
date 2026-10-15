import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/invocation_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_resolver.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/eldritch_invocation_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/pact_boon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Os filtros da lista de invocações.
///
/// Bloqueadas aparecem na lista, e isso é decisão de produto: esconder o que
/// falta alcançar deixaria a progressão invisível e faria o jogador procurar
/// no livro para saber o que vem depois.
enum InvocationFilter {
  all('all', 'Todas'),
  available('available', 'Disponíveis'),
  selected('selected', 'Selecionadas'),
  blocked('blocked', 'Bloqueadas');

  const InvocationFilter(this.id, this.label);

  final String id;
  final String label;
}

/// Seleção e substituição de Invocações Místicas.
///
/// Grava a cada toque, como a tela de idiomas: a escolha é uma só decisão.
/// Cada gravação passa pelo domínio, que revalida — esta tela desabilita o que
/// está bloqueado para explicar o motivo, não para ser a barreira.
class ManageEldritchInvocationsPage extends ConsumerStatefulWidget {
  const ManageEldritchInvocationsPage({required this.characterId, super.key});

  /// Recebe o ID, e não o personagem.
  ///
  /// Uma cópia passada por argumento ficaria velha no primeiro toque: a tela
  /// grava a cada escolha, e a lista precisa recontar as vagas em seguida. É a
  /// mesma decisão do Painel de combate e do gerenciador de magias.
  final String characterId;

  @override
  ConsumerState<ManageEldritchInvocationsPage> createState() =>
      _ManageEldritchInvocationsPageState();
}

class _ManageEldritchInvocationsPageState
    extends ConsumerState<ManageEldritchInvocationsPage> {
  final TextEditingController _search = TextEditingController();

  InvocationFilter _filter = InvocationFilter.all;
  bool _busy = false;

  /// Id da invocação que será substituída, quando o jogador pediu uma troca.
  ///
  /// Enquanto estiver preenchido a tela está em modo substituição: o próximo
  /// toque numa invocação disponível troca, em vez de ocupar vaga nova.
  String? _replacing;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterAsync = ref.watch(
      characterByIdProvider(widget.characterId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Invocações Místicas')),
      body: characterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Erro ao carregar o personagem: $error'),
          ),
        ),
        data: (character) {
          if (character == null) {
            return const Center(child: Text('Personagem não encontrado.'));
          }

          final async = ref.watch(resolvedInvocationsProvider(character));

          return async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao carregar as invocações: $error'),
              ),
            ),
            data: _body,
          );
        },
      ),
    );
  }

  Widget _body(ResolvedInvocations resolved) {
    final text = Theme.of(context).textTheme;

    if (!resolved.isWarlock) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Invocações Místicas são da classe Bruxo. Este personagem não tem '
            'níveis de Bruxo.',
            key: const ValueKey('invocations-not-warlock'),
            textAlign: TextAlign.center,
            style: text.bodyMedium,
          ),
        ),
      );
    }

    if (resolved.limit <= 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'O Bruxo aprende as duas primeiras Invocações Místicas no 2º '
            'nível. Este personagem está no ${resolved.warlockLevel}º nível '
            'de Bruxo.',
            key: const ValueKey('invocations-too-early'),
            textAlign: TextAlign.center,
            style: text.bodyMedium,
          ),
        ),
      );
    }

    final visible = _visible(resolved);

    return Column(
      children: [
        _Header(
          characterId: widget.characterId,
          resolved: resolved,
          replacing: _replacing == null
              ? null
              : resolved.byId(_replacing)?.name ?? _replacing,
          onCancelReplace: () => setState(() => _replacing = null),
        ),
        _Filters(
          search: _search,
          filter: _filter,
          onSearchChanged: (_) => setState(() {}),
          onFilterChanged: (value) => setState(() => _filter = value),
        ),
        if (visible.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nenhuma invocação encontrada com esse filtro.',
                  key: const ValueKey('invocations-empty'),
                  style: text.bodyMedium,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final item = visible[index];

                return _InvocationCard(
                  item: item,
                  resolved: resolved,
                  busy: _busy,
                  isReplacementTarget: _replacing == item.id,
                  replacingAnother: _replacing != null && _replacing != item.id,
                  onSelect: () => _select(item.id),
                  onReplace: () => setState(() => _replacing = item.id),
                  onRemove: () => _remove(item.id),
                  onApplyReplacement: () => _replace(item.id),
                );
              },
            ),
          ),
      ],
    );
  }

  /// Aplica busca e filtro, mantendo a ordem alfabética do catálogo.
  List<ResolvedInvocation> _visible(ResolvedInvocations resolved) {
    final needle = EldritchInvocationEntry.normalizeName(_search.text);

    return [
      for (final item in resolved.options)
        if (_matchesFilter(item) && _matchesSearch(item, needle)) item,
    ];
  }

  bool _matchesFilter(ResolvedInvocation item) {
    switch (_filter) {
      case InvocationFilter.all:
        return true;
      case InvocationFilter.available:
        return item.availability == InvocationAvailability.available;
      case InvocationFilter.selected:
        return item.isSelected;
      case InvocationFilter.blocked:
        return item.availability == InvocationAvailability.blocked;
    }
  }

  bool _matchesSearch(ResolvedInvocation item, String needle) {
    if (needle.isEmpty) return true;

    return item.entry.searchableNames.any(
      (name) => EldritchInvocationEntry.normalizeName(name).contains(needle),
    );
  }

  Future<void> _select(String invocationId) async {
    await _write(
      () => ref.read(selectEldritchInvocationProvider)(
        characterId: widget.characterId,
        invocationId: invocationId,
      ),
    );
  }

  Future<void> _replace(String invocationId) async {
    final replacedId = _replacing;
    if (replacedId == null) return;

    await _write(
      () => ref.read(replaceEldritchInvocationProvider)(
        characterId: widget.characterId,
        replacedId: replacedId,
        invocationId: invocationId,
      ),
    );

    if (mounted) setState(() => _replacing = null);
  }

  Future<void> _remove(String invocationId) async {
    await _write(
      () => ref.read(removeEldritchInvocationProvider)(
        characterId: widget.characterId,
        invocationId: invocationId,
      ),
    );
  }

  Future<void> _write(Future<InvocationWriteResult> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final result = await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// Contagem, nível de Bruxo e Dádiva do Pacto.
class _Header extends ConsumerWidget {
  const _Header({
    required this.characterId,
    required this.resolved,
    required this.replacing,
    required this.onCancelReplace,
  });

  final String characterId;
  final ResolvedInvocations resolved;

  /// Nome da invocação que está sendo substituída, quando há uma.
  final String? replacing;

  final VoidCallback onCancelReplace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final boon = resolved.profile.pactBoon;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invocações Místicas: ${resolved.countLabel}',
            key: const ValueKey('invocations-page-count'),
            style: text.titleMedium,
          ),
          Text(
            '${resolved.className} nível ${resolved.warlockLevel}'
            '${boon == null ? '' : ' • ${boon.label}'}',
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
          if (boon == null && resolved.warlockLevel >= 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Escolha a sua Dádiva do Pacto: metade do catálogo depende '
                'dela.',
                key: const ValueKey('invocations-no-boon'),
                style: text.bodySmall?.copyWith(color: AppColors.error),
              ),
            ),
          if (resolved.warlockLevel >= 3) ...[
            const SizedBox(height: 8),
            _PactBoonPicker(characterId: characterId, resolved: resolved),
          ],
          if (replacing != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Substituindo $replacing. Toque na invocação que entra.',
                      key: const ValueKey('invocations-replacing'),
                      style: text.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: onCancelReplace,
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A escolha da Dádiva do Pacto, em chips.
class _PactBoonPicker extends ConsumerStatefulWidget {
  const _PactBoonPicker({required this.characterId, required this.resolved});

  final String characterId;
  final ResolvedInvocations resolved;

  @override
  ConsumerState<_PactBoonPicker> createState() => _PactBoonPickerState();
}

class _PactBoonPickerState extends ConsumerState<_PactBoonPicker> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.resolved.profile.pactBoon;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final boon in PactBoon.values)
          ChoiceChip(
            key: ValueKey('pact-boon-${boon.id}'),
            label: Text(boon.label),
            selected: selected == boon,
            onSelected: _busy ? null : (_) => _choose(boon),
          ),
      ],
    );
  }

  Future<void> _choose(PactBoon boon) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      await ref.read(choosePactBoonProvider)(
        characterId: widget.characterId,
        boon: boon,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${boon.label} escolhido.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// Busca por nome e os quatro filtros.
class _Filters extends StatelessWidget {
  const _Filters({
    required this.search,
    required this.filter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final TextEditingController search;
  final InvocationFilter filter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<InvocationFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: search,
            key: const ValueKey('invocations-search'),
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Pesquisar por nome',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in InvocationFilter.values) ...[
                  ChoiceChip(
                    key: ValueKey('invocations-filter-${item.id}'),
                    label: Text(item.label),
                    selected: filter == item,
                    onSelected: (_) => onFilterChanged(item),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Um cartão de invocação: nome, fonte, texto, pré-requisito e ação.
class _InvocationCard extends StatelessWidget {
  const _InvocationCard({
    required this.item,
    required this.resolved,
    required this.busy,
    required this.isReplacementTarget,
    required this.replacingAnother,
    required this.onSelect,
    required this.onReplace,
    required this.onRemove,
    required this.onApplyReplacement,
  });

  final ResolvedInvocation item;
  final ResolvedInvocations resolved;
  final bool busy;

  /// Se esta é a invocação que o jogador escolheu substituir.
  final bool isReplacementTarget;

  /// Se o jogador está substituindo OUTRA invocação.
  final bool replacingAnother;

  final VoidCallback onSelect;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final VoidCallback onApplyReplacement;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final entry = item.entry;
    final blocked = item.isBlocked || !item.isValid;

    final details = <String>[
      if (entry.source.isNotEmpty) entry.sourceLabel,
      if (entry.prerequisiteLabels.isNotEmpty)
        'Pré-requisito: ${entry.prerequisiteLabels.join(', ')}',
      for (final grant in entry.spellGrants)
        '${grant.namePt ?? grant.spellName} — ${grant.costLabel}',
    ];

    return Card(
      key: ValueKey('invocation-card-${item.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.name,
                    style: text.titleSmall?.copyWith(
                      color: blocked ? AppColors.onDarkVariant : null,
                    ),
                  ),
                ),
                _StatusChip(availability: item.availability),
              ],
            ),
            if (entry.hasDescription) ...[
              const SizedBox(height: 6),
              Text(
                entry.description!,
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              ),
            ],
            if (details.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                details.join(' • '),
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                ),
              ),
            ],
            if (item.blocks.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.blockReason,
                key: ValueKey('invocation-reason-${item.id}'),
                style: text.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 8),
            _Actions(
              item: item,
              resolved: resolved,
              busy: busy,
              isReplacementTarget: isReplacementTarget,
              replacingAnother: replacingAnother,
              onSelect: onSelect,
              onReplace: onReplace,
              onRemove: onRemove,
              onApplyReplacement: onApplyReplacement,
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.item,
    required this.resolved,
    required this.busy,
    required this.isReplacementTarget,
    required this.replacingAnother,
    required this.onSelect,
    required this.onReplace,
    required this.onRemove,
    required this.onApplyReplacement,
  });

  final ResolvedInvocation item;
  final ResolvedInvocations resolved;
  final bool busy;
  final bool isReplacementTarget;
  final bool replacingAnother;
  final VoidCallback onSelect;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final VoidCallback onApplyReplacement;

  @override
  Widget build(BuildContext context) {
    if (item.isSelected) {
      return Row(
        children: [
          if (isReplacementTarget)
            Text(
              'Escolha a substituta na lista.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            TextButton.icon(
              key: ValueKey('invocation-replace-${item.id}'),
              onPressed: busy ? null : onReplace,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Substituir'),
            ),
          const Spacer(),
          TextButton.icon(
            key: ValueKey('invocation-remove-${item.id}'),
            onPressed: busy ? null : onRemove,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remover'),
          ),
        ],
      );
    }

    // Bloqueada continua visível e explicada, com o botão desabilitado. A
    // barreira de verdade está no domínio: esta tela só evita o toque inútil.
    final enabled = !busy && item.blocks.isEmpty;

    if (replacingAnother) {
      return Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          key: ValueKey('invocation-apply-${item.id}'),
          onPressed: enabled ? onApplyReplacement : null,
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Trocar por esta'),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: FilledButton.icon(
        key: ValueKey('invocation-select-${item.id}'),
        onPressed: enabled && resolved.freeSlots > 0 ? onSelect : null,
        icon: const Icon(Icons.add),
        label: Text(
          resolved.freeSlots > 0
              ? 'Escolher'
              : 'Sem vaga — substitua uma invocação',
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.availability});

  final InvocationAvailability availability;

  @override
  Widget build(BuildContext context) {
    final color = switch (availability) {
      InvocationAvailability.selected => AppColors.gold,
      InvocationAvailability.invalid => AppColors.error,
      InvocationAvailability.available => null,
      InvocationAvailability.blocked => AppColors.onDarkVariant,
    };

    return Chip(
      label: Text(availability.label),
      labelStyle: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: color),
      visualDensity: VisualDensity.compact,
    );
  }
}
