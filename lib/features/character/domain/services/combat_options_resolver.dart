import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_option.dart';
import 'package:dnd_ficha_app/features/character/domain/services/casting_time_parser.dart';
import 'package:dnd_ficha_app/features/character/domain/services/universal_combat_actions.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';

/// A lista de opções de combate já resolvida, agrupada por tipo de ação.
class CombatOptions {
  const CombatOptions({required this.byType, required this.attacksPerAction});

  /// Opções por tipo, na ordem de exibição do enum.
  final Map<CombatActionType, List<CombatOption>> byType;

  /// Quantos ataques a ação de Atacar rende com a build atual.
  final int attacksPerAction;

  List<CombatOption> operator [](CombatActionType type) =>
      byType[type] ?? const [];

  bool get isEmpty => byType.values.every((list) => list.isEmpty);
}

/// Monta a seção "Ações em combate" a partir da build do personagem.
///
/// É aqui que as regras moram. A tela recebe [CombatOption] pronto, com
/// disponibilidade e motivo já decididos, e não reimplementa nenhuma regra —
/// era o requisito de não ter condicional de regra espalhada na interface.
///
/// O que entra na lista:
///
/// - as ações universais do PHB, que todo personagem tem;
/// - características de classe e de subclasse que declarem bloco `action`;
/// - magias conhecidas ou preparadas, com o tipo vindo do tempo de conjuração;
/// - itens mágicos com cargas.
///
/// O que fica de fora, e por quê: característica sem bloco `action` no asset é
/// tratada como passiva. Isso é decisão de dado, não de código — a maioria das
/// características realmente é passiva, e adivinhar pelo texto da descrição
/// produziria linha errada na ficha de alguém.
class CombatOptionsResolver {
  const CombatOptionsResolver._();

  static CombatOptions resolve({
    required Character character,
    required List<ClassEntry> classes,
    required List<ClassFeatureEntry> classFeatures,
    List<SubclassEntry> subclasses = const [],
    List<SpellEntry> spells = const [],
  }) {
    final options = <CombatOption>[
      ...UniversalCombatActions.all,
      ..._fromClassFeatures(
        character: character,
        classes: classes,
        classFeatures: classFeatures,
      ),
      ..._fromSubclassFeatures(
        character: character,
        subclasses: subclasses,
      ),
      ..._fromSpells(character: character, spells: spells),
      ..._fromMagicItems(character),
    ];

    final attacks = _attacksPerAction(
      character: character,
      classFeatures: classFeatures,
    );

    final consolidated = _consolidate(options);
    final withAttacks = _describeAttackAction(consolidated, attacks);
    final blocked = _applyConditions(withAttacks, character);

    return CombatOptions(
      byType: _group(blocked),
      attacksPerAction: attacks,
    );
  }

  // ------------------------------------------------------ características

  static Iterable<CombatOption> _fromClassFeatures({
    required Character character,
    required List<ClassEntry> classes,
    required List<ClassFeatureEntry> classFeatures,
  }) {
    final result = <CombatOption>[];

    for (final classLevel in character.classLevels) {
      final entry = _classById(classes, classLevel.classId);
      final className = entry?.name ?? classLevel.classId;

      // Só o que o personagem já alcançou nesta classe. `classFeatures` vem
      // com o compêndio inteiro, então o corte por nível é aqui.
      final reached = classFeatures.where(
        (item) =>
            item.classId == classLevel.classId &&
            item.level <= classLevel.level,
      );

      for (final featureEntry in reached) {
        for (final feature in featureEntry.features) {
          final action = feature.action;
          if (action == null) continue;

          result.add(
            _optionFrom(
              feature: feature,
              action: action,
              character: character,
              source: CombatOptionSource.classFeature,
              sourceLabel: '$className ${featureEntry.level}º',
              idPrefix: 'class.${classLevel.classId}',
              level: featureEntry.level,
            ),
          );
        }
      }
    }

    return result;
  }

  static CombatOption _optionFrom({
    required ClassFeature feature,
    required FeatureAction action,
    required Character character,
    required CombatOptionSource source,
    required String sourceLabel,
    required String idPrefix,
    required int level,
  }) {
    final name = action.label ?? feature.name;
    final group = action.group;

    return CombatOption(
      // O grupo é identidade global, e por isso NÃO leva o prefixo da classe:
      // é o que faz o Ataque Extra do guerreiro e o do patrulheiro virarem uma
      // linha só no multiclasse. Grupo específico de uma classe já se resolve
      // no próprio nome, como `fighter.action_surge`.
      //
      // Sem grupo, o prefixo fica: duas classes podem ter características de
      // nome igual e efeito diferente, e juntá-las seria pior que repetir.
      id: group ?? '$idPrefix.${_slug(name)}',
      name: name,
      summary: feature.description,
      actionType: action.type,
      source: source,
      sourceLabel: sourceLabel,
      requirement: action.requires,
      cost: action.cost,
      trigger: action.trigger,
      maxUses: _resolveUses(action, character),
      recharge: action.recharge,
      priority: 40 + level,
      ruleReference: sourceLabel,
      origins: [sourceLabel],
    );
  }

