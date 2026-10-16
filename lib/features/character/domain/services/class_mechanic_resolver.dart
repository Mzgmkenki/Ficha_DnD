import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_class_mechanic.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_prerequisites.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_resources.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_mechanic_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_table.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/class_mechanic_catalog.dart';

/// Em que situação uma opção de mecânica está, para este personagem.
enum MechanicOptionAvailability {
  /// Escolhida e com todos os pré-requisitos cumpridos.
  selected('selected', 'Selecionada'),

  /// Concedida pela regra, sem gastar vaga.
  granted('granted', 'Concedida'),

  /// Escolhida, mas os pré-requisitos deixaram de ser cumpridos.
  ///
  /// Continua ocupando a vaga e aparecendo na ficha. Os efeitos NÃO são
  /// aplicados, e a ficha pede a substituição — apagar a escolha em silêncio
  /// seria pior, porque o jogador perderia a decisão sem saber por quê.
  invalid('invalid', 'Inválida'),

  /// Disponível para escolher.
  available('available', 'Disponível'),

  /// Visível, mas bloqueada por pré-requisito.
  blocked('blocked', 'Bloqueada');

  const MechanicOptionAvailability(this.id, this.label);

  final String id;
  final String label;

  /// Se a opção está no conjunto "o personagem tem esta opção".
  bool get isOwned =>
      this == MechanicOptionAvailability.selected ||
      this == MechanicOptionAvailability.granted ||
      this == MechanicOptionAvailability.invalid;

  /// Se a opção gasta uma vaga de escolha.
  bool get consumesSlot =>
      this == MechanicOptionAvailability.selected ||
      this == MechanicOptionAvailability.invalid;
}

/// Uma opção de mecânica, já resolvida contra este personagem.
class ResolvedMechanicOption {
  const ResolvedMechanicOption({
    required this.mechanicId,
    required this.option,
    required this.availability,
    this.blocks = const [],
    this.activationBlocks = const [],
    this.isActive = false,
    this.chosenAtLevel = 0,
    this.replacedOptionId,
    this.replacedAtLevel,
    this.resource,
  });

  final String mechanicId;
  final MechanicOption option;
  final MechanicOptionAvailability availability;

  /// Pré-requisitos não cumpridos. Vazia quando está disponível ou válida.
  final List<MechanicBlock> blocks;

  /// O que impede a ATIVAÇÃO agora, mesmo com a opção escolhida e válida.
  ///
  /// Separado de [blocks] porque são perguntas diferentes: "posso escolher" e
  /// "posso ligar agora". Um modo pode estar conhecido e válido e ainda assim
  /// não poder ser ligado porque outro incompatível está ativo.
  final List<MechanicBlock> activationBlocks;

  /// Se o modo está ligado.
  final bool isActive;

  /// Nível na classe em que a opção foi escolhida. Zero quando não foi.
  final int chosenAtLevel;

  final String? replacedOptionId;
  final int? replacedAtLevel;

  /// Usos próprios da opção, quando ela declara algum.
  final FeatureResource? resource;

  String get id => option.id;

  String get name => option.name;

  /// Chave desta opção, como o perfil e o serviço de seleção a montam.
  String get key => ClassMechanicPrerequisites.optionKey(mechanicId, option.id);

  bool get isOwned => availability.isOwned;

  bool get isSelected => availability == MechanicOptionAvailability.selected;

  bool get isGranted => availability == MechanicOptionAvailability.granted;

  bool get isInvalid => availability == MechanicOptionAvailability.invalid;

  bool get isBlocked => availability == MechanicOptionAvailability.blocked;

  bool get isAvailable => availability == MechanicOptionAvailability.available;

  /// Se os efeitos desta opção devem ser aplicados na ficha.
  ///
  /// Opção inválida continua listada, mas não vale. Opção que é modo só vale
  /// enquanto estiver ligada — é a tradução direta de "não aplique
  /// permanentemente um bônus pertencente a um modo temporário".
  bool get appliesEffects {
    if (!isSelected && !isGranted) return false;
    if (option.isMode) return isActive;
    return true;
  }

  /// Se o modo pode ser ligado agora.
  bool get canActivate =>
      option.isMode && isOwned && !isInvalid && activationBlocks.isEmpty;

  /// Motivos do bloqueio numa frase, como a ficha mostra.
  String get blockReason => blocks.map((item) => item.message).join(' ');

