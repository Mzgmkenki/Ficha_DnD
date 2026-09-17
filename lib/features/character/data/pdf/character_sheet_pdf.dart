import 'package:dnd_ficha_app/core/branding/app_branding.dart';
import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/core/utils/distance_format.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/sync_subclass_spells.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/services/active_effects.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/initiative_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/skill_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/spell_slot_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/spellcasting_service.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Tudo que o PDF precisa, já resolvido.
///
/// O gerador não conhece Riverpod nem o banco: quem monta este pacote é o caso
/// de uso. Isso deixa a geração testável sem subir app nem provider.
class CharacterSheetPdfData {
  const CharacterSheetPdfData({
    required this.character,
    this.classes = const [],
    this.subclasses = const [],
    this.races = const [],
    this.backgrounds = const [],
    this.classFeatures = const [],
    this.feats = const [],
    this.spells = const [],
    this.spellSlots = const [],
    this.logoBytes,
    this.portraitBytes,
    this.titleFontBytes,
  });

  final Character character;
  final List<ClassEntry> classes;
  final List<SubclassEntry> subclasses;
  final List<RaceEntry> races;
  final List<BackgroundEntry> backgrounds;
  final List<ClassFeatureEntry> classFeatures;

  /// Compêndio de talentos, para a iniciativa impressa bater com a da tela: o
  /// Alerta soma +5 e sem esta lista o PDF não saberia disso.
  final List<FeatEntry> feats;

  final List<SpellEntry> spells;
  final List<SpellSlotProgressionEntry> spellSlots;

  /// Logo do app, usada como marca d'água. Nulo enquanto a arte não existir.
  final Uint8List? logoBytes;

  /// Retrato do personagem, lido do disco. Nulo quando não há retrato.
  final Uint8List? portraitBytes;

  /// TTF dos títulos, para o PDF sair na mesma fonte da ficha.
  final Uint8List? titleFontBytes;
}

/// Monta o PDF da ficha.
///
/// O documento é claro, não escuro como o app: imprimir uma página preta gasta
/// tinta e o resultado fica pior que o da tela. O vermelho da identidade fica
/// nos títulos e nos destaques.
class CharacterSheetPdf {
  const CharacterSheetPdf._();

