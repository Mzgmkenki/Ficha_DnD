import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_equipment_selection.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/services/owned_armor.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';

/// Um equipamento já resolvido a partir da seleção.
///
/// Quantidade agregada: quando dois grupos concedem o mesmo item — o Ladino que
/// pega espada curta no grupo 1 e "uma segunda espada curta" no grupo 2 —, o
/// resultado é uma linha com quantidade 2, e não duas linhas iguais. Isso é o
/// que mantém a chave de origem única e a seção de Armas legível.
class ResolvedClassEquipment {
  const ResolvedClassEquipment({
    required this.item,
    required this.grantRef,
    this.fromFixed = false,
  });

  final ClassEquipmentItem item;

  /// Grupo e alternativa que concederam o item (`martial|two_martial`), ou
  /// `fixed`. Com mais de uma procedência, vêm separadas por ` + `.
  final String grantRef;

  /// `true` quando ao menos uma das procedências é equipamento automático.
  final bool fromFixed;

  EquipmentDestination get destination => item.destination;
}

/// O que sobrou depois de aplicar, trocar ou limpar o equipamento da classe.
///
/// Devolve o estado final e também o diff, pelo mesmo motivo de
/// `BackgroundGrantResult`: a tela precisa dizer o que exatamente saiu e o que
/// foi preservado, não um aviso genérico.
class ClassEquipmentGrantResult {
  const ClassEquipmentGrantResult({
    required this.inventory,
    required this.weapons,
    required this.selection,
    this.addedItems = const <InventoryItem>[],
    this.removedItems = const <InventoryItem>[],
    this.keptDivergedItems = const <InventoryItem>[],
    this.addedWeapons = const <CharacterWeapon>[],
    this.removedWeapons = const <CharacterWeapon>[],
    this.keptDivergedWeapons = const <CharacterWeapon>[],
  });

  final List<InventoryItem> inventory;
  final List<CharacterWeapon> weapons;

  /// A seleção depois de descartar o que não existe na classe nova.
  final ClassEquipmentSelection selection;

  final List<InventoryItem> addedItems;
  final List<InventoryItem> removedItems;

  /// Itens concedidos que o jogador havia mexido e por isso foram mantidos.
  final List<InventoryItem> keptDivergedItems;

  final List<CharacterWeapon> addedWeapons;
  final List<CharacterWeapon> removedWeapons;
  final List<CharacterWeapon> keptDivergedWeapons;

  /// `true` quando nada mudou. Evita gravação e aviso à toa quando a tela
  /// reconstrói e reaplica a mesma classe.
  bool get isUnchanged =>
      addedItems.isEmpty &&
      removedItems.isEmpty &&
      addedWeapons.isEmpty &&
      removedWeapons.isEmpty;

  /// `true` quando há algo que o jogador precisa saber.
  bool get needsPlayerAttention =>
      keptDivergedItems.isNotEmpty || keptDivergedWeapons.isNotEmpty;
}

/// Aplica o equipamento inicial da classe, mantendo o rastro da origem.
///
/// Toda a regra de "não duplicar, não apagar o que é de outra fonte e não
/// perder o que o jogador mexeu" mora aqui, fora dos widgets, e é pura: recebe
/// o estado e devolve o próximo. É o que permite testar a troca de classe e a
/// troca de alternativa sem subir a interface.
///
/// Irmão de `BackgroundGrants`. Os dois não foram unificados porque o
/// antecedente concede uma lista fixa e dinheiro, enquanto a classe concede
/// por grupos de escolha e manda item para três áreas diferentes da ficha.
class ClassEquipmentGrants {
  const ClassEquipmentGrants._();

  /// Origem usada em tudo o que a classe concede.
  static const GrantSource source = GrantSource.characterClass;

  /// Referência de origem do equipamento recebido automaticamente.
  static const String fixedRef = 'fixed';

  /// Rótulo de origem, no formato que a ficha mostra.
  static String labelFor(String className) {
    final name = className.trim();
    if (name.isEmpty) return 'Equipamento inicial da classe';
    return 'Equipamento inicial da classe: $name';
  }

