import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/subclass_choice.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

/// Clérigo escolhe o domínio já no 1º nível.
const _cleric = ClassEntry(
  id: 'cleric',
  name: 'Clérigo',
  hitDie: 'd8',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
  subclassLevel: 1,
  subclassLabel: 'Domínio Divino',
);

/// Guerreiro escolhe o arquétipo no 3º.
const _fighter = ClassEntry(
  id: 'fighter',
  name: 'Guerreiro',
  hitDie: 'd10',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
  subclassLevel: 3,
  subclassLabel: 'Arquétipo Marcial',
);

/// Classe sem subclasse cadastrada no compêndio.
const _homebrew = ClassEntry(
  id: 'homebrew',
  name: 'Caseira',
  hitDie: 'd8',
  source: 'custom',
  skillOptions: [],
  savingThrows: [],
);

const _classes = [_cleric, _fighter, _homebrew];

void main() {
  group('isPending', () {
    test('está em aberto quando o nível alcançou e não há subclasse', () {
      const level = ClassLevel(classId: 'fighter', level: 3);

      expect(SubclassChoices.isPending(level, _fighter), isTrue);
    });

    test('não está em aberto antes do nível de escolha', () {
      const level = ClassLevel(classId: 'fighter', level: 2);

      expect(SubclassChoices.isPending(level, _fighter), isFalse);
    });

    test('não está em aberto quando já foi escolhida', () {
      const level = ClassLevel(
        classId: 'fighter',
        level: 3,
        subclassId: 'fighter_champion',
      );

      expect(SubclassChoices.isPending(level, _fighter), isFalse);
    });

    test('continua em aberto acima do nível de escolha', () {
      // É a mudança de comportamento: antes só valia na transição exata, então
      // quem passasse do 3º sem escolher nunca era perguntado de novo.
      const level = ClassLevel(classId: 'fighter', level: 7);

      expect(SubclassChoices.isPending(level, _fighter), isTrue);
    });

    test('classe sem nível de subclasse nunca fica em aberto', () {
      const level = ClassLevel(classId: 'homebrew', level: 20);

      expect(SubclassChoices.isPending(level, _homebrew), isFalse);
    });

    test('classe fora do compêndio não fica em aberto', () {
      const level = ClassLevel(classId: 'sumida', level: 5);

      expect(SubclassChoices.isPending(level, null), isFalse);
    });

    test('id de subclasse vazio conta como não escolhida', () {
      const level = ClassLevel(
        classId: 'fighter',
        level: 3,
        subclassId: '',
      );

      expect(SubclassChoices.isPending(level, _fighter), isTrue);
    });
  });

  group('pendingFor', () {
    test('devolve nada quando tudo está resolvido', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'cleric',
            level: 3,
            subclassId: 'cleric_life_domain',
          ),
        ],
      );

      expect(SubclassChoices.pendingFor(character, _classes), isEmpty);
    });

    test('o clérigo de 1º nível já entra com a escolha aberta', () {
      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'cleric', level: 1)],
      );

      final pending = SubclassChoices.pendingFor(character, _classes);

      expect(pending, hasLength(1));
      expect(pending.single.classId, 'cleric');
      expect(pending.single.className, 'Clérigo');
      expect(pending.single.label, 'Domínio Divino');
      expect(pending.single.level, 1);
    });

    test('multiclasse pode ter duas escolhas abertas ao mesmo tempo', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'cleric', level: 1),
          ClassLevel(classId: 'fighter', level: 3),
        ],
      );

      final pending = SubclassChoices.pendingFor(character, _classes);

      expect(pending.map((item) => item.classId), ['cleric', 'fighter']);
    });

    test('só a classe que alcançou o nível entra', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'cleric', level: 1),
          ClassLevel(classId: 'fighter', level: 2),
        ],
      );

      final pending = SubclassChoices.pendingFor(character, _classes);

      expect(pending.map((item) => item.classId), ['cleric']);
    });

    test('o rótulo cai no genérico quando a classe não declara', () {
      const semRotulo = ClassEntry(
        id: 'x',
        name: 'X',
        hitDie: 'd8',
        source: 'custom',
        skillOptions: [],
        savingThrows: [],
        subclassLevel: 2,
      );

      final character = characterFixture(
        classLevels: const [ClassLevel(classId: 'x', level: 2)],
      );

      final pending = SubclassChoices.pendingFor(character, const [semRotulo]);

      expect(pending.single.label, 'Subclasse');
    });
  });

  group('pendingForClass', () {
    test('acha a escolha da classe pedida', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(classId: 'cleric', level: 1),
          ClassLevel(classId: 'fighter', level: 3),
        ],
      );

      final choice = SubclassChoices.pendingForClass(
        character,
        _classes,
        'fighter',
      );

      expect(choice?.label, 'Arquétipo Marcial');
    });

    test('devolve nulo quando aquela classe não tem escolha aberta', () {
      final character = characterFixture(
        classLevels: const [
          ClassLevel(
            classId: 'fighter',
            level: 3,
            subclassId: 'fighter_champion',
          ),
        ],
      );

      expect(
        SubclassChoices.pendingForClass(character, _classes, 'fighter'),
        isNull,
      );
    });
  });
}
