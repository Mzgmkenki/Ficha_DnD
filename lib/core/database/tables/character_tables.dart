import 'package:drift/drift.dart';

class Characters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get playerName => text().nullable()();

  /// Caminho da imagem de aparência, dentro do diretório do app.
  TextColumn get portraitPath => text().nullable()();

  TextColumn get speciesId => text().nullable()();
  TextColumn get backgroundId => text().nullable()();

  /// Id do alinhamento (`lawful_good`, `true_neutral`, ...).
  ///
  /// Anulável de propósito: nulo é "não definido", que não é a mesma coisa que
  /// neutro. Personagem criado antes desta coluna existir fica nulo e continua
  /// abrindo — nenhum alinhamento é atribuído por conta própria.
  TextColumn get alignment => text().nullable()();

  // Antecedente customizável: usado quando background_id == 'custom'. O
  // compêndio é somente leitura, então o antecedente criado pelo jogador
  // precisa morar no próprio personagem.
  TextColumn get customBackgroundName => text().nullable()();

  /// Ids das perícias do antecedente customizado, separados por vírgula.
  TextColumn get customBackgroundSkills =>
      text().withDefault(const Constant(''))();

  /// Texto livre com as características do antecedente customizado.
  TextColumn get customBackgroundFeatures =>
      text().withDefault(const Constant(''))();

  TextColumn get notes => text().withDefault(const Constant(''))();

  IntColumn get strength => integer().withDefault(const Constant(10))();
  IntColumn get dexterity => integer().withDefault(const Constant(10))();
  IntColumn get constitution => integer().withDefault(const Constant(10))();
  IntColumn get intelligence => integer().withDefault(const Constant(10))();
  IntColumn get wisdom => integer().withDefault(const Constant(10))();
  IntColumn get charisma => integer().withDefault(const Constant(10))();

  /// Distribuição base do conjunto padrão, serializada como
  /// `strength:15,dexterity:14,...`. Nula para personagens antigos, cujos
  /// totais acima continuam sendo a única fonte de verdade.
  TextColumn get baseAbilityScores => text().nullable()();

  /// Bônus de origem aplicados na criação, separados dos valores base.
  TextColumn get originAbilityBonuses => text().nullable()();

  /// Origem das proficiências adquiridas durante a criação, em JSON.
  TextColumn get skillProficiencyGrants =>
      text().withDefault(const Constant('[]'))();

  IntColumn get armorClass => integer().withDefault(const Constant(10))();
  IntColumn get initiativeBonus => integer().withDefault(const Constant(0))();

  /// Deslocamento em metros, arredondado. Legado: a coluna é inteira e não
  /// cabia o 7,5 m do anão. A leitura usa [speedMeters]; esta continua sendo
  /// gravada para bases antigas não ficarem incoerentes.
  IntColumn get speed => integer().withDefault(const Constant(9))();

  /// Deslocamento em metros, com fração. Nulo em base que ainda não migrou.
  RealColumn get speedMeters => real().nullable()();

  IntColumn get maxHitPoints => integer().withDefault(const Constant(1))();
  IntColumn get currentHitPoints => integer().withDefault(const Constant(1))();
  IntColumn get temporaryHitPoints =>
      integer().withDefault(const Constant(0))();

  BoolColumn get saveStrength => boolean().withDefault(const Constant(false))();
  BoolColumn get saveDexterity =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get saveConstitution =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get saveIntelligence =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get saveWisdom => boolean().withDefault(const Constant(false))();
  BoolColumn get saveCharisma => boolean().withDefault(const Constant(false))();

  BoolColumn get skillAcrobatics =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillAnimalHandling =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillArcana => boolean().withDefault(const Constant(false))();
  BoolColumn get skillAthletics =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillDeception =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillHistory => boolean().withDefault(const Constant(false))();
  BoolColumn get skillInsight => boolean().withDefault(const Constant(false))();
  BoolColumn get skillIntimidation =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillInvestigation =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillMedicine =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillNature => boolean().withDefault(const Constant(false))();
  BoolColumn get skillPerception =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillPerformance =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillPersuasion =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillReligion =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillSleightOfHand =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get skillStealth => boolean().withDefault(const Constant(false))();
  BoolColumn get skillSurvival =>
      boolean().withDefault(const Constant(false))();

  // Nível de proficiência por perícia: 0=nenhum, 1=metade, 2=proficiente,
  // 3=especialista. Substitui os booleanos acima, que não conseguiam
  // representar Especialista nem Meia Proficiência. As colunas booleanas
  // ficam como legado para não perder dados de bases antigas.
  IntColumn get lvlAcrobatics => integer().withDefault(const Constant(0))();
  IntColumn get lvlAnimalHandling => integer().withDefault(const Constant(0))();
  IntColumn get lvlArcana => integer().withDefault(const Constant(0))();
  IntColumn get lvlAthletics => integer().withDefault(const Constant(0))();
  IntColumn get lvlDeception => integer().withDefault(const Constant(0))();
  IntColumn get lvlHistory => integer().withDefault(const Constant(0))();
  IntColumn get lvlInsight => integer().withDefault(const Constant(0))();
  IntColumn get lvlIntimidation => integer().withDefault(const Constant(0))();
  IntColumn get lvlInvestigation => integer().withDefault(const Constant(0))();
  IntColumn get lvlMedicine => integer().withDefault(const Constant(0))();
  IntColumn get lvlNature => integer().withDefault(const Constant(0))();
  IntColumn get lvlPerception => integer().withDefault(const Constant(0))();
  IntColumn get lvlPerformance => integer().withDefault(const Constant(0))();
  IntColumn get lvlPersuasion => integer().withDefault(const Constant(0))();
  IntColumn get lvlReligion => integer().withDefault(const Constant(0))();
  IntColumn get lvlSleightOfHand => integer().withDefault(const Constant(0))();
  IntColumn get lvlStealth => integer().withDefault(const Constant(0))();
  IntColumn get lvlSurvival => integer().withDefault(const Constant(0))();

  /// Inspiração heroica: o personagem tem ou não.
  BoolColumn get inspiration => boolean().withDefault(const Constant(false))();

  /// Níveis de exaustão (0 a 6).
  IntColumn get exhaustion => integer().withDefault(const Constant(0))();

  /// Ids das condições ativas, separados por vírgula (`paralyzed,stunned`).
  ///
  /// CSV em vez de tabela filha porque o vocabulário é fixo e pequeno, e o
  /// conjunto é sempre lido e gravado inteiro. Mesma escolha de
  /// [customBackgroundSkills]. Exaustão não entra aqui: tem níveis, não
  /// ligado/desligado, e já mora em [exhaustion].
  TextColumn get conditions => text().withDefault(const Constant(''))();

  /// Sucessos nos testes contra a morte (0 a 3).
  ///
  /// Contagem, não histórico: a ficha de papel tem três bolinhas de cada lado, e
  /// é essa a informação que a mesa consulta. Guardar cada rolagem seria outra
  /// funcionalidade, e exigiria tabela filha.
  IntColumn get deathSaveSuccesses =>
      integer().withDefault(const Constant(0))();

  /// Falhas nos testes contra a morte (0 a 3).
  IntColumn get deathSaveFailures => integer().withDefault(const Constant(0))();

  /// Dados de vida já gastos desde o último descanso longo.
  IntColumn get hitDiceUsed => integer().withDefault(const Constant(0))();

  // Moedas (PC, PP, PE, PO, PL).
  IntColumn get copperPieces => integer().withDefault(const Constant(0))();
  IntColumn get silverPieces => integer().withDefault(const Constant(0))();
  IntColumn get electrumPieces => integer().withDefault(const Constant(0))();
  IntColumn get goldPieces => integer().withDefault(const Constant(0))();
  IntColumn get platinumPieces => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CharacterClassLevels extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();
  TextColumn get classId => text()();
  TextColumn get subclassId => text().nullable()();
  IntColumn get level => integer()();
  TextColumn get spellcastingAbility => text().nullable()();
  TextColumn get spellcastingType => text().nullable()();
}

