import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/granted_ability_increases.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';

/// De onde a característica veio.
enum FeatureOrigin {
  classFeature('class', 'Classe'),
  subclassFeature('subclass', 'Subclasse'),

  /// Invocação Mística do Bruxo.
  ///
  /// Entra no enum para as invocações com usos limitados poderem ser
  /// apresentadas pelo mesmo `FeatureResources` das características de classe,
  /// em vez de um segundo contador paralelo. `SpecialFeatureResolver.resolve`
  /// NÃO produz este valor: quem monta as invocações é
  /// `EldritchInvocationResolver`, e é por isso que elas não aparecem
  /// duplicadas na seção de características de classe.
  invocation('invocation', 'Invocação Mística');

  const FeatureOrigin(this.id, this.label);

  final String id;
  final String label;
}

/// Uma característica que o personagem REALMENTE tem, já resolvida contra a
/// classe, a subclasse e o nível dele.
///
/// Existe para a interface não precisar cruzar três listas do compêndio de
/// novo em cada tela — e para a origem aparecer na ficha, que é o que permite
/// escrever "Defesa sem Armadura — Bárbaro, nível 1".
class ResolvedFeature {
  const ResolvedFeature({
    required this.id,
    required this.name,
    required this.origin,
    required this.classId,
    required this.originId,
    required this.originLabel,
    required this.level,
    this.description,
    this.effects = const [],
    this.action,
    this.choice,
    this.supersededBy,
  });

  /// Identificador estável desta característica NESTE personagem.
  ///
  /// É a chave do estado persistido (usos gastos, escolha feita), por isso
  /// precisa sobreviver a tradução de nome e a reordenação do asset. O nível
  /// entra na chave porque a mesma classe pode conceder nomes iguais em
  /// níveis diferentes.
  final String id;

  final String name;
  final String? description;

  final FeatureOrigin origin;

  /// Classe que concedeu. No multiclasse é o que diz qual linha de
  /// `classLevels` pagou por esta característica.
  final String classId;

  /// Id da fonte: a classe, ou a subclasse quando vem dela.
  final String originId;

  /// Nome da fonte, como a ficha mostra: `Bárbaro`, `Caminho do Berserker`.
  final String originLabel;

  /// Nível de classe em que foi obtida.
  final int level;

  final List<FeatureEffect> effects;

  /// O custo na economia do turno, quando tem um.
  final FeatureAction? action;

  /// Decisão que a característica exige, quando exige uma.
  final FeatureChoice? choice;

  /// Id da característica que tornou esta inoperante.
  ///
  /// Preenchido pela regra de multiclasse: quem já tem Defesa sem Armadura não
  /// recebe uma segunda versão. A característica NÃO é apagada — ela continua
  /// listada na ficha, explicada, só sem efeito.
  final String? supersededBy;

  bool get isSuperseded => supersededBy != null;

  bool get hasDescription {
    final text = description;
    return text != null && text.trim().isNotEmpty;
  }

  /// Origem e nível, como a ficha escreve: `Bárbaro, nível 1`.
  String get sourceLabel => '$originLabel, nível $level';

  /// Linha completa: `Defesa sem Armadura — Bárbaro, nível 1`.
  String get headline => '$name — $sourceLabel';

  /// Efeitos que o app transforma em número.
  ///
  /// Vazia numa característica superada: ela existe na ficha, mas não produz
  /// efeito nenhum.
  List<FeatureEffect> get calculatedEffects {
    if (isSuperseded) return const [];
    return effects.where((item) => item.isCalculated).toList(growable: false);
  }

  /// Efeitos declarados que o app não arbitra, para a ficha mostrar a regra.
  List<FeatureEffect> get referenceEffects =>
      effects.where((item) => !item.isCalculated).toList(growable: false);

  ResolvedFeature copyWith({String? supersededBy}) {
    return ResolvedFeature(
      id: id,
      name: name,
      origin: origin,
      classId: classId,
      originId: originId,
      originLabel: originLabel,
      level: level,
      description: description,
      effects: effects,
      action: action,
      choice: choice,
      supersededBy: supersededBy ?? this.supersededBy,
    );
  }
}

