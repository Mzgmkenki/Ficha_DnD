import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RacialTraitsPanel extends ConsumerWidget {
  const RacialTraitsPanel({
    required this.speciesId,
    super.key,
  });

  final String? speciesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (speciesId == null || speciesId!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Nenhuma raça vinculada ao personagem.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final racesAsync = ref.watch(raceEntriesProvider);

    return racesAsync.when(
      data: (races) {
        final selectedRace = _findRaceById(races, speciesId!);

        if (selectedRace == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Raça não encontrada no compêndio.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final combinedRace = _buildCombinedRaceData(races, selectedRace);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Características Raciais',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                Text(
                  combinedRace.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                if (combinedRace.description != null &&
                    combinedRace.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(combinedRace.description!),
                ],

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      label: 'Tipo',
                      value: _translateCreatureType(combinedRace.creatureType),
                    ),
                    _InfoChip(
                      label: 'Tamanho',
                      value: _translateSize(combinedRace.size),
                    ),
                    _InfoChip(
                      label: 'Deslocamento',
                      value: '${combinedRace.speed ?? 9}m',
                    ),
                    if (combinedRace.darkvision != null)
                      _InfoChip(
                        label: 'Visão no Escuro',
                        value: '${combinedRace.darkvision}m',
                      ),
                  ],
                ),

                if (combinedRace.languages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Idiomas',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(combinedRace.languages.join(', ')),
                ],

                const SizedBox(height: 12),

                Text(
                  'Bônus de atributos',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),

                if (combinedRace.fixedAbilityBonuses.isEmpty)
                  const Text('Sem bônus de atributos definidos.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: combinedRace.fixedAbilityBonuses.entries.map(
                      (entry) {
                        return Chip(
                          label: Text(
                            '${_abilityShortLabel(entry.key)} +${entry.value}',
                          ),
                        );
                      },
                    ).toList(),
                  ),

                const SizedBox(height: 12),

                Text(
                  'Características',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),

                if (combinedRace.traits.isEmpty)
                  const Text('Nenhuma característica racial cadastrada.')
                else
                  ...combinedRace.traits.map(
                    (trait) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(trait)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Erro ao carregar características raciais: $error'),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  RaceEntry? _findRaceById(List<RaceEntry> races, String id) {
    for (final race in races) {
      if (race.id == id) return race;
    }
    return null;
  }

  _CombinedRaceData _buildCombinedRaceData(
    List<RaceEntry> races,
    RaceEntry selectedRace,
  ) {
    final isSubrace =
    selectedRace.isSubrace ||
    (selectedRace.parentRaceId != null &&
        selectedRace.parentRaceId!.trim().isNotEmpty);

    if (!isSubrace || selectedRace.parentRaceId == null) {
      return _CombinedRaceData.fromSingleRace(selectedRace);
    }

    final baseRace = _findRaceById(races, selectedRace.parentRaceId!);

    if (baseRace == null) {
      return _CombinedRaceData.fromSingleRace(selectedRace);
    }

    final bonuses = <String, int>{};

    for (final entry in baseRace.fixedAbilityBonuses.entries) {
      bonuses[entry.key] = (bonuses[entry.key] ?? 0) + entry.value;
    }

    for (final entry in selectedRace.fixedAbilityBonuses.entries) {
      bonuses[entry.key] = (bonuses[entry.key] ?? 0) + entry.value;
    }

    final traits = <String>[
      ...baseRace.traits,
      ...selectedRace.traits,
    ];

    final languages = <String>{
      ...baseRace.languages,
      ...selectedRace.languages,
    }.toList(growable: false);

    final descriptionParts = <String>[
      if (baseRace.description != null &&
          baseRace.description!.trim().isNotEmpty)
        baseRace.description!,
      if (selectedRace.description != null &&
          selectedRace.description!.trim().isNotEmpty)
        selectedRace.description!,
    ];

    return _CombinedRaceData(
      name: '${baseRace.name} — ${selectedRace.name}',
      description:
          descriptionParts.isEmpty ? null : descriptionParts.join('\n\n'),
      size: selectedRace.size ?? baseRace.size,
      speed: selectedRace.speed ?? baseRace.speed,
      creatureType: selectedRace.creatureType ?? baseRace.creatureType,
      darkvision: selectedRace.darkvision ?? baseRace.darkvision,
      fixedAbilityBonuses: bonuses,
      traits: traits,
      languages: languages,
    );
  }

  String _abilityShortLabel(String key) {
    const labels = <String, String>{
      'strength': 'FOR',
      'dexterity': 'DES',
      'constitution': 'CON',
      'intelligence': 'INT',
      'wisdom': 'SAB',
      'charisma': 'CAR',
      'dois_atributos_escolhidos': '2 atributos',
      'um_escolhido': '1 atributo',
    };

    return labels[key] ?? key;
  }

  String _translateCreatureType(String? value) {
    switch (value) {
      case 'humanoid':
        return 'Humanoide';
      case 'fey':
        return 'Feérico';
      case 'construct':
        return 'Construto';
      case 'ooze':
        return 'Gosma';
      case 'monstrosity':
        return 'Monstruosidade';
      default:
        return 'Humanoide';
    }
  }

  String _translateSize(String? value) {
    switch (value) {
      case 'small':
        return 'Pequeno';
      case 'medium':
        return 'Médio';
      case 'large':
        return 'Grande';
      default:
        return 'Não definido';
    }
  }
}

class _CombinedRaceData {
  const _CombinedRaceData({
    required this.name,
    required this.fixedAbilityBonuses,
    required this.traits,
    required this.languages,
    this.description,
    this.size,
    this.speed,
    this.creatureType,
    this.darkvision,
  });

  factory _CombinedRaceData.fromSingleRace(RaceEntry race) {
    return _CombinedRaceData(
      name: race.name,
      description: race.description,
      size: race.size,
      speed: race.speed,
      creatureType: race.creatureType,
      darkvision: race.darkvision,
      fixedAbilityBonuses: race.fixedAbilityBonuses,
      traits: race.traits,
      languages: race.languages,
    );
  }

  final String name;
  final String? description;
  final String? size;
  final int? speed;
  final String? creatureType;
  final int? darkvision;
  final Map<String, int> fixedAbilityBonuses;
  final List<String> traits;
  final List<String> languages;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
    );
  }
}