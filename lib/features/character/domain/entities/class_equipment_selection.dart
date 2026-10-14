import 'package:dnd_ficha_app/features/compendium/domain/entities/class_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';

/// O que o jogador escolheu no equipamento inicial da classe.
///
/// Guarda só a decisão — qual alternativa de cada grupo e qual item de cada
/// escolha complementar —, nunca os itens resultantes. Os itens são derivados
/// disto por `ClassEquipmentGrants`, e é essa separação que torna a troca de
/// alternativa reversível: basta recalcular a partir da escolha nova.
///
/// Imutável, no mesmo espírito de `BackgroundPersonalitySelection`: cada
/// alteração devolve uma seleção nova, e a tela só troca a referência.
class ClassEquipmentSelection {
  const ClassEquipmentSelection({
    this.classId,
    this.chosenOptions = const <String, List<String>>{},
    this.picks = const <String, List<String?>>{},
  });

  static const ClassEquipmentSelection empty = ClassEquipmentSelection();

  /// Classe a que esta seleção pertence.
  ///
  /// Sem isso não haveria como perceber que a seleção guardada é de outra
  /// classe: os ids de grupo se repetem entre classes (`armor`, `pack`), e as
  /// escolhas do Guerreiro seriam lidas como se fossem do Clérigo.
  final String? classId;

  /// Alternativas escolhidas por grupo. A lista tem no máximo
  /// `ClassEquipmentGroup.choose` entradas.
  final Map<String, List<String>> chosenOptions;

  /// Itens escolhidos nas escolhas complementares, por chave de pick.
  ///
  /// A lista tem uma posição por item pedido, e `null` marca a posição ainda
  /// vazia. Posição em vez de conjunto porque o livro permite escolher a mesma
  /// arma duas vezes ("duas armas marciais" pode ser duas espadas longas), e
  /// um conjunto perderia a segunda.
  final Map<String, List<String?>> picks;

  /// Chave de uma escolha complementar do equipamento fixo.
  static String fixedPickKey(String pickId) => 'fixed|$pickId';

  /// Chave de uma escolha complementar que pertence a uma alternativa.
  ///
  /// Inclui a alternativa de propósito: trocar de alternativa no mesmo grupo
  /// troca a chave, e é isso que deixa a escolha antiga para trás em vez de
  /// aplicá-la à alternativa nova.
  static String groupPickKey({
    required String groupId,
    required String optionId,
    required String pickId,
  }) =>
      '$groupId|$optionId|$pickId';

  List<String> optionsFor(String groupId) =>
      chosenOptions[groupId] ?? const <String>[];

  bool hasOption(String groupId, String optionId) =>
      optionsFor(groupId).contains(optionId);

  /// A única alternativa escolhida no grupo, quando há uma.
  String? singleOptionFor(String groupId) {
    final options = optionsFor(groupId);
    return options.isEmpty ? null : options.first;
  }

  List<String?> slotsFor(String key, int count) {
    final current = picks[key];
    if (current == null) return List<String?>.filled(count, null);

    // Normaliza o tamanho: o asset pode ter mudado a quantidade pedida entre
    // duas versões do app, e a lista guardada não pode ditar o formato.
    return [
      for (var index = 0; index < count; index++)
        index < current.length ? current[index] : null,
    ];
  }

  String? slotAt(String key, int index) {
    final current = picks[key];
    if (current == null || index >= current.length) return null;
    return current[index];
  }

  /// Marca a classe, limpando tudo quando ela realmente mudou.
  ///
  /// Reaplicar a mesma classe preserva as escolhas: é o que impede a rolagem
  /// da tela e a reconstrução dos widgets de zerarem o que o jogador escolheu.
  ClassEquipmentSelection forClass(String? nextClassId) {
    if (nextClassId == classId) return this;
    return ClassEquipmentSelection(classId: nextClassId);
  }

  /// Marca a classe sem mexer nas escolhas.
  ///
  /// Serve para a seleção que acabou de sair da interface, que já é da classe
  /// certa mas pode não ter o id preenchido ainda. Diferente de [forClass], que
  /// descarta tudo quando a classe muda.
  ClassEquipmentSelection withClassId(String? nextClassId) {
    if (nextClassId == classId) return this;
    return ClassEquipmentSelection(
      classId: nextClassId,
      chosenOptions: chosenOptions,
      picks: picks,
    );
  }