  /// Motivos que impedem a ativação, numa frase.
  String get activationBlockReason =>
      activationBlocks.map((item) => item.message).join(' ');

  /// Efeitos que o motor transforma em número, só quando a opção está valendo.
  List<FeatureEffect> get calculatedEffects {
    if (!appliesEffects) return const [];
    return option.calculatedEffects;
  }

  /// Histórico de substituição, em texto. Nulo quando não houve troca.
  String? get replacementLabel {
    final previous = replacedOptionId;
    if (previous == null || previous.isEmpty) return null;

    final level = replacedAtLevel;
    return level == null
        ? 'Substituiu $previous.'
        : 'Substituiu $previous no nível $level.';
  }

  ResolvedMechanicOption copyWith({
    MechanicOptionAvailability? availability,
    List<MechanicBlock>? blocks,
    List<MechanicBlock>? activationBlocks,
    bool? isActive,
    FeatureResource? resource,
  }) {
    return ResolvedMechanicOption(
      mechanicId: mechanicId,
      option: option,
      availability: availability ?? this.availability,
      blocks: blocks ?? this.blocks,
      activationBlocks: activationBlocks ?? this.activationBlocks,
      isActive: isActive ?? this.isActive,
      chosenAtLevel: chosenAtLevel,
      replacedOptionId: replacedOptionId,
      replacedAtLevel: replacedAtLevel,
      resource: resource ?? this.resource,
    );
  }
}

/// Uma mecânica de classe, já resolvida contra este personagem: nível
/// alcançado, limite, vagas, opções, modos ativos, recursos e tabela.
class ResolvedClassMechanic {
  const ResolvedClassMechanic({
    required this.entry,
    required this.classId,
    required this.classLevel,
    required this.originLabel,
    required this.options,
    this.blocks = const [],
    this.resource,
    this.rollResultRowId,
    this.note,
  });

  final ClassMechanicEntry entry;

  /// Classe que concedeu. No multiclasse é o que diz qual linha de
  /// `classLevels` pagou por esta mecânica.
  final String classId;

  /// Nível NA CLASSE responsável. Nunca o nível total do personagem.
  final int classLevel;

  /// Nome da fonte, como a ficha mostra: `Mestre de Batalha`, `Guerreiro`.
  final String originLabel;

  final List<ResolvedMechanicOption> options;

  /// Pré-requisitos da mecânica não cumpridos. Vazia quando está liberada.
  final List<MechanicBlock> blocks;

  /// Recurso compartilhado da mecânica, quando ela declara um.
  final FeatureResource? resource;

  /// Id da linha de tabela registrada como resultado atual.
  final String? rollResultRowId;

  /// Anotação livre do jogador sobre esta mecânica.
  final String? note;

  String get id => entry.id;

  String get name => entry.name;

  /// Se a mecânica está liberada para este personagem.
  bool get isUnlocked => blocks.isEmpty;

  /// Origem e nível, como a ficha escreve: `Mestre de Batalha, nível 3`.
  String get sourceLabel => '$originLabel, nível ${entry.level}';

  /// Linha completa: `Manobras — Mestre de Batalha, nível 3`.
  String get headline => '$name — $sourceLabel';

  /// Total de opções permitidas neste nível.
  int get limit => entry.picksAt(classLevel);

  /// Quantas opções NOVAS este nível concede.
  int get newPicksAtLevel => entry.newPicksAt(classLevel);

  /// Observação de progressão que vale neste nível.
  String? get progressionNote => entry.progressionNoteAt(classLevel);

  /// Limite de modos ativos simultâneos neste nível.
  int? get maxActive => entry.maxActiveAt(classLevel);

  List<ResolvedMechanicOption> get owned =>
      options.where((item) => item.isOwned).toList(growable: false);

  /// Escolhidas e válidas. São as únicas que produzem efeito permanente.
  List<ResolvedMechanicOption> get selected =>
      options.where((item) => item.isSelected).toList(growable: false);

  List<ResolvedMechanicOption> get granted =>
      options.where((item) => item.isGranted).toList(growable: false);

  /// Escolhidas que perderam o pré-requisito.
  List<ResolvedMechanicOption> get invalid =>
      options.where((item) => item.isInvalid).toList(growable: false);

  List<ResolvedMechanicOption> get available =>
      options.where((item) => item.isAvailable).toList(growable: false);

  List<ResolvedMechanicOption> get blocked =>
      options.where((item) => item.isBlocked).toList(growable: false);

