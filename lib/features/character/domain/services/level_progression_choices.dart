import 'package:dnd_ficha_app/features/character/domain/entities/ability_score_improvement.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';

/// O que foi escolhido numa progressão de nível.
enum LevelProgressionKind {
  /// Ainda não escolhido.
  pending('pending', 'Escolha pendente'),

  /// Talento.
  feat('feat', 'Talento'),

  /// Incremento no Valor de Atributo.
  improvement('improvement', 'Incremento no Valor de Atributo');

  const LevelProgressionKind(this.id, this.label);

  final String id;
  final String label;
}

/// Uma escolha de progressão: um nível que concede talento OU incremento.
///
/// Representa a VAGA, não a decisão: uma vaga sem nada escolhido é justamente
/// a pendência que a ficha precisa mostrar. É o mesmo formato de
/// `PendingSubclassChoice`, pelo mesmo motivo — a ficha trata as duas
/// pendências igual.
class LevelProgressionSlot {
  const LevelProgressionSlot({
    required this.classId,
    required this.className,
    required this.classLevel,
    this.feat,
    this.improvement,
    this.fromRace = false,
  });

  /// Classe que concede. Vazia na vaga concedida pela raça.
  final String classId;

  final String className;

  /// Nível NA CLASSE que concede. Zero na vaga da raça.
  final int classLevel;

  /// Talento escolhido nesta vaga, quando foi um talento.
  final CharacterFeat? feat;

  /// Incremento escolhido nesta vaga, quando foi um incremento.
  final AbilityScoreImprovement? improvement;

  /// Se a vaga veio da raça, e não de um nível de classe.
  final bool fromRace;

  LevelProgressionKind get kind {
    if (improvement != null) return LevelProgressionKind.improvement;
    if (feat != null) return LevelProgressionKind.feat;
    return LevelProgressionKind.pending;
  }

  bool get isPending => kind == LevelProgressionKind.pending;

  /// Se a vaga aceita um Incremento no Valor de Atributo.
  ///
  /// A vaga da raça não aceita: o Humano Variante ganha um TALENTO no 1º
  /// nível, não a troca por atributo. Oferecer o incremento ali inventaria uma
  /// regra que o livro não tem.
  bool get allowsImprovement => !fromRace;

  String get progressionId => fromRace
      ? 'feat.race'
      : AbilityScoreImprovement.progressionIdFor(
          classId: classId,
          level: classLevel,
        );

  /// Como a ficha identifica a vaga: `Guerreiro 4`, ou `Raça` na da raça.
  String get label => fromRace ? 'Raça' : '$className $classLevel';

  LevelProgressionSlot copyWith({
    CharacterFeat? feat,
    AbilityScoreImprovement? improvement,
  }) {
    return LevelProgressionSlot(
      classId: classId,
      className: className,
      classLevel: classLevel,
      feat: feat ?? this.feat,
      improvement: improvement ?? this.improvement,
      fromRace: fromRace,
    );
  }
}

/// Monta as vagas de progressão do personagem e diz quais estão em aberto.
///
/// Por que existe: a ficha já sabia CONTAR escolhas de talento, mas não sabia
/// a qual nível cada uma pertencia. Sem isso não há como registrar "Guerreiro
/// 4 — Incremento: Força +2" nem como oferecer a escolha no nível certo num
/// personagem multiclasse.
///
/// A associação entre o que foi escolhido e a vaga é feita aqui, e em três
/// passadas, porque o dado histórico não é uniforme:
///
/// 1. incrementos casam por classe e nível exatos, que é o que eles gravam;
/// 2. talentos casam por classe e nível quando os dois batem com uma vaga;
/// 3. o que sobrou preenche as vagas mais antigas ainda livres.
///
/// O passo 3 é o que mantém fichas antigas coerentes: até esta versão o
/// talento era gravado com o nível TOTAL do personagem, não o da classe, então
/// casar por igualdade deixaria quase todo talento antigo órfão — e a ficha
/// ofereceria de novo uma escolha já gasta.
class LevelProgressionChoices {
  const LevelProgressionChoices._();

  static List<LevelProgressionSlot> forCharacter(
    Character character,
    List<ClassEntry> classes, {
    List<RaceEntry> races = const [],
  }) {
    final slots = <LevelProgressionSlot>[];

    for (final classLevel in character.classLevels) {
      final entry = _classById(classes, classLevel.classId);
      if (entry == null) continue;

      final className = entry.name;
      final granted =
          entry.featLevels.where((level) => level <= classLevel.level).toList()
            ..sort();

      for (final level in granted) {
        slots.add(
          LevelProgressionSlot(
            classId: classLevel.classId,
            className: className,
            classLevel: level,
          ),
        );
      }
    }

    if (_raceGrantsFeat(character, races)) {
      slots.add(
        const LevelProgressionSlot(
          classId: '',
          className: 'Raça',
          classLevel: 0,
          fromRace: true,
        ),
      );
    }

    return _assign(slots, character);
  }

