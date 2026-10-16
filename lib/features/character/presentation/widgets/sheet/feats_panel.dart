import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_character_feats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_score_improvement.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/services/level_progression_choices.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/level_progression_flow.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Talentos e Incrementos no Valor de Atributo do personagem.
///
/// As duas coisas moram no mesmo painel porque disputam a MESMA escolha de
/// nível: o nível concede "um incremento ou um talento". Separá-las em duas
/// seções faria o jogador somar de cabeça para descobrir quantas escolhas
/// ainda tem.
///
/// As perícias que o talento concede entram na ficha na hora, e é isso que o
/// painel mostra abaixo de cada talento — para o jogador entender de onde veio
/// a proficiência nova.
///
/// A sequência de janelas não mora aqui: ela é de [LevelProgressionFlow], que
/// a subida de nível também usa. O painel só decide o que MOSTRAR e para qual
/// vaga pedir a decisão.
class FeatsPanel extends ConsumerWidget {
  const FeatsPanel({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classEntriesProvider);
    final featsAsync = ref.watch(featEntriesProvider);
    final racesAsync = ref.watch(raceEntriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: classesAsync.when(
          data:
              (classes) => featsAsync.when(
                data:
                    (catalog) => racesAsync.when(
                      // A raça só é necessária para o filtro de pré-requisito, então
                      // uma falha ao carregá-la não pode esconder a seção inteira: cai
                      // numa lista vazia e os talentos de raça simplesmente não passam.
                      data:
                          (races) =>
                              _content(context, ref, classes, catalog, races),
                      error:
                          (_, __) => _content(
                            context,
                            ref,
                            classes,
                            catalog,
                            const [],
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                    ),
                error: (error, _) => Text('Erro ao carregar talentos: $error'),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
          error: (error, _) => Text('Erro ao carregar classes: $error'),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    List<ClassEntry> classes,
    List<FeatEntry> catalog,
    List<RaceEntry> races,
  ) {
    final allowance = ManageCharacterFeats.allowanceFor(
      character,
      classes,
      races: races,
    );
    final theme = Theme.of(context);

    // As listas vêm por parâmetro, não de um `ref.read`: elas já foram
    // carregadas para montar o painel, e reler daria uma lista vazia se o
    // provider tivesse sido invalidado no meio — o que faria todo talento de
    // conjurador desaparecer sem motivo.
    final flow = LevelProgressionFlow(
      ref: ref,
      character: character,
      classes: classes,
      catalog: catalog,
      races: races,
    );

    final slots = flow.slots;
    final pending = slots.where((slot) => slot.isPending).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          allowance.granted == 0
              ? 'Nenhuma classe deste personagem chegou a um nível de talento '
                  'ainda.'
              : 'Escolhas de nível: ${allowance.taken} de '
                  '${allowance.granted} usadas '
                  '(${allowance.feats} talento(s), '
                  '${allowance.improvements} incremento(s)).',
          style: theme.textTheme.bodyMedium,
        ),

        // Sem esta linha, um Humano Variante de 1º nível veria uma escolha
        // disponível sem nada na ficha explicando de onde ela veio.
        if (allowance.fromRace)
          Text(
            'Uma delas vem da raça, que concede um talento no 1º nível.',
            style: theme.textTheme.bodySmall,
          ),

        if (catalog.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'O catálogo de talentos está vazio. Assim que os dados entrarem em '
            'assets/data/srd/feats.json eles aparecem aqui.',
            style: theme.textTheme.bodySmall,
          ),
        ],

        // Histórico por vaga: é o que responde "o que eu escolhi no Guerreiro
        // 4?" sem o jogador cruzar duas listas.
        if (slots.any((slot) => !slot.isPending)) ...[
          const SizedBox(height: 12),
          for (final slot in slots)
            if (slot.improvement case final improvement?)
              _ImprovementTile(
                slot: slot,
                improvement: improvement,
                onRemove: () => flow.removeImprovement(context, improvement),
                onSwapToFeat:
                    catalog.isEmpty
                        ? null
                        : () =>
                            flow.swapImprovementForFeat(context, improvement),
              )
            else if (slot.feat case final feat?)
              _FeatTile(
                feat: feat,
                slotLabel: slot.label,
                entry: _entryFor(catalog, feat.featId),
                onRemove: () => flow.removeFeat(context, feat),
                onSwapToImprovement:
                    slot.allowsImprovement
                        ? () => flow.swapFeatForImprovement(context, slot, feat)
                        : null,
              ),
        ],

        if (pending.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            pending.length == 1
                ? 'Escolha pendente: ${pending.first.label}.'
                : '${pending.length} escolhas pendentes: '
                    '${pending.map((slot) => slot.label).join(', ')}.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              // A chave antiga é mantida: o botão continua sendo o mesmo ponto
              // de entrada, agora com as duas opções em vez de só talento.
              key: const ValueKey('add-feat'),
              onPressed: () => flow.chooseFor(context, pending.first),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(
                pending.first.allowsImprovement
                    ? 'Escolher talento ou incremento'
                    : 'Escolher talento',
              ),
            ),
          ),
        ],
      ],
    );
  }

  static FeatEntry? _entryFor(List<FeatEntry> catalog, String id) {
    for (final item in catalog) {
      if (item.id == id) return item;
    }
    return null;
  }
}