  /// Usos fixos, ou derivados quando o asset declara uma fórmula.
  static int? _resolveUses(FeatureAction action, Character character) {
    final fixed = action.uses;
    if (fixed != null) return fixed;

    switch (action.usesFormula?.trim().toLowerCase()) {
      case 'proficiency':
        return character.proficiencyBonus;
      case null:
        return null;
      default:
        // Fórmula que o código ainda não conhece: melhor não mostrar número
        // nenhum que mostrar um errado. A descrição da característica continua
        // dizendo a conta.
        return null;
    }
  }

  static Iterable<CombatOption> _fromSubclassFeatures({
    required Character character,
    required List<SubclassEntry> subclasses,
  }) {
    final result = <CombatOption>[];

    for (final classLevel in character.classLevels) {
      final subclassId = classLevel.subclassId;
      if (subclassId == null || subclassId.isEmpty) continue;

      // A subclasse tem que ser da classe desta linha: com variantes de classe
      // o mesmo id aparece para mais de uma classe, e pegar a primeira daria a
      // característica do nível errado se os níveis diferissem.
      final subclass = subclasses
          .where(
            (item) =>
                item.id == subclassId && item.classId == classLevel.classId,
          )
          .followedBy(subclasses.where((item) => item.id == subclassId))
          .cast<SubclassEntry?>()
          .firstWhere((item) => item != null, orElse: () => null);

      if (subclass == null) continue;

      for (final feature in subclass.featuresUpTo(classLevel.level)) {
        final action = feature.action;
        if (action == null) continue;

        final name = action.label ?? feature.name;
        final group = action.group;

        result.add(
          CombatOption(
            id: group ?? 'subclass.$subclassId.${_slug(name)}',
            name: name,
            summary: feature.description,
            actionType: action.type,
            source: CombatOptionSource.subclassFeature,
            sourceLabel: '${subclass.name} ${feature.level}º',
            requirement: action.requires,
            cost: action.cost,
            trigger: action.trigger,
            maxUses: _resolveUses(action, character),
            recharge: action.recharge,
            priority: 50 + feature.level,
            ruleReference: subclass.name,
            origins: [subclass.name],
          ),
        );
      }
    }

    return result;
  }

  // -------------------------------------------------------------- magias

  static Iterable<CombatOption> _fromSpells({
    required Character character,
    required List<SpellEntry> spells,
  }) {
    final result = <CombatOption>[];
    final byId = {for (final spell in spells) spell.id: spell};

    for (final known in character.spells) {
      // Truque e magia sempre disponível entram; magia conhecida mas não
      // preparada fica fora, porque não pode ser conjurada agora.
      final spell = byId[known.spellId];
      if (spell == null) continue;

      final usable =
          known.isPrepared || known.isAlwaysAvailable || spell.level == 0;
      if (!usable) continue;

      final timing = CastingTimeParser.parse(spell.castingTime);
      if (!timing.fitsInATurn) continue;

      result.add(
        CombatOption(
          id: 'spell.${spell.id}',
          name: spell.namePt.isEmpty ? spell.nameOriginal : spell.namePt,
          summary: _spellSummary(spell),
          actionType: timing.actionType!,
          source: CombatOptionSource.spell,
          sourceLabel: known.sourceName,
          cost: spell.level == 0
              ? 'Truque, não gasta espaço'
              : 'Espaço de ${spell.level}º círculo',
          trigger: timing.trigger,
          requirement: spell.concentration ? 'Exige Concentração.' : null,
          priority: 60 + spell.level,
          ruleReference: spell.source,
          origins: [known.sourceName],
        ),
      );
    }

    return result;
  }

  static String _spellSummary(SpellEntry spell) {
    final parts = <String>[
      spell.level == 0 ? 'Truque' : '${spell.level}º círculo',
      spell.school,
      if (spell.range.isNotEmpty) spell.range,
      if (spell.concentration) 'Concentração',
      if (spell.ritual) 'Ritual',
    ];

    return parts.where((item) => item.trim().isNotEmpty).join(' • ');
  }

  // --------------------------------------------------------- itens mágicos

  static Iterable<CombatOption> _fromMagicItems(Character character) {
    final result = <CombatOption>[];

    for (final item in character.magicItems) {
      // Só itens com carga entram: sem cargas não há como saber se o item faz
      // algo que custe ação, e listar tudo encheria a seção de item passivo.
      final max = item.maxCharges;
      if (max == null || max <= 0) continue;

      final left = item.charges;

      result.add(
        CombatOption(
          id: 'item.${item.localId}',
          name: item.name,
          summary: item.description.trim().isEmpty ? null : item.description,
          actionType: CombatActionType.action,
          source: CombatOptionSource.magicItem,
          sourceLabel: 'Item mágico',
          maxUses: max,
          remainingUses: left,
          recharge: ActionRecharge.fromId(item.rechargeRule) ??
              ActionRecharge.longRest,
          isAvailable: left == null || left > 0,
          unavailableReason:
              left != null && left <= 0 ? 'Sem cargas restantes.' : null,
          priority: 80,
          origins: const ['Item mágico'],
        ),
      );
    }

    return result;
  }

