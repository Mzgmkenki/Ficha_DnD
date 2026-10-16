import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/feature_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_score_improvement.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/services/ability_score_improvements.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feat_eligibility.dart';
import 'package:dnd_ficha_app/features/character/domain/services/level_progression_choices.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/ability_score_improvement_dialog.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/feat_picker_dialog.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/level_progression_choice_dialog.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Conduz a escolha de progressão de nível: talento OU Incremento no Valor de
/// Atributo.
///
/// Por que existe como objeto próprio, e não como métodos de uma tela: três
/// caminhos precisam da MESMA sequência de janelas — a seção da ficha, a
/// subida de nível e a tela de níveis de classe. Antes só a seção da ficha
/// sabia conduzi-la, e por isso subir de nível apenas mostrava um aviso de
/// rodapé: a janela nunca abria sozinha porque o fluxo não existia fora do
/// painel que o implementava.
///
/// Não decide NADA de regra. Quem diz quais vagas existem é
/// [LevelProgressionChoices], a partir de `ClassEntry.featLevels` do
/// compêndio; quem grava é o caso de uso. Daí a consequência que o requisito
/// pede: nenhuma lista fixa de níveis mora aqui, e uma classe que conceda a
/// escolha em níveis diferentes passa a funcionar sem tocar nesta camada.
class LevelProgressionFlow {
  const LevelProgressionFlow({
    required this.ref,
    required this.character,
    required this.classes,
    required this.catalog,
    required this.races,
  });

  final WidgetRef ref;

  /// O personagem como está GRAVADO, e não como a tela o viu pela última vez.
  final Character character;

  final List<ClassEntry> classes;
  final List<FeatEntry> catalog;
  final List<RaceEntry> races;

