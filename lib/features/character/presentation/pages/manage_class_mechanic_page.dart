import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/class_mechanic_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_resources.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/mechanic_table_view.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gerencia uma mecânica de classe: escolhas, substituições, modos, usos e
/// tabela.
///
/// Recebe só os ids, e não a entidade, pelo mesmo motivo da tela de Invocações
/// Místicas: a página grava a cada toque e precisa recontar as vagas, então
/// uma cópia do personagem ficaria velha na primeira escolha.
///
/// Nenhuma regra mora aqui. A opção aparece desabilitada porque o domínio
/// disse que está bloqueada, e o motivo exibido é a frase que o validador
/// produziu — a tela não remonta nenhuma das duas coisas.
class ManageClassMechanicPage extends ConsumerStatefulWidget {
  const ManageClassMechanicPage({
    required this.characterId,
    required this.mechanicId,
    super.key,
  });

  final String characterId;
  final String mechanicId;

  @override
  ConsumerState<ManageClassMechanicPage> createState() =>
      _ManageClassMechanicPageState();
}

class _ManageClassMechanicPageState
    extends ConsumerState<ManageClassMechanicPage> {
  /// Opção marcada para sair, quando o jogador está substituindo.
  ///
  /// Guardar aqui, e não no personagem, é de propósito: escolher quem sai é
  /// estado de tela, e persistir isso deixaria uma substituição pela metade
  /// gravada na ficha.
  String? _replacing;

  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(characterByIdProvider(widget.characterId));

    return Scaffold(
      appBar: AppBar(title: const Text('Recursos de classe')),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _Message(text: 'Erro ao carregar: $error'),
          data: (character) {
            if (character == null) {
              return const _Message(text: 'Personagem não encontrado.');
            }
            return _MechanicBody(
              character: character,
              mechanicId: widget.mechanicId,
              replacing: _replacing,
              query: _query,
              onReplacingChanged: (value) => setState(() => _replacing = value),
              onQueryChanged: () => setState(() {}),
            );
          },
        ),
      ),
    );
  }
}

class _MechanicBody extends ConsumerWidget {
  const _MechanicBody({
    required this.character,
    required this.mechanicId,
    required this.replacing,
    required this.query,
    required this.onReplacingChanged,
    required this.onQueryChanged,
  });

  final Character character;
  final String mechanicId;
  final String? replacing;
  final TextEditingController query;
  final ValueChanged<String?> onReplacingChanged;
  final VoidCallback onQueryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      resolvedClassMechanicProvider((
        character: character,
        mechanicId: mechanicId,
      )),
    );

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _Message(text: 'Erro ao carregar: $error'),
      data: (mechanic) {
        if (mechanic == null) {
          return const _Message(
            text:
                'Esta característica não está disponível para este '
                'personagem.',
          );
        }
        return _content(context, ref, mechanic);
      },
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    ResolvedClassMechanic mechanic,
  ) {
    final text = Theme.of(context).textTheme;
    final entry = mechanic.entry;

    final needle = query.text.trim().toLowerCase();
    final options =
        needle.isEmpty
            ? mechanic.options
            : [
              for (final option in mechanic.options)
                if (option.option.searchableNames.any(
                  (name) => name.toLowerCase().contains(needle),
                ))
                  option,
            ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(mechanic.name, style: text.titleLarge),
        Text(
          mechanic.sourceLabel,
          style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
        ),

        if (entry.summary case final summary?) ...[
          const SizedBox(height: 8),
          Text(summary, style: text.bodyMedium),
        ],

        if (entry.description case final description?) ...[
          const SizedBox(height: 4),
          Text(description, style: text.bodySmall),
        ],

        const SizedBox(height: 12),
        _Facts(mechanic: mechanic),

        if (mechanic.resource case final resource?) ...[
          const Divider(height: 24),
          Text('Usos', style: text.titleSmall),
          const SizedBox(height: 4),
          _ResourceRow(character: character, resource: resource),
        ],

        if (mechanic.table case final table?) ...[
          const Divider(height: 24),
          _TableSection(character: character, mechanic: mechanic, table: table),
        ],

        if (entry.options.isEmpty)
          const SizedBox.shrink()
        else ...[
          const Divider(height: 24),

          // Contagem e vagas em linhas separadas, não lado a lado: numa tela
          // de 360 px "3 de 9 conhecidas" mais "Novas escolhas disponíveis: 2"
          // não cabem na mesma linha, e o texto da direita era cortado.
          Text(
            mechanic.countLabel ?? 'Opções',
            key: const ValueKey('manage-mechanic-count'),
            style: text.titleSmall,
          ),

          if (entry.hasPicks && mechanic.freeSlots > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                mechanic.freeSlots == 1
                    ? 'Novas escolhas disponíveis: 1'
                    : 'Novas escolhas disponíveis: ${mechanic.freeSlots}',
                key: const ValueKey('manage-mechanic-free-slots'),
                style: text.bodySmall?.copyWith(color: AppColors.error),
              ),
            ),

          if (mechanic.overLimit > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Você tem ${mechanic.overLimit} opção(ões) além do limite do '
                'seu nível. Remova as que sobraram.',
                key: const ValueKey('manage-mechanic-over-limit'),
                style: text.bodySmall?.copyWith(color: AppColors.error),
              ),
            ),

          if (replacing case final replaced?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Substituindo '
                    '${mechanic.optionById(replaced)?.name ?? replaced}: '
                    'escolha a opção que entra.',
                    key: const ValueKey('manage-mechanic-replacing'),
                    style: text.bodySmall?.copyWith(color: AppColors.error),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const ValueKey('manage-mechanic-cancel-replace'),
                      onPressed: () => onReplacingChanged(null),
                      child: const Text('Cancelar substituição'),
                    ),
                  ),
                ],
              ),
            ),

          if (entry.options.length >= 8) ...[
            const SizedBox(height: 8),
            TextField(
              controller: query,
              key: const ValueKey('manage-mechanic-search'),
              onChanged: (_) => onQueryChanged(),
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search),
                labelText: 'Buscar opção',
              ),
            ),
          ],

          const SizedBox(height: 8),

          if (options.isEmpty)
            Text(
              'Nenhuma opção corresponde à busca.',
              key: const ValueKey('manage-mechanic-empty'),
              style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
            )
          else
            for (final option in options)
              _OptionCard(
                character: character,
                mechanic: mechanic,
                option: option,
                replacing: replacing,
                onReplacingChanged: onReplacingChanged,
              ),
        ],
      ],
    );
  }
}

