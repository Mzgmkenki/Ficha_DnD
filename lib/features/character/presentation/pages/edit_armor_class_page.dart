import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Calcula a CA a partir de armadura + escudo + bônus, em vez de exigir que
/// o jogador faça a conta de cabeça e digite um número.
///
/// A armadura que o personagem POSSUI vem do inventário (ver `OwnedArmor`):
/// equipamento inicial da classe, antecedente ou item adicionado à mão caem
/// todos no mesmo lugar, sem segunda cópia. Equipar aqui grava o estado no
/// próprio item, então reabrir a tela mostra a armadura que está vestida — e
/// a CA passa a contar só o que está equipado.
class EditArmorClassPage extends ConsumerStatefulWidget {
  const EditArmorClassPage({required this.character, super.key});

  final Character character;

  @override
  ConsumerState<EditArmorClassPage> createState() => _EditArmorClassPageState();
}

class _EditArmorClassPageState extends ConsumerState<EditArmorClassPage> {
  /// Armadura escolhida no seletor.
  ///
  /// Começa na que está equipada no inventário: antes a tela sempre abria em
  /// "Sem armadura", mesmo com CA 18 salva, e não havia como saber qual
  /// armadura tinha produzido o número.
  late String _armorId;
  late bool _hasShield;
  int _otherBonus = 0;
  bool _saving = false;

  /// Inventário em edição.
  ///
  /// A troca de equipado mexe aqui e só vai para o banco no salvar, junto com
  /// a CA: duas gravações separadas poderiam deixar a armadura equipada com o
  /// número antigo.
  late List<InventoryItem> _inventory;

  AbilityScores get _scores => widget.character.abilityScores;

  @override
  void initState() {
    super.initState();
    _inventory = List<InventoryItem>.from(widget.character.inventory);
    _armorId =
        OwnedArmor.equippedWearable(
          _inventory,
          abilityScores: _scores,
        )?.armor?.id ??
        'none';
    _hasShield = OwnedArmor.hasEquippedShield(_inventory);
  }

  /// Por que esta armadura da tabela não pode ser usada, ou `null`.
  ///
  /// Vale para a armadura escolhida no seletor, inclusive a que o personagem
  /// não possui: o seletor também serve para quem calcula a CA de uma armadura
  /// que pretende comprar, e o requisito é o mesmo.
  String? _blockReasonFor(ArmorOption armor) =>
      _profileFor(armor).blockReason(_scores);

  /// O perfil da armadura escolhida no seletor.
  ///
  /// Quando o personagem POSSUI aquela armadura, vale o perfil da peça dele —
  /// com bônus mágico e exceções. Caso contrário, a armadura básica da tabela.
  ArmorProfile _profileFor(ArmorOption armor) =>
      _findOwnedWearable(armor.id)?.profile ?? armor.profile;

  int _magicBonusFor(ArmorOption armor) => _profileFor(armor).magicBonus;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final armor = ArmorOption.fromId(_armorId) ?? ArmorOption.all.first;
    final blockReason = _blockReasonFor(armor);

    // Armadura bloqueada não entra na conta: o número mostrado tem que ser o
    // mesmo que a ficha vai guardar, e `OwnedArmor` também a ignoraria.
    final result = ArmorClassCalculator.calculate(
      armor: blockReason == null ? armor : ArmorOption.all.first,
      abilityScores: _scores,
      hasShield: _hasShield,
      otherBonus: _otherBonus,
      armorMagicBonus: blockReason == null ? _magicBonusFor(armor) : 0,
    );

    final owned = OwnedArmor.from(_inventory);

