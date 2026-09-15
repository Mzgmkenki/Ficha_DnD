import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';

/// Uma escolha de subclasse que o personagem alcançou e ainda não fez.
class PendingSubclassChoice {
  const PendingSubclassChoice({
    required this.classId,
    required this.className,
    required this.label,
    required this.level,
  });

  final String classId;
  final String className;

  /// Como a classe chama a subclasse: Domínio Divino, Arquétipo Marcial, etc.
  final String label;

  /// Nível do personagem nessa classe, para o resumo mostrar só as
  /// características já liberadas.
  final int level;
}

/// Diz quando a escolha de subclasse está em aberto.
///
/// A regra vive aqui porque os dois caminhos que mexem em nível — o atalho da
/// ficha e a tela de classes — precisam decidir igual. Antes ela era privada
/// dentro do caso de uso de subir de nível, e a tela de classes não tinha como
/// consultá-la.
class SubclassChoices {
  const SubclassChoices._();

  /// Se [classLevel] já destravou a subclasse e ela está vazia.
  ///
  /// A comparação é "já alcançou", não "acabou de alcançar". Um Clérigo que
  /// passou do 1º nível sem escolher o domínio continua com uma decisão em
  /// aberto, e as características dele seguem travadas até resolver — perguntar
  /// de novo é mais útil que deixar a ficha silenciosamente incompleta.
  static bool isPending(ClassLevel classLevel, ClassEntry? classEntry) {
    if (classEntry == null) return false;
    if (!classEntry.subclassUnlockedAt(classLevel.level)) return false;

    final chosen = classLevel.subclassId;
    return chosen == null || chosen.isEmpty;
  }

  /// Todas as escolhas em aberto do personagem, na ordem das classes.
  ///
  /// No multiclasse pode haver mais de uma: Clérigo 1 / Guerreiro 3 abre as
  /// duas de uma vez.
  static List<PendingSubclassChoice> pendingFor(
    Character character,
    List<ClassEntry> classes,
  ) {
    final result = <PendingSubclassChoice>[];

    for (final classLevel in character.classLevels) {
      final entry = entryFor(classes, classLevel.classId);
      if (!isPending(classLevel, entry)) continue;

      result.add(
        PendingSubclassChoice(
          classId: classLevel.classId,
          className: entry?.name ?? classLevel.classId,
          label: entry?.subclassLabelOrDefault ?? 'Subclasse',
          level: classLevel.level,
        ),
      );
    }

    return result;
  }

  /// A escolha em aberto de uma classe específica, ou nulo se não houver.
  static PendingSubclassChoice? pendingForClass(
    Character character,
    List<ClassEntry> classes,
    String classId,
  ) {
    for (final choice in pendingFor(character, classes)) {
      if (choice.classId == classId) return choice;
    }

    return null;
  }

  static ClassEntry? entryFor(List<ClassEntry> classes, String classId) {
    for (final item in classes) {
      if (item.id == classId) return item;
    }

    return null;
  }
}
