import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_class_mechanic.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_prerequisites.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_resources.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_mechanic_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/class_mechanic_catalog.dart';

/// O que aconteceu ao tentar escolher, substituir, remover, ligar ou desligar
/// algo numa mecânica de classe.
///
/// Devolve resultado em vez de lançar porque "não pode" é um estado normal da
/// tela, não um defeito: o jogador toca numa manobra bloqueada e precisa ler o
/// motivo, não ver o app quebrar.
class MechanicSelectionOutcome {
  const MechanicSelectionOutcome._({
    required this.character,
    required this.changed,
    this.error,
    this.selected,
    this.replaced,
    this.deactivated = const [],
  });

  factory MechanicSelectionOutcome.unchanged(
    Character character, {
    String? error,
  }) {
    return MechanicSelectionOutcome._(
      character: character,
      changed: false,
      error: error,
    );
  }

  factory MechanicSelectionOutcome.applied(
    Character character, {
    MechanicOption? selected,
    String? replaced,
    List<String> deactivated = const [],
  }) {
    return MechanicSelectionOutcome._(
      character: character,
      changed: true,
      selected: selected,
      replaced: replaced,
      deactivated: deactivated,
    );
  }

  /// O personagem já com a mudança, ou o original quando nada mudou.
  final Character character;

  final bool changed;

  /// Motivo da recusa, pronto para a tela mostrar. Nulo quando deu certo.
  final String? error;

  /// A opção que entrou, quando entrou alguma.
  final MechanicOption? selected;

  /// Id da opção que saiu, quando houve substituição ou remoção.
  final String? replaced;

  /// Nomes dos modos que foram desligados para abrir espaço.
  ///
  /// Existe para a tela poder AVISAR da transição em vez de o jogador
  /// descobrir sozinho que a Forma Estelar anterior sumiu.
  final List<String> deactivated;

  bool get isRejected => error != null;

  /// Aviso sobre a transição de modos, quando houve alguma.
  String? get transitionNotice {
    if (deactivated.isEmpty) return null;
    if (deactivated.length == 1) {
      return '${deactivated.first} foi desativada para abrir espaço.';
    }
    return '${deactivated.join(', ')} foram desativadas para abrir espaço.';
  }
}

/// Escolhe, substitui, remove, liga e desliga opções de mecânicas de classe.
///
/// Toda escrita passa por aqui, e é de propósito: a validação de
/// pré-requisito, de vaga e de modo incompatível mora no DOMÍNIO, não numa
/// opção desabilitada na interface. Se a decisão estivesse só no widget,
/// importar uma ficha, subir de nível ou editar a classe entraria sem
/// validação nenhuma.
///
/// O que o serviço NUNCA faz: apagar uma escolha em silêncio. Opção que perdeu
/// o pré-requisito continua gravada, aparece marcada como inválida e espera o
/// jogador substituí-la — ver [MechanicOptionAvailability.invalid].
class ClassMechanicSelection {
  const ClassMechanicSelection._();

