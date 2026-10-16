import 'dart:convert';
import 'dart:io';

import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_class_mechanic.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_selection.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_ability_bonuses.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_mechanic_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/class_mechanic_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// As duas correções do Bárbaro, contra o CONTEÚDO REAL do compêndio.
///
/// Usa o asset de verdade de propósito, e não catálogo sintético: o que estava
/// errado era o dado e a sua ligação com o motor, não a regra genérica. Um
/// teste sintético passaria com o asset vazio.
///
/// 1. Espírito Totêmico, a escolha obrigatória do 3º nível do Guerreiro
///    Totêmico, que não era apresentada.
/// 2. Campeão Primal, o +4 em Força e Constituição do 20º nível, que estava
///    declarado no asset mas nunca era aplicado.
void main() {
  late List<ClassEntry> classes;
  late List<SubclassEntry> subclasses;
  late List<ClassFeatureEntry> classFeatures;
  late ClassMechanicCatalog catalog;

  const totemId = 'barbarian_totem_warrior.totem_spirit';
  const beastAspectId = 'barbarian_totem_warrior.beast_aspect';
  const attunementId = 'barbarian_totem_warrior.totemic_attunement';
  const totemSubclass = 'barbarian_totem_warrior';

  List<Map<String, dynamic>> readList(String path) {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'asset não encontrado: $path');

    return (jsonDecode(file.readAsStringSync()) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  setUpAll(() {
    // Lê o asset de verdade pelos mesmos construtores que o app usa, como
    // `test/feature_effects_asset_test.dart`.
    classes = [
      for (final item in readList('assets/data/srd/classes.json'))
        ClassEntry(
          id: item['id'] as String,
          name: item['name'] as String,
          hitDie: item['hit_die'] as String? ?? 'd8',
          source: item['source'] as String? ?? 'srd',
          skillOptions: const [],
          savingThrows: const [],
          subclassLevel: item['subclass_level'] as int?,
          subclassLabel: item['subclass_label'] as String?,
        ),
    ];

    subclasses = [
      for (final item in readList('assets/data/srd/subclasses.json'))
        SubclassEntry(
          id: item['id'] as String,
          classId: item['class_id'] as String,
          name: item['name'] as String,
          source: item['source'] as String? ?? 'srd',
          features: [
            for (final raw in (item['features'] as List<dynamic>?) ?? const [])
              SubclassFeature(
                level: (raw as Map)['level'] as int? ?? 1,
                name: raw['name'] as String? ?? '',
                description: raw['description'] as String? ?? '',
                effects: FeatureEffect.parseList(raw['effects']),
                choice: FeatureChoice.tryParse(raw['choice']),
              ),
          ],
        ),
    ];

    classFeatures = [
      for (final item in readList('assets/data/srd/class_features.json'))
        ClassFeatureEntry(
          classId: item['class_id'] as String,
          level: item['level'] as int,
          source: item['source'] as String? ?? 'srd',
          features: [
            for (final raw in item['features'] as List<dynamic>)
              if (ClassFeature.tryParse(raw) case final feature?) feature,
          ],
        ),
    ];

    catalog = ClassMechanicCatalog.from([
      for (final item in readList('assets/data/srd/class_mechanics.json'))
        if (ClassMechanicEntry.tryParse(item) case final entry?) entry,
    ]);
  });

  /// Ids das opções que a mecânica tem como escolhidas e válidas.
  List<String> selectedIds(ResolvedClassMechanic mechanic) =>
      mechanic.selected.map((item) => item.option.id).toList(growable: false);

  /// Bárbaro com [level] níveis, opcionalmente com a subclasse e as escolhas.
  Character barbarian({
    required int level,
    String? subclassId,
    List<CharacterClassMechanic> mechanics = const [],
    Map<Ability, int> featureAbilityBonuses = const {},
    int strength = 10,
    int constitution = 10,
  }) {
    return characterFixture(
      classLevels: [
        ClassLevel(classId: 'barbarian', level: level, subclassId: subclassId),
      ],
      abilityScores: scoresWith(strength: strength, constitution: constitution),
      classMechanics: mechanics,
      featureAbilityBonuses: featureAbilityBonuses,
    );
  }

  ResolvedClassMechanics resolveMechanics(Character character) {
    return ClassMechanicResolver.resolve(
      character: character,
      catalog: catalog,
      classes: classes,
      subclasses: subclasses,
    );
  }

  ResolvedFeatures resolveFeatures(Character character) {
    return SpecialFeatureResolver.resolve(
      character: character,
      classes: classes,
      classFeatures: classFeatures,
      subclasses: subclasses,
    );
  }

  /// O que a reconciliação faria com este personagem agora.
  ///
  /// Reproduz exatamente o que `featureAbilityBonusResolverProvider` monta, só
  /// sem Riverpod: resolve as características, lê os aumentos e os tetos, e
  /// aplica.
  Character reconcile(Character character) {
    final features = resolveFeatures(character);
    final context = FeatureFormulaContext.fromCharacter(character);

    return FeatureAbilityBonuses.reconcile(
      character: character,
      granted: features.abilityBonuses(context),
      maximums: features.abilityMaximums(context),
    );
  }

  CharacterClassMechanic pick(String mechanicId, String optionId, int level) {
    return CharacterClassMechanic(
      mechanicId: mechanicId,
      optionId: optionId,
      chosenAtLevel: level,
    );
  }

  group('1. escolha do totem no 3º nível', () {
    test('1. Bárbaro de 2º nível não recebe escolha de totem', () {
      final resolved = resolveMechanics(barbarian(level: 2));

      expect(
        resolved.byId(totemId),
        isNull,
        reason: 'sem subclasse no 2º nível não há mecânica de subclasse',
      );
      expect(resolved.blocking, isEmpty);
      expect(resolved.blockingReason, isNull);
    });

    test('1b. Totêmico de 2º nível ainda não libera a escolha', () {
      // Cenário de ficha editada à mão: a subclasse aparece antes do nível.
      // O corte é pelo nível NA CLASSE, então a mecânica continua bloqueada.
      final resolved = resolveMechanics(
        barbarian(level: 2, subclassId: totemSubclass),
      );

      final totem = resolved.byId(totemId);
      expect(totem, isNotNull);
      expect(totem!.isUnlocked, isFalse);
      expect(totem.blocksCompletion, isFalse);
      expect(totem.isVisible, isFalse);
    });

    test('2. Totêmico de 3º nível recebe a escolha obrigatória', () {
      final resolved = resolveMechanics(
        barbarian(level: 3, subclassId: totemSubclass),
      );

      final totem = resolved.byId(totemId);
      expect(totem, isNotNull);
      expect(totem!.isUnlocked, isTrue);
      expect(totem.isVisible, isTrue);
      expect(totem.limit, 1);
      expect(totem.freeSlots, 1);
      expect(totem.hasPendingPicks, isTrue);
      expect(totem.blocksCompletion, isTrue);

      // A escolha é oferecida com as cinco opções oficiais, todas acessíveis.
      expect(totem.options, hasLength(5));
      expect(
        totem.options.map((item) => item.option.id),
        containsAll(['bear', 'eagle', 'wolf', 'elk', 'tiger']),
      );
      for (final option in totem.options) {
        expect(
          option.availability,
          MechanicOptionAvailability.available,
          reason: '${option.option.id} deveria estar disponível no 3º nível',
        );
        expect(option.option.summary, isNotNull);
        expect(option.option.description, isNotNull);
      }
    });

    test(
      '2b. o registro aponta para classe, subclasse, característica e nível',
      () {
        final entry = catalog.byId(totemId);

        expect(entry, isNotNull);
        expect(entry!.classId, 'barbarian');
        expect(entry.subclassId, totemSubclass);
        expect(entry.featureName, 'Espírito Totêmico');
        expect(entry.level, 3);
        expect(entry.edition, '2014');
        expect(entry.source, 'phb');
        expect(entry.isRequired, isTrue);
        expect(entry.id, totemId, reason: 'id estável, não nome traduzido');

        // Nome traduzido e original convivem, e o id da opção é o estável.
        final bear = entry.optionById('bear');
        expect(bear, isNotNull);
        expect(bear!.name, 'Urso');
        expect(bear.nameOriginal, 'Bear');
      },
    );

    test('3. não é possível concluir sem selecionar o totem', () {
      final pending = resolveMechanics(
        barbarian(level: 3, subclassId: totemSubclass),
      );

      expect(pending.hasBlocking, isTrue);
      expect(pending.blocking.map((item) => item.id), [totemId]);
      expect(
        pending.blockingReason,
        'Escolha obrigatória em aberto: Espírito Totêmico.',
      );

      // Escolhido, deixa de bloquear.
      final resolved = resolveMechanics(
        barbarian(
          level: 3,
          subclassId: totemSubclass,
          mechanics: [pick(totemId, 'bear', 3)],
        ),
      );

      expect(resolved.hasBlocking, isFalse);
      expect(resolved.blockingReason, isNull);
      expect(resolved.byId(totemId)!.hasPendingPicks, isFalse);
    });

    test('3b. a seleção passa pelo serviço e grava o nível da escolha', () {
      final character = barbarian(level: 3, subclassId: totemSubclass);
      final mechanic = resolveMechanics(character).byId(totemId)!;

      final outcome = ClassMechanicSelection.select(
        character: character,
        mechanic: mechanic,
        optionId: 'elk',
      );

      expect(outcome.changed, isTrue);
      expect(outcome.error, isNull);

      final saved = outcome.character.classMechanicsFor(totemId);
      expect(saved, hasLength(1));
      expect(saved.single.optionId, 'elk');
      expect(saved.single.isSelected, isTrue);
      expect(
        saved.single.chosenAtLevel,
        3,
        reason: 'o nível gravado é o da classe, não o total',
      );
    });

    test('4. a escolha sobrevevive a fechar e abrir o aplicativo', () {
      // Fechar e abrir é reler o personagem do banco. O que o teste garante é
      // que o estado salvo basta: resolver de novo, sem nenhum contexto de
      // sessão, devolve a escolha feita e nenhuma pendência.
      final reopened = barbarian(
        level: 3,
        subclassId: totemSubclass,
        mechanics: [pick(totemId, 'wolf', 3)],
      );

      final totem = resolveMechanics(reopened).byId(totemId)!;

      expect(selectedIds(totem), ['wolf']);
      expect(totem.hasPendingPicks, isFalse);
      expect(totem.blocksCompletion, isFalse);
      expect(totem.freeSlots, 0);
    });

    test('5. a escolha não é duplicada ao editar o personagem', () {
      final character = barbarian(
        level: 3,
        subclassId: totemSubclass,
        mechanics: [pick(totemId, 'bear', 3)],
      );

      final mechanic = resolveMechanics(character).byId(totemId)!;

      // Escolher a mesma opção de novo não cria um segundo registro.
      final again = ClassMechanicSelection.select(
        character: character,
        mechanic: mechanic,
        optionId: 'bear',
      );

      expect(again.changed, isFalse);
      expect(again.character.classMechanicsFor(totemId), hasLength(1));

      // E uma segunda opção não entra sem vaga: o limite do 3º nível é 1.
      final other = ClassMechanicSelection.select(
        character: character,
        mechanic: mechanic,
        optionId: 'eagle',
      );

      expect(other.changed, isFalse);
      expect(other.error, isNotNull);
      expect(other.character.classMechanicsFor(totemId), hasLength(1));
    });

    test('6. trocar de subclasse desativa o efeito e preserva o registro', () {
      final chosen = barbarian(
        level: 3,
        subclassId: totemSubclass,
        mechanics: [pick(totemId, 'bear', 3)],
      );

      final switched = chosen.copyWith(
        classLevels: const [
          ClassLevel(
            classId: 'barbarian',
            level: 3,
            subclassId: 'barbarian_berserker',
          ),
        ],
      );

      final resolved = resolveMechanics(switched);

      expect(
        resolved.byId(totemId),
        isNull,
        reason: 'a mecânica é derivada da subclasse, então deixa de valer',
      );
      expect(resolved.hasBlocking, isFalse);
      expect(
        switched.classMechanicsFor(totemId),
        hasLength(1),
        reason: 'o histórico fica: nada é apagado em silêncio',
      );
    });

    test('7. reduzir para o 2º nível desativa o efeito', () {
      final chosen = barbarian(
        level: 3,
        subclassId: totemSubclass,
        mechanics: [pick(totemId, 'tiger', 3)],
      );

      final demoted = chosen.copyWith(
        classLevels: const [
          ClassLevel(classId: 'barbarian', level: 2, subclassId: totemSubclass),
        ],
      );

      final totem = resolveMechanics(demoted).byId(totemId)!;

      expect(totem.isUnlocked, isFalse);
      expect(totem.isVisible, isFalse);
      expect(totem.blocksCompletion, isFalse);
      expect(totem.limit, 0);
      expect(
        demoted.classMechanicsFor(totemId),
        hasLength(1),
        reason: 'a escolha continua gravada para voltar se o nível voltar',
      );
    });

    test('7b. voltar ao 3º nível restaura a escolha anterior', () {
      final restored = barbarian(
        level: 3,
        subclassId: totemSubclass,
        mechanics: [pick(totemId, 'tiger', 3)],
      );

      final totem = resolveMechanics(restored).byId(totemId)!;

      expect(selectedIds(totem), ['tiger']);
      expect(totem.hasPendingPicks, isFalse);
      expect(
        totem.invalid,
        isEmpty,
        reason: 'a opção continua válida, então não é preciso escolher de novo',
      );
    });

    test(
      '8. os recursos totêmicos dos níveis 6 e 14 continuam funcionando',
      () {
        // Regressão: o 3º nível entrou como mecânica nova, e as duas que já
        // existiam não podem ter mudado de limite, de opções nem de progressão.
        final resolved = resolveMechanics(
          barbarian(
            level: 14,
            subclassId: totemSubclass,
            mechanics: [
              pick(totemId, 'bear', 3),
              pick(beastAspectId, 'eagle', 6),
              pick(attunementId, 'wolf', 14),
            ],
          ),
        );

        for (final id in [totemId, beastAspectId, attunementId]) {
          final mechanic = resolved.byId(id);
          expect(mechanic, isNotNull, reason: '$id deveria estar resolvida');
          expect(mechanic!.isUnlocked, isTrue);
          expect(mechanic.limit, 1, reason: 'cada nível concede uma escolha');
          expect(mechanic.freeSlots, 0);
          expect(mechanic.options, hasLength(5));
        }

        expect(selectedIds(resolved.byId(totemId)!), ['bear']);
        expect(selectedIds(resolved.byId(beastAspectId)!), ['eagle']);
        expect(selectedIds(resolved.byId(attunementId)!), ['wolf']);

        expect(
          resolved.hasPending,
          isFalse,
          reason: 'as três escolhas estão feitas',
        );
      },
    );

    test('8b. as escolhas dos três níveis são independentes entre si', () {
      final resolved = resolveMechanics(
        barbarian(
          level: 14,
          subclassId: totemSubclass,
          mechanics: [pick(totemId, 'bear', 3)],
        ),
      );

      // Escolher o Urso no 3º não preenche nem restringe o 6º e o 14º.
      expect(resolved.byId(beastAspectId)!.freeSlots, 1);
      expect(resolved.byId(attunementId)!.freeSlots, 1);
      expect(resolved.byId(totemId)!.freeSlots, 0);

      // E só o 3º é obrigatório: os outros dois continuam adiáveis, como antes.
      expect(resolved.pending.map((item) => item.id), [
        beastAspectId,
        attunementId,
      ]);
      expect(resolved.blocking, isEmpty);
    });

    test('8c. repetir o mesmo animal em outro nível é permitido', () {
      final character = barbarian(
        level: 6,
        subclassId: totemSubclass,
        mechanics: [pick(totemId, 'bear', 3)],
      );

      final beastAspect = resolveMechanics(character).byId(beastAspectId)!;

      final outcome = ClassMechanicSelection.select(
        character: character,
        mechanic: beastAspect,
        optionId: 'bear',
      );

      expect(outcome.changed, isTrue);
      expect(outcome.character.classMechanicsFor(beastAspectId), hasLength(1));
      expect(
        outcome.character.classMechanicsFor(totemId),
        hasLength(1),
        reason: 'a escolha do 3º nível fica intacta',
      );
    });
  });

  group('2. Campeão Primal no 20º nível', () {
    test('9. Bárbaro de 19º nível não recebe os bônus', () {
      final character = barbarian(level: 19, strength: 18, constitution: 16);
      final updated = reconcile(character);

      expect(identical(updated, character), isTrue);
      expect(updated.abilityScores.strength, 18);
      expect(updated.abilityScores.constitution, 16);
      expect(updated.featureAbilityBonuses, isEmpty);
    });

    test(
      '10. Bárbaro de 20º nível recebe +4 em Força e +4 em Constituição',
      () {
        final updated = reconcile(
          barbarian(level: 20, strength: 18, constitution: 16),
        );

        expect(updated.abilityScores.strength, 22, reason: '18 + 4');
        expect(updated.abilityScores.constitution, 20, reason: '16 + 4');
        expect(updated.featureAbilityBonuses, {
          Ability.strength: 4,
          Ability.constitution: 4,
        });

        // Só os dois atributos declarados.
        expect(updated.abilityScores.dexterity, 10);
        expect(updated.abilityScores.intelligence, 10);
        expect(updated.abilityScores.wisdom, 10);
        expect(updated.abilityScores.charisma, 10);
      },
    );

    test('11. o limite desses atributos passa para 24', () {
      final character = barbarian(level: 20, strength: 20, constitution: 20);
      final features = resolveFeatures(character);
      final context = FeatureFormulaContext.fromCharacter(character);
      final maximums = features.abilityMaximums(context);

      expect(maximums[Ability.strength], 24);
      expect(maximums[Ability.constitution], 24);
      expect(features.maximumFor(Ability.strength, context), 24);
      expect(
        features.maximumFor(Ability.dexterity, context),
        20,
        reason: 'os outros quatro continuam no 20 da regra',
      );

      // E o aumento usa o teto novo: 20 vira 24, não para em 20.
      final updated = reconcile(character);
      expect(updated.abilityScores.strength, 24);
      expect(updated.abilityScores.constitution, 24);
    });

    test('11b. o aumento não passa do teto de 24', () {
      // Quem já estava em 22 por outra fonte recebe só o que cabe, e o valor
      // aplicado fica registrado para a remoção devolver exatamente isso.
      final updated = reconcile(
        barbarian(level: 20, strength: 22, constitution: 24),
      );

      expect(updated.abilityScores.strength, 24);
      expect(
        updated.abilityScores.constitution,
        24,
        reason: 'já estava no teto: não sobe e também não é reduzido',
      );
      expect(updated.featureAbilityBonuses[Ability.strength], 2);
      expect(updated.featureAbilityBonuses[Ability.constitution], isNull);
    });

    test(
      '12. multiclasse com nível total 20 e Bárbaro abaixo de 20 não recebe',
      () {
        final character = characterFixture(
          classLevels: const [
            ClassLevel(classId: 'barbarian', level: 19),
            ClassLevel(classId: 'fighter', level: 1),
          ],
          abilityScores: scoresWith(strength: 18, constitution: 16),
        );

        expect(character.totalLevel, 20);

        final updated = reconcile(character);

        expect(identical(updated, character), isTrue);
        expect(updated.abilityScores.strength, 18);
        expect(updated.abilityScores.constitution, 16);
        expect(updated.featureAbilityBonuses, isEmpty);
      },
    );

    test('12b. o 20º nível DE BÁRBARO vale mesmo em multiclasse', () {
      // O contrário do caso acima, para o teste não passar por acidente ao
      // nunca aplicar nada em multiclasse. Aqui a classe está no 20º.
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'barbarian', level: 20)],
        abilityScores: scoresWith(strength: 15, constitution: 14),
      );

      final updated = reconcile(character);

      expect(updated.abilityScores.strength, 19);
      expect(updated.abilityScores.constitution, 18);
    });

    test('13. o bônus não é aplicado mais de uma vez', () {
      var character = barbarian(level: 20, strength: 18, constitution: 16);

      character = reconcile(character);
      expect(character.abilityScores.strength, 22);

      // Reconciliar de novo é o que acontece a cada abertura da ficha.
      for (var i = 0; i < 5; i++) {
        final again = reconcile(character);
        expect(
          identical(again, character),
          isTrue,
          reason: 'sem mudança, nem o objeto é recriado — e nada é gravado',
        );
        character = again;
      }

      expect(character.abilityScores.strength, 22);
      expect(character.abilityScores.constitution, 20);
      expect(character.featureAbilityBonuses, {
        Ability.strength: 4,
        Ability.constitution: 4,
      });
    });

    test('14. cair do 20º para o 19º remove somente esse bônus', () {
      final atTwenty = reconcile(
        barbarian(level: 20, strength: 18, constitution: 16),
      );

      expect(atTwenty.abilityScores.strength, 22);

      final demoted = reconcile(
        atTwenty.copyWith(
          classLevels: const [ClassLevel(classId: 'barbarian', level: 19)],
        ),
      );

      expect(demoted.abilityScores.strength, 18, reason: 'volta ao original');
      expect(demoted.abilityScores.constitution, 16);
      expect(demoted.featureAbilityBonuses, isEmpty);

      // O teto também volta ao normal.
      final features = resolveFeatures(demoted);
      final context = FeatureFormulaContext.fromCharacter(demoted);
      expect(features.maximumFor(Ability.strength, context), 20);

      // E alternar 19 ↔ 20 aplica e remove só esta contribuição.
      final again = reconcile(
        demoted.copyWith(
          classLevels: const [ClassLevel(classId: 'barbarian', level: 20)],
        ),
      );
      expect(again.abilityScores.strength, 22);
      expect(again.abilityScores.constitution, 20);
    });

    test('14b. remover preserva o que veio de outras fontes', () {
      // Simula um aumento vindo de fora: o total já está acima da base, e o
      // registro da característica guarda só o que ela aplicou.
      final atTwenty = reconcile(
        barbarian(level: 20, strength: 16, constitution: 12),
      );

      // Outra fonte soma +2 em Força depois, direto no total.
      final boosted = atTwenty.copyWith(
        abilityScores: atTwenty.abilityScores.withValue(Ability.strength, 22),
      );

      final demoted = reconcile(
        boosted.copyWith(
          classLevels: const [ClassLevel(classId: 'barbarian', level: 19)],
        ),
      );

      expect(
        demoted.abilityScores.strength,
        18,
        reason: '22 menos os 4 da característica: os +2 de fora ficam',
      );
      expect(demoted.abilityScores.constitution, 12);
      expect(demoted.featureAbilityBonuses, isEmpty);
    });

    test('15. os valores derivados são recalculados', () {
      final before = barbarian(level: 20, strength: 18, constitution: 16);
      final after = reconcile(before);

      int dieSize(String classId) => 12;

      final hpBefore = HitPointsCalculator.maxHitPoints(
        classLevels: before.classLevels,
        abilityScores: before.abilityScores,
        dieSizeForClass: dieSize,
      );
      final hpAfter = HitPointsCalculator.maxHitPoints(
        classLevels: after.classLevels,
        abilityScores: after.abilityScores,
        dieSizeForClass: dieSize,
      );

      // Constituição 16 → 20 é modificador +3 → +5, e isso vale 2 por nível.
      expect(after.abilityScores.constitution.abilityModifier, 5);
      expect(
        hpAfter - hpBefore,
        40,
        reason: '2 pontos a mais por cada um dos 20 níveis',
      );

      // Modificador de Força também sobe, e é dele que saem ataque, dano,
      // resistência, perícia e capacidade de carga.
      expect(before.abilityScores.strength.abilityModifier, 4);
      expect(after.abilityScores.strength.abilityModifier, 6);

      // Defesa sem Armadura do Bárbaro é 10 + DES + CON, então ela sobe junto.
      final features = resolveFeatures(after);
      final formula = features
          .forDisplay(FeatureDisplaySlot.armorClass)
          .expand((item) => item.calculatedEffects)
          .firstWhere((effect) => effect.id.startsWith('barbarian.'));

      expect(
        FeatureFormula.valueOf(
          formula.formula,
          FeatureFormulaContext.fromCharacter(after),
        ),
        15,
        reason: '10 + 0 de Destreza + 5 de Constituição',
      );
    });

    test(
      '15b. a subida de nível recalcula o PV já com a Constituição nova',
      () {
        // Garante a ORDEM dentro do caso de uso: se o PV fosse calculado antes
        // da reconciliação, o Bárbaro 20 ficaria com 40 pontos de vida a menos.
        final before = barbarian(level: 19, strength: 18, constitution: 16);

        final levelled = reconcile(
          before.copyWith(
            classLevels: const [ClassLevel(classId: 'barbarian', level: 20)],
          ),
        );

        final hp = HitPointsCalculator.maxHitPoints(
          classLevels: levelled.classLevels,
          abilityScores: levelled.abilityScores,
          dieSizeForClass: (_) => 12,
        );

        expect(levelled.abilityScores.constitution, 20);
        expect(
          hp,
          12 + 19 * 7 + 20 * 5,
          reason: 'd12 + média 7 + CON 5 por nível',
        );
      },
    );

    test('16. personagem antigo é migrado sem duplicidade', () {
      // Antes desta versão o app não aplicava o aumento e a coluna nova nasce
      // nula, então o personagem salvo chega com `featureAbilityBonuses` vazio.
      final legacy = barbarian(level: 20, strength: 18, constitution: 16);
      expect(legacy.featureAbilityBonuses, isEmpty);

      final firstOpen = reconcile(legacy);
      expect(firstOpen.abilityScores.strength, 22);
      expect(firstOpen.abilityScores.constitution, 20);

      final secondOpen = reconcile(firstOpen);
      expect(
        identical(secondOpen, firstOpen),
        isTrue,
        reason: 'a segunda abertura não grava nem soma de novo',
      );
      expect(secondOpen.abilityScores.strength, 22);
    });

    test('16b. quem já havia somado à mão não estoura o teto', () {
      // A observação antiga do asset mandava o jogador somar os aumentos na
      // tela de atributos. Esse personagem não pode virar 28 de Força.
      final manual = barbarian(level: 20, strength: 24, constitution: 24);

      final updated = reconcile(manual);

      expect(identical(updated, manual), isTrue);
      expect(updated.abilityScores.strength, 24);
      expect(updated.abilityScores.constitution, 24);
      expect(updated.featureAbilityBonuses, isEmpty);
    });

    test('16c. o registro sobrevive ao CSV do banco', () {
      final csv = FeatureAbilityBonuses.toCsv(const {
        Ability.strength: 4,
        Ability.constitution: 4,
      });

      expect(csv, 'strength:4,constitution:4');
      expect(FeatureAbilityBonuses.parseCsv(csv), {
        Ability.strength: 4,
        Ability.constitution: 4,
      });

      // Tolerante ao que vem de ficha editada à mão.
      expect(FeatureAbilityBonuses.toCsv(const {}), isNull);
      expect(FeatureAbilityBonuses.parseCsv(null), isEmpty);
      expect(FeatureAbilityBonuses.parseCsv(''), isEmpty);
      expect(FeatureAbilityBonuses.parseCsv('nonsense'), isEmpty);
      expect(FeatureAbilityBonuses.parseCsv('strength:x'), isEmpty);
      expect(FeatureAbilityBonuses.parseCsv('mana:4'), isEmpty);
      expect(FeatureAbilityBonuses.parseCsv(' strength : 4 '), {
        Ability.strength: 4,
      });
    });

    test('16d. o aumento entra na decomposição do total', () {
      // A ficha precisa saber qual parte do 22 de Força veio da característica,
      // senão a tela de atributos mostraria 22 como "valor base".
      final updated = reconcile(
        barbarian(level: 20, strength: 18, constitution: 16),
      );

      expect(updated.otherPermanentAbilityBonuses[Ability.strength], 4);
      expect(updated.otherPermanentAbilityBonuses[Ability.constitution], 4);
    });

    test('16e. o aumento não conta duas vezes quando o efeito repete', () {
      // Dedupe por id de efeito: a mesma declaração não pode somar duas vezes
      // se o resolvedor devolver a característica repetida.
      final character = barbarian(level: 20);
      final features = resolveFeatures(character);
      final context = FeatureFormulaContext.fromCharacter(character);

      final doubled = ResolvedFeatures(
        features: [...features.features, ...features.features],
      );

      expect(doubled.abilityBonuses(context), {
        Ability.strength: 4,
        Ability.constitution: 4,
      });
      expect(doubled.abilityMaximums(context), {
        Ability.strength: 24,
        Ability.constitution: 24,
      });
    });
  });

  group('integridade do asset do Bárbaro', () {
    test('as três mecânicas do Totêmico estão nos níveis certos', () {
      final totemMechanics = catalog.forSubclass(totemSubclass);

      expect(totemMechanics.map((item) => item.id), [
        totemId,
        beastAspectId,
        attunementId,
      ]);
      expect(totemMechanics.map((item) => item.level), [3, 6, 14]);
    });

    test('só a escolha do 3º nível é obrigatória', () {
      expect(catalog.byId(totemId)!.isRequired, isTrue);
      expect(catalog.byId(beastAspectId)!.isRequired, isFalse);
      expect(catalog.byId(attunementId)!.isRequired, isFalse);

      // E nenhuma outra mecânica do compêndio ficou obrigatória por descuido.
      final required = catalog.all
          .where((item) => item.isRequired)
          .map((item) => item.id)
          .toList(growable: false);

      expect(required, [totemId]);
    });

    test('os cinco espíritos não prometem bônus permanente', () {
      // Todos dependem da Fúria ativa, e o motor não modela estado de combate.
      // Declarar bônus calculado aqui poria número errado na ficha.
      final entry = catalog.byId(totemId)!;

      for (final option in entry.options) {
        for (final effect in option.effects) {
          expect(
            effect.isCalculated,
            isFalse,
            reason: '${option.id}: ${effect.path} viraria bônus permanente',
          );
          expect(
            effect.note,
            isNotNull,
            reason: '${option.id}: a condição precisa estar escrita',
          );
        }
      }
    });

    test('a característica do 20º nível diz o que faz', () {
      final level20 = classFeatures.firstWhere(
        (item) => item.classId == 'barbarian' && item.level == 20,
      );

      final feature = level20.features.single;
      expect(feature.name, 'Campeão Primal');
      expect(feature.description, contains('Força +4'));
      expect(feature.description, contains('Constituição +4'));
      expect(feature.description, contains('24'));

      final bonus = feature.effects.firstWhere(
        (effect) => effect.path == FeatureEffectPaths.abilityBonus,
      );
      expect(bonus.abilities, [Ability.strength, Ability.constitution]);
      expect(bonus.formula, '4');
      expect(bonus.isCalculated, isTrue);

      final maximum = feature.effects.firstWhere(
        (effect) => effect.path == FeatureEffectPaths.abilityMaximum,
      );
      expect(maximum.formula, '24');
      expect(maximum.abilities, [Ability.strength, Ability.constitution]);
    });
  });
}
