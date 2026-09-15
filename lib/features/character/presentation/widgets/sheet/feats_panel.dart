import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/manage_character_feats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feat_eligibility.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Talentos do personagem, com quantas escolhas ainda faltam.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          allowance.granted == 0
              ? 'Nenhuma classe deste personagem chegou a um nível de talento '
                  'ainda.'
              : 'Escolhas de talento: ${allowance.taken} de '
                  '${allowance.granted} usadas.',
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

        if (character.feats.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final feat in character.feats)
            _FeatTile(
              feat: feat,
              entry: _entryFor(catalog, feat.featId),
              onRemove: () => _remove(context, ref, feat),
            ),
        ],

        if (allowance.hasPending && catalog.isNotEmpty) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              key: const ValueKey('add-feat'),
              onPressed: () => _add(context, ref, classes, catalog, races),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Escolher talento'),
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

  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    List<ClassEntry> classes,
    List<FeatEntry> catalog,
    List<RaceEntry> races,
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

    // A classe que concedeu: com uma classe só não há dúvida. No multiclasse
    // fica sem classe, porque a contagem de escolhas é somada e não por linha.
    final classId = character.classLevels.length == 1
        ? character.classLevels.single.classId
        : null;

    try {
      await ref.read(manageCharacterFeatsProvider).addFeat(
            characterId: character.id,
            feat: choice.feat,
            chosenSkills: choice.skills,
            classId: classId,
            level: classId == null ? null : character.totalLevel,
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

class _FeatTile extends StatelessWidget {
  const _FeatTile({
    required this.feat,
    required this.entry,
    required this.onRemove,
  });

  final CharacterFeat feat;
  final FeatEntry? entry;
  final VoidCallback onRemove;

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
                  entry?.name ?? feat.featId,
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
              ],
            ),
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
}

/// O que o jogador decidiu no diálogo.
class _FeatChoice {
  const _FeatChoice({required this.feat, required this.skills});

  final FeatEntry feat;
  final List<Skill> skills;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;
    final choice = selected?.skillChoice;
    final toChoose = selected?.skillsToChoose ?? 0;
    final complete = selected != null && _skills.length == toChoose;

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
