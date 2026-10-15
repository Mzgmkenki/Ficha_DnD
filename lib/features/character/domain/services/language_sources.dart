import 'package:dnd_ficha_app/features/character/domain/services/language_resolver.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_grant.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_catalog.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_text_import.dart';

/// Uma classe do personagem, com o nível e a subclasse escolhida.
class LanguageClassSource {
  const LanguageClassSource({
    required this.entry,
    required this.level,
    this.subclass,
  });

  final ClassEntry entry;
  final int level;
  final SubclassEntry? subclass;
}

/// Monta a lista de fontes de idioma a partir do compêndio.
///
/// É o ÚNICO lugar do app que sabe que idioma pode vir de raça, sub-raça,
/// classe, subclasse, antecedente, característica e talento. Tudo depois daqui
/// trabalha com [LanguageGrantSource], que não tem ideia de qual era a fonte —
/// e é isso que mantém a regra fora das telas.
///
/// Serve tanto à criação (um personagem de 1º nível ainda sem `Character`)
/// quanto à ficha salva (multiclasse), porque recebe as peças soltas em vez de
/// um personagem.
class LanguageSourceBuilder {
  const LanguageSourceBuilder._();

  /// Fontes e o que foi descartado por não ser reconhecido.
  static LanguageSourceBundle build({
    required LanguageCatalog catalog,
    RaceEntry? race,
    RaceEntry? subrace,
    BackgroundEntry? background,
    List<LanguageClassSource> classes = const [],
    List<ClassFeatureEntry> classFeatures = const [],
    List<FeatEntry> feats = const [],
  }) {
    final sources = <LanguageGrantSource>[];
    final issues = <LanguageTextIssue>[];

    void addRace(RaceEntry? entry, LanguageSourceKind kind) {
      if (entry == null) return;

      // Declaração estruturada vence sempre. Só quando ela falta é que o texto
      // livre do asset é importado.
      if (entry.languageGrants.isNotEmpty) {
        sources.add(
          LanguageGrantSource(
            kind: kind,
            sourceId: entry.id,
            sourceLabel: '${kind.label} ${entry.name}',
            grants: entry.languageGrants,
          ),
        );
        return;
      }

      if (entry.languages.isEmpty) return;

      final imported = LanguageTextImporter.convert(
        texts: entry.languages,
        catalog: catalog,
        idPrefix: 'race.${entry.id}',
      );
      issues.addAll(imported.issues);
      if (imported.isEmpty) return;

      sources.add(
        LanguageGrantSource(
          kind: kind,
          sourceId: entry.id,
          sourceLabel: '${kind.label} ${entry.name}',
          grants: imported.grants,
        ),
      );
    }

    addRace(race, LanguageSourceKind.race);
    addRace(subrace, LanguageSourceKind.subrace);

    if (background != null) {
      final grants = background.languageGrants.isNotEmpty
          ? background.languageGrants
          : <LanguageGrant>[
              // O asset sempre guardou só a quantidade. Converter aqui mantém
              // os 30 antecedentes funcionando sem reescrever o arquivo, e um
              // antecedente que precise de restrição declara `language_grants`.
              if (background.languages > 0)
                LanguageGrant(
                  id: 'background.${background.id}.choice',
                  choose: background.languages,
                  label: 'Idioma do antecedente',
                ),
            ];

      if (grants.isNotEmpty) {
        sources.add(
          LanguageGrantSource(
            kind: LanguageSourceKind.background,
            sourceId: background.id,
            sourceLabel: 'antecedente ${background.name}',
            grants: grants,
          ),
        );
      }
    }

    for (final item in classes) {
      // Características de classe já liberadas pelo nível.
      for (final group in classFeatures) {
        if (group.classId != item.entry.id) continue;
        if (group.level > item.level) continue;

        for (final feature in group.features) {
          if (feature.languageGrants.isEmpty) continue;
          sources.add(
            LanguageGrantSource(
              kind: LanguageSourceKind.feature,
              sourceId: '${item.entry.id}.${group.level}.${feature.name}',
              sourceLabel: feature.name,
              grants: feature.languageGrants,
            ),
          );
        }
      }

      final subclass = item.subclass;
      if (subclass == null) continue;

      for (final feature in subclass.featuresUpTo(item.level)) {
        if (feature.languageGrants.isEmpty) continue;
        sources.add(
          LanguageGrantSource(
            kind: LanguageSourceKind.subclass,
            sourceId: '${subclass.id}.${feature.level}.${feature.name}',
            sourceLabel: '${feature.name} (${subclass.name})',
            grants: feature.languageGrants,
          ),
        );
      }
    }

    for (final feat in feats) {
      if (feat.languageGrants.isEmpty) continue;
      sources.add(
        LanguageGrantSource(
          kind: LanguageSourceKind.feat,
          sourceId: feat.id,
          sourceLabel: 'talento ${feat.name}',
          grants: feat.languageGrants,
        ),
      );
    }

    return LanguageSourceBundle(
      sources: List<LanguageGrantSource>.unmodifiable(sources),
      issues: List<LanguageTextIssue>.unmodifiable(issues),
    );
  }
}

/// As fontes montadas, com o que o texto livre não entregou.
class LanguageSourceBundle {
  const LanguageSourceBundle({required this.sources, required this.issues});

  static const LanguageSourceBundle empty = LanguageSourceBundle(
    sources: <LanguageGrantSource>[],
    issues: <LanguageTextIssue>[],
  );

  final List<LanguageGrantSource> sources;

  /// Trechos de texto livre que o catálogo não reconheceu.
  ///
  /// Não geram concessão. Ficam disponíveis para a tela avisar que o
  /// compêndio tem dado que o app não entendeu, em vez de a diferença passar
  /// despercebida.
  final List<LanguageTextIssue> issues;
}
