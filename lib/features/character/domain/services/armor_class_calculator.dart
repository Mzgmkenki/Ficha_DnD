import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';

/// Categorias de armadura de 5e, que determinam como a Destreza entra na CA.
enum ArmorCategory {
  none('Sem armadura'),
  light('Leve'),
  medium('Média'),
  heavy('Pesada');

  const ArmorCategory(this.label);
  final String label;
}

/// Uma armadura do compêndio básico.
class ArmorOption {
  const ArmorOption({
    required this.id,
    required this.name,
    required this.category,
    required this.baseArmorClass,
    this.strengthRequirement = 0,
    this.stealthDisadvantage = false,
  });

  final String id;
  final String name;
  final ArmorCategory category;
  final int baseArmorClass;
  final int strengthRequirement;
  final bool stealthDisadvantage;

  /// Armaduras do PHB. Mantido em código porque é uma tabela pequena e
  /// estável, e evita mais um asset para carregar.
  static const List<ArmorOption> all = [
    ArmorOption(
      id: 'none',
      name: 'Sem armadura',
      category: ArmorCategory.none,
      baseArmorClass: 10,
    ),
    // Leves
    ArmorOption(
      id: 'padded',
      name: 'Acolchoada',
      category: ArmorCategory.light,
      baseArmorClass: 11,
      stealthDisadvantage: true,
    ),
    ArmorOption(
      id: 'leather',
      name: 'Couro',
      category: ArmorCategory.light,
      baseArmorClass: 11,
    ),
    ArmorOption(
      id: 'studded_leather',
      name: 'Couro batido',
      category: ArmorCategory.light,
      baseArmorClass: 12,
    ),
    // Médias
    ArmorOption(
      id: 'hide',
      name: 'Peles',
      category: ArmorCategory.medium,
      baseArmorClass: 12,
    ),
    ArmorOption(
      id: 'chain_shirt',
      name: 'Camisão de malha',
      category: ArmorCategory.medium,
      baseArmorClass: 13,
    ),
    ArmorOption(
      id: 'scale_mail',
      name: 'Brunea',
      category: ArmorCategory.medium,
      baseArmorClass: 14,
      stealthDisadvantage: true,
    ),
    ArmorOption(
      id: 'breastplate',
      name: 'Peitoral',
      category: ArmorCategory.medium,
      baseArmorClass: 14,
    ),
    ArmorOption(
      id: 'half_plate',
      name: 'Meia armadura',
      category: ArmorCategory.medium,
      baseArmorClass: 15,
      stealthDisadvantage: true,
    ),
    // Pesadas
    ArmorOption(
      id: 'ring_mail',
      name: 'Cota de anéis',
      category: ArmorCategory.heavy,
      baseArmorClass: 14,
      stealthDisadvantage: true,
    ),
    ArmorOption(
      id: 'chain_mail',
      name: 'Cota de malha',
      category: ArmorCategory.heavy,
      baseArmorClass: 16,
      strengthRequirement: 13,
      stealthDisadvantage: true,
    ),
    ArmorOption(
      id: 'splint',
      name: 'Talas',
      category: ArmorCategory.heavy,
      baseArmorClass: 17,
      strengthRequirement: 15,
      stealthDisadvantage: true,
    ),
    ArmorOption(
      id: 'plate',
      name: 'Placas',
      category: ArmorCategory.heavy,
      baseArmorClass: 18,
      strengthRequirement: 15,
      stealthDisadvantage: true,
    ),
  ];

  static ArmorOption? fromId(String? id) {
    if (id == null) return null;
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}

/// Resultado do cálculo, com a explicação de como chegou no número.
class ArmorClassResult {
  const ArmorClassResult({
    required this.total,
    required this.explanation,
    this.stealthDisadvantage = false,
  });

  final int total;
  final String explanation;
  final bool stealthDisadvantage;
}

/// Calcula a CA a partir da armadura, escudo e bônus diversos.
class ArmorClassCalculator {
  const ArmorClassCalculator._();

  static ArmorClassResult calculate({
    required ArmorOption armor,
    required AbilityScores abilityScores,
    bool hasShield = false,
    int otherBonus = 0,
  }) {
    final dexModifier = abilityScores.dexterity.abilityModifier;

    // A Destreza entra inteira em armadura leve/nenhuma, limitada a +2 em
    // média e não entra em pesada.
    final int appliedDex;
    final String dexNote;

    switch (armor.category) {
      case ArmorCategory.none:
      case ArmorCategory.light:
        appliedDex = dexModifier;
        dexNote = 'DES ${_signed(dexModifier)}';
        break;
      case ArmorCategory.medium:
        appliedDex = dexModifier > 2 ? 2 : dexModifier;
        dexNote = 'DES ${_signed(appliedDex)} (limite +2)';
        break;
      case ArmorCategory.heavy:
        appliedDex = 0;
        dexNote = 'DES não se aplica';
        break;
    }

    final shieldBonus = hasShield ? 2 : 0;
    final total =
        armor.baseArmorClass + appliedDex + shieldBonus + otherBonus;

    final parts = <String>[
      '${armor.name} ${armor.baseArmorClass}',
      dexNote,
      if (hasShield) 'escudo +2',
      if (otherBonus != 0) 'outros ${_signed(otherBonus)}',
    ];

    return ArmorClassResult(
      total: total,
      explanation: parts.join(' • '),
      stealthDisadvantage: armor.stealthDisadvantage,
    );
  }

  /// Indica se o personagem não cumpre o requisito de Força da armadura
  /// (o que reduz o deslocamento em 3 m pela regra).
  static bool failsStrengthRequirement({
    required ArmorOption armor,
    required AbilityScores abilityScores,
  }) {
    if (armor.strengthRequirement <= 0) return false;
    return abilityScores.strength < armor.strengthRequirement;
  }

  static String _signed(int value) => value >= 0 ? '+$value' : '$value';
}