/// Os fatos da regra, em texto, para o jogador não precisar abrir o livro.
class _Facts extends StatelessWidget {
  const _Facts({required this.mechanic});

  final ResolvedClassMechanic mechanic;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final entry = mechanic.entry;

    final facts = <String>[
      if (entry.kindsLabel.isNotEmpty) entry.kindsLabel,
      if (entry.activation case final value?) 'Ativação: $value',
      if (entry.duration case final value?) 'Duração: $value',
      if (entry.recovery case final value?) 'Recuperação: $value',
      if (mechanic.maxActive case final value?)
        value == 1
            ? 'Um modo ativo por vez'
            : 'Até $value modos ativos por vez',
      if (mechanic.progressionNote case final value?) value,
      if (entry.replacement case final rule?)
        rule.label
      else if (entry.hasPicks)
        'As escolhas são permanentes: a regra não permite trocá-las.',
      if (entry.note case final note?) note,
    ];

    if (facts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final fact in facts)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '• $fact',
              style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
            ),
          ),
      ],
    );
  }
}

/// A tabela da mecânica, com registro manual e rolagem quando couber.
class _TableSection extends ConsumerWidget {
  const _TableSection({
    required this.character,
    required this.mechanic,
    required this.table,
  });

  final Character character;
  final ResolvedClassMechanic mechanic;
  final MechanicTable table;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final row = mechanic.rollResultRow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(table.title, style: text.titleSmall),
        const SizedBox(height: 4),