  List<ResolvedMechanicOption> get active =>
      options.where((item) => item.isActive).toList(growable: false);

  /// Opções que podem ser ligadas e desligadas.
  List<ResolvedMechanicOption> get modes =>
      options.where((item) => item.option.isMode).toList(growable: false);

  /// Quantas vagas de escolha estão ocupadas.
  int get selectedCount =>
      options.where((item) => item.availability.consumesSlot).length;

  /// Vagas ainda não usadas. Nunca negativa.
  int get freeSlots {
    if (!entry.hasPicks) return 0;
    final left = limit - selectedCount;
    return left < 0 ? 0 : left;
  }

  /// Quantas opções estão escolhidas além do limite.
  ///
  /// Acontece quando o jogador perde níveis ao editar a ficha. A ficha avisa
  /// em vez de escolher sozinha qual descartar.
  int get overLimit {
    if (!entry.hasPicks) return 0;
    final over = selectedCount - limit;
    return over < 0 ? 0 : over;
  }

  /// Se a mecânica tem vaga obrigatória em aberto.
  ///
  /// É o que bloqueia concluir a criação ou a evolução: escolha pendente numa
  /// lista de opções conhecidas é decisão que falta, não preferência.
  bool get hasPendingPicks => isUnlocked && entry.hasPicks && freeSlots > 0;

  bool get hasInvalid => invalid.isNotEmpty;

  /// Se a mecânica deve aparecer na ficha.
  ///
  /// Mecânica bloqueada por nível NÃO aparece: ela é de um nível futuro, e
  /// mostrá-la sugeriria que o personagem já a tem.
  bool get isVisible => isUnlocked;

  /// A tabela da mecânica, quando há uma.
  MechanicTable? get table => entry.table;

  /// A linha registrada como resultado atual da tabela.
  MechanicTableRow? get rollResultRow => entry.table?.byId(rollResultRowId);

  /// Como a ficha mostra a contagem: `3 de 3 conhecidas`.
  String? get countLabel {
    if (!entry.hasPicks) return null;
    return '$selectedCount de $limit conhecidas';
  }

  /// Uma linha curta para o cabeçalho fechado:
  /// `3 de 3 conhecidas • 2 usos restantes`.
  String get summaryLabel {
    final parts = <String>[
      if (countLabel case final label?) label,
      if (resource case final value?) '${value.usesLabel} usos',
      if (active.isNotEmpty)
        'ativo: ${active.map((item) => item.name).join(', ')}',
      if (rollResultRow case final row?) 'resultado: ${row.label}',
    ];

    if (parts.isEmpty) return entry.kindsLabel;
    return parts.join(' • ');
  }

  /// Aviso curto para o cabeçalho fechado, quando há algo a corrigir.
  String? get badgeLabel {
    if (hasInvalid) return 'revisar';
    if (overLimit > 0) return 'acima do limite';
    if (hasPendingPicks) {
      return freeSlots == 1
          ? '1 escolha pendente'
          : '$freeSlots escolhas pendentes';
    }
    return null;
  }

  ResolvedMechanicOption? optionById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final item in options) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Efeitos calculados que estão VALENDO agora.
  ///
  /// Só de opção escolhida e válida, e só de modo ligado. É o filtro que
  /// impede um bônus temporário de virar permanente na ficha.
  List<FeatureEffect> get activeCalculatedEffects {
    final result = <FeatureEffect>[
      // Efeitos da mecânica valem desde que ela esteja liberada.
      if (isUnlocked)
        for (final effect in entry.effects)
          if (effect.isCalculated) effect,
      for (final option in options) ...option.calculatedEffects,
    ];

    return result.isEmpty ? const [] : List<FeatureEffect>.unmodifiable(result);
  }
}

/// As mecânicas internas de classe e subclasse do personagem, já resolvidas.
class ResolvedClassMechanics {
  const ResolvedClassMechanics({
    required this.mechanics,
    this.profile = MechanicProfile.empty,
  });

  static const ResolvedClassMechanics empty = ResolvedClassMechanics(
    mechanics: [],
  );

  final List<ResolvedClassMechanic> mechanics;

  /// O perfil usado na validação, para a tela não remontá-lo.
  final MechanicProfile profile;

  bool get isEmpty => mechanics.isEmpty;

  bool get isNotEmpty => mechanics.isNotEmpty;

  /// Mecânicas que a ficha mostra.
  List<ResolvedClassMechanic> get visible =>
      mechanics.where((item) => item.isVisible).toList(growable: false);

