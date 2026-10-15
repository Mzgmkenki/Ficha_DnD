import 'package:dnd_ficha_app/features/character/domain/entities/character_language.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_selection.dart';
import 'package:dnd_ficha_app/features/character/domain/services/language_sources.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feat_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_grant.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/race_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_catalog.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/language_text_import.dart';
import 'package:flutter_test/flutter_test.dart';

/// Catálogo mínimo, com um idioma de cada disponibilidade que importa.
///
/// Montado à mão em vez de lido do asset: estes testes verificam a REGRA, e
/// depender do arquivo faria uma correção de dado quebrar teste de regra. A
/// integridade do asset tem teste próprio.
final _catalog = LanguageCatalog.from(const [
  LanguageEntry(
    id: 'common',
    name: 'Comum',
    nameOriginal: 'Common',
    category: LanguageCategory.standard,
    availability: LanguageAvailability.standard,
    script: 'Comum',
  ),
  LanguageEntry(
    id: 'elvish',
    name: 'Élfico',
    nameOriginal: 'Elvish',
    category: LanguageCategory.standard,
    availability: LanguageAvailability.standard,
    script: 'Élfico',
  ),
  LanguageEntry(
    id: 'dwarvish',
    name: 'Anão',
    nameOriginal: 'Dwarvish',
    category: LanguageCategory.standard,
    availability: LanguageAvailability.standard,
    script: 'Anão',
  ),
  LanguageEntry(
    id: 'giant',
    name: 'Gigante',
    nameOriginal: 'Giant',
    category: LanguageCategory.standard,
    availability: LanguageAvailability.standard,
  ),
  LanguageEntry(
    id: 'draconic',
    name: 'Dracônico',
    nameOriginal: 'Draconic',
    category: LanguageCategory.exotic,
    availability: LanguageAvailability.dungeonMaster,
  ),
  LanguageEntry(
    id: 'druidic',
    name: 'Druídico',
    nameOriginal: 'Druidic',
    category: LanguageCategory.secret,
    availability: LanguageAvailability.featureOnly,
  ),
  LanguageEntry(
    id: 'thieves_cant',
    name: 'Gíria dos Ladrões',
    nameOriginal: "Thieves' Cant",
    category: LanguageCategory.secret,
    availability: LanguageAvailability.featureOnly,
    aliases: ['Gíria de Ladrão'],
  ),
  LanguageEntry(
    id: 'chondathan',
    name: 'Chondathano',
    nameOriginal: 'Chondathan',
    category: LanguageCategory.faerunRegional,
    availability: LanguageAvailability.settingGated,
  ),
  LanguageEntry(
    id: 'gnoll',
    name: 'Gnoll',
    nameOriginal: 'Gnoll',
    category: LanguageCategory.creature,
    availability: LanguageAvailability.hidden,
  ),
]);

// --- Fontes de teste -------------------------------------------------------

const _elf = RaceEntry(
  id: 'elf_phb',
  name: 'Elfo',
  source: 'phb',
  languages: ['Comum', 'Élfico'],
);

const _dwarf = RaceEntry(
  id: 'dwarf_phb',
  name: 'Anão',
  source: 'phb',
  languages: ['Comum', 'Anão'],
);

/// Humano: Comum e um idioma à escolha. É o caso de 47 das 78 raças.
const _human = RaceEntry(
  id: 'human_phb',
  name: 'Humano',
  source: 'phb',
  languages: ['Comum', 'um idioma à escolha'],
);

/// Sub-raça que acrescenta escolha sobre a raça base.
const _highElf = RaceEntry(
  id: 'high_elf',
  name: 'Alto Elfo',
  source: 'phb',
  parentRaceId: 'elf_phb',
  isSubrace: true,
  languages: ['um idioma à escolha'],
);

const _acolyte = BackgroundEntry(
  id: 'acolyte',
  name: 'Acólito',
  skillIds: ['insight', 'religion'],
  languages: 2,
);

const _criminal = BackgroundEntry(
  id: 'criminal',
  name: 'Criminoso',
  skillIds: ['deception', 'stealth'],
);

const _fighter = ClassEntry(
  id: 'fighter',
  name: 'Guerreiro',
  hitDie: 'd10',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
);

const _druid = ClassEntry(
  id: 'druid',
  name: 'Druida',
  hitDie: 'd8',
  source: 'srd',
  skillOptions: [],
  savingThrows: [],
);

