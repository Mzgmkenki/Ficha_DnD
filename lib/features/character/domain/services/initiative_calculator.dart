import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/initiative_rule.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';

/// De onde vem uma parcela da iniciativa.
enum InitiativeSource {
  /// O modificador de Destreza, que todo personagem soma.
  dexterity,

  /// Modificador de outro atributo, concedido por característica.
  otherAbility,

  /// Bônus de proficiência, inteiro ou pela metade.
  proficiency,

  classFeature,
  subclassFeature,
  feat,
  raceTrait,

  /// O campo "outros" da ficha, preenchido à mão pelo jogador.
  manual,
}

/// Uma parcela da iniciativa, com o valor e de onde saiu.
class InitiativeModifier {
  const InitiativeModifier({
    required this.label,
    required this.value,
    required this.source,
    this.origin,
  });

  /// Como a parcela aparece na composição. Ex.: `Destreza`, `Sabedoria`.
  final String label;

  final int value;
  final InitiativeSource source;

  /// Quem concedeu, quando não é o próprio atributo. Ex.: `Emboscador
  /// Terrível`.
  final String? origin;

  /// `+3 de Destreza` ou `+2 de Sabedoria (Emboscador Terrível)`.
  String get description {
    final signed = value >= 0 ? '+$value' : '$value';
    final source = origin == null ? label : '$label ($origin)';

    return '$signed de $source';
  }
}

/// A iniciativa somada, com a composição e as fontes de vantagem.
class InitiativeResult {
  const InitiativeResult({
    required this.total,
    required this.modifiers,
    this.advantageSources = const [],
  });

  final int total;

  /// As parcelas na ordem de exibição, começando pela Destreza.
  final List<InitiativeModifier> modifiers;

  /// Características que dão vantagem na jogada. Não entram na soma porque
  /// vantagem é rolar dois dados, não somar um número.
  final List<String> advantageSources;

  bool get hasAdvantage => advantageSources.isNotEmpty;

  String get formattedTotal => total >= 0 ? '+$total' : '$total';

  /// `+7 = +3 de Destreza +2 de Sabedoria (Emboscador Terrível) +2 de outros`.
  ///
  /// Serve para a ficha explicar o número em vez de só mostrá-lo.
  String get explanation {
    if (modifiers.isEmpty) return formattedTotal;

    final parts = modifiers.map((item) => item.description).join(' ');

    return '$formattedTotal = $parts';
  }
}

/// Calcula a iniciativa e explica de onde cada parcela veio.
///
/// A regra base é a mesma para todo personagem: soma o modificador de Destreza,
/// porque a iniciativa é um teste de Destreza (PHB, capítulo 9). Não depende de
/// proficiência em salvaguarda de Destreza, e nada aqui olha para isso.
///
/// O que vai além da Destreza vem declarado no asset, em bloco `initiative`
/// ([InitiativeRule]), e não de condicional por id de subclasse na interface. É
/// isso que permite Emboscador Terrível somar Sabedoria sem que nenhum widget
/// saiba que Perseguidor Sombrio existe — e garante que a soma só aconteça
/// quando a subclasse certa, a característica certa e o nível certo estão
/// presentes.
class InitiativeCalculator {
  const InitiativeCalculator._();

  static InitiativeResult calculate({
    required Character character,
    List<ClassFeatureEntry> classFeatures = const [],
    List<SubclassEntry> subclasses = const [],
    List<FeatEntry> feats = const [],
    List<RaceEntry> races = const [],
  }) {
    final modifiers = <InitiativeModifier>[];
    final advantage = <String>[];

    // A Destreza entra sempre e primeiro.
    final dexterity = character.abilityScores.dexterity.abilityModifier;
    modifiers.add(
      InitiativeModifier(
        label: Ability.dexterity.label,
        value: dexterity,
        source: InitiativeSource.dexterity,
      ),
    );

    for (final granted in _rules(
      character: character,
      classFeatures: classFeatures,
      subclasses: subclasses,
      feats: feats,
      races: races,
    )) {
      _apply(
        granted: granted,
        character: character,
        modifiers: modifiers,
        advantage: advantage,
      );
    }

    // O campo "outros" da ficha fecha a lista: é ajuste manual do jogador e
    // fica depois do que as regras concedem.
    final manual = character.combatStats.initiativeBonus;
    if (manual != 0) {
      modifiers.add(
        InitiativeModifier(
          label: 'outros',
          value: manual,
          source: InitiativeSource.manual,
        ),
      );
    }

    final total = modifiers.fold(0, (sum, item) => sum + item.value);

    return InitiativeResult(
      total: total,
      modifiers: List.unmodifiable(modifiers),
      advantageSources: List.unmodifiable(advantage),
    );
  }