  /// Monta o fluxo lendo o personagem do banco e o compêndio.
  ///
  /// Lê do repositório, e não do `characterByIdProvider`: a sequência roda logo
  /// depois de uma gravação, e o stream da ficha pode ainda não ter emitido o
  /// personagem novo. Com o valor antigo a vaga que o nível acabou de abrir não
  /// apareceria — justamente o caso em que a janela precisa abrir.
  ///
  /// Devolve nulo quando falta algo essencial. Best-effort de propósito: falha
  /// de leitura de asset não pode desfazer um nível já gravado, e a pendência
  /// continua marcada na ficha para a próxima tentativa.
  static Future<LevelProgressionFlow?> load(
    WidgetRef ref, {
    required String characterId,
  }) async {
    try {
      final character = await ref
          .read(characterRepositoryProvider)
          .findById(characterId);

      if (character == null) return null;

      final classes = await ref.read(classEntriesProvider.future);
      final catalog = await ref.read(featEntriesProvider.future);

      // A raça só importa para o talento do Humano Variante e para o filtro de
      // pré-requisito: falhar nela cai numa lista vazia em vez de cancelar a
      // escolha inteira.
      List<RaceEntry> races;
      try {
        races = await ref.read(raceEntriesProvider.future);
      } catch (_) {
        races = const [];
      }

      return LevelProgressionFlow(
        ref: ref,
        character: character,
        classes: classes,
        catalog: catalog,
        races: races,
      );
    } catch (error, stackTrace) {
      debugPrint('Falha ao carregar as escolhas de progressão: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  /// Todas as vagas de progressão, resolvidas e em aberto.
  List<LevelProgressionSlot> get slots =>
      LevelProgressionChoices.forCharacter(character, classes, races: races);

  /// Só as vagas em aberto, na ordem em que foram concedidas.
  List<LevelProgressionSlot> get pending =>
      LevelProgressionChoices.pendingFor(character, classes, races: races);

  /// Os talentos que este personagem alcança agora.
  List<FeatEntry> get availableFeats {
    if (catalog.isEmpty) return const [];

    return FeatEligibility.available(
      feats: catalog,
      character: character,
      classes: classes,
      races: races,
    );
  }

  /// Pergunta o que fazer com a vaga e encaminha para o fluxo escolhido.
  ///
  /// Devolve `true` só quando a vaga foi de fato GRAVADA. Fechar sem decidir,
  /// cancelar a distribuição de pontos ou desistir do seletor de talentos
  /// devolvem `false` e não aplicam nada — nem parcialmente. É esse retorno
  /// que a sequência automática usa para saber se pode seguir para a próxima
  /// pendência ou se deve parar.
  Future<bool> chooseFor(
    BuildContext context,
    LevelProgressionSlot slot, {
    bool barrierDismissible = true,
  }) async {
    final available = availableFeats;

    // Vaga que não aceita incremento e sem talento elegível não tem o que
    // oferecer: avisa em vez de abrir um diálogo vazio.
    if (!slot.allowsImprovement && available.isEmpty) {
      notify(context, noFeatsMessage);
      return false;
    }

    final decision = await showLevelProgressionChoiceDialog(
      context: context,
      slot: slot,
      canChooseFeat: available.isNotEmpty,
      featUnavailableReason: noFeatsMessage,
      barrierDismissible: barrierDismissible,
    );

    if (decision == null || !context.mounted) return false;

    return switch (decision) {
      LevelProgressionDecision.feat => addFeat(context, slot),
      LevelProgressionDecision.improvement => addImprovement(context, slot),
    };
  }

  /// Abre o seletor e grava o talento na vaga.
  Future<bool> addFeat(BuildContext context, LevelProgressionSlot? slot) async {
    // Só entra na lista o que o personagem alcança. `available` também descarta
    // o talento não repetível que ele já tem, senão o caso de uso recusaria
    // depois de o jogador ter escolhido.
    final available = availableFeats;

    if (available.isEmpty) {
      notify(context, noFeatsMessage);
      return false;
    }

    final choice = await showFeatPickerDialog(
      context: context,
      available: available,
      slotLabel: slot == null || slot.fromRace ? null : slot.label,
    );

    if (choice == null || !context.mounted) return false;

    // A vaga diz exatamente qual classe e qual NÍVEL DA CLASSE concederam a
    // escolha. Antes era gravado o nível TOTAL do personagem, que no
    // multiclasse não corresponde a vaga nenhuma — e por isso a ficha não
    // conseguia dizer em que nível cada talento tinha sido pego.
    final classId =
        slot != null && !slot.fromRace
            ? slot.classId
            : (character.classLevels.length == 1
                ? character.classLevels.single.classId
                : null);

    final level =
        slot != null && !slot.fromRace
            ? slot.classLevel
            : (classId == null ? null : character.totalLevel);

    try {
      await ref
          .read(manageCharacterFeatsProvider)
          .addFeat(
            characterId: character.id,
            feat: choice.feat,
            chosenSkills: choice.skills,
            chosenAbility: choice.ability,
            classId: classId,
            level: level,
          );

      return true;
    } catch (error) {
      if (!context.mounted) return false;
      notify(context, 'Não deu para adicionar o talento: $error');
      return false;
    }
  }

  /// Abre a distribuição de pontos e grava o incremento na vaga.
  ///
  /// O incremento NÃO é gravado como um talento de mentira: ele vira uma
  /// [AbilityScoreImprovement] própria, com a classe e o nível de origem, e é
  /// isso que permite removê-lo devolvendo exatamente os pontos que deu.
  Future<bool> addImprovement(
    BuildContext context,
    LevelProgressionSlot slot, {
    CharacterFeat? replacing,
  }) async {
    final maximums = await _maximums();
    if (!context.mounted) return false;

    // Ao trocar um talento que dava atributo, o teto é conferido contra a
    // ficha JÁ sem ele: o ponto que o talento ocupava volta a ser folga.
    final current =
        replacing == null
            ? character.abilityScores
            : AbilityScoreImprovements.revoke(
              character.abilityScores,
              replacing.appliedAbilityIncreases,
            );

    final draft = await showAbilityScoreImprovementDialog(
      context: context,
      current: current,
      slotLabel: slot.label,
      maximums: maximums,
    );

    if (draft == null || !context.mounted) return false;

    final useCase = ref.read(manageAbilityScoreImprovementsProvider);

    try {
      final outcome =
          replacing == null
              ? await useCase.choose(
                characterId: character.id,
                classId: slot.classId,
                classLevel: slot.classLevel,
                increases: draft.increases,
                maximums: maximums,
              )
              : await useCase.replaceFeat(
                characterId: character.id,
                featLocalId: replacing.localId!,
                classId: slot.classId,
                classLevel: slot.classLevel,
                increases: draft.increases,
                maximums: maximums,
              );

      if (!context.mounted) return true;

      notify(
        context,
        '${slot.label} — Incremento no Valor de Atributo: '
        '${outcome.appliedLabel}.'
        '${outcome.unequippedArmorNotice == null ? '' : ' '
                '${outcome.unequippedArmorNotice}'}',
      );

      return true;
    } catch (error) {
      if (!context.mounted) return false;
      notify(context, 'Não deu para registrar o incremento: $error');
      return false;
    }
  }

  /// Troca um talento já escolhido por um incremento, na mesma vaga.
  Future<void> swapFeatForImprovement(
    BuildContext context,
    LevelProgressionSlot slot,
    CharacterFeat feat,
  ) async {
    if (feat.localId == null) {
      notify(context, 'Salve a ficha antes de trocar este talento.');
      return;
    }

    final confirmed = await confirm(
      context,
      title: 'Trocar por incremento?',
      message:
          'O talento sai da ficha e o que ele concedeu é desfeito: '
          'proficiências que só ele dava e o aumento de atributo dele. '
          'Depois você distribui os pontos do incremento.',
      confirmLabel: 'Trocar',
    );

    if (!confirmed || !context.mounted) return;

    await addImprovement(context, slot, replacing: feat);
  }

  /// Troca um incremento por um talento, na mesma vaga.
  ///
  /// Em dois passos, e não numa gravação só: o estado intermediário — vaga
  /// pendente, pontos devolvidos — é um estado VÁLIDO da ficha. Se a escolha
  /// do talento for cancelada no meio, o personagem fica coerente e a ficha
  /// volta a oferecer a escolha.
  Future<void> swapImprovementForFeat(
    BuildContext context,
    AbilityScoreImprovement improvement,
  ) async {
    final localId = improvement.localId;
    if (localId == null) {
      notify(context, 'Salve a ficha antes de trocar este incremento.');
      return;
    }

    final confirmed = await confirm(
      context,
      title: 'Trocar por talento?',
      message:
          improvement.isEmpty
              ? 'O incremento sai da ficha e a escolha volta a ficar em aberto.'
              : 'Os pontos deste incremento (${improvement.increasesLabel}) '
                  'voltam. Bônus de origem, itens e incrementos de outros níveis '
                  'não são tocados.',
      confirmLabel: 'Trocar',
    );

    if (!confirmed || !context.mounted) return;

    if (!await removeImprovement(context, improvement, confirmFirst: false)) {
      return;
    }

    if (!context.mounted) return;

    // Relê do banco antes de escolher o talento: sem o incremento os atributos
    // caíram, e um talento com pré-requisito de atributo não pode ser
    // oferecido com base nos números antigos.
    final next = await load(ref, characterId: character.id);
    if (next == null || !context.mounted) return;

    final slot = LevelProgressionSlot(
      classId: improvement.classId,
      className: _classNameFor(classes, improvement.classId),
      classLevel: improvement.classLevel,
    );

    await next.addFeat(context, slot);
  }

  /// Remove um incremento e devolve os pontos que ele havia dado.
  Future<bool> removeImprovement(
    BuildContext context,
    AbilityScoreImprovement improvement, {
    bool confirmFirst = true,
  }) async {
    final localId = improvement.localId;
    if (localId == null) return false;

    if (confirmFirst) {
      final confirmed = await confirm(
        context,
        title: 'Remover incremento?',
        message:
            improvement.isEmpty
                ? 'A escolha volta a ficar em aberto.'
                : 'Os pontos (${improvement.increasesLabel}) voltam, e a escolha '
                    'deste nível fica em aberto de novo.',
        confirmLabel: 'Remover',
      );

      if (!confirmed || !context.mounted) return false;
    }

    try {
      final outcome = await ref
          .read(manageAbilityScoreImprovementsProvider)
          .remove(characterId: character.id, localId: localId);

      if (!context.mounted) return true;

      if (outcome.unequippedArmorNotice case final notice?) {
        notify(context, notice);
      }

      return true;
    } catch (error) {
      if (!context.mounted) return false;
      notify(context, 'Não deu para remover o incremento: $error');
      return false;
    }
  }

  /// Remove um talento escolhido, liberando a vaga do nível.
  Future<void> removeFeat(BuildContext context, CharacterFeat feat) async {
    final localId = feat.localId;
    if (localId == null) return;

    try {
      await ref
          .read(manageCharacterFeatsProvider)
          .removeFeat(characterId: character.id, localId: localId);
    } catch (error) {
      if (!context.mounted) return;
      notify(context, 'Não deu para remover o talento: $error');
    }
  }

  /// O teto de cada atributo, com as exceções de característica.
  ///
  /// Falha de leitura do compêndio cai no teto padrão em vez de impedir a
  /// escolha: 20 é o limite da regra, e é o certo em todos os casos menos a
  /// exceção declarada.
  Future<Map<Ability, int>> _maximums() async {
    try {
      return await ref.read(abilityMaximumsProvider(character).future);
    } catch (_) {
      return const {};
    }
  }

  static const String noFeatsMessage =
      'Nenhum talento disponível: o personagem não cumpre os pré-requisitos '
      'dos que restam.';

  static String _classNameFor(List<ClassEntry> classes, String classId) {
    for (final entry in classes) {
      if (entry.id == classId) return entry.name;
    }
    return classId;
  }

  static void notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final answer = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(confirmLabel),
              ),
            ],
          ),
    );

    return answer ?? false;
  }
}

