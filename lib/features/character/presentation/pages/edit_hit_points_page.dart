import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditHitPointsPage extends ConsumerStatefulWidget {
  const EditHitPointsPage({
    required this.characterId,
    required this.initialHitPoints,
    super.key,
  });

  final String characterId;
  final HitPoints initialHitPoints;

  @override
  ConsumerState<EditHitPointsPage> createState() => _EditHitPointsPageState();
}

class _EditHitPointsPageState extends ConsumerState<EditHitPointsPage> {
  late final TextEditingController _currentController;
  late final TextEditingController _maximumController;
  late final TextEditingController _temporaryController;

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currentController =
        TextEditingController(text: widget.initialHitPoints.current.toString());
    _maximumController =
        TextEditingController(text: widget.initialHitPoints.maximum.toString());
    _temporaryController = TextEditingController(
      text: widget.initialHitPoints.temporary.toString(),
    );
  }

  @override
  void dispose() {
    _currentController.dispose();
    _maximumController.dispose();
    _temporaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar pontos de vida'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: context.scrollContentPadding(),
          children: [
            _numberField('HP atual', _currentController),
            const SizedBox(height: 12),
            _numberField('HP máximo', _maximumController),
            const SizedBox(height: 12),
            _numberField('HP temporário', _temporaryController, allowZero: true),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.favorite),
              label: Text(_saving ? 'Salvando...' : 'Salvar HP'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(
    String label,
    TextEditingController controller, {
    bool allowZero = false,
  }) {
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

        if (allowZero) {
          if (parsed < 0) return 'Use zero ou mais.';
        } else {
          if (parsed < 1) return 'Use pelo menos 1.';
        }

        return null;
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final current = int.parse(_currentController.text);
    final maximum = int.parse(_maximumController.text);
    final temporary = int.parse(_temporaryController.text);

    if (current > maximum) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HP atual não pode ser maior que o máximo.')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final useCase = ref.read(updateCharacterHitPointsProvider);

      await useCase(
        characterId: widget.characterId,
        hitPoints: HitPoints(
          current: current,
          maximum: maximum,
          temporary: temporary,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar HP: $error')),
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