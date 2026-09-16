import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/features/compendium/data/repositories/compendium_repository_impl.dart';
import 'package:dnd_ficha_app/features/compendium/data/sources/srd_asset_source.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Variante de classe: mesma classe, outra lista de características.
///
/// O que motivou isso: o Patrulheiro Revisado é o patrulheiro com as opções de
/// Tasha, e precisa oferecer as MESMAS subclasses. Duplicar as nove entradas do
/// asset seria conteúdo repetido para manter em dois lugares, então a
/// expansão acontece na leitura — e é justamente por ser invisível que ela
/// precisa de teste.
class _FakeSource extends SrdAssetSource {
  _FakeSource(this.files);

  final Map<String, List<Map<String, dynamic>>> files;

  @override
  Future<List<Map<String, dynamic>>> loadJsonList(String path) async {
    final rows = files[path];
    if (rows == null) throw Exception('asset não esperado no teste: $path');
    return rows;
  }
}

/// Lê os assets do disco, para exercitar o repositório de verdade.
///
/// O `SrdAssetSource` normal usa `rootBundle`, que não existe num teste de
/// unidade; trocar só a leitura deixa o resto do caminho igual ao do app.
class _DiskSource extends SrdAssetSource {
  @override
  Future<List<Map<String, dynamic>>> loadJsonList(String path) async {
    final decoded = jsonDecode(File(path).readAsStringSync()) as List<dynamic>;

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }
}

