import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/initiative_rule.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_grant.dart';

/// O que uma característica custa na economia do turno.
///
/// Só existe nas características que de fato consomem ação, ação bônus ou
/// reação. A maioria é passiva e não declara nada — e a ausência é o caso
/// normal, não um dado faltando.
class FeatureAction {
  const FeatureAction({
    required this.type,
    this.uses,
    this.usesFormula,
    this.recharge,
    this.trigger,
    this.requires,
    this.cost,
    this.attacks,
    this.group,
    this.label,
  });

  final CombatActionType type;

  /// Chave que junta as etapas de uma mesma progressão.
  ///
  /// "Canalizar Divindade (1 uso)" no 2º nível e "(3 usos)" no 18º são a mesma
  /// opção de turno, e um clérigo de 18º nível não pode ver três linhas dela.
  /// O resolvedor mantém só a do nível mais alto dentro do grupo.
  final String? group;

  /// Nome a exibir, quando o do asset carrega o sufixo da progressão.
  ///
  /// "Canalizar Divindade (3 usos)" é bom no compêndio e redundante no painel,
  /// que já mostra os usos em campo próprio.
  final String? label;

  /// Usos fixos por recarga.
  final int? uses;

  /// Usos derivados de um valor do personagem, quando não são fixos.
  ///
  /// Vocabulário pequeno de propósito: hoje só `proficiency`, que cobre os
  /// casos de Tasha (Inimigo Favorecido, Véu da Natureza, Incansável).
  final String? usesFormula;

  final ActionRecharge? recharge;

  /// O que dispara, nas reações.
  final String? trigger;

  /// Condição para poder usar, em texto.
  final String? requires;

  /// Custo além do tipo de ação: pontos de ki, um espaço de magia.
  final String? cost;

  /// Quantos ataques a ação de Atacar passa a fazer.
  ///
  /// É como o Ataque Extra entra: ele não é uma ação própria, muda a ação de
  /// Atacar. Em multiclasse não acumula — o resolvedor usa o maior valor.
  final int? attacks;

  bool get hasLimitedUses => uses != null || usesFormula != null;

  /// Lê o bloco `action` do asset. Nulo quando a característica é passiva.
  ///
  /// Tolerante como o resto do compêndio: bloco sem tipo reconhecido é
  /// descartado em vez de derrubar a leitura das outras características.
  static FeatureAction? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final type = CombatActionType.fromId(raw['type']?.toString());
    if (type == null) return null;

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    int? number(String key) {
      final value = raw[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    return FeatureAction(
      type: type,
      uses: number('uses'),
      usesFormula: text('uses_formula'),
      recharge: ActionRecharge.fromId(raw['recharge']?.toString()),
      trigger: text('trigger'),
      requires: text('requires'),
      cost: text('cost'),
      attacks: number('attacks'),
      group: text('group'),
      label: text('label'),
    );
  }
}

/// Uma característica de classe, com o texto que explica o que ela faz.
///
/// A descrição é opcional porque o compêndio pode ser preenchido por partes: um
/// nome sem texto continua aparecendo na ficha, só sem a explicação.
class ClassFeature {
  const ClassFeature({
    required this.name,
    this.description,
    this.action,
    this.initiative,
    this.effects = const [],
    this.choice,
    this.languageGrants = const [],
  });

  final String name;
  final String? description;

  /// O custo na economia do turno, quando a característica tem um.
  final FeatureAction? action;

  /// O que a característica faz com a iniciativa, quando faz algo.
  ///
  /// Só duas características de classe declaram: Instinto Feral do bárbaro
  /// (vantagem) e Pau para Toda Obra do bardo (metade da proficiência).
  final InitiativeRule? initiative;

  /// O que a característica muda na ficha, em forma de registro normalizado.
  ///
  /// Vazia é o caso comum: a maioria das características é texto de regra que
  /// o jogador aplica em mesa. Declarar um efeito aqui é afirmar que o app
  /// sabe calculá-lo — e é por isso que a lista não é inferida da descrição.
  final List<FeatureEffect> effects;

  /// Decisão que a característica exige do jogador, quando exige uma.
  final FeatureChoice? choice;

  /// Idiomas que a característica concede.
  ///
  /// É por aqui que Druídico e Gíria dos Ladrões entram: são idiomas de
  /// disponibilidade `feature_only`, então ninguém os escolhe livremente, e a
  /// única porta é a característica que os declara.
  final List<LanguageGrant> languageGrants;

  bool get hasDescription {
    final text = description;
    return text != null && text.trim().isNotEmpty;
  }

  /// Efeitos que o resolvedor transforma em número.
  List<FeatureEffect> get calculatedEffects =>
      effects.where((item) => item.isCalculated).toList(growable: false);

  /// Lê tanto `"Fúria"` quanto `{"name": "Fúria", "description": "..."}`.
  ///
  /// A tolerância é de propósito: com 13 classes e mais de 200 características,
  /// o arquivo pode ficar meio migrado por um tempo, e um formato antigo numa
  /// entrada não pode derrubar o compêndio inteiro.
  static ClassFeature? tryParse(Object? raw) {
    if (raw is String) {
      final name = raw.trim();
      return name.isEmpty ? null : ClassFeature(name: name);
    }

    if (raw is Map) {
      final name = raw['name']?.toString().trim() ?? '';
      if (name.isEmpty) return null;

      final description = raw['description']?.toString().trim();

      return ClassFeature(
        name: name,
        description: description == null || description.isEmpty
            ? null
            : description,
        action: FeatureAction.tryParse(raw['action']),
        initiative: InitiativeRule.tryParse(raw['initiative']),
        effects: FeatureEffect.parseList(raw['effects']),
        choice: FeatureChoice.tryParse(raw['choice']),
        languageGrants: LanguageGrant.parseList(
          raw['language_grants'],
          idPrefix: 'feature.${LanguageEntry.normalizeName(name)}',
        ),
      );
    }

    return null;
  }
}

class ClassFeatureEntry {
  const ClassFeatureEntry({
    required this.classId,
    required this.level,
    required this.features,
    required this.source,
  });

  final String classId;
  final int level;
  final List<ClassFeature> features;
  final String source;

  /// Só os nomes, para quem não precisa do texto.
  List<String> get featureNames =>
      features.map((item) => item.name).toList(growable: false);
}
