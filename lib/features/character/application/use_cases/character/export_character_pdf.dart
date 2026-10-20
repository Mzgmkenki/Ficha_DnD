import 'dart:io';

import 'package:dnd_ficha_app/core/branding/app_branding.dart';
import 'package:dnd_ficha_app/features/character/data/pdf/character_sheet_pdf.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/character/domain/services/armor_class_options.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
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
import 'package:flutter/services.dart';

/// PDF pronto para entregar ao sistema.
class CharacterPdf {
  const CharacterPdf({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// Gera o PDF da ficha.
///
/// Junta o personagem com o compêndio, o retrato, a logo e a fonte dos
/// títulos, e entrega os bytes. Não compartilha nem salva: quem decide o que
/// fazer com o arquivo é a camada de tela.
class ExportCharacterPdf {
  ExportCharacterPdf(this._repository);

  final CharacterRepository _repository;

  /// Fonte dos títulos, para o PDF sair na mesma cara da ficha.
  static const String _titleFontAsset =
      'assets/fonts/CinzelDecorative-Bold.ttf';

  Future<CharacterPdf> call({
    required String characterId,
    required List<ClassEntry> classes,
    required List<SubclassEntry> subclasses,
    required List<RaceEntry> races,
    required List<BackgroundEntry> backgrounds,
    required List<ClassFeatureEntry> classFeatures,
    required List<SpellEntry> spells,
    required List<SpellSlotProgressionEntry> spellSlots,
    List<FeatEntry> feats = const [],
    List<WeaponEntry> weapons = const [],
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    // A CA é resolvida aqui, e não lida do inteiro gravado: Defesa sem
    // Armadura é característica de classe, e o compêndio necessário já está
    // nos parâmetros. Sem isto o PDF sairia com o número de antes da última
    // mudança de atributo.
    final features = SpecialFeatureResolver.resolve(
      character: character,
      classes: classes,
      classFeatures: classFeatures,
      subclasses: subclasses,
      // A raça entra aqui para a CA impressa considerar a Armadura Natural.
      // Sem isto o PDF de um Tartaruga sairia com a CA da fórmula comum,
      // divergindo do número que a ficha mostra na tela.
      races: races,
    );

    final armorClass = ArmorClassOptions.resolve(
      features: features,
      abilityScores: character.abilityScores,
      inventory: character.inventory,
      context: FeatureFormulaContext.fromCharacter(character),
      preferredFormulaId: character.armorClassFormulaId,
      otherBonus: character.armorClassOtherBonus,
    );

    final bytes = await CharacterSheetPdf.build(
      CharacterSheetPdfData(
        character: character,
        armorClass: armorClass.result.total,
        classes: classes,
        subclasses: subclasses,
        races: races,
        backgrounds: backgrounds,
        classFeatures: classFeatures,
        feats: feats,
        spells: spells,
        spellSlots: spellSlots,
        weapons: weapons,
        logoBytes: await AppBranding.loadLogoBytes(),
        iconBytes: await AppBranding.loadIconBytes(),
        portraitBytes: await _readPortrait(character.portraitPath),
        titleFontBytes: await _readFont(),
      ),
    );

    return CharacterPdf(
      bytes: bytes,
      fileName: CharacterSheetPdf.fileName(character),
    );
  }

  /// Lê o retrato do disco. Falhar aqui só custa o retrato, não o PDF: o
  /// arquivo pode ter sido apagado pelo sistema depois de ser gravado.
  Future<Uint8List?> _readPortrait(String? path) async {
    if (path == null || path.isEmpty) return null;

    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (error) {
      debugPrint('Retrato não pôde ser lido para o PDF: $error');
      return null;
    }
  }

  Future<Uint8List?> _readFont() async {
    try {
      final data = await rootBundle.load(_titleFontAsset);
      return data.buffer.asUint8List();
    } catch (error) {
      debugPrint('Fonte dos títulos indisponível para o PDF: $error');
      return null;
    }
  }
}
