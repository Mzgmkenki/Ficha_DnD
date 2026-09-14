import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// Estratégia de migração do banco local.
///
/// IMPORTANTE: dentro de [MigrationStrategy.onUpgrade] o banco está numa
/// transação de migração. Fazer leituras pelo objeto `db` (por exemplo
/// `db.customSelect('PRAGMA table_info(...)')`) trava a abertura do banco,
/// e o app fica eternamente em estado de carregamento.
///
/// Por isso a idempotência aqui é obtida engolindo o erro de "coluna/tabela
/// já existe" em vez de consultar o schema antes.
MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Salvaguardas
        await _tryAddColumn(m, db.characters, db.characters.saveStrength);
        await _tryAddColumn(m, db.characters, db.characters.saveDexterity);
        await _tryAddColumn(m, db.characters, db.characters.saveConstitution);
        await _tryAddColumn(m, db.characters, db.characters.saveIntelligence);
        await _tryAddColumn(m, db.characters, db.characters.saveWisdom);
        await _tryAddColumn(m, db.characters, db.characters.saveCharisma);

        // Perícias (booleanos legados)
        await _tryAddColumn(m, db.characters, db.characters.skillAcrobatics);
        await _tryAddColumn(m, db.characters, db.characters.skillAnimalHandling);
        await _tryAddColumn(m, db.characters, db.characters.skillArcana);
        await _tryAddColumn(m, db.characters, db.characters.skillAthletics);
        await _tryAddColumn(m, db.characters, db.characters.skillDeception);
        await _tryAddColumn(m, db.characters, db.characters.skillHistory);
        await _tryAddColumn(m, db.characters, db.characters.skillInsight);
        await _tryAddColumn(m, db.characters, db.characters.skillIntimidation);
        await _tryAddColumn(m, db.characters, db.characters.skillInvestigation);
        await _tryAddColumn(m, db.characters, db.characters.skillMedicine);
        await _tryAddColumn(m, db.characters, db.characters.skillNature);
        await _tryAddColumn(m, db.characters, db.characters.skillPerception);
        await _tryAddColumn(m, db.characters, db.characters.skillPerformance);
        await _tryAddColumn(m, db.characters, db.characters.skillPersuasion);
        await _tryAddColumn(m, db.characters, db.characters.skillReligion);
        await _tryAddColumn(m, db.characters, db.characters.skillSleightOfHand);
        await _tryAddColumn(m, db.characters, db.characters.skillStealth);
        await _tryAddColumn(m, db.characters, db.characters.skillSurvival);
      }

      if (from < 3) {
        await _tryAddColumn(m, db.characters, db.characters.playerName);
        await _tryAddColumn(m, db.characters, db.characters.backgroundId);
        await _tryAddColumn(m, db.characters, db.characters.notes);

        await _tryCreateTable(m, db.characterMagicItems);
        await _tryCreateTable(m, db.characterMagicItemSpells);
        await _tryCreateTable(m, db.characterSpellSlotsUsage);
        await _tryCreateTable(m, db.classEntries);
      }

      if (from < 4) {
        // Nível de proficiência por perícia: 0=nenhum, 1=metade,
        // 2=proficiente, 3=especialista.
        await _tryAddColumn(m, db.characters, db.characters.lvlAcrobatics);
        await _tryAddColumn(m, db.characters, db.characters.lvlAnimalHandling);
        await _tryAddColumn(m, db.characters, db.characters.lvlArcana);
        await _tryAddColumn(m, db.characters, db.characters.lvlAthletics);
        await _tryAddColumn(m, db.characters, db.characters.lvlDeception);
        await _tryAddColumn(m, db.characters, db.characters.lvlHistory);
        await _tryAddColumn(m, db.characters, db.characters.lvlInsight);
        await _tryAddColumn(m, db.characters, db.characters.lvlIntimidation);
        await _tryAddColumn(m, db.characters, db.characters.lvlInvestigation);
        await _tryAddColumn(m, db.characters, db.characters.lvlMedicine);
        await _tryAddColumn(m, db.characters, db.characters.lvlNature);
        await _tryAddColumn(m, db.characters, db.characters.lvlPerception);
        await _tryAddColumn(m, db.characters, db.characters.lvlPerformance);
        await _tryAddColumn(m, db.characters, db.characters.lvlPersuasion);
        await _tryAddColumn(m, db.characters, db.characters.lvlReligion);
        await _tryAddColumn(m, db.characters, db.characters.lvlSleightOfHand);
        await _tryAddColumn(m, db.characters, db.characters.lvlStealth);
        await _tryAddColumn(m, db.characters, db.characters.lvlSurvival);

        // Recursos de mesa.
        await _tryAddColumn(m, db.characters, db.characters.inspiration);
        await _tryAddColumn(m, db.characters, db.characters.exhaustion);
        await _tryAddColumn(m, db.characters, db.characters.hitDiceUsed);

        // Backfill: quem era proficiente (bool = 1) passa a nível 2.
        const pairs = <List<String>>[
          ['lvl_acrobatics', 'skill_acrobatics'],
          ['lvl_animal_handling', 'skill_animal_handling'],
          ['lvl_arcana', 'skill_arcana'],
          ['lvl_athletics', 'skill_athletics'],
          ['lvl_deception', 'skill_deception'],
          ['lvl_history', 'skill_history'],
          ['lvl_insight', 'skill_insight'],
          ['lvl_intimidation', 'skill_intimidation'],
          ['lvl_investigation', 'skill_investigation'],
          ['lvl_medicine', 'skill_medicine'],
          ['lvl_nature', 'skill_nature'],
          ['lvl_perception', 'skill_perception'],
          ['lvl_performance', 'skill_performance'],
          ['lvl_persuasion', 'skill_persuasion'],
          ['lvl_religion', 'skill_religion'],
          ['lvl_sleight_of_hand', 'skill_sleight_of_hand'],
          ['lvl_stealth', 'skill_stealth'],
          ['lvl_survival', 'skill_survival'],
        ];

        for (final pair in pairs) {
          // Apenas escrita (UPDATE). Leituras aqui é que são problemáticas.
          await _tryQuery(
            db,
            'UPDATE characters SET ${pair[0]} = 2 WHERE ${pair[1]} = 1',
          );
        }
      }

      if (from < 5) {
        // Moedas.
        await _tryAddColumn(m, db.characters, db.characters.copperPieces);
        await _tryAddColumn(m, db.characters, db.characters.silverPieces);
        await _tryAddColumn(m, db.characters, db.characters.electrumPieces);
        await _tryAddColumn(m, db.characters, db.characters.goldPieces);
        await _tryAddColumn(m, db.characters, db.characters.platinumPieces);
      }

      if (from < 6) {
        // Antecedente customizável (background_id == 'custom').
        await _tryAddColumn(
          m,
          db.characters,
          db.characters.customBackgroundName,
        );
        await _tryAddColumn(
          m,
          db.characters,
          db.characters.customBackgroundSkills,
        );
        await _tryAddColumn(
          m,
          db.characters,
          db.characters.customBackgroundFeatures,
        );
      }

      if (from < 7) {
        // Retrato do personagem (imagem de aparência).
        await _tryAddColumn(m, db.characters, db.characters.portraitPath);
      }

      if (from < 8) {
        // Repete a coluna da versão 7 de propósito.
        //
        // Apareceu banco marcado como versão 7 sem a coluna: o `user_version`
        // subiu numa execução em que o bloco `from < 7` ainda não existia, e
        // como o drift só chama `onUpgrade` quando a versão difere, o banco
        // ficava preso nesse estado para sempre — a leitura funcionava (coluna
        // ausente vira null) e só o INSERT falhava.
        //
        // Não apague achando que é duplicado: `_tryAddColumn` engole o erro de
        // "coluna já existe", então em banco saudável isso é no-op.
        await _tryAddColumn(m, db.characters, db.characters.portraitPath);
      }

      if (from < 9) {
        // Deslocamento com fração: a coluna `speed` é inteira e transformava
        // os 7,5 m do anão em 7. A antiga fica como legado, do mesmo jeito que
        // as colunas booleanas de perícia.
        await _tryAddColumn(m, db.characters, db.characters.speedMeters);

        // Backfill: quem já existia mantém o deslocamento que tinha.
        await _tryQuery(
          db,
          'UPDATE characters SET speed_meters = speed '
          'WHERE speed_meters IS NULL',
        );
      }
    },
    beforeOpen: (details) async {
      // Roda fora da transação de migração, então aqui é seguro usar `db`.
      try {
        await db.customStatement(
          'DELETE FROM character_spell_slots_usage WHERE local_id NOT IN ('
          '  SELECT MIN(local_id) FROM character_spell_slots_usage'
          '  GROUP BY character_id, slot_level'
          ')',
        );

        await db.customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_slot_usage_unique '
          'ON character_spell_slots_usage (character_id, slot_level)',
        );
      } catch (error, stackTrace) {
        // Índice é uma otimização de segurança: se falhar, o app segue
        // funcionando (o updateUsedSpellSlot já roda em transação). Aqui o
        // catch é amplo de propósito, porque abrir o app é mais importante
        // que o índice — mas o erro não é mais engolido em silêncio.
        debugPrint('Falha ao criar idx_slot_usage_unique: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    },
  );
}

