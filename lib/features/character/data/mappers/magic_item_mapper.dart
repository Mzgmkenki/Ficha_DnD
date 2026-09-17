import 'package:dnd_ficha_app/core/database/app_database.dart' as db;
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/magic_item_bonus.dart';
import 'package:drift/drift.dart' as drift;

/// Traduz o item mágico entre a linha do banco e a entidade.
///
/// Existe como arquivo próprio porque as três gravações (salvar personagem
/// inteiro, adicionar item, atualizar item) precisam montar exatamente as
/// mesmas colunas. Enquanto eram quatro bônus dava para repetir inline no
/// repositório; com o degrau, as estatísticas e o estado de uso, repetir três
/// vezes é onde uma coluna esquecida passa despercebida.
class MagicItemMapper {
  const MagicItemMapper._();

  /// Monta a entidade a partir da linha e das magias vinculadas.
  ///
  /// Reconhece aqui a linha gravada antes do bônus controlado e a converte com
  /// [convertLegacyMagicItemBonuses]. A conversão não pode morar na migração:
  /// ela compara os quatro valores entre si, e ler linhas dentro de `onUpgrade`
  /// trava a abertura do banco.
  static CharacterMagicItem fromDatabase({
    required db.CharacterMagicItem row,
    required List<CharacterMagicItemSpell> spells,
  }) {
    if (_isLegacyRow(row)) {
      return CharacterMagicItem.fromLegacyBonuses(
        localId: row.localId,
        name: row.name,
        description: row.description,
        spells: spells,
        charges: row.charges,
        maxCharges: row.maxCharges,
        rechargeRule: row.rechargeRule,
        castingAbility: row.castingAbility,
        saveDc: row.saveDc,
        attackBonus: row.attackBonus,
        weaponAttackBonus: row.weaponAttackBonus,
        weaponDamageBonus: row.weaponDamageBonus,
        spellAttackBonus: row.spellAttackBonus,
        spellSaveDcBonus: row.spellSaveDcBonus,
        isEquipped: row.isEquipped,
        requiresAttunement: row.requiresAttunement,
        isAttuned: row.isAttuned,
      );
    }

    return CharacterMagicItem(
      localId: row.localId,
      name: row.name,
      description: row.description,
      spells: spells,
      charges: row.charges,
      maxCharges: row.maxCharges,
      rechargeRule: row.rechargeRule,
      castingAbility: row.castingAbility,
      saveDc: row.saveDc,
      attackBonus: row.attackBonus,
      bonus: MagicItemBonus.fromValue(row.magicBonus),
      bonusTargets: MagicItemBonusTarget.parseCsv(row.bonusTargets),
      isEquipped: row.isEquipped,
      requiresAttunement: row.requiresAttunement,
      isAttuned: row.isAttuned,
    );
  }

  /// Linha gravada antes da migração 14.
  ///
  /// O sinal é o formato novo estar vazio (`magic_bonus` zero e
  /// `bonus_targets` sem nada) enquanto algum dos quatro campos livres declara
  /// algo. Item sem bônus nenhum não entra aqui, porque não há o que converter,
  /// e item já gravado no formato novo tampouco — então reler a mesma linha
  /// duas vezes dá o mesmo resultado.
  static bool _isLegacyRow(db.CharacterMagicItem row) {
    if (row.magicBonus != 0) return false;
    if (row.bonusTargets.isNotEmpty) return false;

    return row.weaponAttackBonus != 0 ||
        row.weaponDamageBonus != 0 ||
        row.spellAttackBonus != 0 ||
        row.spellSaveDcBonus != 0;
  }

