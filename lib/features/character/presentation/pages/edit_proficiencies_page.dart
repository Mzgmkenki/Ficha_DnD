import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
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

class _EditProficienciesPageState
    extends ConsumerState<EditProficienciesPage> {
  late bool _saveStrength;
  late bool _saveDexterity;
  late bool _saveConstitution;
  late bool _saveIntelligence;
  late bool _saveWisdom;
  late bool _saveCharisma;

  late bool _acrobatics;
  late bool _animalHandling;
  late bool _arcana;
  late bool _athletics;
  late bool _deception;
  late bool _history;
  late bool _insight;
  late bool _intimidation;
  late bool _investigation;
  late bool _medicine;
  late bool _nature;
  late bool _perception;
  late bool _performance;
  late bool _persuasion;
  late bool _religion;
  late bool _sleightOfHand;
  late bool _stealth;
  late bool _survival;

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

    _acrobatics = widget.initialSkills.acrobatics;
    _animalHandling = widget.initialSkills.animalHandling;
    _arcana = widget.initialSkills.arcana;
    _athletics = widget.initialSkills.athletics;
    _deception = widget.initialSkills.deception;
    _history = widget.initialSkills.history;
    _insight = widget.initialSkills.insight;
    _intimidation = widget.initialSkills.intimidation;
    _investigation = widget.initialSkills.investigation;
    _medicine = widget.initialSkills.medicine;
    _nature = widget.initialSkills.nature;
    _perception = widget.initialSkills.perception;
    _performance = widget.initialSkills.performance;
    _persuasion = widget.initialSkills.persuasion;
    _religion = widget.initialSkills.religion;
    _sleightOfHand = widget.initialSkills.sleightOfHand;
    _stealth = widget.initialSkills.stealth;
    _survival = widget.initialSkills.survival;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar proficiências'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Salvaguardas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
          Text(
            'Perícias',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            title: 'Acrobacia',
            value: _acrobatics,
            onChanged: (value) => setState(() => _acrobatics = value),
          ),
          _buildSwitchTile(
            title: 'Adestrar Animais',
            value: _animalHandling,
            onChanged: (value) => setState(() => _animalHandling = value),
          ),
          _buildSwitchTile(
            title: 'Arcanismo',
            value: _arcana,
            onChanged: (value) => setState(() => _arcana = value),
          ),
          _buildSwitchTile(
            title: 'Atletismo',
            value: _athletics,
            onChanged: (value) => setState(() => _athletics = value),
          ),
          _buildSwitchTile(
            title: 'Enganação',
            value: _deception,
            onChanged: (value) => setState(() => _deception = value),
          ),
          _buildSwitchTile(
            title: 'História',
            value: _history,
            onChanged: (value) => setState(() => _history = value),
          ),
          _buildSwitchTile(
            title: 'Intuição',
            value: _insight,
            onChanged: (value) => setState(() => _insight = value),
          ),
          _buildSwitchTile(
            title: 'Intimidação',
            value: _intimidation,
            onChanged: (value) => setState(() => _intimidation = value),
          ),
          _buildSwitchTile(
            title: 'Investigação',
            value: _investigation,
            onChanged: (value) => setState(() => _investigation = value),
          ),
          _buildSwitchTile(
            title: 'Medicina',
            value: _medicine,
            onChanged: (value) => setState(() => _medicine = value),
          ),
          _buildSwitchTile(
            title: 'Natureza',
            value: _nature,
            onChanged: (value) => setState(() => _nature = value),
          ),
          _buildSwitchTile(
            title: 'Percepção',
            value: _perception,
            onChanged: (value) => setState(() => _perception = value),
          ),
          _buildSwitchTile(
            title: 'Atuação',
            value: _performance,
            onChanged: (value) => setState(() => _performance = value),
          ),
          _buildSwitchTile(
            title: 'Persuasão',
            value: _persuasion,
            onChanged: (value) => setState(() => _persuasion = value),
          ),
          _buildSwitchTile(
            title: 'Religião',
            value: _religion,
            onChanged: (value) => setState(() => _religion = value),
          ),
          _buildSwitchTile(
            title: 'Prestidigitação',
            value: _sleightOfHand,
            onChanged: (value) => setState(() => _sleightOfHand = value),
          ),
          _buildSwitchTile(
            title: 'Furtividade',
            value: _stealth,
            onChanged: (value) => setState(() => _stealth = value),
          ),
          _buildSwitchTile(
            title: 'Sobrevivência',
            value: _survival,
            onChanged: (value) => setState(() => _survival = value),
          ),
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
        skillProficiencies: SkillProficiencies(
          acrobatics: _acrobatics,
          animalHandling: _animalHandling,
          arcana: _arcana,
          athletics: _athletics,
          deception: _deception,
          history: _history,
          insight: _insight,
          intimidation: _intimidation,
          investigation: _investigation,
          medicine: _medicine,
          nature: _nature,
          perception: _perception,
          performance: _performance,
          persuasion: _persuasion,
          religion: _religion,
          sleightOfHand: _sleightOfHand,
          stealth: _stealth,
          survival: _survival,
        ),
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