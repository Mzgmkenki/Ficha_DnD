import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/services/standard_array.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const complete = <Ability, int>{
    Ability.strength: 15,
    Ability.dexterity: 14,
    Ability.constitution: 13,
    Ability.intelligence: 12,
    Ability.wisdom: 10,
    Ability.charisma: 8,
  };

  test('expõe os seis valores recomendados', () {
    expect(StandardArray.values, [15, 14, 13, 12, 10, 8]);
  });

  test('cada valor completo é usado exatamente uma vez', () {
    expect(StandardArray.validationError(complete), isNull);
    expect(StandardArray.available(complete), isEmpty);
  });

  test('valor usado sai e volta ao conjunto disponível', () {
    final draft = <Ability, int>{Ability.strength: 15};
    expect(StandardArray.available(draft), isNot(contains(15)));

    draft.remove(Ability.strength);
    expect(StandardArray.available(draft), contains(15));
  });

  test('bloqueia distribuição incompleta, duplicada e valor externo', () {
    expect(
      StandardArray.validationError({Ability.strength: 15}),
      contains('seis atributos'),
    );

    final duplicate = {...complete, Ability.charisma: 15};
    expect(StandardArray.validationError(duplicate), contains('uma vez'));

    final external = {...complete, Ability.charisma: 9};
    expect(StandardArray.validationError(external), contains('somente'));
  });

  test('base, bônus de origem e total permanecem separados', () {
    final allocation = AbilityScoreAllocation(
      baseScores: StandardArray.toAbilityScores(complete),
      originBonuses: const {Ability.strength: 2, Ability.wisdom: 1},
    );

    final totals = allocation.totals(otherBonuses: const {Ability.strength: 1});

    expect(allocation.baseScores.strength, 15);
    expect(allocation.originBonusFor(Ability.strength), 2);
    expect(totals.strength, 18);
    expect(totals.wisdom, 11);
  });

  test('modificadores negativos e positivos usam o total final', () {
    expect(8.abilityModifier, -1);
    expect(9.abilityModifier, -1);
    expect(10.abilityModifier, 0);
    expect(17.abilityModifier, 3);
  });
}
