import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/pact_boon.dart';

/// Como a invocação libera a magia que concede.
enum InvocationSpellMode {
  /// À vontade, sem gastar espaço de magia.
  atWill('at_will', 'à vontade'),

  /// Uma vez por descanso longo.
  oncePerLongRest('once_per_long_rest', 'uma vez por descanso longo');

  const InvocationSpellMode(this.id, this.label);

  final String id;
  final String label;

  static InvocationSpellMode? fromId(String? id) {
    if (id == null) return null;
    final normalized = id.trim().toLowerCase();
    for (final item in InvocationSpellMode.values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}

/// Uma magia que a invocação coloca no livro do personagem.
///
/// O nome da magia fica em INGLÊS de propósito: é o que `SpellNameIndex`
/// resolve com segurança. Três magias de Tasha compartilham o nome em
/// português com magias do PHB (Invocar Celestial, Elemental e Feérico), e
/// casar por nome traduzido pegaria a errada.
class InvocationSpellGrant {
  const InvocationSpellGrant({
    required this.spellName,
    required this.mode,
    this.namePt,
    this.usesPactSlot = false,
    this.selfOnly = false,
    this.note,
  });

  /// Nome em inglês, para a busca no compêndio.
  final String spellName;

  /// Nome em português, só para a ficha explicar antes de resolver a magia.
  final String? namePt;

  final InvocationSpellMode mode;

  /// Se a conjuração consome um espaço de Magia de Pacto.
  ///
  /// Separado de [mode] porque as duas coisas são independentes no livro:
  /// Sussurros Enfeitiçadores é "uma vez por descanso longo E gastando espaço",
  /// Servidão Imortal é "uma vez por descanso longo e SEM gastar espaço".
  final bool usesPactSlot;

  /// Se a magia só pode ser conjurada no próprio personagem.
  final bool selfOnly;

  /// Restrição de regra que o app não arbitra, em texto.
  final String? note;

  /// Se a magia não custa espaço de magia nenhum.
  bool get isFree => !usesPactSlot;

  /// Como a ficha resume o custo: `à vontade, sem gastar espaço de magia`.
  String get costLabel {
    final base = mode.label;
    if (usesPactSlot) return '$base, gastando um espaço de magia de Bruxo';
    return '$base, sem gastar espaço de magia';
  }

  static InvocationSpellGrant? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final spellName = raw['spell']?.toString().trim();
    if (spellName == null || spellName.isEmpty) return null;

    // Sem modo declarado a concessão é descartada: inventar "à vontade" daria
    // ao jogador uma magia gratuita que a regra não concede.
    final mode = InvocationSpellMode.fromId(raw['mode']?.toString());
    if (mode == null) return null;

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    return InvocationSpellGrant(
      spellName: spellName,
      namePt: text('name_pt'),
      mode: mode,
      usesPactSlot: raw['uses_pact_slot'] == true,
      selfOnly: raw['self_only'] == true,
      note: text('note'),
    );
  }

  static List<InvocationSpellGrant> parseList(Object? raw) {
    if (raw is! List) return const [];

    final result = <InvocationSpellGrant>[];
    for (final item in raw) {
      final grant = tryParse(item);
      if (grant != null) result.add(grant);
    }

    return result.isEmpty
        ? const []
        : List<InvocationSpellGrant>.unmodifiable(result);
  }
}

/// O que a invocação muda em Rajada Mística.
///
/// Fica estruturado, e não em texto, porque a ficha precisa SOMAR: um Bruxo
/// com Rajada Agonizante, Lança Mística e Rajada Repelente tem um ataque com
/// três mudanças ao mesmo tempo, e cada uma vem de uma invocação diferente.
class EldritchBlastModifier {
  const EldritchBlastModifier({
    this.damageBonusFormula,
    this.rangeMeters,
    this.pushMeters,
    this.pullMeters,
    this.slowMeters,
    this.oncePerTurn = false,
  });

  /// Fórmula do dano extra por acerto. Ver `FeatureFormula`.
  final String? damageBonusFormula;

  /// Alcance que substitui o padrão, em metros.
  final int? rangeMeters;

  final int? pushMeters;
  final int? pullMeters;
  final int? slowMeters;

  /// Se o efeito vale uma vez por turno, e não em cada acerto.
  final bool oncePerTurn;

