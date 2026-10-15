import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/sync_invocation_spells.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_prerequisites.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_selection.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_resources.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/spell_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/eldritch_invocation_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/pact_boon.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// As Invocações Místicas do personagem, já resolvidas.
///
/// Indexado pelo personagem inteiro, como `resolvedFeaturesProvider`, porque o
/// resultado depende de nível na classe Bruxo, Dádiva do Pacto escolhida,
/// magias conhecidas, subclasse e seleção — e o `Character` é a única chave
/// que carrega todas. É isso que faz a ficha recalcular sozinha: subir de
/// nível, trocar o pacto ou aprender Rajada Mística produz um `Character` novo
/// e, com ele, uma lista nova.
final resolvedInvocationsProvider = FutureProvider.family
    .autoDispose<ResolvedInvocations, Character>((ref, character) async {
  final catalog = await ref.watch(eldritchInvocationCatalogProvider.future);
  final classes = await ref.watch(classEntriesProvider.future);
  final subclasses = await ref.watch(subclassEntriesProvider.future);
  final spells = await ref.watch(spellEntriesProvider.future);

  return EldritchInvocationResolver.resolve(
    character: character,
    catalog: catalog,
    classes: classes,
    subclasses: subclasses,
    spells: spells,
  );
});

/// O perfil de Bruxo usado na validação, para a tela não remontá-lo.
final warlockProfileProvider = FutureProvider.family
    .autoDispose<WarlockProfile, Character>((ref, character) async {
  final resolved = await ref.watch(resolvedInvocationsProvider(character).future);
  return resolved.profile;
});

/// O que as invocações válidas fazem com Rajada Mística, já somado.
final eldritchBlastSummaryProvider = FutureProvider.family
    .autoDispose<EldritchBlastSummary, Character>((ref, character) async {
  final resolved = await ref.watch(
    resolvedInvocationsProvider(character).future,
  );

  return EldritchInvocationResolver.blastSummaryFor(
    character: character,
    invocations: resolved,
  );
});

/// O que as invocações válidas fazem com a arma do Pacto da Lâmina.
final pactWeaponSummaryProvider = FutureProvider.family
    .autoDispose<PactWeaponSummary, Character>((ref, character) async {
  final resolved = await ref.watch(
    resolvedInvocationsProvider(character).future,
  );

  return EldritchInvocationResolver.pactWeaponSummaryFor(
    character: character,
    invocations: resolved,
  );
});

/// Os recursos limitados que as invocações concedem.
///
/// Reaproveita `FeatureResources`, o mesmo motor dos recursos de
/// característica, em vez de um contador paralelo: a invocação declara o mesmo
/// bloco `action`, então o painel de Recursos e descanso e o descanso em si
/// funcionam sem saber que invocação existe.
final invocationResourcesProvider = FutureProvider.family
    .autoDispose<List<FeatureResource>, Character>((ref, character) async {
  final resolved = await ref.watch(
    resolvedInvocationsProvider(character).future,
  );

  return FeatureResources.from(
    character: character,
    features: resolved.asFeatures,
    context: FeatureFormulaContext.fromCharacter(character),
  );
});

final syncInvocationSpellsProvider = Provider<SyncInvocationSpells>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return SyncInvocationSpells(repository);
});

/// Resultado de uma escrita de invocação, para a tela avisar o jogador.
class InvocationWriteResult {
  const InvocationWriteResult({required this.message, required this.changed});

  final String message;
  final bool changed;
}

/// Lê o personagem agora, em vez de aceitar uma cópia de quem chamou.
///
/// É o ponto que impede o bug clássico desta tela: a página recebeu um
/// `Character` ao abrir, o jogador escolheu uma invocação, e a segunda escolha
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

/// Escolhe uma invocação numa vaga livre.
final selectEldritchInvocationProvider = Provider<
    Future<InvocationWriteResult> Function({
      required String characterId,
      required String invocationId,
    })>((ref) {
  return ({
    required String characterId,
    required String invocationId,
  }) async {
    final character = await _current(ref, characterId);
    final resolved = await ref.read(
      resolvedInvocationsProvider(character).future,
    );

    final outcome = EldritchInvocationSelection.select(
      character: character,
      resolved: resolved,
      invocationId: invocationId,
    );

    return _persist(
      ref,
      outcome,
      success: (entry) => '${entry.name} escolhida.',
    );
  };
});

