import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/feature_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_prerequisites.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_selection.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_resources.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// As mecânicas internas de classe e subclasse do personagem, já resolvidas.
///
/// Indexado pelo personagem inteiro, como `resolvedFeaturesProvider` e
/// `resolvedInvocationsProvider`, porque o resultado depende de nível na
/// classe, subclasse, atributos, magias conhecidas, proficiências e seleção —
/// e o `Character` é a única chave que carrega todas. É isso que faz a ficha
/// recalcular sozinha: subir de nível, trocar a subclasse ou escolher uma
/// manobra produz um `Character` novo e, com ele, uma lista nova.
final resolvedClassMechanicsProvider = FutureProvider.family
    .autoDispose<ResolvedClassMechanics, Character>((ref, character) async {
      final catalog = await ref.watch(classMechanicCatalogProvider.future);
      final classes = await ref.watch(classEntriesProvider.future);
      final subclasses = await ref.watch(subclassEntriesProvider.future);
      final spells = await ref.watch(spellEntriesProvider.future);
      final features = await ref.watch(
        resolvedFeaturesProvider(character).future,
      );

      return ClassMechanicResolver.resolve(
        character: character,
        catalog: catalog,
        classes: classes,
        subclasses: subclasses,
        spells: spells,
        features: features,
      );
    });

/// O perfil usado na validação, para a tela não remontá-lo.
final mechanicProfileProvider = FutureProvider.family
    .autoDispose<MechanicProfile, Character>((ref, character) async {
      final resolved = await ref.watch(
        resolvedClassMechanicsProvider(character).future,
      );
      return resolved.profile;
    });

/// Uma mecânica específica, já resolvida.
///
/// Serve à tela de gerenciamento, que recebe o id pela rota e não pode
/// remontar o resolvedor inteiro só para achar uma entrada.
final resolvedClassMechanicProvider = FutureProvider.family.autoDispose<
  ResolvedClassMechanic?,
  ({Character character, String mechanicId})
>((ref, params) async {
  final resolved = await ref.watch(
    resolvedClassMechanicsProvider(params.character).future,
  );
  return resolved.byId(params.mechanicId);
});

/// Os recursos limitados que as mecânicas de classe concedem.
///
/// Reaproveita [FeatureResource], o mesmo registro dos recursos de
/// característica, para o painel de Recursos e descanso e o próprio descanso
/// funcionarem sem saber que mecânica de subclasse existe.
final classMechanicResourcesProvider = FutureProvider.family
    .autoDispose<List<FeatureResource>, Character>((ref, character) async {
      final resolved = await ref.watch(
        resolvedClassMechanicsProvider(character).future,
      );
      return resolved.resources;
    });

/// Mecânicas com escolha obrigatória em aberto.
///
/// É o que a criação e a evolução consultam para decidir se mostram a etapa de
/// "Escolhas de classe" — e para impedir concluir com pendência.
final pendingClassMechanicsProvider = FutureProvider.family
    .autoDispose<List<ResolvedClassMechanic>, Character>((
      ref,
      character,
    ) async {
      final resolved = await ref.watch(
        resolvedClassMechanicsProvider(character).future,
      );
      return resolved.pending;
    });

/// Resultado de uma escrita de mecânica, para a tela avisar o jogador.
class MechanicWriteResult {
  const MechanicWriteResult({required this.message, required this.changed});

  final String message;
  final bool changed;
}

/// Lê o personagem agora, em vez de aceitar uma cópia de quem chamou.
///
/// É o ponto que impede o bug clássico destas telas: a página recebeu um
/// `Character` ao abrir, o jogador escolheu uma manobra, e a segunda escolha
/// partiria da cópia ANTIGA — gravando uma lista sem a primeira. Lendo do
/// repositório a cada escrita, cada gravação parte do estado real.
Future<Character> _current(Ref ref, String characterId) async {
  final character = await ref
      .read(characterRepositoryProvider)
      .findById(characterId);

  if (character == null) {
    throw Exception('Personagem não encontrado.');
  }

  return character;
}

