import 'package:drift/drift.dart';

class Characters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get playerName => text().nullable()();

  /// Caminho da imagem de aparência, dentro do diretório do app.
  TextColumn get portraitPath => text().nullable()();

  TextColumn get speciesId => text().nullable()();
  TextColumn get backgroundId => text().nullable()();

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
  IntColumn get temporaryHitPoints => integer().withDefault(const Constant(0))();

  BoolColumn get saveStrength => boolean().withDefault(const Constant(false))();
  BoolColumn get saveDexterity => boolean().withDefault(const Constant(false))();
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

class CharacterMagicItems extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get charges => integer().nullable()();
  IntColumn get maxCharges => integer().nullable()();
  TextColumn get rechargeRule => text().nullable()();
  TextColumn get castingAbility => text().nullable()();
  IntColumn get saveDc => integer().nullable()();
  IntColumn get attackBonus => integer().nullable()();
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

class CharacterSpellSlotsUsage extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get characterId => text().references(Characters, #id)();
  IntColumn get slotLevel => integer()(); // 1 até 9
  IntColumn get used => integer().withDefault(const Constant(0))();
}