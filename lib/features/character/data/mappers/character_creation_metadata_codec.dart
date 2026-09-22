import 'dart:convert';

import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiency_grant.dart';
import 'package:dnd_ficha_app/features/character/domain/services/standard_array.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';

class CharacterCreationMetadataCodec {
  const CharacterCreationMetadataCodec._();

  static String? encodeBaseScores(AbilityScoreAllocation? allocation) {
    if (allocation == null) return null;
    return Ability.values
        .map(
          (ability) =>
              '${ability.name}:${allocation.baseScores.valueFor(ability)}',
        )
        .join(',');
  }

  static String? encodeOriginBonuses(AbilityScoreAllocation? allocation) {
    if (allocation == null) return null;
    return allocation.originBonuses.entries
        .where((entry) => entry.value > 0)
        .map((entry) => '${entry.key.name}:${entry.value}')
        .join(',');
  }

  static AbilityScoreAllocation? decodeAllocation(
    String? baseRaw,
    String? originRaw,
  ) {
    final base = _parseAbilityMap(baseRaw);
    if (!StandardArray.isValid(base)) return null;

    final origin = _parseAbilityMap(originRaw, allowPartial: true);
    return AbilityScoreAllocation(
      baseScores: StandardArray.toAbilityScores(base),
      originBonuses: origin,
    );
  }

  static Map<Ability, int> _parseAbilityMap(
    String? raw, {
    bool allowPartial = false,
  }) {
    if (raw == null || raw.trim().isEmpty) return const {};

    final result = <Ability, int>{};
    for (final part in raw.split(',')) {
      final pair = part.split(':');
      if (pair.length != 2) continue;
      final ability = Ability.fromName(pair.first.trim());
      final value = int.tryParse(pair.last.trim());
      if (ability == null || value == null) continue;
      if (allowPartial && value <= 0) continue;
      result[ability] = value;
    }
    return result;
  }

  static String encodeSkillGrants(List<SkillProficiencyGrant> grants) {
    return jsonEncode([
      for (final grant in grants)
        <String, Object>{
          'skill': grant.skill.id,
          'source': grant.source.name,
          'sourceId': grant.sourceId,
          'sourceLabel': grant.sourceLabel,
          'automatic': grant.automatic,
        },
    ]);
  }

  static List<SkillProficiencyGrant> decodeSkillGrants(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final result = <SkillProficiencyGrant>[];
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        final skill = Skill.fromId(item['skill'] as String?);
        final source = _sourceFromName(item['source'] as String?);
        final sourceId = item['sourceId'];
        final sourceLabel = item['sourceLabel'];
        if (skill == null ||
            source == null ||
            sourceId is! String ||
            sourceLabel is! String) {
          continue;
        }
        result.add(
          SkillProficiencyGrant(
            skill: skill,
            source: source,
            sourceId: sourceId,
            sourceLabel: sourceLabel,
            automatic: item['automatic'] == true,
          ),
        );
      }
      return result;
    } on FormatException {
      return const [];
    }
  }

  static SkillGrantSource? _sourceFromName(String? value) {
    for (final source in SkillGrantSource.values) {
      if (source.name == value) return source;
    }
    return null;
  }
}