  bool get isEmpty =>
      damageBonusFormula == null &&
      rangeMeters == null &&
      pushMeters == null &&
      pullMeters == null &&
      slowMeters == null;

  static EldritchBlastModifier? tryParse(Object? raw) {
    if (raw is! Map) return null;

    int? number(String key) {
      final value = raw[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    final formula = raw['damage_bonus']?.toString().trim();

    final result = EldritchBlastModifier(
      damageBonusFormula:
          formula == null || formula.isEmpty ? null : formula,
      rangeMeters: number('range_meters'),
      pushMeters: number('push_meters'),
      pullMeters: number('pull_meters'),
      slowMeters: number('slow_meters'),
      oncePerTurn: raw['once_per_turn'] == true,
    );

    return result.isEmpty ? null : result;
  }
}

/// O que a invocação muda na arma do Pacto da Lâmina.
class PactWeaponModifier {
  const PactWeaponModifier({
    this.attacks,
    this.attackBonus,
    this.damageBonusFlat,
    this.damageBonusFormula,
    this.damageType,
    this.damageMinimum,
    this.extraDamageDice,
    this.spellcastingFocus = false,
    this.allowsRanged = false,
  });

  /// Quantos ataques a ação de Atacar passa a fazer com a arma de pacto.
  final int? attacks;

  final int? attackBonus;

  /// Bônus fixo de dano, como o +1 da Arma de Pacto Aprimorada.
  final int? damageBonusFlat;

  /// Bônus de dano derivado de atributo. Ver `FeatureFormula`.
  final String? damageBonusFormula;

  /// Tipo do dano extra, em texto: `necrótico`, `força`.
  final String? damageType;

  /// Piso do dano extra, quando a regra declara um.
  final int? damageMinimum;

  /// Dados de dano extra em texto, quando dependem do espaço gasto.
  final String? extraDamageDice;

  /// Se a arma serve de foco de conjuração.
  final bool spellcastingFocus;

  /// Se o pacto passa a invocar arma à distância.
  final bool allowsRanged;

  bool get isEmpty =>
      attacks == null &&
      attackBonus == null &&
      damageBonusFlat == null &&
      damageBonusFormula == null &&
      extraDamageDice == null &&
      !spellcastingFocus &&
      !allowsRanged;

  static PactWeaponModifier? tryParse(Object? raw) {
    if (raw is! Map) return null;

    int? number(String key) {
      final value = raw[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    final result = PactWeaponModifier(
      attacks: number('attacks'),
      attackBonus: number('attack_bonus'),
      damageBonusFlat: number('damage_bonus_flat'),
      damageBonusFormula: text('damage_bonus'),
      damageType: text('damage_type'),
      damageMinimum: number('damage_minimum'),
      extraDamageDice: text('extra_damage_dice'),
      spellcastingFocus: raw['spellcasting_focus'] == true,
      allowsRanged: raw['allows_ranged'] == true,
    );

    return result.isEmpty ? null : result;
  }
}

/// Os pré-requisitos de uma invocação, em forma estruturada.
///
/// Nada aqui é texto livre, e isso é o ponto: a disponibilidade é decidida
/// comparando NÍVEL DE BRUXO, ID DE DÁDIVA DO PACTO, ID DE TRUQUE, ID DE
/// MAGIA e ID DE INVOCAÇÃO. Comparar o nome visível quebraria a cada revisão
/// de tradução — e "Pacto da Lâmina" aparece escrito de três formas
/// diferentes só nas descrições do compêndio.
class InvocationPrerequisites {
  const InvocationPrerequisites({
    this.warlockLevel,
    this.pactBoon,
    this.cantrip,
    this.spell,
    this.requiresCurseSource = false,
    this.invocations = const [],
    this.incompatibleWith = const [],
  });

  static const InvocationPrerequisites none = InvocationPrerequisites();

  /// Nível mínimo NA CLASSE BRUXO. Nunca o nível total do personagem.
  final int? warlockLevel;

  /// Dádiva do Pacto exigida.
  final PactBoon? pactBoon;

  /// Id do truque exigido, como `eldritch_blast`.
  final String? cantrip;

  /// Nome em inglês da magia exigida, como `hex`.
  final String? spell;

  /// Se exige a magia Hex OU uma característica de Bruxo que amaldiçoa.
  ///
  /// É o pré-requisito literal de Maldição Enlouquecedora e Maldição
  /// Implacável, e é uma OU: por isso não dá para expressá-lo só com [spell].
  final bool requiresCurseSource;

  /// Ids de invocações que precisam estar selecionadas.
  final List<String> invocations;

  /// Ids de invocações que não podem estar selecionadas junto.
  final List<String> incompatibleWith;

  bool get isEmpty =>
      warlockLevel == null &&
      pactBoon == null &&
      cantrip == null &&
      spell == null &&
      !requiresCurseSource &&
      invocations.isEmpty &&
      incompatibleWith.isEmpty;

  static InvocationPrerequisites tryParse(Object? raw) {
    if (raw is! Map) return none;

    int? number(String key) {
      final value = raw[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    List<String> ids(String key) {
      final value = raw[key];
      if (value is String) {
        final single = value.trim();
        return single.isEmpty ? const [] : [single];
      }
      if (value is! List) return const [];

      final result = <String>[];
      for (final item in value) {
        final id = item?.toString().trim();
        if (id != null && id.isNotEmpty) result.add(id);
      }
      return result.isEmpty ? const [] : List<String>.unmodifiable(result);
    }

    return InvocationPrerequisites(
      warlockLevel: number('warlock_level'),
      pactBoon: PactBoon.fromId(text('pact_boon')),
      cantrip: text('cantrip'),
      spell: text('spell'),
      requiresCurseSource: raw['curse_source'] == true,
      invocations: ids('invocations'),
      incompatibleWith: ids('incompatible_with'),
    );
  }
}

/// Uma Invocação Mística do catálogo.
///
/// É dado de compêndio: o personagem guarda apenas o [id] escolhido, e tudo o
/// que aparece na ficha é lido daqui a cada leitura. Corrigir o texto do
/// catálogo corrige a ficha, e uma invocação que deixa de ser elegível não é
/// apagada do personagem — ver `EldritchInvocationResolver`.
class EldritchInvocationEntry {
  const EldritchInvocationEntry({
    required this.id,
    required this.name,
    required this.source,
    this.nameOriginal,
    this.description,
    this.prerequisites = InvocationPrerequisites.none,
    this.spellGrants = const [],
    this.action,
    this.blast,
    this.pactWeapon,
    this.skillProficiencies = const [],
    this.isCurseSource = false,
    this.tags = const [],
  });

  /// Identificador estável, único no catálogo. É o que fica persistido.
  final String id;

  final String name;

  /// Nome em inglês, para busca e para quem consulta o livro original.
  final String? nameOriginal;

  final String? description;

  /// Livro de origem: `phb`, `xge`, `tcoe`.
  final String source;

  final InvocationPrerequisites prerequisites;

  /// Magias que a invocação concede.
  final List<InvocationSpellGrant> spellGrants;

  /// O custo na economia do turno e o limite de usos, quando há.
  ///
  /// Reaproveita o mesmo bloco `action` das características de classe para a
  /// seção de Recursos e descanso não precisar de um segundo vocabulário.
  final FeatureAction? action;

  /// O que muda em Rajada Mística.
  final EldritchBlastModifier? blast;

  /// O que muda na arma do Pacto da Lâmina.
  final PactWeaponModifier? pactWeapon;

  /// Perícias em que a invocação concede proficiência, por id de perícia.
  final List<String> skillProficiencies;

  /// Se ESTA invocação amaldiçoa um alvo, e portanto satisfaz o pré-requisito
  /// de Maldição Enlouquecedora e Maldição Implacável.
  ///
  /// Existe porque o compêndio de referência cita Sinal de Mau Agouro ao lado
  /// de Maldição da Lâmina como fonte válida: a maldição não vem só da magia
  /// Hex nem só de uma característica de subclasse, e uma invocação pode
  /// habilitar outra. Fica declarado no asset, e não numa lista de ids no
  /// código, pelo mesmo motivo da etiqueta na subclasse.
  final bool isCurseSource;

  final List<String> tags;

  /// Chave do estado persistido desta invocação (usos gastos).
  ///
  /// Não usa nível nem nome: a invocação é a mesma em qualquer nível, e o nome
  /// é traduzido. Formato irmão do de `SpecialFeatureResolver.featureId`, para
  /// as duas chaves nunca colidirem.
  String get featureId => featureIdFor(id);

  static String featureIdFor(String invocationId) =>
      'invocation.$invocationId';

  /// Nomes pelos quais a busca da tela encontra esta invocação.
  List<String> get searchableNames => [
    name,
    if (nameOriginal != null) nameOriginal!,
  ];

  bool get hasLimitedUses => action?.hasLimitedUses ?? false;

  bool get hasDescription {
    final text = description;
    return text != null && text.trim().isNotEmpty;
  }

  bool get grantsSpells => spellGrants.isNotEmpty;

  bool get modifiesBlast => blast != null;

  bool get modifiesPactWeapon => pactWeapon != null;

  /// Se a invocação não faz nada além do que o texto descreve.
  bool get isPassive =>
      action == null &&
      spellGrants.isEmpty &&
      blast == null &&
      pactWeapon == null &&
      skillProficiencies.isEmpty;

  /// Rótulo da fonte, como a ficha mostra.
  String get sourceLabel {
    switch (source.trim().toLowerCase()) {
      case 'phb':
        return 'Livro do Jogador';
      case 'xge':
        return 'Guia de Xanathar';
      case 'tcoe':
      case 'tce':
        return 'Caldeirão de Tasha';
      default:
        return source;
    }
  }

  /// Texto do pré-requisito, para a tela listar sem reimplementar a regra.
  ///
  /// Vazio quando não há nenhum. Não decide disponibilidade: quem decide é
  /// `EldritchInvocationPrerequisites`, no domínio.
  List<String> get prerequisiteLabels {
    final pre = prerequisites;
    return [
      if (pre.warlockLevel != null) 'Bruxo de nível ${pre.warlockLevel}',
      if (pre.pactBoon != null) pre.pactBoon!.label,
      if (pre.cantrip == 'eldritch_blast') 'truque Rajada Mística',
      if (pre.cantrip != null && pre.cantrip != 'eldritch_blast')
        'truque ${pre.cantrip}',
      if (pre.requiresCurseSource)
        'magia Hex ou característica de Bruxo que amaldiçoa',
      if (pre.spell != null && !pre.requiresCurseSource) 'magia ${pre.spell}',
    ];
  }

  /// Lê uma entrada do catálogo.
  ///
  /// Tolerante como o resto do compêndio: entrada sem id ou sem nome é
  /// descartada em vez de derrubar a leitura das outras 53.
  static EldritchInvocationEntry? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final id = raw['id']?.toString().trim();
    final name = raw['name']?.toString().trim();
    if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    final skills = <String>[];
    final rawSkills = raw['skill_proficiencies'];
    if (rawSkills is List) {
      for (final item in rawSkills) {
        final skill = item?.toString().trim();
        if (skill != null && skill.isNotEmpty) skills.add(skill);
      }
    }

    final tags = <String>[];
    final rawTags = raw['tags'];
    if (rawTags is List) {
      for (final item in rawTags) {
        final tag = item?.toString().trim();
        if (tag != null && tag.isNotEmpty) tags.add(tag);
      }
    }

    return EldritchInvocationEntry(
      id: id,
      name: name,
      nameOriginal: text('name_original'),
      description: text('description'),
      source: text('source') ?? '',
      prerequisites: InvocationPrerequisites.tryParse(raw['prerequisites']),
      spellGrants: InvocationSpellGrant.parseList(raw['grants_spells']),
      action: FeatureAction.tryParse(raw['action']),
      blast: EldritchBlastModifier.tryParse(raw['blast']),
      pactWeapon: PactWeaponModifier.tryParse(raw['pact_weapon']),
      skillProficiencies: skills.isEmpty
          ? const []
          : List<String>.unmodifiable(skills),
      isCurseSource: raw['curse_source'] == true,
      tags: tags.isEmpty ? const [] : List<String>.unmodifiable(tags),
    );
  }

  /// Normaliza texto para busca e comparação de nome.
  static String normalizeName(String value) {
    final lower = value.trim().toLowerCase();

    final withoutAccents = lower
        .replaceAll(RegExp('[áàâãä]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[íìîï]'), 'i')
        .replaceAll(RegExp('[óòôõö]'), 'o')
        .replaceAll(RegExp('[úùûü]'), 'u')
        .replaceAll('ç', 'c');

    return withoutAccents
        // O sublinhado entra na lista porque os ids de pré-requisito usam
        // `eldritch_blast` e o compêndio guarda `Eldritch Blast`: sem isso as
        // duas formas nunca se encontrariam.
        .replaceAll(RegExp(r"[_'’\.,\-/]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
