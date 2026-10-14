/// Normalização de texto usada para decidir identidade de magia.
///
/// Duas regras valem para tudo aqui.
///
/// A primeira: normalizar nunca altera o dado gravado, só a chave de
/// comparação. O asset continua com "Bênção" acentuado.
///
/// A segunda: esta normalização dobra mais que a do `SpellNameIndex` do app, e
/// é de propósito. Ela pode considerar iguais dois nomes que o app trataria
/// como diferentes ("Melfs" e "Melf's", por exemplo, que o app separa porque
/// troca apóstrofo por espaço). O erro de cada lado não custa o mesmo: acusar
/// duplicidade que não existe gasta uma linha de relatório, deixar passar uma
/// que existe coloca a mesma magia duas vezes na lista do jogador.
library;

/// Dobra o nome de uma magia para a forma de comparação.
///
/// Remove acento, caixa, pontuação, hífen, apóstrofo e espaço repetido. O
/// resultado não serve para exibir, só para comparar.
String normalizeSpellName(String value) {
  return foldAccents(value.trim().toLowerCase())
      // Apóstrofo desaparece em vez de virar espaço, para "Melf's Acid Arrow"
      // casar com "Melfs Acid Arrow". Trocar por espaço, como o app faz,
      // deixaria "melf s" de um lado e "melfs" do outro.
      .replaceAll(RegExp(r'''['’`´]'''), '')
      // Hífen e o resto da pontuação viram espaço, porque aí a separação de
      // palavra existe: "Green-Flame Blade" é "Green Flame Blade".
      .replaceAll(RegExp(r'''["“”.,;:!?/\\()\[\]{}\-–—_*]'''), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Troca letra acentuada pela equivalente sem acento.
///
/// Feito à mão em vez de `unorm`/ICU porque o projeto não tem dependência de
/// normalização Unicode e o conjunto de letras do português e do inglês cabe
/// numa tabela.
String foldAccents(String value) {
  const map = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
    'ý': 'y',
    'ÿ': 'y',
  };

  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(map[char] ?? char);
  }
  return buffer.toString();
}

/// Remove o possessivo do autor do nome da magia.
///
/// "Melf's Acid Arrow" e "Flecha Ácida de Melf" viram "Acid Arrow" e "Flecha
/// Ácida". Mesma regra do `SpellNameIndex`, para o importador casar os mesmos
/// pares que o app casa.
String withoutAuthor(String name) {
  final apostrophe = RegExp(r"^[\p{L}]+['’]s\s+", unicode: true);
  if (apostrophe.hasMatch(name)) {
    return name.replaceFirst(apostrophe, '');
  }

  final ofAuthor = RegExp(r'\s+d[eo]\s+[\p{L}]+$', unicode: true);
  if (ofAuthor.hasMatch(name)) {
    return name.replaceFirst(ofAuthor, '');
  }

  return name;
}

/// Grafia que o asset precisa ter para cada classe.
///
/// `CompendiumRepositoryImpl._mapClassName` lê o nome da classe por igualdade
/// com acento e **descarta em silêncio** o que não reconhece. Escrever
/// "Patrulheiro" no asset, que é o rótulo da UI, faz a magia sumir do filtro de
/// patrulheiro sem nenhum erro. Esta tabela existe para transformar isso num
/// aviso do importador em vez de um bug silencioso.
const Map<String, String> canonicalClassNames = {
  'barbaro': 'Bárbaro',
  'barbarian': 'Bárbaro',
  'bardo': 'Bardo',
  'bard': 'Bardo',
  'clerigo': 'Clérigo',
  'cleric': 'Clérigo',
  'druida': 'Druida',
  'druid': 'Druida',
  'guerreiro': 'Guerreiro',
  'fighter': 'Guerreiro',
  'monge': 'Monge',
  'monk': 'Monge',
  'paladino': 'Paladino',
  'paladin': 'Paladino',
  // O asset usa "Guardião"; "Patrulheiro" é só o rótulo da interface.
  'guardiao': 'Guardião',
  'patrulheiro': 'Guardião',
  'ranger': 'Guardião',
  'ladino': 'Ladino',
  'rogue': 'Ladino',
  'feiticeiro': 'Feiticeiro',
  'sorcerer': 'Feiticeiro',
  'bruxo': 'Bruxo',
  'warlock': 'Bruxo',
  'mago': 'Mago',
  'wizard': 'Mago',
  'artifice': 'Artífice',
  'artificer': 'Artífice',
};