        if (row != null)
          Text(
            'Resultado registrado: ${row.label}'
            '${row.values.isEmpty ? '' : ' — ${row.values.first}'}',
            key: const ValueKey('manage-mechanic-roll-result'),
            style: text.bodySmall,
          )
        else
          Text(
            table.isRollable
                ? 'Nenhum resultado registrado.'
                : 'Tabela de consulta: as linhas não viram escolha.',
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),

        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              key: const ValueKey('manage-mechanic-open-table'),
              onPressed: () => _open(context, ref, allowSelection: false),
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Consultar'),
            ),

            // Registro manual e rolagem só existem em tabela rolável: numa
            // tabela de consulta eles transformariam a linha em escolha, que é
            // exatamente o que o levantamento proíbe.
            if (table.isRollable) ...[
              OutlinedButton.icon(
                key: const ValueKey('manage-mechanic-pick-row'),
                onPressed: () => _open(context, ref, allowSelection: true),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Informar resultado'),
              ),
              FilledButton.icon(
                key: const ValueKey('manage-mechanic-roll'),
                onPressed: () => _roll(context, ref),
                icon: const Icon(Icons.casino_outlined),
                label: Text('Rolar ${table.dice}'),
              ),
            ],

            if (row != null)
              TextButton.icon(
                key: const ValueKey('manage-mechanic-clear-roll'),
                onPressed: () => _write(context, ref, ''),
                icon: const Icon(Icons.clear),
                label: const Text('Apagar resultado'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref, {
    required bool allowSelection,
  }) async {
    final picked = await showMechanicTableSheet(
      context,
      table: table,
      highlightedRowId: mechanic.rollResultRowId,
      allowSelection: allowSelection,
    );

    if (picked == null || !context.mounted) return;
    await _write(context, ref, picked.id);
  }

  /// Rola na tabela usando o dado do app.
  ///
  /// Reaproveita `DiceRoller`, que já existe e já é injetável nos testes: um
  /// gerador próprio aqui tornaria o resultado impossível de fixar numa
  /// suíte.
  Future<void> _roll(BuildContext context, WidgetRef ref) async {
    final faces = table.faces;
    if (faces == null) return;

    final rolled = ref.read(diceRollerProvider).rollDie(faces);
    final row = table.rowFor(rolled);

    if (row == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rolou $rolled, e nenhuma linha da tabela cobre esse valor. '
            'Confira a tabela.',
          ),
        ),
      );
      return;
    }

    await _write(context, ref, row.id, rolled: rolled);
  }

  Future<void> _write(
    BuildContext context,
    WidgetRef ref,
    String rowId, {
    int? rolled,
  }) async {
    final result = await ref.read(setClassMechanicRollResultProvider)(
      characterId: character.id,
      mechanicId: mechanic.id,
      rowId: rowId,
    );

    if (!context.mounted) return;

    final prefix = rolled == null ? '' : 'Rolou $rolled. ';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$prefix${result.message}')));
  }
}

/// Um cartão de opção: nome, descrição, motivo do bloqueio e ações.
class _OptionCard extends ConsumerWidget {
  const _OptionCard({
    required this.character,
    required this.mechanic,
    required this.option,
    required this.replacing,
    required this.onReplacingChanged,
  });

  final Character character;
  final ResolvedClassMechanic mechanic;
  final ResolvedMechanicOption option;
  final String? replacing;
  final ValueChanged<String?> onReplacingChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final entry = mechanic.entry;
    final isReplacingThis = replacing == option.id;
    final isReplacementTarget = replacing != null && !isReplacingThis;

    return Card(
      key: ValueKey('manage-option-${option.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(option.name, style: text.bodyLarge)),
                _StatusChip(option: option),
              ],
            ),

            if (option.option.nameOriginal case final original?)
              Text(
                original,
                style: text.bodySmall?.copyWith(
                  color: AppColors.onDarkVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),

            if (option.option.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(option.option.description, style: text.bodySmall),
            ],

            if (option.option.action?.cost case final cost?)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Custo: $cost',
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
              ),