  /// Resolve a seleção nos equipamentos que ela concede.
  ///
  /// Serve tanto para montar o resumo na tela quanto para calcular o que vai
  /// para a ficha — a prévia e o resultado final saem da mesma função, e por
  /// isso não podem divergir. Escolha pendente simplesmente não produz item.
  static List<ResolvedClassEquipment> resolve({
    required ClassStartingEquipment? equipment,
    required ClassEquipmentSelection selection,
    required List<WeaponEntry> weaponCatalog,
  }) {
    if (equipment == null) return const <ResolvedClassEquipment>[];

    final aggregated = <String, _Aggregate>{};

    void add(ClassEquipmentItem item, String ref, {required bool fixed}) {
      final current = aggregated[item.id];
      if (current == null) {
        aggregated[item.id] = _Aggregate(item, ref, fixed);
        return;
      }
      current.quantity += item.quantity;
      current.addRef(ref);
      if (fixed) current.fromFixed = true;
    }

    void addPick(ClassEquipmentPick pick, String key, String ref) {
      final options = pick.resolveOptions(weaponCatalog);
      for (final chosenId in selection.slotsFor(key, pick.count)) {
        if (chosenId == null) continue;
        for (final option in options) {
          if (option.id != chosenId) continue;
          add(option, ref, fixed: ref == fixedRef);
          break;
        }
      }
    }

    for (final item in equipment.fixedItems) {
      add(item, fixedRef, fixed: true);
    }

    for (final pick in equipment.fixedPicks) {
      addPick(pick, ClassEquipmentSelection.fixedPickKey(pick.id), fixedRef);
    }

    for (final group in selection.visibleGroups(equipment)) {
      for (final optionId in selection.optionsFor(group.id)) {
        final option = group.optionById(optionId);
        if (option == null) continue;

        final ref = '${group.id}|${option.id}';

        for (final item in option.items) {
          add(item, ref, fixed: false);
        }

        for (final pick in option.picks) {
          addPick(
            pick,
            ClassEquipmentSelection.groupPickKey(
              groupId: group.id,
              optionId: option.id,
              pickId: pick.id,
            ),
            ref,
          );
        }
      }
    }

    return List<ResolvedClassEquipment>.unmodifiable([
      for (final entry in aggregated.values)
        ResolvedClassEquipment(
          item: entry.item.withQuantity(entry.quantity),
          grantRef: entry.refs.join(' + '),
          fromFixed: entry.fromFixed,
        ),
    ]);
  }

  /// Aplica o equipamento da classe sobre o estado atual.
  ///
  /// Serve para a primeira aplicação, para a troca de alternativa e para a
  /// troca de classe: o que a classe anterior havia concedido é identificado
  /// pela origem e sai, e o que a seleção atual concede entra. Chamar duas
  /// vezes com a mesma seleção não muda nada — é isso que protege contra a tela
  /// reconstruir e contra ir e voltar entre as etapas.
  ///
  /// Passar `equipment: null` limpa o que a classe havia concedido, sem
  /// encostar no resto. É o caminho da classe que não declara equipamento.
  static ClassEquipmentGrantResult apply({
    required ClassStartingEquipment? equipment,
    required ClassEquipmentSelection selection,
    required List<WeaponEntry> weaponCatalog,
    required List<InventoryItem> inventory,
    required List<CharacterWeapon> weapons,
    String className = '',
    bool atCreation = true,
    bool autoEquipArmor = true,
    AbilityScores? abilityScores,
  }) {
    final nextSelection =
        equipment == null
            ? ClassEquipmentSelection(classId: selection.classId)
            : selection.retainValidFor(equipment, weaponCatalog);

    final classId = equipment?.classId;
    final label = labelFor(className);

    final resolved = resolve(
      equipment: equipment,
      selection: nextSelection,
      weaponCatalog: weaponCatalog,
    );

    final itemTargets = <String, InventoryItem>{};
    final weaponTargets = <String, CharacterWeapon>{};

    for (final entry in resolved) {
      if (entry.destination == EquipmentDestination.weapon) {
        final weapon = _weaponFor(
          entry: entry,
          classId: classId,
          label: label,
          atCreation: atCreation,
        );
        final key = weapon.grantKey;
        if (key != null) weaponTargets[key] = weapon;
        continue;
      }

      final item = _itemFor(
        entry: entry,
        classId: classId,
        label: label,
        atCreation: atCreation,
      );
      final key = item.grantKey;
      if (key != null) itemTargets[key] = item;
    }

    final inventoryOutcome = _reconcileInventory(
      inventory: inventory,
      targets: itemTargets,
    );

    final weaponOutcome = _reconcileWeapons(
      weapons: weapons,
      targets: weaponTargets,
    );

    var nextInventory = inventoryOutcome.result;

    if (autoEquipArmor) {
      nextInventory = _autoEquip(
        inventory: nextInventory,
        granted: inventoryOutcome.addedKeys,
        abilityScores: abilityScores,
      );
    }

    return ClassEquipmentGrantResult(
      inventory: List<InventoryItem>.unmodifiable(nextInventory),
      weapons: List<CharacterWeapon>.unmodifiable(weaponOutcome.result),
      selection: nextSelection,
      addedItems: List<InventoryItem>.unmodifiable(inventoryOutcome.added),
      removedItems: List<InventoryItem>.unmodifiable(inventoryOutcome.removed),
      keptDivergedItems: List<InventoryItem>.unmodifiable(
        inventoryOutcome.keptDiverged,
      ),
      addedWeapons: List<CharacterWeapon>.unmodifiable(weaponOutcome.added),
      removedWeapons: List<CharacterWeapon>.unmodifiable(weaponOutcome.removed),
      keptDivergedWeapons: List<CharacterWeapon>.unmodifiable(
        weaponOutcome.keptDiverged,
      ),
    );
  }

