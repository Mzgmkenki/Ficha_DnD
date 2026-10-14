import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';

/// O que sobrou depois de reconferir os requisitos da armadura equipada.
class ArmorRequirementsOutcome {
  const ArmorRequirementsOutcome({
    required this.character,
    this.unequipped = const <OwnedArmorPiece>[],
    this.notice,
  });

  /// O personagem já com a armadura inválida guardada e a CA recalculada.
  final Character character;

  /// Peças que saíram por falta de Força. Continuam no inventário.
  final List<OwnedArmorPiece> unequipped;

  /// Aviso pronto para a tela, ou `null` quando nada mudou.
  final String? notice;

  bool get changed => unequipped.isNotEmpty;
}

/// Reconfere o requisito de Força da armadura equipada e conserta a ficha.
///
/// Serve a todo caminho que mexe em atributo: edição manual, remoção de talento
/// com aumento de atributo e qualquer outro que apareça depois. A regra mora
/// aqui, uma vez, em vez de ser repetida em cada caso de uso.
///
/// Duas decisões deliberadas:
///
/// 1. A armadura é apenas DESEQUIPADA, nunca removida. O personagem não perdeu
///    a peça; ele só não tem Força para usá-la, e pode voltar a usar depois.
/// 2. A CA só é recalculada quando algo realmente saiu. Personagem antigo que
///    digitou a CA à mão, sem armadura cadastrada no inventário, continua com o
///    número dele — recalcular nesse caso jogaria fora um valor que o app não
///    tem como reconstruir, porque o bônus manual da tela de CA não é
///    persistido.
class ArmorRequirements {
  const ArmorRequirements._();

  static ArmorRequirementsOutcome apply(Character character) {
    final result = OwnedArmor.enforceRequirements(
      inventory: character.inventory,
      abilityScores: character.abilityScores,
    );

    if (result.unequipped.isEmpty) {
      return ArmorRequirementsOutcome(character: character);
    }

    final armorClass = OwnedArmor.armorClass(
      inventory: result.inventory,
      abilityScores: character.abilityScores,
    );

    return ArmorRequirementsOutcome(
      character: character.copyWith(
        inventory: result.inventory,
        combatStats: character.combatStats.copyWith(
          armorClass: armorClass.total,
        ),
      ),
      unequipped: result.unequipped,
      notice: OwnedArmor.unequipNotice(result, character.abilityScores),
    );
  }
}
