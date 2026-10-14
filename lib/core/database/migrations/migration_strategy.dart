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
        await _tryAddColumn(
          m,
          db.characters,
          db.characters.skillAnimalHandling,
        );
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

      if (from < 10) {
        // Condições ativas (paralisado, atordoado, etc.), como CSV de ids.
        await _tryAddColumn(m, db.characters, db.characters.conditions);

        // O ALTER TABLE com DEFAULT já preenche as linhas existentes, mas em
        // base que veio de uma versão onde a coluna foi criada sem default o
        // valor fica nulo, e `parseCsv` receberia null. Barato garantir.
        await _tryQuery(
          db,
          "UPDATE characters SET conditions = '' WHERE conditions IS NULL",
        );
      }

      if (from < 11) {
        // Talentos escolhidos pelo personagem.
        await _tryCreateTable(m, db.characterFeats);
      }

      if (from < 12) {
        // Aumento de atributo do talento: o atributo que o jogador escolheu e
        // quanto o talento realmente somou.
        await _tryAddColumn(
          m,
          db.characterFeats,
          db.characterFeats.chosenAbility,
        );
        await _tryAddColumn(
          m,
          db.characterFeats,
          db.characterFeats.appliedAbilityIncreases,
        );

        // Talento pego antes desta versão não somou nada, então fica com o
        // mapa vazio — e removê-lo não vai tirar ponto de atributo nenhum.
        await _tryQuery(
          db,
          "UPDATE character_feats SET applied_ability_increases = '' "
          'WHERE applied_ability_increases IS NULL',
        );
      }

      if (from < 13) {
        // Armas do personagem.
        await _tryCreateTable(m, db.characterWeapons);

        // Bônus estruturados do item mágico. As colunas `save_dc` e
        // `attack_bonus` continuam existindo e continuam significando valor
        // absoluto: quem tinha um item com CD fixa não perde nada.
        await _tryAddColumn(
          m,
          db.characterMagicItems,
          db.characterMagicItems.weaponAttackBonus,
        );
        await _tryAddColumn(
          m,
          db.characterMagicItems,
          db.characterMagicItems.weaponDamageBonus,
        );
        await _tryAddColumn(
          m,
          db.characterMagicItems,
          db.characterMagicItems.spellAttackBonus,
        );
        await _tryAddColumn(
          m,
          db.characterMagicItems,
          db.characterMagicItems.spellSaveDcBonus,
        );

        // Item cadastrado antes desta versão não declarava nenhum bônus, então
        // fica em zero. Deduzir um `+1` do nome seria adivinhar: o app não sabe
        // se a descrição manda somar em ataque mágico ou só na arma.
        for (final column in const [
          'weapon_attack_bonus',
          'weapon_damage_bonus',
          'spell_attack_bonus',
          'spell_save_dc_bonus',
        ]) {
          await _tryQuery(
            db,
            'UPDATE character_magic_items SET $column = 0 '
            'WHERE $column IS NULL',
          );
        }
      }

      if (from < 14) {
        // Bônus controlado do item mágico: um degrau (0, +1, +2, +3) mais as
        // estatísticas que ele afeta, em vez de quatro números livres.
        await _tryAddColumn(
          m,
          db.characterMagicItems,
          db.characterMagicItems.magicBonus,
        );
        await _tryAddColumn(
          m,
          db.characterMagicItems,
          db.characterMagicItems.bonusTargets,
        );

        // Estado de uso. Sem isso todo item somava sempre, inclusive o que
        // está na mochila e o que exige sintonia sem estar sintonizado.
        await _tryAddColumn(
          m,
          db.characterMagicItems,
          db.characterMagicItems.isEquipped,
        );
        await _tryAddColumn(
          m,
          db.characterMagicItems,
          db.characterMagicItems.requiresAttunement,
        );
        await _tryAddColumn(
          m,
          db.characterMagicItems,
          db.characterMagicItems.isAttuned,
        );

        // Item que já existia continua valendo o que valia: equipado, sem
        // exigência de sintonia. Marcar `requires_attunement` por conta
        // própria desligaria bônus que o jogador já usava em mesa.
        await _tryQuery(
          db,
          'UPDATE character_magic_items SET is_equipped = 1 '
          'WHERE is_equipped IS NULL',
        );
        await _tryQuery(
          db,
          'UPDATE character_magic_items SET requires_attunement = 0 '
          'WHERE requires_attunement IS NULL',
        );
        await _tryQuery(
          db,
          'UPDATE character_magic_items SET is_attuned = 0 '
          'WHERE is_attuned IS NULL',
        );
        await _tryQuery(
          db,
          'UPDATE character_magic_items SET magic_bonus = 0 '
          'WHERE magic_bonus IS NULL',
        );
        await _tryQuery(
          db,
          "UPDATE character_magic_items SET bonus_targets = '' "
          'WHERE bonus_targets IS NULL',
        );

        // A conversão dos quatro campos livres para o degrau + estatísticas
        // NÃO acontece aqui de propósito. Ela depende de comparar os quatro
        // valores entre si, e fazer isso exigiria ler as linhas dentro da
        // transação de migração — o que trava a abertura do banco (ver o
        // comentário no topo deste arquivo). Em vez disso a leitura no
        // repositório reconhece a linha antiga (`bonus_targets` vazio e
        // `magic_bonus` zero com algum dos quatro diferente de zero) e chama
        // `convertLegacyMagicItemBonuses`, que é puro e testável. O efeito é o
        // mesmo e nada é perdido: o item só passa a gravar no formato novo
        // quando o jogador o edita.
      }

      if (from < 15) {
        // Alinhamento. Fica anulável e SEM backfill de propósito: nulo é "não
        // definido", e escolher um alinhamento para o personagem que já existe
        // seria inventar uma decisão do jogador. Neutro não é o padrão.
        await _tryAddColumn(m, db.characters, db.characters.alignment);

        // Testes contra a morte: um contador para cada lado.
        await _tryAddColumn(m, db.characters, db.characters.deathSaveSuccesses);
        await _tryAddColumn(m, db.characters, db.characters.deathSaveFailures);

        // Personagem que já existia não estava no meio de uma sequência de
        // testes, então começa zerado nos dois lados.
        for (final column in const [
          'death_save_successes',
          'death_save_failures',
        ]) {
          await _tryQuery(
            db,
            'UPDATE characters SET $column = 0 WHERE $column IS NULL',
          );
        }
      }

      if (from < 16) {
        // Metadados de criação. As duas primeiras colunas ficam nulas em
        // personagens antigos: inferir a base a partir do total perderia a
        // distinção entre bônus de origem, talento e edição manual.
        await _tryAddColumn(m, db.characters, db.characters.baseAbilityScores);
        await _tryAddColumn(
          m,
          db.characters,
          db.characters.originAbilityBonuses,
        );
        await _tryAddColumn(
          m,
          db.characters,
          db.characters.skillProficiencyGrants,
        );

        await _tryQuery(
          db,
          "UPDATE characters SET skill_proficiency_grants = '[]' "
          'WHERE skill_proficiency_grants IS NULL',
        );
      }

      if (from < 17) {
        // Inventário do personagem e rastro de origem do dinheiro.
        //
        // As duas tabelas nascem vazias de propósito. Popular o inventário a
        // partir das armas e dos itens mágicos já cadastrados pareceria
        // simpático, mas duplicaria o que já aparece naquelas seções: a espada
        // apareceria em "Armas" e de novo em "Inventário", e consumir uma
        // delas não mexeria na outra. Quem quiser a arma listada também no
        // inventário adiciona o item e usa o vínculo
        // (`linked_weapon_local_id`), que é explícito.
        await _tryCreateTable(m, db.characterInventoryItems);
        await _tryCreateTable(m, db.characterCurrencyGrants);

        // Traços, ideal, vínculo e defeito escolhidos no antecedente.
        await _tryAddColumn(
          m,
          db.characters,
          db.characters.backgroundPersonalityChoices,
        );

        // Personagem anterior a esta versão não tem escolhas narrativas, e
        // sortear por conta própria seria inventar decisão do jogador. Fica a
        // lista vazia: a ficha mostra o antecedente normalmente, só sem a
        // seção de personalidade, e a criação de personagem novo é que passa a
        // pedir as escolhas.
        await _tryQuery(
          db,
          "UPDATE characters SET background_personality_choices = '[]' "
          'WHERE background_personality_choices IS NULL',
        );
      }

      if (from < 18) {
        // Equipamento inicial da classe: a arma passa a ter quantidade e
        // rastro de origem, como o item de inventário já tinha.
        //
        // Nada é inferido para a arma que já existia. Ela fica com quantidade
        // 1, origem `manual` e sem referência de concessão — que é a verdade:
        // foi o jogador quem a cadastrou. Deduzir "classe" a partir da
        // proficiência faria a troca de classe apagar arma que o jogador
        // escolheu à mão.
        await _tryAddColumn(
          m,
          db.characterWeapons,
          db.characterWeapons.quantity,
        );
        await _tryAddColumn(m, db.characterWeapons, db.characterWeapons.source);
        await _tryAddColumn(
          m,
          db.characterWeapons,
          db.characterWeapons.sourceId,
        );
        await _tryAddColumn(
          m,
          db.characterWeapons,
          db.characterWeapons.sourceLabel,
        );
        await _tryAddColumn(
          m,
          db.characterWeapons,
          db.characterWeapons.grantedAtCreation,
        );
        await _tryAddColumn(
          m,
          db.characterWeapons,
          db.characterWeapons.grantedQuantity,
        );
        await _tryAddColumn(
          m,
          db.characterWeapons,
          db.characterWeapons.manuallyEdited,
        );
        await _tryAddColumn(
          m,
          db.characterWeapons,
          db.characterWeapons.grantRef,
        );

        // Qual grupo e qual alternativa concederam o item.
        await _tryAddColumn(
          m,
          db.characterInventoryItems,
          db.characterInventoryItems.grantRef,
        );

        // O ALTER TABLE com DEFAULT já preenche as linhas existentes, mas em
        // base que veio de uma versão onde a coluna foi criada sem default o
        // valor fica nulo, e aí a leitura veria quantidade zero numa arma que
        // o personagem tem. Barato garantir.
        await _tryQuery(
          db,
          'UPDATE character_weapons SET quantity = 1 '
          'WHERE quantity IS NULL OR quantity < 1',
        );
        await _tryQuery(
          db,
          "UPDATE character_weapons SET source = 'manual' WHERE source IS NULL",
        );
        await _tryQuery(
          db,
          'UPDATE character_weapons SET granted_at_creation = 0 '
          'WHERE granted_at_creation IS NULL',
        );
        await _tryQuery(
          db,
          'UPDATE character_weapons SET manually_edited = 0 '
          'WHERE manually_edited IS NULL',
        );
      }

      if (from < 19) {
        // Requisito de Força e desvantagem em Furtividade por PEÇA, para a
        // armadura mágica poder divergir da tabela.
        //
        // As duas primeiras ficam nulas, e nulo quer dizer "usa o que a tabela
        // diz". É o que mantém a armadura já gravada se comportando igual: a
        // cota de malha continua exigindo Força 13 porque o requisito vive na
        // tabela, não na linha. Preencher com o valor da tabela aqui seria
        // congelar o dado e perder correção futura do compêndio.
        await _tryAddColumn(
          m,
          db.characterInventoryItems,
          db.characterInventoryItems.armorStrengthRequirement,
        );
        await _tryAddColumn(
          m,
          db.characterInventoryItems,
          db.characterInventoryItems.armorStealthDisadvantage,
        );
        await _tryAddColumn(
          m,
          db.characterInventoryItems,
          db.characterInventoryItems.armorMagicBonus,
        );

        await _tryQuery(
          db,
          'UPDATE character_inventory_items SET armor_magic_bonus = 0 '
          'WHERE armor_magic_bonus IS NULL',
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
