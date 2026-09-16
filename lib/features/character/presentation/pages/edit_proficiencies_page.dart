import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProficienciesPage extends ConsumerStatefulWidget {
  const EditProficienciesPage({
    required this.characterId,
    required this.initialSavingThrows,
    required this.initialSkills,
    super.key,
  });

  final String characterId;
  final SavingThrowProficiencies initialSavingThrows;
  final SkillProficiencies initialSkills;

  @override
  ConsumerState<EditProficienciesPage> createState() =>
      _EditProficienciesPageState();
}

class _EditProficienciesPageState extends ConsumerState<EditProficienciesPage> {
  late bool _saveStrength;
  late bool _saveDexterity;
  late bool _saveConstitution;
  late bool _saveIntelligence;
  late bool _saveWisdom;
  late bool _saveCharisma;

  /// Nível escolhido por perícia. Substitui os 18 booleanos anteriores.
  final Map<Skill, ProficiencyLevel> _skillLevels = {};

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _saveStrength = widget.initialSavingThrows.strength;
    _saveDexterity = widget.initialSavingThrows.dexterity;
    _saveConstitution = widget.initialSavingThrows.constitution;
    _saveIntelligence = widget.initialSavingThrows.intelligence;
    _saveWisdom = widget.initialSavingThrows.wisdom;
    _saveCharisma = widget.initialSavingThrows.charisma;

    for (final skill in Skill.values) {
      _skillLevels[skill] = widget.initialSkills.levelFor(skill);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skills = Skill.sortedByLabel;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar proficiências')),
      body: ListView(
        padding: context.scrollContentPadding(),
        children: [
          Text('Salvaguardas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildSwitchTile(
            title: 'Força',
            value: _saveStrength,
            onChanged: (value) => setState(() => _saveStrength = value),
          ),
          _buildSwitchTile(
            title: 'Destreza',
            value: _saveDexterity,
            onChanged: (value) => setState(() => _saveDexterity = value),
          ),
          _buildSwitchTile(
            title: 'Constituição',
            value: _saveConstitution,
            onChanged: (value) => setState(() => _saveConstitution = value),
          ),
          _buildSwitchTile(
            title: 'Inteligência',
            value: _saveIntelligence,
            onChanged: (value) => setState(() => _saveIntelligence = value),
          ),
          _buildSwitchTile(
            title: 'Sabedoria',
            value: _saveWisdom,
            onChanged: (value) => setState(() => _saveWisdom = value),
          ),
          _buildSwitchTile(
            title: 'Carisma',
            value: _saveCharisma,
            onChanged: (value) => setState(() => _saveCharisma = value),
          ),
          const SizedBox(height: 24),
          Text('Perícias', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Especialista dobra o bônus de proficiência. Meia proficiência '
            'soma metade (arredondada para baixo).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ...skills.map(_buildSkillTile),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_saving ? 'Salvando...' : 'Salvar proficiências'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillTile(Skill skill) {
    final current = _skillLevels[skill] ?? ProficiencyLevel.none;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${skill.label} (${skill.abbreviation})'),
          const SizedBox(height: 6),
          SegmentedButton<ProficiencyLevel>(
            segments: const [
              ButtonSegment(
                value: ProficiencyLevel.none,
                label: Text('—'),
                tooltip: 'Sem proficiência',
              ),
              ButtonSegment(
                value: ProficiencyLevel.half,
                label: Text('½'),
                tooltip: 'Meia proficiência',
              ),
              ButtonSegment(
                value: ProficiencyLevel.proficient,
                label: Text('P'),
                tooltip: 'Proficiente',
              ),
              ButtonSegment(
                value: ProficiencyLevel.expertise,
                label: Text('E'),
                tooltip: 'Especialista',
              ),
            ],
            selected: {current},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              setState(() => _skillLevels[skill] = selection.first);
            },
            showSelectedIcon: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });

    try {
      final useCase = ref.read(updateCharacterProficienciesProvider);

      await useCase(
        characterId: widget.characterId,
        savingThrowProficiencies: SavingThrowProficiencies(
          strength: _saveStrength,
          dexterity: _saveDexterity,
          constitution: _saveConstitution,
          intelligence: _saveIntelligence,
          wisdom: _saveWisdom,
          charisma: _saveCharisma,
        ),
        skillProficiencies: SkillProficiencies(levels: Map.of(_skillLevels)),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar proficiências: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}
