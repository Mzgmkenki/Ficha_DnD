import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/custom_background_form.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Edita os dados de identidade do personagem: nome, jogador, antecedente
/// (inclusive o customizável) e anotações.
class EditIdentityPage extends ConsumerStatefulWidget {
  const EditIdentityPage({
    required this.characterId,
    required this.initialName,
    required this.initialNotes,
    this.initialPlayerName,
    this.initialBackgroundId,
    this.initialCustomBackground = const CustomBackground(),
    super.key,
  });

  final String characterId;
  final String initialName;
  final String initialNotes;
  final String? initialPlayerName;
  final String? initialBackgroundId;
  final CustomBackground initialCustomBackground;

  @override
  ConsumerState<EditIdentityPage> createState() => _EditIdentityPageState();
}

class _EditIdentityPageState extends ConsumerState<EditIdentityPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _playerController;
  late final TextEditingController _notesController;
  late final TextEditingController _customNameController;
  late final TextEditingController _customFeaturesController;

  String? _selectedBackgroundId;
  String? _customSkillOne;
  String? _customSkillTwo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialName);
    _playerController =
        TextEditingController(text: widget.initialPlayerName ?? '');
    _notesController = TextEditingController(text: widget.initialNotes);
    _customNameController = TextEditingController(
      text: widget.initialCustomBackground.name ?? '',
    );
    _customFeaturesController = TextEditingController(
      text: widget.initialCustomBackground.features,
    );

    _selectedBackgroundId = widget.initialBackgroundId;

    final skillIds = widget.initialCustomBackground.skillIds;
    _customSkillOne = skillIds.isNotEmpty ? skillIds[0] : null;
    _customSkillTwo = skillIds.length > 1 ? skillIds[1] : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _playerController.dispose();
    _notesController.dispose();
    _customNameController.dispose();
    _customFeaturesController.dispose();
    super.dispose();
  }

  bool get _isCustomBackground =>
      _selectedBackgroundId == BackgroundEntry.customId;

  @override
  Widget build(BuildContext context) {
    // Não bloqueia o formulário: se o compêndio ainda estiver carregando, o
    // seletor de antecedente simplesmente não aparece e o resto é editável.
    final backgrounds = ref.watch(backgroundEntriesProvider).value ??
        const <BackgroundEntry>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Editar identidade')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do personagem',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe um nome.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _playerController,
              decoration: const InputDecoration(
                labelText: 'Jogador (opcional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            if (backgrounds.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Antecedente',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _resolveSelectedBackgroundId(backgrounds),
                decoration: const InputDecoration(
                  labelText: 'Antecedente',
                  border: OutlineInputBorder(),
                ),
                items: backgrounds
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedBackgroundId = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione um antecedente.';
                  }
                  return null;
                },
              ),
              if (_isCustomBackground)
                CustomBackgroundForm(
                  nameController: _customNameController,
                  featuresController: _customFeaturesController,
                  skillOneId: _customSkillOne,
                  skillTwoId: _customSkillTwo,
                  onSkillsChanged: (one, two) {
                    setState(() {
                      _customSkillOne = one;
                      _customSkillTwo = two;
                    });
                  },
                  footnote: 'As perícias do antecedente são marcadas como '
                      'proficientes ao salvar. Nada é desmarcado: ajuste o '
                      'resto em Perícias.',
                )
              else
                _BackgroundSkillsNote(
                  background: _findBackground(backgrounds),
                ),
            ],
            const SizedBox(height: 20),
            Text(
              'Anotações',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Anotações da ficha',
                hintText: 'Aliados, objetivos, itens, o que combinou na mesa...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              minLines: 5,
              maxLines: 15,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
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
              label: Text(_saving ? 'Salvando...' : 'Salvar identidade'),
            ),
          ],
        ),
      ),
    );
  }

  BackgroundEntry? _findBackground(List<BackgroundEntry> backgrounds) {
    for (final item in backgrounds) {
      if (item.id == _selectedBackgroundId) return item;
    }
    return null;
  }

  /// Um id salvo que não exista mais no compêndio quebraria o dropdown, que
  /// exige exatamente um item casando com o valor.
  String? _resolveSelectedBackgroundId(List<BackgroundEntry> backgrounds) {
    return _findBackground(backgrounds)?.id;
  }

  CustomBackground _buildCustomBackground() {
    final name = _customNameController.text.trim();

    return CustomBackground(
      name: name.isEmpty ? null : name,
      skillIds: [
        if (_customSkillOne != null) _customSkillOne!,
        if (_customSkillTwo != null) _customSkillTwo!,
      ],
      features: _customFeaturesController.text.trim(),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // O formulário é um ListView: campos fora da viewport são desmontados e
    // saem do Form, então validate() não enxerga mais os validators deles.
    // As regras que não podem escapar são checadas contra o estado.
    final missing = <String>[
      if (_nameController.text.trim().isEmpty) 'o nome do personagem',
      if (_isCustomBackground &&
          (_customSkillOne == null || _customSkillTwo == null))
        'as duas perícias do antecedente',
    ];

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falta preencher ${missing.join(' e ')}.')),
      );
      return;
    }

    final customBackground =
        _isCustomBackground ? _buildCustomBackground() : const CustomBackground();

    final backgrounds = ref.read(backgroundEntriesProvider).value ??
        const <BackgroundEntry>[];
    final grantedSkills = _isCustomBackground
        ? customBackground.skills
        : (_findBackground(backgrounds)?.skills ?? const <Skill>[]);

    setState(() {
      _saving = true;
    });

    try {
      final useCase = ref.read(updateCharacterIdentityProvider);
      final playerName = _playerController.text.trim();

      await useCase(
        characterId: widget.characterId,
        name: _nameController.text.trim(),
        notes: _notesController.text.trim(),
        playerName: playerName.isEmpty ? null : playerName,
        backgroundId: _selectedBackgroundId,
        customBackground: customBackground,
        grantedSkills: grantedSkills,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar identidade: $error')),
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

/// Mostra o que o antecedente do compêndio concede, para o jogador saber o
/// que a troca vai marcar na ficha.
class _BackgroundSkillsNote extends StatelessWidget {
  const _BackgroundSkillsNote({required this.background});

  final BackgroundEntry? background;

  @override
  Widget build(BuildContext context) {
    final entry = background;
    if (entry == null) return const SizedBox.shrink();

    final skills = entry.skills.map((skill) => skill.label).join(', ');

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.description != null) ...[
              Text(entry.description!),
              const SizedBox(height: 8),
            ],
            if (skills.isNotEmpty)
              Text(
                'Perícias concedidas: $skills',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            Text(
              'Ao salvar, essas perícias são marcadas como proficientes. '
              'Nada é desmarcado: ajuste o resto em Perícias.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
