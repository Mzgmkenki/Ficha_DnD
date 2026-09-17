import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/death_saves.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Testes contra a morte: três sucessos e três falhas.
///
/// Nada é marcado automaticamente. A regra depende de coisas que a ficha não
/// sabe — quanto dano chegou, se foi crítico, se alguém curou antes do turno —
/// então o controle é do jogador, e o botão de rolar 1d20 só interpreta o dado
/// que saiu.
class DeathSavesPanel extends ConsumerStatefulWidget {
  const DeathSavesPanel({required this.character, super.key});

  final Character character;

  @override
  ConsumerState<DeathSavesPanel> createState() => _DeathSavesPanelState();
}

class _DeathSavesPanelState extends ConsumerState<DeathSavesPanel> {
  /// Estado anterior, para o botão de desfazer.
  ///
  /// Só de sessão: desfazer serve para o toque errado que acabou de acontecer, e
  /// guardar isso no banco daria a entender que o histórico sobrevive ao
  /// fechamento da ficha, o que não é verdade.
  DeathSaves? _previous;

  /// Última frase de resultado, do dado ou da ação.
  String? _lastMessage;

  DeathSaves get _saves => widget.character.deathSaves;

  bool get _isDying => widget.character.hitPoints.current <= 0;

  Future<void> _apply(DeathSaves updated, {String? message}) async {
    final before = _saves;

    setState(() {
      _previous = before;
      _lastMessage = message;
    });

    await ref.read(setDeathSavesProvider)(widget.character, updated);
  }

  Future<void> _undo() async {
    final target = _previous;
    if (target == null) return;

    setState(() {
      _previous = null;
      _lastMessage = 'Última marcação desfeita.';
    });

    await ref.read(setDeathSavesProvider)(widget.character, target);
  }

