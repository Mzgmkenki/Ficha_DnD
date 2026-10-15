import 'package:dnd_ficha_app/features/character/domain/services/granted_ability_increases.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Um Incremento no Valor de Atributo que o personagem recebeu num nível.
///
/// É um tipo PRÓPRIO de progressão, e não um talento fictício: as duas coisas
/// gastam a mesma escolha de nível, mas têm natureza diferente — o talento
/// aponta para o compêndio, o incremento é uma distribuição de pontos. Guardar
/// o incremento como "talento especial" obrigaria todo lugar que lê talentos a
/// filtrar esse caso, e faria a ficha listar um talento que não existe.
///
/// Guarda o que REALMENTE entrou em cada atributo, como [CharacterFeat] faz
/// com `appliedAbilityIncreases`, pelo mesmo motivo: sem isso, desfazer a
/// escolha não teria como saber o que devolver, e um atributo que estava no
/// teto seria rebaixado por um ponto que nunca recebeu.
class AbilityScoreImprovement {
  const AbilityScoreImprovement({
    required this.classId,
    required this.classLevel,
    required this.appliedIncreases,
    this.localId,
    String? progressionId,
  }) : _progressionId = progressionId;

  /// Chave da linha no banco. Nula em incremento recém-montado.
  final int? localId;

  /// Classe que concedeu a escolha.
  ///
  /// Obrigatória, e não opcional como em [CharacterFeat]: no multiclasse a
  /// escolha vem do nível DA CLASSE, então sem ela não há como dizer qual
  /// progressão foi gasta. É também o que mantém o caminho aberto para
  /// multiclasse sem remodelar nada.
  final String classId;

  /// Nível NA CLASSE em que a escolha foi feita, não o nível total.
  final int classLevel;

  /// Quanto este incremento somou em cada atributo, por nome de [Ability].
  final Map<String, int> appliedIncreases;

  final String? _progressionId;

  /// Identificador da progressão que concedeu a escolha.
  ///
  /// Derivado quando não foi informado, para fichas antigas e importadas não
  /// precisarem trazer o campo.
  String get progressionId =>
      _progressionId ?? progressionIdFor(classId: classId, level: classLevel);

  static String progressionIdFor({
    required String classId,
    required int level,
  }) => 'asi.$classId.$level';

  /// Quantos pontos este incremento distribuiu de fato.
  int get pointsApplied =>
      appliedIncreases.values.fold(0, (total, value) => total + value);

  bool get isEmpty => appliedIncreases.isEmpty;

  /// Os aumentos como pares de atributo e valor, na ordem do enum.
  ///
  /// Ordem fixa para a ficha não trocar "Força +1, Sabedoria +1" de lugar
  /// entre dois carregamentos do mesmo personagem.
  List<({Ability ability, int amount})> get increases {
    final result = <({Ability ability, int amount})>[];

    for (final ability in Ability.values) {
      final amount = appliedIncreases[ability.name];
      if (amount == null || amount <= 0) continue;
      result.add((ability: ability, amount: amount));
    }

    return result;
  }

  /// O resultado em texto: `Força +2` ou `Constituição +1, Sabedoria +1`.
  ///
  /// Vazio quando nada entrou, o que acontece quando todos os atributos
  /// escolhidos já estavam no teto.
  String get increasesLabel => increases
      .map((item) => '${item.ability.label} +${item.amount}')
      .join(', ');

  String get appliedIncreasesAsCsv =>
      GrantedAbilityIncreases.toCsv(appliedIncreases);

  AbilityScoreImprovement copyWith({
    int? localId,
    String? classId,
    int? classLevel,
    Map<String, int>? appliedIncreases,
    String? progressionId,
  }) {
    return AbilityScoreImprovement(
      localId: localId ?? this.localId,
      classId: classId ?? this.classId,
      classLevel: classLevel ?? this.classLevel,
      appliedIncreases: appliedIncreases ?? this.appliedIncreases,
      progressionId: progressionId ?? _progressionId,
    );
  }
}