void main() {
  const classesPath = 'assets/data/srd/classes.json';
  const subclassesPath = 'assets/data/srd/subclasses.json';

  Map<String, dynamic> classRow(String id, {String? variantOf}) {
    return {
      'id': id,
      'name': id,
      'hit_die': 'd10',
      'subclass_level': 3,
      'subclass_label': 'Arquétipo',
      if (variantOf != null) 'variant_of': variantOf,
    };
  }

  Map<String, dynamic> subclassRow(String id, String classId) {
    return {
      'id': id,
      'class_id': classId,
      'name': 'Subclasse $id',
      'source': 'phb',
      'description': 'Descrição de $id',
      'features': [
        {'level': 3, 'name': 'Recurso', 'description': 'Faz algo.'},
      ],
      'spells': [
        {'level': 3, 'names': ['Hunter\'s Mark']},
      ],
      'tags': ['teste'],
    };
  }

  CompendiumRepositoryImpl repositoryWith({
    required List<Map<String, dynamic>> classes,
    required List<Map<String, dynamic>> subclasses,
  }) {
    return CompendiumRepositoryImpl(
      _FakeSource({classesPath: classes, subclassesPath: subclasses}),
    );
  }

  group('expansão de subclasse para variante', () {
    test('a variante recebe as subclasses da classe-base', () async {
      final repository = repositoryWith(
        classes: [classRow('ranger'), classRow('ranger_x', variantOf: 'ranger')],
        subclasses: [
          subclassRow('ranger_hunter', 'ranger'),
          subclassRow('ranger_beast_master', 'ranger'),
        ],
      );

      final all = await repository.loadSubclasses();
      final forVariant = all.where((item) => item.classId == 'ranger_x');

      expect(
        forVariant.map((item) => item.id),
        containsAll(['ranger_hunter', 'ranger_beast_master']),
      );
    });

    test('a classe-base continua com as subclasses dela', () async {
      // A expansão acrescenta, não move: o patrulheiro comum não pode perder
      // as próprias subclasses por causa da variante.
      final repository = repositoryWith(
        classes: [classRow('ranger'), classRow('ranger_x', variantOf: 'ranger')],
        subclasses: [subclassRow('ranger_hunter', 'ranger')],
      );

      final all = await repository.loadSubclasses();

      expect(
        all.where((item) => item.classId == 'ranger').map((item) => item.id),
        ['ranger_hunter'],
      );
      expect(all, hasLength(2));
    });

    test('a cópia mantém nome, descrição, características e magias', () async {
      final repository = repositoryWith(
        classes: [classRow('ranger'), classRow('ranger_x', variantOf: 'ranger')],
        subclasses: [subclassRow('ranger_hunter', 'ranger')],
      );

      final all = await repository.loadSubclasses();
      final original = all.firstWhere((item) => item.classId == 'ranger');
      final copy = all.firstWhere((item) => item.classId == 'ranger_x');

      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.source, original.source);
      expect(copy.description, original.description);
      expect(copy.tags, original.tags);
      expect(copy.features.single.name, original.features.single.name);
      expect(copy.spells.single.spellNames, original.spells.single.spellNames);
    });

    test('classe sem variante nenhuma não muda a lista', () async {
      final repository = repositoryWith(
        classes: [classRow('ranger'), classRow('rogue')],
        subclasses: [
          subclassRow('ranger_hunter', 'ranger'),
          subclassRow('rogue_thief', 'rogue'),
        ],
      );

      final all = await repository.loadSubclasses();

      expect(all, hasLength(2));
      expect(
        all.map((item) => item.classId),
        containsAll(['ranger', 'rogue']),
      );
    });

    test('variante apontando para si mesma é ignorada', () async {
      // Erro de digitação no asset não pode virar entrada duplicada.
      final repository = repositoryWith(
        classes: [classRow('ranger', variantOf: 'ranger')],
        subclasses: [subclassRow('ranger_hunter', 'ranger')],
      );

      final all = await repository.loadSubclasses();

      expect(all, hasLength(1));
    });

    test('variante de classe sem subclasse não acrescenta nada', () async {
      final repository = repositoryWith(
        classes: [
          classRow('barbarian'),
          classRow('barbarian_x', variantOf: 'barbarian'),
        ],
        subclasses: [subclassRow('ranger_hunter', 'ranger')],
      );

      final all = await repository.loadSubclasses();

      expect(all, hasLength(1));
      expect(all.single.classId, 'ranger');
    });

    test('a variante herda os campos de classe que declarou', () async {
      final repository = repositoryWith(
        classes: [classRow('ranger'), classRow('ranger_x', variantOf: 'ranger')],
        subclasses: const [],
      );

      final classes = await repository.loadClasses();
      final variant = classes.firstWhere((item) => item.id == 'ranger_x');

      expect(variant.variantOf, 'ranger');
      expect(variant.isVariant, isTrue);
      expect(variant.baseClassId, 'ranger');
    });
  });

  group('ClassEntry.baseClassId', () {
    test('classe comum é a própria base', () {
      const entry = ClassEntry(
        id: 'ranger',
        name: 'Patrulheiro',
        hitDie: 'd10',
        source: 'srd',
        skillOptions: [],
        savingThrows: [],
      );

      expect(entry.baseClassId, 'ranger');
      expect(entry.isVariant, isFalse);
    });
  });

  group('SubclassEntry.forClass', () {
    const subclass = SubclassEntry(
      id: 'ranger_hunter',
      classId: 'ranger',
      name: 'Caçador',
      source: 'phb',
    );

    test('devolve a mesma instância quando a classe não muda', () {
      expect(subclass.forClass('ranger'), same(subclass));
    });

    test('troca só o classId', () {
      final moved = subclass.forClass('ranger_tcoe');

      expect(moved.classId, 'ranger_tcoe');
      expect(moved.id, 'ranger_hunter');
      expect(moved.name, 'Caçador');
    });
  });

  group('asset: declaração de variante', () {
    List<Map<String, dynamic>> readList(String path) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'asset não encontrado: $path');

      return (jsonDecode(file.readAsStringSync()) as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
    }

    late List<Map<String, dynamic>> classes;
    late List<Map<String, dynamic>> subclasses;

    setUpAll(() {
      classes = readList(classesPath);
      subclasses = readList(subclassesPath);
    });

    test('variant_of aponta para uma classe existente e não para si mesma', () {
      final ids = classes.map((item) => item['id'] as String).toSet();

      for (final item in classes) {
        final base = item['variant_of'];
        if (base == null) continue;

        expect(base, isA<String>(), reason: '${item['id']} com variant_of ruim');
        expect(
          ids,
          contains(base),
          reason: '${item['id']} aponta para classe inexistente: $base',
        );
        expect(
          base,
          isNot(item['id']),
          reason: '${item['id']} aponta para si mesma',
        );
      }
    });

    test('a classe-base de uma variante não é ela mesma uma variante', () {
      // A expansão resolve um nível só. Uma corrente ficaria pela metade em
      // silêncio, e a variante do fim não receberia subclasse nenhuma.
      final variantOfById = {
        for (final item in classes)
          item['id'] as String: item['variant_of'] as String?,
      };

      for (final entry in variantOfById.entries) {
        final base = entry.value;
        if (base == null) continue;

        expect(
          variantOfById[base],
          isNull,
          reason: '${entry.key} herda de $base, que também é variante',
        );
      }
    });

    test('a classe-base de uma variante tem subclasses para emprestar', () {
      for (final item in classes) {
        final base = item['variant_of'];
        if (base == null) continue;

        expect(
          subclasses.where((sub) => sub['class_id'] == base),
          isNotEmpty,
          reason: '${item['id']} herda de $base, que não tem subclasse',
        );
      }
    });

    test('o Patrulheiro Revisado existe e herda do Patrulheiro', () {
      final variant = classes.firstWhere(
        (item) => item['id'] == 'ranger_tcoe',
        orElse: () => <String, dynamic>{},
      );

      expect(variant, isNotEmpty, reason: 'ranger_tcoe não está em classes.json');
      expect(variant['variant_of'], 'ranger');

      // Meio-conjurador de Sabedoria e escolha de arquétipo no 3º nível, igual
      // ao patrulheiro: é o que faz as subclasses emprestadas continuarem
      // válidas nos níveis 3, 7, 11 e 15.
      expect(variant['spellcasting_type'], 'half');
      expect(variant['spellcasting_ability'], 'wisdom');
      expect(variant['subclass_level'], 3);
      expect(variant['hit_die'], 'd10');
    });

    test('com os assets reais, as subclasses das duas são as mesmas', () async {
      // É a exigência de verdade: o Patrulheiro Revisado tem que oferecer
      // exatamente os arquétipos do Patrulheiro, nem um a mais nem a menos.
      final repository = CompendiumRepositoryImpl(_DiskSource());
      final all = await repository.loadSubclasses();

      Set<String> idsFor(String classId) => all
          .where((item) => item.classId == classId)
          .map((item) => item.id)
          .toSet();

      final base = idsFor('ranger');

      expect(base, isNotEmpty, reason: 'o patrulheiro perdeu as subclasses');
      expect(idsFor('ranger_tcoe'), base);
    });

    test('a expansão não mexe nas subclasses das outras classes', () async {
      final repository = CompendiumRepositoryImpl(_DiskSource());
      final all = await repository.loadSubclasses();

      final declaredIds = subclasses
          .map((item) => '${item['class_id']}/${item['id']}')
          .toSet();
      final expandedIds = all.map((item) => '${item.classId}/${item.id}').toSet();

      // Tudo que o asset declara continua lá, e o que sobra é só da variante.
      expect(expandedIds, containsAll(declaredIds));

      final extra = expandedIds.difference(declaredIds);
      expect(
        extra.every((item) => item.startsWith('ranger_tcoe/')),
        isTrue,
        reason: 'a expansão criou entrada inesperada: $extra',
      );
    });
  });
}