/// Característica que concede um idioma secreto.
const _druidicFeature = ClassFeatureEntry(
  classId: 'druid',
  level: 1,
  source: 'phb',
  features: [
    ClassFeature(
      name: 'Druídico',
      description: 'Você conhece o idioma secreto dos druidas.',
      languageGrants: [
        LanguageGrant(
          id: 'druid.druidic',
          fixed: ['druidic'],
          label: 'Idioma secreto dos druidas',
        ),
      ],
    ),
  ],
);

/// Característica que abre vagas de escolha, no 6º nível.
const _cannyFeature = ClassFeatureEntry(
  classId: 'fighter',
  level: 6,
  source: 'phb',
  features: [
    ClassFeature(
      name: 'Explorador Hábil',
      languageGrants: [
        LanguageGrant(
          id: 'ranger.canny.languages',
          choose: 2,
          label: 'Idiomas do Explorador Hábil',
        ),
      ],
    ),
  ],
);

const _linguist = FeatEntry(
  id: 'linguist',
  name: 'Linguista',
  languageGrants: [
    LanguageGrant(id: 'feat.linguist.choice', choose: 3),
  ],
);

ResolvedLanguages _resolve({
  RaceEntry? race,
  RaceEntry? subrace,
  BackgroundEntry? background,
  List<LanguageClassSource> classes = const [],
  List<ClassFeatureEntry> classFeatures = const [],
  List<FeatEntry> feats = const [],
  List<CharacterLanguage> selections = const [],
}) {
  final bundle = LanguageSourceBuilder.build(
    catalog: _catalog,
    race: race,
    subrace: subrace,
    background: background,
    classes: classes,
    classFeatures: classFeatures,
    feats: feats,
  );

  return LanguageResolver.resolve(
    catalog: _catalog,
    sources: bundle.sources,
    selections: selections,
  );
}

/// Preenche uma vaga, devolvendo a lista de escolhas.
List<CharacterLanguage> _fill(
  ResolvedLanguages resolved,
  LanguageSlot slot,
  String languageId, {
  List<CharacterLanguage> current = const [],
}) {
  return LanguageSelection.choose(
    current: current,
    slot: slot,
    languageId: languageId,
    catalog: _catalog,
    resolved: resolved,
  );
}

