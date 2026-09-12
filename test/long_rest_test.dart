import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/character_fixture.dart';

/// Descanso longo grava em três lugares diferentes (personagem, uso de
/// espaços de magia e cargas de item). Este fake registra as três chamadas
/// para provar que o botão faz tudo, e não só a parte do personagem.
class _FakeCharacterRepository implements CharacterRepository {
  _FakeCharacterRepository(this.stored);

  Character stored;
  Character? updated;

  bool resetSlotsCalled = false;
  List<int>? resetSlotLevels;
  String? resetCharacterId;

  final List<(int, int?)> chargeWrites = [];

  @override
  Future<Character?> findById(String id) async => stored;

  @override
  Future<void> update(Character character) async {
    updated = character;
    stored = character;
  }

  @override
  Future<void> resetUsedSpellSlots({
    required String characterId,
    List<int>? slotLevels,
  }) async {
    resetSlotsCalled = true;
    resetCharacterId = characterId;
    resetSlotLevels = slotLevels;
  }

  @override
  Future<void> updateMagicItemCharges({
    required int magicItemId,
    required int? charges,
  }) async {
    chargeWrites.add((magicItemId, charges));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} não usado no teste');
  }
}

CharacterMagicItem _item({
  required int localId,
  int? charges,
  int? maxCharges,
  String? rechargeRule,
}) {
  return CharacterMagicItem(
    localId: localId,
    name: 'Item $localId',
    description: '',
    spells: const [],
    charges: charges,
    maxCharges: maxCharges,
    rechargeRule: rechargeRule,
  );
}

void main() {
  late _FakeCharacterRepository repository;
  late ProviderContainer container;

  Character build({List<CharacterMagicItem> items = const []}) {
    return characterFixture(
      hitPoints: const HitPoints(current: 9, maximum: 60, temporary: 5),
      hitDiceUsed: 8,
      exhaustion: 2,
    ).copyWith(magicItems: items);
  }

  void setUpContainer(Character character) {
    repository = _FakeCharacterRepository(character);
    container = ProviderContainer(
      overrides: [
        characterRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  }

  test('o botão aplica todos os benefícios de uma vez', () async {
    final character = build(
      items: [
        _item(localId: 1, charges: 0, maxCharges: 3),
        _item(localId: 2, charges: 2, maxCharges: 7, rechargeRule: 'Ao amanhecer'),
      ],
    );
    setUpContainer(character);

    final summary = await container.read(longRestProvider)(
      character: character,
      totalHitDice: 8,
    );

    // Pontos de vida cheios e temporários zerados.
    expect(repository.updated!.hitPoints.current, 60);
    expect(repository.updated!.hitPoints.temporary, 0);

    // Metade dos dados de vida de volta e um nível de exaustão a menos.
    expect(repository.updated!.hitDiceUsed, 4);
    expect(repository.updated!.exhaustion, 1);

    // Espaços de magia: `null` manda zerar todos os níveis.
    expect(repository.resetSlotsCalled, isTrue);
    expect(repository.resetCharacterId, character.id);
    expect(repository.resetSlotLevels, isNull);

    // Cargas de item gravadas no máximo de cada um.
    expect(repository.chargeWrites, [(1, 3), (2, 7)]);

    expect(summary, contains('PV restaurados'));
    expect(summary, contains('espaços de magia renovados'));
    expect(summary, contains('2 item(ns) mágico(s)'));
  });

  test('sem item mágico, nenhuma carga é gravada', () async {
    final character = build();
    setUpContainer(character);

    await container.read(longRestProvider)(
      character: character,
      totalHitDice: 8,
    );

    expect(repository.chargeWrites, isEmpty);
    expect(repository.resetSlotLevels, isNull);
    expect(repository.updated!.hitPoints.current, 60);
  });

  test('item que não recarrega fica intacto', () async {
    final character = build(
      items: [
        _item(
          localId: 5,
          charges: 1,
          maxCharges: 4,
          rechargeRule: 'Recupera ao derrubar um dragão.',
        ),
      ],
    );
    setUpContainer(character);

    await container.read(longRestProvider)(
      character: character,
      totalHitDice: 8,
    );

    expect(repository.chargeWrites, isEmpty);
  });
}
