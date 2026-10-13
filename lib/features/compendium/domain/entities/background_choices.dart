import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

/// Perícias que o antecedente deixa o jogador escolher.
///
/// Diferente das perícias fixas (`BackgroundEntry.skillIds`): aqui o livro diz
/// "duas entre Enganação, Furtividade, Intuição e Persuasão". Fica guardado de
/// forma estruturada para não virar texto solto, mas a criação ainda não
/// oferece o seletor — conceder uma perícia que o jogador não escolheu seria
/// decidir por ele, então nada é concedido automaticamente a partir daqui.
class BackgroundSkillChoice {
  const BackgroundSkillChoice({
    required this.count,
    this.label,
    this.skillIds = const <String>[],
  });

  /// Quantas perícias o jogador escolhe.
  final int count;

  /// Texto do livro que descreve a escolha.
  final String? label;

  /// Ids das perícias candidatas (ver [Skill.id]).
  final List<String> skillIds;

  bool get isEmpty => count <= 0 || skillIds.isEmpty;

  /// Candidatas resolvidas para o enum de domínio, ignorando ids inválidos.
  List<Skill> get skills {
    final result = <Skill>[];
    for (final id in skillIds) {
      final skill = Skill.fromId(id);
      if (skill != null) result.add(skill);
    }
    return result;
  }
}

/// Uma linha de uma tabela auxiliar do antecedente.
class BackgroundTableOption {
  const BackgroundTableOption({required this.roll, required this.text});

  final int roll;
  final String text;
}

/// Tabela auxiliar que o antecedente oferece além da personalidade.
///
/// São as "outras escolhas previstas": tipo de guilda, especialidade do
/// criminoso, motivo do afastamento do eremita. Não têm efeito mecânico e por
/// isso não entram na validação da criação — ficam como referência na ficha,
/// para a mesa rolar ou escolher.
class BackgroundExtraChoice {
  const BackgroundExtraChoice({
    required this.id,
    required this.label,
    this.die = '',
    this.options = const <BackgroundTableOption>[],
  });

  final String id;
  final String label;

  /// Dado da tabela (`d6`, `d8`, `d10`, `d20`).
  final String die;

  final List<BackgroundTableOption> options;

  bool get isEmpty => options.isEmpty;
}

/// Uma das características alternativas do antecedente.
///
/// O Nobre escolhe entre Posição de Privilégio e Servos, e o Navegante entre
/// Passagem de Navio e Reputação Ruim. A característica declarada em
/// `BackgroundEntry.featureName` continua sendo a padrão; esta lista existe
/// para a alternativa não desaparecer.
class BackgroundFeatureOption {
  const BackgroundFeatureOption({
    required this.id,
    required this.name,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
}
