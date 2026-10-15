import 'package:dnd_ficha_app/core/branding/app_branding.dart';
import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/core/utils/distance_format.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/sync_subclass_spells.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_magic_item.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_spell.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/death_saves.dart';
import 'package:dnd_ficha_app/features/character/domain/services/active_effects.dart';
import 'package:dnd_ficha_app/features/character/domain/services/hit_points_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/initiative_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/skill_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/spell_slot_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/services/spellcasting_service.dart';
import 'package:dnd_ficha_app/features/character/domain/services/weapon_attack_calculator.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/condition.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/proficiency_level.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/weapon_entry.dart';
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
    this.weapons = const [],
    this.logoBytes,
    this.iconBytes,
    this.portraitBytes,
    this.titleFontBytes,
    this.interactiveForms = true,
    this.armorClass,
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

  /// Compêndio de armas, para a ficha imprimir os ataques.
  ///
  /// `CharacterWeapon` guarda só a decisão do jogador; dado de dano, tipo de
  /// dano, propriedades e alcance vivem no compêndio e são resolvidos por id.
  final List<WeaponEntry> weapons;

  /// Logo completa, com o wordmark. Nulo enquanto a arte não existir.
  final Uint8List? logoBytes;

  /// Só a marca, sem o nome. É o que vira marca d'água e o selo do cabeçalho:
  /// reduzido, o wordmark da logo completa viraria um borrão, e no fundo da
  /// página o nome repetido atrás do texto atrapalha a leitura.
  final Uint8List? iconBytes;

  /// Retrato do personagem, lido do disco. Nulo quando não há retrato.
  final Uint8List? portraitBytes;

  /// TTF dos títulos, para o PDF sair na mesma fonte da ficha.
  final Uint8List? titleFontBytes;

  /// Se as caixas de marcação saem como campo de formulário do PDF.
  ///
  /// Ligado, o jogador marca a condição no leitor. Desligado, sai a mesma caixa
  /// desenhada, para marcar à mão depois de imprimir. O desenho é idêntico nos
  /// dois casos, então a ficha impressa não muda de aparência.
  final bool interactiveForms;

  /// CA já resolvida, com fórmula de característica e bônus manual.
  ///
  /// Vem de fora pelo mesmo motivo da iniciativa: a CA depende do compêndio
  /// (Defesa sem Armadura é uma característica de classe), e o gerador não
  /// conhece provider nem banco. Nulo cai no inteiro gravado no personagem,
  /// que é o que o PDF usava antes.
  final int? armorClass;

  /// A CA que o PDF deve imprimir.
  int get effectiveArmorClass => armorClass ?? character.combatStats.armorClass;
}

/// Monta o PDF da ficha.
///
/// O documento é claro, não escuro como o app: imprimir uma página preta gasta
/// tinta e o resultado fica pior que o da tela. A identidade vem da fonte dos
/// títulos, do vermelho DragonSheet nos cabeçalhos e da marca d'água discreta —
/// e não de ornamento, que em impressão a laser vira borrão.
///
/// A organização segue a lógica de uma ficha de mesa: o que é consultado a cada
/// turno vem primeiro, em caixa destacada; o que é consultado de vez em quando
/// vem em lista, depois. O layout é próprio do DragonSheet.
class CharacterSheetPdf {
  const CharacterSheetPdf._();

  // ------------------------------------------------------------------- paleta

