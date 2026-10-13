import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/background_personality_choice.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_feat.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_weapon.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/combat_stats.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency_grant.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/custom_background.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/death_saves.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/hit_points.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/inventory_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/saving_throw_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiencies.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/skill_proficiency_grant.dart';
import 'package:dnd_ficha_app/features/character/domain/services/standard_array.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/alignment.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';

/// Marcador usado no [Character.copyWith] para distinguir "não informado"
/// de "informado como null".
const Object _sentinel = Object();

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.abilityScores,
    required this.classLevels,
    required this.hitPoints,
    required this.combatStats,
    required this.createdAt,
    required this.updatedAt,
    this.playerName,
    this.portraitPath,
    this.speciesId,
    this.backgroundId,
    this.customBackground = const CustomBackground(),
    this.notes = '',
    this.savingThrowProficiencies = const SavingThrowProficiencies(),
    this.skillProficiencies = const SkillProficiencies(),
    this.spells = const [],
    this.weapons = const [],
    this.magicItems = const [],
    this.feats = const [],
    this.inspiration = false,
    this.exhaustion = 0,
    this.conditions = const {},
    this.deathSaves = const DeathSaves(),
    this.hitDiceUsed = 0,
    this.currency = const Currency(),
    this.alignment,
    this.abilityScoreAllocation,
    this.skillProficiencyGrants = const [],
    this.inventory = const [],
    this.currencyGrants = const [],
    this.backgroundPersonalityChoices = const [],
  });

  final String id;
  final String name;
  final String? playerName;

  /// Caminho absoluto da imagem de aparência, dentro do diretório do app.
  ///
  /// Guarda uma cópia feita pelo app, não o arquivo original escolhido pelo
  /// jogador: o caminho que o gerenciador de arquivos devolve aponta para o
  /// cache e pode ser apagado pelo sistema a qualquer momento.
  final String? portraitPath;

  final String? speciesId;
  final String? backgroundId;

  /// Dados do antecedente criado pelo jogador. Só é usado quando
  /// [backgroundId] é `'custom'` (`BackgroundEntry.customId`); nos demais
  /// casos o antecedente vem do compêndio.
  final CustomBackground customBackground;

  final AbilityScores abilityScores;

  /// Valores base e bônus de origem usados na criação.
  ///
  /// É nulo em personagens anteriores ao schema 16. Nesses casos
  /// [abilityScores] continua sendo a fonte de verdade e nada é recalculado.
  final AbilityScoreAllocation? abilityScoreAllocation;
  final List<ClassLevel> classLevels;
  final HitPoints hitPoints;
  final CombatStats combatStats;
  final String notes;
  final SavingThrowProficiencies savingThrowProficiencies;
  final SkillProficiencies skillProficiencies;

  /// Origem das proficiências escolhidas ou concedidas na criação.
  /// Personagens antigos mantêm a lista vazia por compatibilidade.
  final List<SkillProficiencyGrant> skillProficiencyGrants;
  final List<CharacterSpell> spells;

  /// Armas que o personagem carrega.
  final List<CharacterWeapon> weapons;

  final List<CharacterMagicItem> magicItems;

  /// Talentos escolhidos nos níveis em que a classe permite.
  final List<CharacterFeat> feats;

  /// Inspiração heroica concedida pelo mestre.
  final bool inspiration;

  /// Níveis de exaustão (0 a 6). A partir de 1 já impõe desvantagem em
  /// testes de atributo, o que afeta os valores passivos.
  final int exhaustion;

  /// Condições ativas, como Paralisado ou Atordoado.
  ///
  /// Guarda só o que o jogador marcou. As condições que estas arrastam pelas
  /// regras (Paralisado implica Incapacitado) são derivadas na leitura, por
  /// `Condition.expand`, para desmarcar a original não deixar sobras.
  final Set<Condition> conditions;

  /// Sucessos e falhas nos testes contra a morte.
  ///
  /// Só tem sentido a 0 pontos de vida, mas fica guardado sempre: zerar ao subir
  /// de PV é decisão de regra (ver `DeathSaveService`), não do armazenamento.
  final DeathSaves deathSaves;

  /// Dados de vida gastos desde o último descanso longo.
  final int hitDiceUsed;

  /// Alinhamento do personagem.
  ///
  /// Nulo é "não definido", e não neutro: o neutro é uma escolha, e ainda não
  /// ter escolhido é outra coisa. Personagem criado antes deste campo existir
  /// chega aqui como nulo e continua abrindo normalmente.
  final CharacterAlignment? alignment;

  /// Moedas carregadas pelo personagem.
  ///
  /// É o total, porque é assim que a mesa consulta a carteira. Quanto deste
  /// total veio de cada fonte automática fica em [currencyGrants], ao lado.
  final Currency currency;

  /// Itens que o personagem carrega.
  ///
  /// Não duplica armas nem itens mágicos: aqueles continuam nas próprias
  /// seções, e um item daqui pode apontar para eles por vínculo. Personagem
  /// anterior ao schema 17 chega com a lista vazia.
  final List<InventoryItem> inventory;

  /// Registro de quanto cada fonte automática somou em [currency].
  ///
  /// Existe para trocar o antecedente subtrair exatamente o que ele havia
  /// concedido, sem encostar no dinheiro ganho em outra fonte nem no que o
  /// jogador ajustou à mão.
  final List<CurrencyGrant> currencyGrants;

  /// Traços, ideal, vínculo e defeito escolhidos no antecedente.
  ///
  /// Vazia em personagem criado antes desta funcionalidade, e isso é um estado
  /// válido: a ficha simplesmente não mostra a seção de personalidade. Nada é
  /// sorteado por conta própria.
  final List<BackgroundPersonalityChoice> backgroundPersonalityChoices;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Visão das escolhas narrativas com as regras de validação.
  BackgroundPersonalitySelection get personalitySelection =>
      BackgroundPersonalitySelection(backgroundPersonalityChoices);

  /// Itens do inventário concedidos por uma origem específica.
  List<InventoryItem> inventoryFrom(GrantSource source, {String? sourceId}) {
    return inventory
        .where(
          (item) =>
              item.source == source &&
              (sourceId == null || item.sourceId == sourceId),
        )
        .toList(growable: false);
  }

  int get totalLevel {
    return classLevels.fold(0, (total, item) => total + item.level);
  }

  int get proficiencyBonus {
    final level = totalLevel;

    if (level >= 17) return 6;
    if (level >= 13) return 5;
    if (level >= 9) return 4;
    if (level >= 5) return 3;
    return 2;
  }

  /// Bônus permanentes posteriores à criação. Hoje são os aumentos realmente
  /// aplicados pelos talentos, que já ficam persistidos junto a cada talento.
  Map<Ability, int> get otherPermanentAbilityBonuses {
    final result = <Ability, int>{};
    for (final feat in feats) {
      for (final entry in feat.appliedAbilityIncreases.entries) {
        final ability = Ability.fromName(entry.key);
        if (ability == null) continue;
        result[ability] = (result[ability] ?? 0) + entry.value;
      }
    }
    return result;
  }

  Character copyWith({
    String? id,
    String? name,
    Object? playerName = _sentinel,
    Object? portraitPath = _sentinel,
    Object? speciesId = _sentinel,
    Object? backgroundId = _sentinel,
    CustomBackground? customBackground,
    AbilityScores? abilityScores,
    Object? abilityScoreAllocation = _sentinel,
    List<ClassLevel>? classLevels,
    HitPoints? hitPoints,
    CombatStats? combatStats,
    String? notes,
    SavingThrowProficiencies? savingThrowProficiencies,
    SkillProficiencies? skillProficiencies,
    List<SkillProficiencyGrant>? skillProficiencyGrants,
    List<CharacterSpell>? spells,
    List<CharacterWeapon>? weapons,
    List<CharacterMagicItem>? magicItems,
    List<CharacterFeat>? feats,
    bool? inspiration,
    int? exhaustion,
    Set<Condition>? conditions,
    DeathSaves? deathSaves,
    int? hitDiceUsed,
    Currency? currency,
    List<InventoryItem>? inventory,
    List<CurrencyGrant>? currencyGrants,
    List<BackgroundPersonalityChoice>? backgroundPersonalityChoices,
    Object? alignment = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      // Sentinela permite explicitamente setar estes campos para null
      // (com `x ?? this.x` era impossível limpá-los).
      playerName:
          playerName == _sentinel ? this.playerName : playerName as String?,
      // Sentinela é obrigatória aqui: remover o retrato é setar null, e com
      // `?? this.portraitPath` isso seria impossível.
      portraitPath:
          portraitPath == _sentinel
              ? this.portraitPath
              : portraitPath as String?,
      speciesId: speciesId == _sentinel ? this.speciesId : speciesId as String?,
      backgroundId:
          backgroundId == _sentinel
              ? this.backgroundId
              : backgroundId as String?,
      customBackground: customBackground ?? this.customBackground,
      abilityScores: abilityScores ?? this.abilityScores,
      abilityScoreAllocation:
          abilityScoreAllocation == _sentinel
              ? this.abilityScoreAllocation
              : abilityScoreAllocation as AbilityScoreAllocation?,
      classLevels: classLevels ?? this.classLevels,
      hitPoints: hitPoints ?? this.hitPoints,
      combatStats: combatStats ?? this.combatStats,
      notes: notes ?? this.notes,
      savingThrowProficiencies:
          savingThrowProficiencies ?? this.savingThrowProficiencies,
      skillProficiencies: skillProficiencies ?? this.skillProficiencies,
      skillProficiencyGrants:
          skillProficiencyGrants ?? this.skillProficiencyGrants,
      spells: spells ?? this.spells,
      weapons: weapons ?? this.weapons,
      magicItems: magicItems ?? this.magicItems,
      feats: feats ?? this.feats,
      inspiration: inspiration ?? this.inspiration,
      exhaustion: exhaustion ?? this.exhaustion,
      // Sem sentinela: limpar as condições é passar um conjunto vazio, não
      // null, então `?? this.conditions` dá conta.
      conditions: conditions ?? this.conditions,
      // Também sem sentinela: zerar os testes contra a morte é passar
      // `DeathSaves()`, que não é null.
      deathSaves: deathSaves ?? this.deathSaves,
      hitDiceUsed: hitDiceUsed ?? this.hitDiceUsed,
      currency: currency ?? this.currency,
      // Sem sentinela nos três: limpar é passar lista vazia, não null.
      inventory: inventory ?? this.inventory,
      currencyGrants: currencyGrants ?? this.currencyGrants,
      backgroundPersonalityChoices:
          backgroundPersonalityChoices ?? this.backgroundPersonalityChoices,
      // Sentinela é obrigatória: voltar o alinhamento para "não definido" é
      // setar null, e com `?? this.alignment` isso seria impossível.
      alignment:
          alignment == _sentinel
              ? this.alignment
              : alignment as CharacterAlignment?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