  /// Só as vagas em aberto.
  static List<LevelProgressionSlot> pendingFor(
    Character character,
    List<ClassEntry> classes, {
    List<RaceEntry> races = const [],
  }) {
    return forCharacter(character, classes, races: races)
        .where((slot) => slot.isPending)
        .toList(growable: false);
  }

  /// A próxima vaga em aberto, que é a que a ficha oferece.
  static LevelProgressionSlot? nextPending(
    Character character,
    List<ClassEntry> classes, {
    List<RaceEntry> races = const [],
  }) {
    final pending = pendingFor(character, classes, races: races);
    return pending.isEmpty ? null : pending.first;
  }

  /// Vagas já resolvidas, para a ficha listar o histórico.
  static List<LevelProgressionSlot> resolvedFor(
    Character character,
    List<ClassEntry> classes, {
    List<RaceEntry> races = const [],
  }) {
    return forCharacter(character, classes, races: races)
        .where((slot) => !slot.isPending)
        .toList(growable: false);
  }

  static List<LevelProgressionSlot> _assign(
    List<LevelProgressionSlot> slots,
    Character character,
  ) {
    final result = List<LevelProgressionSlot>.from(slots);
    final takenIndexes = <int>{};

    // 1ª passada: incremento casa por classe e nível, que é o que ele grava.
    for (final improvement in character.abilityImprovements) {
      final index = _indexOf(
        result,
        takenIndexes,
        classId: improvement.classId,
        classLevel: improvement.classLevel,
      );
      if (index == null) continue;

      result[index] = result[index].copyWith(improvement: improvement);
      takenIndexes.add(index);
    }

    // 2ª passada: talento com classe e nível que batem com uma vaga.
    final unmatchedFeats = <CharacterFeat>[];
    for (final feat in character.feats) {
      final classId = feat.classId;
      final level = feat.level;

      if (classId == null || level == null) {
        unmatchedFeats.add(feat);
        continue;
      }

      final index = _indexOf(
        result,
        takenIndexes,
        classId: classId,
        classLevel: level,
      );

      if (index == null) {
        unmatchedFeats.add(feat);
        continue;
      }

      result[index] = result[index].copyWith(feat: feat);
      takenIndexes.add(index);
    }

    // 3ª passada: o que sobrou vai para a vaga livre mais antiga. Preferimos a
    // vaga da própria classe do talento, quando ele declara uma.
    for (final feat in unmatchedFeats) {
      final index =
          _firstFree(result, takenIndexes, classId: feat.classId) ??
          _firstFree(result, takenIndexes);
      if (index == null) continue;

      result[index] = result[index].copyWith(feat: feat);
      takenIndexes.add(index);
    }

    return List<LevelProgressionSlot>.unmodifiable(result);
  }

  static int? _indexOf(
    List<LevelProgressionSlot> slots,
    Set<int> taken, {
    required String classId,
    required int classLevel,
  }) {
    for (var index = 0; index < slots.length; index++) {
      if (taken.contains(index)) continue;
      final slot = slots[index];
      if (slot.classId == classId && slot.classLevel == classLevel) {
        return index;
      }
    }
    return null;
  }

  static int? _firstFree(
    List<LevelProgressionSlot> slots,
    Set<int> taken, {
    String? classId,
  }) {
    for (var index = 0; index < slots.length; index++) {
      if (taken.contains(index)) continue;
      if (classId != null && slots[index].classId != classId) continue;
      return index;
    }
    return null;
  }

  /// Se a raça do personagem concede um talento.
  ///
  /// Mesma comparação por id exato de `ManageCharacterFeats`: o talento do
  /// Humano Variante é dele, não de "humano" em geral.
  static bool _raceGrantsFeat(Character character, List<RaceEntry> races) {
    final speciesId = character.speciesId;
    if (speciesId == null || speciesId.isEmpty) return false;

    for (final race in races) {
      if (race.id == speciesId) return race.grantsFeat;
    }

    return false;
  }

  static ClassEntry? _classById(List<ClassEntry> classes, String id) {
    for (final item in classes) {
      if (item.id == id) return item;
    }
    return null;
  }
}
