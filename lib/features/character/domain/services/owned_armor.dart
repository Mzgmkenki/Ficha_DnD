import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/item_category.dart';

/// O escudo.
///
/// Fica fora de [ArmorOption.all] de propósito: escudo não é armadura
/// vestível, não tem CA base nem limite de Destreza, e entra na conta como
/// bônus próprio. Misturá-lo na tabela faria a lista de armaduras oferecer
/// "escudo" como armadura e o cálculo somar a CA base dele.
class ShieldOption {
  const ShieldOption._();

  /// Id usado como `InventoryItem.itemId` do escudo.
  static const String id = 'shield';

  static const String name = 'Escudo';

  /// Bônus que o escudo equipado concede à CA.
  static const int armorClassBonus = 2;
}

/// Uma peça de defesa que o personagem possui.
///
/// É uma visão sobre o inventário, não uma entidade nova: a armadura possuída
/// é um `InventoryItem` como qualquer outro, e aqui ela só aparece resolvida
/// contra a tabela de armaduras e contra as exceções da própria peça.
class OwnedArmorPiece {
  const OwnedArmorPiece({
    required this.item,
    this.profile,
    this.isShield = false,
  });

  final InventoryItem item;

  /// A armadura resolvida, já com as exceções da peça. Nula no escudo.
  final ArmorProfile? profile;

  final bool isShield;

  /// A armadura da tabela, sem exceções. Nula no escudo.
  ArmorOption? get armor => profile?.option;

  bool get isEquipped => item.equipped;

  /// Nome como está na ficha: o escudo de madeira do Druida continua se
  /// chamando "Escudo de madeira".
  String get name => item.name;

  String get originLabel => item.originLabel;

  /// O `+1`/`+2`/`+3` da peça mágica.
  int get magicBonus => item.armorMagicBonus;

  bool get isMagical => magicBonus != 0;

  /// Força exigida pela peça, já considerando a exceção dela.
  ///
  /// Escudo não exige Força em 5e, então é sempre nulo nele.
  int? get strengthRequirement => profile?.strengthRequirement;

  bool get requiresStrength => profile?.requiresStrength ?? false;

  /// `true` quando a peça impõe desvantagem em Furtividade.
  ///
  /// Escudo não impõe.
  bool get stealthDisadvantage => profile?.stealthDisadvantage ?? false;

  /// `true` quando o personagem cumpre o requisito de Força da peça.
  bool meetsStrengthRequirement(AbilityScores abilityScores) =>
      profile?.meetsStrengthRequirement(abilityScores) ?? true;

  /// Por que esta peça não pode ser equipada, ou `null` quando pode.
  String? blockReason(AbilityScores abilityScores) =>
      profile?.blockReason(abilityScores);

  /// Bônus que a peça dá à CA quando equipada. Só o escudo responde aqui; a
  /// armadura vestível entra pela CA base.
  int get shieldBonus =>
      isShield ? ShieldOption.armorClassBonus + magicBonus : 0;
}

/// Resultado de equipar, desequipar ou revalidar as peças de defesa.
class ArmorEquipResult {
  const ArmorEquipResult({
    required this.inventory,
    this.blockedReason,
    this.unequipped = const <OwnedArmorPiece>[],
  });

  final List<InventoryItem> inventory;

  /// Preenchido quando a ação foi recusada. O inventário volta intacto.
  final String? blockedReason;

  /// Peças que foram desequipadas por não cumprirem mais o requisito.
  final List<OwnedArmorPiece> unequipped;

  bool get wasBlocked => blockedReason != null;

  bool get changed => unequipped.isNotEmpty || blockedReason == null;
}