  /// Escolhe (ou desmarca) uma alternativa.
  ///
  /// Com `choose: 1` a alternativa nova substitui a anterior. Com mais de uma,
  /// a alternativa já marcada é desmarcada e a nova entra até o limite.
  /// Em qualquer caso as escolhas complementares do grupo são descartadas:
  /// manter a arma marcial escolhida para "uma arma marcial e um escudo"
  /// depois de trocar para "duas armas marciais" deixaria uma escolha pela
  /// metade parecendo completa.
  ClassEquipmentSelection toggleOption({
    required String groupId,
    required String optionId,
    int choose = 1,
  }) {
    final current = optionsFor(groupId);
    final next = <String>[];

    if (current.contains(optionId)) {
      next.addAll(current.where((item) => item != optionId));
    } else if (choose <= 1) {
      next.add(optionId);
    } else {
      next.addAll(current);
      if (next.length >= choose) next.removeAt(0);
      next.add(optionId);
    }

    final options = Map<String, List<String>>.from(chosenOptions);
    if (next.isEmpty) {
      options.remove(groupId);
    } else {
      options[groupId] = List<String>.unmodifiable(next);
    }

    final keptPicks = <String, List<String?>>{};
    for (final entry in picks.entries) {
      final parts = entry.key.split('|');
      final belongsToGroup = parts.length == 3 && parts.first == groupId;
      // A escolha complementar sobrevive só se a alternativa dela continuar
      // marcada.
      if (belongsToGroup && !next.contains(parts[1])) continue;
      keptPicks[entry.key] = entry.value;
    }

    return ClassEquipmentSelection(
      classId: classId,
      chosenOptions: Map<String, List<String>>.unmodifiable(options),
      picks: Map<String, List<String?>>.unmodifiable(keptPicks),
    );
  }

  /// Preenche (ou limpa, com `itemId: null`) uma posição de escolha
  /// complementar.
  ClassEquipmentSelection withPick({
    required String key,
    required int index,
    required int count,
    required String? itemId,
  }) {
    final slots = slotsFor(key, count);
    if (index < 0 || index >= slots.length) return this;

    slots[index] = itemId;

    final next = Map<String, List<String?>>.from(picks);
    if (slots.every((item) => item == null)) {
      next.remove(key);
    } else {
      next[key] = List<String?>.unmodifiable(slots);
    }

    return ClassEquipmentSelection(
      classId: classId,
      chosenOptions: chosenOptions,
      picks: Map<String, List<String?>>.unmodifiable(next),
    );
  }

  /// Descarta o que não existe mais no equipamento informado.
  ///
  /// Serve para dado de asset corrigido entre duas versões do app: uma
  /// alternativa removida do livro não pode continuar valendo numa ficha em
  /// criação.
  ClassEquipmentSelection retainValidFor(
    ClassStartingEquipment? equipment,
    List<WeaponEntry> weapons,
  ) {
    if (equipment == null) return ClassEquipmentSelection(classId: classId);

    final options = <String, List<String>>{};
    final validPickKeys = <String, int>{};

    for (final pick in equipment.fixedPicks) {
      validPickKeys[fixedPickKey(pick.id)] = pick.count;
    }

    for (final group in equipment.groups) {
      final chosen = optionsFor(group.id)
          .where((id) => group.optionById(id) != null)
          .toList(growable: false);
      if (chosen.isEmpty) continue;

      options[group.id] = List<String>.unmodifiable(chosen);

      for (final optionId in chosen) {
        final option = group.optionById(optionId);
        if (option == null) continue;
        for (final pick in option.picks) {
          validPickKeys[groupPickKey(
            groupId: group.id,
            optionId: optionId,
            pickId: pick.id,
          )] = pick.count;
        }
      }
    }

    final allowedItemIds = <String, Set<String>>{};
    for (final pick in _allPicks(equipment)) {
      allowedItemIds[pick.key] = {
        for (final item in pick.pick.resolveOptions(weapons)) item.id,
      };
    }

    final keptPicks = <String, List<String?>>{};
    for (final entry in picks.entries) {
      final count = validPickKeys[entry.key];
      if (count == null) continue;

      final allowed = allowedItemIds[entry.key] ?? const <String>{};
      final slots = [
        for (var index = 0; index < count; index++)
          index < entry.value.length &&
                  entry.value[index] != null &&
                  allowed.contains(entry.value[index])
              ? entry.value[index]
              : null,
      ];

      if (slots.every((item) => item == null)) continue;
      keptPicks[entry.key] = List<String?>.unmodifiable(slots);
    }

    return ClassEquipmentSelection(
      classId: classId,
      chosenOptions: Map<String, List<String>>.unmodifiable(options),
      picks: Map<String, List<String?>>.unmodifiable(keptPicks),
    );
  }