/// Uma escolha de característica que o personagem alcançou e não fez.
///
/// Espelha `PendingSubclassChoice`: o mesmo problema, o mesmo formato, para a
/// ficha tratar as duas pendências igual.
class PendingFeatureChoice {
  const PendingFeatureChoice({required this.feature, required this.choice});

  final ResolvedFeature feature;
  final FeatureChoice choice;

  String get featureId => feature.id;
  String get choiceId => choice.id;
}

/// O conjunto de características do personagem, com os efeitos já agregados.
class ResolvedFeatures {
  const ResolvedFeatures({required this.features});

  static const ResolvedFeatures empty = ResolvedFeatures(features: []);

  final List<ResolvedFeature> features;

  bool get isEmpty => features.isEmpty;

  ResolvedFeature? byId(String id) {
    for (final feature in features) {
      if (feature.id == id) return feature;
    }
    return null;
  }

  /// Características de uma classe específica, na ordem dos níveis.
  List<ResolvedFeature> forClass(String classId) =>
      features.where((item) => item.classId == classId).toList(growable: false);

  /// Características que pedem para ser mostradas numa área da ficha.
  ///
  /// O filtro é pelo que o DADO declara, não por uma lista de nomes na tela:
  /// é o que permite uma característica nova aparecer no lugar certo sem
  /// mexer em widget nenhum.
  List<ResolvedFeature> forDisplay(FeatureDisplaySlot slot) {
    return features
        .where((feature) => feature.effects.any((e) => e.display == slot))
        .toList(growable: false);
  }

  /// Teto de crescimento de cada atributo.
  ///
  /// Começa no 20 da regra e só sobe se alguma característica alcançada
  /// declarar outro limite — é o que mantém o Campeão Primal como exceção
  /// declarada em vez de um `if` no caminho do incremento.
  Map<Ability, int> abilityMaximums(FeatureFormulaContext context) {
    final result = <Ability, int>{};

    for (final feature in features) {
      for (final effect in feature.calculatedEffects) {
        if (effect.path != FeatureEffectPaths.abilityMaximum) continue;

        final value = FeatureFormula.valueOf(effect.formula, context);
        if (value == null) continue;

        for (final ability in effect.abilities) {
          final current = result[ability] ?? GrantedAbilityIncreases.maximum;
          if (value > current) result[ability] = value;
        }
      }
    }

    return result;
  }

  /// O teto de um atributo, já com as exceções aplicadas.
  int maximumFor(Ability ability, FeatureFormulaContext context) =>
      abilityMaximums(context)[ability] ?? GrantedAbilityIncreases.maximum;

  /// Aumentos permanentes de atributo que as características concedem.
  ///
  /// Só as características que o personagem ALCANÇOU entram aqui: a lista já
  /// vem cortada pelo nível DA CLASSE em `SpecialFeatureResolver.resolve`, e é
  /// isso que faz o Campeão Primal valer para o Bárbaro 20 e não para um
  /// personagem de nível total 20 com 19 níveis de Bárbaro.
  ///
  /// Característica superada não concede nada, porque [calculatedEffects]
  /// devolve vazio nesse caso.
  ///
  /// O mapa é deduplicado por id de efeito: a mesma declaração não pode contar
  /// duas vezes, e é essa garantia que mantém a aplicação idempotente por
  /// construção, sem depender de quem chama.
  Map<Ability, int> abilityBonuses(FeatureFormulaContext context) {
    final result = <Ability, int>{};
    final highestByGroup = <String, Map<Ability, int>>{};
    final seen = <String>{};

    for (final feature in features) {
      for (final effect in feature.calculatedEffects) {
        if (effect.path != FeatureEffectPaths.abilityBonus) continue;
        if (!seen.add(effect.id)) continue;

        final value = FeatureFormula.valueOf(effect.formula, context);
        if (value == null || value == 0) continue;

        // `highest` existe para duas fontes do mesmo benefício não se somarem.
        // Sem grupo declarado, o próprio caminho serve de grupo.
        if (effect.stacking == FeatureEffectStacking.highest) {
          final group = effect.group ?? effect.path;
          final bucket = highestByGroup.putIfAbsent(group, () => {});
          for (final ability in effect.abilities) {
            final current = bucket[ability];
            if (current == null || value > current) bucket[ability] = value;
          }
          continue;
        }

        for (final ability in effect.abilities) {
          result[ability] = (result[ability] ?? 0) + value;
        }
      }
    }

    for (final bucket in highestByGroup.values) {
      for (final entry in bucket.entries) {
        result[entry.key] = (result[entry.key] ?? 0) + entry.value;
      }
    }

    return result;
  }