  /// Rola 1d20 e aplica a faixa correspondente.
  ///
  /// Sem modificador: o teste contra a morte não é teste de atributo nem
  /// salvaguarda, e não leva proficiência nem Constituição.
  Future<void> _roll() async {
    final roll = ref.read(diceRollerProvider).rollD20(
          label: 'Teste contra a morte',
        );

    final outcome = await ref.read(rollDeathSaveProvider)(
      character: widget.character,
      roll: roll,
    );

    if (!mounted) return;

    setState(() {
      _previous = _saves;
      _lastMessage = outcome.summary;
    });

    if (outcome.regainsHitPoint) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('20 natural: 1 ponto de vida recuperado.'),
        ),
      );
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar os testes?'),
        content: Text(
          'Isso apaga ${_saves.describe().toLowerCase()}. '
          'Use quando o personagem sair da situação de morte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _apply(const DeathSaves(), message: 'Marcadores zerados.');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final saves = _saves;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StateBanner(saves: saves, isDying: _isDying),
            const SizedBox(height: 12),
            _MarkerRow(
              label: 'Sucessos',
              count: saves.successes,
              filledColor: AppColors.gold,
              // O tipo do marcador é dito no rótulo e na forma: o sucesso é
              // redondo, a falha é quadrada. Depender só da cor deixaria quem
              // não distingue vermelho de dourado sem informação.
              shape: BoxShape.circle,
              semanticName: 'sucesso',
              onTap: saves.isResolved
                  ? null
                  : (index) => _apply(
                        saves.copyWith(successes: index + 1),
                        message: 'Sucesso marcado.',
                      ),
              onClearTo: (index) => _apply(
                saves.copyWith(successes: index),
                message: 'Sucesso desmarcado.',
              ),
            ),
            const SizedBox(height: 12),
            _MarkerRow(
              label: 'Falhas',
              count: saves.failures,
              filledColor: AppColors.red,
              shape: BoxShape.rectangle,
              semanticName: 'falha',
              onTap: saves.isResolved
                  ? null
                  : (index) => _apply(
                        saves.copyWith(failures: index + 1),
                        message: 'Falha marcada.',
                      ),
              onClearTo: (index) => _apply(
                saves.copyWith(failures: index),
                message: 'Falha desmarcada.',
              ),
            ),
            if (_lastMessage case final message?) ...[
              const SizedBox(height: 12),
              Text(message, style: text.bodySmall),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: saves.isResolved ? null : _roll,
                  icon: const Icon(Icons.casino_outlined, size: 18),
                  label: const Text('Rolar 1d20'),
                ),
                if (_previous != null && _previous != saves)
                  OutlinedButton.icon(
                    onPressed: _undo,
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text('Desfazer'),
                  ),
                if (saves.isNotEmpty)
                  TextButton.icon(
                    onPressed: _confirmClear,
                    icon: const Icon(Icons.layers_clear_outlined, size: 18),
                    label: const Text('Limpar testes'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'O teste contra a morte não leva modificador. 1 natural conta '
              'como duas falhas; 20 natural devolve 1 ponto de vida.',
              style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado alcançado: morrendo, estável ou morto.
class _StateBanner extends StatelessWidget {
  const _StateBanner({required this.saves, required this.isDying});

  final DeathSaves saves;
  final bool isDying;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final (String title, String detail, Color color) = switch (saves) {
      final s when s.isDead => (
          'Morto',
          'Três falhas registradas.',
          AppColors.red,
        ),
      final s when s.isStable => (
          'Estável',
          'Três sucessos: o personagem para de rolar e segue a 0 PV, '
              'inconsciente.',
          AppColors.gold,
        ),
      _ when isDying => (
          'Morrendo',
          'A 0 pontos de vida: role um teste no começo de cada turno.',
          AppColors.red,
        ),
      _ => (
          'Fora de perigo',
          'Com pontos de vida acima de zero não há teste a rolar.',
          AppColors.onDarkVariant,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.titleMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(detail, style: text.bodySmall),
        ],
      ),
    );
  }
}

/// Uma fila de três marcadores.
///
/// Tocar num marcador vazio marca até ele; tocar num marcado desmarca a partir
/// dele. É o mesmo gesto de uma barra de estrelas, e evita ter que acertar
/// exatamente a última bolinha para corrigir.
class _MarkerRow extends StatelessWidget {
  const _MarkerRow({
    required this.label,
    required this.count,
    required this.filledColor,
    required this.shape,
    required this.semanticName,
    required this.onTap,
    required this.onClearTo,
  });

  final String label;
  final int count;
  final Color filledColor;
  final BoxShape shape;
  final String semanticName;

  /// Marca até o índice tocado. Nulo desabilita (sequência já resolvida).
  final void Function(int index)? onTap;

  /// Desmarca a partir do índice tocado.
  final void Function(int index) onClearTo;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: text.labelLarge)),
            Text(
              '$count / ${DeathSaves.maxMarks}',
              style: text.labelMedium?.copyWith(color: filledColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var index = 0; index < DeathSaves.maxMarks; index++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _Marker(
                  filled: index < count,
                  filledColor: filledColor,
                  shape: shape,
                  // O alvo inteiro é tocável, com 48 de lado: numa ficha usada
                  // no celular em mesa, acertar uma bolinha de 20 px não dá.
                  onTap: index < count
                      ? () => onClearTo(index)
                      : (onTap == null ? null : () => onTap!(index)),
                  semanticsLabel: index < count
                      ? 'Desmarcar $semanticName ${index + 1}'
                      : 'Marcar $semanticName ${index + 1}',
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.filled,
    required this.filledColor,
    required this.shape,
    required this.onTap,
    required this.semanticsLabel,
  });

  final bool filled;
  final Color filledColor;
  final BoxShape shape;
  final VoidCallback? onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final radius = shape == BoxShape.circle
        ? BorderRadius.circular(24)
        : BorderRadius.circular(6);

    return Semantics(
      button: true,
      checked: filled,
      label: semanticsLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: shape,
                borderRadius: shape == BoxShape.rectangle ? radius : null,
                color: filled ? filledColor : Colors.transparent,
                border: Border.all(
                  color: filled ? filledColor : AppColors.outline,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
