import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';

/// Os valores do personagem que uma fórmula de característica pode citar.
///
/// Vem pronto em vez de o avaliador receber o `Character` inteiro para a
/// fórmula poder ser testada sem montar uma ficha, e para ficar explícito o
/// que ela tem direito de ler.
class FeatureFormulaContext {
  const FeatureFormulaContext({
    required this.abilityScores,
    required this.proficiencyBonus,
    required this.totalLevel,
    this.classLevels = const {},
  });

  final AbilityScores abilityScores;
  final int proficiencyBonus;
  final int totalLevel;

  /// Nível em cada classe, por id. É o que permite `level.monk` significar o
  /// nível de monge e não o nível total — a distinção que o multiclasse exige.
  final Map<String, int> classLevels;

  factory FeatureFormulaContext.fromCharacter(Character character) {
    return FeatureFormulaContext(
      abilityScores: character.abilityScores,
      proficiencyBonus: character.proficiencyBonus,
      totalLevel: character.totalLevel,
      classLevels: {
        for (final item in character.classLevels) item.classId: item.level,
      },
    );
  }
}

/// Uma parcela da conta, para a ficha poder mostrar de onde o número saiu.
class FeatureFormulaTerm {
  const FeatureFormulaTerm({
    required this.label,
    required this.value,
  });

  /// Como a parcela aparece: `10`, `DES`, `CON`, `PB`.
  final String label;

  /// Quanto ela valeu, já com o sinal da operação.
  final int value;
}

/// O resultado de avaliar uma fórmula.
class FeatureFormulaResult {
  const FeatureFormulaResult({required this.value, required this.terms});

  final int value;
  final List<FeatureFormulaTerm> terms;

  /// A conta escrita, como a ficha mostra: `10 + DES +2 + CON +3 = 15`.
  ///
  /// Montada aqui para o gerenciamento de CA, o resumo de combate e o PDF
  /// dizerem exatamente a mesma frase.
  String get composition {
    if (terms.isEmpty) return '$value';

    final parts = <String>[];
    for (var index = 0; index < terms.length; index++) {
      final term = terms[index];
      final isNumeric = term.label == '${term.value}';

      if (index == 0) {
        parts.add(isNumeric ? '${term.value}' : '${term.label} ${_signed(term.value)}');
        continue;
      }

      final connector = term.value < 0 ? '-' : '+';
      final magnitude = term.value.abs();
      parts.add(
        isNumeric ? '$connector $magnitude' : '$connector ${term.label} $magnitude',
      );
    }

    return '${parts.join(' ')} = $value';
  }

  static String _signed(int value) => value >= 0 ? '+$value' : '$value';
}

/// Avalia as fórmulas declaradas nas características do compêndio.
///
/// Vocabulário pequeno de propósito. O levantamento escreve as contas que
/// importam como soma de parcelas simples — `10 + mod.DES + mod.CON`,
/// `13 + mod.DES`, `24` —, então não há motivo para um interpretador de
/// expressão completo, com precedência e parênteses, que seria mais superfície
/// para errar do que benefício.
///
/// Token desconhecido devolve `null`, e não zero. Isso é deliberado: um efeito
/// que o código não entende é descartado pelo resolvedor e a descrição da
/// característica continua dizendo a regra. Tratar como zero produziria uma CA
/// silenciosamente errada na ficha de alguém, que é muito pior que não
/// calcular.
class FeatureFormula {
  const FeatureFormula._();

  /// Abreviações em português aceitas no asset, além do nome do enum.
  ///
  /// O levantamento escreve `mod.DES` e `mod.SAB`; o resto do app usa o nome
  /// em inglês do enum. Aceitar os dois evita uma tradução no meio do dado.
  static const Map<String, Ability> _abilityAliases = {
    'for': Ability.strength,
    'des': Ability.dexterity,
    'con': Ability.constitution,
    'int': Ability.intelligence,
    'sab': Ability.wisdom,
    'car': Ability.charisma,
  };

  /// Avalia [formula] no contexto dado, ou `null` se não der para avaliar.
  static FeatureFormulaResult? evaluate(
    String? formula,
    FeatureFormulaContext context,
  ) {
    final text = formula?.trim();
    if (text == null || text.isEmpty) return null;

    // Normaliza para a separação por espaço funcionar com `10+mod.DES`.
    final spaced = text.replaceAll('+', ' + ').replaceAll('-', ' - ');
    final tokens = spaced
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (tokens.isEmpty) return null;

    final terms = <FeatureFormulaTerm>[];
    var sign = 1;
    var expectingOperand = true;

    for (final token in tokens) {
      if (token == '+' || token == '-') {
        // Dois operadores seguidos, ou operador no fim: dado malformado.
        if (expectingOperand) return null;
        sign = token == '+' ? 1 : -1;
        expectingOperand = true;
        continue;
      }

      if (!expectingOperand) return null;

      final term = _resolveToken(token, context);
      if (term == null) return null;

      terms.add(
        FeatureFormulaTerm(label: term.label, value: sign * term.value),
      );
      sign = 1;
      expectingOperand = false;
    }

    // Fórmula terminando em operador.
    if (expectingOperand) return null;

    final total = terms.fold(0, (sum, term) => sum + term.value);
    return FeatureFormulaResult(value: total, terms: terms);
  }

  /// Só o número, para quem não precisa mostrar a conta.
  static int? valueOf(String? formula, FeatureFormulaContext context) =>
      evaluate(formula, context)?.value;

  static FeatureFormulaTerm? _resolveToken(
    String token,
    FeatureFormulaContext context,
  ) {
    final normalized = token.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final literal = int.tryParse(normalized);
    if (literal != null) {
      return FeatureFormulaTerm(label: '$literal', value: literal);
    }

    if (normalized == 'pb' || normalized == 'proficiency') {
      return FeatureFormulaTerm(
        label: 'PB',
        value: context.proficiencyBonus,
      );
    }

    if (normalized.startsWith('mod.')) {
      final ability = _ability(normalized.substring(4));
      if (ability == null) return null;
      return FeatureFormulaTerm(
        label: ability.abbreviation,
        value: context.abilityScores.valueFor(ability).abilityModifier,
      );
    }

    if (normalized.startsWith('score.')) {
      final ability = _ability(normalized.substring(6));
      if (ability == null) return null;
      return FeatureFormulaTerm(
        label: ability.abbreviation,
        value: context.abilityScores.valueFor(ability),
      );
    }

    if (normalized.startsWith('level.')) {
      final key = normalized.substring(6);
      if (key == 'total') {
        return FeatureFormulaTerm(label: 'nível', value: context.totalLevel);
      }

      // Classe que o personagem não tem vale zero, não erro: a fórmula
      // continua válida, só não soma nada — é o que acontece ao citar o nível
      // de uma classe fora do multiclasse atual.
      final level = context.classLevels[key];
      if (level == null) {
        return const FeatureFormulaTerm(label: 'nível', value: 0);
      }
      return FeatureFormulaTerm(label: 'nível', value: level);
    }

    return null;
  }

  static Ability? _ability(String raw) {
    final key = raw.trim().toLowerCase();
    if (key.isEmpty) return null;

    final alias = _abilityAliases[key];
    if (alias != null) return alias;

    for (final ability in Ability.values) {
      if (ability.name == key) return ability;
    }

    return null;
  }
}