  /// Bônus de CA declarados pelas características, somados.
  ///
  /// Soma porque são bônus independentes, não fórmulas base — quem não soma é
  /// a CA-base, resolvida em `ArmorClassOptions`.
  int armorClassBonus(FeatureFormulaContext context) {
    var total = 0;

    for (final feature in features) {
      for (final effect in feature.calculatedEffects) {
        if (effect.path != FeatureEffectPaths.armorClassBonus) continue;
        final value = FeatureFormula.valueOf(effect.formula, context);
        if (value != null) total += value;
      }
    }

    return total;
  }

  /// Escolhas obrigatórias ainda em aberto.
  ///
  /// [selections] é o que o jogador já decidiu, por id de característica. Uma
  /// escolha cujo id salvo não existe mais nas opções conta como pendente: o
  /// compêndio pode ter sido revisado, e deixar a ficha com um valor inválido
  /// seria pior que pedir de novo.
  List<PendingFeatureChoice> pendingChoices(Map<String, String> selections) {
    final result = <PendingFeatureChoice>[];

    for (final feature in features) {
      final choice = feature.choice;
      if (choice == null || !choice.isRequired) continue;
      // Característica superada não cobra escolha: ela não está valendo.
      if (feature.isSuperseded) continue;

      if (choice.optionById(selections[feature.id]) != null) continue;

      result.add(PendingFeatureChoice(feature: feature, choice: choice));
    }

    return result;
  }
}

/// Monta as características especiais a partir da classe, da subclasse e do
/// nível do personagem.
///
/// É o ponto único em que a regra mora. A interface recebe [ResolvedFeatures]
/// pronto e não reimplementa nenhuma decisão — nem o corte por nível, nem a
/// exceção de multiclasse, nem a leitura das fórmulas.
///
/// O que entra:
///
/// - características de classe já alcançadas em cada classe do personagem;
/// - características da subclasse escolhida, quando há uma;
/// - os efeitos declarados em cada uma delas.
///
/// O que fica de fora: características de níveis futuros. O corte é por
/// `level <= nível na classe`, o mesmo que as outras telas usam, para uma
/// característica do 6º nível não aparecer ativa num personagem de 3º.
class SpecialFeatureResolver {
  const SpecialFeatureResolver._();