  /// Acrescenta uma opção, se houver vaga e os pré-requisitos baterem.
  static MechanicSelectionOutcome select({
    required Character character,
    required ResolvedClassMechanic mechanic,
    required String optionId,
  }) {
    if (!mechanic.isUnlocked) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: mechanic.blocks.map((item) => item.message).join(' '),
      );
    }

    if (!mechanic.entry.hasPicks) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: '${mechanic.name} não guarda escolhas permanentes.',
      );
    }

    final resolved = mechanic.optionById(optionId);

    if (resolved == null) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: 'Esta opção não existe nesta característica.',
      );
    }

    if (resolved.isGranted) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: '${resolved.name} é concedida pela regra e não ocupa vaga.',
      );
    }

    if (resolved.isOwned && !mechanic.entry.allowDuplicateOptions) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: '${resolved.name} já está selecionada.',
      );
    }

    if (resolved.blocks.isNotEmpty) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: resolved.blockReason,
      );
    }

    if (mechanic.freeSlots <= 0) {
      // Sem vaga, a saída é substituir — e é isso que a mensagem diz, em vez
      // de escolher sozinha qual opção descartar.
      final suffix =
          mechanic.entry.canReplace
              ? ' Substitua uma opção para escolher outra.'
              : '';

      return MechanicSelectionOutcome.unchanged(
        character,
        error: 'Você já tem ${mechanic.countLabel}.$suffix',
      );
    }

    return MechanicSelectionOutcome.applied(
      character.copyWith(
        classMechanics: [
          ...character.classMechanics,
          CharacterClassMechanic(
            mechanicId: mechanic.id,
            optionId: resolved.id,
            chosenAtLevel: mechanic.classLevel,
          ),
        ],
      ),
      selected: resolved.option,
    );
  }

  /// Troca uma opção conhecida por outra para a qual o personagem seja
  /// elegível.
  ///
  /// [freeEdit] é o modo explícito de edição livre da ficha. Ele não cria
  /// permissão onde não existe: mecânica sem regra de substituição continua
  /// sem troca, porque o Ancestral Dracônico é escolhido uma vez e pronto.
  static MechanicSelectionOutcome replace({
    required Character character,
    required ResolvedClassMechanic mechanic,
    required String replacedId,
    required String optionId,
    bool freeEdit = false,
    ClassMechanicCatalog? catalog,
  }) {
    if (replacedId == optionId) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: 'Escolha uma opção diferente da que será substituída.',
      );
    }

    if (!mechanic.entry.canReplace) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error:
            '${mechanic.name} não permite substituir uma opção já '
            'escolhida.',
      );
    }

    if (!mechanic.entry.canReplaceAt(mechanic.classLevel, freeEdit: freeEdit)) {
      final rule = mechanic.entry.replacement!;
      return MechanicSelectionOutcome.unchanged(
        character,
        error: 'A substituição não está disponível agora. ${rule.label}',
      );
    }

    final current = mechanic.optionById(replacedId);
    final hasSelection = character.classMechanics.any(
      (item) =>
          item.mechanicId == mechanic.id &&
          item.optionId == replacedId &&
          item.countsAsPick,
    );

    if (!hasSelection) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error:
            '${current?.name ?? replacedId} não está entre as opções '
            'selecionadas.',
      );
    }

    final candidate = mechanic.optionById(optionId);

    if (candidate == null) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: 'Esta opção não existe nesta característica.',
      );
    }

    if (candidate.isOwned && !mechanic.entry.allowDuplicateOptions) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: '${candidate.name} já está selecionada.',
      );
    }

    // A substituta é validada com a que SAI já fora da conta. Importa em dois
    // casos: uma opção incompatível com a que está sendo substituída tem de
    // poder entrar, e uma que dependa da que sai não pode entrar.
    final blocks = ClassMechanicPrerequisites.evaluateOption(
      entry: mechanic.entry,
      option: candidate.option,
      profile: _withoutOption(mechanic: mechanic, optionId: replacedId),
      catalog: catalog,
    );

    if (blocks.isNotEmpty) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: blocks.map((item) => item.message).join(' '),
      );
    }

    final updated = character.copyWith(
      classMechanics: [
        for (final item in character.classMechanics)
          if (!(item.mechanicId == mechanic.id && item.optionId == replacedId))
            item,
        CharacterClassMechanic(
          mechanicId: mechanic.id,
          optionId: candidate.id,
          chosenAtLevel: mechanic.classLevel,
          replacedOptionId: replacedId,
          replacedAtLevel: mechanic.classLevel,
        ),
      ],
    );

    return MechanicSelectionOutcome.applied(
      _withoutState(updated, mechanic: mechanic, optionId: replacedId),
      selected: candidate.option,
      replaced: replacedId,
    );
  }

  /// Remove uma opção, liberando a vaga.
  ///
  /// Existe para o jogador corrigir uma escolha, e não para o app limpar
  /// seleção inválida por conta própria: quem decide descartar é sempre o
  /// jogador.
  static MechanicSelectionOutcome remove({
    required Character character,
    required ResolvedClassMechanic mechanic,
    required String optionId,
  }) {
    final hasSelection = character.classMechanics.any(
      (item) =>
          item.mechanicId == mechanic.id &&
          item.optionId == optionId &&
          item.countsAsPick,
    );

    if (!hasSelection) {
      return MechanicSelectionOutcome.unchanged(character);
    }

    final updated = character.copyWith(
      classMechanics: [
        for (final item in character.classMechanics)
          if (!(item.mechanicId == mechanic.id && item.optionId == optionId))
            item,
      ],
    );

    return MechanicSelectionOutcome.applied(
      _withoutState(updated, mechanic: mechanic, optionId: optionId),
      replaced: optionId,
    );
  }

  /// Liga um modo, fazendo a transição de forma segura.
  ///
  /// Quando o modo que entra é incompatível com um já ligado, ou quando o
  /// limite é de um modo por vez, os conflitantes são DESLIGADOS e a transição
  /// é reportada em [MechanicSelectionOutcome.deactivated]. É o que o
  /// levantamento pede: informar o conflito e transicionar, em vez de recusar
  /// sem explicar ou deixar dois estados incompatíveis ligados.
  ///
  /// Quando o limite é maior que um e já está cheio, a ativação é RECUSADA: aí
  /// não existe "o conflitante óbvio", e desligar um à sorte perderia estado
  /// que o jogador controlava.
  static MechanicSelectionOutcome activate({
    required Character character,
    required ResolvedClassMechanic mechanic,
    required String optionId,
  }) {
    final resolved = mechanic.optionById(optionId);

    if (resolved == null) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: 'Esta opção não existe nesta característica.',
      );
    }

    if (!resolved.option.isMode) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: '${resolved.name} não é um modo que possa ser ligado.',
      );
    }

    if (!resolved.isOwned) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error:
            '${resolved.name} ainda não está disponível. '
                    '${resolved.blockReason}'
                .trim(),
      );
    }

    if (resolved.isInvalid) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error:
            '${resolved.name} perdeu os pré-requisitos e não pode ser '
                    'ativada. ${resolved.blockReason}'
                .trim(),
      );
    }

    if (resolved.isActive) {
      return MechanicSelectionOutcome.unchanged(character);
    }

    final limit = mechanic.maxActive;
    final conflicting = _conflictingActive(mechanic, resolved);

    // Limite maior que um, cheio e sem conflito declarado: o jogador precisa
    // escolher o que desligar.
    if (limit != null &&
        limit > 1 &&
        mechanic.active.length >= limit &&
        conflicting.isEmpty) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error:
            'No máximo $limit opções desta característica podem ficar '
            'ativas por vez. Desative uma antes de ligar outra.',
      );
    }

    final toDeactivate = <ResolvedMechanicOption>[
      ...conflicting,
      // Com limite de um modo, qualquer outro ligado sai: é a transição segura
      // da Forma Estelar, do Modelo de Armadura e do Terceiro Olho.
      if (limit == 1)
        for (final active in mechanic.active)
          if (active.id != resolved.id && !conflicting.contains(active)) active,
    ];

    var updated = character;
    for (final item in toDeactivate) {
      updated = FeatureResources.setActive(
        character: updated,
        featureId: mechanic.entry.featureIdFor(item.id),
        isActive: false,
      );
    }

    updated = FeatureResources.setActive(
      character: updated,
      featureId: mechanic.entry.featureIdFor(resolved.id),
      isActive: true,
    );

    return MechanicSelectionOutcome.applied(
      updated,
      selected: resolved.option,
      deactivated: [for (final item in toDeactivate) item.name],
    );
  }

  /// Desliga um modo.
  ///
  /// Os efeitos param de valer no mesmo instante: quem decide isso é
  /// [ResolvedMechanicOption.appliesEffects], que só conta modo ligado.
  static MechanicSelectionOutcome deactivate({
    required Character character,
    required ResolvedClassMechanic mechanic,
    required String optionId,
  }) {
    final resolved = mechanic.optionById(optionId);

    if (resolved == null) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: 'Esta opção não existe nesta característica.',
      );
    }

    if (!resolved.isActive) {
      return MechanicSelectionOutcome.unchanged(character);
    }

    return MechanicSelectionOutcome.applied(
      FeatureResources.setActive(
        character: character,
        featureId: mechanic.entry.featureIdFor(resolved.id),
        isActive: false,
      ),
      selected: resolved.option,
    );
  }

  /// Desliga TODOS os modos de uma mecânica.
  ///
  /// Serve para o encerramento declarado pela regra — a Fúria acabou, o
  /// descanso terminou — sem a tela precisar iterar as opções.
  static Character deactivateAll({
    required Character character,
    required ResolvedClassMechanic mechanic,
  }) {
    var updated = character;

    for (final option in mechanic.active) {
      updated = FeatureResources.setActive(
        character: updated,
        featureId: mechanic.entry.featureIdFor(option.id),
        isActive: false,
      );
    }

    return updated;
  }

  /// Registra o resultado de uma tabela de rolagem.
  ///
  /// Guarda o id da LINHA, e nada é aplicado automaticamente: o levantamento é
  /// explícito em que o resultado é consultado, e metade dos efeitos depende
  /// de escolha de alvo em mesa.
  static MechanicSelectionOutcome setRollResult({
    required Character character,
    required ResolvedClassMechanic mechanic,
    required String rowId,
  }) {
    final table = mechanic.table;

    if (table == null) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: '${mechanic.name} não tem tabela para registrar resultado.',
      );
    }

    if (table.byId(rowId) == null) {
      return MechanicSelectionOutcome.unchanged(
        character,
        error: 'Este resultado não existe na tabela.',
      );
    }

    return MechanicSelectionOutcome.applied(
      _writeMechanicRecord(
        character,
        mechanicId: mechanic.id,
        rollResult: rowId,
      ),
    );
  }

  /// Apaga o resultado registrado da tabela.
  static MechanicSelectionOutcome clearRollResult({
    required Character character,
    required ResolvedClassMechanic mechanic,
  }) {
    final hasResult = character.classMechanics.any(
      (item) => item.mechanicId == mechanic.id && item.hasRollResult,
    );

    if (!hasResult) return MechanicSelectionOutcome.unchanged(character);

    return MechanicSelectionOutcome.applied(
      _writeMechanicRecord(character, mechanicId: mechanic.id, rollResult: ''),
    );
  }

  /// Remove tudo o que estava gravado de uma mecânica.
  ///
  /// Usado quando o jogador pede para refazer as escolhas. Não é chamado por
  /// mudança de classe ou de nível: lá o histórico é preservado e as escolhas
  /// que perderam validade aparecem marcadas, para o jogador decidir.
  static MechanicSelectionOutcome reset({
    required Character character,
    required ResolvedClassMechanic mechanic,
  }) {
    final hasAny = character.classMechanics.any(
      (item) => item.mechanicId == mechanic.id,
    );

    if (!hasAny) return MechanicSelectionOutcome.unchanged(character);

    var updated = character.copyWith(
      classMechanics: [
        for (final item in character.classMechanics)
          if (item.mechanicId != mechanic.id) item,
      ],
    );

    // Os usos e o estado ativo moram em `featureStates`: limpar só a seleção
    // deixaria um contador órfão que voltaria a aparecer se a opção fosse
    // escolhida de novo.
    final prefix = '${ClassMechanicEntry.mechanicFeatureId(mechanic.id)}.';
    final own = ClassMechanicEntry.mechanicFeatureId(mechanic.id);

    updated = updated.copyWith(
      featureStates: [
        for (final state in updated.featureStates)
          if (state.featureId != own && !state.featureId.startsWith(prefix))
            state,
      ],
    );

    return MechanicSelectionOutcome.applied(updated);
  }

  /// O perfil da mecânica sem contar [optionId] entre as selecionadas.
  static MechanicProfile _withoutOption({
    required ResolvedClassMechanic mechanic,
    required String optionId,
  }) {
    final key = ClassMechanicPrerequisites.optionKey(mechanic.id, optionId);

    return MechanicProfile(
      classLevels: {mechanic.classId: mechanic.classLevel},
      subclassByClass: {
        if (mechanic.entry.subclassId case final id? when id.isNotEmpty)
          mechanic.classId: id,
      },
      selectedOptionKeys: {
        for (final option in mechanic.owned)
          if (option.key != key) option.key,
      },
      activeOptionKeys: {
        for (final option in mechanic.active)
          if (option.key != key) option.key,
      },
    );
  }

  /// Modos ligados que são incompatíveis com [candidate].
  static List<ResolvedMechanicOption> _conflictingActive(
    ResolvedClassMechanic mechanic,
    ResolvedMechanicOption candidate,
  ) {
    final declared = <String>{
      for (final reference in candidate.option.incompatibleWith)
        ClassMechanicPrerequisites.resolveKey(
          reference,
          withinMechanicId: mechanic.id,
        ),
    };

    return [
      for (final active in mechanic.active)
        if (active.id != candidate.id &&
            (declared.contains(active.key) ||
                active.option.incompatibleWith.any(
                  (reference) =>
                      ClassMechanicPrerequisites.resolveKey(
                        reference,
                        withinMechanicId: mechanic.id,
                      ) ==
                      candidate.key,
                )))
          active,
    ];
  }

  /// Apaga o estado de usos e de ativação de uma opção que saiu da ficha.
  ///
  /// Um contador de opção que não está mais selecionada não tem sentido, e
  /// mantê-lo faria a opção voltar já gasta se o jogador a escolhesse de novo.
  static Character _withoutState(
    Character character, {
    required ResolvedClassMechanic mechanic,
    required String optionId,
  }) {
    final featureId = mechanic.entry.featureIdFor(optionId);

    if (character.featureStateFor(featureId) == null) return character;

    return character.copyWith(
      featureStates: [
        for (final state in character.featureStates)
          if (state.featureId != featureId) state,
      ],
    );
  }

  /// Grava o registro de nível de MECÂNICA (resultado de tabela, anotação).
  ///
  /// É a linha com `optionId` nulo: ela não conta como escolha, e por isso
  /// `isSelected` é falso — senão o resultado "3" do Surto Selvagem apareceria
  /// como uma manobra escolhida na contagem.
  static Character _writeMechanicRecord(
    Character character, {
    required String mechanicId,
    String? rollResult,
    String? note,
  }) {
    CharacterClassMechanic? existing;
    for (final item in character.classMechanics) {
      if (item.mechanicId == mechanicId && !item.hasOption) {
        existing = item;
        break;
      }
    }

    final nextRoll =
        rollResult == null
            ? existing?.rollResult
            : rollResult.isEmpty
            ? null
            : rollResult;
    final nextNote =
        note == null
            ? existing?.note
            : note.isEmpty
            ? null
            : note;

    final replacement = CharacterClassMechanic(
      localId: existing?.localId,
      mechanicId: mechanicId,
      isSelected: false,
      rollResult: nextRoll,
      note: nextNote,
    );

    if (existing == null) {
      // Registro que não guarda nada não é criado: é o que evita a ficha
      // acumular linha vazia a cada abertura.
      if (replacement.isPristine) return character;

      return character.copyWith(
        classMechanics: [...character.classMechanics, replacement],
      );
    }

    if (replacement.isPristine) {
      return character.copyWith(
        classMechanics: [
          for (final item in character.classMechanics)
            if (!identical(item, existing)) item,
        ],
      );
    }

    return character.copyWith(
      classMechanics: [
        for (final item in character.classMechanics)
          if (identical(item, existing)) replacement else item,
      ],
    );
  }
}
