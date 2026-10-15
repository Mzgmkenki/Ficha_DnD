import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/feature_providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_character_feats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_score_improvement.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/services/ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feat_eligibility.dart';
import 'package:dnd_ficha_app/features/character/domain/services/level_progression_choices.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/ability_score_improvement_dialog.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/level_progression_choice_dialog.dart';
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
          data: (classes) => featsAsync.when(
            data: (catalog) => racesAsync.when(
              // A raça só é necessária para o filtro de pré-requisito, então
              // uma falha ao carregá-la não pode esconder a seção inteira: cai
              // numa lista vazia e os talentos de raça simplesmente não passam.
              data: (races) => _content(context, ref, classes, catalog, races),
              error: (_, __) =>
                  _content(context, ref, classes, catalog, const []),
              loading: () => const Center(child: CircularProgressIndicator()),
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

    final slots = LevelProgressionChoices.forCharacter(
      character,
      classes,
      races: races,
    );
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
                onRemove: () => _removeImprovement(context, ref, improvement),
                onSwapToFeat: catalog.isEmpty
                    ? null
                    : () => _swapImprovementForFeat(
                          context,
                          ref,
                          classes,
                          catalog,
                          races,
                          improvement,
                        ),
              )
            else if (slot.feat case final feat?)
              _FeatTile(
                feat: feat,
                slotLabel: slot.fromRace ? 'Raça' : slot.label,
                entry: _entryFor(catalog, feat.featId),
                onRemove: () => _remove(context, ref, feat),
                onSwapToImprovement: slot.allowsImprovement
                    ? () => _swapFeatForImprovement(context, ref, slot, feat)
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
              onPressed: () => _chooseProgression(
                context,
                ref,
                classes,
                catalog,
                races,
                pending.first,
              ),
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

  /// Pergunta o que fazer com a vaga e encaminha para o fluxo escolhido.
  Future<void> _chooseProgression(
    BuildContext context,
    WidgetRef ref,
    List<ClassEntry> classes,
    List<FeatEntry> catalog,
    List<RaceEntry> races,
    LevelProgressionSlot slot,
  ) async {
    final available = _availableFeats(classes, catalog, races);

    // Vaga que não aceita incremento e sem talento elegível não tem o que
    // oferecer: avisa em vez de abrir um diálogo vazio.
    if (!slot.allowsImprovement && available.isEmpty) {
      _notify(context, _noFeatsMessage);
      return;
    }

    final decision = await showLevelProgressionChoiceDialog(
      context: context,
      slot: slot,
      canChooseFeat: available.isNotEmpty,
      featUnavailableReason: _noFeatsMessage,
    );

    if (decision == null || !context.mounted) return;

    switch (decision) {
      case LevelProgressionDecision.feat:
        await _add(context, ref, classes, catalog, races, slot);
      case LevelProgressionDecision.improvement:
        await _addImprovement(context, ref, slot);
    }
  }

  /// Abre a distribuição e grava o incremento na vaga.
  Future<void> _addImprovement(
    BuildContext context,
    WidgetRef ref,
    LevelProgressionSlot slot, {
    CharacterFeat? replacing,
  }) async {
    final maximums = await _maximums(ref);
    if (!context.mounted) return;

    // Ao trocar um talento que dava atributo, o teto é conferido contra a
    // ficha JÁ sem ele: o ponto que o talento ocupava volta a ser folga.
    final current = replacing == null
        ? character.abilityScores
        : _withoutFeatIncreases(replacing);

    final draft = await showAbilityScoreImprovementDialog(
      context: context,
      current: current,
      slotLabel: slot.label,
      maximums: maximums,
    );

    if (draft == null || !context.mounted) return;

    final useCase = ref.read(manageAbilityScoreImprovementsProvider);

    try {
      final outcome = replacing == null
          ? await useCase.choose(
              characterId: character.id,
              classId: slot.classId,
              classLevel: slot.classLevel,
              increases: draft.increases,
              maximums: maximums,
            )
          : await useCase.replaceFeat(
              characterId: character.id,
              featLocalId: replacing.localId!,
              classId: slot.classId,
              classLevel: slot.classLevel,
              increases: draft.increases,
              maximums: maximums,
            );

      if (!context.mounted) return;
      _notify(
        context,
        '${slot.label} — Incremento no Valor de Atributo: '
        '${outcome.appliedLabel}.'
        '${outcome.unequippedArmorNotice == null ? '' : ' '
            '${outcome.unequippedArmorNotice}'}',
      );
    } catch (error) {
      if (!context.mounted) return;
      _notify(context, 'Não deu para registrar o incremento: $error');
    }
  }

  /// Troca um talento já escolhido por um incremento, na mesma vaga.
  Future<void> _swapFeatForImprovement(
    BuildContext context,
    WidgetRef ref,
    LevelProgressionSlot slot,
    CharacterFeat feat,
  ) async {
    if (feat.localId == null) {
      _notify(context, 'Salve a ficha antes de trocar este talento.');
      return;
    }

    final confirmed = await _confirm(
      context,
      title: 'Trocar por incremento?',
      message: 'O talento sai da ficha e o que ele concedeu é desfeito: '
          'proficiências que só ele dava e o aumento de atributo dele. '
          'Depois você distribui os pontos do incremento.',
      confirmLabel: 'Trocar',
    );

    if (!confirmed || !context.mounted) return;

    await _addImprovement(context, ref, slot, replacing: feat);
  }

  /// Troca um incremento por um talento, na mesma vaga.
  ///
  /// Em dois passos, e não numa gravação só: o estado intermediário — vaga
  /// pendente, pontos devolvidos — é um estado VÁLIDO da ficha. Se a escolha
  /// do talento for cancelada no meio, o personagem fica coerente e a ficha
  /// volta a oferecer a escolha.
  Future<void> _swapImprovementForFeat(
    BuildContext context,
    WidgetRef ref,
    List<ClassEntry> classes,
    List<FeatEntry> catalog,
    List<RaceEntry> races,
    AbilityScoreImprovement improvement,
  ) async {
    final localId = improvement.localId;
    if (localId == null) {
      _notify(context, 'Salve a ficha antes de trocar este incremento.');
      return;
    }

    final confirmed = await _confirm(
      context,
      title: 'Trocar por talento?',
      message: improvement.isEmpty
          ? 'O incremento sai da ficha e a escolha volta a ficar em aberto.'
          : 'Os pontos deste incremento (${improvement.increasesLabel}) '
              'voltam. Bônus de origem, itens e incrementos de outros níveis '
              'não são tocados.',
      confirmLabel: 'Trocar',
    );

    if (!confirmed || !context.mounted) return;

    try {
      final outcome = await ref
          .read(manageAbilityScoreImprovementsProvider)
          .remove(characterId: character.id, localId: localId);

      if (!context.mounted) return;

      if (outcome.unequippedArmorNotice case final notice?) {
        _notify(context, notice);
      }
    } catch (error) {
      if (!context.mounted) return;
      _notify(context, 'Não deu para remover o incremento: $error');
      return;
    }

    if (!context.mounted) return;

    final slot = LevelProgressionSlot(
      classId: improvement.classId,
      className: _classNameFor(classes, improvement.classId),
      classLevel: improvement.classLevel,
    );

    await _add(context, ref, classes, catalog, races, slot);
  }

  Future<void> _removeImprovement(
    BuildContext context,
    WidgetRef ref,
    AbilityScoreImprovement improvement,
  ) async {
    final localId = improvement.localId;
    if (localId == null) return;

    final confirmed = await _confirm(
      context,
      title: 'Remover incremento?',
      message: improvement.isEmpty
          ? 'A escolha volta a ficar em aberto.'
          : 'Os pontos (${improvement.increasesLabel}) voltam, e a escolha '
              'deste nível fica em aberto de novo.',
      confirmLabel: 'Remover',
    );

    if (!confirmed || !context.mounted) return;

    try {
      final outcome = await ref
          .read(manageAbilityScoreImprovementsProvider)
          .remove(characterId: character.id, localId: localId);

      if (!context.mounted) return;
      if (outcome.unequippedArmorNotice case final notice?) {
        _notify(context, notice);
      }
    } catch (error) {
      if (!context.mounted) return;
      _notify(context, 'Não deu para remover o incremento: $error');
    }
  }

  /// Os atributos como ficariam sem o aumento que o talento havia dado.
  AbilityScores _withoutFeatIncreases(CharacterFeat feat) {
    return AbilityScoreImprovements.revoke(
      character.abilityScores,
      feat.appliedAbilityIncreases,
    );
  }

  /// O teto de cada atributo, com as exceções de característica.
  ///
  /// Falha de leitura do compêndio cai no teto padrão em vez de impedir a
  /// escolha: 20 é o limite da regra, e é o certo em todos os casos menos a
  /// exceção declarada.
  Future<Map<Ability, int>> _maximums(WidgetRef ref) async {
    try {
      return await ref.read(abilityMaximumsProvider(character).future);
    } catch (_) {
      return const {};
    }
  }

  static const String _noFeatsMessage =
      'Nenhum talento disponível: o personagem não cumpre os pré-requisitos '
      'dos que restam.';

  static String _classNameFor(List<ClassEntry> classes, String classId) {
    for (final entry in classes) {
      if (entry.id == classId) return entry.name;
    }
    return classId;
  }

  List<FeatEntry> _availableFeats(
    List<ClassEntry> classes,
    List<FeatEntry> catalog,
    List<RaceEntry> races,
  ) {
    if (catalog.isEmpty) return const [];

    return FeatEligibility.available(
      feats: catalog,
      character: character,
      classes: classes,
      races: races,
    );
  }

  static void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return answer ?? false;
  }

  static FeatEntry? _entryFor(List<FeatEntry> catalog, String id) {
    for (final item in catalog) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    List<ClassEntry> classes,
    List<FeatEntry> catalog,
    List<RaceEntry> races,
    LevelProgressionSlot? slot,
  ) async {
    // Só entra na lista o que o personagem alcança. `available` também descarta
    // o talento não repetível que ele já tem, senão o caso de uso recusaria
    // depois de o jogador ter escolhido.
    //
    // As classes vêm por parâmetro, não de um `ref.read`: elas já foram
    // carregadas para montar o painel, e reler daria uma lista vazia se o
    // provider tivesse sido invalidado no meio — o que faria todo talento de
    // conjurador desaparecer sem motivo.
    final available = FeatEligibility.available(
      feats: catalog,
      character: character,
      classes: classes,
      races: races,
    );

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhum talento disponível: o personagem não cumpre os '
            'pré-requisitos dos que restam.',
          ),
        ),
      );
      return;
    }

    final choice = await showDialog<_FeatChoice>(
      context: context,
      builder: (context) => _FeatPickerDialog(available: available),
    );

    if (choice == null) return;

    // A vaga diz exatamente qual classe e qual NÍVEL DA CLASSE concederam a
    // escolha. Antes era gravado o nível TOTAL do personagem, que no
    // multiclasse não corresponde a vaga nenhuma — e por isso a ficha não
    // conseguia dizer em que nível cada talento tinha sido pego.
    final classId = slot != null && !slot.fromRace
        ? slot.classId
        : (character.classLevels.length == 1
              ? character.classLevels.single.classId
              : null);

    final level = slot != null && !slot.fromRace
        ? slot.classLevel
        : (classId == null ? null : character.totalLevel);

    try {
      await ref.read(manageCharacterFeatsProvider).addFeat(
            characterId: character.id,
            feat: choice.feat,
            chosenSkills: choice.skills,
            chosenAbility: choice.ability,
            classId: classId,
            level: level,
          );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não deu para adicionar o talento: $error')),
      );
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    CharacterFeat feat,
  ) async {
    final localId = feat.localId;
    if (localId == null) return;

    try {
      await ref.read(manageCharacterFeatsProvider).removeFeat(
            characterId: character.id,
            localId: localId,
          );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não deu para remover o talento: $error')),
      );
    }
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