/// Armadura e escudo que o personagem possui, lidos do inventário.
///
/// Todas as funções são puras e recebem a lista: nenhuma consulta o banco. Duas
/// regras moram aqui, e não nas telas:
///
/// 1. A Classe de Armadura usa só o que está EQUIPADO — possuir três armaduras
///    não soma três vezes.
/// 2. Armadura cujo requisito de Força não é cumprido não pode ser equipada e
///    não entra na CA, mesmo que a linha do banco diga `equipped = 1`. Isso é
///    deliberadamente defensivo: ficha importada, base editada à mão e queda de
///    Força depois de equipar são três caminhos que chegariam a esse estado sem
///    passar por tela nenhuma.
class OwnedArmor {
  const OwnedArmor._();

  /// Peças reconhecidas no inventário, na ordem em que estão lá.
  ///
  /// Item na categoria armadura cujo `itemId` não existe na tabela é ignorado:
  /// sem CA base não há como calcular, e chutar um valor seria inventar regra.
  /// Ele continua visível no Inventário normalmente.
  static List<OwnedArmorPiece> from(List<InventoryItem> inventory) {
    final result = <OwnedArmorPiece>[];

    for (final item in inventory) {
      if (item.category != ItemCategory.armor) continue;

      if (item.itemId == ShieldOption.id) {
        result.add(OwnedArmorPiece(item: item, isShield: true));
        continue;
      }

      final armor = ArmorOption.fromId(item.itemId);
      if (armor == null) continue;
      if (armor.category == ArmorCategory.none) continue;

      result.add(
        OwnedArmorPiece(
          item: item,
          profile: ArmorProfile(
            option: armor,
            strengthRequirementOverride: item.armorStrengthRequirement,
            stealthDisadvantageOverride: item.armorStealthDisadvantage,
            magicBonus: item.armorMagicBonus,
          ),
        ),
      );
    }

    return List<OwnedArmorPiece>.unmodifiable(result);
  }

  /// Só as armaduras vestíveis.
  static List<OwnedArmorPiece> wearables(List<InventoryItem> inventory) =>
      from(inventory).where((piece) => !piece.isShield).toList(growable: false);

  /// Só os escudos.
  static List<OwnedArmorPiece> shields(List<InventoryItem> inventory) =>
      from(inventory).where((piece) => piece.isShield).toList(growable: false);

  /// A armadura equipada E válida, quando há uma.
  ///
  /// Armadura marcada como equipada que não cumpre o requisito de Força NÃO é
  /// devolvida: para a regra, o personagem não está usando aquilo. Ela continua
  /// no inventário e continua aparecendo na lista de peças possuídas.
  static OwnedArmorPiece? equippedWearable(
    List<InventoryItem> inventory, {
    AbilityScores? abilityScores,
  }) {
    for (final piece in wearables(inventory)) {
      if (!piece.isEquipped) continue;
      if (abilityScores != null &&
          !piece.meetsStrengthRequirement(abilityScores)) {
        continue;
      }
      return piece;
    }
    return null;
  }

  static OwnedArmorPiece? equippedShield(List<InventoryItem> inventory) {
    for (final piece in shields(inventory)) {
      if (piece.isEquipped) return piece;
    }
    return null;
  }

  static bool hasEquippedShield(List<InventoryItem> inventory) =>
      equippedShield(inventory) != null;

  /// A armadura que está valendo, já resolvida para o cálculo.
  ///
  /// Sem armadura equipada devolve "Sem armadura", que é o estado correto de
  /// quem não vestiu nada — e não um erro.
  static ArmorProfile effectiveArmor(
    List<InventoryItem> inventory, {
    AbilityScores? abilityScores,
  }) {
    final piece = equippedWearable(inventory, abilityScores: abilityScores);
    return piece?.profile ?? ArmorOption.all.first.profile;
  }

  /// `true` quando a armadura equipada impõe desvantagem em Furtividade.
  ///
  /// Só conta peça equipada e válida: armadura bloqueada por Força não está
  /// sendo usada, e portanto não penaliza. Escudo não entra — escudo não impõe
  /// desvantagem em 5e.
  static bool hasStealthDisadvantage(
    List<InventoryItem> inventory, {
    AbilityScores? abilityScores,
  }) {
    final piece = equippedWearable(inventory, abilityScores: abilityScores);
    return piece?.stealthDisadvantage ?? false;
  }