  ResolvedClassMechanic? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final item in mechanics) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Mecânicas de uma classe específica, na ordem dos níveis.
  List<ResolvedClassMechanic> forClass(String classId) =>
      visible.where((item) => item.classId == classId).toList(growable: false);

  /// Mecânicas de uma subclasse específica.
  List<ResolvedClassMechanic> forSubclass(String subclassId) => visible
      .where((item) => item.entry.subclassId == subclassId)
      .toList(growable: false);

  /// Mecânicas que pedem para ser mostradas numa área da ficha.
  ///
  /// O filtro é pelo que o DADO declara, não por uma lista de nomes na tela:
  /// é o que permite uma mecânica nova aparecer no lugar certo sem mexer em
  /// widget nenhum.
  List<ResolvedClassMechanic> forDisplay(FeatureDisplaySlot slot) => visible
      .where((item) => item.entry.display == slot)
      .toList(growable: false);

  /// Mecânicas com escolha obrigatória em aberto.
  ///
  /// É o que a tela de criação e a de evolução consultam para decidir se
  /// mostram a etapa de "Escolhas de classe" — e para impedir concluir com
  /// pendência.
  List<ResolvedClassMechanic> get pending =>
      visible.where((item) => item.hasPendingPicks).toList(growable: false);

  /// Mecânicas com escolha que perdeu o pré-requisito.
  List<ResolvedClassMechanic> get needingReview => visible
      .where((item) => item.hasInvalid || item.overLimit > 0)
      .toList(growable: false);

  bool get hasPending => pending.isNotEmpty;

  bool get needsReview => needingReview.isNotEmpty;

  /// Total de escolhas obrigatórias em aberto.
  int get pendingPickCount =>
      pending.fold(0, (total, item) => total + item.freeSlots);

  /// Todos os recursos limitados que as mecânicas e as opções concedem.
  ///
  /// Reaproveita [FeatureResource], o mesmo registro dos recursos de
  /// característica, para o painel de Recursos e descanso e o descanso em si
  /// não precisarem saber que mecânica de subclasse existe.
  List<FeatureResource> get resources {
    final result = <FeatureResource>[];

    for (final mechanic in visible) {
      if (mechanic.resource case final value?) result.add(value);

      for (final option in mechanic.options) {
        // Só opção que o personagem tem: contador de manobra que ele não
        // conhece não é recurso, é ruído.
        if (!option.isOwned) continue;
        if (option.resource case final value?) result.add(value);
      }
    }

    return result.isEmpty
        ? const []
        : List<FeatureResource>.unmodifiable(result);
  }

  /// Modos ligados agora, em todas as mecânicas.
  List<ResolvedMechanicOption> get activeModes {
    final result = <ResolvedMechanicOption>[];
    for (final mechanic in visible) {
      result.addAll(mechanic.active);
    }
    return result.isEmpty
        ? const []
        : List<ResolvedMechanicOption>.unmodifiable(result);
  }

  /// Soma dos bônus de CA que as mecânicas VALENDO declaram.
  ///
  /// Soma porque são bônus independentes, não fórmulas base — igual ao que
  /// `ResolvedFeatures.armorClassBonus` faz para as características. Só entra
  /// modo ligado: um bônus de modo temporário não pode ficar na CA depois de
  /// desligado.
  int armorClassBonus(FeatureFormulaContext context) {
    var total = 0;

    for (final mechanic in visible) {
      for (final effect in mechanic.activeCalculatedEffects) {
        if (effect.path != FeatureEffectPaths.armorClassBonus) continue;
        final value = FeatureFormula.valueOf(effect.formula, context);
        if (value != null) total += value;
      }
    }

    return total;
  }

  /// Ids de recurso que voltam com as recargas informadas.
  ///
  /// Devolve as chaves que `FeatureResources.restoreAll` espera, para o
  /// descanso continuar sem depender do catálogo.
  Set<String> featureIdsRestoredBy(Set<ActionRecharge> recharges) {
    final result = <String>{};

    for (final mechanic in visible) {
      final mechanicRecharge = mechanic.entry.action?.recharge;
      if (mechanicRecharge != null && recharges.contains(mechanicRecharge)) {
        result.add(mechanic.entry.featureIdFor());
      }

      for (final option in mechanic.options) {
        if (!option.isOwned) continue;
        final recharge = option.option.action?.recharge;
        if (recharge == null || !recharges.contains(recharge)) continue;
        result.add(mechanic.entry.featureIdFor(option.id));
      }
    }

    return result;
  }
}

