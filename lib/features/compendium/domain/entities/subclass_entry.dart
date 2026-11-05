import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/initiative_rule.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_grant.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spellcasting_progression.dart';

/// Magias que a subclasse concede num nível de classe.
///
/// Guardamos o nome, não o id: o documento de origem lista as magias por nome,
/// e um id numérico digitado à mão seria impossível de revisar. A conversão
/// para id acontece no `SpellNameIndex`, e há teste garantindo que todo nome
/// citado existe no compêndio.
class SubclassSpellGrant {
  const SubclassSpellGrant({required this.level, required this.spellNames});

  /// Nível de classe em que as magias passam a estar disponíveis.
  final int level;

  final List<String> spellNames;
}

/// Conjuração concedida pela subclasse, e não pela classe.
///
/// É o caso do Trapaceiro Arcano e do Cavaleiro Arcano: Ladino e Guerreiro não
/// conjuram, mas essas duas subclasses conjuram magias de mago como
/// um-terço-conjuradores a partir do 3º nível. Sem isto, os espaços de magia
/// desses personagens eram calculados a partir da classe, que declara
/// `spellcasting_type: null`, e o resultado era zero espaço.
class SubclassSpellcasting {
  const SubclassSpellcasting({required this.type, this.ability, this.spellList});

  /// Tipo de progressão, nos mesmos valores de `ClassEntry.spellcastingType`.
  /// Ver [SpellcastingProgression].
  final String type;

  /// Atributo de conjuração, quando o asset declara. Inteligência nos dois
  /// casos atuais, porque ambos conjuram da lista do mago.
  final String? ability;

  /// Lista de magias de onde a subclasse conjura, quando declarada.
  final String? spellList;

  /// Nível de classe a partir do qual a conjuração existe: 3 para um-terço.
  int get startLevel => SpellcastingProgression.startLevel(type);

  /// Se o tipo declarado é uma progressão de conjuração reconhecida.
  bool get isCasting => SpellcastingProgression.isCasting(type);
}

/// Característica que a subclasse concede num nível específico.
class SubclassFeature {
  const SubclassFeature({
    required this.level,
    required this.name,
    required this.description,
    this.action,
    this.initiative,
    this.effects = const [],
    this.choice,
    this.languageGrants = const [],
  });

  /// Nível de classe em que a característica é liberada.
  final int level;

  final String name;
  final String description;

  /// O que custa na economia do turno, no mesmo formato das características de
  /// classe. Nulo é o caso normal: a maioria é passiva.
  final FeatureAction? action;

  /// O que a característica faz com a iniciativa, quando faz algo.
  ///
  /// É por aqui que Emboscador Terrível soma Sabedoria à iniciativa, em vez de
  /// a interface checar o id da subclasse.
  final InitiativeRule? initiative;

  /// O que a característica muda na ficha, no mesmo formato das
  /// características de classe. Ver [FeatureEffect].
  final List<FeatureEffect> effects;

  /// Decisão que a característica exige do jogador, quando exige uma.
  final FeatureChoice? choice;

  /// Idiomas que a característica de subclasse concede.
  ///
  /// Mesmo formato das características de classe. Ver [LanguageGrant].
  final List<LanguageGrant> languageGrants;
}

/// Subclasse de uma classe: Campeão do Guerreiro, Domínio da Vida do Clérigo.
///
/// O nível em que a escolha acontece não fica aqui, e sim em
/// `ClassEntry.subclassLevel`, porque é a classe que define isso — o Guerreiro
/// escolhe no 3º nível, o Clérigo já no 1º.
class SubclassEntry {
  const SubclassEntry({
    required this.id,
    required this.classId,
    required this.name,
    required this.source,
    this.description,
    this.features = const [],
    this.spells = const [],
    this.tags = const [],
    this.spellcasting,
  });

  final String id;

  /// Id da classe a que pertence.
  final String classId;

  final String name;
  final String source;
  final String? description;
  final List<SubclassFeature> features;

  /// Magias concedidas pela subclasse, por nível de classe.
  final List<SubclassSpellGrant> spells;

  final List<String> tags;

  /// Conjuração que a subclasse concede, quando concede. Nulo é o caso normal:
  /// a maioria das subclasses não muda nada na conjuração da classe.
  final SubclassSpellcasting? spellcasting;

  /// Se esta subclasse concede conjuração por conta própria.
  bool get grantsSpellcasting => spellcasting?.isCasting ?? false;

  /// Características já liberadas para quem tem [level] níveis na classe.
  List<SubclassFeature> featuresUpTo(int level) {
    final visible = features
        .where((feature) => feature.level <= level)
        .toList(growable: false);

    return visible..sort((a, b) => a.level.compareTo(b.level));
  }

  /// A mesma subclasse, apresentada como pertencente a [classId].
  ///
  /// Serve para uma variante de classe reaproveitar as subclasses da
  /// classe-base sem duplicar as entradas do asset. O conteúdo é idêntico de
  /// propósito: o Caçador de uma variante do Patrulheiro é o mesmo Caçador, só
  /// precisa aparecer para o id da variante nos filtros que comparam
  /// `classId`.
  SubclassEntry forClass(String classId) {
    if (classId == this.classId) return this;

    return SubclassEntry(
      id: id,
      classId: classId,
      name: name,
      source: source,
      description: description,
      features: features,
      spells: spells,
      tags: tags,
      spellcasting: spellcasting,
    );
  }

  /// Nomes das magias já liberadas para quem tem [level] níveis na classe.
  ///
  /// Sem repetição: uma magia que apareça em dois níveis (acontece nas listas
  /// escritas à mão) entra uma vez só.
  List<String> spellNamesUpTo(int level) {
    final names = <String>{};

    for (final grant in spells) {
      if (grant.level > level) continue;
      names.addAll(grant.spellNames.where((name) => name.trim().isNotEmpty));
    }

    return names.toList(growable: false);
  }
}
