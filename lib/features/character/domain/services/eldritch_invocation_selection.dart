import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_eldritch_invocation.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_prerequisites.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_resolver.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/eldritch_invocation_entry.dart';

/// O que aconteceu ao tentar escolher, substituir ou remover uma invocação.
///
/// Devolve resultado em vez de lançar porque "não pode" é um estado normal da
/// tela, não um defeito: o jogador clica numa invocação bloqueada e precisa
/// ler o motivo, não ver o app quebrar.
class InvocationSelectionOutcome {
  const InvocationSelectionOutcome._({
    required this.character,
    required this.changed,
    this.error,
    this.selected,
    this.replaced,
  });

  factory InvocationSelectionOutcome.unchanged(
    Character character, {
    String? error,
  }) {
    return InvocationSelectionOutcome._(
      character: character,
      changed: false,
      error: error,
    );
  }

  factory InvocationSelectionOutcome.applied(
    Character character, {
    EldritchInvocationEntry? selected,
    String? replaced,
  }) {
    return InvocationSelectionOutcome._(
      character: character,
      changed: true,
      selected: selected,
      replaced: replaced,
    );
  }

  /// O personagem já com a mudança, ou o original quando nada mudou.
  final Character character;

  final bool changed;

  /// Motivo da recusa, pronto para a tela mostrar. Nulo quando deu certo.
  final String? error;

  /// A invocação que entrou, quando entrou alguma.
  final EldritchInvocationEntry? selected;

  /// Id da invocação que saiu, quando houve substituição ou remoção.
  final String? replaced;

  bool get isRejected => error != null;
}

/// Escolhe, substitui e remove Invocações Místicas.
///
/// Toda escrita passa por aqui, e é de propósito: a validação de pré-requisito
/// e de vaga mora no DOMÍNIO, não numa opção desabilitada na interface. Se a
/// decisão estivesse só no widget, importar uma ficha, subir de nível ou
/// editar a classe entraria sem validação nenhuma.
///
/// O que o serviço NUNCA faz: apagar uma escolha em silêncio. Invocação que
/// perdeu o pré-requisito continua gravada, aparece marcada como inválida e
/// espera o jogador substituí-la — ver `InvocationAvailability.invalid`.
class EldritchInvocationSelection {
  const EldritchInvocationSelection._();

  /// Acrescenta uma invocação, se houver vaga e os pré-requisitos baterem.
  static InvocationSelectionOutcome select({
    required Character character,
    required ResolvedInvocations resolved,
    required String invocationId,
  }) {
    final option = resolved.byId(invocationId);

    if (option == null) {
      return InvocationSelectionOutcome.unchanged(
        character,
        error: 'Esta invocação não existe no catálogo.',
      );
    }

    if (option.isSelected) {
      return InvocationSelectionOutcome.unchanged(
        character,
        error: '${option.name} já está selecionada.',
      );
    }

    if (option.blocks.isNotEmpty) {
      return InvocationSelectionOutcome.unchanged(
        character,
        error: option.blockReason,
      );
    }

    if (resolved.freeSlots <= 0) {
      // Sem vaga, a saída é substituir — e é isso que a mensagem diz, em vez
      // de escolher sozinha qual invocação descartar.
      return InvocationSelectionOutcome.unchanged(
        character,
        error:
            'Você já tem ${resolved.countLabel}. Substitua uma invocação '
            'para escolher outra.',
      );
    }

    return InvocationSelectionOutcome.applied(
      character.copyWith(
        eldritchInvocations: [
          ...character.eldritchInvocations,
          CharacterEldritchInvocation(
            invocationId: option.id,
            chosenAtLevel: resolved.warlockLevel,
          ),
        ],
      ),
      selected: option.entry,
    );
  }

