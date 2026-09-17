import 'package:dnd_ficha_app/features/character/application/providers/weapon_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/weapon_attack_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// As armas do personagem, com ataque e dano já calculados.
///
/// Não repete regra nenhuma: o cálculo mora em [WeaponAttackCalculator] e chega
/// aqui pronto, com a composição em texto.
class WeaponsPanel extends ConsumerWidget {
  const WeaponsPanel({
    required this.character,
    this.onManage,
    super.key,
  });

  final Character character;

  /// Abre a tela de gerenciar armas. Nulo esconde o botão.
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attacksAsync = ref.watch(characterAttacksProvider(character));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: attacksAsync.when(
          data: (attacks) => _content(context, attacks),
          error: (error, stackTrace) => Text('Erro ao calcular ataques: $error'),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<WeaponAttack> attacks) {
    // Arma guardada cujo id não existe mais no compêndio não gera ataque, e a
    // diferença entre as duas listas é o que permite avisar em vez de a linha
    // simplesmente desaparecer.
    final missing = character.weapons.length - attacks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (attacks.isEmpty)
          const Text('Nenhuma arma cadastrada.')
        else
          ...attacks.map(
            (attack) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AttackTile(attack: attack),
            ),
          ),
        if (missing > 0) ...[
          const SizedBox(height: 8),
          Text(
            missing == 1
                ? 'Uma arma salva não foi encontrada no compêndio.'
                : '$missing armas salvas não foram encontradas no compêndio.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (onManage != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onManage,
              icon: const Icon(Icons.add),
              label: const Text('Gerenciar armas'),
            ),
          ),
        ],
      ],
    );
  }
}

/// Uma arma na ficha: nome, ataque, dano e a conta de cada um.
class _AttackTile extends StatelessWidget {
  const _AttackTile({required this.attack});

  final WeaponAttack attack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = attack.entry;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    attack.name,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  attack.formattedAttack,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${entry.category.label} • ${entry.rangeType.label}'
              ' • ${attack.ability.abbreviation}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text('Ataque ${attack.attackExplanation}'),
            if (attack.damageExplanation case final damage?)
              Text('Dano $damage'),
            if (!attack.isProficient) ...[
              const SizedBox(height: 4),
              Text(
                'Sem proficiência: o bônus de proficiência não entra.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (entry.properties.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Propriedades: ${entry.propertiesLabel}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (entry.special case final special?) ...[
              const SizedBox(height: 4),
              Text(special, style: theme.textTheme.bodySmall),
            ],
            if (attack.weapon.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                attack.weapon.notes.trim(),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