class CharacterSpells extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();
  IntColumn get spellId => integer()();
  TextColumn get sourceType => text()(); // class, item, custom, race, feat...
  TextColumn get sourceId => text()();
  TextColumn get sourceName => text()();
  BoolColumn get isPrepared => boolean().withDefault(const Constant(false))();
  BoolColumn get isKnown => boolean().withDefault(const Constant(true))();
  BoolColumn get isAlwaysAvailable =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// Armas que o personagem carrega.
///
/// Guarda só o que é decisão do jogador. Dado de dano, tipo de dano e
/// propriedades ficam no compêndio (`assets/data/srd/weapons.json`) e são
/// resolvidos por [weaponId] na leitura: repetir aqui deixaria a ficha
/// desatualizada se a tabela do livro fosse corrigida.
class CharacterWeapons extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();

  /// Id da arma no compêndio (`WeaponEntry.id`).
  TextColumn get weaponId => text()();

  /// Apelido da arma. Nulo usa o nome do compêndio.
  ///
  /// Serve para a arma mágica com nome próprio continuar sendo mecanicamente
  /// uma espada longa.
  TextColumn get name => text().nullable()();

  /// Bônus mágico da arma: o `+1`, `+2` ou `+3`.
  ///
  /// Soma nas jogadas de ataque E nas de dano daquela arma, que é o que a
  /// descrição de arma mágica diz. Não mexe em ataque de magia nem em CD: isso
  /// só acontece se o item declarar, e quem cuida disso é o item mágico.
  IntColumn get magicBonus => integer().withDefault(const Constant(0))();

  /// Atributo escolhido nas armas com Acuidade, pelo nome do enum `Ability`.
  ///
  /// Nulo deixa o cálculo pegar o melhor entre Força e Destreza, que é a
  /// escolha certa em praticamente todo caso.
  TextColumn get chosenAbility => text().nullable()();

  /// Se está empunhada com as duas mãos.
  ///
  /// Só muda algo nas armas Versáteis, que trocam o dado (1d8 vira 1d10 na
  /// espada longa).
  BoolColumn get twoHanded => boolean().withDefault(const Constant(false))();

  /// Proficiência marcada à mão.
  ///
  /// Nulo é o normal: a proficiência vem da classe. O campo existe porque
  /// raça, antecedente e talento também concedem proficiência com arma, e
  /// nenhum dos três está cadastrado de forma estruturada — sem o override, um
  /// elfo com arco longo apareceria sem proficiência e não haveria como
  /// corrigir.
  BoolColumn get proficiencyOverride => boolean().nullable()();

  TextColumn get notes => text().withDefault(const Constant(''))();
}

