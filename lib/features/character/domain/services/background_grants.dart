import 'package:dnd_ficha_app/features/character/domain/entities/background_personality_choice.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency_grant.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_equipment.dart';

/// O que sobrou depois de aplicar ou trocar o antecedente.
///
/// Devolve também o que foi mexido, e não só o estado final, porque a tela
/// precisa avisar o jogador exatamente o que saiu e o que precisa ser refeito —
/// um aviso genérico de "suas escolhas foram perdidas" não diz o que fazer.
class BackgroundGrantResult {
  const BackgroundGrantResult({
    required this.inventory,
    required this.wallet,
    required this.currencyGrants,
    required this.personality,
    this.addedItems = const <InventoryItem>[],
    this.removedItems = const <InventoryItem>[],
    this.keptDivergedItems = const <InventoryItem>[],
    this.droppedChoices = const <BackgroundPersonalityChoice>[],
  });

  final List<InventoryItem> inventory;
  final Currency wallet;
  final List<CurrencyGrant> currencyGrants;
  final BackgroundPersonalitySelection personality;

  /// Itens que o novo antecedente acrescentou.
  final List<InventoryItem> addedItems;

  /// Itens do antecedente anterior que foram retirados.
  final List<InventoryItem> removedItems;

  /// Itens concedidos que o jogador havia mexido e por isso foram mantidos.
  ///
  /// A tela usa esta lista para explicar por que eles continuam ali.
  final List<InventoryItem> keptDivergedItems;

  /// Escolhas narrativas que não existem no antecedente novo.
  final List<BackgroundPersonalityChoice> droppedChoices;

  /// `true` quando nada mudou. Evita gravação e aviso à toa quando a tela
  /// reconstrói e reaplica o mesmo antecedente.
  bool get isUnchanged =>
      addedItems.isEmpty &&
      removedItems.isEmpty &&
      droppedChoices.isEmpty;

  /// `true` quando há algo que o jogador precisa saber.
  bool get needsPlayerAttention =>
      droppedChoices.isNotEmpty || keptDivergedItems.isNotEmpty;
}

/// Aplica o que o antecedente concede, mantendo o rastro da origem.
///
/// Toda a regra de "não duplicar, não apagar o que é de outra fonte e não
/// perder o que o jogador mexeu" mora aqui, fora dos widgets, e é pura: recebe
/// o estado e devolve o próximo. É o que permite testar a troca de antecedente
/// sem subir a interface.
class BackgroundGrants {
  const BackgroundGrants._();

  /// Origem usada em tudo o que o antecedente concede.
  static const GrantSource source = GrantSource.background;

  /// Rótulo de origem, no formato que a ficha mostra.
  static String labelFor(BackgroundEntry background) =>
      'Antecedente: ${background.name}';

  /// Monta o item de inventário correspondente a um equipamento concedido.
  static InventoryItem itemFor({
    required BackgroundEntry background,
    required BackgroundEquipmentItem equipment,
    bool atCreation = true,
  }) {
    return InventoryItem(
      itemId: equipment.id,
      name: equipment.name,
      quantity: equipment.quantity,
      category: equipment.category,
      source: source,
      sourceId: background.id,
      sourceLabel: labelFor(background),
      grantedAtCreation: atCreation,
      // Guardar a quantidade concedida é o que permite perceber depois que o
      // jogador consumiu ou acumulou unidades deste item.
      grantedQuantity: equipment.quantity,
    );
  }

  /// Monta o registro de moedas concedidas.
  static CurrencyGrant? currencyGrantFor({
    required BackgroundEntry background,
    bool atCreation = true,
  }) {
    final currency = background.grantedCurrency;
    if (currency.isEmpty) return null;

    return CurrencyGrant(
      source: source,
      currency: currency,
      sourceId: background.id,
      sourceLabel: labelFor(background),
      grantedAtCreation: atCreation,
    );
  }

