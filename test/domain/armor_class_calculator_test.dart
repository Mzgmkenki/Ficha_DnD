import 'package:dnd_ficha_app/features/character/domain/services/armor_class_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/character_fixture.dart';

ArmorOption _armor(String id) {
  final armor = ArmorOption.fromId(id);
  if (armor == null) throw StateError('Armadura $id não existe na tabela.');
  return armor;
}

int _ac(
  String armorId, {
  int dexterity = 10,
  bool shield = false,
  int otherBonus = 0,
}) {
  return ArmorClassCalculator.calculate(
    armor: _armor(armorId),
    abilityScores: scoresWith(dexterity: dexterity),
    hasShield: shield,
    otherBonus: otherBonus,
  ).total;
}

void main() {
  group('tabela de armaduras', () {
    test('fromId devolve null para id desconhecido', () {
      expect(ArmorOption.fromId('mithril'), isNull);
      expect(ArmorOption.fromId(null), isNull);
    });

    test('valores base conferem com o PHB', () {
      expect(_armor('none').baseArmorClass, 10);
      expect(_armor('padded').baseArmorClass, 11);
      expect(_armor('leather').baseArmorClass, 11);
      expect(_armor('studded_leather').baseArmorClass, 12);
      expect(_armor('hide').baseArmorClass, 12);
      expect(_armor('chain_shirt').baseArmorClass, 13);
      expect(_armor('scale_mail').baseArmorClass, 14);
      expect(_armor('breastplate').baseArmorClass, 14);
      expect(_armor('half_plate').baseArmorClass, 15);
      expect(_armor('ring_mail').baseArmorClass, 14);
      expect(_armor('chain_mail').baseArmorClass, 16);
      expect(_armor('splint').baseArmorClass, 17);
      expect(_armor('plate').baseArmorClass, 18);
    });

    test('requisitos de Força conferem com o PHB', () {
      expect(_armor('chain_mail').strengthRequirement, 13);
      expect(_armor('splint').strengthRequirement, 15);
      expect(_armor('plate').strengthRequirement, 15);
      // As demais não exigem Força.
      expect(_armor('half_plate').strengthRequirement, 0);
      expect(_armor('ring_mail').strengthRequirement, 0);
    });

    test('desvantagem em Furtividade confere com o PHB', () {
      expect(_armor('padded').stealthDisadvantage, isTrue);
      expect(_armor('scale_mail').stealthDisadvantage, isTrue);
      expect(_armor('half_plate').stealthDisadvantage, isTrue);
      expect(_armor('ring_mail').stealthDisadvantage, isTrue);
      expect(_armor('chain_mail').stealthDisadvantage, isTrue);
      expect(_armor('splint').stealthDisadvantage, isTrue);
      expect(_armor('plate').stealthDisadvantage, isTrue);

      expect(_armor('leather').stealthDisadvantage, isFalse);
      expect(_armor('studded_leather').stealthDisadvantage, isFalse);
      expect(_armor('hide').stealthDisadvantage, isFalse);
      expect(_armor('chain_shirt').stealthDisadvantage, isFalse);
      expect(_armor('breastplate').stealthDisadvantage, isFalse);
    });
  });

  group('Destreza por categoria', () {
    test('sem armadura soma a Destreza inteira', () {
      expect(_ac('none', dexterity: 18), 10 + 4);
      expect(_ac('none', dexterity: 10), 10);
    });

    test('armadura leve soma a Destreza inteira', () {
      // Couro batido 12 + DES +4.
      expect(_ac('studded_leather', dexterity: 18), 16);
    });

    test('armadura média limita a Destreza a +2', () {
      // Peitoral 14 + no máximo +2.
      expect(_ac('breastplate', dexterity: 20), 16);
      expect(_ac('breastplate', dexterity: 14), 16);
      // Abaixo do limite, entra o valor real.
      expect(_ac('breastplate', dexterity: 12), 15);
    });

    test('armadura pesada ignora a Destreza', () {
      expect(_ac('plate', dexterity: 20), 18);
      expect(_ac('plate', dexterity: 6), 18);
    });

    test('Destreza negativa penaliza, inclusive em armadura média', () {
      // O limite de +2 é teto, não piso.
      expect(_ac('none', dexterity: 6), 10 - 2);
      expect(_ac('breastplate', dexterity: 6), 14 - 2);
      // Em pesada, a Destreza ruim não atrapalha.
      expect(_ac('plate', dexterity: 6), 18);
    });
  });

  group('escudo e outros bônus', () {
    test('escudo soma 2', () {
      expect(_ac('none', shield: true), 12);
      expect(_ac('plate', shield: true), 20);
    });

    test('outros bônus entram no total, positivos ou negativos', () {
      expect(_ac('none', otherBonus: 1), 11);
      expect(_ac('none', otherBonus: -1), 9);
    });

    test('caso completo: meia armadura, DES 16, escudo e anel +1', () {
      // 15 + 2 (limite) + 2 + 1.
      expect(
        _ac('half_plate', dexterity: 16, shield: true, otherBonus: 1),
        20,
      );
    });
  });

  group('explicação do cálculo', () {
    test('mostra as parcelas de armadura média', () {
      final result = ArmorClassCalculator.calculate(
        armor: _armor('breastplate'),
        abilityScores: scoresWith(dexterity: 20),
        hasShield: true,
        otherBonus: 1,
      );

      // 14 + 2 (DES limitada) + 2 (escudo) + 1 (outros).
      expect(result.total, 19);
      expect(result.explanation, contains('Peitoral 14'));
      expect(result.explanation, contains('limite +2'));
      expect(result.explanation, contains('escudo +2'));
      expect(result.explanation, contains('outros +1'));
    });

    test('não cita outros bônus quando são zero', () {
      final result = ArmorClassCalculator.calculate(
        armor: _armor('leather'),
        abilityScores: flatScores,
      );

      expect(result.explanation, isNot(contains('outros')));
      expect(result.explanation, isNot(contains('escudo')));
    });

    test('repassa a desvantagem em Furtividade da armadura', () {
      final loud = ArmorClassCalculator.calculate(
        armor: _armor('plate'),
        abilityScores: flatScores,
      );
      final quiet = ArmorClassCalculator.calculate(
        armor: _armor('leather'),
        abilityScores: flatScores,
      );

      expect(loud.stealthDisadvantage, isTrue);
      expect(quiet.stealthDisadvantage, isFalse);
    });
  });

  group('requisito de Força', () {
    test('falha quando a Força é menor que o exigido', () {
      expect(
        ArmorClassCalculator.failsStrengthRequirement(
          armor: _armor('plate'),
          abilityScores: scoresWith(strength: 14),
        ),
        isTrue,
      );
    });

    test('cumpre no valor exato', () {
      expect(
        ArmorClassCalculator.failsStrengthRequirement(
          armor: _armor('plate'),
          abilityScores: scoresWith(strength: 15),
        ),
        isFalse,
      );
    });

    test('armadura sem requisito nunca falha', () {
      expect(
        ArmorClassCalculator.failsStrengthRequirement(
          armor: _armor('leather'),
          abilityScores: scoresWith(strength: 1),
        ),
        isFalse,
      );
    });
  });
}