  /// Companion para inserir o item de um personagem.
  static db.CharacterMagicItemsCompanion toInsert({
    required String characterId,
    required CharacterMagicItem item,
  }) {
    final shape = _BonusShape.of(item);

    return db.CharacterMagicItemsCompanion.insert(
      characterId: characterId,
      name: item.name,
      description: drift.Value(item.description),
      charges: drift.Value(item.charges),
      maxCharges: drift.Value(item.maxCharges),
      rechargeRule: drift.Value(item.rechargeRule),
      castingAbility: drift.Value(item.castingAbility),
      saveDc: drift.Value(item.saveDc),
      attackBonus: drift.Value(item.attackBonus),
      magicBonus: drift.Value(shape.magicBonus),
      bonusTargets: drift.Value(shape.targetsCsv),
      isEquipped: drift.Value(item.isEquipped),
      requiresAttunement: drift.Value(item.requiresAttunement),
      isAttuned: drift.Value(item.isAttuned),
      weaponAttackBonus: drift.Value(shape.weaponAttack),
      weaponDamageBonus: drift.Value(shape.weaponDamage),
      spellAttackBonus: drift.Value(shape.spellAttack),
      spellSaveDcBonus: drift.Value(shape.spellSaveDc),
    );
  }

  /// Companion para atualizar o item inteiro.
  static db.CharacterMagicItemsCompanion toUpdate(CharacterMagicItem item) {
    final shape = _BonusShape.of(item);

    return db.CharacterMagicItemsCompanion(
      name: drift.Value(item.name),
      description: drift.Value(item.description),
      charges: drift.Value(item.charges),
      maxCharges: drift.Value(item.maxCharges),
      rechargeRule: drift.Value(item.rechargeRule),
      castingAbility: drift.Value(item.castingAbility),
      saveDc: drift.Value(item.saveDc),
      attackBonus: drift.Value(item.attackBonus),
      magicBonus: drift.Value(shape.magicBonus),
      bonusTargets: drift.Value(shape.targetsCsv),
      isEquipped: drift.Value(item.isEquipped),
      requiresAttunement: drift.Value(item.requiresAttunement),
      isAttuned: drift.Value(item.isAttuned),
      weaponAttackBonus: drift.Value(shape.weaponAttack),
      weaponDamageBonus: drift.Value(shape.weaponDamage),
      spellAttackBonus: drift.Value(shape.spellAttack),
      spellSaveDcBonus: drift.Value(shape.spellSaveDc),
    );
  }
}

/// Como os bônus do item vão para as colunas.
///
/// Os quatro campos livres recebem sempre o valor DECLARADO, nunca o efetivo:
/// desequipar um item não pode apagar a configuração dele, senão equipar de
/// volta traria o item sem bônus.
class _BonusShape {
  const _BonusShape({
    required this.magicBonus,
    required this.targetsCsv,
    required this.weaponAttack,
    required this.weaponDamage,
    required this.spellAttack,
    required this.spellSaveDc,
  });

  /// Item marcado para revisão é gravado exatamente na forma antiga:
  /// `magic_bonus` zero, `bonus_targets` vazio e os quatro números crus.
  ///
  /// É o que mantém a releitura estável. Se gravássemos as estatísticas
  /// afetadas, a linha deixaria de ser reconhecida como antiga e o `-1` do item
  /// maldito viraria zero na próxima abertura da ficha — perda silenciosa,
  /// exatamente o que a revisão existe para evitar.
  factory _BonusShape.of(CharacterMagicItem item) {
    final review = item.needsBonusReview;

    return _BonusShape(
      magicBonus: review ? 0 : item.bonus.value,
      targetsCsv:
          review ? '' : MagicItemBonusTarget.toCsv(item.bonusTargets),
      weaponAttack: item.declaredBonusFor(MagicItemBonusTarget.weaponAttack),
      weaponDamage: item.declaredBonusFor(MagicItemBonusTarget.weaponDamage),
      spellAttack: item.declaredBonusFor(MagicItemBonusTarget.spellAttack),
      spellSaveDc: item.declaredBonusFor(MagicItemBonusTarget.spellSaveDc),
    );
  }

  final int magicBonus;
  final String targetsCsv;
  final int weaponAttack;
  final int weaponDamage;
  final int spellAttack;
  final int spellSaveDc;
}
