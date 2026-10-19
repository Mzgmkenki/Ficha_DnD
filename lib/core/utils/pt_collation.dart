/// Ordenação alfabética de texto em português.
///
/// Por que existe: `String.compareTo` compara ponto de código, e isso não é
/// ordem alfabética em português. `'á'` é 225 e `'r'` é 114, então o
/// `compareTo` cru coloca "Bardo" ANTES de "Bárbaro" — e qualquer lista de
/// classes ordenada assim sai errada na primeira linha. O mesmo vale para
/// maiúscula contra minúscula, porque `'Z'` (90) vem antes de `'a'` (97).
///
/// Centralizado de propósito. Antes desta unificação havia quatro comparações
/// diferentes espalhadas pelo projeto: três `normalizeName` próprios (idioma,
/// invocação e mecânica de classe) e um `compareTo` cru nos demais. Resultado
/// prático: a mesma palavra acentuada caía em posições diferentes dependendo
/// da tela.
library;

/// Troca letra acentuada pela equivalente sem acento.
///
/// Feito à mão em vez de `unorm`/ICU porque o projeto não tem dependência de
/// normalização Unicode e o conjunto de letras do português e do inglês cabe
/// numa tabela. É a tabela ÚNICA do projeto: o importador de magias delega
/// para cá, para as duas não divergirem.
String foldPtAccents(String value) {
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

/// Compara dois textos como um leitor brasileiro espera numa lista.
///
/// Ignora caixa e trata acento como a letra base, que é o comportamento do
/// dicionário: "Bárbaro" vem antes de "Bardo" porque o acento não muda a
/// posição do `a`.
///
/// O acento só decide quando as formas sem acento são iguais, e aí o
/// desempate é pelo texto cru. Isso mantém a ordenação ESTÁVEL: sem esse
/// segundo critério, "Ioun" e "íoun" ficariam empatados e a posição relativa
/// delas mudaria conforme o algoritmo de sort.
int comparePtBr(String a, String b) {
  final folded = foldPtAccents(
    a.trim().toLowerCase(),
  ).compareTo(foldPtAccents(b.trim().toLowerCase()));

  if (folded != 0) return folded;

  return a.compareTo(b);
}

/// Compara pelo nome exibido, com o id como desempate.
///
/// O id entra porque dois conteúdos podem legitimamente ter o mesmo nome em
/// português — "Patrulheiro" e "Patrulheiro Revisado" não, mas subclasses
/// homônimas de fontes diferentes sim. Sem o desempate, a ordem entre elas
/// mudaria de uma reconstrução para a outra e a lista "dançaria" na tela.
int compareDisplayNames({
  required String nameA,
  required String idA,
  required String nameB,
  required String idB,
}) {
  final byName = comparePtBr(nameA, nameB);
  if (byName != 0) return byName;
  return idA.compareTo(idB);
}

/// Devolve uma CÓPIA ordenada pelo nome exibido.
///
/// Cópia, e nunca ordenação no lugar: as listas do compêndio são compartilhadas
/// entre telas e vêm de provider em cache. Um `..sort()` na lista original
/// mudaria a ordem para todo mundo, inclusive para quem depende da ordem do
/// arquivo — o equipamento inicial de classe, por exemplo.
///
/// A lista devolvida é imutável para quem recebe não conseguir reordená-la por
/// engano depois.
List<T> sortedByDisplayName<T>(
  Iterable<T> items, {
  required String Function(T item) name,
  required String Function(T item) id,
}) {
  final result = items.toList();

  result.sort(
    (a, b) => compareDisplayNames(
      nameA: name(a),
      idA: id(a),
      nameB: name(b),
      idB: id(b),
    ),
  );

  return List<T>.unmodifiable(result);
}