/// O que o jogador decidiu no diálogo.
class _FeatChoice {
  const _FeatChoice({required this.feat, required this.skills, this.ability});

  final FeatEntry feat;
  final List<Skill> skills;

  /// Atributo escolhido, nos talentos que oferecem "+1 em X ou Y".
  final Ability? ability;
}

class _FeatPickerDialog extends StatefulWidget {
  const _FeatPickerDialog({required this.available});

  final List<FeatEntry> available;

  @override
  State<_FeatPickerDialog> createState() => _FeatPickerDialogState();
}

class _FeatPickerDialogState extends State<_FeatPickerDialog> {
  FeatEntry? _selected;
  final Set<Skill> _skills = {};
  Ability? _ability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;
    final choice = selected?.skillChoice;
    final toChoose = selected?.skillsToChoose ?? 0;
    final abilityOptions = selected?.abilityOptions ?? const <Ability>[];

    // Talento com escolha de atributo só fica completo depois de escolher: sem
    // essa trava o jogador confirmaria e perderia o +1 sem perceber.
    final complete = selected != null &&
        _skills.length == toChoose &&
        (abilityOptions.isEmpty || _ability != null);

    return AlertDialog(
      title: const Text('Escolher talento'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              key: const ValueKey('feat-dropdown'),
              initialValue: selected?.id,
              decoration: const InputDecoration(labelText: 'Talento'),
              // Sem `isExpanded` o dropdown se dimensiona pelo item mais largo.
              // Com 105 talentos, nomes como "Descendente dos Planos
              // Exteriores" passam da largura do diálogo, o texto quebra em
              // duas linhas e estoura a altura fixa do campo.
              isExpanded: true,
              items: [
                for (final feat in widget.available)
                  DropdownMenuItem(
                    value: feat.id,
                    child: Text(
                      feat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (id) {
                setState(() {
                  _selected = _find(id);
                  // Trocar de talento zera as escolhas: as opções do anterior
                  // não valem para o novo.
                  _skills.clear();
                  _ability = null;
                });
              },
            ),

            if (selected?.description case final text? when text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(text, style: theme.textTheme.bodySmall),
              ),

            // Só o que o app não confere. O que ele confere já filtrou a lista,
            // então repetir aqui seria ruído.
            if (selected != null && selected.requires.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Confirme à mão: ${selected.requires.notes.join('; ')}.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            if (abilityOptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Escolha o atributo que recebe +1:'),
              // O grupo vive num ancestral, e não em cada item: `groupValue` e
              // `onChanged` do RadioListTile foram depreciados depois do
              // Flutter 3.32 em favor do RadioGroup.
              RadioGroup<Ability>(
                groupValue: _ability,
                onChanged: (picked) => setState(() => _ability = picked),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final ability in abilityOptions)
                      RadioListTile<Ability>(
                        key: ValueKey('feat-ability-${ability.name}'),
                        value: ability,
                        title: Text(ability.label),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                  ],
                ),
              ),
            ],

            if (choice != null) ...[
              const SizedBox(height: 12),
              Text(
                toChoose == 1
                    ? 'Escolha 1 perícia:'
                    : 'Escolha $toChoose perícias:',
              ),
              for (final skill in choice.skills)
                CheckboxListTile(
                  key: ValueKey('feat-skill-${skill.id}'),
                  value: _skills.contains(skill),
                  title: Text(skill.label),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) {
                    setState(() {
                      if (checked ?? false) {
                        // Trava no limite em vez de desmarcar outra: desmarcar
                        // escondido faria o jogador perder a escolha anterior
                        // sem entender por quê.
                        if (_skills.length < toChoose) _skills.add(skill);
                      } else {
                        _skills.remove(skill);
                      }
                    });
                  },
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: !complete
              ? null
              : () => Navigator.of(context).pop(
                    _FeatChoice(
                      feat: selected,
                      skills: _skills.toList(growable: false),
                      ability: _ability,
                    ),
                  ),
          child: const Text('Adicionar'),
        ),
      ],
    );
  }

  FeatEntry? _find(String? id) {
    if (id == null) return null;
    for (final feat in widget.available) {
      if (feat.id == id) return feat;
    }
    return null;
  }
}
