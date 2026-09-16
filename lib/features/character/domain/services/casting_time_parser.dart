import 'package:dnd_ficha_app/features/character/domain/value_objects/combat_action_type.dart';

/// O que o tempo de conjuração de uma magia significa na economia do turno.
class CastingTime {
  const CastingTime({required this.actionType, this.trigger, this.note});

  /// Nulo quando a magia não cabe num turno de combate: 1 minuto, 10 minutos,
  /// 1 hora. Ela continua conjurável, só não entra na lista de ações.
  final CombatActionType? actionType;

  /// O gatilho da reação, extraído do próprio texto do asset.
  final String? trigger;

  /// Observação quando o tempo tem uma segunda forma, como "1 ação ou 8 horas".
  final String? note;

  bool get fitsInATurn => actionType != null;
}

/// Lê o campo `tempo` das magias e devolve o tipo de ação.
///
/// Existe porque este é o único metadado de economia de ação que o compêndio já
/// tem de graça: são centenas de magias com o tempo escrito em português, e
/// interpretar a string sai muito mais barato que cadastrar tudo de novo.
///
/// O texto vem de três arquivos diferentes e não é padronizado — aparecem
/// "Uma ação", "1 ação", "Uma ação bônus" e reações com o gatilho na mesma
/// frase, depois de uma vírgula.
class CastingTimeParser {
  const CastingTimeParser._();

  static CastingTime parse(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return const CastingTime(actionType: null);

    final normalized = _normalize(text);

    // Reação primeiro: o gatilho vem depois da vírgula, e o resto da frase
    // contém a palavra "ação" — testar ação antes classificaria errado.
    if (normalized.contains('reacao')) {
      return CastingTime(
        actionType: CombatActionType.reaction,
        trigger: _triggerFrom(text),
      );
    }

    // Bônus antes de ação, pela mesma razão: "uma ação bônus" contém "ação".
    if (normalized.contains('bonus')) {
      return CastingTime(
        actionType: CombatActionType.bonusAction,
        note: _alternativeFrom(text),
      );
    }

    if (_hasAction(normalized)) {
      return CastingTime(
        actionType: CombatActionType.action,
        note: _alternativeFrom(text),
      );
    }

    // Tempo longo: ritual, preparação, conjuração de minutos ou horas. Fica
    // fora da lista do turno de propósito.
    return CastingTime(actionType: null, note: text);
  }

  /// Se o texto fala de uma ação, e não de "1 minuto" ou "10 minutos".
  static bool _hasAction(String normalized) {
    return normalized.contains('acao');
  }

  /// O gatilho da reação, que no asset vem depois da primeira vírgula.
  ///
  /// Sem a vírgula não há gatilho declarado, e devolver nulo é melhor que
  /// devolver a frase inteira repetindo "uma reação".
  static String? _triggerFrom(String text) {
    final comma = text.indexOf(',');
    if (comma < 0 || comma + 1 >= text.length) return null;

    final trigger = text.substring(comma + 1).trim();
    if (trigger.isEmpty) return null;

    // Sobe a primeira letra: o trecho começa em minúscula no meio da frase.
    return trigger[0].toUpperCase() + trigger.substring(1);
  }

  /// A segunda forma de conjurar, em "Uma ação ou 8 horas".
  static String? _alternativeFrom(String text) {
    final normalized = _normalize(text);
    final index = normalized.indexOf(' ou ');
    if (index < 0) return null;

    return 'Também pode ser conjurada em '
        '${text.substring(index + 4).trim()}.';
  }

  /// Minúsculas e sem acento, para o `contains` não depender de como o arquivo
  /// escreveu a palavra.
  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }
}