/// Monta as mecânicas internas de classe e subclasse do personagem.
///
/// É o ponto único em que a regra mora. A interface recebe
/// [ResolvedClassMechanics] pronto e não repete nenhuma decisão — nem o corte
/// por nível, nem o limite de escolhas, nem a validação de pré-requisito, nem
/// a diferença entre "ainda não escolheu" e "escolheu e perdeu o
/// pré-requisito".
///
/// Três coisas que o resolvedor faz de propósito:
///
/// - usa o nível NA CLASSE responsável, nunca o total. Um Guerreiro 3 /
///   Bruxo 9 conhece três manobras, não nove;
/// - não apaga seleção inválida. Ela continua na lista, marcada, sem efeito e
///   com o motivo — ver [MechanicOptionAvailability.invalid];
/// - não aplica efeito de modo desligado. Um bônus que pertence a um modo
///   temporário só entra no cálculo enquanto o modo está ligado.
class ClassMechanicResolver {
  const ClassMechanicResolver._();

  static ResolvedClassMechanics resolve({
    required Character character,
    required ClassMechanicCatalog catalog,
    required List<ClassEntry> classes,
    List<SubclassEntry> subclasses = const [],
    List<SpellEntry> spells = const [],
    ResolvedFeatures features = ResolvedFeatures.empty,
  }) {
    if (catalog.isEmpty || character.classLevels.isEmpty) {
      return ResolvedClassMechanics.empty;
    }

    final profile = profileFor(
      character: character,
      classes: classes,
      spells: spells,
      features: features,
    );

    final context = FeatureFormulaContext.fromCharacter(character);
    final resolved = <ResolvedClassMechanic>[];
    final seen = <String>{};

    for (final classLevel in character.classLevels) {
      final classEntry = _classById(classes, classLevel.classId);
      final className = classEntry?.name ?? classLevel.classId;
      final subclass = _subclassFor(subclasses, classLevel);

      final entries = catalog.forClassLine(
        classId: classLevel.classId,
        subclassId: classLevel.subclassId,
        baseClassId: classEntry?.variantOf,
      );

      for (final entry in entries) {
        // Id repetido entre duas linhas de classe (acontece com variante que
        // herda a classe-base) é a MESMA mecânica: resolver duas vezes faria a
        // ficha mostrar dois limites para a mesma lista.
        if (!seen.add(entry.id)) continue;

        resolved.add(
          _resolveOne(
            character: character,
            entry: entry,
            classId: classLevel.classId,
            classLevel: classLevel.level,
            originLabel:
                entry.subclassId == null || entry.subclassId!.isEmpty
                    ? className
                    : subclass?.name ?? entry.subclassId!,
            profile: profile,
            catalog: catalog,
            context: context,
          ),
        );
      }
    }

    resolved.sort((a, b) {
      final byClass = a.classId.compareTo(b.classId);
      if (byClass != 0) return byClass;
      final byLevel = a.entry.level.compareTo(b.entry.level);
      if (byLevel != 0) return byLevel;
      return ClassMechanicEntry.normalizeName(
        a.name,
      ).compareTo(ClassMechanicEntry.normalizeName(b.name));
    });

    return ResolvedClassMechanics(
      mechanics: List<ResolvedClassMechanic>.unmodifiable(resolved),
      profile: profile,
    );
  }

  /// Monta o perfil usado na validação.
  ///
  /// Público porque a tela de gerenciamento, o serviço de seleção e os testes
  /// precisam do MESMO perfil que o resolvedor usou — remontá-lo em outro
  /// lugar seria abrir espaço para duas respostas diferentes à mesma pergunta.
  static MechanicProfile profileFor({
    required Character character,
    required List<ClassEntry> classes,
    List<SpellEntry> spells = const [],
    ResolvedFeatures features = ResolvedFeatures.empty,
  }) {
    final selected = <String>{};
    final active = <String>{};

    for (final record in character.classMechanics) {
      if (!record.countsAsPick) continue;
      selected.add(
        ClassMechanicPrerequisites.optionKey(
          record.mechanicId,
          record.optionId!,
        ),
      );
    }

    // O estado ligado vive em `featureStates`, sob a chave de
    // `ClassMechanicEntry.mechanicFeatureId`. Ler de lá, e não de um segundo
    // campo, é o que mantém uma única fonte para "está ativo".
    for (final state in character.featureStates) {
      if (!state.isActive) continue;
      final key = _optionKeyFromFeatureId(state.featureId);
      if (key != null) active.add(key);
    }

    return MechanicProfile(
      classLevels: {
        for (final item in character.classLevels) item.classId: item.level,
      },
      subclassByClass: {
        for (final item in character.classLevels)
          if (item.subclassId case final id? when id.isNotEmpty)
            item.classId: id,
      },
      abilityScores: character.abilityScores,
      proficiencyBonus: character.proficiencyBonus,
      featureKeys: {
        for (final feature in features.features)
          ClassMechanicEntry.normalizeName(feature.name),
      },
      knownSpellKeys: _knownSpellKeys(character, spells),
      proficiencyKeys: _proficiencyKeys(character),
      equipmentKeys: _equipmentKeys(character),
      selectedOptionKeys: selected,
      activeOptionKeys: active,
    );
  }