void main() {
  group('1. raça que concede idiomas fixos', () {
    test('Elfo entra com Comum e Élfico automáticos, sem vaga', () {
      final resolved = _resolve(race: _elf);

      expect(
        resolved.automatic.map((item) => item.languageId),
        containsAll(['common', 'elvish']),
      );
      expect(resolved.automatic, hasLength(2));
      expect(
        resolved.totalSlots,
        0,
        reason: 'o Elfo não dá idioma à escolha',
      );
    });

    test('a origem do idioma automático é exibível', () {
      final resolved = _resolve(race: _elf);
      final common = resolved.automatic.firstWhere(
        (item) => item.languageId == 'common',
      );

      expect(common.originLabel, 'raça Elfo');
      expect(common.isAutomatic, isTrue);
      expect(common.displayName, 'Comum');
    });

    test('o texto livre do asset é normalizado em id', () {
      // "Comum" e "Élfico" não têm id no asset de raças; o catálogo reconhece
      // por nome na importação, e o que sai é id.
      final imported = LanguageTextImporter.convert(
        texts: const ['COMUM', '  élfico  '],
        catalog: _catalog,
        idPrefix: 'race.elf_phb',
      );

      expect(imported.issues, isEmpty);
      expect(imported.grants.single.fixed, ['common', 'elvish']);
    });

    test('texto que não é idioma nem escolha é relatado, não inventado', () {
      final imported = LanguageTextImporter.convert(
        texts: const ['Idioma Inexistente de Teste'],
        catalog: _catalog,
        idPrefix: 'race.x',
      );

      expect(imported.grants, isEmpty);
      expect(imported.issues, hasLength(1));
      expect(imported.issues.single.text, 'Idioma Inexistente de Teste');
    });
  });

  group('2. antecedente que concede idiomas adicionais', () {
    test('Acólito abre duas vagas livres', () {
      final resolved = _resolve(background: _acolyte);

      expect(resolved.totalSlots, 2);
      expect(resolved.filledCount, 0);
      expect(resolved.pendingCount, 2);
      expect(resolved.progressLabel, 'Idiomas adicionais selecionados: 0 de 2.');
    });

    test('a vaga aponta para o antecedente que a abriu', () {
      final resolved = _resolve(background: _acolyte);

      expect(resolved.slots.first.sourceLabel, 'antecedente Acólito');
      expect(resolved.slots.first.kind, LanguageSourceKind.background);
    });

    test('antecedente sem idioma adicional não abre vaga', () {
      final resolved = _resolve(background: _criminal);
      expect(resolved.totalSlots, 0);
    });

    test('preencher uma das duas deixa a outra pendente', () {
      var resolved = _resolve(background: _acolyte);
      final picks = _fill(resolved, resolved.slots.first, 'elvish');

      resolved = _resolve(background: _acolyte, selections: picks);

      expect(resolved.filledCount, 1);
      expect(resolved.pendingCount, 1);
      expect(resolved.progressLabel, 'Idiomas adicionais selecionados: 1 de 2.');
      expect(
        resolved.chosen.single.languageId,
        'elvish',
        reason: 'a escolha aparece como idioma do personagem',
      );
    });
  });

  group('3. soma de concessões de fontes diferentes', () {
    test('raça, antecedente e talento somam vagas sem se atropelar', () {
      final resolved = _resolve(
        race: _human,
        background: _acolyte,
        feats: const [_linguist],
      );

      // Humano: 1 vaga. Acólito: 2. Linguista: 3.
      expect(resolved.totalSlots, 6);
      expect(
        resolved.automatic.map((item) => item.languageId),
        ['common'],
      );
    });

    test('cada vaga tem id próprio, mesmo vindo da mesma concessão', () {
      final resolved = _resolve(feats: const [_linguist]);

      expect(resolved.slots, hasLength(3));
      expect(
        resolved.slots.map((item) => item.id).toSet(),
        hasLength(3),
        reason: 'três vagas da mesma concessão não podem colidir num id só',
      );
    });

    test('sub-raça acrescenta vaga sem apagar a da raça base', () {
      final resolved = _resolve(race: _elf, subrace: _highElf);

      expect(
        resolved.automatic.map((item) => item.languageId),
        containsAll(['common', 'elvish']),
        reason: 'os fixos da raça base continuam',
      );
      expect(
        resolved.totalSlots,
        1,
        reason: 'a vaga vem da sub-raça',
      );
      expect(resolved.slots.single.kind, LanguageSourceKind.subrace);
    });
  });

  group('4. classe que não concede idiomas', () {
    test('Guerreiro de 1º nível não abre vaga nem concede idioma', () {
      final resolved = _resolve(
        classes: const [
          LanguageClassSource(entry: _fighter, level: 1),
        ],
        classFeatures: const [_cannyFeature],
      );

      expect(resolved.automatic, isEmpty);
      expect(
        resolved.totalSlots,
        0,
        reason: 'a característica que dá idioma só chega no 6º nível',
      );
    });

    test('o idioma não é inferido da descrição da classe', () {
      // `ClassEntry` não tem campo de idioma, e nada é deduzido do texto: a
      // concessão só existe se a característica declarar.
      final resolved = _resolve(
        classes: const [
          LanguageClassSource(entry: _fighter, level: 20),
        ],
      );

      expect(resolved.automatic, isEmpty);
      expect(resolved.totalSlots, 0);
    });
  });

  group('5. característica que concede uma escolha adicional', () {
    test('a característica do 6º nível abre duas vagas', () {
      final resolved = _resolve(
        classes: const [
          LanguageClassSource(entry: _fighter, level: 6),
        ],
        classFeatures: const [_cannyFeature],
      );

      expect(resolved.totalSlots, 2);
      expect(resolved.slots.first.kind, LanguageSourceKind.feature);
      expect(resolved.slots.first.label, 'Idiomas do Explorador Hábil');
    });

    test('característica concede idioma secreto automaticamente', () {
      final resolved = _resolve(
        classes: const [
          LanguageClassSource(entry: _druid, level: 1),
        ],
        classFeatures: const [_druidicFeature],
      );

      expect(
        resolved.automatic.map((item) => item.languageId),
        ['druidic'],
      );
      expect(resolved.automatic.single.originLabel, 'Druídico');
      expect(
        resolved.totalSlots,
        0,
        reason: 'é concessão fixa, não escolha',
      );
    });
  });

  group('6. bloqueio de idioma já conhecido', () {
    test('idioma automático não pode ser escolhido de novo', () {
      final resolved = _resolve(race: _human, background: _acolyte);
      final slot = resolved.slots.first;

      final reason = LanguageSelection.blockReasonFor(
        language: _catalog.byId('common')!,
        slot: slot,
        resolved: resolved,
      );

      expect(reason, 'Já concedido por raça Humano');
    });

    test('idioma escolhido numa vaga não pode entrar em outra', () {
      var resolved = _resolve(background: _acolyte);
      final picks = _fill(resolved, resolved.slots.first, 'elvish');
      resolved = _resolve(background: _acolyte, selections: picks);

      final reason = LanguageSelection.blockReasonFor(
        language: _catalog.byId('elvish')!,
        slot: resolved.slots.last,
        resolved: resolved,
      );

      expect(reason, 'Já escolhido em outra vaga');
    });

    test('a gravação recusa, não só a interface', () {
      final resolved = _resolve(race: _human);

      expect(
        () => _fill(resolved, resolved.slots.single, 'common'),
        throwsArgumentError,
        reason: 'a validação de domínio é a que vale',
      );
    });

    test('a opção já conhecida aparece desabilitada, com motivo', () {
      final resolved = _resolve(race: _human);
      final options = LanguageSelection.optionsFor(
        slot: resolved.slots.single,
        catalog: _catalog,
        resolved: resolved,
      );

      final common = options.firstWhere(
        (item) => item.language.id == 'common',
      );
      expect(common.isEnabled, isFalse);
      expect(common.blockReason, isNotNull);
    });
  });

  group('7. bloqueio ao ultrapassar o limite', () {
    test('duas escolhas na mesma vaga: a primeira fica, a segunda cai', () {
      final slotId = _resolve(race: _human).slots.single.id;

      final resolved = _resolve(
        race: _human,
        selections: [
          CharacterLanguage(
            languageId: 'elvish',
            slotId: slotId,
            sourceId: 'human_phb',
          ),
          CharacterLanguage(
            languageId: 'dwarvish',
            slotId: slotId,
            sourceId: 'human_phb',
          ),
        ],
      );

      expect(resolved.filledCount, 1);
      expect(resolved.chosen.single.languageId, 'elvish');
      expect(resolved.droppedSelections, hasLength(1));
      expect(resolved.droppedSelections.single.languageId, 'dwarvish');
    });

    test('o contador nunca fica negativo nem passa do total', () {
      final slotId = _resolve(race: _human).slots.single.id;

      final resolved = _resolve(
        race: _human,
        selections: [
          CharacterLanguage(languageId: 'elvish', slotId: slotId),
          const CharacterLanguage(
            languageId: 'dwarvish',
            slotId: 'vaga.que.nao.existe#1',
          ),
          const CharacterLanguage(
            languageId: 'giant',
            slotId: 'outra.vaga.inexistente#1',
          ),
        ],
      );

      expect(resolved.totalSlots, 1);
      expect(resolved.filledCount, 1);
      expect(resolved.pendingCount, 0);
    });

    test('escolher numa vaga ocupada substitui, em vez de somar', () {
      var resolved = _resolve(background: _acolyte);
      final slot = resolved.slots.first;

      var picks = _fill(resolved, slot, 'elvish');
      resolved = _resolve(background: _acolyte, selections: picks);
      picks = _fill(resolved, slot, 'dwarvish', current: picks);

      resolved = _resolve(background: _acolyte, selections: picks);

      expect(resolved.filledCount, 1);
      expect(resolved.chosen.single.languageId, 'dwarvish');
    });
  });

  group('8. impedimento de concluir com escolha pendente', () {
    test('vaga vazia produz erro de validação', () {
      final resolved = _resolve(background: _acolyte);

      expect(
        LanguageSelection.validationError(resolved),
        'Faltam escolher 2 idiomas.',
      );
    });

    test('uma vaga só diz de onde ela vem', () {
      final resolved = _resolve(race: _human);

      expect(
        LanguageSelection.validationError(resolved),
        'Falta escolher 1 idioma (raça Humano).',
      );
    });

    test('tudo preenchido não impede nada', () {
      var resolved = _resolve(race: _human);
      final picks = _fill(resolved, resolved.slots.single, 'elvish');
      resolved = _resolve(race: _human, selections: picks);

      expect(LanguageSelection.validationError(resolved), isNull);
      expect(resolved.hasPendingChoices, isFalse);
    });

    test('sem vaga nenhuma não há pendência', () {
      final resolved = _resolve(race: _elf);
      expect(LanguageSelection.validationError(resolved), isNull);
    });
  });

  group('9. restrição por categoria', () {
    const restricted = BackgroundEntry(
      id: 'sage',
      name: 'Sábio',
      skillIds: ['arcana'],
      languageGrants: [
        LanguageGrant(
          id: 'sage.standard',
          choose: 1,
          categories: [LanguageCategory.standard],
          label: 'Idioma padrão do antecedente',
        ),
      ],
    );

    test('vaga restrita a padrão recusa idioma exótico', () {
      final resolved = _resolve(background: restricted);

      final reason = LanguageSelection.blockReasonFor(
        language: _catalog.byId('draconic')!,
        slot: resolved.slots.single,
        resolved: resolved,
      );

      expect(reason, 'Esta vaga aceita somente idioma padrão');
    });

    test('a vaga restrita só oferece os padrão', () {
      final resolved = _resolve(background: restricted);
      final options = LanguageSelection.optionsFor(
        slot: resolved.slots.single,
        catalog: _catalog,
        resolved: resolved,
      );

      expect(
        options.map((item) => item.language.id).toSet(),
        {'common', 'dwarvish', 'elvish', 'giant'},
        reason: 'exótico, secreto, regional e de criatura ficam fora',
      );
      expect(options.every((item) => item.language.isStandard), isTrue);
    });

    test('vaga com lista específica só aceita a lista', () {
      const named = RaceEntry(
        id: 'simic',
        name: 'Híbrido Simic',
        source: 'ggr',
        languageGrants: [
          LanguageGrant(
            id: 'simic.pair',
            choose: 1,
            options: ['elvish', 'dwarvish'],
          ),
        ],
      );

      final resolved = _resolve(race: named);
      final options = LanguageSelection.optionsFor(
        slot: resolved.slots.single,
        catalog: _catalog,
        resolved: resolved,
      );

      expect(
        options.map((item) => item.language.id).toSet(),
        {'elvish', 'dwarvish'},
      );
      expect(
        LanguageSelection.blockReasonFor(
          language: _catalog.byId('giant')!,
          slot: resolved.slots.single,
          resolved: resolved,
        ),
        'Fora das opções desta origem',
      );
    });

    test('"Élfico ou Vedalken" do asset vira escolha entre dois', () {
      final imported = LanguageTextImporter.convert(
        texts: const ['Comum', 'Élfico ou Anão'],
        catalog: _catalog,
        idPrefix: 'race.x',
      );

      expect(imported.issues, isEmpty);
      expect(imported.grants, hasLength(2));
      expect(imported.grants.first.fixed, ['common']);
      expect(imported.grants.last.choose, 1);
      expect(imported.grants.last.options, ['elvish', 'dwarvish']);
    });
  });

  group('10. bloqueio de idioma secreto sem autorização', () {
    test('Druídico não aparece numa vaga comum', () {
      final resolved = _resolve(background: _acolyte);
      final options = LanguageSelection.optionsFor(
        slot: resolved.slots.first,
        catalog: _catalog,
        resolved: resolved,
      );

      expect(
        options.map((item) => item.language.id),
        isNot(contains('druidic')),
      );
      expect(
        options.map((item) => item.language.id),
        isNot(contains('thieves_cant')),
      );
    });

    test('e é recusado se alguém tentar gravar', () {
      final resolved = _resolve(background: _acolyte);

      expect(
        LanguageSelection.blockReasonFor(
          language: _catalog.byId('druidic')!,
          slot: resolved.slots.first,
          resolved: resolved,
        ),
        'Idioma secreto: só entra por uma característica que o conceda',
      );

      expect(
        () => _fill(resolved, resolved.slots.first, 'druidic'),
        throwsArgumentError,
      );
    });

    test('idioma de criatura também fica fora da lista comum', () {
      final resolved = _resolve(background: _acolyte);
      final options = LanguageSelection.optionsFor(
        slot: resolved.slots.first,
        catalog: _catalog,
        resolved: resolved,
      );

      expect(
        options.map((item) => item.language.id),
        isNot(contains('gnoll')),
      );
    });

    test('regional de cenário só aparece com o filtro ligado', () {
      final resolved = _resolve(background: _acolyte);

      final withoutGated = LanguageSelection.optionsFor(
        slot: resolved.slots.first,
        catalog: _catalog,
        resolved: resolved,
      ).map((item) => item.language.id);

      final withGated = LanguageSelection.optionsFor(
        slot: resolved.slots.first,
        catalog: _catalog,
        resolved: resolved,
        includeGated: true,
      ).map((item) => item.language.id);

      expect(withoutGated, isNot(contains('chondathan')));
      expect(withGated, contains('chondathan'));
      expect(
        withGated,
        isNot(contains('gnoll')),
        reason: 'o filtro de cenário não libera idioma de criatura',
      );
    });

    test('a característica que concede passa por cima da restrição', () {
      // Druídico é `feature_only`, e mesmo assim entra — porque é concessão
      // fixa da característica, não escolha.
      final resolved = _resolve(
        classes: const [LanguageClassSource(entry: _druid, level: 1)],
        classFeatures: const [_druidicFeature],
      );

      expect(resolved.knownLanguageIds, contains('druidic'));
    });
  });

  group('11. recálculo após mudar a raça', () {
    test('a escolha da raça antiga perde a vaga', () {
      var resolved = _resolve(race: _human);
      final picks = _fill(resolved, resolved.slots.single, 'elvish');

      // Trocou Humano por Elfo: o Elfo não dá idioma à escolha.
      resolved = _resolve(race: _elf, selections: picks);

      expect(resolved.totalSlots, 0);
      expect(resolved.chosen, isEmpty);
      expect(resolved.droppedSelections, hasLength(1));
      expect(resolved.droppedSelections.single.languageId, 'elvish');
    });

    test('os automáticos trocam junto com a raça', () {
      final resolved = _resolve(race: _dwarf);

      expect(
        resolved.automatic.map((item) => item.languageId),
        containsAll(['common', 'dwarvish']),
      );
      expect(
        resolved.automatic.map((item) => item.languageId),
        isNot(contains('elvish')),
      );
    });

    test('a escolha some da ficha depois da poda', () {
      var resolved = _resolve(race: _human);
      final picks = _fill(resolved, resolved.slots.single, 'elvish');

      resolved = _resolve(race: _elf, selections: picks);
      final pruned = LanguageSelection.pruneDropped(
        current: picks,
        resolved: resolved,
      );

      expect(pruned, isEmpty);
    });
  });

  group('12. recálculo após mudar o antecedente', () {
    test('trocar para antecedente sem idioma derruba as escolhas', () {
      var resolved = _resolve(background: _acolyte);
      var picks = _fill(resolved, resolved.slots.first, 'elvish');
      resolved = _resolve(background: _acolyte, selections: picks);
      picks = _fill(resolved, resolved.slots.last, 'dwarvish', current: picks);

      resolved = _resolve(background: _criminal, selections: picks);

      expect(resolved.totalSlots, 0);
      expect(resolved.droppedSelections, hasLength(2));
      expect(
        LanguageSelection.pruneDropped(current: picks, resolved: resolved),
        isEmpty,
      );
    });

    test('trocar entre antecedentes com a mesma quantidade mantém a vaga', () {
      const otherTwo = BackgroundEntry(
        id: 'sage',
        name: 'Sábio',
        skillIds: ['arcana'],
        languages: 2,
      );

      var resolved = _resolve(background: _acolyte);
      final picks = _fill(resolved, resolved.slots.first, 'elvish');

      resolved = _resolve(background: otherTwo, selections: picks);

      expect(
        resolved.totalSlots,
        2,
        reason: 'o Sábio também dá dois idiomas',
      );
      expect(
        resolved.droppedSelections,
        hasLength(1),
        reason: 'a vaga do Acólito não é a vaga do Sábio: o id traz a fonte',
      );
    });
  });

  group('13. preservação de escolhas ainda válidas', () {
    test('trocar a raça não mexe na escolha do antecedente', () {
      var resolved = _resolve(race: _human, background: _acolyte);

      final raceSlot = resolved.slots.firstWhere(
        (item) => item.kind == LanguageSourceKind.race,
      );
      final backgroundSlot = resolved.slots.firstWhere(
        (item) => item.kind == LanguageSourceKind.background,
      );

      var picks = _fill(resolved, raceSlot, 'elvish');
      resolved = _resolve(
        race: _human,
        background: _acolyte,
        selections: picks,
      );
      picks = _fill(
        resolved,
        backgroundSlot,
        'dwarvish',
        current: picks,
      );

      // Humano → Elfo: cai a vaga da raça, ficam as duas do antecedente.
      resolved = _resolve(race: _elf, background: _acolyte, selections: picks);

      expect(
        resolved.chosen.map((item) => item.languageId),
        ['dwarvish'],
        reason: 'a escolha do antecedente continua apoiada',
      );
      expect(resolved.droppedSelections.single.languageId, 'elvish');

      final pruned = LanguageSelection.pruneDropped(
        current: picks,
        resolved: resolved,
      );
      expect(pruned, hasLength(1));
      expect(pruned.single.languageId, 'dwarvish');
    });

    test('subir de nível não derruba escolha nenhuma', () {
      var resolved = _resolve(
        classes: const [LanguageClassSource(entry: _fighter, level: 6)],
        classFeatures: const [_cannyFeature],
      );
      final picks = _fill(resolved, resolved.slots.first, 'elvish');

      resolved = _resolve(
        classes: const [LanguageClassSource(entry: _fighter, level: 10)],
        classFeatures: const [_cannyFeature],
        selections: picks,
      );

      expect(resolved.droppedSelections, isEmpty);
      expect(resolved.chosen.single.languageId, 'elvish');
    });
  });

  group('14. remoção de escolhas que perderam sua origem', () {
    test('soltar o talento tira só o que vinha dele', () {
      var resolved = _resolve(
        background: _acolyte,
        feats: const [_linguist],
      );

      final backgroundSlot = resolved.slots.firstWhere(
        (item) => item.kind == LanguageSourceKind.background,
      );
      final featSlot = resolved.slots.firstWhere(
        (item) => item.kind == LanguageSourceKind.feat,
      );

      var picks = _fill(resolved, backgroundSlot, 'elvish');
      resolved = _resolve(
        background: _acolyte,
        feats: const [_linguist],
        selections: picks,
      );
      picks = _fill(resolved, featSlot, 'dwarvish', current: picks);

      // Talento removido.
      resolved = _resolve(background: _acolyte, selections: picks);
      final pruned = LanguageSelection.pruneDropped(
        current: picks,
        resolved: resolved,
      );

      expect(pruned.map((item) => item.languageId), ['elvish']);
      expect(resolved.droppedNotice, isNotNull);
    });

    test('a poda é idempotente', () {
      var resolved = _resolve(race: _human);
      final picks = _fill(resolved, resolved.slots.single, 'elvish');

      resolved = _resolve(race: _elf, selections: picks);
      final once = LanguageSelection.pruneDropped(
        current: picks,
        resolved: resolved,
      );

      final after = _resolve(race: _elf, selections: once);
      expect(after.droppedSelections, isEmpty);
      expect(
        LanguageSelection.pruneDropped(current: once, resolved: after),
        same(once),
        reason: 'nada a podar devolve a mesma lista, sem gravação nova',
      );
    });

    test('idioma manual sobrevive à troca de raça', () {
      // Manual não depende de vaga: o Mestre concedeu, e trocar de raça não
      // desfaz isso.
      final resolved = _resolve(race: _human);
      final manual = LanguageSelection.addManual(
        current: const [],
        languageId: 'giant',
        resolved: resolved,
      );

      final after = _resolve(race: _elf, selections: manual);

      expect(after.droppedSelections, isEmpty);
      expect(after.chosen.single.languageId, 'giant');
      expect(after.chosen.single.kind, LanguageOriginKind.manual);
    });

    test('idioma legado de id desconhecido não é apagado', () {
      final resolved = _resolve(
        race: _elf,
        selections: const [
          CharacterLanguage(
            languageId: 'idioma_que_saiu_do_compendio',
            kind: LanguageOriginKind.legacy,
          ),
        ],
      );

      expect(resolved.droppedSelections, isEmpty);
      expect(resolved.chosen, hasLength(1));
      expect(resolved.chosen.single.isUnknown, isTrue);
      expect(
        resolved.chosen.single.displayName,
        'idioma_que_saiu_do_compendio',
        reason: 'sem entrada no catálogo, o id é o que se tem para mostrar',
      );
    });
  });

  group('15. prevenção de duplicidades', () {
    test('duas fontes com o mesmo idioma: uma linha, duas origens', () {
      const dwarfLike = BackgroundEntry(
        id: 'clan',
        name: 'Clã Anão',
        skillIds: [],
        languageGrants: [
          LanguageGrant(id: 'clan.fixed', fixed: ['dwarvish']),
        ],
      );

      final resolved = _resolve(race: _dwarf, background: dwarfLike);

      final dwarvish = resolved.automatic
          .where((item) => item.languageId == 'dwarvish')
          .toList();

      expect(dwarvish, hasLength(1), reason: 'aparece uma vez na ficha');
      expect(
        dwarvish.single.origins,
        ['raça Anão', 'antecedente Clã Anão'],
        reason: 'as duas origens ficam guardadas',
      );
      expect(
        resolved.totalSlots,
        0,
        reason: 'não há regra geral de substituição: nada é inventado',
      );
    });

    test('escolha que virou automática devolve a vaga', () {
      var resolved = _resolve(race: _human, background: _acolyte);
      final raceSlot = resolved.slots.firstWhere(
        (item) => item.kind == LanguageSourceKind.race,
      );
      final picks = _fill(resolved, raceSlot, 'dwarvish');

      // Trocou Humano por Anão, que já dá Anão automaticamente.
      resolved = _resolve(
        race: _dwarf,
        background: _acolyte,
        selections: picks,
      );

      expect(resolved.knownLanguageIds, contains('dwarvish'));
      expect(
        resolved.automatic.where((i) => i.languageId == 'dwarvish'),
        hasLength(1),
      );
      expect(
        resolved.droppedSelections,
        hasLength(1),
        reason: 'a escolha ficou redundante e a vaga volta a estar livre',
      );
    });

    test('o catálogo descarta id repetido e relata', () {
      final catalog = LanguageCatalog.from(const [
        LanguageEntry(
          id: 'elvish',
          name: 'Élfico',
          category: LanguageCategory.standard,
          availability: LanguageAvailability.standard,
        ),
        LanguageEntry(
          id: 'elvish',
          name: 'Elfo',
          category: LanguageCategory.standard,
          availability: LanguageAvailability.standard,
        ),
      ]);

      expect(catalog.length, 1);
      expect(catalog.duplicates, hasLength(1));
      expect(catalog.duplicates.single.matchedBy, 'identificador');
    });

    test('o catálogo descarta nome repetido com id diferente', () {
      final catalog = LanguageCatalog.from(const [
        LanguageEntry(
          id: 'elvish',
          name: 'Élfico',
          category: LanguageCategory.standard,
          availability: LanguageAvailability.standard,
        ),
        LanguageEntry(
          id: 'elfico',
          name: 'ELFICO',
          category: LanguageCategory.standard,
          availability: LanguageAvailability.standard,
        ),
      ]);

      expect(catalog.length, 1);
      expect(catalog.byId('elvish'), isNotNull);
      expect(catalog.duplicates.single.matchedBy, 'nome');
    });

    test('o mesmo idioma não entra duas vezes por alias', () {
      // "Gíria de Ladrão" é alias de `thieves_cant`.
      expect(_catalog.resolve('Gíria de Ladrão')?.id, 'thieves_cant');
      expect(_catalog.resolve('giria de ladrao')?.id, 'thieves_cant');
      expect(_catalog.resolve("Thieves' Cant")?.id, 'thieves_cant');
    });

    test('acrescentar à mão um idioma já conhecido é recusado', () {
      final resolved = _resolve(race: _elf);

      expect(
        () => LanguageSelection.addManual(
          current: const [],
          languageId: 'elvish',
          resolved: resolved,
        ),
        throwsArgumentError,
      );
    });
  });

  group('busca e exibição', () {
    test('a busca acha por nome, original e alias', () {
      expect(_catalog.byId('elvish')!.containsQuery('elf'), isTrue);
      expect(_catalog.byId('elvish')!.containsQuery('ELV'), isTrue);
      expect(
        _catalog.byId('thieves_cant')!.containsQuery('ladrao'),
        isTrue,
      );
      expect(_catalog.byId('elvish')!.containsQuery('anao'), isFalse);
    });

    test('a opção traz categoria e escrita para a interface', () {
      final resolved = _resolve(background: _acolyte);
      final options = LanguageSelection.optionsFor(
        slot: resolved.slots.first,
        catalog: _catalog,
        resolved: resolved,
      );

      final elvish = options.firstWhere(
        (item) => item.language.id == 'elvish',
      );
      expect(elvish.details, 'Idioma padrão • escrita Élfico');
    });

    test('a vaga se descreve com origem e restrição', () {
      final resolved = _resolve(background: _acolyte);

      expect(
        resolved.slots.first.description,
        'antecedente Acólito — qualquer idioma disponível',
      );
    });
  });
}