  /// Transforma uma regra do asset nas parcelas que ela gera.
  static void _apply({
    required _GrantedRule granted,
    required Character character,
    required List<InitiativeModifier> modifiers,
    required List<String> advantage,
  }) {
    final rule = granted.rule;
    final origin = rule.note ?? granted.name;

    final ability = rule.ability;
    if (ability != null) {
      modifiers.add(
        InitiativeModifier(
          label: ability.label,
          value: character.abilityScores.valueFor(ability).abilityModifier,
          source: InitiativeSource.otherAbility,
          origin: origin,
        ),
      );
    }

    switch (rule.proficiency) {
      case InitiativeProficiencyUse.full:
        modifiers.add(
          InitiativeModifier(
            label: 'proficiência',
            value: character.proficiencyBonus,
            source: InitiativeSource.proficiency,
            origin: origin,
          ),
        );
      case InitiativeProficiencyUse.half:
        // Metade arredondada para baixo, como manda o texto de Pau para Toda
        // Obra. Com bônus 2 dá +1; com 3, também +1.
        modifiers.add(
          InitiativeModifier(
            label: 'meia proficiência',
            value: character.proficiencyBonus ~/ 2,
            source: InitiativeSource.proficiency,
            origin: origin,
          ),
        );
      case null:
        break;
    }

    final bonus = rule.bonus;
    if (bonus != null && bonus != 0) {
      modifiers.add(
        InitiativeModifier(
          label: origin,
          value: bonus,
          source: granted.source,
        ),
      );
    }

    if (rule.advantage) advantage.add(origin);
  }

  // -------------------------------------------------- coleta das regras

  /// Todas as regras de iniciativa que a build do personagem concede.
  static List<_GrantedRule> _rules({
    required Character character,
    required List<ClassFeatureEntry> classFeatures,
    required List<SubclassEntry> subclasses,
    required List<FeatEntry> feats,
    required List<RaceEntry> races,
  }) {
    return [
      ..._fromClassFeatures(character, classFeatures),
      ..._fromSubclasses(character, subclasses),
      ..._fromFeats(character, feats),
      ..._fromRace(character, races),
    ];
  }

  static Iterable<_GrantedRule> _fromClassFeatures(
    Character character,
    List<ClassFeatureEntry> classFeatures,
  ) {
    final result = <_GrantedRule>[];

    for (final classLevel in character.classLevels) {
      // Só o que o personagem já alcançou nesta classe: `classFeatures` traz o
      // compêndio inteiro, então o corte por nível é aqui.
      final reached = classFeatures.where(
        (item) =>
            item.classId == classLevel.classId &&
            item.level <= classLevel.level,
      );

      for (final entry in reached) {
        for (final feature in entry.features) {
          final rule = feature.initiative;
          if (rule == null) continue;

          result.add(
            _GrantedRule(
              name: feature.name,
              rule: rule,
              source: InitiativeSource.classFeature,
            ),
          );
        }
      }
    }

    return result;
  }

  static Iterable<_GrantedRule> _fromSubclasses(
    Character character,
    List<SubclassEntry> subclasses,
  ) {
    final result = <_GrantedRule>[];

    for (final classLevel in character.classLevels) {
      final subclassId = classLevel.subclassId;
      if (subclassId == null || subclassId.isEmpty) continue;

      // A subclasse tem que ser a desta linha de classe. Com variante de
      // classe o mesmo id aparece para mais de uma, e pegar a primeira daria a
      // característica do nível errado quando os níveis diferem.
      final subclass = _subclassFor(subclasses, subclassId, classLevel.classId);
      if (subclass == null) continue;

      for (final feature in subclass.featuresUpTo(classLevel.level)) {
        final rule = feature.initiative;
        if (rule == null) continue;

        result.add(
          _GrantedRule(
            name: feature.name,
            rule: rule,
            source: InitiativeSource.subclassFeature,
          ),
        );
      }
    }

    return result;
  }

  static SubclassEntry? _subclassFor(
    List<SubclassEntry> subclasses,
    String subclassId,
    String classId,
  ) {
    SubclassEntry? fallback;

    for (final item in subclasses) {
      if (item.id != subclassId) continue;
      if (item.classId == classId) return item;
      fallback ??= item;
    }

    return fallback;
  }

  static Iterable<_GrantedRule> _fromFeats(
    Character character,
    List<FeatEntry> feats,
  ) {
    if (character.feats.isEmpty) return const [];

    final byId = {for (final feat in feats) feat.id: feat};
    final result = <_GrantedRule>[];

    for (final taken in character.feats) {
      final entry = byId[taken.featId];
      final rule = entry?.initiative;
      if (entry == null || rule == null) continue;

      result.add(
        _GrantedRule(
          name: entry.name,
          rule: rule,
          source: InitiativeSource.feat,
        ),
      );
    }

    return result;
  }

  static Iterable<_GrantedRule> _fromRace(
    Character character,
    List<RaceEntry> races,
  ) {
    final speciesId = character.speciesId;
    if (speciesId == null || speciesId.isEmpty) return const [];

    RaceEntry? byId(String id) {
      for (final race in races) {
        if (race.id == id) return race;
      }
      return null;
    }

    final species = byId(speciesId);
    if (species == null) return const [];

    // Sub-raça herda os traços da raça base, então as duas contam. As duas
    // podem declarar regra própria sem uma anular a outra.
    final parentId = species.parentRaceId;
    final parent = parentId == null || parentId.trim().isEmpty
        ? null
        : byId(parentId);

    return [
      for (final race in [parent, species])
        if (race?.initiative case final rule?)
          _GrantedRule(
            name: race!.name,
            rule: rule,
            source: InitiativeSource.raceTrait,
          ),
    ];
  }
}

/// Uma regra do asset junto com quem a concedeu.
class _GrantedRule {
  const _GrantedRule({
    required this.name,
    required this.rule,
    required this.source,
  });

  final String name;
  final InitiativeRule rule;
  final InitiativeSource source;
}