  /// Resolve uma mecânica contra o personagem.
  static ResolvedClassMechanic _resolveOne({
    required Character character,
    required ClassMechanicEntry entry,
    required String classId,
    required int classLevel,
    required String originLabel,
    required MechanicProfile profile,
    required ClassMechanicCatalog catalog,
    required FeatureFormulaContext context,
  }) {
    final blocks = ClassMechanicPrerequisites.evaluateMechanic(
      entry: entry,
      profile: profile,
      catalog: catalog,
    );

    final records = <String, CharacterClassMechanic>{};
    String? rollResult;
    String? note;

    for (final record in character.classMechanics) {
      if (record.mechanicId != entry.id) continue;

      if (record.hasRollResult) rollResult = record.rollResult;
      if ((record.note ?? '').isNotEmpty) note = record.note;

      if (!record.countsAsPick) continue;
      // Primeira ocorrência vence: id repetido é dado inconsistente e não pode
      // gastar duas vagas.
      records.putIfAbsent(record.optionId!, () => record);
    }

    final optionUses = entry.optionUsesAt(classLevel);
    final activeCount = _activeCount(character, entry);

    final options = <ResolvedMechanicOption>[];

    for (final option in entry.options) {
      final record = records.remove(option.id);

      final optionBlocks = ClassMechanicPrerequisites.evaluateOption(
        entry: entry,
        option: option,
        // A validação de uma opção JÁ ESCOLHIDA não conta ela mesma como
        // incompatibilidade: senão uma opção que lista as irmãs se bloquearia
        // sozinha depois de escolhida.
        profile:
            record == null
                ? profile
                : profile.copyWith(
                  selectedOptionKeys:
                      profile.selectedOptionKeys
                          .where(
                            (key) =>
                                key !=
                                ClassMechanicPrerequisites.optionKey(
                                  entry.id,
                                  option.id,
                                ),
                          )
                          .toSet(),
                ),
        catalog: catalog,
      );

      // Mecânica que não cobra vaga concede TODAS as opções desbloqueadas.
      //
      // É o caso do modo ativável e da escolha por uso: as três constelações
      // da Forma Estelar não são aprendidas, e os cinco tipos de dano do
      // Cutelo Elemental não gastam escolha — o personagem tem acesso a
      // todos e decide no momento do uso. Tratá-las como "disponível para
      // escolher" faria a ficha pedir uma decisão permanente que a regra não
      // pede, e impediria ligar o modo.
      final isAccessible = option.isGranted || !entry.hasPicks;

      final availability = switch ((
        isAccessible,
        record != null,
        optionBlocks.isEmpty,
      )) {
        (true, _, true) => MechanicOptionAvailability.granted,
        (true, _, false) => MechanicOptionAvailability.blocked,
        (false, true, true) => MechanicOptionAvailability.selected,
        (false, true, false) => MechanicOptionAvailability.invalid,
        (false, false, true) => MechanicOptionAvailability.available,
        (false, false, false) => MechanicOptionAvailability.blocked,
      };

      final isActive =
          character.featureStateFor(entry.featureIdFor(option.id))?.isActive ??
          false;

      final activationBlocks =
          option.isMode
              ? ClassMechanicPrerequisites.evaluateActivation(
                entry: entry,
                option: option,
                profile: profile,
                // Quando o próprio modo já está ligado, ele não conta contra o
                // limite: senão desligar ficaria impossível de explicar.
                activeCount: isActive ? activeCount - 1 : activeCount,
                catalog: catalog,
              )
              : const <MechanicBlock>[];

      options.add(
        ResolvedMechanicOption(
          mechanicId: entry.id,
          option: option,
          availability: availability,
          blocks: optionBlocks,
          activationBlocks: activationBlocks,
          isActive: isActive,
          chosenAtLevel: record?.chosenAtLevel ?? 0,
          replacedOptionId: record?.replacedOptionId,
          replacedAtLevel: record?.replacedAtLevel,
          resource:
              availability.isOwned
                  ? _optionResource(
                    character: character,
                    entry: entry,
                    option: option,
                    originLabel: originLabel,
                    overrideUses: optionUses,
                    context: context,
                  )
                  : null,
        ),
      );
    }

    // O que sobrou em `records` é id que não existe mais no catálogo. Também
    // não é apagado: entra como inválido, com o motivo, para o jogador saber
    // que precisa substituir.
    for (final orphan in records.values) {
      final id = orphan.optionId!;
      options.add(
        ResolvedMechanicOption(
          mechanicId: entry.id,
          option: MechanicOption(
            id: id,
            name: id,
            description:
                'Esta opção não existe mais no catálogo desta característica.',
          ),
          availability: MechanicOptionAvailability.invalid,
          blocks: const [
            MechanicBlock(
              kind: MechanicBlockKind.unknownOption,
              message:
                  'Esta opção não existe mais no catálogo. Escolha outra '
                  'no lugar dela.',
            ),
          ],
          chosenAtLevel: orphan.chosenAtLevel,
          replacedOptionId: orphan.replacedOptionId,
          replacedAtLevel: orphan.replacedAtLevel,
        ),
      );
    }

    return ResolvedClassMechanic(
      entry: entry,
      classId: classId,
      classLevel: classLevel,
      originLabel: originLabel,
      options: List<ResolvedMechanicOption>.unmodifiable(options),
      blocks: blocks,
      resource:
          blocks.isEmpty
              ? _mechanicResource(
                character: character,
                entry: entry,
                classLevel: classLevel,
                originLabel: originLabel,
                context: context,
              )
              : null,
      rollResultRowId: rollResult,
      note: note,
    );
  }