  /// A peça responsável pela desvantagem em Furtividade, quando há uma.
  ///
  /// Devolve a peça, e não um booleano, para o aviso poder dizer o nome dela —
  /// "Brunea impõe desvantagem" é mais útil que "você tem desvantagem".
  static OwnedArmorPiece? stealthDisadvantageSource(
    List<InventoryItem> inventory, {
    AbilityScores? abilityScores,
  }) {
    final piece = equippedWearable(inventory, abilityScores: abilityScores);
    if (piece == null || !piece.stealthDisadvantage) return null;
    return piece;
  }

  /// `true` quando a peça pode ser equipada.
  static bool canEquip({
    required OwnedArmorPiece piece,
    required AbilityScores abilityScores,
  }) => piece.meetsStrengthRequirement(abilityScores);

  /// Veste a única armadura possuída, quando nada está vestido e ela é válida.
  ///
  /// É o fecho da criação de personagem: o equipamento inicial da classe é
  /// escolhido antes de os atributos estarem distribuídos, então o momento de
  /// vestir é o de concluir, quando a Força já é definitiva. Com mais de uma
  /// armadura a decisão é do jogador e nada é vestido.
  static List<InventoryItem> autoEquipSingle({
    required List<InventoryItem> inventory,
    required AbilityScores abilityScores,
  }) {
    if (equippedWearable(inventory, abilityScores: abilityScores) != null) {
      return inventory;
    }

    final candidates = wearables(inventory);
    if (candidates.length != 1) return inventory;

    return equipWearable(
      inventory: inventory,
      piece: candidates.single,
      abilityScores: abilityScores,
    ).inventory;
  }

  /// Equipa uma armadura vestível, desequipando as outras.
  ///
  /// Recusa quando o requisito de Força não é cumprido: devolve o inventário
  /// intacto e o motivo em [ArmorEquipResult.blockedReason]. A validação é
  /// aqui, no domínio, e não só no botão — a tela é um dos caminhos, não o
  /// único.
  ///
  /// Exclusividade é a regra: só se veste uma armadura. O escudo não é tocado,
  /// porque escudo e armadura convivem. Passar `piece: null` desequipa.
  static ArmorEquipResult equipWearable({
    required List<InventoryItem> inventory,
    required OwnedArmorPiece? piece,
    required AbilityScores abilityScores,
  }) {
    if (piece != null) {
      final reason = piece.blockReason(abilityScores);
      if (reason != null) {
        return ArmorEquipResult(inventory: inventory, blockedReason: reason);
      }
    }

    return ArmorEquipResult(
      inventory: _writeWearableEquipped(inventory, piece?.item),
    );
  }

  /// Equipa ou guarda o escudo.
  ///
  /// Com [piece] nulo, vale o primeiro escudo do inventário: a tela de CA tem
  /// um interruptor único, e quem só tem um escudo não deveria ter que
  /// escolher qual. Escudo não tem requisito de Força em 5e, então não há o que
  /// bloquear.
  static List<InventoryItem> setShieldEquipped({
    required List<InventoryItem> inventory,
    required bool equipped,
    InventoryItem? piece,
  }) {
    final shieldList = shields(inventory);
    if (shieldList.isEmpty) return inventory;

    final target = piece ?? shieldList.first.item;
    final targetRow = target.localId;

    return [
      for (final item in inventory)
        if (item.itemId != ShieldOption.id ||
            item.category != ItemCategory.armor)
          item
        else
          item.copyWith(
            equipped: _isSameRow(item, target, targetRow) ? equipped : false,
          ),
    ];
  }

