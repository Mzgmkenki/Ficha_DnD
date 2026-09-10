import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

/// Antecedente montado pelo próprio jogador.
///
/// Diferente dos antecedentes do compêndio, este não é dado de referência:
/// ele pertence ao personagem, então nome, perícias escolhidas e o texto de
/// características ficam guardados junto da ficha.
class CustomBackground {
  const CustomBackground({
    this.name,
    this.skillIds = const [],
    this.features = '',
  });

  /// Nome dado pelo jogador. Quando vazio, a ficha usa [fallbackName].
  final String? name;

  /// Ids das perícias concedidas (ver [Skill.id]).
  final List<String> skillIds;

  /// Texto livre com as características do antecedente.
  final String features;

  static const String fallbackName = 'Antecedente Customizável';

  /// Nome para exibição, já com o fallback aplicado.
  String get displayName {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? fallbackName : trimmed;
  }

  /// Perícias resolvidas para o enum de domínio, ignorando ids inválidos.
  List<Skill> get skills {
    final result = <Skill>[];
    for (final id in skillIds) {
      final skill = Skill.fromId(id);
      if (skill != null) result.add(skill);
    }
    return result;
  }

  /// `true` quando o jogador não preencheu nada.
  bool get isEmpty {
    return (name?.trim().isEmpty ?? true) &&
        skillIds.isEmpty &&
        features.trim().isEmpty;
  }

  bool get isNotEmpty => !isEmpty;

  /// Perícias em CSV, formato usado na coluna do banco.
  String get skillIdsAsCsv => skillIds.join(',');

  /// Lê o CSV persistido, descartando ids vazios.
  static List<String> parseSkillIdsCsv(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];

    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  CustomBackground copyWith({
    String? name,
    List<String>? skillIds,
    String? features,
  }) {
    return CustomBackground(
      name: name ?? this.name,
      skillIds: skillIds ?? this.skillIds,
      features: features ?? this.features,
    );
  }
}
