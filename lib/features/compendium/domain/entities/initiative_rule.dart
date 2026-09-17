import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Como o bônus de proficiência entra na iniciativa.
enum InitiativeProficiencyUse {
  /// O bônus inteiro. Ex.: Gatilho de Lebre do harengon.
  full('full'),

  /// Metade, arredondada para baixo. Ex.: Pau para Toda Obra do bardo, que
  /// vale para qualquer teste de atributo sem proficiência — e a iniciativa é
  /// um teste de Destreza.
  half('half');

  const InitiativeProficiencyUse(this.id);
  final String id;

  static InitiativeProficiencyUse? fromId(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in InitiativeProficiencyUse.values) {
      if (item.id == normalized) return item;
    }
    return null;
  }
}

/// O que uma característica, traço racial ou talento faz com a iniciativa.
///
/// Existe para as regras especiais ficarem no asset, e não em condicional por
/// nome de subclasse espalhada pela interface. Sem isso, "Emboscador Terrível
/// soma Sabedoria" viraria um `if (subclassId == 'gloom_stalker')` dentro de
/// um widget.
///
/// Formato no asset, em snake_case como o resto do compêndio:
///
/// ```json
/// {
///   "name": "Emboscador Terrível",
///   "description": "Soma o modificador de Sabedoria à iniciativa. ...",
///   "initiative": { "ability": "wisdom" }
/// }
/// ```
///
/// Campos aceitos, todos opcionais e combináveis:
///
/// - `ability`: nome do atributo cujo modificador entra além da Destreza;
/// - `proficiency`: `full` ou `half`, para o bônus de proficiência;
/// - `bonus`: valor fixo, como o +5 do talento Alerta;
/// - `advantage`: vantagem na rolagem, como Instinto Feral do bárbaro;
/// - `note`: rótulo curto da origem, quando ela não tem nome próprio (é o caso
///   dos traços raciais, que ficam no nível da raça e não do traço).
///
/// A ausência do bloco é o caso normal: a esmagadora maioria das
/// características não mexe em iniciativa.
class InitiativeRule {
  const InitiativeRule({
    this.ability,
    this.proficiency,
    this.bonus,
    this.advantage = false,
    this.note,
  });

  /// Atributo somado além da Destreza.
  ///
  /// Não substitui a Destreza: em 2014 nenhuma característica troca o atributo
  /// da iniciativa, elas somam por cima. Emboscador Terrível é DES + SAB.
  final Ability? ability;

  final InitiativeProficiencyUse? proficiency;

  /// Valor fixo somado.
  final int? bonus;

  /// Vantagem na jogada. Não é bônus numérico e por isso não entra na soma.
  final bool advantage;

  /// Rótulo da origem, quando não vem do nome da característica.
  final String? note;

  /// Se a regra não faz nada. Bloco vazio no asset é erro de preenchimento, e
  /// descartar aqui evita uma linha sem efeito na composição da ficha.
  bool get isEmpty =>
      ability == null &&
      proficiency == null &&
      (bonus ?? 0) == 0 &&
      !advantage;

  /// Lê o bloco `initiative` do asset. Nulo quando não existe ou não faz nada.
  ///
  /// Tolerante como o resto do compêndio: valor irreconhecível é ignorado em
  /// vez de derrubar a leitura das outras características.
  static InitiativeRule? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final noteRaw = raw['note']?.toString().trim();

    int? number(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    final rule = InitiativeRule(
      ability: Ability.fromName(raw['ability']?.toString().trim()),
      proficiency: InitiativeProficiencyUse.fromId(
        raw['proficiency']?.toString(),
      ),
      bonus: number(raw['bonus']),
      advantage: raw['advantage'] == true,
      note: noteRaw == null || noteRaw.isEmpty ? null : noteRaw,
    );

    return rule.isEmpty ? null : rule;
  }
}