/// Abre automaticamente as escolhas de progressão em aberto, uma por vez.
///
/// É o que faltava para a janela aparecer sozinha: a subida de nível e a tela
/// de níveis chamam isto depois de gravar, e cada pendência vira uma janela na
/// ordem em que foi concedida.
///
/// Depois de gravar, e nunca antes, por um motivo concreto: quem resolve a
/// escolha lê o personagem do BANCO. Exigir a decisão antes do salvamento
/// deixaria o jogador sem caminho para decidir — foi o mesmo laço que o totem
/// de 3º nível do Bárbaro produziu.
///
/// Por que relê o personagem a cada volta em vez de percorrer uma lista: a
/// vaga só sai da fila quando a gravação acontece. Reusar a lista de antes
/// reofereceria uma vaga já preenchida e, pior, deixaria `_guardSlotIsFree`
/// recusar a segunda gravação no mesmo nível.
Future<void> promptPendingLevelProgression({
  required BuildContext context,
  required WidgetRef ref,
  required String characterId,
}) async {
  // Trava contra laço de janelas: a fila tem de ENCURTAR a cada volta. Se não
  // encurtou, a gravação não consumiu a vaga e insistir repetiria a mesma
  // janela para sempre.
  var previousPending = -1;

  while (true) {
    if (!context.mounted) return;

    final flow = await LevelProgressionFlow.load(ref, characterId: characterId);
    if (flow == null || !context.mounted) return;

    final pending = flow.pending;

    // Nível sem escolha não abre nada, e é por isso que não existe lista fixa
    // de níveis aqui: quem não tem vaga em aberto sai por este `return`.
    if (pending.isEmpty) return;
    if (previousPending >= 0 && pending.length >= previousPending) return;
    previousPending = pending.length;

    final resolved = await flow.chooseFor(
      context,
      pending.first,
      barrierDismissible: false,
    );

    // Desistir encerra a sequência. A pendência continua marcada na ficha e
    // volta a ser oferecida na próxima subida de nível ou ao salvar a tela de
    // níveis: insistir agora prenderia o jogador num laço de janelas.
    if (!resolved) return;
  }
}