/// Resolve a mecânica a partir do estado atual do personagem.
Future<({Character character, ResolvedClassMechanic? mechanic})> _resolve(
  Ref ref,
  String characterId,
  String mechanicId,
) async {
  final character = await _current(ref, characterId);
  final resolved = await ref.read(
    resolvedClassMechanicsProvider(character).future,
  );

  return (character: character, mechanic: resolved.byId(mechanicId));
}

/// Escolhe uma opção numa vaga livre.
final selectClassMechanicOptionProvider = Provider<
  Future<MechanicWriteResult> Function({
    required String characterId,
    required String mechanicId,
    required String optionId,
  })
>((ref) {
  return ({
    required String characterId,
    required String mechanicId,
    required String optionId,
  }) async {
    final state = await _resolve(ref, characterId, mechanicId);
    final mechanic = state.mechanic;

    if (mechanic == null) {
      return const MechanicWriteResult(
        message:
            'Esta característica não está disponível para este '
            'personagem.',
        changed: false,
      );
    }

    final outcome = ClassMechanicSelection.select(
      character: state.character,
      mechanic: mechanic,
      optionId: optionId,
    );

    return _persist(ref, outcome, success: (name) => '$name escolhida.');
  };
});

/// Substitui uma opção conhecida por outra.
final replaceClassMechanicOptionProvider = Provider<
  Future<MechanicWriteResult> Function({
    required String characterId,
    required String mechanicId,
    required String replacedId,
    required String optionId,
    bool freeEdit,
  })
>((ref) {
  return ({
    required String characterId,
    required String mechanicId,
    required String replacedId,
    required String optionId,
    bool freeEdit = false,
  }) async {
    final state = await _resolve(ref, characterId, mechanicId);
    final mechanic = state.mechanic;

    if (mechanic == null) {
      return const MechanicWriteResult(
        message:
            'Esta característica não está disponível para este '
            'personagem.',
        changed: false,
      );
    }

    final catalog = await ref.read(classMechanicCatalogProvider.future);
    final previous = mechanic.optionById(replacedId)?.name ?? replacedId;

    final outcome = ClassMechanicSelection.replace(
      character: state.character,
      mechanic: mechanic,
      replacedId: replacedId,
      optionId: optionId,
      freeEdit: freeEdit,
      catalog: catalog,
    );

    return _persist(
      ref,
      outcome,
      success: (name) => '$previous substituída por $name.',
    );
  };
});

/// Remove uma opção, liberando a vaga.
final removeClassMechanicOptionProvider = Provider<
  Future<MechanicWriteResult> Function({
    required String characterId,
    required String mechanicId,
    required String optionId,
  })
>((ref) {
  return ({
    required String characterId,
    required String mechanicId,
    required String optionId,
  }) async {
    final state = await _resolve(ref, characterId, mechanicId);
    final mechanic = state.mechanic;

    if (mechanic == null) {
      return const MechanicWriteResult(
        message:
            'Esta característica não está disponível para este '
            'personagem.',
        changed: false,
      );
    }

    final removed = mechanic.optionById(optionId)?.name ?? optionId;

    final outcome = ClassMechanicSelection.remove(
      character: state.character,
      mechanic: mechanic,
      optionId: optionId,
    );

    return _persist(ref, outcome, success: (_) => '$removed removida.');
  };
});

/// Liga ou desliga um modo, com a transição segura do domínio.
final setClassMechanicModeProvider = Provider<
  Future<MechanicWriteResult> Function({
    required String characterId,
    required String mechanicId,
    required String optionId,
    required bool isActive,
  })
>((ref) {
  return ({
    required String characterId,
    required String mechanicId,
    required String optionId,
    required bool isActive,
  }) async {
    final state = await _resolve(ref, characterId, mechanicId);
    final mechanic = state.mechanic;

    if (mechanic == null) {
      return const MechanicWriteResult(
        message:
            'Esta característica não está disponível para este '
            'personagem.',
        changed: false,
      );
    }

    final outcome =
        isActive
            ? ClassMechanicSelection.activate(
              character: state.character,
              mechanic: mechanic,
              optionId: optionId,
            )
            : ClassMechanicSelection.deactivate(
              character: state.character,
              mechanic: mechanic,
              optionId: optionId,
            );

    return _persist(
      ref,
      outcome,
      success: (name) {
        final base = isActive ? '$name ativada.' : '$name desativada.';
        final notice = outcome.transitionNotice;
        return notice == null ? base : '$base $notice';
      },
    );
  };
});

