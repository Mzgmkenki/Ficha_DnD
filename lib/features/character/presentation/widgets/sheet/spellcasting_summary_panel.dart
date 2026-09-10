import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/spellcasting_service.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:flutter/material.dart';

class SpellcastingSummaryPanel extends StatelessWidget {
  const SpellcastingSummaryPanel({
    required this.character,
    required this.classes,
    super.key,
  });

  final Character character;
  final List<ClassEntry> classes;

  @override
  Widget build(BuildContext context) {
    final classRows = _buildClassRows();
    final itemRows = _buildItemRows();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título fica no cabeçalho da seção, na ficha.
            if (classRows.isEmpty && itemRows.isEmpty)
              const Text(
                'Nenhuma fonte de conjuração identificada ainda.',
              )
            else ...[
              if (classRows.isNotEmpty) ...[
                Text(
                  'Classes',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...classRows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SummaryTile(
                      title: row.title,
                      lines: [
                        'Atributo: ${row.abilityLabel}',
                        'CD de magia: ${row.saveDc}',
                        'Ataque mágico: ${_signed(row.attackBonus)}',
                      ],
                    ),
                  ),
                ),
              ],
              if (classRows.isNotEmpty && itemRows.isNotEmpty)
                const SizedBox(height: 8),
              if (itemRows.isNotEmpty) ...[
                Text(
                  'Itens mágicos',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...itemRows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SummaryTile(
                      title: row.title,
                      lines: [
                        if (row.abilityLabel != null)
                          'Atributo: ${row.abilityLabel}',
                        'CD do item: ${row.saveDcLabel}',
                        'Ataque do item: ${row.attackBonusLabel}',
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  List<_ClassSpellcastingRow> _buildClassRows() {
    final rows = <_ClassSpellcastingRow>[];

    for (final classLevel in character.classLevels) {
      final classEntry = _findClassEntry(classLevel.classId);

      // Só conjuradores entram no painel. Antes, um Bárbaro puro aparecia
      // com "CD de magia" porque a checagem era apenas pelo atributo.
      if (classEntry != null && !classEntry.isSpellcaster) continue;

      // Meio-conjurador só conjura no nível 2, um-terço no 3.
      if (classEntry != null &&
          classLevel.level < classEntry.spellcastingStartLevel) {
        continue;
      }

      final ability = _resolveSpellcastingAbility(
        classId: classLevel.classId,
        classEntry: classEntry,
      );

      if (ability == null) continue;

      rows.add(
        _ClassSpellcastingRow(
          title:
              '${classEntry?.name ?? classLevel.classId} • Nv. ${classLevel.level}',
          abilityLabel: ability.label,
          saveDc: SpellcastingService.spellSaveDc(
            proficiencyBonus: character.proficiencyBonus,
            castingAbility: ability,
            scores: character.abilityScores,
          ),
          attackBonus: SpellcastingService.spellAttackBonus(
            proficiencyBonus: character.proficiencyBonus,
            castingAbility: ability,
            scores: character.abilityScores,
          ),
        ),
      );
    }

    return rows;
  }

  List<_ItemSpellcastingRow> _buildItemRows() {
    final rows = <_ItemSpellcastingRow>[];

    for (final item in character.magicItems) {
      if (item.spells.isEmpty) continue;

      if (item.saveDc == null &&
          item.attackBonus == null &&
          item.castingAbility == null) {
        continue;
      }

      rows.add(
        _ItemSpellcastingRow(
          title: item.name,
          abilityLabel: _castingAbilityLabel(item.castingAbility),
          saveDcLabel: item.saveDc?.toString() ?? 'Não definido',
          attackBonusLabel: item.attackBonus != null
              ? _signed(item.attackBonus!)
              : 'Não definido',
        ),
      );
    }

    return rows;
  }

  ClassEntry? _findClassEntry(String classId) {
    for (final item in classes) {
      if (item.id == classId) return item;
    }
    return null;
  }

  Ability? _resolveSpellcastingAbility({
    required String classId,
    required ClassEntry? classEntry,
  }) {
    // O campo dedicado tem prioridade. Usar `primaryAbility` aqui fazia o
    // Patrulheiro conjurar com Destreza em vez de Sabedoria.
    final declared = _parseAbility(classEntry?.spellcastingAbility);
    if (declared != null) return declared;

    switch (classId.trim().toLowerCase()) {
      case 'wizard':
      case 'mago':
      case 'artificer':
      case 'artífice':
      case 'eldritch_knight':
      case 'arcane_trickster':
        return Ability.intelligence;

      case 'cleric':
      case 'clérigo':
      case 'druid':
      case 'druida':
      case 'ranger':
      case 'patrulheiro':
        return Ability.wisdom;

      case 'bard':
      case 'bardo':
      case 'sorcerer':
      case 'feiticeiro':
      case 'warlock':
      case 'bruxo':
      case 'paladin':
      case 'paladino':
        return Ability.charisma;

      default:
        return null;
    }
  }

  Ability? _parseAbility(String? raw) {
    if (raw == null) return null;

    switch (raw.trim().toLowerCase()) {
      case 'strength':
      case 'força':
        return Ability.strength;
      case 'dexterity':
      case 'destreza':
        return Ability.dexterity;
      case 'constitution':
      case 'constituição':
        return Ability.constitution;
      case 'intelligence':
      case 'inteligência':
        return Ability.intelligence;
      case 'wisdom':
      case 'sabedoria':
        return Ability.wisdom;
      case 'charisma':
      case 'carisma':
        return Ability.charisma;
      default:
        return null;
    }
  }

  String? _castingAbilityLabel(String? raw) => _parseAbility(raw)?.label;

  String _signed(int value) {
    return value >= 0 ? '+$value' : '$value';
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.45),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(line),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassSpellcastingRow {
  const _ClassSpellcastingRow({
    required this.title,
    required this.abilityLabel,
    required this.saveDc,
    required this.attackBonus,
  });

  final String title;
  final String abilityLabel;
  final int saveDc;
  final int attackBonus;
}

class _ItemSpellcastingRow {
  const _ItemSpellcastingRow({
    required this.title,
    required this.abilityLabel,
    required this.saveDcLabel,
    required this.attackBonusLabel,
  });

  final String title;
  final String? abilityLabel;
  final String saveDcLabel;
  final String attackBonusLabel;
}