  static const PdfColor _ink = PdfColor.fromInt(0xFF1A1A1E);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B6B73);
  static const PdfColor _accent = PdfColor.fromInt(0xFFB71C24);
  static const PdfColor _rule = PdfColor.fromInt(0xFFD8D8DC);

  /// Borda das caixas de valor. Mais escura que [_rule] porque a caixa precisa
  /// se ler como caixa em escala de cinza, e não como sombra.
  static const PdfColor _boxRule = PdfColor.fromInt(0xFF8A8A93);

  static const PdfColor _band = PdfColor.fromInt(0xFFF4F4F6);

  /// Faixa dos cabeçalhos de seção: vermelho lavado, que em escala de cinza
  /// vira um cinza claro e continua separando as seções.
  static const PdfColor _accentBand = PdfColor.fromInt(0xFFF7E7E8);

  static const PdfColor _white = PdfColor.fromInt(0xFFFFFFFF);

  // ---------------------------------------------------------------- medidas

  /// Moldura do retrato, na mesma proporção 4:3 do painel de personagens
  /// (`PortraitBanner`). Antes era um quadrado, e num retrato vertical o
  /// quadrado só cabia mostrando o corpo inteiro em miniatura.
  @visibleForTesting
  static const double portraitWidth = 168;

  @visibleForTesting
  static const double portraitHeight = portraitWidth / (4 / 3);

  /// Caixa de valor: larga o bastante para o rótulo em duas linhas e alta o
  /// bastante para escrever à mão em cima do valor impresso.
  @visibleForTesting
  static const double boxWidth = 82;

  @visibleForTesting
  static const double boxHeight = 46;

  /// Margens da página. Seguras para impressora doméstica, que costuma perder
  /// os 10 mm da borda.
  @visibleForTesting
  static const pw.EdgeInsets pageMargin = pw.EdgeInsets.fromLTRB(
    30,
    26,
    30,
    24,
  );

  /// Nome sugerido do arquivo, já sem caracteres que atrapalham no sistema.
  static String fileName(Character character) {
    final slug = character.name
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^A-Za-zÀ-ÿ0-9_-]'), '');

    return 'ficha-${slug.isEmpty ? 'personagem' : slug}.pdf';
  }

  /// Monta o documento e devolve os bytes.
  ///
  /// [compress] existe para a verificação de layout: com o fluxo de conteúdo
  /// comprimido não há como inspecionar onde cada texto e cada caixa foram
  /// desenhados. Em produção fica ligado, senão o arquivo triplica de tamanho.
  static Future<Uint8List> build(
    CharacterSheetPdfData data, {
    bool compress = true,
  }) async {
    final character = data.character;
    final titleFont = _loadTitleFont(data.titleFontBytes);

    final document = pw.Document(
      title: 'Ficha de ${character.name}',
      author: AppBranding.appName,
      creator: AppBranding.appName,
      subject: 'Ficha de personagem de D&D 5e',
      compress: compress,
    );

    // As imagens são criadas UMA vez e reusadas em todas as páginas. Criar
    // dentro do `buildBackground`, que roda por página, embutiria os mesmos
    // bytes várias vezes e engordaria o arquivo à toa.
    final mark = _image(data.iconBytes) ?? _image(data.logoBytes);
    final portrait = _image(data.portraitBytes);

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pageMargin,
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
            italic: pw.Font.helveticaOblique(),
          ).copyWith(
            defaultTextStyle: pw.TextStyle(fontSize: 8.5, color: _ink),
          ),
          // A marca d'água vive no fundo da página, então repete em todas sem
          // interferir na paginação do conteúdo.
          buildBackground: (context) => _watermark(mark),
        ),
        // Nada de `pw.Checkbox` no cabeçalho ou no rodapé: eles são construídos
        // uma vez por página, e um campo de formulário com o mesmo nome
        // repetido faz o leitor tratar as caixas como uma só.
        header:
            (context) =>
                context.pageNumber == 1
                    ? pw.SizedBox()
                    : _runningHeader(data, titleFont, mark, context),
        footer: (context) => _footer(mark, context),
        build: (context) => _body(data, titleFont, portrait, mark),
      ),
    );

    return Uint8List.fromList(await document.save());
  }

  static pw.MemoryImage? _image(Uint8List? bytes) {
    if (bytes == null) return null;

    try {
      return pw.MemoryImage(bytes);
    } catch (error) {
      // Arte corrompida não pode impedir a exportação: a ficha sai sem ela.
      debugPrint('Imagem não pôde ser usada no PDF: $error');
      return null;
    }
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

  // ------------------------------------------------------ moldura do documento

  /// Marca d'água: só o símbolo, centralizado e bem apagado.
  ///
  /// 4% é o ponto em que ela aparece no papel sem competir com o texto por
  /// cima. Acima disso o número da CA impresso em cima do dragão fica difícil
  /// de ler, inclusive em escala de cinza, que é como a maioria imprime.
  static pw.Widget _watermark(pw.MemoryImage? mark) {
    if (mark == null) return pw.SizedBox();

    return pw.Center(
      child: pw.Opacity(opacity: 0.04, child: pw.Image(mark, width: 300)),
    );
  }

  /// Cabeçalho das páginas seguintes: selo, nome e nível.
  ///
  /// Repetir o nome importa numa ficha de várias páginas que circula na mesa: a
  /// folha 3 solta precisa dizer de quem é.
  static pw.Widget _runningHeader(
    CharacterSheetPdfData data,
    pw.Font? titleFont,
    pw.MemoryImage? mark,
    pw.Context context,
  ) {
    final character = data.character;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _accent, width: 0.8)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (mark != null) ...[
            pw.Image(mark, width: 13, height: 13),
            pw.SizedBox(width: 6),
          ],
          pw.Expanded(
            child: pw.Text(
              _safe(character.name),
              style: pw.TextStyle(
                font: titleFont,
                fontSize: 9,
                fontWeight: titleFont == null ? pw.FontWeight.bold : null,
                color: _ink,
              ),
            ),
          ),
          pw.Text(
            _safe(
              '${_classLine(data, short: true)} | Nível ${character.totalLevel}',
            ),
            style: pw.TextStyle(fontSize: 7.5, color: _muted),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.MemoryImage? mark, pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _rule, width: 0.5)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (mark != null) ...[
            pw.Opacity(
              opacity: 0.55,
              child: pw.Image(mark, width: 9, height: 9),
            ),
            pw.SizedBox(width: 4),
          ],
          pw.Text(
            AppBranding.appName,
            style: pw.TextStyle(fontSize: 7, color: _muted, letterSpacing: 0.5),
          ),
          pw.Expanded(child: pw.SizedBox()),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 7, color: _muted),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------- corpo

  /// A ordem das seções.
  ///
  /// O que é consultado a cada turno vem primeiro: identidade, números de
  /// combate, atributos, salvaguardas, perícias, ataques. Depois o que é
  /// consultado de vez em quando: magias, características, equipamento. As
  /// condições ficam no fim porque são preenchidas na mesa, e é bom que caiam
  /// numa folha que dá para deixar de lado.
  ///
  /// "Ações em combate" NÃO entra aqui de propósito: é um painel de apoio da
  /// tela, que muda a cada turno e ocuparia páginas sem ajudar quem já está com
  /// a ficha na mão. A funcionalidade continua no app.
  static List<pw.Widget> _body(
    CharacterSheetPdfData data,
    pw.Font? titleFont,
    pw.MemoryImage? portrait,
    pw.MemoryImage? mark,
  ) {
    final character = data.character;

    return [
      _masthead(data, titleFont, portrait, mark),
      ..._section('Combate', titleFont, _combat(data)),
      ..._section('Atributos e salvaguardas', titleFont, _abilities(character)),
      ..._section('Perícias', titleFont, _skills(character)),
      ..._section('Ataques e armas', titleFont, _attacks(data)),
      ..._section('Conjuração', titleFont, _spellcasting(data)),
      ..._section('Magias', titleFont, _spellList(data)),
      ..._section(
        'Características e proficiências',
        titleFont,
        _features(data),
      ),
      ..._section('Equipamento', titleFont, _equipment(data)),
      ..._section('Condições', titleFont, _conditions(data)),
      ..._section('Anotações', titleFont, _notes(character)),
    ];
  }

  // ----------------------------------------------------------------- cabeçalho

  /// Cabeçalho da primeira página: marca, nome, classe e identificação.
  static pw.Widget _masthead(
    CharacterSheetPdfData data,
    pw.Font? titleFont,
    pw.MemoryImage? portrait,
    pw.MemoryImage? mark,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Faixa da marca. O ícone aparece aqui em tamanho de selo, uma vez só:
        // repeti-lo ao lado de cada seção viraria poluição.
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (mark != null) ...[
              pw.Image(mark, width: 22, height: 22),
              pw.SizedBox(width: 7),
            ],
            pw.Text(
              AppBranding.appName.toUpperCase(),
              style: pw.TextStyle(
                font: titleFont,
                fontSize: 10,
                fontWeight: titleFont == null ? pw.FontWeight.bold : null,
                color: _accent,
                letterSpacing: 2,
              ),
            ),
            pw.Expanded(child: pw.SizedBox()),
            pw.Text(
              'FICHA DE PERSONAGEM - D&D 5E',
              style: pw.TextStyle(fontSize: 7, color: _muted, letterSpacing: 1),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Container(height: 1.6, color: _accent),
        pw.SizedBox(height: 9),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _portraitFrame(portrait),
            pw.SizedBox(width: 11),
            pw.Expanded(child: _identity(data, titleFont)),
          ],
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  /// Retrato enquadrado igual ao painel de personagens.
  ///
  /// O app resolve isso em `_PortraitFrame`: `cover` para preencher a moldura
  /// sem distorcer, e âncora no topo. As duas coisas juntas importam — `cover`
  /// centralizado corta a faixa do meio de uma imagem vertical, e é justamente
  /// a cabeça que se perde. Retrato de personagem é quase sempre vertical, e o
  /// rosto é o que identifica.
  static pw.Widget _portraitFrame(pw.MemoryImage? image) {
    return pw.Container(
      width: portraitWidth,
      height: portraitHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _boxRule, width: 0.8),
        color: image == null ? _band : null,
        image:
            image == null
                ? null
                : pw.DecorationImage(
                  image: image,
                  fit: pw.BoxFit.cover,
                  // O recorte salvo já tem a proporção 4:3 desta moldura.
                  // `cover` preserva também personagens antigos sem distorção.
                  alignment: pw.Alignment.center,
                ),
      ),
      child:
          image == null
              ? pw.Center(
                child: pw.Text(
                  'SEM IMAGEM',
                  style: pw.TextStyle(fontSize: 7, color: _muted),
                ),
              )
              : null,
    );
  }

  static pw.Widget _identity(CharacterSheetPdfData data, pw.Font? titleFont) {
    final character = data.character;
    final subclassLine = character.classLevels
        .map((item) => _subclassName(data, item.subclassId))
        .whereType<String>()
        .join(' | ');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          _safe(character.name),
          style: pw.TextStyle(
            font: titleFont,
            fontSize: 21,
            fontWeight: titleFont == null ? pw.FontWeight.bold : null,
            color: _ink,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          _safe('${_classLine(data)}  -  Nível ${character.totalLevel}'),
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _accent,
          ),
        ),
        if (subclassLine.isNotEmpty) ...[
          pw.SizedBox(height: 1),
          pw.Text(
            _safe(subclassLine),
            style: pw.TextStyle(fontSize: 8.5, color: _muted),
          ),
        ],
        pw.SizedBox(height: 7),
        // Campos de identificação. Alinhamento e experiência não existem no
        // modelo do app, então saem como linha em branco para preencher à mão —
        // melhor que omitir um campo que a ficha de mesa usa.
        pw.Row(
          children: [
            pw.Expanded(child: _field('Raça', _raceName(data))),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _field('Antecedente', _backgroundName(data))),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _field('Jogador', character.playerName)),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          children: [
            // Sem alinhamento a linha sai em branco para preencher à mão, em vez
            // de imprimir "Não definido" — na ficha de papel a linha vazia já
            // diz isso.
            pw.Expanded(
              child: _field('Alinhamento', character.alignment?.label),
            ),
            pw.SizedBox(width: 8),
            // Experiência não existe no modelo do app: sai como linha em branco.
            pw.Expanded(child: _field('Experiência', null)),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _field('Inspiração', character.inspiration ? 'Sim' : null),
            ),
          ],
        ),
      ],
    );
  }

  /// Rótulo pequeno com valor sobre linha.
  ///
  /// Valor nulo deixa a linha vazia de propósito: é um campo que o jogador
  /// preenche na mesa, e a linha diz onde escrever.
  static pw.Widget _field(String label, String? value) {
    final text = value?.trim() ?? '';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          _safe(label.toUpperCase()),
          style: pw.TextStyle(fontSize: 6, color: _muted, letterSpacing: 0.5),
        ),
        pw.SizedBox(height: 1),
        pw.Container(
          height: 12,
          alignment: pw.Alignment.bottomLeft,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.6)),
          ),
          child: pw.Text(
            _safe(text),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
            style: pw.TextStyle(fontSize: 8.5, color: _ink),
          ),
        ),
      ],
    );
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

    // Mesmo serviço da ficha: a Destreza entra sempre e as regras especiais vêm
    // do compêndio. A caixa mostra o total final; a composição fica na linha de
    // baixo, que é onde há espaço para explicar.
    final initiative = InitiativeCalculator.calculate(
      character: character,
      classFeatures: data.classFeatures,
      subclasses: data.subclasses,
      feats: data.feats,
      races: data.races,
    );

    final hitDiceLabel =
        pool.isEmpty ? '-' : pool.map((group) => group.label).join(' + ');

    return [
      // Primeira fila: os números que decidem o turno.
      _boxRow([
        _valueBox(
          label: 'Classe de armadura',
          value: '${data.effectiveArmorClass}',
        ),
        _valueBox(
          label: 'Iniciativa',
          value: initiative.formattedTotal,
          note: initiative.hasAdvantage ? 'com vantagem' : null,
        ),
        _valueBox(
          label: 'Deslocamento',
          value: formatMeters(stats.speedInMeters),
        ),
        _valueBox(
          label: 'Bônus de proficiência',
          value: _signed(character.proficiencyBonus),
        ),
        _valueBox(
          label: 'Percepção passiva',
          value: '${SkillCalculator.passivePerception(character)}',
        ),
        _valueBox(
          label: 'Inspiração',
          value: character.inspiration ? 'Sim' : '',
          fillable: !character.inspiration,
        ),
      ]),
      pw.SizedBox(height: 6),
      // Segunda fila: pontos de vida e o que se gasta em combate.
      _boxRow([
        _valueBox(label: 'PV máximos', value: '${hp.maximum}'),
        _valueBox(label: 'PV atuais', value: '${hp.current}', writable: true),
        _valueBox(
          label: 'PV temporários',
          value: hp.temporary > 0 ? '${hp.temporary}' : '',
          fillable: hp.temporary == 0,
          writable: true,
        ),
        _valueBox(
          label: 'Dados de vida',
          value: hitDiceLabel,
          note:
              pool.isEmpty
                  ? null
                  : '${totalHitDice - character.hitDiceUsed} livres',
          small: true,
        ),
        _valueBox(
          label: 'Investigação passiva',
          value: '${SkillCalculator.passiveInvestigation(character)}',
        ),
        _valueBox(
          label: 'Intuição passiva',
          value: '${SkillCalculator.passiveInsight(character)}',
        ),
      ]),
      pw.SizedBox(height: 6),
      _deathSavesBox(data),
      // A composição impressa deixa o jogador conferir a conta na mesa, sem o
      // app aberto. Só aparece quando há algo além da Destreza.
      if (initiative.modifiers.length > 1) ...[
        pw.SizedBox(height: 5),
        _note('Iniciativa: ${initiative.explanation}'),
      ],
      if (initiative.hasAdvantage)
        _note(
          'Vantagem na iniciativa: ${initiative.advantageSources.join(', ')}.',
        ),
    ];
  }

  /// Testes contra a morte, com os marcadores já registrados na ficha.
  ///
  /// Sai marcado como está no app, e o resto fica vazio para continuar a
  /// contagem à mão na mesa.
  static pw.Widget _deathSavesBox(CharacterSheetPdfData data) {
    final saves = data.character.deathSaves;

    final state =
        saves.isDead
            ? 'Morto: três falhas.'
            : saves.isStable
            ? 'Estável: três sucessos.'
            : '3 sucessos estabilizam; 3 falhas matam.';

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        color: _band,
        border: pw.Border.all(color: _boxRule, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            _safe('TESTES CONTRA A MORTE'),
            style: pw.TextStyle(
              fontSize: 6.5,
              color: _muted,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Text(
            _safe('Sucessos'),
            style: pw.TextStyle(fontSize: 8, color: _ink),
          ),
          pw.SizedBox(width: 5),
          for (var i = 1; i <= DeathSaves.maxMarks; i++) ...[
            _checkBox(
              data,
              name: 'death_success_$i',
              value: i <= saves.successes,
            ),
            pw.SizedBox(width: 4),
          ],
          pw.SizedBox(width: 12),
          pw.Text(
            _safe('Falhas'),
            style: pw.TextStyle(fontSize: 8, color: _ink),
          ),
          pw.SizedBox(width: 5),
          for (var i = 1; i <= DeathSaves.maxMarks; i++) ...[
            _checkBox(
              data,
              name: 'death_failure_$i',
              value: i <= saves.failures,
            ),
            pw.SizedBox(width: 4),
          ],
          pw.Expanded(child: pw.SizedBox()),
          pw.Text(
            _safe(state),
            style: pw.TextStyle(
              fontSize: 6.5,
              color: saves.isResolved ? _accent : _muted,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- atributos

  static List<pw.Widget> _abilities(Character character) {
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
      pw.Row(
        children: [
          for (final ability in Ability.values) ...[
            pw.Expanded(
              child: _abilityBlock(
                ability: ability,
                score: character.abilityScores.valueFor(ability),
                saveBonus:
                    character.abilityScores.valueFor(ability).abilityModifier +
                    (proficientIn(ability) ? character.proficiencyBonus : 0),
                saveProficient: proficientIn(ability),
              ),
            ),
            if (ability != Ability.values.last) pw.SizedBox(width: 5),
          ],
        ],
      ),
      pw.SizedBox(height: 4),
      _note(
        'A salvaguarda marcada com (P) tem o bônus de proficiência somado.',
      ),
    ];
  }

  /// Bloco de atributo: valor, modificador e a salvaguarda logo abaixo.
  ///
  /// As duas coisas no mesmo bloco porque em mesa a pergunta vem junto — "rola
  /// um teste de Destreza" e "rola uma salvaguarda de Destreza" saem do mesmo
  /// lugar da ficha.
  static pw.Widget _abilityBlock({
    required Ability ability,
    required int score,
    required int saveBonus,
    required bool saveProficient,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _white,
        border: pw.Border.all(color: _boxRule, width: 0.8),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            color: _band,
            child: pw.Text(
              _safe(ability.abbreviation.toUpperCase()),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 7,
                color: _muted,
                letterSpacing: 0.6,
              ),
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '$score',
            style: pw.TextStyle(
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
              color: _ink,
            ),
          ),
          pw.Text(
            _signed(score.abilityModifier),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _accent,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: _rule, width: 0.6)),
            ),
            child: pw.Text(
              _safe(
                'Salv. ${_signed(saveBonus)}${saveProficient ? ' (P)' : ''}',
              ),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 7,
                color: saveProficient ? _ink : _muted,
                fontWeight: saveProficient ? pw.FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
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
      // `Table` é splittable, então uma lista longa de perícias quebra entre
      // páginas em vez de estourar a caixa.
      pw.Table(
        border: pw.TableBorder.all(color: _rule, width: 0.6),
        // Largura fixa por coluna é obrigatória aqui: as células usam
        // `Expanded`, e a largura intrínseca padrão da tabela chega sem limite,
        // o que faz o layout do pdf lançar em vez de desenhar.
        columnWidths: const {0: pw.FlexColumnWidth(), 1: pw.FlexColumnWidth()},
        children: rows,
      ),
      pw.SizedBox(height: 4),
      _note('(P) proficiente  -  (E) especialista  -  (½) metade'),
    ];
  }

  static pw.Widget _skillCell(Character character, Skill skill) {
    final level = character.skillProficiencies.levelFor(skill);
    final tag = level.shortTag;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: pw.Row(
        children: [
          pw.Container(
            width: 8,
            height: 8,
            margin: const pw.EdgeInsets.only(right: 5),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              // Círculo cheio para proficiente: é o marcador que se lê de
              // longe, e continua legível em escala de cinza.
              color: level.isProficientOrBetter ? _accent : _white,
              border: pw.Border.all(color: _boxRule, width: 0.6),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              _safe('${skill.label} (${skill.abbreviation})'),
              maxLines: 1,
              style: pw.TextStyle(
                fontSize: 8,
                color: level.isProficientOrBetter ? _ink : _muted,
                fontWeight:
                    level.isProficientOrBetter ? pw.FontWeight.bold : null,
              ),
            ),
          ),
          if (tag != null)
            pw.Text(
              _safe(' ($tag) '),
              style: pw.TextStyle(fontSize: 7, color: _accent),
            ),
          pw.Text(
            _signed(SkillCalculator.skillBonus(character, skill)),
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------- ataques

  static List<pw.Widget> _attacks(CharacterSheetPdfData data) {
    final character = data.character;

    if (character.weapons.isEmpty) {
      return [_plain('Nenhuma arma cadastrada.')];
    }

    final catalog = {for (final entry in data.weapons) entry.id: entry};

    // Mesma conta da ficha: só o item mágico que declarou efeito de arma soma
    // aqui, e só se estiver equipado (e sintonizado, quando exige).
    var itemAttack = 0;
    var itemDamage = 0;
    for (final item in character.magicItems) {
      itemAttack += item.weaponAttackBonus;
      itemDamage += item.weaponDamageBonus;
    }

    final attacks = <WeaponAttack>[];
    final unknown = <String>[];

    for (final weapon in character.weapons) {
      final entry = catalog[weapon.weaponId];

      if (entry == null) {
        // Arma cujo id saiu do compêndio não é escondida em silêncio: some da
        // tabela, mas o nome fica registrado abaixo dela.
        unknown.add(
          weapon.name?.trim().isNotEmpty == true
              ? weapon.name!.trim()
              : weapon.weaponId,
        );
        continue;
      }

      attacks.add(
        WeaponAttackCalculator.calculate(
          character: character,
          weapon: weapon,
          entry: entry,
          classes: data.classes,
          magicItemAttackBonus: itemAttack,
          magicItemDamageBonus: itemDamage,
        ),
      );
    }

    return [
      if (attacks.isNotEmpty)
        pw.Table(
          border: pw.TableBorder.all(color: _rule, width: 0.6),
          columnWidths: const {
            0: pw.FlexColumnWidth(3.1),
            1: pw.FixedColumnWidth(40),
            2: pw.FlexColumnWidth(2.1),
            3: pw.FlexColumnWidth(1.5),
            4: pw.FlexColumnWidth(3),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _band),
              children: [
                _headCell('Arma'),
                _headCell('Ataque', center: true),
                _headCell('Dano'),
                _headCell('Alcance'),
                _headCell('Propriedades'),
              ],
            ),
            for (final attack in attacks)
              pw.TableRow(
                children: [
                  _bodyCell(
                    attack.weapon.magicBonus == 0
                        ? attack.name
                        : '${attack.name} (mágica '
                            '${_signed(attack.weapon.magicBonus)})',
                    bold: true,
                  ),
                  _bodyCell(attack.formattedAttack, center: true, bold: true),
                  _bodyCell(attack.damageExplanation ?? 'sem dano'),
                  _bodyCell(_rangeLabel(attack.entry)),
                  _bodyCell(attack.entry.propertiesLabel),
                ],
              ),
          ],
        ),
      if (attacks.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        // A composição de cada ataque em linha própria: a tabela mostra o
        // número, e aqui fica de onde ele saiu.
        for (final attack in attacks)
          _note(
            '${attack.name}: ${attack.attackExplanation}'
            '${attack.isProficient ? '' : ' (sem proficiência)'}',
          ),
      ],
      if (itemAttack != 0 || itemDamage != 0)
        _note(
          'Itens mágicos equipados somam ${_signed(itemAttack)} no ataque e '
          '${_signed(itemDamage)} no dano de todas as armas.',
        ),
      if (unknown.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        _warning(
          'Sem dados no compêndio para: ${unknown.join(', ')}. '
          'Confira a arma no app.',
        ),
      ],
    ];
  }

  static String _rangeLabel(WeaponEntry entry) {
    final range = entry.range ?? entry.thrownRange;
    if (range == null) return entry.isMelee ? 'Corpo a corpo' : '-';

    return '${formatMeters(range.normal)}/${formatMeters(range.long)}';
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

    // Mesmo serviço da ficha: só entra o bônus que o item declarou em campo
    // próprio, nunca um `+1` deduzido do nome — e só com o item em uso.
    final itemBonus = SpellcastingService.itemBonuses(character.magicItems);

    for (final classLevel in character.classLevels) {
      final entry = _classEntry(data, classLevel.classId);
      if (entry == null || !entry.isSpellcaster) continue;
      if (classLevel.level < entry.spellcastingStartLevel) continue;

      final ability = Ability.fromName(entry.spellcastingAbility);
      if (ability == null) continue;

      final dc = SpellcastingService.spellSaveDc(
        proficiencyBonus: character.proficiencyBonus,
        castingAbility: ability,
        scores: character.abilityScores,
        itemBonus: itemBonus.saveDc,
      );
      final attack = SpellcastingService.spellAttackBonus(
        proficiencyBonus: character.proficiencyBonus,
        castingAbility: ability,
        scores: character.abilityScores,
        itemBonus: itemBonus.attack,
      );

      widgets
        ..add(_subTitle(entry.name))
        ..add(pw.SizedBox(height: 3))
        ..add(
          _boxRow([
            _valueBox(label: 'Atributo de conjuração', value: ability.label),
            _valueBox(label: 'CD das magias', value: '$dc'),
            _valueBox(label: 'Ataque mágico', value: _signed(attack)),
          ]),
        )
        ..add(pw.SizedBox(height: 6));
    }

    if (itemBonus.sources.isNotEmpty) {
      widgets.add(
        _note(
          'Inclui bônus de item: ${itemBonus.sources.join(', ')} '
          '(${_signed(itemBonus.attack)} no ataque, '
          '${_signed(itemBonus.saveDc)} na CD).',
        ),
      );
    }

    final standard = summary.standardSlots;
    if (standard != null) {
      widgets
        ..add(pw.SizedBox(height: 2))
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
        ..add(_note(summary.explanation!.trim()));
    }

    return widgets;
  }

  /// Espaços por círculo, com espaço para marcar o que foi gasto.
  static pw.Widget _slotRow(String title, SpellSlotProgressionEntry row) {
    final slots = SpellSlotCalculator.slotsByLevel(row);

    if (slots.isEmpty) return _plain('$title: nenhum.');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          _safe(title.toUpperCase()),
          style: pw.TextStyle(fontSize: 6.5, color: _muted, letterSpacing: 0.5),
        ),
        pw.SizedBox(height: 3),
        pw.Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            for (final entry in slots.entries)
              pw.Container(
                width: 62,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: _white,
                  border: pw.Border.all(color: _boxRule, width: 0.7),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      _safe('${entry.key}º círculo'),
                      style: pw.TextStyle(fontSize: 6.5, color: _muted),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${entry.value}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
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

    // Agrupa por círculo, que é como a ficha de mesa organiza: na hora de
    // conjurar a pergunta é "o que eu tenho de 2º círculo?".
    final grouped = <int, List<CharacterSpell>>{};
    for (final spell in character.spells) {
      final level = byId[spell.spellId]?.level ?? 0;
      grouped.putIfAbsent(level, () => []).add(spell);
    }

    final levels = grouped.keys.toList()..sort();
    final widgets = <pw.Widget>[];

    for (final level in levels) {
      final list =
          grouped[level]!..sort((a, b) {
            final nameA = byId[a.spellId]?.namePt ?? '';
            final nameB = byId[b.spellId]?.namePt ?? '';
            return nameA.compareTo(nameB);
          });

      widgets
        ..add(
          _subTitle(
            level == 0
                ? 'Truques (${list.length})'
                : '$levelº círculo (${list.length})',
          ),
        )
        // Lista plana em vez de `Column`: cada linha é um widget do
        // `MultiPage`, então uma lista longa quebra entre páginas sem
        // sobrepor nada.
        ..addAll([
          for (final spell in list)
            _spellLine(data, spell, byId[spell.spellId]),
        ])
        ..add(pw.SizedBox(height: 5));
    }

    return widgets;
  }

  static pw.Widget _spellLine(
    CharacterSheetPdfData data,
    CharacterSpell spell,
    SpellEntry? entry,
  ) {
    final origin = _sourceLabels[spell.sourceType] ?? 'Outra origem';
    final originName = spell.sourceName.trim();

    final tags = <String>[
      if (spell.isPrepared) 'preparada',
      if (spell.isAlwaysAvailable) 'sempre disponível',
      if (entry?.concentration == true) 'concentração',
      if (entry?.ritual == true) 'ritual',
    ];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Caixa de preparada, para marcar em mesa quando a preparação muda.
          _checkBox(
            data,
            name: 'spell_${spell.spellId}_${spell.sourceType}',
            value: spell.isPrepared,
            size: 7,
          ),
          pw.SizedBox(width: 5),
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              _safe(entry?.namePt ?? 'Magia #${spell.spellId}'),
              style: pw.TextStyle(fontSize: 8.5, color: _ink),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              _safe(originName.isEmpty ? origin : '$origin: $originName'),
              style: pw.TextStyle(fontSize: 7, color: _muted),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              _safe(tags.join(', ')),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 7, color: _accent),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- características

  static List<pw.Widget> _features(CharacterSheetPdfData data) {
    final character = data.character;
    final widgets = <pw.Widget>[];

    // Raça primeiro: é o que o jogador consulta para saber o que tem "de
    // nascença", e sub-raça herda os traços da raça base.
    final race = _raceEntry(data);
    if (race != null) {
      final parent =
          race.hasParentRace
              ? _firstWhereOrNull(
                data.races,
                (item) => item.id == race.parentRaceId,
              )
              : null;

      final traits = <String>[...?parent?.traits, ...race.traits];
      final languages = <String>[...?parent?.languages, ...race.languages];

      widgets.add(_subTitle(race.name));

      final line = [
        if (race.size != null) 'Tamanho: ${race.size}',
        if ((race.speed ?? parent?.speed) != null)
          'Deslocamento: ${formatMeters(race.speed ?? parent!.speed!)}',
        if ((race.darkvision ?? parent?.darkvision) != null)
          'Visão no escuro: ${race.darkvision ?? parent!.darkvision} m',
      ];
      if (line.isNotEmpty) widgets.add(_plain(line.join('  -  ')));

      widgets.addAll([for (final trait in traits) _bullet(trait)]);

      if (languages.isNotEmpty) {
        widgets
          ..add(pw.SizedBox(height: 3))
          ..add(_labelled('Idiomas', languages.join(', ')));
      }

      widgets.add(pw.SizedBox(height: 5));
    }

    // Antecedente.
    widgets.addAll(_background(data));

    // Classe e subclasse.
    for (final classLevel in character.classLevels) {
      final features =
          data.classFeatures
              .where(
                (entry) =>
                    entry.classId == classLevel.classId &&
                    entry.level <= classLevel.level,
              )
              .toList()
            ..sort((a, b) => a.level.compareTo(b.level));

      widgets.add(
        _subTitle(
          '${_className(data, classLevel.classId)} - nível ${classLevel.level}',
        ),
      );

      if (features.isEmpty) {
        widgets.add(_plain('Nenhuma característica cadastrada.'));
      } else {
        for (final entry in features) {
          for (final feature in entry.features) {
            // Quando não há texto cadastrado, sai só o nome em vez de
            // dois-pontos vazios.
            widgets.add(
              _bullet(
                feature.hasDescription
                    ? '${feature.name} (nível ${entry.level}): '
                        '${feature.description}'
                    : '${feature.name} (nível ${entry.level})',
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
              _bullet(
                '${feature.name} (nível ${feature.level}): '
                '${feature.description}',
              ),
            );
          }
        }
      }

      widgets.add(pw.SizedBox(height: 5));
    }

    // Talentos.
    if (character.feats.isNotEmpty) {
      widgets.add(_subTitle('Talentos'));

      final byId = {for (final entry in data.feats) entry.id: entry};

      for (final taken in character.feats) {
        final entry = byId[taken.featId];
        final name = entry?.name ?? taken.featId;
        final chosen = taken.chosenAbility;

        widgets.add(_bullet(chosen == null ? name : '$name (${chosen.label})'));

        final description = entry?.description?.trim();
        if (description != null && description.isNotEmpty) {
          widgets.add(_indented(description));
        }
      }

      widgets.add(pw.SizedBox(height: 5));
    }

    // Proficiências, reunidas de onde o app realmente sabe.
    widgets.add(_subTitle('Proficiências'));
    widgets.addAll(_proficiencies(data));

    return widgets;
  }

  static List<pw.Widget> _proficiencies(CharacterSheetPdfData data) {
    final character = data.character;

    final saves = <String>[
      for (final ability in Ability.values)
        if (_saveProficient(character, ability)) ability.label,
    ];

    final skills = <String>[
      for (final skill in Skill.sortedByLabel)
        if (character.skillProficiencies.levelFor(skill).isProficientOrBetter)
          skill.label,
    ];

    final expertise = <String>[
      for (final skill in Skill.sortedByLabel)
        if (character.skillProficiencies.levelFor(skill) ==
            ProficiencyLevel.expertise)
          skill.label,
    ];

    final weapons = <String>[];
    for (final classLevel in character.classLevels) {
      final entry = _classEntry(data, classLevel.classId);
      final proficiencies = entry?.weaponProficiencies;
      if (proficiencies == null || proficiencies.isEmpty) continue;

      for (final category in proficiencies.categories) {
        final label = 'Armas ${category.label.toLowerCase()}';
        if (!weapons.contains(label)) weapons.add(label);
      }
      for (final id in proficiencies.weaponIds) {
        final weapon = _firstWhereOrNull(data.weapons, (item) => item.id == id);
        final label = weapon?.name ?? id;
        if (!weapons.contains(label)) weapons.add(label);
      }
    }

    return [
      _labelled('Salvaguardas', saves.isEmpty ? 'Nenhuma' : saves.join(', ')),
      _labelled('Perícias', skills.isEmpty ? 'Nenhuma' : skills.join(', ')),
      if (expertise.isNotEmpty)
        _labelled('Especialista em', expertise.join(', ')),
      if (weapons.isNotEmpty) _labelled('Armas', weapons.join(', ')),
    ];
  }

  static bool _saveProficient(Character character, Ability ability) {
    final saves = character.savingThrowProficiencies;

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

  static List<pw.Widget> _background(CharacterSheetPdfData data) {
    final character = data.character;

    if (character.backgroundId == BackgroundEntry.customId) {
      final custom = character.customBackground;
      return [
        _subTitle(custom.displayName),
        if (custom.skills.isNotEmpty)
          _labelled('Perícias', custom.skills.map((s) => s.label).join(', ')),
        if (custom.features.trim().isNotEmpty) _plain(custom.features.trim()),
        pw.SizedBox(height: 5),
      ];
    }

    final entry = _firstWhereOrNull(
      data.backgrounds,
      (item) => item.id == character.backgroundId,
    );

    if (entry == null) {
      return [
        _subTitle('Antecedente'),
        _plain('Nenhum antecedente escolhido.'),
        pw.SizedBox(height: 5),
      ];
    }

    return [
      _subTitle(entry.name),
      if (entry.skills.isNotEmpty)
        _labelled('Perícias', entry.skills.map((s) => s.label).join(', ')),
      if (entry.featureName != null)
        _bullet('${entry.featureName}: ${entry.featureDescription ?? ''}'),
      if (entry.description != null) _plain(entry.description!),
      pw.SizedBox(height: 5),
    ];
  }

  // --------------------------------------------------------------- equipamento

  static List<pw.Widget> _equipment(CharacterSheetPdfData data) {
    final character = data.character;
    final widgets = <pw.Widget>[];

    // Moedas primeiro: é o que muda com mais frequência.
    final currency = character.currency;
    widgets
      ..add(_subTitle('Moedas'))
      ..add(pw.SizedBox(height: 3))
      ..add(
        _boxRow([
          _valueBox(label: 'PL', value: '${currency.platinum}', writable: true),
          _valueBox(label: 'PO', value: '${currency.gold}', writable: true),
          _valueBox(label: 'PE', value: '${currency.electrum}', writable: true),
          _valueBox(label: 'PP', value: '${currency.silver}', writable: true),
          _valueBox(label: 'PC', value: '${currency.copper}', writable: true),
          _valueBox(
            label: 'Total em ouro',
            value: currency.totalInGold.toStringAsFixed(2),
            small: true,
          ),
        ]),
      )
      ..add(pw.SizedBox(height: 8))
      ..add(_subTitle('Itens mágicos'));

    if (character.magicItems.isEmpty) {
      widgets.add(_plain('Nenhum item mágico.'));
      return widgets;
    }

    final spellsById = {for (final spell in data.spells) spell.id: spell};

    for (final item in character.magicItems) {
      widgets.addAll(_magicItem(item, spellsById));
    }

    // Quantos itens estão sintonizados, que é o limite que a mesa controla.
    final attuned =
        character.magicItems
            .where((item) => item.requiresAttunement && item.isAttuned)
            .length;
    if (attuned > 0) {
      widgets
        ..add(pw.SizedBox(height: 2))
        ..add(_note('Itens sintonizados: $attuned.'));
    }

    return widgets;
  }

  static List<pw.Widget> _magicItem(
    CharacterMagicItem item,
    Map<int, SpellEntry> spellsById,
  ) {
    final states = <String>[
      item.isEquipped ? 'equipado' : 'guardado',
      if (item.requiresAttunement)
        item.isAttuned ? 'sintonizado' : 'sem sintonia',
    ];

    final bonus = item.describeDeclaredBonuses();

    return [
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 1),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                _safe(item.name),
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink,
                ),
              ),
            ),
            pw.Text(
              _safe(states.join(' - ')),
              style: pw.TextStyle(fontSize: 7, color: _muted),
            ),
            if (item.maxCharges != null) ...[
              pw.SizedBox(width: 6),
              pw.Text(
                _safe('cargas ${item.charges ?? 0}/${item.maxCharges}'),
                style: pw.TextStyle(fontSize: 7, color: _accent),
              ),
            ],
          ],
        ),
      ),
      // Bônus declarado e onde ele vale. Quando o item não está em uso, a linha
      // diz isso: sem o aviso o jogador somaria um bônus que a ficha não usou.
      if (bonus.isNotEmpty)
        _indented(
          item.isActive
              ? 'Bônus: $bonus'
              : 'Bônus: $bonus (não está somando: '
                  '${item.isEquipped ? 'exige sintonia' : 'não equipado'})',
        ),
      if (item.needsBonusReview)
        _indented(
          'Bônus antigo, fora das opções +1 a +3. Revise o item no app.',
        ),
      if (item.saveDc != null) _indented('CD fixa do item: ${item.saveDc}'),
      if (item.attackBonus != null)
        _indented('Ataque fixo do item: ${_signed(item.attackBonus!)}'),
      if (item.description.trim().isNotEmpty)
        _indented(item.description.trim()),
      if (item.spells.isNotEmpty)
        _indented(
          'Magias: ${item.spells.map((s) => spellsById[s.spellId]?.namePt ?? '#${s.spellId}').join(', ')}',
        ),
      if (item.rechargeRule?.trim().isNotEmpty == true)
        _indented('Recarga: ${item.rechargeRule!.trim()}'),
      pw.SizedBox(height: 4),
    ];
  }

  // ----------------------------------------------------------------- condições

  /// Condições marcáveis, exaustão e o que está ativo agora.
  ///
  /// A lista é a do PHB 2014, que é a edição do resto do projeto (o Alerta soma
  /// +5 e a tabela de exaustão tem seis degraus). Exaustão fica fora da lista de
  /// caixas porque tem níveis, e não ligado/desligado.
  static List<pw.Widget> _conditions(CharacterSheetPdfData data) {
    final character = data.character;
    final marked = character.conditions;

    final effects = ActiveEffects.from(
      conditions: marked,
      exhaustion: character.exhaustion,
    );

    return [
      _note(
        'Marque o que está afetando o personagem. Lista do Livro do Jogador '
        '(5e, 2014).',
      ),
      pw.SizedBox(height: 5),
      // `Wrap` é splittable, então a grade quebra entre páginas em vez de
      // estourar. Cada condição é uma caixa atômica, que nunca parte no meio.
      pw.Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          for (final condition in Condition.sortedByLabel)
            _conditionChip(data, condition, marked.contains(condition)),
        ],
      ),
      pw.SizedBox(height: 7),
      _exhaustionRow(data, character.exhaustion),
      pw.SizedBox(height: 7),
      _subTitle('Outras condições e observações'),
      // Linhas em branco: a mesa inventa efeito que a ficha não conhece, e sem
      // espaço para escrever o jogador anota na margem.
      for (var i = 0; i < 3; i++) _blankLine(),
      if (effects.isNotEmpty) ...[
        pw.SizedBox(height: 7),
        _subTitle('Efeitos ativos ao exportar'),
        for (final effect in effects) ...[
          _bullet(
            effect.isImplied
                ? '${effect.source} (por ${effect.impliedBy})'
                : effect.source,
          ),
          for (final line in effect.effects) _indented(line),
        ],
      ],
    ];
  }

  static pw.Widget _conditionChip(
    CharacterSheetPdfData data,
    Condition condition,
    bool marked,
  ) {
    return pw.Container(
      width: 122,
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: pw.BoxDecoration(
        color: marked ? _accentBand : _white,
        border: pw.Border.all(
          color: marked ? _accent : _boxRule,
          width: marked ? 0.9 : 0.6,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _checkBox(data, name: 'condition_${condition.id}', value: marked),
          pw.SizedBox(width: 5),
          pw.Expanded(
            child: pw.Text(
              _safe(condition.label),
              maxLines: 1,
              style: pw.TextStyle(
                fontSize: 8,
                color: _ink,
                fontWeight: marked ? pw.FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _exhaustionRow(CharacterSheetPdfData data, int level) {
    final safe = level.clamp(0, ActiveEffects.maxExhaustion);

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        color: _band,
        border: pw.Border.all(color: _boxRule, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            _safe('EXAUSTÃO'),
            style: pw.TextStyle(
              fontSize: 6.5,
              color: _muted,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(width: 10),
          for (var step = 1; step <= ActiveEffects.maxExhaustion; step++) ...[
            _checkBox(data, name: 'exhaustion_$step', value: step <= safe),
            pw.SizedBox(width: 2),
            pw.Text('$step', style: pw.TextStyle(fontSize: 7, color: _muted)),
            pw.SizedBox(width: 7),
          ],
          pw.Expanded(child: pw.SizedBox()),
          pw.Text(
            _safe('Nível atual: $safe'),
            style: pw.TextStyle(
              fontSize: 7.5,
              color: safe > 0 ? _accent : _muted,
              fontWeight: safe > 0 ? pw.FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- anotações

  static List<pw.Widget> _notes(Character character) {
    final notes = character.notes.trim();

    return [
      if (notes.isEmpty)
        _plain('Sem anotações.')
      else
        // `Text` é splittable, então uma anotação longa quebra entre páginas em
        // vez de ser cortada.
        pw.Text(
          _safe(notes),
          style: pw.TextStyle(fontSize: 8.5, color: _ink, lineSpacing: 1.4),
        ),
      pw.SizedBox(height: 6),
      for (var i = 0; i < 4; i++) _blankLine(),
    ];
  }

  // ------------------------------------------------------------------- helpers

  /// Cabeçalho de seção: faixa lavada com barra de acento à esquerda.
  ///
  /// A barra é o que dá a cara do DragonSheet sem ornamento: ela sobrevive à
  /// impressão a laser e à escala de cinza, onde filete fino e textura somem.
  static List<pw.Widget> _section(
    String title,
    pw.Font? titleFont,
    List<pw.Widget> children,
  ) {
    return [
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 9, bottom: 6),
        decoration: const pw.BoxDecoration(
          color: _accentBand,
          border: pw.Border(
            left: pw.BorderSide(color: _accent, width: 2.6),
            bottom: pw.BorderSide(color: _accent, width: 0.6),
          ),
        ),
        padding: const pw.EdgeInsets.fromLTRB(7, 3.5, 7, 3.5),
        child: pw.Text(
          _safe(title.toUpperCase()),
          style: pw.TextStyle(
            font: titleFont,
            fontSize: 10,
            fontWeight: titleFont == null ? pw.FontWeight.bold : null,
            color: _accent,
            letterSpacing: 0.8,
          ),
        ),
      ),
      ...children,
    ];
  }

  static pw.Widget _subTitle(String text, {bool small = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: small ? 2 : 4, bottom: 2),
      child: pw.Text(
        _safe(text),
        style: pw.TextStyle(
          fontSize: small ? 8 : 9,
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
        style: pw.TextStyle(fontSize: 8.5, color: _ink, lineSpacing: 1.2),
      ),
    );
  }

  /// Linha de lista, com o traço fora do bloco de texto.
  ///
  /// `Row` com `Expanded` em vez de `- ` na frente do texto: assim a segunda
  /// linha de uma descrição longa alinha embaixo da primeira, e não embaixo do
  /// traço.
  static pw.Widget _bullet(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 9,
            child: pw.Text(
              '-',
              style: pw.TextStyle(fontSize: 8.5, color: _accent),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              _safe(text),
              style: pw.TextStyle(fontSize: 8.5, color: _ink, lineSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  /// Texto recuado, para o detalhe que pertence à linha de cima.
  static pw.Widget _indented(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 9, bottom: 1.5),
      child: pw.Text(
        _safe(text),
        style: pw.TextStyle(fontSize: 7.5, color: _muted, lineSpacing: 1.2),
      ),
    );
  }

  /// `Idiomas: Comum, Élfico` — rótulo em negrito, valor em corrido.
  static pw.Widget _labelled(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: _safe('$label: '),
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
                color: _ink,
              ),
            ),
            pw.TextSpan(
              text: _safe(value),
              style: pw.TextStyle(fontSize: 8.5, color: _ink),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _note(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5),
      child: pw.Text(
        _safe(text),
        style: pw.TextStyle(fontSize: 7, color: _muted, lineSpacing: 1.2),
      ),
    );
  }

  /// Aviso do que não pôde ser impresso.
  ///
  /// Existe para nada desaparecer em silêncio: uma arma sem correspondência no
  /// compêndio é dito na ficha, em vez de a linha simplesmente não sair.
  static pw.Widget _warning(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: pw.BoxDecoration(
        color: _accentBand,
        border: pw.Border.all(color: _accent, width: 0.6),
      ),
      child: pw.Text(
        _safe(text),
        style: pw.TextStyle(fontSize: 7.5, color: _ink),
      ),
    );
  }

  /// Linha em branco para escrever à mão.
  static pw.Widget _blankLine() {
    return pw.Container(
      height: 14,
      margin: const pw.EdgeInsets.only(bottom: 2),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.6)),
      ),
    );
  }

  /// Fila de caixas de valor, com largura igual e alinhamento consistente.
  static pw.Widget _boxRow(List<pw.Widget> boxes) {
    return pw.Wrap(spacing: 6, runSpacing: 6, children: boxes);
  }

  /// Caixa de valor destacada.
  ///
  /// Tamanho fixo de propósito: é o que mantém as caixas alinhadas entre filas
  /// e dá espaço para escrever em cima do valor impresso durante o jogo.
  ///
  /// [fillable] deixa o miolo vazio, para o jogador preencher. [writable]
  /// desenha uma linha fina sob o valor, marcando o campo que muda em mesa (PV
  /// atuais, moedas) e distinguindo-o do valor calculado (CA, iniciativa).
  static pw.Widget _valueBox({
    required String label,
    required String value,
    String? note,
    bool fillable = false,
    bool writable = false,
    bool small = false,
  }) {
    return pw.Container(
      width: boxWidth,
      height: boxHeight,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      decoration: pw.BoxDecoration(
        color: _white,
        border: pw.Border.all(color: _boxRule, width: 0.8),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            _safe(label.toUpperCase()),
            textAlign: pw.TextAlign.center,
            maxLines: 2,
            style: pw.TextStyle(
              fontSize: 5.8,
              color: _muted,
              letterSpacing: 0.3,
              lineSpacing: 0.8,
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              alignment: pw.Alignment.center,
              child:
                  fillable
                      ? pw.SizedBox()
                      : pw.Text(
                        _safe(value),
                        textAlign: pw.TextAlign.center,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: small ? 9 : 15,
                          fontWeight: pw.FontWeight.bold,
                          color: _ink,
                          lineSpacing: 0.8,
                        ),
                      ),
            ),
          ),
          if (writable)
            pw.Container(height: 0.6, width: boxWidth * 0.62, color: _rule)
          else if (note != null)
            pw.Text(
              _safe(note),
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: pw.TextStyle(fontSize: 5.6, color: _accent),
            )
          else
            pw.SizedBox(height: 3),
        ],
      ),
    );
  }

  /// Caixa de marcação.
  ///
  /// Sai como campo de formulário quando o leitor suporta, e como caixa
  /// desenhada quando não. O desenho é o mesmo nos dois casos, então a ficha
  /// impressa fica idêntica — o que muda é só poder clicar.
  static pw.Widget _checkBox(
    CharacterSheetPdfData data, {
    required String name,
    bool value = false,
    double size = 9,
  }) {
    final border = pw.BoxDecoration(
      color: _white,
      border: pw.Border.all(color: _boxRule, width: 0.8),
    );

    if (!data.interactiveForms) {
      return pw.Container(
        width: size,
        height: size,
        decoration: border,
        alignment: pw.Alignment.center,
        // Marcado sem formulário vira um quadrado cheio: o "X" desenhado em 9pt
        // com a fonte do corpo fica torto e some na impressão.
        child:
            value
                ? pw.Container(
                  width: size * 0.55,
                  height: size * 0.55,
                  color: _accent,
                )
                : pw.SizedBox(),
      );
    }

    return pw.Checkbox(
      name: name,
      value: value,
      width: size,
      height: size,
      activeColor: _accent,
      checkColor: _white,
      decoration: border,
    );
  }

  static pw.Widget _headCell(String text, {bool center = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: pw.Text(
        _safe(text.toUpperCase()),
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(fontSize: 6.5, color: _muted, letterSpacing: 0.4),
      ),
    );
  }

  static pw.Widget _bodyCell(
    String text, {
    bool center = false,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: pw.Text(
        _safe(text),
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8,
          color: _ink,
          fontWeight: bold ? pw.FontWeight.bold : null,
          lineSpacing: 1.1,
        ),
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

  // ----------------------------------------------------------------- lookups

  /// `Clérigo 3 / Mago 2`, ou só o nome da primeira classe quando `short`.
  static String _classLine(CharacterSheetPdfData data, {bool short = false}) {
    final levels = data.character.classLevels;
    if (levels.isEmpty) return 'Sem classe';

    if (short) return _className(data, levels.first.classId);

    return levels
        .map((item) => '${_className(data, item.classId)} ${item.level}')
        .join(' / ');
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

  static String? _raceName(CharacterSheetPdfData data) =>
      _raceEntry(data)?.name;

  static String? _backgroundName(CharacterSheetPdfData data) {
    final character = data.character;

    if (character.backgroundId == BackgroundEntry.customId) {
      return character.customBackground.displayName;
    }

    return _firstWhereOrNull(
      data.backgrounds,
      (item) => item.id == character.backgroundId,
    )?.name;
  }

  static T? _firstWhereOrNull<T>(List<T> list, bool Function(T) test) {
    for (final item in list) {
      if (test(item)) return item;
    }
    return null;
  }
}