class CharacterMagicItems extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get charges => integer().nullable()();
  IntColumn get maxCharges => integer().nullable()();
  TextColumn get rechargeRule => text().nullable()();
  TextColumn get castingAbility => text().nullable()();

  /// CD fixa do item, quando ele define a própria.
  ///
  /// Valor ABSOLUTO, não bônus: é o "CD 15" impresso na descrição de varinhas
  /// e cajados, que não depende dos atributos de quem usa. Para o item que
  /// SOMA à CD do conjurador existe [spellSaveDcBonus].
  IntColumn get saveDc => integer().nullable()();

  /// Bônus de ataque fixo do item, quando ele define o próprio.
  ///
  /// Também absoluto, pelo mesmo motivo de [saveDc].
  IntColumn get attackBonus => integer().nullable()();

  // ------------------------------------------------------- bônus estruturados
  //
  // Separados dos dois campos acima porque respondem outra pergunta: aqui é
  // quanto o item SOMA ao que o personagem já tem. Cada efeito tem coluna
  // própria de propósito — um item `+1` afeta ataque e dano da arma, e só
  // afeta ataque mágico ou CD se a descrição dele disser isso. Com um único
  // campo "bônus" não haveria como distinguir os dois casos.
  //
  // As quatro colunas guardam o valor DECLARADO por estatística, não o que
  // está valendo: quem decide se o bônus entra na conta é `is_equipped` mais
  // `requires_attunement`/`is_attuned`, e apagar o número ao desequipar
  // perderia a configuração do item.
  //
  // Desde a migração 14 elas são um espelho de `magic_bonus` +
  // `bonus_targets`, mantido porque é o que uma build antiga e um arquivo
  // exportado antigo sabem ler. A exceção é o item marcado para revisão, em
  // que elas continuam sendo a fonte de verdade (ver `magic_bonus`).

  /// Soma nas jogadas de ataque com arma.
  IntColumn get weaponAttackBonus => integer().withDefault(const Constant(0))();

  /// Soma nas jogadas de dano com arma.
  IntColumn get weaponDamageBonus => integer().withDefault(const Constant(0))();

  /// Soma no bônus de ataque com magia.
  IntColumn get spellAttackBonus => integer().withDefault(const Constant(0))();

  /// Soma na CD de resistência das magias do personagem.
  IntColumn get spellSaveDcBonus => integer().withDefault(const Constant(0))();

  // ------------------------------------------------------- bônus controlado

  /// O degrau de bônus do item: 0, 1, 2 ou 3.
  ///
  /// Substitui os quatro campos livres como entrada do jogador. Zero com
  /// [bonusTargets] vazio é o item que não concede bônus nenhum.
  ///
  /// Item cujos valores antigos não cabem neste formato (negativo, acima de 3,
  /// ou diferentes entre estatísticas) fica com zero aqui e é reconhecido na
  /// leitura como "para revisar", caso em que as quatro colunas acima seguem
  /// valendo. A conversão mora no domínio
  /// (`convertLegacyMagicItemBonuses`) em vez de num UPDATE da migração,
  /// porque dentro de `onUpgrade` não é seguro ler o banco.
  IntColumn get magicBonus => integer().withDefault(const Constant(0))();

  /// Estatísticas afetadas pelo [magicBonus], como CSV de ids.
  ///
  /// CSV pelo mesmo motivo da coluna `conditions`: vocabulário pequeno e fixo,
  /// sempre lido e escrito inteiro.
  TextColumn get bonusTargets => text().withDefault(const Constant(''))();

  /// Se o item está equipado ou em uso.
  ///
  /// Item guardado não soma. Padrão `true` para a ficha que já existia não
  /// mudar de número ao migrar.
  BoolColumn get isEquipped => boolean().withDefault(const Constant(true))();

  /// Se a descrição do item exige sintonia.
  BoolColumn get requiresAttunement =>
      boolean().withDefault(const Constant(false))();

  /// Se o personagem está sintonizado com o item.
  ///
  /// Só tem efeito quando [requiresAttunement] é verdadeiro.
  BoolColumn get isAttuned => boolean().withDefault(const Constant(false))();
}

