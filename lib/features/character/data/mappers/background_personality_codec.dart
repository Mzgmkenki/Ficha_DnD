import 'dart:convert';

import 'package:dnd_ficha_app/features/character/domain/entities/background_personality_choice.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_personality.dart';

/// Converte as escolhas narrativas do antecedente para a coluna JSON e de
/// volta.
///
/// Mesma escolha do `CharacterCreationMetadataCodec`: JSON numa coluna só,
/// porque o conjunto é pequeno, é sempre lido e gravado inteiro, e cada entrada
/// tem dois campos alternativos. A leitura é tolerante de propósito — dado
/// ilegível devolve lista vazia em vez de impedir o personagem de abrir.
class BackgroundPersonalityCodec {
  const BackgroundPersonalityCodec._();

  static String encode(List<BackgroundPersonalityChoice> choices) {
    return jsonEncode([
      for (final choice in choices)
        if (!choice.isEmpty)
          <String, Object?>{
            'category': choice.category.id,
            'optionId': choice.optionId,
            'customText': choice.customText,
          },
    ]);
  }

  static List<BackgroundPersonalityChoice> decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final result = <BackgroundPersonalityChoice>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);

        // Categoria desconhecida é descartada: sem ela a escolha não tem onde
        // aparecer na tela.
        final category = PersonalityCategory.fromId(map['category'] as String?);
        if (category == null) continue;

        final optionId = (map['optionId'] as String?)?.trim();
        final customText = (map['customText'] as String?)?.trim();

        final choice = BackgroundPersonalityChoice(
          category: category,
          optionId: optionId == null || optionId.isEmpty ? null : optionId,
          customText:
              customText == null || customText.isEmpty ? null : customText,
        );

        if (!choice.isEmpty) result.add(choice);
      }

      return List<BackgroundPersonalityChoice>.unmodifiable(result);
    } on FormatException {
      // Coluna corrompida não pode travar a ficha.
      return const [];
    }
  }
}
