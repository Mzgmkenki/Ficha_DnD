import 'package:dnd_ficha_app/core/utils/pt_collation.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_mechanic_entry.dart';

/// Nível primeiro, nome depois.
///
/// O nível vem antes de propósito e não é alfabético: a lista de recursos de
/// classe é lida como progressão, e o jogador de 5º nível espera ver o que
/// ganhou no 1º acima do que ganhou no 5º. O alfabético só resolve o empate
/// dentro do mesmo nível.
int _byLevelThenName(ClassMechanicEntry a, ClassMechanicEntry b) {
  final byLevel = a.level.compareTo(b.level);
  if (byLevel != 0) return byLevel;

  return compareDisplayNames(
    nameA: a.name,
    idA: a.id,
    nameB: b.name,
    idB: b.id,
  );
}

/// Uma duplicidade descartada ao montar o catálogo de mecânicas.
///
/// Fica registrada em vez de desaparecer em silêncio: duplicidade no asset é
/// defeito de dado, e o teste de asset precisa dizer qual entrada repetiu
/// qual. É também o que torna a leitura idempotente — processar o mesmo
/// arquivo de novo não pode produzir duas vezes a lista de manobras.
class ClassMechanicDuplicate {
  const ClassMechanicDuplicate({
    required this.keptId,
    required this.discardedId,
    required this.matchedBy,
  });

  /// Id que permaneceu. É sempre o primeiro visto.
  final String keptId;

  final String discardedId;

  /// Por qual campo a duplicidade foi detectada: `identificador` ou
  /// `origem e nome`.
  final String matchedBy;

  String get description =>
      'A mecânica "$discardedId" repete "$keptId" pelo $matchedBy.';
}

/// O catálogo de mecânicas internas de classe e subclasse, pronto para
/// consulta.
///
/// Centraliza as perguntas que o resolvedor, a tela de gerenciamento e os
/// testes fazem: "qual mecânica é este id?", "quais mecânicas esta subclasse
/// concede?" e "este id ainda existe?". É aqui, e não em cada tela, que a
/// indexação por classe e subclasse mora — dois índices diferentes é o mesmo
/// que nenhum.
class ClassMechanicCatalog {
  /// Não é `const` por causa do cache de ordenação: um campo `late final` não
  /// convive com construtor gerador constante.
  ClassMechanicCatalog._(
    this._byId,
    this._byClass,
    this._bySubclass,
    this.duplicates,
  );

  /// Catálogo vazio, para estado de carregamento e falha de asset.
  ///
  /// Falha de leitura NÃO pode derrubar a ficha: sem mecânicas, a seção
  /// simplesmente não aparece e o resto do personagem continua acessível.
  factory ClassMechanicCatalog.empty() => ClassMechanicCatalog._(
    const <String, ClassMechanicEntry>{},
    const <String, List<ClassMechanicEntry>>{},
    const <String, List<ClassMechanicEntry>>{},
    const [],
  );

  /// Monta o catálogo descartando duplicatas.
  ///
  /// A primeira entrada vista vence. Duas chaves são verificadas:
  ///
  /// - o id, que é o que fica persistido na ficha;
  /// - a combinação de origem mais nome, que pega a mesma mecânica cadastrada
  ///   duas vezes com ids diferentes — e que faria a tela mostrar "Manobras"
  ///   duas vezes, cada uma com o próprio limite.
  factory ClassMechanicCatalog.from(Iterable<ClassMechanicEntry> entries) {
    final byId = <String, ClassMechanicEntry>{};
    final byOriginAndName = <String, String>{};
    final duplicates = <ClassMechanicDuplicate>[];

    for (final entry in entries) {
      final existing = byId[entry.id];
      if (existing != null) {
        duplicates.add(
          ClassMechanicDuplicate(
            keptId: existing.id,
            discardedId: entry.id,
            matchedBy: 'identificador',
          ),
        );
        continue;
      }

      final nameKey =
          '${entry.originId}|${ClassMechanicEntry.normalizeName(entry.name)}';
      final owner = byOriginAndName[nameKey];
      if (owner != null) {
        duplicates.add(
          ClassMechanicDuplicate(
            keptId: owner,
            discardedId: entry.id,
            matchedBy: 'origem e nome',
          ),
        );
        continue;
      }

      byId[entry.id] = entry;
      byOriginAndName[nameKey] = entry.id;
    }

    final byClass = <String, List<ClassMechanicEntry>>{};
    final bySubclass = <String, List<ClassMechanicEntry>>{};

    final ordered = byId.values.toList()..sort(_byLevelThenName);

    for (final entry in ordered) {
      byClass
          .putIfAbsent(entry.classId, () => <ClassMechanicEntry>[])
          .add(entry);

      final subclassId = entry.subclassId;
      if (subclassId != null && subclassId.isNotEmpty) {
        bySubclass
            .putIfAbsent(subclassId, () => <ClassMechanicEntry>[])
            .add(entry);
      }
    }

    return ClassMechanicCatalog._(
      Map<String, ClassMechanicEntry>.unmodifiable(byId),
      Map<String, List<ClassMechanicEntry>>.unmodifiable({
        for (final item in byClass.entries)
          item.key: List<ClassMechanicEntry>.unmodifiable(item.value),
      }),
      Map<String, List<ClassMechanicEntry>>.unmodifiable({
        for (final item in bySubclass.entries)
          item.key: List<ClassMechanicEntry>.unmodifiable(item.value),
      }),
      List<ClassMechanicDuplicate>.unmodifiable(duplicates),
    );
  }