  /// Quantos modos desta mecânica estão ligados.
  static int _activeCount(Character character, ClassMechanicEntry entry) {
    var total = 0;
    for (final option in entry.options) {
      if (!option.isMode) continue;
      final state = character.featureStateFor(entry.featureIdFor(option.id));
      if (state?.isActive ?? false) total++;
    }
    return total;
  }

  /// O recurso compartilhado da mecânica, quando ela declara um.
  static FeatureResource? _mechanicResource({
    required Character character,
    required ClassMechanicEntry entry,
    required int classLevel,
    required String originLabel,
    required FeatureFormulaContext context,
  }) {
    final action = entry.action;
    if (action == null) return null;

    // A progressão tem prioridade sobre o número fixo: os Dados de
    // Superioridade são 4 no 3º nível e 6 no 15º, e um valor fixo erraria em
    // metade dos níveis.
    final fromProgression = entry.usesAt(classLevel);
    final maximum =
        fromProgression ?? FeatureResources.maximumFor(action, context);

    if (maximum == null) return null;

    final floor = entry.usesMinimum;
    final effective = floor != null && maximum < floor ? floor : maximum;
    if (effective <= 0) return null;

    final featureId = entry.featureIdFor();
    final stored = character.featureStateFor(featureId)?.usesSpent ?? 0;

    return FeatureResource(
      featureId: featureId,
      label: action.label ?? entry.name,
      sourceLabel: '$originLabel, nível ${entry.level}',
      maximum: effective,
      spent: stored > effective ? effective : stored,
      recharge: action.recharge,
      cost: action.cost,
    );
  }

  /// Os usos próprios de uma opção, quando ela declara algum.
  static FeatureResource? _optionResource({
    required Character character,
    required ClassMechanicEntry entry,
    required MechanicOption option,
    required String originLabel,
    required int? overrideUses,
    required FeatureFormulaContext context,
  }) {
    final action = option.action;
    if (action == null || !action.hasLimitedUses) return null;

    // A progressão da mecânica manda nos usos de cada opção quando declara:
    // é o que faz a runa valer uma invocação até o 14º nível e duas a partir
    // do 15º sem repetir o número em cada runa.
    final maximum =
        overrideUses ?? FeatureResources.maximumFor(action, context);
    if (maximum == null || maximum <= 0) return null;

    final featureId = entry.featureIdFor(option.id);
    final stored = character.featureStateFor(featureId)?.usesSpent ?? 0;

    return FeatureResource(
      featureId: featureId,
      label: '${entry.name}: ${option.name}',
      sourceLabel: '$originLabel, nível ${entry.level}',
      maximum: maximum,
      spent: stored > maximum ? maximum : stored,
      recharge: action.recharge,
      cost: action.cost,
    );
  }