/// Só engole o erro se a mensagem for a esperada.
///
/// Antes estes helpers usavam `catch (_)` puro, o que também engolia falhas
/// reais (disco cheio, banco corrompido) e mesmo assim marcava a migração
/// como concluída — perdendo dados sem aviso.
bool _errorMatches(Object error, List<String> expectedFragments) {
  final message = error.toString().toLowerCase();
  return expectedFragments.any(message.contains);
}

/// Adiciona a coluna, ignorando o erro caso ela já exista.
Future<void> _tryAddColumn(
  Migrator m,
  TableInfo<Table, dynamic> table,
  GeneratedColumn<Object> column,
) async {
  try {
    await m.addColumn(table, column);
  } catch (error) {
    // "duplicate column name" — a coluna já estava lá.
    if (!_errorMatches(error, const ['duplicate column'])) rethrow;
  }
}

/// Cria a tabela, ignorando o erro caso ela já exista.
Future<void> _tryCreateTable(
  Migrator m,
  TableInfo<Table, dynamic> table,
) async {
  try {
    await m.createTable(table);
  } catch (error) {
    // "table X already exists".
    if (!_errorMatches(error, const ['already exists'])) rethrow;
  }
}

/// Backfill é best-effort: numa base que nunca teve a coluna legada, o
/// UPDATE não tem o que copiar. Qualquer outro erro sobe.
Future<void> _tryQuery(AppDatabase db, String sql) async {
  try {
    await db.customStatement(sql);
  } catch (error) {
    if (!_errorMatches(error, const ['no such column', 'no such table'])) {
      rethrow;
    }
  }
}
