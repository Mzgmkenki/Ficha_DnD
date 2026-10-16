import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// O que uma mecânica de classe, ou uma opção dentro dela, exige do
/// personagem.
///
/// Tudo aqui é propriedade ESTRUTURADA, nunca texto de interface: nível na
/// classe responsável, id de subclasse, id de opção, nome normalizado de
/// magia. É o que permite o validador ser aritmética sobre conjuntos, e é o
/// que impede o pré-requisito de quebrar quando o compêndio é retraduzido.
///
/// Um campo vazio é "não exige", e esse é o caso comum: a maioria das opções
/// do levantamento não pede nada além do nível em que a mecânica aparece.
class MechanicPrerequisite {
  const MechanicPrerequisite({
    this.classLevel,
    this.classId,
    this.subclassId,
    this.features = const [],
    this.abilityMinimums = const {},
    this.spells = const [],
    this.proficiencies = const [],
    this.equipment = const [],
    this.options = const [],
    this.activeOptions = const [],
    this.note,
  });

  static const MechanicPrerequisite none = MechanicPrerequisite();

  /// Nível mínimo NA CLASSE que concede a mecânica.
  ///
  /// Nunca o nível total do personagem. Um Guerreiro 3 / Bruxo 9 tem nível
  /// total 12 e nível de Guerreiro 3, e é o 3 que decide se a Runa da Colina
  /// (que exige 7) está liberada.
  final int? classLevel;

  /// Classe exigida, quando a exigência não é a classe dona da mecânica.
  final String? classId;

  /// Subclasse exigida, pelo id do compêndio.
  final String? subclassId;

  /// Características exigidas, pelo nome como o compêndio as escreve.
  ///
  /// Nome e não id porque o id de característica embute o nível de aquisição
  /// (`subclass.fighter_rune_knight.3.escultor_de_runas`), e amarrar o
  /// pré-requisito a ele faria mover a característica de nível invalidar a
  /// exigência. A comparação é feita sobre o nome normalizado.
  final List<String> features;

  /// Valor mínimo de atributo.
  final Map<Ability, int> abilityMinimums;

  /// Magias ou truques que o personagem precisa conhecer, por nome.
  ///
  /// Nome, e não id numérico: o id vem do asset de magias e pode ser
  /// renumerado. Cada magia conhecida entra no perfil pelos dois nomes, o
  /// original e o traduzido, então o pré-requisito casa em qualquer um.
  final List<String> spells;

  /// Proficiências exigidas, por id ou nome normalizado.
  final List<String> proficiencies;

  /// Equipamento exigido, por id ou nome normalizado.
  final List<String> equipment;

  /// Outras opções que precisam estar escolhidas.
  ///
  /// Aceita `option_id` (dentro da mesma mecânica) e
  /// `mecanica_id:option_id` (em outra mecânica).
  final List<String> options;

  /// Opções que precisam estar ATIVAS, não apenas escolhidas.
  ///
  /// É a diferença entre conhecer um modo e estar com ele ligado — a
  /// separação que o levantamento pede em "separar opção conhecida de opção
  /// atualmente ativa".
  final List<String> activeOptions;

  /// Exigência que o app não arbitra, em texto, para a ficha mostrar.
  ///
  /// Não bloqueia nada: é regra que depende da mesa, e transformá-la em
  /// bloqueio seria decidir no lugar do Mestre.
  final String? note;

  bool get isEmpty =>
      classLevel == null &&
      classId == null &&
      subclassId == null &&
      features.isEmpty &&
      abilityMinimums.isEmpty &&
      spells.isEmpty &&
      proficiencies.isEmpty &&
      equipment.isEmpty &&
      options.isEmpty &&
      activeOptions.isEmpty &&
      (note == null || note!.trim().isEmpty);

  bool get isNotEmpty => !isEmpty;

  /// Lê o bloco `prerequisites` do asset.
  ///
  /// Tolerante como o resto do compêndio: chave desconhecida é ignorada e
  /// valor malformado é descartado, em vez de derrubar a leitura das outras
  /// mecânicas. Em um arquivo com centenas de opções, uma linha errada não
  /// pode apagar o resto.
  static MechanicPrerequisite tryParse(Object? raw) {
    if (raw is! Map) return MechanicPrerequisite.none;

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

    final abilities = <Ability, int>{};
    final rawAbilities = raw['ability_minimums'] ?? raw['abilities'];
    if (rawAbilities is Map) {
      for (final entry in rawAbilities.entries) {
        final ability = _ability(entry.key?.toString());
        if (ability == null) continue;

        final value = entry.value;
        final parsed =
            value is int
                ? value
                : value is num
                ? value.toInt()
                : int.tryParse(value?.toString().trim() ?? '');
        if (parsed == null) continue;

        abilities[ability] = parsed;
      }
    }

    return MechanicPrerequisite(
      classLevel: number('class_level') ?? number('level'),
      classId: text('class_id'),
      subclassId: text('subclass_id'),
      features: parseStringList(raw['features']),
      abilityMinimums: Map<Ability, int>.unmodifiable(abilities),
      spells: parseStringList(raw['spells']),
      proficiencies: parseStringList(raw['proficiencies']),
      equipment: parseStringList(raw['equipment']),
      options: parseStringList(raw['options']),
      activeOptions: parseStringList(raw['active_options']),
      note: text('note'),
    );
  }

  /// Lê um array de texto, descartando entrada vazia.
  ///
  /// Aceita também uma string solta, porque é assim que o asset escreve a
  /// exigência única — e obrigar `["x"]` em toda linha só geraria ruído.
  static List<String> parseStringList(Object? raw) {
    if (raw == null) return const [];

    if (raw is String) {
      final value = raw.trim();
      return value.isEmpty ? const [] : List<String>.unmodifiable([value]);
    }

    if (raw is! List) return const [];

    final result = <String>[];
    for (final item in raw) {
      final value = item?.toString().trim();
      if (value == null || value.isEmpty) continue;
      result.add(value);
    }

    return result.isEmpty ? const [] : List<String>.unmodifiable(result);
  }

  /// Aceita o nome do enum (`wisdom`) e a abreviação em português (`SAB`).
  ///
  /// Os dois porque o levantamento escreve `SAB` e o resto do app usa o nome
  /// do enum; traduzir no meio do dado seria mais um lugar para divergir.
  static Ability? _ability(String? raw) {
    final key = raw?.trim().toLowerCase();
    if (key == null || key.isEmpty) return null;

    const aliases = <String, Ability>{
      'for': Ability.strength,
      'des': Ability.dexterity,
      'con': Ability.constitution,
      'int': Ability.intelligence,
      'sab': Ability.wisdom,
      'car': Ability.charisma,
    };

    final alias = aliases[key];
    if (alias != null) return alias;

    return Ability.fromName(key);
  }
}