  /// Mensagem para o jogador depois de uma troca de classe.
  ///
  /// Devolve `null` quando não há nada a avisar. O texto é montado aqui, e não
  /// no widget, para a mesma troca dar o mesmo aviso em qualquer tela.
  static String? changeNotice(ClassEquipmentGrantResult result) {
    final kept =
        result.keptDivergedItems.length + result.keptDivergedWeapons.length;
    if (kept == 0) return null;

    return kept == 1
        ? '1 equipamento da classe anterior foi mantido porque você o editou.'
        : '$kept equipamentos da classe anterior foram mantidos porque você '
            'os editou.';
  }

  static InventoryItem _itemFor({
    required ResolvedClassEquipment entry,
    required String? classId,
    required String label,
    required bool atCreation,
  }) {
    final item = entry.item;

    return InventoryItem(
      itemId: item.id,
      name: item.name,
      quantity: item.quantity,
      description: item.description,
      category: item.category,
      source: source,
      sourceId: classId,
      sourceLabel: label,
      grantedAtCreation: atCreation,
      // Guardar a quantidade concedida é o que permite perceber depois que o
      // jogador consumiu ou acumulou unidades deste item — munição, sobretudo.
      grantedQuantity: item.quantity,
      grantRef: entry.grantRef,
    );
  }

  static CharacterWeapon _weaponFor({
    required ResolvedClassEquipment entry,
    required String? classId,
    required String label,
    required bool atCreation,
  }) {
    final item = entry.item;

    return CharacterWeapon(
      localId: null,
      weaponId: item.weaponId!,
      quantity: item.quantity,
      source: source,
      sourceId: classId,
      sourceLabel: label,
      grantedAtCreation: atCreation,
      grantedQuantity: item.quantity,
      grantRef: entry.grantRef,
    );
  }

  /// Decide o que fica, o que sai e o que entra no inventário.
  ///
  /// Mesmo algoritmo de `BackgroundGrants.apply`, e deliberadamente: as duas
  /// fontes têm que se comportar igual para o jogador.
  static _Outcome<InventoryItem> _reconcileInventory({
    required List<InventoryItem> inventory,
    required Map<String, InventoryItem> targets,
  }) {
    final kept = <InventoryItem>[];
    final removed = <InventoryItem>[];
    final keptDiverged = <InventoryItem>[];
    final alreadyPresent = <String>{};

    for (final item in inventory) {
      // Item manual e item de antecedente, raça ou talento não são assunto
      // deste serviço. Passam intactos.
      if (item.source != source) {
        kept.add(item);
        continue;
      }

      final key = item.grantKey;
      final target = key == null ? null : targets[key];

      if (target != null) {
        alreadyPresent.add(key!);

        // O jogador mexeu: a versão dele vence. Sobrescrever apagaria o
        // trabalho dele sem avisar, e nada foi perdido para precisar avisar.
        if (item.divergedFromGrant) {
          kept.add(item);
          continue;
        }

        // Intocado: assume os valores da concessão atual, preservando a linha
        // no banco e o estado de equipado. É o que faz a quantidade acompanhar
        // a troca de alternativa (uma espada curta virando duas) sem recriar o
        // item.
        kept.add(
          target.copyWith(
            localId: item.localId,
            equipped: item.equipped,
            note: item.note,
          ),
        );
        continue;
      }

      // Veio de outra classe (ou de outra alternativa) e o jogador mexeu nele.
      // Apagar em silêncio destruiria trabalho; fica, com a origem preservada,
      // e quem chamou recebe a lista para avisar.
      if (item.divergedFromGrant) {
        kept.add(item);
        keptDiverged.add(item);
        continue;
      }

      removed.add(item);
    }

    final added = <InventoryItem>[];
    final addedKeys = <String>{};
    for (final entry in targets.entries) {
      if (alreadyPresent.contains(entry.key)) continue;
      added.add(entry.value);
      addedKeys.add(entry.key);
    }

    return _Outcome<InventoryItem>(
      result: [...kept, ...added],
      added: added,
      removed: removed,
      keptDiverged: keptDiverged,
      addedKeys: addedKeys,
    );
  }