  /// Troca uma invocação conhecida por outra para a qual o personagem seja
  /// elegível.
  ///
  /// A invocação que sai deixa de ocupar vaga e perde os usos gastos: um
  /// contador de invocação que não está mais na ficha não tem sentido, e
  /// mantê-lo faria a invocação voltar já gasta se o jogador a escolhesse de
  /// novo.
  static InvocationSelectionOutcome replace({
    required Character character,
    required ResolvedInvocations resolved,
    required String replacedId,
    required String invocationId,
  }) {
    if (replacedId == invocationId) {
      return InvocationSelectionOutcome.unchanged(
        character,
        error: 'Escolha uma invocação diferente da que será substituída.',
      );
    }

    final current = resolved.byId(replacedId);
    final hasSelection = character.eldritchInvocations.any(
      (item) => item.invocationId == replacedId,
    );

    if (!hasSelection) {
      return InvocationSelectionOutcome.unchanged(
        character,
        error:
            '${current?.name ?? replacedId} não está entre as invocações '
            'selecionadas.',
      );
    }

    final option = resolved.byId(invocationId);

    if (option == null) {
      return InvocationSelectionOutcome.unchanged(
        character,
        error: 'Esta invocação não existe no catálogo.',
      );
    }

    if (option.isSelected) {
      return InvocationSelectionOutcome.unchanged(
        character,
        error: '${option.name} já está selecionada.',
      );
    }

    // A substituta é validada com a que SAI já fora da conta. Importa em dois
    // casos: uma invocação incompatível com a que está sendo substituída tem
    // de poder entrar, e uma que dependa da que sai não pode entrar.
    final blocks = _revalidateWithout(
      resolved: resolved,
      option: option,
      withoutId: replacedId,
    );

    if (blocks.isNotEmpty) {
      return InvocationSelectionOutcome.unchanged(
        character,
        error: blocks.map((item) => item.message).join(' '),
      );
    }

    return InvocationSelectionOutcome.applied(
      _withoutUses(
        character.copyWith(
          eldritchInvocations: [
            for (final item in character.eldritchInvocations)
              if (item.invocationId != replacedId) item,
            CharacterEldritchInvocation(
              invocationId: option.id,
              chosenAtLevel: resolved.warlockLevel,
              replacedInvocationId: replacedId,
              replacedAtLevel: resolved.warlockLevel,
            ),
          ],
        ),
        invocationId: replacedId,
      ),
      selected: option.entry,
      replaced: replacedId,
    );
  }

  /// Remove uma invocação, liberando a vaga.
  ///
  /// Existe para o jogador corrigir uma escolha, e não para o app limpar
  /// seleção inválida por conta própria: quem decide descartar é sempre o
  /// jogador.
  static InvocationSelectionOutcome remove({
    required Character character,
    required String invocationId,
  }) {
    final hasSelection = character.eldritchInvocations.any(
      (item) => item.invocationId == invocationId,
    );

    if (!hasSelection) {
      return InvocationSelectionOutcome.unchanged(character);
    }

    return InvocationSelectionOutcome.applied(
      _withoutUses(
        character.copyWith(
          eldritchInvocations: [
            for (final item in character.eldritchInvocations)
              if (item.invocationId != invocationId) item,
          ],
        ),
        invocationId: invocationId,
      ),
      replaced: invocationId,
    );
  }

  /// Revalida a candidata sem contar [withoutId] entre as selecionadas.
  static List<InvocationBlock> _revalidateWithout({
    required ResolvedInvocations resolved,
    required ResolvedInvocation option,
    required String withoutId,
  }) {
    final profile = resolved.profile.copyWith(
      selectedInvocationIds: resolved.profile.selectedInvocationIds
          .where((id) => id != withoutId)
          .toSet(),
    );

    return EldritchInvocationPrerequisites.evaluate(
      invocation: option.entry,
      profile: profile,
    );
  }

  /// Apaga o estado de usos da invocação que saiu da ficha.
  static Character _withoutUses(
    Character character, {
    required String invocationId,
  }) {
    final featureId = EldritchInvocationEntry.featureIdFor(invocationId);

    if (character.featureStateFor(featureId) == null) return character;

    return character.copyWith(
      featureStates: [
        for (final state in character.featureStates)
          if (state.featureId != featureId) state,
      ],
    );
  }
}
