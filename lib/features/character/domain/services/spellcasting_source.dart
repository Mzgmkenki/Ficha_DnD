import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spellcasting_progression.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';

/// Quem concede a conjuração de uma linha de classe, já resolvido.
class SpellcastingSource {
  const SpellcastingSource({
    required this.type,
    required this.name,
    required this.startLevel,
    required this.fromSubclass,
    this.ability,
  });

  /// Progressão de espaços. Ver [SpellcastingProgression].
  final String type;

  /// Nome a exibir. É o da subclasse quando é ela que concede: "Trapaceiro
  /// Arcano" diz mais ao jogador que "Ladino", que nem conjura.
  final String name;

  /// Nível de classe a partir do qual a conjuração existe.
  final int startLevel;

  /// Se a concessão vem da subclasse, e não da classe.
  final bool fromSubclass;

  /// Atributo de conjuração declarado, como vem do asset. Nulo quando o asset
  /// não declara e quem chama precisa recorrer ao próprio padrão.
  final String? ability;

  /// Se a conjuração já está valendo com [level] níveis na classe.
  ///
  /// Falso para o Paladino de 1º nível: ele é conjurador, mas só ganha o
  /// primeiro espaço no 2º. Quem calcula espaços ainda quer contá-lo — é o que
  /// permite dizer "ainda sem slots" em vez de mostrar painel vazio —, e quem
  /// só lista CD e ataque mágico prefere omiti-lo.
  bool isActiveAt(int level) => level >= startLevel;
}

/// Resolve de onde vem a conjuração de uma linha de classe.
///
/// Existe porque a resposta não está só na classe. Ladino e Guerreiro declaram
/// `spellcasting_type: null`, mas Trapaceiro Arcano e Cavaleiro Arcano
/// conjuram como um-terço-conjuradores a partir do 3º nível — a concessão é da
/// subclasse.
///
/// Fica num lugar só porque três consumidores precisam da mesma resposta: o
/// cálculo de espaços, o resumo de conjuração da ficha e o PDF. Enquanto cada
/// um resolvia por conta própria, o resumo da ficha carregava um `switch` por
/// id de subclasse que nunca era alcançado.
abstract final class SpellcastingSourceResolver {
  /// A conjuração concedida para [classLevel], ou nulo se não houver nenhuma.
  ///
  /// A classe tem prioridade sobre a subclasse: uma subclasse de conjurador
  /// não substitui a progressão da classe, só acrescenta magias.
  ///
  /// NÃO filtra por nível: devolve a concessão mesmo que ela só comece a valer
  /// mais tarde. Quem precisa do corte usa [SpellcastingSource.isActiveAt] —
  /// é essa separação que mantém o Paladino de 1º nível contando como
  /// conjurador sem espaços, em vez de desaparecer do painel.
  static SpellcastingSource? resolve({
    required ClassLevel classLevel,
    required List<ClassEntry> classes,
    List<SubclassEntry> subclasses = const [],
  }) {
    final classEntry = _classById(classes, classLevel.classId);
    final fromClass = SpellcastingProgression.normalize(
      classEntry?.spellcastingType,
    );

    if (fromClass != null) {
      return SpellcastingSource(
        type: fromClass,
        name: classEntry?.name ?? classLevel.classId,
        startLevel: SpellcastingProgression.startLevel(fromClass),
        fromSubclass: false,
        ability: classEntry?.spellcastingAbility,
      );
    }

    final subclass = _subclassById(subclasses, classLevel.subclassId);
    final granted = subclass?.spellcasting;
    if (subclass == null || granted == null || !granted.isCasting) return null;

    return SpellcastingSource(
      type: SpellcastingProgression.normalize(granted.type)!,
      name: subclass.name,
      startLevel: granted.startLevel,
      fromSubclass: true,
      ability: granted.ability,
    );
  }

  static ClassEntry? _classById(List<ClassEntry> classes, String id) {
    for (final item in classes) {
      if (item.id == id) return item;
    }
    return null;
  }

  static SubclassEntry? _subclassById(
    List<SubclassEntry> subclasses,
    String? id,
  ) {
    if (id == null) return null;
    for (final item in subclasses) {
      if (item.id == id) return item;
    }
    return null;
  }
}
