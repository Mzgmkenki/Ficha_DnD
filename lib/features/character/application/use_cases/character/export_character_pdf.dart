import 'dart:io';

import 'package:dnd_ficha_app/core/branding/app_branding.dart';
import 'package:dnd_ficha_app/features/character/data/pdf/character_sheet_pdf.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_slot_progression_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
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
  }) async {
    final character = await _repository.findById(characterId);

    if (character == null) {
      throw Exception('Personagem não encontrado.');
    }

    final bytes = await CharacterSheetPdf.build(
      CharacterSheetPdfData(
        character: character,
        classes: classes,
        subclasses: subclasses,
        races: races,
        backgrounds: backgrounds,
        classFeatures: classFeatures,
        feats: feats,
        spells: spells,
        spellSlots: spellSlots,
        logoBytes: await AppBranding.loadLogoBytes(),
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
