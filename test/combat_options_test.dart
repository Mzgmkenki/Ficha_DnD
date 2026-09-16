import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/casting_time_parser.dart';
import 'package:dnd_ficha_app/features/character/domain/services/combat_options_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/turn_possibilities.dart';
import 'package:dnd_ficha_app/features/character/domain/services/universal_combat_actions.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// A seção "Ações em combate".
///
/// O ponto que estes testes protegem é a fronteira: a tela recebe a lista já
/// resolvida, então qualquer regra errada aqui vira informação errada em mesa,
/// sem nada para avisar.
void main() {
  const fighter = ClassEntry(
    id: 'fighter',
    name: 'Guerreiro',
    hitDie: 'd10',
    source: 'srd',
    skillOptions: [],
    savingThrows: [],
  );

  const ranger = ClassEntry(
    id: 'ranger',
    name: 'Patrulheiro',
    hitDie: 'd10',
    source: 'srd',
    skillOptions: [],
    savingThrows: [],
  );

  /// Retomar o Fôlego: ação bônus, 1 uso, descanso curto.
  const secondWind = ClassFeatureEntry(
    classId: 'fighter',
    level: 1,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Retomar o Fôlego',
        description: 'Recupera 1d10 + nível.',
        action: FeatureAction(
          type: CombatActionType.bonusAction,
          uses: 1,
          recharge: ActionRecharge.shortRest,
        ),
      ),
    ],
  );

  const extraAttack = ClassFeatureEntry(
    classId: 'fighter',
    level: 5,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Ataque Extra',
        description: 'Dois ataques.',
        action: FeatureAction(
          type: CombatActionType.special,
          group: 'extra_attack',
          attacks: 2,
        ),
      ),
    ],
  );

  const extraAttackTwo = ClassFeatureEntry(
    classId: 'fighter',
    level: 11,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Ataque Extra (2)',
        description: 'Três ataques.',
        action: FeatureAction(
          type: CombatActionType.special,
          label: 'Ataque Extra',
          group: 'extra_attack',
          attacks: 3,
        ),
      ),
    ],
  );

  const rangerExtraAttack = ClassFeatureEntry(
    classId: 'ranger',
    level: 5,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Ataque Extra',
        description: 'Dois ataques.',
        action: FeatureAction(
          type: CombatActionType.special,
          group: 'extra_attack',
          attacks: 2,
        ),
      ),
    ],
  );

  const actionSurgeOne = ClassFeatureEntry(
    classId: 'fighter',
    level: 2,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Surto de Ação (1 uso)',
        description: 'Uma ação a mais.',
        action: FeatureAction(
          type: CombatActionType.special,
          label: 'Surto de Ação',
          group: 'fighter.action_surge',
          uses: 1,
          recharge: ActionRecharge.shortRest,
        ),
      ),
    ],
  );

  const actionSurgeTwo = ClassFeatureEntry(
    classId: 'fighter',
    level: 17,
    source: 'phb',
    features: [
      ClassFeature(
        name: 'Surto de Ação (2 usos)',
        description: 'Dois usos.',
        action: FeatureAction(
          type: CombatActionType.special,
          label: 'Surto de Ação',
          group: 'fighter.action_surge',
          uses: 2,
          recharge: ActionRecharge.shortRest,
        ),
      ),
    ],
  );

  /// Característica passiva: sem bloco `action`, não entra na lista.
  const passive = ClassFeatureEntry(
    classId: 'fighter',
    level: 1,
    source: 'phb',
    features: [
      ClassFeature(name: 'Estilo de Luta', description: 'Arquearia ou Defesa.'),
    ],
  );

  /// Usos derivados do bônus de proficiência.
  const naturesVeil = ClassFeatureEntry(
    classId: 'ranger',
    level: 10,
    source: 'tcoe',
    features: [
      ClassFeature(
        name: 'Véu da Natureza',
        description: 'Fica Invisível.',
        action: FeatureAction(
          type: CombatActionType.bonusAction,
          usesFormula: 'proficiency',
          recharge: ActionRecharge.longRest,
        ),
      ),
    ],
  );

  SpellEntry spell({
    required int id,
    required String name,
    required int level,
    required String castingTime,
    bool concentration = false,
  }) {
    return SpellEntry(
      id: id,
      namePt: name,
      nameOriginal: name,
      level: level,
      school: 'Evocação',
      castingTime: castingTime,
      range: '18 m',
      components: 'V S',
      hasCostlyMaterials: false,
      duration: '1 minuto',
      concentration: concentration,
      ritual: false,
      classes: const ['wizard'],
      subclasses: const [],
      description: '',
      source: 'phb',
      page: '',
      isSrd: true,
    );
  }

  CharacterSpell known(
    int id, {
    bool isPrepared = true,
    bool isKnown = true,
  }) {
    return CharacterSpell(
      spellId: id,
      sourceType: 'class',
      sourceId: 'wizard',
      sourceName: 'Mago',
      isPrepared: isPrepared,
      isKnown: isKnown,
      isAlwaysAvailable: false,
    );
  }

  group('CastingTimeParser', () {
    test('uma ação vira ação', () {
      final parsed = CastingTimeParser.parse('Uma ação');

      expect(parsed.actionType, CombatActionType.action);
      expect(parsed.fitsInATurn, isTrue);
    });

    test('ação bônus não é confundida com ação', () {
      // "Uma ação bônus" contém a palavra "ação": testar ação primeiro
      // classificaria toda ação bônus como ação.
      final parsed = CastingTimeParser.parse('Uma ação bônus');

      expect(parsed.actionType, CombatActionType.bonusAction);
    });

    test('reação traz o gatilho do próprio texto', () {
      final parsed = CastingTimeParser.parse(
        'Uma reação, que você executa quando é atingido por um ataque',
      );

      expect(parsed.actionType, CombatActionType.reaction);
      expect(parsed.trigger, startsWith('Que você executa quando'));
    });

    test('tempo longo não cabe no turno', () {
      for (final raw in const ['1 minuto', '10 minutos', 'Uma hora', '8 horas']) {
        final parsed = CastingTimeParser.parse(raw);
        expect(parsed.fitsInATurn, isFalse, reason: raw);
      }
    });

    test('tempo alternativo é registrado como observação', () {
      final parsed = CastingTimeParser.parse('Uma ação ou 8 horas');

      expect(parsed.actionType, CombatActionType.action);
      expect(parsed.note, contains('8 horas'));
    });

    test('vazio não vira ação nenhuma', () {
      expect(CastingTimeParser.parse('').fitsInATurn, isFalse);
      expect(CastingTimeParser.parse(null).fitsInATurn, isFalse);
    });
  });

  group('personagem simples', () {
    test('toda build recebe as ações universais', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(),
        classes: const [fighter],
        classFeatures: const [],
      );

      final actions = options[CombatActionType.action].map((item) => item.name);

      expect(
        actions,
        containsAll([
          'Atacar',
          'Correr',
          'Desengajar',
          'Esquivar',
          'Ajudar',
          'Esconder-se',
          'Preparar uma ação',
          'Usar objeto',
        ]),
      );
      expect(options.attacksPerAction, 1);
    });

    test('sem Ataque Extra a ação de Atacar não fala em quantidade', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(),
        classes: const [fighter],
        classFeatures: const [],
      );

      final attack = options[CombatActionType.action]
          .firstWhere((item) => item.id == UniversalCombatActions.attackId);

      expect(attack.summary, isNot(contains('ataques')));
    });

    test('característica sem bloco de ação fica fora da lista', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(),
        classes: const [fighter],
        classFeatures: const [passive],
      );

      final names = options.byType.values
          .expand((list) => list)
          .map((item) => item.name);

      expect(names, isNot(contains('Estilo de Luta')));
    });
  });

  group('características de classe', () {
    test('Retomar o Fôlego entra como ação bônus com usos e recarga', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
        classes: const [fighter],
        classFeatures: const [secondWind],
      );

      final option = options[CombatActionType.bonusAction]
          .firstWhere((item) => item.name == 'Retomar o Fôlego');

      expect(option.source, CombatOptionSource.classFeature);
      expect(option.maxUses, 1);
      expect(option.recharge, ActionRecharge.shortRest);
      expect(option.usesLabel, '1 uso, recarrega em descanso curto');
      expect(option.sourceLabel, 'Guerreiro 1º');
    });

    test('característica de nível acima do atual não aparece', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 3)],
        ),
        classes: const [fighter],
        classFeatures: const [secondWind, extraAttack],
      );

      expect(options.attacksPerAction, 1);
    });

    test('Ataque Extra muda a descrição da ação de Atacar', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 5)],
        ),
        classes: const [fighter],
        classFeatures: const [extraAttack],
      );

      expect(options.attacksPerAction, 2);

      final attack = options[CombatActionType.action]
          .firstWhere((item) => item.id == UniversalCombatActions.attackId);

      expect(attack.summary, contains('2 ataques'));
    });

    test('progressão do Ataque Extra usa o maior valor alcançado', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 11)],
        ),
        classes: const [fighter],
        classFeatures: const [extraAttack, extraAttackTwo],
      );

      expect(options.attacksPerAction, 3);
    });

    test('progressão de usos vira uma linha só, com o valor mais alto', () {
      // Um guerreiro de 17º tem as duas entradas de Surto de Ação no
      // compêndio; a ficha não pode mostrar duas.
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 17)],
        ),
        classes: const [fighter],
        classFeatures: const [actionSurgeOne, actionSurgeTwo],
      );

      final surges = options[CombatActionType.special]
          .where((item) => item.name == 'Surto de Ação');

      expect(surges, hasLength(1));
      expect(surges.single.maxUses, 2);
    });

    test('usos derivados do bônus de proficiência são calculados', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'ranger', level: 10)],
        ),
        classes: const [ranger],
        classFeatures: const [naturesVeil],
      );

      final option = options[CombatActionType.bonusAction]
          .firstWhere((item) => item.name == 'Véu da Natureza');

      // 10º nível: bônus de proficiência +4.
      expect(option.maxUses, 4);
    });
  });

  group('multiclasse', () {
    test('Ataque Extra não acumula entre classes', () {
      // Guerreiro 5 / Patrulheiro 5 faz dois ataques, não três. É o erro
      // clássico de somar em vez de pegar o maior.
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [
            ClassLevel(classId: 'fighter', level: 5),
            ClassLevel(classId: 'ranger', level: 5),
          ],
        ),
        classes: const [fighter, ranger],
        classFeatures: const [extraAttack, rangerExtraAttack],
      );

      expect(options.attacksPerAction, 2);
    });

    test('a mesma característica por duas classes vira uma linha', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [
            ClassLevel(classId: 'fighter', level: 5),
            ClassLevel(classId: 'ranger', level: 5),
          ],
        ),
        classes: const [fighter, ranger],
        classFeatures: const [extraAttack, rangerExtraAttack],
      );

      final entries = options[CombatActionType.special]
          .where((item) => item.name == 'Ataque Extra');

      expect(entries, hasLength(1));
      expect(
        entries.single.origins,
        containsAll(['Guerreiro 5º', 'Patrulheiro 5º']),
        reason: 'as duas origens precisam ficar registradas',
      );
    });

    test('não duplica as ações universais', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [
            ClassLevel(classId: 'fighter', level: 5),
            ClassLevel(classId: 'ranger', level: 5),
          ],
        ),
        classes: const [fighter, ranger],
        classFeatures: const [],
      );

      final dashes = options[CombatActionType.action]
          .where((item) => item.name == 'Correr');

      expect(dashes, hasLength(1));
    });
  });

  group('magias', () {
    test('magia preparada entra pelo tempo de conjuração', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(spells: [known(1), known(2)]),
        classes: const [fighter],
        classFeatures: const [],
        spells: [
          spell(id: 1, name: 'Bola de Fogo', level: 3, castingTime: 'Uma ação'),
          spell(
            id: 2,
            name: 'Palavra de Cura',
            level: 1,
            castingTime: 'Uma ação bônus',
          ),
        ],
      );

      expect(
        options[CombatActionType.action].map((item) => item.name),
        contains('Bola de Fogo'),
      );
      expect(
        options[CombatActionType.bonusAction].map((item) => item.name),
        contains('Palavra de Cura'),
      );
    });

    test('magia conhecida e não preparada fica fora', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(spells: [known(1, isPrepared: false)]),
        classes: const [fighter],
        classFeatures: const [],
        spells: [
          spell(id: 1, name: 'Bola de Fogo', level: 3, castingTime: 'Uma ação'),
        ],
      );

      expect(
        options[CombatActionType.action].map((item) => item.name),
        isNot(contains('Bola de Fogo')),
      );
    });

    test('truque entra mesmo sem estar preparado', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(spells: [known(1, isPrepared: false)]),
        classes: const [fighter],
        classFeatures: const [],
        spells: [
          spell(id: 1, name: 'Raio de Fogo', level: 0, castingTime: 'Uma ação'),
        ],
      );

      final option = options[CombatActionType.action]
          .firstWhere((item) => item.name == 'Raio de Fogo');

      expect(option.cost, contains('Truque'));
    });

    test('magia de conjuração longa não entra na lista do turno', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(spells: [known(1)]),
        classes: const [fighter],
        classFeatures: const [],
        spells: [
          spell(id: 1, name: 'Ritual Longo', level: 3, castingTime: '10 minutos'),
        ],
      );

      final names = options.byType.values
          .expand((list) => list)
          .map((item) => item.name);

      expect(names, isNot(contains('Ritual Longo')));
    });

    test('magia de Concentração avisa na condição', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(spells: [known(1)]),
        classes: const [fighter],
        classFeatures: const [],
        spells: [
          spell(
            id: 1,
            name: 'Enfeitiçar Pessoa',
            level: 1,
            castingTime: 'Uma ação',
            concentration: true,
          ),
        ],
      );

      final option = options[CombatActionType.action]
          .firstWhere((item) => item.name == 'Enfeitiçar Pessoa');

      expect(option.requirement, contains('Concentração'));
    });
  });

  group('recursos esgotados', () {
    test('item sem carga fica indisponível com motivo', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          magicItems: const [
            CharacterMagicItem(
              localId: 1,
              name: 'Cajado de Fogo',
              description: 'Solta chamas.',
              spells: [],
              charges: 0,
              maxCharges: 10,
            ),
          ],
        ),
        classes: const [fighter],
        classFeatures: const [],
      );

      final option = options[CombatActionType.action]
          .firstWhere((item) => item.name == 'Cajado de Fogo');

      expect(option.isAvailable, isFalse);
      expect(option.unavailableReason, contains('Sem cargas'));
      expect(option.isExhausted, isTrue);
      expect(option.usesLabel, startsWith('0 de 10'));
    });

    test('item com carga fica disponível e mostra o restante', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          magicItems: const [
            CharacterMagicItem(
              localId: 1,
              name: 'Cajado de Fogo',
              description: '',
              spells: [],
              charges: 4,
              maxCharges: 10,
            ),
          ],
        ),
        classes: const [fighter],
        classFeatures: const [],
      );

      final option = options[CombatActionType.action]
          .firstWhere((item) => item.name == 'Cajado de Fogo');

      expect(option.isAvailable, isTrue);
      expect(option.usesLabel, startsWith('4 de 10'));
    });

    test('característica sem rastreamento não se declara esgotada', () {
      // O app não persiste uso de característica: mostrar "0 restantes" seria
      // afirmar algo que não se sabe.
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
        classes: const [fighter],
        classFeatures: const [secondWind],
      );

      final option = options[CombatActionType.bonusAction]
          .firstWhere((item) => item.name == 'Retomar o Fôlego');

      expect(option.remainingUses, isNull);
      expect(option.isExhausted, isFalse);
      expect(option.isAvailable, isTrue);
    });
  });

  group('condições bloqueiam o que a regra diz', () {
    test('Incapacitado tira ação, ação bônus e reação', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          conditions: const {Condition.incapacitated},
        ),
        classes: const [fighter],
        classFeatures: const [],
      );

      for (final type in const [
        CombatActionType.action,
        CombatActionType.bonusAction,
        CombatActionType.reaction,
      ]) {
        for (final option in options[type]) {
          expect(option.isAvailable, isFalse, reason: '${option.name} ($type)');
          expect(option.unavailableReason, contains('não pode realizar'));
        }
      }
    });

    test('Inconsciente arrasta Incapacitado e aparece como motivo', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(conditions: const {Condition.unconscious}),
        classes: const [fighter],
        classFeatures: const [],
      );

      final attack = options[CombatActionType.action]
          .firstWhere((item) => item.id == UniversalCombatActions.attackId);

      expect(attack.isAvailable, isFalse);
      expect(attack.unavailableReason, contains('Inconsciente'));
    });

    test('Agarrado zera o movimento sem tirar a ação', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(conditions: const {Condition.grappled}),
        classes: const [fighter],
        classFeatures: const [],
      );

      for (final option in options[CombatActionType.movement]) {
        expect(option.isAvailable, isFalse);
        expect(option.unavailableReason, contains('Agarrado'));
      }

      final attack = options[CombatActionType.action]
          .firstWhere((item) => item.id == UniversalCombatActions.attackId);
      expect(attack.isAvailable, isTrue);
    });

    test('condição que só dá desvantagem não bloqueia nada', () {
      // Envenenado dá desvantagem em ataque, e quem decide se vale atacar
      // assim é o jogador.
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(conditions: const {Condition.poisoned}),
        classes: const [fighter],
        classFeatures: const [],
      );

      final attack = options[CombatActionType.action]
          .firstWhere((item) => item.id == UniversalCombatActions.attackId);

      expect(attack.isAvailable, isTrue);
    });
  });

  group('subclasse', () {
    const hunter = SubclassEntry(
      id: 'ranger_hunter',
      classId: 'ranger',
      name: 'Caçador',
      source: 'phb',
      features: [
        SubclassFeature(
          level: 3,
          name: 'Presa do Caçador',
          description: 'Dano extra.',
        ),
        SubclassFeature(
          level: 7,
          name: 'Táticas Defensivas',
          description: 'Reage a um ataque.',
          action: FeatureAction(
            type: CombatActionType.reaction,
            trigger: 'Uma criatura ataca você.',
          ),
        ),
      ],
    );

    test('característica de subclasse com ação entra na lista', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'ranger',
              level: 7,
              subclassId: 'ranger_hunter',
            ),
          ],
        ),
        classes: const [ranger],
        classFeatures: const [],
        subclasses: const [hunter],
      );

      final option = options[CombatActionType.reaction]
          .firstWhere((item) => item.name == 'Táticas Defensivas');

      expect(option.source, CombatOptionSource.subclassFeature);
      expect(option.trigger, contains('ataca você'));
      expect(option.sourceLabel, 'Caçador 7º');
    });

    test('característica de subclasse acima do nível não aparece', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [
            ClassLevel(
              classId: 'ranger',
              level: 3,
              subclassId: 'ranger_hunter',
            ),
          ],
        ),
        classes: const [ranger],
        classFeatures: const [],
        subclasses: const [hunter],
      );

      final names =
          options[CombatActionType.reaction].map((item) => item.name);

      expect(names, isNot(contains('Táticas Defensivas')));
    });

    test('sem subclasse escolhida nada de subclasse entra', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'ranger', level: 7)],
        ),
        classes: const [ranger],
        classFeatures: const [],
        subclasses: const [hunter],
      );

      final names =
          options[CombatActionType.reaction].map((item) => item.name);

      expect(names, isNot(contains('Táticas Defensivas')));
    });
  });

  group('possibilidades para este turno', () {
    test('combina movimento, ação e ação bônus quando há as três', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 1)],
        ),
        classes: const [fighter],
        classFeatures: const [secondWind],
      );

      final titles = TurnPossibilities.from(options).map((item) => item.title);

      expect(titles, contains('Movimento + ação + ação bônus'));
    });

    test('sem ação bônus não sugere combinação com ela', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(),
        classes: const [fighter],
        classFeatures: const [],
      );

      final titles = TurnPossibilities.from(options).map((item) => item.title);

      expect(titles, isNot(contains('Ação + ação bônus')));
      expect(titles, contains('Movimento + ação'));
    });

    test('Surto de Ação rende a sugestão de ação adicional', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          classLevels: const [ClassLevel(classId: 'fighter', level: 2)],
        ),
        classes: const [fighter],
        classFeatures: const [actionSurgeOne],
      );

      final possibilities = TurnPossibilities.from(options);
      final surge = possibilities.where(
        (item) => item.title.contains('Surto de Ação'),
      );

      expect(surge, hasLength(1));
      expect(surge.single.steps.length, 3);
    });

    test('Incapacitado não gera sugestão nenhuma', () {
      final options = CombatOptionsResolver.resolve(
        character: characterFixture(
          conditions: const {Condition.incapacitated},
        ),
        classes: const [fighter],
        classFeatures: const [],
      );

      expect(TurnPossibilities.from(options), isEmpty);
    });
  });
}