/// Um Incremento no Valor de Atributo já registrado.
///
/// Mostra a vaga e o resultado, que é a informação que a ficha precisa dar:
/// "Guerreiro 4 — Incremento no Valor de Atributo: Força +2".
class _ImprovementTile extends StatelessWidget {
  const _ImprovementTile({
    required this.slot,
    required this.improvement,
    required this.onRemove,
    this.onSwapToFeat,
  });

  final LevelProgressionSlot slot;
  final AbilityScoreImprovement improvement;
  final VoidCallback onRemove;
  final VoidCallback? onSwapToFeat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.label} — Incremento no Valor de Atributo',
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  improvement.isEmpty
                      // Dizer isso é melhor que omitir: senão o jogador acha
                      // que o app esqueceu de aplicar os pontos.
                      ? 'Os atributos escolhidos já estavam no máximo, sem '
                          'aumento.'
                      : improvement.increasesLabel,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (onSwapToFeat case final swap?)
            IconButton(
              key: ValueKey('swap-improvement-${improvement.localId}'),
              tooltip: 'Trocar por talento',
              onPressed: swap,
              icon: const Icon(Icons.swap_horiz),
            ),
          IconButton(
            key: ValueKey('remove-improvement-${improvement.localId}'),
            tooltip: 'Remover incremento',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _FeatTile extends StatelessWidget {
  const _FeatTile({
    required this.feat,
    required this.entry,
    required this.onRemove,
    this.slotLabel,
    this.onSwapToImprovement,
  });

  final CharacterFeat feat;
  final FeatEntry? entry;
  final VoidCallback onRemove;

  /// Vaga que o talento ocupa: `Guerreiro 4`.
  final String? slotLabel;

  final VoidCallback? onSwapToImprovement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final granted = feat.grantedSkills;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Id cru como fallback: um talento removido do compêndio não
                  // pode virar uma linha em branco na ficha.
                  slotLabel == null
                      ? (entry?.name ?? feat.featId)
                      : '$slotLabel — Talento: '
                          '${entry?.name ?? feat.featId}',
                  style: theme.textTheme.titleSmall,
                ),
                if (entry?.description case final text?
                    when text.trim().isNotEmpty)
                  Text(text, style: theme.textTheme.bodySmall),
                if (granted.isNotEmpty)
                  Text(
                    'Proficiência concedida: '
                    '${granted.map((skill) => skill.label).join(', ')}',
                    style: theme.textTheme.bodySmall,
                  ),
                if (_abilityLine(feat) case final line?)
                  Text(line, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (onSwapToImprovement case final swap?)
            IconButton(
              key: ValueKey('swap-feat-${feat.localId}'),
              tooltip: 'Trocar por Incremento no Valor de Atributo',
              onPressed: swap,
              icon: const Icon(Icons.swap_horiz),
            ),
          IconButton(
            tooltip: 'Remover talento',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  /// Linha do aumento de atributo, ou nulo quando não há o que dizer.
  ///
  /// Quando o talento tinha escolha mas nada entrou, o atributo já estava no
  /// teto de 20 — dizer isso é melhor que omitir, senão o jogador acha que o
  /// app esqueceu de aplicar.
  static String? _abilityLine(CharacterFeat feat) {
    final applied = feat.appliedAbilityIncreases;

    if (applied.isNotEmpty) {
      final parts = [
        for (final entry in applied.entries)
          if (Ability.fromName(entry.key) case final ability?)
            '${ability.label} +${entry.value}',
      ];

      if (parts.isNotEmpty) return 'Atributo: ${parts.join(', ')}';
    }

    if (feat.chosenAbility case final ability?) {
      return '${ability.label} já estava no máximo de 20, sem aumento.';
    }

    return null;
  }
}