            if (option.replacementLabel case final label?)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  label,
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
              ),

            // Opção bloqueada continua VISÍVEL, com todos os motivos: é o que
            // torna a progressão legível em vez de invisível.
            if (option.blocks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final block in option.blocks)
                      Text(
                        block.message,
                        key: ValueKey(
                          'manage-option-block-${option.id}-${block.kind.id}',
                        ),
                        style: text.bodySmall?.copyWith(color: AppColors.error),
                      ),
                  ],
                ),
              ),

            if (option.resource case final resource?) ...[
              const SizedBox(height: 4),
              _ResourceRow(character: character, resource: resource),
            ],

            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                // Entrar numa vaga livre.
                if (!option.isOwned && !isReplacementTarget)
                  FilledButton(
                    key: ValueKey('manage-option-select-${option.id}'),
                    onPressed:
                        option.isAvailable && mechanic.freeSlots > 0
                            ? () => _select(context, ref)
                            : null,
                    child: const Text('Escolher'),
                  ),

                // Entrar no lugar de outra.
                if (!option.isOwned && isReplacementTarget)
                  FilledButton(
                    key: ValueKey('manage-option-replace-${option.id}'),
                    onPressed:
                        option.isAvailable
                            ? () => _replace(context, ref)
                            : null,
                    child: const Text('Entrar no lugar'),
                  ),

                // Marcar para sair. Só aparece quando a regra permite trocar.
                if (option.availability.consumesSlot &&
                    entry.canReplace &&
                    !isReplacingThis)
                  OutlinedButton(
                    key: ValueKey('manage-option-start-replace-${option.id}'),
                    onPressed: () => onReplacingChanged(option.id),
                    child: const Text('Substituir'),
                  ),

                if (option.availability.consumesSlot)
                  TextButton(
                    key: ValueKey('manage-option-remove-${option.id}'),
                    onPressed: () => _remove(context, ref),
                    child: const Text('Remover'),
                  ),

                if (option.option.isMode && option.isOwned)
                  TextButton.icon(
                    key: ValueKey('manage-option-mode-${option.id}'),
                    onPressed:
                        option.isActive || option.canActivate
                            ? () => _toggle(context, ref, !option.isActive)
                            : null,
                    icon: Icon(option.isActive ? Icons.flash_off : Icons.bolt),
                    label: Text(option.isActive ? 'Desativar' : 'Ativar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _select(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(selectClassMechanicOptionProvider)(
      characterId: character.id,
      mechanicId: mechanic.id,
      optionId: option.id,
    );

    if (!context.mounted) return;
    _notify(context, result.message);
  }

  Future<void> _replace(BuildContext context, WidgetRef ref) async {
    final replaced = replacing;
    if (replaced == null) return;

    final result = await ref.read(replaceClassMechanicOptionProvider)(
      characterId: character.id,
      mechanicId: mechanic.id,
      replacedId: replaced,
      optionId: option.id,
      // A tela de gerenciamento É o modo de edição livre da ficha: o jogador
      // vem aqui para corrigir uma decisão, não para aplicar a regra de subir
      // de nível. A permissão continua vindo do domínio — mecânica sem regra
      // de substituição segue sem troca.
      freeEdit: true,
    );

    if (result.changed) onReplacingChanged(null);

    if (!context.mounted) return;
    _notify(context, result.message);
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(removeClassMechanicOptionProvider)(
      characterId: character.id,
      mechanicId: mechanic.id,
      optionId: option.id,
    );

    if (result.changed && replacing == option.id) onReplacingChanged(null);

    if (!context.mounted) return;
    _notify(context, result.message);
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
    _notify(context, result.message);
  }

  /// Mostra o resultado da escrita.
  ///
  /// O `mounted` é conferido por quem chama, e não aqui: o analisador não
  /// atravessa a fronteira do método, e esconder a checagem dentro dele
  /// silenciaria o aviso sem resolver o problema real de usar o contexto
  /// depois de a tela sair.
  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// A situação da opção, como etiqueta.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.option});

  final ResolvedMechanicOption option;

  @override
  Widget build(BuildContext context) {
    final color = switch (option.availability) {
      MechanicOptionAvailability.selected => AppColors.redContainer,
      MechanicOptionAvailability.granted => AppColors.redContainer,
      MechanicOptionAvailability.invalid => AppColors.error,
      MechanicOptionAvailability.blocked => AppColors.error,
      MechanicOptionAvailability.available => null,
    };

    if (color == null) return const SizedBox.shrink();

    return Container(
      key: ValueKey('manage-option-status-${option.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        option.isActive ? 'Ativa' : option.availability.label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.onRedContainer),
      ),
    );
  }
}

/// Um contador de usos, com os botões de gastar e devolver.
class _ResourceRow extends ConsumerWidget {
  const _ResourceRow({required this.character, required this.resource});

  final Character character;
  final FeatureResource resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    final subtitle = [
      if (resource.rechargeLabel case final value?) 'volta em $value',
      if (resource.cost case final value?) value,
    ].join(' • ');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resource.label, style: text.bodyMedium),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          key: ValueKey('mechanic-restore-${resource.featureId}'),
          tooltip: 'Devolver um uso',
          onPressed:
              resource.canRestore
                  ? () => ref.read(restoreClassMechanicUseProvider)(
                    character: character,
                    resource: resource,
                  )
                  : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
        SizedBox(
          width: 56,
          child: Text(
            resource.usesLabel,
            key: ValueKey('mechanic-uses-${resource.featureId}'),
            textAlign: TextAlign.center,
            style: text.titleSmall,
          ),
        ),
        IconButton(
          key: ValueKey('mechanic-spend-${resource.featureId}'),
          tooltip: 'Gastar um uso',
          onPressed:
              resource.canSpend
                  ? () => ref.read(spendClassMechanicUseProvider)(
                    character: character,
                    resource: resource,
                  )
                  : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