/// Substitui uma invocação conhecida por outra.
final replaceEldritchInvocationProvider = Provider<
    Future<InvocationWriteResult> Function({
      required String characterId,
      required String replacedId,
      required String invocationId,
    })>((ref) {
  return ({
    required String characterId,
    required String replacedId,
    required String invocationId,
  }) async {
    final character = await _current(ref, characterId);
    final resolved = await ref.read(
      resolvedInvocationsProvider(character).future,
    );

    final outcome = EldritchInvocationSelection.replace(
      character: character,
      resolved: resolved,
      replacedId: replacedId,
      invocationId: invocationId,
    );

    final previous = resolved.byId(replacedId)?.name ?? replacedId;

    return _persist(
      ref,
      outcome,
      success: (entry) => '$previous substituída por ${entry.name}.',
    );
  };
});

/// Remove uma invocação, liberando a vaga.
final removeEldritchInvocationProvider = Provider<
    Future<InvocationWriteResult> Function({
      required String characterId,
      required String invocationId,
    })>((ref) {
  return ({
    required String characterId,
    required String invocationId,
  }) async {
    final character = await _current(ref, characterId);
    final resolved = await ref.read(
      resolvedInvocationsProvider(character).future,
    );

    final removed = resolved.byId(invocationId)?.name ?? invocationId;

    final outcome = EldritchInvocationSelection.remove(
      character: character,
      invocationId: invocationId,
    );

    return _persist(ref, outcome, success: (_) => '$removed removida.');
  };
});

/// Grava a Dádiva do Pacto escolhida e reconcilia o que ela libera ou bloqueia.
///
/// A dádiva é chave de dependência de metade do catálogo, então trocá-la pode
/// invalidar invocação já escolhida. A invalidação NÃO apaga a escolha: ela
/// passa a aparecer marcada na ficha, sem efeito, esperando substituição. O
/// que a troca faz é retirar do livro as magias das invocações que deixaram de
/// valer, e é a sincronização que cuida disso.
final choosePactBoonProvider = Provider<
    Future<void> Function({
      required String characterId,
      required PactBoon boon,
    })>((ref) {
  return ({required String characterId, required PactBoon boon}) async {
    final character = await _current(ref, characterId);

    final updated = FeatureResources.chooseOption(
      character: character,
      featureId: PactBoon.featureId,
      optionId: boon.id,
    );

    await ref
        .read(characterRepositoryProvider)
        .update(updated.copyWith(updatedAt: DateTime.now()));

    await _syncSpells(ref, characterId);
  };
});

/// Grava a mudança e deixa o livro de magias coerente com ela.
Future<InvocationWriteResult> _persist(
  Ref ref,
  InvocationSelectionOutcome outcome, {
  required String Function(EldritchInvocationEntry entry) success,
}) async {
  final error = outcome.error;
  if (error != null) {
    return InvocationWriteResult(message: error, changed: false);
  }

  if (!outcome.changed) {
    return const InvocationWriteResult(
      message: 'Nada a alterar.',
      changed: false,
    );
  }

  final repository = ref.read(characterRepositoryProvider);
  await repository.update(
    outcome.character.copyWith(updatedAt: DateTime.now()),
  );

  await _syncSpells(ref, outcome.character.id);

  final entry = outcome.selected;
  return InvocationWriteResult(
    message: entry == null
        ? 'Invocações atualizadas.'
        : success(entry),
    changed: true,
  );
}

/// Sincroniza as magias concedidas, sem deixar a escrita principal falhar.
///
/// Best-effort de propósito, como a sincronização de subclasse: se o compêndio
/// não carregar, a invocação continua gravada e a magia pode ser conferida
/// depois. Perder a escolha do jogador por causa de uma falha de leitura de
/// asset seria pior.
Future<void> _syncSpells(Ref ref, String characterId) async {
  try {
    final catalog = await ref.read(eldritchInvocationCatalogProvider.future);
    final classes = await ref.read(classEntriesProvider.future);
    final subclasses = await ref.read(subclassEntriesProvider.future);
    final spells = await ref.read(spellEntriesProvider.future);
    // O índice é montado aqui, e não lido de `spellNameIndexProvider`, para
    // este arquivo não depender de `character_providers.dart` — que já depende
    // deste, por causa dos recursos de invocação no descanso.
    final spellIndex = SpellNameIndex(spells);

    final result = await ref.read(syncInvocationSpellsProvider)(
      characterId: characterId,
      catalog: catalog,
      classes: classes,
      subclasses: subclasses,
      spells: spells,
      spellIndex: spellIndex,
    );

    if (result.unknownSpellNames.isNotEmpty) {
      // Nome que não existe no compêndio é erro de digitação no catálogo, e
      // precisa aparecer no log em vez de virar magia faltando em silêncio.
      debugPrint(
        'Magias de invocação não encontradas no compêndio: '
        '${result.unknownSpellNames.join(', ')}',
      );
    }
  } catch (error) {
    debugPrint('Falha ao sincronizar magias de invocação: $error');
  }
}
