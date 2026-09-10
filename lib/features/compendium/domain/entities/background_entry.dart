import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

/// Antecedente (background) do personagem.
///
/// Concede duas proficiências em perícia, idiomas, ferramentas, uma
/// característica narrativa e ouro inicial.
class BackgroundEntry {
  const BackgroundEntry({
    required this.id,
    required this.name,
    required this.skillIds,
    this.description,
    this.languages = 0,
    this.tools = const [],
    this.featureName,
    this.featureDescription,
    this.startingGold = 0,
    this.source = 'phb',
  });

  /// Id reservado para o antecedente montado pelo próprio jogador.
  ///
  /// Não existe no compêndio: as perícias e as características ficam
  /// guardadas no personagem (ver `Character.customBackground`).
  static const String customId = 'custom';

  /// Opção sintética exibida no seletor de antecedentes.
  static const BackgroundEntry customOption = BackgroundEntry(
    id: customId,
    name: 'Antecedente Customizável',
    description: 'Monte o seu próprio antecedente: escolha as perícias e '
        'descreva as características dele.',
    skillIds: [],
    source: 'custom',
  );

  final String id;
  final String name;
  final String? description;

  /// Ids das perícias concedidas (ver [Skill.id]).
  final List<String> skillIds;

  /// Quantidade de idiomas adicionais à escolha do jogador.
  final int languages;

  final List<String> tools;
  final String? featureName;
  final String? featureDescription;
  final int startingGold;
  final String source;

  /// `true` quando é a opção de antecedente criado pelo jogador.
  bool get isCustom => id == customId;

  /// Perícias resolvidas para o enum de domínio, ignorando ids inválidos.
  List<Skill> get skills {
    final result = <Skill>[];
    for (final id in skillIds) {
      final skill = Skill.fromId(id);
      if (skill != null) result.add(skill);
    }
    return result;
  }
}