/// Resolve a grafia da classe. Devolve nulo quando o nome é desconhecido.
String? canonicalClassName(String value) {
  final key = foldAccents(value.trim().toLowerCase());
  if (key.isEmpty) return null;
  return canonicalClassNames[key];
}

/// Lê o nível da magia aceitando número, "Truque" e "3º círculo".
///
/// Devolve nulo quando não dá para decidir. Quem chama transforma isso em
/// registro rejeitado, com o valor recebido no relatório.
int? parseSpellLevel(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is! String) return null;

  final text = foldAccents(value.trim().toLowerCase());
  if (text.isEmpty) return null;
  if (text == 'truque' || text == 'cantrip' || text == '0') return 0;

  // "3º círculo", "3o circulo", "3rd level", "nivel 3", "circulo 3".
  final digits = RegExp(r'\d+').firstMatch(text);
  if (digits == null) return null;
  return int.tryParse(digits.group(0)!);
}

/// Lê a página aceitando número e texto, porque o asset guarda texto.
///
/// `loadSpells` faz `spell['pagina'] as String?`: um número aqui derruba a
/// leitura dos quatro arquivos de magia, não só desta magia.
String? parseSpellPage(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.trim();
  if (value is int) return '$value';
  if (value is num) return '${value.toInt()}';
  return null;
}

/// Lê booleano aceitando "Sim"/"Não", "true"/"false", 1/0.
///
/// Devolve nulo quando o texto não é reconhecido, para o campo virar aviso em
/// vez de `false` calado.
bool? parseSpellBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is! String) return null;

  final text = foldAccents(value.trim().toLowerCase());
  if (text.isEmpty) return null;
  if (text == 'sim' || text == 's' || text == 'true' || text == '1') {
    return true;
  }
  if (text == 'nao' || text == 'n' || text == 'false' || text == '0') {
    return false;
  }
  return null;
}

/// Quebra uma lista escrita em texto: "Bruxo, Feiticeiro, Mago".
///
/// Aceita vírgula, ponto e vírgula e barra como separador, e trata travessão
/// solto ("—", "-", "N/A") como lista vazia, que é como as fontes escrevem
/// "nenhuma classe".
List<String> splitTextList(String? raw) {
  if (raw == null) return const [];

  final trimmed = raw.trim();
  if (trimmed.isEmpty) return const [];

  final folded = foldAccents(trimmed.toLowerCase());
  if (folded == '—' ||
      folded == '–' ||
      folded == '-' ||
      folded == 'n/a' ||
      folded == 'nenhuma' ||
      folded == 'nenhum' ||
      folded == 'none') {
    return const [];
  }

  return trimmed
      .split(RegExp(r'[,;/]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty && item != '—' && item != '-')
      .toList(growable: false);
}

/// Quebra uma lista que pode vir como texto ou como lista JSON.
List<String> coerceTextList(dynamic value) {
  if (value == null) return const [];
  if (value is String) return splitTextList(value);
  if (value is Iterable) {
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  return const [];
}

/// Une duas listas preservando a ordem e sem repetir.
///
/// Compara pela forma dobrada, então "Guardião" não entra duas vezes por causa
/// de um "Guardiao" vindo da fonte nova.
List<String> mergeTextLists(List<String> current, List<String> incoming) {
  final seen = <String>{};
  final result = <String>[];

  for (final item in [...current, ...incoming]) {
    final key = foldAccents(item.trim().toLowerCase());
    if (key.isEmpty || !seen.add(key)) continue;
    result.add(item.trim());
  }

  return result;
}

/// Resquício de HTML que o asset não deveria carregar.
///
/// Os assets antigos guardavam `<br>` e `&emsp;` dentro da descrição, e a ficha
/// mostrava o markup literal. `test/html_text_test.dart` guarda essa limpeza;
/// aqui o importador barra a entrada antes de o teste reclamar.
final RegExp htmlResidue = RegExp(r'<[^>]+>|&[a-zA-Z]+;|&#\d+;');