  final Map<String, ClassMechanicEntry> _byId;
  final Map<String, List<ClassMechanicEntry>> _byClass;
  final Map<String, List<ClassMechanicEntry>> _bySubclass;

  /// Duplicidades descartadas ao montar o catálogo.
  final List<ClassMechanicDuplicate> duplicates;

  /// A lista ordenada, calculada no primeiro acesso e reaproveitada.
  late final List<ClassMechanicEntry> _sorted =
      List<ClassMechanicEntry>.unmodifiable(
        _byId.values.toList()..sort(_byLevelThenName),
      );

  bool get isEmpty => _byId.isEmpty;

  bool get isNotEmpty => _byId.isNotEmpty;

  int get length => _byId.length;

  /// Todas as mecânicas, ordenadas por nível e nome.
  List<ClassMechanicEntry> get all => _sorted;

  ClassMechanicEntry? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    return _byId[id];
  }

  bool contains(String? id) => byId(id) != null;

  /// Mecânicas declaradas PELA CLASSE, sem as das subclasses dela.
  ///
  /// A separação importa: a ficha mostra as da classe sempre, e as da
  /// subclasse só depois de o jogador escolher o arquétipo.
  List<ClassMechanicEntry> forClass(String? classId) {
    if (classId == null || classId.isEmpty) return const [];

    return [
      for (final entry in _byClass[classId] ?? const <ClassMechanicEntry>[])
        if (entry.subclassId == null || entry.subclassId!.isEmpty) entry,
    ];
  }

  /// Mecânicas de uma subclasse.
  List<ClassMechanicEntry> forSubclass(String? subclassId) {
    if (subclassId == null || subclassId.isEmpty) return const [];
    return _bySubclass[subclassId] ?? const [];
  }

  /// Tudo o que uma linha de classe pode conceder, com ou sem subclasse.
  ///
  /// Inclui a classe E a subclasse de propósito: é o conjunto que o resolvedor
  /// precisa percorrer para uma linha de `classLevels`, e montá-lo aqui evita
  /// que ele junte as duas listas de novo em cada chamada.
  List<ClassMechanicEntry> forClassLine({
    required String classId,
    String? subclassId,
    String? baseClassId,
  }) {
    final result = <ClassMechanicEntry>[
      ...forClass(classId),
      // Variante de classe herda as mecânicas da classe-base, como herda as
      // subclasses e a lista de magias.
      if (baseClassId != null && baseClassId != classId)
        ...forClass(baseClassId),
      ...forSubclass(subclassId),
    ];

    result.sort(_byLevelThenName);

    return List<ClassMechanicEntry>.unmodifiable(result);
  }

  /// Acha a mecânica a partir de texto livre: id ou nome.
  ClassMechanicEntry? resolve(String? text) {
    if (text == null) return null;

    final direct = _byId[text.trim()];
    if (direct != null) return direct;

    final needle = ClassMechanicEntry.normalizeName(text);
    if (needle.isEmpty) return null;

    for (final entry in _byId.values) {
      if (ClassMechanicEntry.normalizeName(entry.name) == needle) return entry;
    }

    return null;
  }

  /// Acha a opção referida por `mecanica_id:option_id` ou por `option_id`
  /// dentro de [withinMechanicId].
  ///
  /// É o que permite um pré-requisito citar outra opção sem a regra conhecer a
  /// estrutura do catálogo.
  MechanicOption? resolveOption(String reference, {String? withinMechanicId}) {
    final text = reference.trim();
    if (text.isEmpty) return null;

    final separator = text.indexOf(':');
    if (separator > 0) {
      final mechanicId = text.substring(0, separator).trim();
      final optionId = text.substring(separator + 1).trim();
      return byId(mechanicId)?.optionById(optionId);
    }

    return byId(withinMechanicId)?.optionById(text);
  }

  /// Nome a exibir para uma referência de opção, com o id como último recurso.
  ///
  /// Mostrar o id cru é ruim, mas é melhor que esconder a exigência: catálogo
  /// incompleto é defeito de dado, não motivo para a tela mentir que a opção
  /// está disponível.
  String optionLabel(String reference, {String? withinMechanicId}) {
    final option = resolveOption(reference, withinMechanicId: withinMechanicId);
    if (option != null) return option.name;

    final separator = reference.indexOf(':');
    return separator > 0 ? reference.substring(separator + 1) : reference;
  }
}