  /// Desequipa toda armadura que não cumpre mais o requisito de Força.
  ///
  /// É o que mantém a ficha coerente quando a Força CAI depois de a armadura ter
  /// sido equipada — edição manual dos atributos, remoção de um talento que dava
  /// aumento, ou ficha importada de outra origem. A peça continua no inventário:
  /// o personagem não perdeu a armadura, só não consegue mais usá-la.
  static ArmorEquipResult enforceRequirements({
    required List<InventoryItem> inventory,
    required AbilityScores abilityScores,
  }) {
    final offenders = [
      for (final piece in wearables(inventory))
        if (piece.isEquipped && !piece.meetsStrengthRequirement(abilityScores))
          piece,
    ];

    if (offenders.isEmpty) {
      return ArmorEquipResult(inventory: inventory);
    }

    final rows = {
      for (final piece in offenders) piece.item.localId: piece.item,
    };

    final next = [
      for (final item in inventory)
        if (item.category == ItemCategory.armor &&
            item.itemId != ShieldOption.id &&
            item.equipped &&
            _isOffender(item, rows))
          item.copyWith(equipped: false)
        else
          item,
    ];

    return ArmorEquipResult(inventory: next, unequipped: offenders);
  }

  /// Mensagem para o jogador depois de um desequipar automático.
  ///
  /// Devolve `null` quando não houve nenhum. O texto é montado aqui para a
  /// mesma situação dar o mesmo aviso em qualquer tela.
  static String? unequipNotice(
    ArmorEquipResult result,
    AbilityScores abilityScores,
  ) {
    if (result.unequipped.isEmpty) return null;

    if (result.unequipped.length == 1) {
      final piece = result.unequipped.single;
      return '${piece.name} foi desequipada: requer Força '
          '${piece.strengthRequirement}, e a atual é '
          '${abilityScores.strength}. Ela continua no inventário.';
    }

    final names = result.unequipped.map((piece) => piece.name).join(', ');
    return '${result.unequipped.length} armaduras foram desequipadas por falta '
        'de Força ($names). Elas continuam no inventário.';
  }

  /// A CA que resulta do que está equipado.
  ///
  /// Armadura bloqueada por Força não participa, mesmo marcada como equipada.
  static ArmorClassResult armorClass({
    required List<InventoryItem> inventory,
    required AbilityScores abilityScores,
    int otherBonus = 0,
  }) {
    final armor = effectiveArmor(inventory, abilityScores: abilityScores);
    final shield = equippedShield(inventory);

    return ArmorClassCalculator.calculate(
      armor: armor.option,
      abilityScores: abilityScores,
      hasShield: shield != null,
      // O escudo mágico soma junto com o bônus fixo de +2 do escudo.
      otherBonus: otherBonus + (shield?.magicBonus ?? 0),
      armorMagicBonus: armor.magicBonus,
      stealthDisadvantage: armor.stealthDisadvantage,
    );
  }

  static List<InventoryItem> _writeWearableEquipped(
    List<InventoryItem> inventory,
    InventoryItem? target,
  ) {
    final targetRow = target?.localId;

    return [
      for (final item in inventory)
        if (item.category != ItemCategory.armor ||
            item.itemId == ShieldOption.id)
          item
        else if (ArmorOption.fromId(item.itemId) == null)
          item
        else
          item.copyWith(equipped: _isSameRow(item, target, targetRow)),
    ];
  }

  static bool _isOffender(InventoryItem item, Map<int?, InventoryItem> rows) {
    if (rows.containsKey(item.localId) && item.localId != null) return true;
    // Item ainda não gravado não tem id: casa pela identidade do objeto.
    return rows.values.any((other) => identical(other, item));
  }

  /// Casa a linha por [InventoryItem.localId] quando existe e cai na
  /// identidade do objeto quando o item ainda não foi gravado — que é o caso
  /// durante a criação, onde nenhum item tem id ainda.
  static bool _isSameRow(InventoryItem item, InventoryItem? target, int? row) {
    if (target == null) return false;
    if (row != null) return item.localId == row;
    return identical(item, target);
  }
}
