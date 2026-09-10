import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditAbilityScoresPage extends ConsumerStatefulWidget {
  const EditAbilityScoresPage({
    required this.characterId,
    required this.initialScores,
    super.key,
  });

  final String characterId;
  final AbilityScores initialScores;

  @override
  ConsumerState<EditAbilityScoresPage> createState() =>
      _EditAbilityScoresPageState();
}

class _EditAbilityScoresPageState extends ConsumerState<EditAbilityScoresPage> {
  late final TextEditingController _strengthController;
  late final TextEditingController _dexterityController;
  late final TextEditingController _constitutionController;
  late final TextEditingController _intelligenceController;
  late final TextEditingController _wisdomController;
  late final TextEditingController _charismaController;

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _strengthController =
        TextEditingController(text: widget.initialScores.strength.toString());
    _dexterityController =
        TextEditingController(text: widget.initialScores.dexterity.toString());
    _constitutionController =
        TextEditingController(text: widget.initialScores.constitution.toString());
    _intelligenceController =
        TextEditingController(text: widget.initialScores.intelligence.toString());
    _wisdomController =
        TextEditingController(text: widget.initialScores.wisdom.toString());
    _charismaController =
        TextEditingController(text: widget.initialScores.charisma.toString());
  }

  @override
  void dispose() {
    _strengthController.dispose();
    _dexterityController.dispose();
    _constitutionController.dispose();
    _intelligenceController.dispose();
    _wisdomController.dispose();
    _charismaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar atributos'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _scoreField('Força', _strengthController),
            const SizedBox(height: 12),
            _scoreField('Destreza', _dexterityController),
            const SizedBox(height: 12),
            _scoreField('Constituição', _constitutionController),
            const SizedBox(height: 12),
            _scoreField('Inteligência', _intelligenceController),
            const SizedBox(height: 12),
            _scoreField('Sabedoria', _wisdomController),
            const SizedBox(height: 12),
            _scoreField('Carisma', _charismaController),
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
              label: Text(_saving ? 'Salvando...' : 'Salvar atributos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe um valor.';
        }

        final parsed = int.tryParse(value);
        if (parsed == null) {
          return 'Digite um número válido.';
        }

        if (parsed < 1 || parsed > 30) {
          return 'Use um valor entre 1 e 30.';
        }

        return null;
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newScores = AbilityScores(
      strength: int.parse(_strengthController.text),
      dexterity: int.parse(_dexterityController.text),
      constitution: int.parse(_constitutionController.text),
      intelligence: int.parse(_intelligenceController.text),
      wisdom: int.parse(_wisdomController.text),
      charisma: int.parse(_charismaController.text),
    );

    // Lê direto do repositório: depender do provider `autoDispose` aqui é
    // arriscado, pois ele pode ser descartado antes do future resolver.
    final character = await ref
        .read(characterRepositoryProvider)
        .findById(widget.characterId);

    if (character == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao validar personagem.')),
      );
      return;
    }

    if (character.classLevels.length > 1) {
      final secondaryClassIds =
          character.classLevels.skip(1).map((e) => e.classId).toSet();

      final error = _validateMulticlassRequirements(
        newScores,
        secondaryClassIds,
      );

      if (error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pré-requisito quebrado: $error'),
          ),
        );
        return;
      }
    }

    setState(() {
      _saving = true;
    });

    try {
      final useCase = ref.read(updateCharacterAbilityScoresProvider);
      final classes = await ref.read(classEntriesProvider.future);

      await useCase(
        characterId: widget.characterId,
        abilityScores: newScores,
        // Permite recalcular o PV máximo quando a Constituição muda.
        dieSizeForClass: (classId) {
          for (final entry in classes) {
            if (entry.id == classId) {
              return HitPointsCalculator.parseDieSize(entry.hitDie);
            }
          }
          return 8;
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String? _validateMulticlassRequirements(
    AbilityScores scores,
    Set<String> classIds,
  ) {
    int score(String key) {
      switch (key) {
        case 'strength':
          return scores.strength;
        case 'dexterity':
          return scores.dexterity;
        case 'constitution':
          return scores.constitution;
        case 'intelligence':
          return scores.intelligence;
        case 'wisdom':
          return scores.wisdom;
        case 'charisma':
          return scores.charisma;
        default:
          return 0;
      }
    }

    bool atLeast13(String key) => score(key) >= 13;

    for (final classId in classIds) {
      switch (classId) {
        case 'barbarian':
          if (!atLeast13('strength')) return 'Bárbaro exige Força 13';
          break;

        case 'bard':
          if (!atLeast13('charisma')) return 'Bardo exige Carisma 13';
          break;

        case 'cleric':
          if (!atLeast13('wisdom')) return 'Clérigo exige Sabedoria 13';
          break;

        case 'druid':
          if (!atLeast13('wisdom')) return 'Druida exige Sabedoria 13';
          break;

        case 'fighter':
          if (!(atLeast13('strength') || atLeast13('dexterity'))) {
            return 'Guerreiro exige Força 13 ou Destreza 13';
          }
          break;

        case 'monk':
          if (!atLeast13('dexterity') || !atLeast13('wisdom')) {
            return 'Monge exige Destreza 13 e Sabedoria 13';
          }
          break;

        case 'paladin':
          if (!atLeast13('strength') || !atLeast13('charisma')) {
            return 'Paladino exige Força 13 e Carisma 13';
          }
          break;

        case 'ranger':
          if (!atLeast13('dexterity') || !atLeast13('wisdom')) {
            return 'Patrulheiro exige Destreza 13 e Sabedoria 13';
          }
          break;

        case 'rogue':
          if (!atLeast13('dexterity')) return 'Ladino exige Destreza 13';
          break;

        case 'sorcerer':
          if (!atLeast13('charisma')) return 'Feiticeiro exige Carisma 13';
          break;

        case 'warlock':
          if (!atLeast13('charisma')) return 'Bruxo exige Carisma 13';
          break;

        case 'wizard':
          if (!atLeast13('intelligence')) return 'Mago exige Inteligência 13';
          break;
      }
    }

    return null;
  }
}