/// Registra o resultado de uma tabela de rolagem.
final setClassMechanicRollResultProvider = Provider<
  Future<MechanicWriteResult> Function({
    required String characterId,
    required String mechanicId,
    required String rowId,
  })
>((ref) {
  return ({
    required String characterId,
    required String mechanicId,
    required String rowId,
  }) async {
    final state = await _resolve(ref, characterId, mechanicId);
    final mechanic = state.mechanic;

    if (mechanic == null) {
      return const MechanicWriteResult(
        message:
            'Esta característica não está disponível para este '
            'personagem.',
        changed: false,
      );
    }

    final outcome =
        rowId.isEmpty
            ? ClassMechanicSelection.clearRollResult(
              character: state.character,
              mechanic: mechanic,
            )
            : ClassMechanicSelection.setRollResult(
              character: state.character,
              mechanic: mechanic,
              rowId: rowId,
            );

    final label = mechanic.table?.byId(rowId)?.label;

    return _persist(
      ref,
      outcome,
      success:
          (_) =>
              rowId.isEmpty
                  ? 'Resultado apagado.'
                  : 'Resultado $label registrado.',
    );
  };
});

/// Refaz as escolhas de uma mecânica, apagando o que estava gravado nela.
final resetClassMechanicProvider = Provider<
  Future<MechanicWriteResult> Function({
    required String characterId,
    required String mechanicId,
  })
>((ref) {
  return ({required String characterId, required String mechanicId}) async {
    final state = await _resolve(ref, characterId, mechanicId);
    final mechanic = state.mechanic;

    if (mechanic == null) {
      return const MechanicWriteResult(
        message:
            'Esta característica não está disponível para este '
            'personagem.',
        changed: false,
      );
    }

    final outcome = ClassMechanicSelection.reset(
      character: state.character,
      mechanic: mechanic,
    );

    return _persist(
      ref,
      outcome,
      success: (_) => 'Escolhas de ${mechanic.name} reiniciadas.',
    );
  };
});

/// Gasta um uso de um recurso de mecânica.
///
/// Passa por `FeatureResources`, o mesmo motor dos recursos de característica:
/// o contador vive em `featureStates`, então não há um segundo caminho de
/// escrita para manter em sincronia.
final spendClassMechanicUseProvider = Provider<
  Future<void> Function({
    required Character character,
    required FeatureResource resource,
  })
>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required Character character,
    required FeatureResource resource,
  }) async {
    final updated = FeatureResources.spend(
      character: character,
      resource: resource,
    );

    // Sem mudança não grava: o botão no limite não pode gerar escrita inútil
    // nem disparar a remontagem do agregado.
    if (identical(updated, character)) return;

    await repository.update(updated.copyWith(updatedAt: DateTime.now()));
  };
});

/// Devolve um uso de um recurso de mecânica.
final restoreClassMechanicUseProvider = Provider<
  Future<void> Function({
    required Character character,
    required FeatureResource resource,
  })
>((ref) {
  final repository = ref.watch(characterRepositoryProvider);

  return ({
    required Character character,
    required FeatureResource resource,
  }) async {
    final updated = FeatureResources.restore(
      character: character,
      resource: resource,
    );

    if (identical(updated, character)) return;

    await repository.update(updated.copyWith(updatedAt: DateTime.now()));
  };
});

/// Grava a mudança e devolve a mensagem que a tela mostra.
Future<MechanicWriteResult> _persist(
  Ref ref,
  MechanicSelectionOutcome outcome, {
  required String Function(String name) success,
}) async {
  final error = outcome.error;
  if (error != null) {
    return MechanicWriteResult(message: error, changed: false);
  }

  if (!outcome.changed) {
    return const MechanicWriteResult(
      message: 'Nada a alterar.',
      changed: false,
    );
  }

  await ref
      .read(characterRepositoryProvider)
      .update(outcome.character.copyWith(updatedAt: DateTime.now()));

  return MechanicWriteResult(
    message: success(outcome.selected?.name ?? 'Escolhas atualizadas'),
    changed: true,
  );
}
