import 'package:dnd_ficha_app/core/database/app_database.dart' as db;
import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/currency_grant.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';
import 'package:drift/drift.dart' as drift;

/// Converte linhas de `character_currency_grants` para [CurrencyGrant] e de
/// volta.
class CurrencyGrantMapper {
  const CurrencyGrantMapper._();

  static CurrencyGrant fromDatabase(db.CharacterCurrencyGrant row) {
    return CurrencyGrant(
      source: GrantSource.fromIdOrManual(row.source),
      // `nonNegative` porque um valor negativo gravado faria a remoção somar
      // dinheiro em vez de subtrair.
      currency: Currency(
        copper: row.copperPieces,
        silver: row.silverPieces,
        electrum: row.electrumPieces,
        gold: row.goldPieces,
        platinum: row.platinumPieces,
      ).nonNegative,
      sourceId: row.sourceId,
      sourceLabel: row.sourceLabel,
      grantedAtCreation: row.grantedAtCreation,
    );
  }

  static db.CharacterCurrencyGrantsCompanion toInsert({
    required String characterId,
    required CurrencyGrant grant,
  }) {
    final currency = grant.currency.nonNegative;

    return db.CharacterCurrencyGrantsCompanion.insert(
      characterId: characterId,
      source: grant.source.id,
      sourceId: drift.Value(grant.sourceId),
      sourceLabel: drift.Value(grant.sourceLabel),
      copperPieces: drift.Value(currency.copper),
      silverPieces: drift.Value(currency.silver),
      electrumPieces: drift.Value(currency.electrum),
      goldPieces: drift.Value(currency.gold),
      platinumPieces: drift.Value(currency.platinum),
      grantedAtCreation: drift.Value(grant.grantedAtCreation),
    );
  }
}
