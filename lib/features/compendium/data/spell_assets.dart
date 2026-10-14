/// Arquivos que compõem a base de magias.
///
/// A lista estava repetida em três lugares (a leitura do repositório e dois
/// testes de asset). Quando um livro novo entra, esquecer um dos três fazia o
/// teste passar sobre uma base diferente da que o app carrega.
///
/// A ordem importa: `SpellNameIndex` registra o primeiro nome que encontra, e
/// três magias de Tasha repetem o nome português de magias do Livro do Jogador
/// (Invocar Celestial, Invocar Elemental e Invocar Feérico). Manter o Livro do
/// Jogador na frente preserva a resolução que as subclasses já esperam.
const List<String> spellAssetPaths = [
  'assets/data/spells/magias-livro-do-jogador.json',
  'assets/data/spells/magias-xanathar-guide.json',
  'assets/data/spells/magias-tasha-cauldron.json',
  'assets/data/spells/magias-fontes-adicionais.json',
];