  /// Aplica o antecedente sobre o estado atual.
  ///
  /// Serve tanto para a primeira aplicação quanto para a troca: o que o
  /// antecedente anterior havia concedido é identificado pela origem e sai, e o
  /// que o novo concede entra. Chamar duas vezes com o mesmo antecedente não
  /// muda nada — é isso que protege contra a tela reconstruir.
  ///
  /// Passar `background: null` limpa o que o antecedente havia concedido, sem
  /// encostar no resto.
  static BackgroundGrantResult apply({
    required BackgroundEntry? background,
    required List<InventoryItem> inventory,
    required Currency wallet,
    required List<CurrencyGrant> currencyGrants,
    BackgroundPersonalitySelection? personality,
    bool atCreation = true,
  }) {
    // O antecedente customizável não tem equipamento nem dinheiro no
    // compêndio: o que ele concede é escrito pelo jogador no próprio
    // personagem. Tratar como "nenhum antecedente" aqui evita conceder nada
    // por engano.
    final effective =
        (background == null || background.isCustom) ? null : background;

    // ------------------------------------------------------------ inventário
    //
    // O que o novo antecedente deve conceder, indexado pela chave estável de
    // origem. A chave nunca envolve o nome do item, que o jogador pode trocar.
    final targets = <String, InventoryItem>{};
    if (effective != null) {
      for (final equipment in effective.startingEquipment) {
        final item = itemFor(
          background: effective,
          equipment: equipment,
          atCreation: atCreation,
        );
        final key = item.grantKey;
        if (key != null) targets[key] = item;
      }
    }

    final kept = <InventoryItem>[];
    final removed = <InventoryItem>[];
    final keptDiverged = <InventoryItem>[];
    final alreadyPresent = <String>{};

    for (final item in inventory) {
      // Item manual e item de classe, raça ou talento não são assunto deste
      // serviço. Passam intactos.
      if (item.source != source) {
        kept.add(item);
        continue;
      }

      final key = item.grantKey;

      // Já é um dos que o novo antecedente concede: fica como está, com a
      // quantidade e o localId que já tinha. Remover e recriar perderia a
      // edição do jogador e trocaria a linha no banco sem necessidade.
      if (key != null && targets.containsKey(key)) {
        kept.add(item);
        alreadyPresent.add(key);
        continue;
      }

      // Veio de outro antecedente e o jogador mexeu nele. Apagar em silêncio
      // destruiria trabalho; fica, com a origem preservada para consulta, e
      // quem chamou recebe a lista para avisar.
      if (item.divergedFromGrant) {
        kept.add(item);
        keptDiverged.add(item);
        continue;
      }

      // Veio do antecedente anterior e está intocado: sai.
      removed.add(item);
    }

    final added = <InventoryItem>[];
    for (final entry in targets.entries) {
      if (alreadyPresent.contains(entry.key)) continue;
      added.add(entry.value);
    }

    // ---------------------------------------------------------------- moedas
    final ledger = CurrencyLedger.replaceSource(
      wallet: wallet,
      grants: currencyGrants,
      source: source,
      grant: effective == null
          ? null
          : currencyGrantFor(background: effective, atCreation: atCreation),
    );

    // --------------------------------------------------------- personalidade
    final current = personality ?? BackgroundPersonalitySelection.empty;
    final tables = effective?.personality;

    final List<BackgroundPersonalityChoice> dropped;
    final BackgroundPersonalitySelection nextPersonality;

    if (tables == null || tables.isEmpty) {
      // Sem tabelas não há escolha possível, então nada pode continuar válido.
      dropped = current.choices;
      nextPersonality = BackgroundPersonalitySelection.empty;
    } else {
      // Escolha que continua existindo nas tabelas novas sobrevive. Isso não é
      // detalhe: Acólito e Agente compartilham tabela, e trocar entre os dois
      // não deve obrigar o jogador a escolher tudo de novo.
      dropped = current.invalidFor(tables);
      nextPersonality = current.retainValidFor(tables);
    }

    return BackgroundGrantResult(
      inventory: List<InventoryItem>.unmodifiable([...kept, ...added]),
      wallet: ledger.wallet,
      currencyGrants: ledger.grants,
      personality: nextPersonality,
      addedItems: List<InventoryItem>.unmodifiable(added),
      removedItems: List<InventoryItem>.unmodifiable(removed),
      keptDivergedItems: List<InventoryItem>.unmodifiable(keptDiverged),
      droppedChoices: List<BackgroundPersonalityChoice>.unmodifiable(dropped),
    );
  }

  /// Mensagem para o jogador depois de uma troca de antecedente.
  ///
  /// Devolve `null` quando não há nada a avisar. O texto é montado aqui, e não
  /// no widget, para a mesma troca dar o mesmo aviso em qualquer tela.
  static String? changeNotice(BackgroundGrantResult result) {
    final parts = <String>[];

    if (result.droppedChoices.isNotEmpty) {
      parts.add(
        'as escolhas de personalidade precisam ser refeitas',
      );
    }

    if (result.keptDivergedItems.isNotEmpty) {
      final count = result.keptDivergedItems.length;
      parts.add(
        count == 1
            ? '1 item do antecedente anterior foi mantido porque você o editou'
            : '$count itens do antecedente anterior foram mantidos porque '
                'você os editou',
      );
    }

    if (parts.isEmpty) return null;

    final sentence = parts.join('; ');
    return '${sentence[0].toUpperCase()}${sentence.substring(1)}.';
  }
}