  /// O que ainda falta escolher, em texto pronto para exibir.
  ///
  /// Lista vazia significa que a seleção está completa. Devolver a lista em vez
  /// de um booleano é o que permite dizer ao jogador exatamente o que falta,
  /// que é a diferença entre um aviso útil e um "preencha tudo".
  List<String> pendingLabels(
    ClassStartingEquipment? equipment,
    List<WeaponEntry> weapons,
  ) {
    if (equipment == null) return const <String>[];

    final pending = <String>[];

    for (final pick in equipment.fixedPicks) {
      final key = fixedPickKey(pick.id);
      final filled = slotsFor(key, pick.count).whereType<String>().length;
      if (filled < pick.count) {
        pending.add(
          pick.count == 1
              ? pick.label
              : '${pick.label} (${pick.progressLabel(filled)})',
        );
      }
    }

    for (final group in visibleGroups(equipment)) {
      final chosen = optionsFor(group.id);

      if (chosen.length < group.choose) {
        pending.add(
          group.label.isEmpty ? group.instructionLabel : group.label,
        );
        continue;
      }

      for (final optionId in chosen) {
        final option = group.optionById(optionId);
        if (option == null) continue;

        for (final pick in option.picks) {
          final key = groupPickKey(
            groupId: group.id,
            optionId: optionId,
            pickId: pick.id,
          );
          final filled = slotsFor(key, pick.count).whereType<String>().length;
          if (filled < pick.count) {
            pending.add(
              pick.count == 1
                  ? pick.label
                  : '${pick.label} (${pick.progressLabel(filled)})',
            );
          }
        }
      }
    }

    return List<String>.unmodifiable(pending);
  }

  /// Grupos que valem para esta seleção.
  ///
  /// Grupo que depende de uma alternativa de outro grupo só aparece quando
  /// aquela alternativa está escolhida.
  List<ClassEquipmentGroup> visibleGroups(ClassStartingEquipment equipment) {
    return [
      for (final group in equipment.groups)
        if (_isGroupVisible(group)) group,
    ];
  }

  bool _isGroupVisible(ClassEquipmentGroup group) {
    final required = group.requiresOptionId;
    if (required == null) return true;

    for (final chosen in chosenOptions.values) {
      if (chosen.contains(required)) return true;
    }
    return false;
  }

  /// `true` quando não falta nenhuma escolha obrigatória.
  bool isComplete(
    ClassStartingEquipment? equipment,
    List<WeaponEntry> weapons,
  ) =>
      pendingLabels(equipment, weapons).isEmpty;

  /// Mensagem única de pendência, ou `null` quando está tudo escolhido.
  String? validationError(
    ClassStartingEquipment? equipment,
    List<WeaponEntry> weapons,
  ) {
    final pending = pendingLabels(equipment, weapons);
    if (pending.isEmpty) return null;

    if (pending.length == 1) {
      return 'Falta escolher: ${pending.first}.';
    }
    return 'Faltam ${pending.length} escolhas de equipamento: '
        '${pending.join('; ')}.';
  }

  List<_KeyedPick> _allPicks(ClassStartingEquipment equipment) {
    final result = <_KeyedPick>[];

    for (final pick in equipment.fixedPicks) {
      result.add(_KeyedPick(fixedPickKey(pick.id), pick));
    }

    for (final group in equipment.groups) {
      for (final option in group.options) {
        for (final pick in option.picks) {
          result.add(
            _KeyedPick(
              groupPickKey(
                groupId: group.id,
                optionId: option.id,
                pickId: pick.id,
              ),
              pick,
            ),
          );
        }
      }
    }

    return result;
  }

  @override
  String toString() =>
      'ClassEquipmentSelection($classId, ${chosenOptions.length} grupos, '
      '${picks.length} escolhas)';
}

class _KeyedPick {
  const _KeyedPick(this.key, this.pick);

  final String key;
  final ClassEquipmentPick pick;
}