class CharacterMagicItemSpells extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get magicItemId =>
      integer().references(CharacterMagicItems, #localId)();
  IntColumn get spellId => integer()();
  BoolColumn get usesCharges => boolean().withDefault(const Constant(false))();
  IntColumn get chargeCost => integer().withDefault(const Constant(1))();
  BoolColumn get isAtWill => boolean().withDefault(const Constant(false))();
  BoolColumn get isAlwaysAvailable =>
      boolean().withDefault(const Constant(true))();
}

/// Talentos que o personagem pegou.
///
/// [grantedSkills] guarda só as perícias que ESTE talento passou a conceder,
/// isto é, as que o personagem ainda não tinha. Sem isso, remover o talento não
/// teria como saber o que devolver: uma perícia que já vinha da classe ou do
/// antecedente seria apagada junto.
class CharacterFeats extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();
  TextColumn get featId => text()();

  /// Classe e nível em que o talento foi pego, para a ficha saber qual escolha
  /// já foi gasta.
  TextColumn get classId => text().nullable()();
  IntColumn get level => integer().nullable()();

  /// Perícias escolhidas pelo jogador dentro das opções do talento, como CSV
  /// de ids de perícia.
  TextColumn get chosenSkills => text().withDefault(const Constant(''))();

  /// Perícias que este talento efetivamente concedeu, como CSV de ids.
  TextColumn get grantedSkills => text().withDefault(const Constant(''))();

  /// Atributo que o jogador escolheu, quando o talento deixa escolher.
  ///
  /// Nome em inglês, igual ao do enum `Ability`.
  TextColumn get chosenAbility => text().nullable()();

  /// Quanto este talento somou em cada atributo, como CSV `atributo:valor`.
  ///
  /// Guardado pelo mesmo motivo de [grantedSkills]: sem saber o que entrou,
  /// remover o talento não teria como devolver. Atributo que já estava no teto
  /// de 20 não aparece aqui.
  TextColumn get appliedAbilityIncreases =>
      text().withDefault(const Constant(''))();
}

class CharacterSpellSlotsUsage extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();
  IntColumn get slotLevel => integer()(); // 1 até 9
  IntColumn get used => integer().withDefault(const Constant(0))();
}