  static const PdfColor _ink = PdfColor.fromInt(0xFF1A1A1E);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B6B73);
  static const PdfColor _accent = PdfColor.fromInt(0xFFB71C24);
  static const PdfColor _rule = PdfColor.fromInt(0xFFD8D8DC);
  static const PdfColor _band = PdfColor.fromInt(0xFFF4F4F6);

  /// Moldura do retrato, na mesma proporção 4:3 do painel de personagens
  /// (`PortraitBanner`). Antes era um quadrado, e num retrato vertical o
  /// quadrado só cabia mostrando o corpo inteiro em miniatura.
  @visibleForTesting
  static const double portraitWidth = 88;

  @visibleForTesting
  static const double portraitHeight = portraitWidth / (4 / 3);

  /// Nome sugerido do arquivo, já sem caracteres que atrapalham no sistema.
  static String fileName(Character character) {
    final slug = character.name
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^A-Za-zÀ-ÿ0-9_-]'), '');

    return 'ficha-${slug.isEmpty ? 'personagem' : slug}.pdf';
  }

  static Future<Uint8List> build(CharacterSheetPdfData data) async {
    final character = data.character;
    final titleFont = _loadTitleFont(data.titleFontBytes);

    final document = pw.Document(
      title: 'Ficha de ${character.name}',
      author: AppBranding.appName,
      creator: AppBranding.appName,
    );

    final logo = data.logoBytes == null
        ? null
        : pw.MemoryImage(data.logoBytes!);

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 24),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
            italic: pw.Font.helveticaOblique(),
          ).copyWith(
            defaultTextStyle: pw.TextStyle(fontSize: 9, color: _ink),
          ),
          // A marca d'água vive no fundo da página, então repete em todas sem
          // interferir na paginação do conteúdo.
          buildBackground: (context) => _watermark(logo),
        ),
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : _runningHeader(character),
        footer: _footer,
        build: (context) => _body(data, titleFont),
      ),
    );

    return Uint8List.fromList(await document.save());
  }

  static pw.Font? _loadTitleFont(Uint8List? bytes) {
    if (bytes == null) return null;

    try {
      return pw.Font.ttf(bytes.buffer.asByteData());
    } catch (error) {
      // Fonte corrompida ou sem os glifos não pode impedir a exportação: os
      // títulos caem na Helvetica em negrito.
      debugPrint('Fonte dos títulos não pôde ser usada no PDF: $error');
      return null;
    }
  }

  /// Retrato enquadrado igual ao painel de personagens.
  ///
  /// O app resolve isso em `_PortraitFrame`: `cover` para preencher a moldura
  /// sem distorcer, e âncora no topo. As duas coisas juntas importam — `cover`
  /// centralizado, que era o padrão aqui, corta a faixa do meio de uma imagem
  /// vertical e é justamente a cabeça que se perde. Retrato de personagem é
  /// quase sempre vertical, e o rosto é o que identifica.
  static pw.Widget _portrait(Uint8List bytes) {
    return pw.Container(
      width: portraitWidth,
      height: portraitHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _rule),
        image: pw.DecorationImage(
          image: pw.MemoryImage(bytes),
          fit: pw.BoxFit.cover,
          // No espaço do PDF o y cresce para cima, então `topCenter` é
          // `Alignment(0, 1)` e realmente ancora no topo da imagem.
          alignment: pw.Alignment.topCenter,
        ),
      ),
    );
  }

  static pw.Widget _watermark(pw.MemoryImage? logo) {
    if (logo == null) return pw.SizedBox();

    return pw.Center(
      child: pw.Opacity(
        opacity: 0.06,
        child: pw.Image(logo, width: 330),
      ),
    );
  }

  static pw.Widget _runningHeader(Character character) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _rule)),
      ),
      child: pw.Text(
        _safe('${character.name} | Nível ${character.totalLevel}'),
        style: pw.TextStyle(fontSize: 8, color: _muted),
      ),
    );
  }

  static pw.Widget _footer(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            AppBranding.appName,
            style: pw.TextStyle(fontSize: 8, color: _muted),
          ),
          pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _body(
    CharacterSheetPdfData data,
    pw.Font? titleFont,
  ) {
    final character = data.character;

    return [
      _identity(data, titleFont),
      ..._section('Combate', titleFont, _combat(data)),
      ..._section('Atributos', titleFont, _abilities(character)),
      ..._section('Salvaguardas', titleFont, _savingThrows(character)),
      ..._section('Perícias', titleFont, _skills(character)),
      ..._section('Conjuração', titleFont, _spellcasting(data)),
      ..._section('Magias', titleFont, _spellList(data)),
      ..._section('Itens mágicos', titleFont, _magicItems(data)),
      ..._section('Condições e efeitos', titleFont, _conditions(character)),
      ..._section('Moedas', titleFont, _currency(character)),
      ..._section('Antecedente', titleFont, _background(data)),
      ..._section('Características raciais', titleFont, _race(data)),
      ..._section('Características de classe', titleFont, _classFeatures(data)),
      ..._section('Anotações', titleFont, _notes(character)),
    ];
  }

  // ---------------------------------------------------------------- identidade

  static pw.Widget _identity(CharacterSheetPdfData data, pw.Font? titleFont) {
    final character = data.character;
    final classLine = character.classLevels
        .map((item) => '${_className(data, item.classId)} ${item.level}')
        .join(' / ');

    final subclassLine = character.classLevels
        .map((item) => _subclassName(data, item.subclassId))
        .whereType<String>()
        .join(' | ');

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _accent, width: 1.4)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (data.portraitBytes != null) ...[
            _portrait(data.portraitBytes!),
            pw.SizedBox(width: 12),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _safe(character.name),
                  style: pw.TextStyle(
                    font: titleFont,
                    fontSize: 20,
                    fontWeight: titleFont == null ? pw.FontWeight.bold : null,
                    color: _ink,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  _safe(classLine.isEmpty ? 'Sem classe' : classLine),
                  style: pw.TextStyle(fontSize: 10, color: _accent),
                ),
                if (subclassLine.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    _safe(subclassLine),
                    style: pw.TextStyle(fontSize: 8.5, color: _muted),
                  ),
                ],
                pw.SizedBox(height: 4),
                pw.Text(
                  _safe(
                    'Nível ${character.totalLevel}  |  '
                    'Proficiência ${_signed(character.proficiencyBonus)}'
                    '${_raceSuffix(data)}'
                    '${_playerSuffix(character)}',
                  ),
                  style: pw.TextStyle(fontSize: 9, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _raceSuffix(CharacterSheetPdfData data) {
    final race = _raceName(data);
    return race == null ? '' : '  |  $race';
  }

  static String _playerSuffix(Character character) {
    final player = character.playerName?.trim() ?? '';
    return player.isEmpty ? '' : '  |  Jogador: $player';
  }

  // ------------------------------------------------------------------- combate

  static List<pw.Widget> _combat(CharacterSheetPdfData data) {
    final character = data.character;
    final stats = character.combatStats;
    final hp = character.hitPoints;

    final pool = HitPointsCalculator.hitDicePool(
      classLevels: character.classLevels,
      classes: data.classes,
    );
    final totalHitDice = character.classLevels.fold<int>(
      0,
      (sum, item) => sum + item.level,
    );

    final hpLabel = hp.temporary > 0
        ? '${hp.current} / ${hp.maximum} (+${hp.temporary} temp.)'
        : '${hp.current} / ${hp.maximum}';

    // Mesmo serviço da ficha: a Destreza entra sempre e as regras especiais
    // vêm do compêndio. Antes o PDF repetia a soma à mão.
    final initiative = InitiativeCalculator.calculate(
      character: character,
      classFeatures: data.classFeatures,
      subclasses: data.subclasses,
      feats: data.feats,
      races: data.races,
    );

    return [
      _chipRow([
        _chip('CA', '${stats.armorClass}'),
        _chip(
          'Iniciativa',
          initiative.hasAdvantage
              ? '${initiative.formattedTotal} (vantagem)'
              : initiative.formattedTotal,
        ),
        _chip('Deslocamento', formatMeters(stats.speedInMeters)),
        _chip('Pontos de vida', hpLabel),
        _chip(
          'Dados de vida',
          pool.isEmpty
              ? '—'
              : '${pool.map((group) => group.label).join(' + ')} '
                  '(${totalHitDice - character.hitDiceUsed} livres)',
        ),
        if (character.inspiration) _chip('Inspiração', 'Sim'),
      ]),
      // A composição impressa deixa o jogador conferir a conta na mesa, sem o
      // app aberto. Só aparece quando há algo além da Destreza.
      if (initiative.modifiers.length > 1)
        _plain('Iniciativa: ${initiative.explanation}'),
      if (initiative.hasAdvantage)
        _plain(
          'Vantagem na iniciativa: '
          '${initiative.advantageSources.join(', ')}.',
        ),
    ];
  }

  // ----------------------------------------------------------------- atributos

  static List<pw.Widget> _abilities(Character character) {
    return [
      pw.Row(
        children: [
          for (final ability in Ability.values)
            pw.Expanded(
              child: pw.Container(
                margin: const pw.EdgeInsets.only(right: 5),
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                decoration: pw.BoxDecoration(
                  color: _band,
                  border: pw.Border.all(color: _rule),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      ability.abbreviation,
                      style: pw.TextStyle(fontSize: 8, color: _muted),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${character.abilityScores.valueFor(ability)}',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                    pw.Text(
                      _signed(
                        character.abilityScores
                            .valueFor(ability)
                            .abilityModifier,
                      ),
                      style: pw.TextStyle(fontSize: 9, color: _accent),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ];
  }

  // -------------------------------------------------------------- salvaguardas

  static List<pw.Widget> _savingThrows(Character character) {
    final saves = character.savingThrowProficiencies;

    bool proficientIn(Ability ability) {
      switch (ability) {
        case Ability.strength:
          return saves.strength;
        case Ability.dexterity:
          return saves.dexterity;
        case Ability.constitution:
          return saves.constitution;
        case Ability.intelligence:
          return saves.intelligence;
        case Ability.wisdom:
          return saves.wisdom;
        case Ability.charisma:
          return saves.charisma;
      }
    }

    return [
      _chipRow([
        for (final ability in Ability.values)
          _chip(
            ability.label,
            _signed(
              character.abilityScores.valueFor(ability).abilityModifier +
                  (proficientIn(ability) ? character.proficiencyBonus : 0),
            ),
            highlight: proficientIn(ability),
          ),
      ]),
    ];
  }

  // ------------------------------------------------------------------ perícias

  static List<pw.Widget> _skills(Character character) {
    final skills = Skill.sortedByLabel;
    final rows = <pw.TableRow>[];

    // Duas perícias por linha: dezoito numa coluna só empurraria o resto do
    // documento para a página seguinte sem necessidade.
    for (var i = 0; i < skills.length; i += 2) {
      rows.add(
        pw.TableRow(
          children: [
            _skillCell(character, skills[i]),
            if (i + 1 < skills.length)
              _skillCell(character, skills[i + 1])
            else
              pw.SizedBox(),
          ],
        ),
      );
    }

    return [
      pw.Table(
        border: pw.TableBorder.all(color: _rule),
        // Largura fixa por coluna é obrigatória aqui: as células usam
        // `Expanded`, e a largura intrínseca padrão da tabela chega sem limite,
        // o que faz o layout do pdf lançar em vez de desenhar.
        columnWidths: const {
          0: pw.FlexColumnWidth(),
          1: pw.FlexColumnWidth(),
        },
        children: rows,
      ),
      pw.SizedBox(height: 6),
      _chipRow([
        _chip('Percepção passiva', '${SkillCalculator.passivePerception(character)}'),
        _chip(
          'Investigação passiva',
          '${SkillCalculator.passiveInvestigation(character)}',
        ),
        _chip('Intuição passiva', '${SkillCalculator.passiveInsight(character)}'),
      ]),
    ];
  }

  static pw.Widget _skillCell(Character character, Skill skill) {
    final level = character.skillProficiencies.levelFor(skill);
    final tag = level.shortTag;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              _safe('${skill.label} (${skill.abbreviation})'),
              style: pw.TextStyle(
                fontSize: 8.5,
                color: level.isProficientOrBetter ? _ink : _muted,
                fontWeight:
                    level.isProficientOrBetter ? pw.FontWeight.bold : null,
              ),
            ),
          ),
          if (tag != null)
            pw.Text(
              _safe(' $tag '),
              style: pw.TextStyle(fontSize: 7.5, color: _accent),
            ),
          pw.Text(
            _signed(SkillCalculator.skillBonus(character, skill)),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- conjuração

  static List<pw.Widget> _spellcasting(CharacterSheetPdfData data) {
    final character = data.character;

    final summary = SpellSlotCalculator.summarize(
      classLevels: character.classLevels,
      classes: data.classes,
      progressions: data.spellSlots,
    );

    if (!summary.hasAnyCasting) {
      return [_plain('Nenhuma classe conjuradora.')];
    }

    final widgets = <pw.Widget>[];

    // CD e ataque por classe conjuradora, que é o número mais consultado em
    // mesa depois do ataque.
    final casterChips = <pw.Widget>[];

    // Mesmo serviço da ficha: só entra o bônus que o item declarou em campo
    // próprio, nunca um `+1` deduzido do nome.
    final itemBonus = SpellcastingService.itemBonuses(character.magicItems);

    for (final classLevel in character.classLevels) {
      final entry = _classEntry(data, classLevel.classId);
      if (entry == null || !entry.isSpellcaster) continue;
      if (classLevel.level < entry.spellcastingStartLevel) continue;

      final ability = Ability.fromName(entry.spellcastingAbility);
      if (ability == null) continue;

      casterChips.add(
        _chip(
          '${entry.name} (${ability.abbreviation})',
          'CD ${SpellcastingService.spellSaveDc(
            proficiencyBonus: character.proficiencyBonus,
            castingAbility: ability,
            scores: character.abilityScores,
            itemBonus: itemBonus.saveDc,
          )}  |  Ataque ${_signed(SpellcastingService.spellAttackBonus(
            proficiencyBonus: character.proficiencyBonus,
            castingAbility: ability,
            scores: character.abilityScores,
            itemBonus: itemBonus.attack,
          ))}',
        ),
      );
    }

    if (casterChips.isNotEmpty) widgets.add(_chipRow(casterChips));

    final standard = summary.standardSlots;
    if (standard != null) {
      widgets
        ..add(pw.SizedBox(height: 6))
        ..add(_slotRow('Espaços de magia', standard));
    }

    final pact = summary.pactSlots;
    if (pact != null) {
      widgets
        ..add(pw.SizedBox(height: 6))
        ..add(_slotRow('Magia de Pacto', pact));
    }

    if (summary.explanation != null) {
      widgets
        ..add(pw.SizedBox(height: 4))
        ..add(_plain(summary.explanation!.trim()));
    }

    return widgets;
  }

  static pw.Widget _slotRow(String title, SpellSlotProgressionEntry row) {
    final slots = SpellSlotCalculator.slotsByLevel(row);

    if (slots.isEmpty) return _plain('$title: nenhum.');

    return _chipRow([
      for (final entry in slots.entries)
        _chip('${entry.key}º círculo', '${entry.value}'),
    ], label: title);
  }

  // -------------------------------------------------------------------- magias

  static const Map<String, String> _sourceLabels = {
    'class': 'Classe',
    subclassSpellSource: 'Subclasse',
    'grimorio': 'Grimório',
    'race': 'Raça',
    'feat': 'Talento',
    'item': 'Item',
    'custom': 'Origem customizada',
  };

  static List<pw.Widget> _spellList(CharacterSheetPdfData data) {
    final character = data.character;
    if (character.spells.isEmpty) {
      return [_plain('Nenhuma magia vinculada.')];
    }

    final byId = {for (final spell in data.spells) spell.id: spell};

    // Agrupa por origem e, dentro dela, pelo nome da origem: é como a ficha
    // mostra, e é o que o jogador procura ("as magias do meu domínio").
    final grouped = <String, List<CharacterSpell>>{};
    for (final spell in character.spells) {
      final label = _sourceLabels[spell.sourceType] ?? 'Outras origens';
      final key = spell.sourceName.trim().isEmpty
          ? label
          : '$label: ${spell.sourceName}';
      grouped.putIfAbsent(key, () => []).add(spell);
    }

    final keys = grouped.keys.toList()..sort();
    final widgets = <pw.Widget>[];

    for (final key in keys) {
      final list = grouped[key]!
        ..sort((a, b) {
          final levelA = byId[a.spellId]?.level ?? 0;
          final levelB = byId[b.spellId]?.level ?? 0;
          if (levelA != levelB) return levelA.compareTo(levelB);

          final nameA = byId[a.spellId]?.namePt ?? '';
          final nameB = byId[b.spellId]?.namePt ?? '';
          return nameA.compareTo(nameB);
        });

      widgets
        ..add(_subTitle('$key (${list.length})'))
        ..add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final spell in list) _spellLine(spell, byId[spell.spellId]),
            ],
          ),
        )
        ..add(pw.SizedBox(height: 6));
    }

    return widgets;
  }

  static pw.Widget _spellLine(CharacterSpell spell, SpellEntry? entry) {
    final tags = <String>[
      if (spell.isPrepared) 'preparada',
      if (spell.isAlwaysAvailable) 'sempre disponível',
    ];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 58,
            child: pw.Text(
              entry == null
                  ? '-'
                  : _safe(
                      entry.level == 0
                          ? 'Truque'
                          : '${entry.level}º círculo',
                    ),
              style: pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              _safe(entry?.namePt ?? 'Magia #${spell.spellId}'),
              style: pw.TextStyle(fontSize: 8.5, color: _ink),
            ),
          ),
          if (tags.isNotEmpty)
            pw.Text(
              _safe(tags.join(', ')),
              style: pw.TextStyle(fontSize: 7.5, color: _accent),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------- itens

  static List<pw.Widget> _magicItems(CharacterSheetPdfData data) {
    final items = data.character.magicItems;
    if (items.isEmpty) return [_plain('Nenhum item mágico.')];

    final byId = {for (final spell in data.spells) spell.id: spell};

    return [
      for (final item in items)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      _safe(item.name),
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                  ),
                  if (item.maxCharges != null)
                    pw.Text(
                      'Cargas ${item.charges ?? 0} / ${item.maxCharges}',
                      style: pw.TextStyle(fontSize: 8, color: _accent),
                    ),
                ],
              ),
              if (item.description.trim().isNotEmpty)
                pw.Text(
                  _safe(item.description.trim()),
                  style: pw.TextStyle(fontSize: 8, color: _muted),
                ),
              if (item.spells.isNotEmpty)
                pw.Text(
                  _safe(
                    'Magias: ${item.spells.map((s) => byId[s.spellId]?.namePt ?? '#${s.spellId}').join(', ')}',
                  ),
                  style: pw.TextStyle(fontSize: 8, color: _ink),
                ),
            ],
          ),
        ),
    ];
  }

  // ---------------------------------------------------------------- condições

  static List<pw.Widget> _conditions(Character character) {
    final effects = ActiveEffects.from(
      conditions: character.conditions,
      exhaustion: character.exhaustion,
    );

    if (effects.isEmpty) return [_plain('Nenhuma condição ativa.')];

    return [
      for (final effect in effects)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _safe(
                  effect.isImplied
                      ? '${effect.source} (por ${effect.impliedBy})'
                      : effect.source,
                ),
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _accent,
                ),
              ),
              for (final line in effect.effects)
                pw.Text(
                  _safe('- $line'),
                  style: pw.TextStyle(fontSize: 8, color: _ink),
                ),
            ],
          ),
        ),
    ];
  }

  // ------------------------------------------------------------------- moedas

  static List<pw.Widget> _currency(Character character) {
    final currency = character.currency;

    return [
      _chipRow([
        _chip('PL', '${currency.platinum}'),
        _chip('PO', '${currency.gold}'),
        _chip('PE', '${currency.electrum}'),
        _chip('PP', '${currency.silver}'),
        _chip('PC', '${currency.copper}'),
        _chip('Total em ouro', currency.totalInGold.toStringAsFixed(2)),
      ]),
    ];
  }

  // -------------------------------------------------------------- antecedente

  static List<pw.Widget> _background(CharacterSheetPdfData data) {
    final character = data.character;

    if (character.backgroundId == BackgroundEntry.customId) {
      final custom = character.customBackground;
      return [
        _subTitle(custom.displayName),
        if (custom.skills.isNotEmpty)
          _plain('Perícias: ${custom.skills.map((s) => s.label).join(', ')}'),
        if (custom.features.trim().isNotEmpty)
          _plain(custom.features.trim()),
      ];
    }

    final entry = _firstWhereOrNull(
      data.backgrounds,
      (item) => item.id == character.backgroundId,
    );

    if (entry == null) return [_plain('Nenhum antecedente escolhido.')];

    return [
      _subTitle(entry.name),
      if (entry.skills.isNotEmpty)
        _plain('Perícias: ${entry.skills.map((s) => s.label).join(', ')}'),
      if (entry.featureName != null)
        _plain('${entry.featureName}: ${entry.featureDescription ?? ''}'),
      if (entry.description != null) _plain(entry.description!),
    ];
  }

  // ---------------------------------------------------------------------- raça

  static List<pw.Widget> _race(CharacterSheetPdfData data) {
    final race = _raceEntry(data);
    if (race == null) return [_plain('Nenhuma raça escolhida.')];

    // Subraça herda os traços da raça base, então junta os dois.
    final parent = race.hasParentRace
        ? _firstWhereOrNull(data.races, (item) => item.id == race.parentRaceId)
        : null;

    final traits = <String>[
      ...?parent?.traits,
      ...race.traits,
    ];
    final languages = <String>[
      ...?parent?.languages,
      ...race.languages,
    ];

    return [
      _subTitle(race.name),
      if (race.size != null || race.speed != null || race.darkvision != null)
        _plain(
          [
            if (race.size != null) 'Tamanho: ${race.size}',
            if ((race.speed ?? parent?.speed) != null)
              'Deslocamento: ${formatMeters(race.speed ?? parent!.speed!)}',
            if ((race.darkvision ?? parent?.darkvision) != null)
              'Visão no escuro: ${race.darkvision ?? parent!.darkvision} m',
          ].join('  |  '),
        ),
      if (languages.isNotEmpty) _plain('Idiomas: ${languages.join(', ')}'),
      for (final trait in traits) _plain('- $trait'),
    ];
  }

  // ---------------------------------------------------- características classe

  static List<pw.Widget> _classFeatures(CharacterSheetPdfData data) {
    final character = data.character;
    if (character.classLevels.isEmpty) return [_plain('Sem classes.')];

    final widgets = <pw.Widget>[];

    for (final classLevel in character.classLevels) {
      final features = data.classFeatures
          .where(
            (entry) =>
                entry.classId == classLevel.classId &&
                entry.level <= classLevel.level,
          )
          .toList()
        ..sort((a, b) => a.level.compareTo(b.level));

      widgets.add(
        _subTitle(
          '${_className(data, classLevel.classId)} — nível ${classLevel.level}',
        ),
      );

      if (features.isEmpty) {
        widgets.add(_plain('Nenhuma característica cadastrada.'));
      } else {
        for (final entry in features) {
          for (final feature in entry.features) {
            // Mesmo formato do bloco de subclasse logo abaixo. Quando não há
            // texto cadastrado, sai só o nome em vez de dois-pontos vazios.
            widgets.add(
              _plain(
                feature.hasDescription
                    ? '- ${feature.name} (nível ${entry.level}): '
                        '${feature.description}'
                    : '- ${feature.name} (nível ${entry.level})',
              ),
            );
          }
        }
      }

      final subclass = _subclassEntry(data, classLevel.subclassId);
      if (subclass != null) {
        widgets.add(_subTitle(subclass.name, small: true));
        final unlocked = subclass.featuresUpTo(classLevel.level);

        if (unlocked.isEmpty) {
          widgets.add(_plain('Nenhuma característica liberada ainda.'));
        } else {
          for (final feature in unlocked) {
            widgets.add(
              _plain('- ${feature.name} (nível ${feature.level}): '
                  '${feature.description}'),
            );
          }
        }
      }

      widgets.add(pw.SizedBox(height: 6));
    }

    return widgets;
  }

  // ---------------------------------------------------------------- anotações

  static List<pw.Widget> _notes(Character character) {
    final notes = character.notes.trim();
    return [_plain(notes.isEmpty ? 'Sem anotações.' : notes)];
  }

  // ------------------------------------------------------------------- helpers

  static List<pw.Widget> _section(
    String title,
    pw.Font? titleFont,
    List<pw.Widget> children,
  ) {
    return [
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 10, bottom: 5),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _safe(title.toUpperCase()),
              style: pw.TextStyle(
                font: titleFont,
                fontSize: 11,
                fontWeight: titleFont == null ? pw.FontWeight.bold : null,
                color: _accent,
                letterSpacing: 0.6,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Container(height: 0.8, color: _rule),
          ],
        ),
      ),
      ...children,
    ];
  }

  static pw.Widget _subTitle(String text, {bool small = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 3, bottom: 2),
      child: pw.Text(
        _safe(text),
        style: pw.TextStyle(
          fontSize: small ? 8.5 : 9.5,
          fontWeight: pw.FontWeight.bold,
          color: small ? _muted : _ink,
        ),
      ),
    );
  }

  static pw.Widget _plain(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5),
      child: pw.Text(
        _safe(text),
        style: pw.TextStyle(fontSize: 8.5, color: _ink),
      ),
    );
  }

  static pw.Widget _chipRow(List<pw.Widget> chips, {String? label}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (label != null)
          pw.Text(
            _safe(label),
            style: pw.TextStyle(fontSize: 8, color: _muted),
          ),
        pw.Wrap(spacing: 6, runSpacing: 5, children: chips),
      ],
    );
  }

  static pw.Widget _chip(String label, String value, {bool highlight = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: pw.BoxDecoration(
        color: highlight ? _band : null,
        border: pw.Border.all(color: highlight ? _accent : _rule),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            _safe(label),
            style: pw.TextStyle(fontSize: 7.5, color: _muted),
          ),
          pw.SizedBox(width: 5),
          pw.Text(
            _safe(value),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  static String _signed(int value) => value >= 0 ? '+$value' : '$value';

  /// Deixa o texto no que a Helvetica embutida sabe desenhar.
  ///
  /// As fontes internas do PDF usam WinAnsi, que cobre o português acentuado
  /// mas não caracteres tipográficos. Sem esta limpeza, um travessão ou uma
  /// aspa curva vinda do compêndio derruba a geração inteira com
  /// "Unable to find a font to draw". Trocar por equivalente ASCII é melhor que
  /// embutir uma fonte de texto só por causa de pontuação.
  static String _safe(String value) {
    final mapped = value
        .replaceAll('\u2022', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-')
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll('\u2026', '...')
        .replaceAll('\u00A0', ' ');

    return String.fromCharCodes(
      mapped.runes.map((rune) => rune <= 0xFF ? rune : 0x3F),
    );
  }

  static ClassEntry? _classEntry(CharacterSheetPdfData data, String classId) {
    return _firstWhereOrNull(data.classes, (item) => item.id == classId);
  }

  static String _className(CharacterSheetPdfData data, String classId) {
    return _classEntry(data, classId)?.name ?? classId;
  }

  static SubclassEntry? _subclassEntry(
    CharacterSheetPdfData data,
    String? subclassId,
  ) {
    if (subclassId == null || subclassId.isEmpty) return null;
    return _firstWhereOrNull(data.subclasses, (item) => item.id == subclassId);
  }

  static String? _subclassName(CharacterSheetPdfData data, String? subclassId) {
    return _subclassEntry(data, subclassId)?.name;
  }

  static RaceEntry? _raceEntry(CharacterSheetPdfData data) {
    final id = data.character.speciesId;
    if (id == null || id.isEmpty) return null;
    return _firstWhereOrNull(data.races, (item) => item.id == id);
  }

  static String? _raceName(CharacterSheetPdfData data) => _raceEntry(data)?.name;

  static T? _firstWhereOrNull<T>(List<T> list, bool Function(T) test) {
    for (final item in list) {
      if (test(item)) return item;
    }
    return null;
  }
}