  static _Outcome<CharacterWeapon> _reconcileWeapons({
    required List<CharacterWeapon> weapons,
    required Map<String, CharacterWeapon> targets,
  }) {
    final kept = <CharacterWeapon>[];
    final removed = <CharacterWeapon>[];
    final keptDiverged = <CharacterWeapon>[];
    final alreadyPresent = <String>{};

    for (final weapon in weapons) {
      if (weapon.source != source) {
        kept.add(weapon);
        continue;
      }

      final key = weapon.grantKey;
      final target = key == null ? null : targets[key];

      if (target != null) {
        alreadyPresent.add(key!);

        if (weapon.divergedFromGrant) {
          kept.add(weapon);
          continue;
        }

        kept.add(
          target.copyWith(
            localId: weapon.localId,
            // Preferência de empunhadura e apelido são decisão do jogador, não
            // da concessão: sobrescrever faria a espada longa voltar a uma mão
            // a cada recálculo.
            name: weapon.name,
            twoHanded: weapon.twoHanded,
            chosenAbility: weapon.chosenAbility,
            notes: weapon.notes,
          ),
        );
        continue;
      }

      if (weapon.divergedFromGrant) {
        kept.add(weapon);
        keptDiverged.add(weapon);
        continue;
      }

      removed.add(weapon);
    }

    final added = <CharacterWeapon>[];
    for (final entry in targets.entries) {
      if (alreadyPresent.contains(entry.key)) continue;
      added.add(entry.value);
    }

    return _Outcome<CharacterWeapon>(
      result: [...kept, ...added],
      added: added,
      removed: removed,
      keptDiverged: keptDiverged,
      addedKeys: const <String>{},
    );
  }

  /// Equipa a armadura e o escudo concedidos, quando não há conflito.
  ///
  /// Conflito é: o personagem já tem armadura equipada (de outra fonte ou
  /// escolhida à mão), ou a classe concedeu mais de uma armadura vestível. Nos
  /// dois casos a decisão é do jogador, e o item fica disponível no
  /// gerenciamento de CA em vez de ser vestido por conta própria.
  ///
  /// Sem [abilityScores] nenhuma armadura com requisito de Força é vestida
  /// automaticamente: na criação os atributos podem ainda não estar
  /// distribuídos, e vestir sem poder conferir produziria exatamente o estado
  /// inconsistente que `OwnedArmor` existe para evitar. A peça fica disponível,
  /// e a conferência final acontece ao concluir a criação.
  static List<InventoryItem> _autoEquip({
    required List<InventoryItem> inventory,
    required Set<String> granted,
    AbilityScores? abilityScores,
  }) {
    var result = inventory;

    final alreadyWearing =
        OwnedArmor.equippedWearable(result, abilityScores: abilityScores) !=
        null;
    if (!alreadyWearing) {
      final candidates = [
        for (final piece in OwnedArmor.wearables(result))
          if (piece.item.grantKey != null &&
              granted.contains(piece.item.grantKey))
            piece,
      ];

      // Sem atributos para conferir, a armadura fica disponível e não vestida:
      // é a opção que nunca produz ficha incoerente.
      if (candidates.length == 1 && abilityScores != null) {
        result =
            OwnedArmor.equipWearable(
              inventory: result,
              piece: candidates.single,
              abilityScores: abilityScores,
            ).inventory;
      }
    }

    if (!OwnedArmor.hasEquippedShield(result)) {
      final shields = [
        for (final piece in OwnedArmor.shields(result))
          if (piece.item.grantKey != null &&
              granted.contains(piece.item.grantKey))
            piece,
      ];

      if (shields.length == 1) {
        result = OwnedArmor.setShieldEquipped(
          inventory: result,
          equipped: true,
          piece: shields.single.item,
        );
      }
    }

    return result;
  }
}

/// Acumulador de quantidade e procedência durante a resolução.
class _Aggregate {
  _Aggregate(this.item, String ref, this.fromFixed)
    : quantity = item.quantity,
      refs = <String>[ref];

  final ClassEquipmentItem item;
  int quantity;
  final List<String> refs;
  bool fromFixed;

  void addRef(String ref) {
    if (refs.contains(ref)) return;
    refs.add(ref);
  }
}

class _Outcome<T> {
  const _Outcome({
    required this.result,
    required this.added,
    required this.removed,
    required this.keptDiverged,
    required this.addedKeys,
  });

  final List<T> result;
  final List<T> added;
  final List<T> removed;
  final List<T> keptDiverged;

  /// Chaves de origem do que acabou de entrar, usadas pelo auto-equipar.
  final Set<String> addedKeys;
}