  static ResolvedFeatures resolve({
    required Character character,
    required List<ClassEntry> classes,
    required List<ClassFeatureEntry> classFeatures,
    List<SubclassEntry> subclasses = const [],
  }) {
    final resolved = <ResolvedFeature>[];

    // A ordem das classes é a ordem de aquisição, e importa: é ela que decide
    // qual Defesa sem Armadura vale num Bárbaro/Monge.
    for (final classLevel in character.classLevels) {
      final entry = _classById(classes, classLevel.classId);
      final className = entry?.name ?? classLevel.classId;

      final reached = classFeatures
        .where(
          (item) =>
              item.classId == classLevel.classId &&
              item.level <= classLevel.level,
        )
        .toList(growable: false)..sort((a, b) => a.level.compareTo(b.level));

      for (final featureEntry in reached) {
        for (final feature in featureEntry.features) {
          resolved.add(
            ResolvedFeature(
              id: featureId(
                origin: FeatureOrigin.classFeature,
                originId: classLevel.classId,
                level: featureEntry.level,
                name: feature.name,
              ),
              name: feature.name,
              description: feature.description,
              origin: FeatureOrigin.classFeature,
              classId: classLevel.classId,
              originId: classLevel.classId,
              originLabel: className,
              level: featureEntry.level,
              effects: feature.effects,
              action: feature.action,
              choice: feature.choice,
            ),
          );
        }
      }

      final subclass = _subclassFor(subclasses, classLevel);
      if (subclass == null) continue;

      for (final feature in subclass.featuresUpTo(classLevel.level)) {
        resolved.add(
          ResolvedFeature(
            id: featureId(
              origin: FeatureOrigin.subclassFeature,
              originId: subclass.id,
              level: feature.level,
              name: feature.name,
            ),
            name: feature.name,
            description: feature.description,
            origin: FeatureOrigin.subclassFeature,
            classId: classLevel.classId,
            originId: subclass.id,
            originLabel: subclass.name,
            level: feature.level,
            effects: feature.effects,
            action: feature.action,
            choice: feature.choice,
          ),
        );
      }
    }

    return ResolvedFeatures(features: _applyUniqueRule(resolved));
  }

  /// Identificador estável de uma característica.
  ///
  /// Público porque o estado persistido (usos, escolha) é gravado por esta
  /// chave, e testes e migração precisam montá-la igual.
  static String featureId({
    required FeatureOrigin origin,
    required String originId,
    required int level,
    required String name,
  }) {
    return '${origin.id}.$originId.$level.${slug(name)}';
  }

  /// Normaliza um nome para caber num identificador.
  static String slug(String value) {
    final lowered = value.toLowerCase().trim();
    final stripped = _withoutDiacritics(lowered);
    return stripped
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// A regra de multiclasse do levantamento: característica com a mesma
  /// identidade não é concedida duas vezes.
  ///
  /// Vale a PRIMEIRA alcançada, na ordem das classes do personagem. As demais
  /// continuam na lista marcadas como superadas, porque a ficha precisa
  /// explicar por que a segunda versão não está valendo — apagá-la faria
  /// parecer que o app perdeu a característica.
  static List<ResolvedFeature> _applyUniqueRule(List<ResolvedFeature> items) {
    final winners = <String, ResolvedFeature>{};
    final result = <ResolvedFeature>[];

    for (final feature in items) {
      final keys =
          feature.effects
              .map((effect) => effect.unique)
              .whereType<String>()
              .toSet();

      if (keys.isEmpty) {
        result.add(feature);
        continue;
      }

      final taken = keys
          .map((key) => winners[key])
          .whereType<ResolvedFeature>()
          .toList(growable: false);

      if (taken.isEmpty) {
        for (final key in keys) {
          winners[key] = feature;
        }
        result.add(feature);
        continue;
      }

      result.add(feature.copyWith(supersededBy: taken.first.id));
    }

    return List<ResolvedFeature>.unmodifiable(result);
  }

  /// A subclasse desta linha de classe, quando há uma escolhida.
  ///
  /// Casa por id E classe primeiro: com variantes de classe o mesmo id de
  /// subclasse aparece para mais de uma classe, e pegar a primeira daria a
  /// característica do nível errado. É a mesma precaução do resolvedor de
  /// combate.
  static SubclassEntry? _subclassFor(
    List<SubclassEntry> subclasses,
    ClassLevel classLevel,
  ) {
    final subclassId = classLevel.subclassId;
    if (subclassId == null || subclassId.isEmpty) return null;

    final classId = classLevel.classId;

    for (final item in subclasses) {
      if (item.id == subclassId && item.classId == classId) return item;
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

  /// Troca acentos pelas letras equivalentes, para o identificador ficar em
  /// ASCII. Os nomes do compêndio são em português, e `Fúria` e `Furia` não
  /// podem gerar chaves diferentes.
  static String _withoutDiacritics(String value) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';

    final buffer = StringBuffer();
    for (final char in value.split('')) {
      final index = from.indexOf(char);
      buffer.write(index == -1 ? char : to[index]);
    }

    return buffer.toString();
  }
}