    return Scaffold(
      appBar: AppBar(title: const Text('Calcular CA')),
      body: ListView(
        padding: context.scrollContentPadding(),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('CA ${result.total}', style: text.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    result.explanation,
                    style: text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          if (owned.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Armaduras e escudos que você possui', style: text.titleSmall),
            const SizedBox(height: 2),
            Text(
              'Só o que está equipado entra na CA.',
              style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
            ),
            for (final piece in owned)
              _OwnedPieceTile(
                piece: piece,
                abilityScores: _scores,
                onToggle: () => _toggle(piece),
              ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const ValueKey('armor-select'),
            initialValue: _armorId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Armadura'),
            items:
                ArmorOption.all.map((item) {
                  final reason = _blockReasonFor(item);
                  final label =
                      item.category == ArmorCategory.none
                          ? item.name
                          : '${item.name} (${item.category.label})';

                  return DropdownMenuItem<String>(
                    value: item.id,
                    // Desabilitada, não escondida: o jogador precisa ver que a
                    // armadura existe e por que não pode usá-la.
                    enabled: reason == null,
                    child: Text(
                      reason == null ? label : '$label — $reason',
                      overflow: TextOverflow.ellipsis,
                      style:
                          reason == null
                              ? null
                              : text.bodyMedium?.copyWith(
                                color: AppColors.onDarkVariant,
                              ),
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value == null) return;

              final selected = ArmorOption.fromId(value);
              final reason =
                  selected == null ? null : _blockReasonFor(selected);
              if (reason != null) {
                _explainBlock(reason);
                return;
              }

              setState(() {
                _armorId = value;
                // Mantém o inventário coerente com o seletor: escolher aqui
                // uma armadura que o personagem possui equipa aquela peça, e
                // escolher outra desequipa — senão a tela mostraria uma
                // armadura e a ficha guardaria outra.
                _inventory =
                    OwnedArmor.equipWearable(
                      inventory: _inventory,
                      piece: _findOwnedWearable(value),
                      abilityScores: _scores,
                    ).inventory;
              });
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            key: const ValueKey('armor-shield'),
            value: _hasShield,
            onChanged:
                (value) => setState(() {
                  _hasShield = value;
                  _inventory = OwnedArmor.setShieldEquipped(
                    inventory: _inventory,
                    equipped: value,
                  );
                }),
            title: const Text('Escudo'),
            subtitle: Text(
              OwnedArmor.shields(_inventory).isEmpty
                  ? '+${ShieldOption.armorClassBonus} na CA'
                  : '+${ShieldOption.armorClassBonus} na CA • '
                      'você possui um escudo',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text('Outros bônus (anel, manto, classe...)'),
              ),
              IconButton(
                onPressed: () => setState(() => _otherBonus--),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                _otherBonus >= 0 ? '+$_otherBonus' : '$_otherBonus',
                style: text.titleMedium,
              ),
              IconButton(
                onPressed: () => setState(() => _otherBonus++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Warning(
            text: armor.category.dexLimitLabel,
            icon: Icons.info_outline,
          ),
          if (_profileFor(armor).stealthDisadvantage) ...[
            const SizedBox(height: 8),
            const _Warning(
              key: ValueKey('armor-stealth-warning'),
              text:
                  'Esta armadura impõe desvantagem em testes de Destreza '
                  '(Furtividade).',
            ),
          ],
          if (blockReason != null) ...[
            const SizedBox(height: 8),
            _Warning(
              key: const ValueKey('armor-strength-warning'),
              text:
                  '$blockReason Ela não pode ser equipada nem entra na CA, '
                  'e continua no inventário.',
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : () => _save(result.total),
            icon:
                _saving
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save),
            label: Text(_saving ? 'Salvando...' : 'Salvar CA ${result.total}'),
          ),
        ],
      ),
    );
  }

  OwnedArmorPiece? _findOwnedWearable(String armorId) {
    for (final piece in OwnedArmor.wearables(_inventory)) {
      if (piece.armor?.id == armorId) return piece;
    }
    return null;
  }

  /// Equipa ou guarda uma peça da lista de possuídos.
  void _toggle(OwnedArmorPiece piece) {
    if (piece.isShield) {
      final next = !piece.isEquipped;
      setState(() {
        _inventory = OwnedArmor.setShieldEquipped(
          inventory: _inventory,
          equipped: next,
          piece: piece.item,
        );
        _hasShield = next;
      });
      return;
    }

    final next = piece.isEquipped ? null : piece;

    // A recusa vem do domínio, não de um `if` daqui: a mesma chamada que a
    // tela faz é a que qualquer outro caminho faria.
    final result = OwnedArmor.equipWearable(
      inventory: _inventory,
      piece: next,
      abilityScores: _scores,
    );

    final reason = result.blockedReason;
    if (reason != null) {
      _explainBlock(reason);
      return;
    }

    setState(() {
      _inventory = result.inventory;
      _armorId = next == null ? 'none' : (piece.armor?.id ?? 'none');
    });
  }

  /// Explica o bloqueio no mesmo lugar em que o jogador tocou.
  void _explainBlock(String reason) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('$reason Esta armadura não pode ser equipada.')),
      );
  }

  Future<void> _save(int total) async {
    setState(() => _saving = true);

    try {
      // Conferência final antes de gravar: se a ficha chegou aqui com uma
      // armadura marcada como equipada que o personagem não consegue usar
      // (base antiga, ficha importada), ela sai agora. A tela nunca cria esse
      // estado, mas gravar é o último ponto em que ele pode ser corrigido.
      final enforced = OwnedArmor.enforceRequirements(
        inventory: _inventory,
        abilityScores: _scores,
      );

      await ref
          .read(characterRepositoryProvider)
          .update(
            widget.character.copyWith(
              // A armadura equipada vai junto com o total: é o que permite
              // reabrir a tela e ver de onde o número saiu.
              inventory: enforced.inventory,
              combatStats: widget.character.combatStats.copyWith(
                armorClass: total,
              ),
              updatedAt: DateTime.now(),
            ),
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar CA: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// Uma armadura ou escudo que o personagem possui.
///
/// Mostra o que a regra usa — categoria, CA base, limite de Destreza,
/// requisito de Força e penalidade — mais a origem, para o jogador saber que
/// aquela brunea veio do equipamento inicial da classe.
class _OwnedPieceTile extends StatelessWidget {
  const _OwnedPieceTile({
    required this.piece,
    required this.abilityScores,
    required this.onToggle,
  });

  final OwnedArmorPiece piece;
  final AbilityScores abilityScores;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final profile = piece.profile;
    final blockReason = piece.blockReason(abilityScores);

    final details = <String>[
      if (piece.isShield)
        'Escudo +${ShieldOption.armorClassBonus + piece.magicBonus}'
      else if (profile != null) ...[
        profile.category.label,
        'CA base ${profile.baseArmorClass}',
        profile.category.dexLimitLabel,
        if (profile.requiresStrength)
          'exige FOR ${profile.strengthRequirement}',
      ],
    ];

    return Card(
      key: ValueKey('owned-armor-${piece.item.itemId}'),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          piece.isMagical
                              ? '${piece.name} '
                                  '${piece.magicBonus > 0 ? '+' : ''}'
                                  '${piece.magicBonus}'
                              : piece.name,
                          style: text.bodyMedium,
                        ),
                      ),
                      if (piece.stealthDisadvantage)
                        const _StealthBadge(
                          key: ValueKey('armor-stealth-badge'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details.join(' • '),
                    style: text.bodySmall?.copyWith(
                      color: AppColors.onDarkVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    piece.originLabel,
                    style: text.labelSmall?.copyWith(
                      color: AppColors.onDarkVariant,
                    ),
                  ),
                  if (blockReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      blockReason,
                      style: text.bodySmall?.copyWith(color: AppColors.red),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (piece.isEquipped)
              FilledButton.tonal(
                onPressed: onToggle,
                child: const Text('Equipado'),
              )
            else if (blockReason != null)
              // Desabilitado com explicação: o toque na opção bloqueada ainda
              // responde, pelo tooltip, em vez de parecer um botão quebrado.
              Tooltip(
                message: blockReason,
                child: OutlinedButton(
                  onPressed: null,
                  child: const Text('Bloqueada'),
                ),
              )
            else
              OutlinedButton(onPressed: onToggle, child: const Text('Equipar')),
          ],
        ),
      ),
    );
  }
}

/// Selo de desvantagem em Furtividade.
///
/// Mesma linguagem visual da etiqueta de especialista na linha de perícia:
/// retângulo com cantos arredondados, texto `labelSmall` e tooltip explicando.
class _StealthBadge extends StatelessWidget {
  const _StealthBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Desvantagem em testes de Destreza (Furtividade)',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.redContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const Icon(Icons.visibility_off_outlined, size: 12),
            const SizedBox(width: 4),
            Text('Furtividade', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning({
    required this.text,
    this.icon = Icons.warning_amber_outlined,
    super.key,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