  /// Volta de uma chave de `featureStates` para a chave de opção.
  ///
  /// `mechanic.<mecanica>.<opcao>` vira `<mecanica>:<opcao>`. Nulo quando a
  /// chave não é de mecânica ou não aponta para uma opção.
  static String? _optionKeyFromFeatureId(String featureId) {
    const prefix = 'mechanic.';
    if (!featureId.startsWith(prefix)) return null;

    final rest = featureId.substring(prefix.length);
    final separator = rest.lastIndexOf('.');
    if (separator <= 0 || separator == rest.length - 1) return null;

    return ClassMechanicPrerequisites.optionKey(
      rest.substring(0, separator),
      rest.substring(separator + 1),
    );
  }

  /// Nomes normalizados de tudo o que o personagem conhece de magia.
  ///
  /// Entra pelos dois nomes de cada magia, o original e o traduzido, porque o
  /// pré-requisito do livro é escrito em inglês e a ficha está em português.
  static Set<String> _knownSpellKeys(
    Character character,
    List<SpellEntry> spells,
  ) {
    if (character.spells.isEmpty || spells.isEmpty) return const {};

    final wanted = <int>{
      for (final spell in character.spells)
        if (spell.isKnown || spell.isAlwaysAvailable || spell.isPrepared)
          spell.spellId,
    };

    if (wanted.isEmpty) return const {};

    final keys = <String>{};
    for (final spell in spells) {
      if (!wanted.contains(spell.id)) continue;

      for (final name in [spell.nameOriginal, spell.namePt]) {
        final key = ClassMechanicEntry.normalizeName(name);
        if (key.isNotEmpty) keys.add(key);
      }
    }

    return keys;
  }

  /// Chaves normalizadas das perícias em que o personagem é proficiente.
  static Set<String> _proficiencyKeys(Character character) {
    final keys = <String>{};

    // `activeLevels` já exclui `ProficiencyLevel.none`. Cada perícia entra
    // pelos dois nomes, o traduzido e o do enum, para o pré-requisito casar
    // tanto com `Furtividade` quanto com `stealth`.
    for (final skill in character.skillProficiencies.activeLevels.keys) {
      keys.add(ClassMechanicEntry.normalizeName(skill.label));
      keys.add(ClassMechanicEntry.normalizeName(skill.name));
    }

    return keys;
  }

  /// Chaves normalizadas do que o personagem carrega.
  ///
  /// Inclui inventário, armas e itens mágicos: o pré-requisito de equipamento
  /// do levantamento cita arma e foco, e os três estão em listas diferentes.
  static Set<String> _equipmentKeys(Character character) {
    final keys = <String>{};

    void add(String? value) {
      if (value == null || value.isEmpty) return;
      keys.add(ClassMechanicEntry.normalizeName(value));
    }

    for (final item in character.inventory) {
      add(item.itemId);
      add(item.name);
    }
    for (final weapon in character.weapons) {
      add(weapon.name);
    }
    for (final item in character.magicItems) {
      add(item.name);
    }

    return keys;
  }

  /// A subclasse desta linha de classe, quando há uma escolhida.
  ///
  /// Casa por id E classe primeiro: com variantes de classe o mesmo id de
  /// subclasse aparece para mais de uma classe, e pegar a primeira daria a
  /// característica do nível errado. É a mesma precaução do
  /// `SpecialFeatureResolver`.
  static SubclassEntry? _subclassFor(
    List<SubclassEntry> subclasses,
    ClassLevel classLevel,
  ) {
    final subclassId = classLevel.subclassId;
    if (subclassId == null || subclassId.isEmpty) return null;

    for (final item in subclasses) {
      if (item.id == subclassId && item.classId == classLevel.classId) {
        return item;
      }
    }
    for (final item in subclasses) {
      if (item.id == subclassId) return item;
    }

    return null;
  }

  static ClassEntry? _classById(List<ClassEntry> classes, String id) {
    for (final item in classes) {
      if (item.id == id) return item;
    }
    return null;
  }
}