  // ------------------------------------------------------- consolidação

  /// Junta opções que representam a mesma coisa, preservando as origens.
  ///
  /// Dois casos reais: a progressão dentro de uma classe (Canalizar Divindade
  /// 1/2/3 usos, que compartilham `group`) e o multiclasse concedendo a mesma
  /// característica por duas classes. Em ambos vence a de maior [maxUses], que
  /// é sempre a do nível mais alto.
  static List<CombatOption> _consolidate(List<CombatOption> options) {
    final byId = <String, CombatOption>{};

    for (final option in options) {
      final current = byId[option.id];

      if (current == null) {
        byId[option.id] = option;
        continue;
      }

      final keepNew = (option.maxUses ?? 0) > (current.maxUses ?? 0);
      final winner = keepNew ? option : current;

      byId[option.id] = winner.copyWith(
        origins: {...current.origins, ...option.origins}.toList(),
      );
    }

    return byId.values.toList(growable: false);
  }

  // ----------------------------------------------------------- ataques

  /// Quantos ataques a ação de Atacar rende.
  ///
  /// Em multiclasse o Ataque Extra NÃO acumula: um Guerreiro 5 / Patrulheiro 5
  /// faz dois ataques, não três. Por isso é o maior valor declarado, e não a
  /// soma.
  static int _attacksPerAction({
    required Character character,
    required List<ClassFeatureEntry> classFeatures,
  }) {
    var attacks = 1;

    for (final classLevel in character.classLevels) {
      final reached = classFeatures.where(
        (item) =>
            item.classId == classLevel.classId &&
            item.level <= classLevel.level,
      );

      for (final entry in reached) {
        for (final feature in entry.features) {
          final declared = feature.action?.attacks;
          if (declared != null && declared > attacks) attacks = declared;
        }
      }
    }

    return attacks;
  }

  /// Escreve a contagem de ataques na descrição da ação de Atacar.
  static List<CombatOption> _describeAttackAction(
    List<CombatOption> options,
    int attacks,
  ) {
    if (attacks <= 1) return options;

    return options.map((option) {
      if (option.id != UniversalCombatActions.attackId) return option;

      return option.copyWith(
        summary: '$attacks ataques, corpo a corpo ou à distância.',
      );
    }).toList(growable: false);
  }

  // --------------------------------------------------------- condições

  /// Aplica o que as condições ativas impedem (PHB, Apêndice A).
  ///
  /// Só as regras que o Apêndice A afirma, sem extrapolar: Incapacitado tira
  /// ação e reação, e deslocamento zero tira movimento. Condição que só dá
  /// desvantagem não bloqueia nada e continua disponível — quem decide se vale
  /// a pena atacar com desvantagem é o jogador.
  static List<CombatOption> _applyConditions(
    List<CombatOption> options,
    Character character,
  ) {
    final active = Condition.expand(character.conditions);
    if (active.isEmpty) return options;

    final incapacitated = active.contains(Condition.incapacitated);
    final speedZero = active.contains(Condition.grappled) ||
        active.contains(Condition.restrained) ||
        active.contains(Condition.paralyzed) ||
        active.contains(Condition.stunned) ||
        active.contains(Condition.unconscious) ||
        active.contains(Condition.petrified);

    // O nome da condição que causou o bloqueio, para o motivo ser específico.
    final blocker = active.contains(Condition.unconscious)
        ? Condition.unconscious
        : active.contains(Condition.paralyzed)
            ? Condition.paralyzed
            : active.contains(Condition.petrified)
                ? Condition.petrified
                : active.contains(Condition.stunned)
                    ? Condition.stunned
                    : Condition.incapacitated;

    return options.map((option) {
      if (incapacitated &&
          (option.actionType == CombatActionType.action ||
              option.actionType == CombatActionType.bonusAction ||
              option.actionType == CombatActionType.reaction)) {
        return option.blocked(
          '${blocker.label}: não pode realizar ações nem reações.',
        );
      }

      if (speedZero && option.actionType == CombatActionType.movement) {
        final cause = active.contains(Condition.grappled)
            ? Condition.grappled
            : active.contains(Condition.restrained)
                ? Condition.restrained
                : blocker;

        return option.blocked('${cause.label}: deslocamento zero.');
      }

      return option;
    }).toList(growable: false);
  }

  // ------------------------------------------------------------ helpers

  static Map<CombatActionType, List<CombatOption>> _group(
    List<CombatOption> options,
  ) {
    final grouped = <CombatActionType, List<CombatOption>>{};

    for (final type in CombatActionType.values) {
      final list = options.where((item) => item.actionType == type).toList()
        ..sort((a, b) {
          final byPriority = a.priority.compareTo(b.priority);
          if (byPriority != 0) return byPriority;
          return a.name.compareTo(b.name);
        });

      grouped[type] = list;
    }

    return grouped;
  }

  static ClassEntry? _classById(List<ClassEntry> classes, String id) {
    for (final entry in classes) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  static String _slug(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
