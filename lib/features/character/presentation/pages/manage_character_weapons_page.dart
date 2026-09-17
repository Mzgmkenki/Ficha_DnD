import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/weapon_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/weapon_providers.dart'
    as compendium;
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cadastro das armas do personagem.
///
/// A arma é sempre escolhida no compêndio: dado de dano, tipo e propriedades
/// vêm de lá. O que se edita aqui é só o que é decisão do jogador — apelido,
/// bônus mágico, atributo nas armas com Acuidade, empunhadura e proficiência.
class ManageCharacterWeaponsPage extends ConsumerStatefulWidget {
  const ManageCharacterWeaponsPage({
    required this.characterId,
    super.key,
  });

  final String characterId;

  @override
  ConsumerState<ManageCharacterWeaponsPage> createState() =>
      _ManageCharacterWeaponsPageState();
}

class _ManageCharacterWeaponsPageState
    extends ConsumerState<ManageCharacterWeaponsPage> {
  @override
  Widget build(BuildContext context) {
    final characterAsync = ref.watch(characterByIdProvider(widget.characterId));
    final weaponsAsync = ref.watch(compendium.weaponEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar armas')),
      body: characterAsync.when(
        data: (character) {
          if (character == null) {
            return const Center(child: Text('Personagem não encontrado.'));
          }

          return weaponsAsync.when(
            data: (catalog) => _body(character, catalog),
            error: (error, _) => Center(
              child: Text('Erro ao carregar as armas: $error'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, stackTrace) => Center(
          child: Text('Erro ao carregar personagem: $error'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _body(Character character, List<WeaponEntry> catalog) {
    final byId = {for (final weapon in catalog) weapon.id: weapon};

    return ListView(
      padding: context.scrollContentPadding(),
      children: [
        Text('Armas do personagem', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (character.weapons.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhuma arma cadastrada.'),
            ),
          )
        else
          ...character.weapons.map(
            (weapon) => Card(
              child: ListTile(
                title: Text(_displayName(weapon, byId[weapon.weaponId])),
                subtitle: Text(_subtitle(weapon, byId[weapon.weaponId])),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(character, weapon, catalog),
                    ),
                    IconButton(
                      tooltip: 'Remover',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _remove(weapon),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _add(character, catalog),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar arma'),
        ),
      ],
    );
  }

  String _displayName(CharacterWeapon weapon, WeaponEntry? entry) {
    final custom = weapon.name?.trim();
    final base = entry?.name ?? weapon.weaponId;

    if (custom == null || custom.isEmpty) {
      return weapon.magicBonus == 0 ? base : '$base +${weapon.magicBonus}';
    }

    return custom;
  }

  String _subtitle(CharacterWeapon weapon, WeaponEntry? entry) {
    if (entry == null) {
      // Acontece quando o asset é editado depois de a ficha ter sido salva.
      return 'Arma "${weapon.weaponId}" não encontrada no compêndio.';
    }

    final parts = <String>[
      entry.name,
      if (entry.damage case final damage?) '$damage ${entry.damageType.label}',
      if (weapon.magicBonus != 0) 'mágica +${weapon.magicBonus}',
      if (weapon.twoHanded) 'duas mãos',
    ];

    return parts.join(' • ');
  }

  Future<void> _add(Character character, List<WeaponEntry> catalog) async {
    final result = await _openEditor(catalog: catalog);
    if (result == null) return;

    await ref.read(addCharacterWeaponProvider)(
      characterId: character.id,
      weapon: result,
    );
  }

  Future<void> _edit(
    Character character,
    CharacterWeapon weapon,
    List<WeaponEntry> catalog,
  ) async {
    final result = await _openEditor(catalog: catalog, initial: weapon);
    if (result == null) return;

    await ref.read(updateCharacterWeaponProvider)(
      weapon: result.copyWith(localId: weapon.localId),
    );
  }

  Future<void> _remove(CharacterWeapon weapon) async {
    final localId = weapon.localId;
    if (localId == null) return;

    await ref.read(deleteCharacterWeaponProvider)(weaponLocalId: localId);
  }

  Future<CharacterWeapon?> _openEditor({
    required List<WeaponEntry> catalog,
    CharacterWeapon? initial,
  }) {
    return showModalBottomSheet<CharacterWeapon>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _WeaponEditor(
        catalog: catalog,
        initial: initial,
      ),
    );
  }
}

/// Formulário de uma arma, em folha inferior.
class _WeaponEditor extends StatefulWidget {
  const _WeaponEditor({required this.catalog, this.initial});

  final List<WeaponEntry> catalog;
  final CharacterWeapon? initial;

  @override
  State<_WeaponEditor> createState() => _WeaponEditorState();
}

class _WeaponEditorState extends State<_WeaponEditor> {
  late String _weaponId;
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late int _magicBonus;
  late bool _twoHanded;
  late Ability? _chosenAbility;
  late bool? _proficiencyOverride;

  @override
  void initState() {
    super.initState();

    final initial = widget.initial;

    _weaponId = initial?.weaponId ?? widget.catalog.first.id;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _magicBonus = initial?.magicBonus ?? 0;
    _twoHanded = initial?.twoHanded ?? false;
    _chosenAbility = initial?.chosenAbility;
    _proficiencyOverride = initial?.proficiencyOverride;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  WeaponEntry get _entry {
    return widget.catalog.firstWhere(
      (item) => item.id == _weaponId,
      orElse: () => widget.catalog.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initial == null ? 'Adicionar arma' : 'Editar arma',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _weaponId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Arma'),
              items: widget.catalog
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(
                        '${item.name} (${item.category.label})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _weaponId = value;
                  // O atributo escolhido e a empunhadura pertenciam à arma
                  // anterior: uma escolha de Força numa rapieira não faz
                  // sentido depois de trocar para um arco.
                  _chosenAbility = null;
                  _twoHanded = false;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.damage ?? 'sem dano'} '
              '${entry.damage == null ? '' : entry.damageType.label} • '
              '${entry.rangeType.label} • ${entry.propertiesLabel}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Apelido (opcional)',
                helperText: 'Em branco usa o nome do compêndio.',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _magicBonus,
              decoration: const InputDecoration(
                labelText: 'Bônus mágico da arma',
                helperText: 'Soma nas jogadas de ataque e de dano desta arma.',
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Nenhum')),
                DropdownMenuItem(value: 1, child: Text('+1')),
                DropdownMenuItem(value: 2, child: Text('+2')),
                DropdownMenuItem(value: 3, child: Text('+3')),
              ],
              onChanged: (value) => setState(() => _magicBonus = value ?? 0),
            ),
            // Só as armas com Acuidade têm escolha de atributo; nas outras a
            // regra decide e mostrar o campo daria a impressão errada.
            if (entry.isFinesse) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _chosenAbility?.name ?? '',
                decoration: const InputDecoration(
                  labelText: 'Atributo (arma com Acuidade)',
                  helperText: 'Automático usa o maior entre Força e Destreza.',
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Automático')),
                  for (final ability in entry.allowedAbilities)
                    DropdownMenuItem(
                      value: ability.name,
                      child: Text(ability.label),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _chosenAbility =
                      value == null || value.isEmpty ? null : Ability.fromName(value);
                }),
              ),
            ],
            if (entry.isVersatile) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _twoHanded,
                title: const Text('Empunhada com as duas mãos'),
                subtitle: Text(
                  'Versátil: o dado vira ${entry.versatileDamage ?? entry.damage}.',
                ),
                onChanged: (value) => setState(() => _twoHanded = value),
              ),
            ],
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _proficiencyText(),
              decoration: const InputDecoration(
                labelText: 'Proficiência',
                helperText: 'Automático usa as proficiências da classe.',
              ),
              items: const [
                DropdownMenuItem(value: 'auto', child: Text('Automático')),
                DropdownMenuItem(value: 'yes', child: Text('Tem proficiência')),
                DropdownMenuItem(value: 'no', child: Text('Sem proficiência')),
              ],
              onChanged: (value) => setState(() {
                _proficiencyOverride = switch (value) {
                  'yes' => true,
                  'no' => false,
                  _ => null,
                };
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                helperText: 'Ex.: dano extra, condição especial da arma.',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _proficiencyText() {
    return switch (_proficiencyOverride) {
      true => 'yes',
      false => 'no',
      null => 'auto',
    };
  }

  void _save() {
    final name = _nameController.text.trim();

    Navigator.of(context).pop(
      CharacterWeapon(
        localId: widget.initial?.localId,
        weaponId: _weaponId,
        name: name.isEmpty ? null : name,
        magicBonus: _magicBonus,
        chosenAbility: _chosenAbility,
        twoHanded: _twoHanded,
        proficiencyOverride: _proficiencyOverride,
        notes: _notesController.text.trim(),
      ),
    );
  }
}
