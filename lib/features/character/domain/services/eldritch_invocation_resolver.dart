import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character_eldritch_invocation.dart';
import 'package:dnd_ficha_app/features/character/domain/services/eldritch_invocation_prerequisites.dart';
import 'package:dnd_ficha_app/features/character/domain/services/feature_formula.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/eldritch_invocation_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/pact_boon.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/eldritch_invocation_catalog.dart';

/// Em que situação uma invocação do catálogo está, para este personagem.
enum InvocationAvailability {
  /// Já selecionada e com todos os pré-requisitos cumpridos.
  selected('selected', 'Selecionada'),

  /// Já selecionada, mas os pré-requisitos deixaram de ser cumpridos.
  ///
  /// Continua ocupando a vaga e aparecendo na ficha. Os efeitos NÃO são
  /// aplicados, e a ficha pede a substituição — apagar a escolha em silêncio
  /// seria pior, porque o jogador perderia a decisão sem saber por quê.
  invalid('invalid', 'Inválida'),

  /// Disponível para escolher.
  available('available', 'Disponível'),

  /// Visível, mas bloqueada por pré-requisito.
  blocked('blocked', 'Bloqueada');

  const InvocationAvailability(this.id, this.label);

  final String id;
  final String label;

  bool get isSelected =>
      this == InvocationAvailability.selected ||
      this == InvocationAvailability.invalid;
}

/// Uma invocação do catálogo, já resolvida contra este personagem.
class ResolvedInvocation {
  const ResolvedInvocation({
    required this.entry,
    required this.availability,
    this.blocks = const [],
    this.chosenAtLevel = 0,
    this.replacedInvocationId,
    this.replacedAtLevel,
  });

  final EldritchInvocationEntry entry;
  final InvocationAvailability availability;

  /// Pré-requisitos não cumpridos. Vazia quando está disponível ou válida.
  final List<InvocationBlock> blocks;

  /// Nível de Bruxo em que foi escolhida. Zero quando não foi.
  final int chosenAtLevel;

  final String? replacedInvocationId;
  final int? replacedAtLevel;

  String get id => entry.id;

  String get name => entry.name;

  bool get isSelected => availability.isSelected;

  bool get isValid => availability != InvocationAvailability.invalid;

  bool get isBlocked => availability == InvocationAvailability.blocked;

  /// Se os efeitos desta invocação devem ser aplicados na ficha.
  ///
  /// Só os de invocação selecionada E válida. É a tradução direta da regra:
  /// invocação que perdeu o pré-requisito continua listada, mas não vale.
  bool get appliesEffects => availability == InvocationAvailability.selected;

  /// Motivos do bloqueio numa frase, como a ficha mostra.
  String get blockReason => blocks.map((item) => item.message).join(' ');

  ResolvedInvocation copyWith({
    InvocationAvailability? availability,
    List<InvocationBlock>? blocks,
  }) {
    return ResolvedInvocation(
      entry: entry,
      availability: availability ?? this.availability,
      blocks: blocks ?? this.blocks,
      chosenAtLevel: chosenAtLevel,
      replacedInvocationId: replacedInvocationId,
      replacedAtLevel: replacedAtLevel,
    );
  }
}

/// O que as invocações válidas fazem com Rajada Mística, somado.
///
/// Existe porque o cantrip não é uma arma e não passa pelo
/// `WeaponAttackCalculator`: o app não tem onde pendurar "mais um raio" nem
/// "dano extra por acerto" num ataque de magia. Então o resumo é calculado
/// aqui e apresentado como painel próprio, com os números já resolvidos.
class EldritchBlastSummary {
  const EldritchBlastSummary({
    required this.rays,
    required this.rangeMeters,
    this.damageBonus = 0,
    this.pushMeters,
    this.pullMeters,
    this.slowMeters,
    this.sources = const [],
  });

  static const EldritchBlastSummary none = EldritchBlastSummary(
    rays: 0,
    rangeMeters: 0,
  );

  /// Quantos raios o truque dispara no nível atual.
  final int rays;

  /// Alcance em metros, já com Lança Mística aplicada quando houver.
  final int rangeMeters;

  /// Dano extra por acerto, somado.
  final int damageBonus;

  final int? pushMeters;
  final int? pullMeters;
  final int? slowMeters;

  /// Nomes das invocações que contribuíram, para a ficha dizer de onde veio.
  final List<String> sources;

  bool get isEmpty => rays <= 0;

  bool get hasModifiers => sources.isNotEmpty;

  /// Raios de Rajada Mística pelo nível de Bruxo, na tabela de 2014.
  ///
  /// Fica no domínio, e não no asset, porque é o texto do próprio truque e não
  /// uma decisão de conteúdo: 1 raio, 2 no 5º, 3 no 11º e 4 no 17º.
  static int raysAt(int warlockLevel) {
    if (warlockLevel <= 0) return 0;
    if (warlockLevel >= 17) return 4;
    if (warlockLevel >= 11) return 3;
    if (warlockLevel >= 5) return 2;
    return 1;
  }

  /// Alcance padrão do truque, em metros (120 pés).
  static const int defaultRangeMeters = 36;
}

/// O que as invocações válidas fazem com a arma do Pacto da Lâmina.
class PactWeaponSummary {
  const PactWeaponSummary({
    this.attacks = 1,
    this.attackBonus = 0,
    this.damageBonusFlat = 0,
    this.damageBonus = 0,
    this.damageTypes = const [],
    this.extraDamageDice = const [],
    this.isSpellcastingFocus = false,
    this.allowsRanged = false,
    this.sources = const [],
  });

  static const PactWeaponSummary none = PactWeaponSummary();

  /// Quantos ataques a ação de Atacar faz com a arma de pacto.
  final int attacks;

  final int attackBonus;

  /// Bônus fixo de dano, como o +1 da Arma de Pacto Aprimorada.
  final int damageBonusFlat;

  /// Bônus de dano vindo de atributo, como o Carisma do Bebedor de Vida.
  final int damageBonus;

  /// Tipos do dano extra, em texto.
  final List<String> damageTypes;

  /// Dados extras que dependem do espaço gasto, em texto.
  final List<String> extraDamageDice;

  final bool isSpellcastingFocus;
  final bool allowsRanged;

  final List<String> sources;

  bool get isEmpty => sources.isEmpty;
}

/// Uma magia que uma invocação válida concede, com a invocação de origem.
class GrantedInvocationSpell {
  const GrantedInvocationSpell({
    required this.invocation,
    required this.grant,
  });

  final EldritchInvocationEntry invocation;
  final InvocationSpellGrant grant;

  /// Nome a exibir antes de a magia ser resolvida no compêndio.
  String get displayName => grant.namePt ?? grant.spellName;
}

/// As Invocações Místicas do personagem, com limite, vagas e validade já
/// resolvidos.
class ResolvedInvocations {
  const ResolvedInvocations({
    required this.warlockLevel,
    required this.limit,
    required this.options,
    required this.profile,
    this.classId = 'warlock',
    this.className = 'Bruxo',
  });

  static const ResolvedInvocations empty = ResolvedInvocations(
    warlockLevel: 0,
    limit: 0,
    options: [],
    profile: WarlockProfile.none,
  );

  /// Nível NA CLASSE BRUXO. Nunca o nível total do personagem.
  final int warlockLevel;

  /// Quantas invocações o personagem conhece neste nível.
  final int limit;

  /// Todas as invocações do catálogo, cada uma com a sua situação.
  ///
  /// A lista inclui as bloqueadas de propósito: o jogador precisa ver o que
  /// existe e o que falta para alcançar, e esconder torna a progressão
  /// invisível.
  final List<ResolvedInvocation> options;

  /// O perfil usado na validação, para a tela não remontá-lo.
  final WarlockProfile profile;

  final String classId;
  final String className;

  bool get isWarlock => warlockLevel > 0;

  /// Se a ficha deve mostrar a seção de Invocações Místicas.
  ///
  /// A regra é "tem pelo menos uma": um Bruxo de 1º nível ainda não escolhe
  /// invocação, e mostrar uma seção vazia só ocuparia espaço.
  bool get hasAny => selected.isNotEmpty;

  List<ResolvedInvocation> get selected =>
      options.where((item) => item.isSelected).toList(growable: false);

  /// Selecionadas e válidas. São as únicas que produzem efeito.
  List<ResolvedInvocation> get valid => options
      .where((item) => item.availability == InvocationAvailability.selected)
      .toList(growable: false);

  /// Selecionadas que perderam o pré-requisito.
  List<ResolvedInvocation> get invalid => options
      .where((item) => item.availability == InvocationAvailability.invalid)
      .toList(growable: false);

  List<ResolvedInvocation> get available => options
      .where((item) => item.availability == InvocationAvailability.available)
      .toList(growable: false);

  List<ResolvedInvocation> get blocked => options
      .where((item) => item.availability == InvocationAvailability.blocked)
      .toList(growable: false);

  int get selectedCount => selected.length;

  /// Vagas ainda não usadas. Nunca negativa.
  int get freeSlots {
    final left = limit - selectedCount;
    return left < 0 ? 0 : left;
  }

  /// Quantas invocações estão selecionadas além do limite.
  ///
  /// Acontece quando o jogador perde níveis de Bruxo ao editar a ficha. A
  /// ficha avisa em vez de escolher sozinha qual descartar.
  int get overLimit {
    final over = selectedCount - limit;
    return over < 0 ? 0 : over;
  }

  bool get hasPendingSlots => freeSlots > 0 && limit > 0;

  bool get hasInvalid => invalid.isNotEmpty;

  /// Como a ficha mostra a contagem: `3 de 3 selecionadas`.
  String get countLabel => '$selectedCount de $limit selecionadas';

  ResolvedInvocation? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final item in options) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Magias concedidas pelas invocações VÁLIDAS.
  List<GrantedInvocationSpell> get grantedSpells {
    final result = <GrantedInvocationSpell>[];

    for (final item in valid) {
      for (final grant in item.entry.spellGrants) {
        result.add(
          GrantedInvocationSpell(invocation: item.entry, grant: grant),
        );
      }
    }

    return List<GrantedInvocationSpell>.unmodifiable(result);
  }

  /// As invocações válidas no formato das características de classe.
  ///
  /// Serve para `FeatureResources` montar os contadores de uso sem um segundo
  /// vocabulário: a invocação declara o mesmo bloco `action` que uma
  /// característica, então o painel de Recursos e descanso e o descanso em si
  /// funcionam sem saber que invocação existe.
  ResolvedFeatures get asFeatures {
    return ResolvedFeatures(
      features: [
        for (final item in valid)
          ResolvedFeature(
            id: item.entry.featureId,
            name: item.entry.name,
            description: item.entry.description,
            origin: FeatureOrigin.invocation,
            classId: classId,
            originId: item.entry.id,
            originLabel: FeatureOrigin.invocation.label,
            level: item.entry.prerequisites.warlockLevel ?? 2,
            action: item.entry.action,
          ),
      ],
    );
  }
}

/// Monta as Invocações Místicas do personagem: limite, vagas, validade e
/// efeitos.
///
/// É o ponto único em que a regra de invocação mora. A interface recebe
/// [ResolvedInvocations] pronto e não repete nenhuma decisão — nem o limite
/// por nível, nem a validação de pré-requisito, nem a diferença entre "ainda
/// não escolheu" e "escolheu e perdeu o pré-requisito".
///
/// Duas coisas que o resolvedor faz de propósito:
///
/// - usa o nível NA CLASSE BRUXO, nunca o total. Um Guerreiro 10 / Bruxo 2 tem
///   duas invocações, não oito;
/// - não apaga seleção inválida. Ela continua na lista, marcada, sem efeito e
///   com o motivo — ver [InvocationAvailability.invalid].
class EldritchInvocationResolver {
  const EldritchInvocationResolver._();

  /// Id da classe que concede invocações, para quem precisa filtrar antes de
  /// resolver.
  static const String warlockClassId = 'warlock';

  static ResolvedInvocations resolve({
    required Character character,
    required EldritchInvocationCatalog catalog,
    required List<ClassEntry> classes,
    List<SubclassEntry> subclasses = const [],
    List<SpellEntry> spells = const [],
  }) {
    final line = _warlockLine(character, classes);

    if (line == null) {
      // Personagem sem nível de Bruxo: nenhuma vaga, e as invocações já
      // gravadas (ficha importada, classe removida) entram como inválidas em
      // vez de desaparecerem.
      return _withoutWarlockLevels(character, catalog);
    }

    final profile = profileFor(
      character: character,
      classes: classes,
      subclasses: subclasses,
      spells: spells,
    );

    final chosen = <String, CharacterEldritchInvocation>{};
    for (final item in character.eldritchInvocations) {
      // Primeira ocorrência vence: id repetido é dado inconsistente e não pode
      // gastar duas vagas.
      chosen.putIfAbsent(item.invocationId, () => item);
    }

    final options = <ResolvedInvocation>[];

    for (final entry in catalog.all) {
      final selection = chosen.remove(entry.id);

      // A validação de uma invocação já escolhida não conta ela mesma como
      // pré-requisito nem como incompatibilidade: senão uma invocação com
      // `incompatible_with` apontando para outra se bloquearia sozinha.
      final blocks = EldritchInvocationPrerequisites.evaluate(
        invocation: entry,
        profile: selection == null
            ? profile
            : profile.copyWith(
                selectedInvocationIds: profile.selectedInvocationIds
                    .where((id) => id != entry.id)
                    .toSet(),
              ),
        catalog: catalog,
      );

      final availability = switch ((selection != null, blocks.isEmpty)) {
        (true, true) => InvocationAvailability.selected,
        (true, false) => InvocationAvailability.invalid,
        (false, true) => InvocationAvailability.available,
        (false, false) => InvocationAvailability.blocked,
      };

      options.add(
        ResolvedInvocation(
          entry: entry,
          availability: availability,
          blocks: blocks,
          chosenAtLevel: selection?.chosenAtLevel ?? 0,
          replacedInvocationId: selection?.replacedInvocationId,
          replacedAtLevel: selection?.replacedAtLevel,
        ),
      );
    }

    // O que sobrou em `chosen` é id que não existe mais no catálogo. Também
    // não é apagado: entra como inválido, com o motivo, para o jogador saber
    // que precisa substituir.
    for (final orphan in chosen.values) {
      options.add(
        ResolvedInvocation(
          entry: EldritchInvocationEntry(
            id: orphan.invocationId,
            name: orphan.invocationId,
            source: '',
          ),
          availability: InvocationAvailability.invalid,
          blocks: const [
            InvocationBlock(
              kind: InvocationBlockKind.unknownInvocation,
              message:
                  'Esta invocação não existe mais no catálogo. Escolha outra '
                  'no lugar dela.',
            ),
          ],
          chosenAtLevel: orphan.chosenAtLevel,
          replacedInvocationId: orphan.replacedInvocationId,
          replacedAtLevel: orphan.replacedAtLevel,
        ),
      );
    }

    return ResolvedInvocations(
      warlockLevel: line.level,
      limit: line.entry.invocationsKnownAt(line.level),
      options: List<ResolvedInvocation>.unmodifiable(options),
      profile: profile,
      classId: line.classId,
      className: line.entry.name,
    );
  }

  /// Monta o perfil do Bruxo para a validação.
  ///
  /// Público porque a tela de seleção e os testes precisam do mesmo perfil que
  /// o resolvedor usou — remontá-lo em outro lugar seria abrir espaço para
  /// duas respostas diferentes à mesma pergunta.
  static WarlockProfile profileFor({
    required Character character,
    required List<ClassEntry> classes,
    List<SubclassEntry> subclasses = const [],
    List<SpellEntry> spells = const [],
  }) {
    final line = _warlockLine(character, classes);
    if (line == null) return WarlockProfile.none;

    return WarlockProfile(
      warlockLevel: line.level,
      pactBoon: pactBoonOf(character),
      knownSpellKeys: _knownSpellKeys(character, spells),
      hasCurseFeature: _hasCurseFeature(character, subclasses),
      selectedInvocationIds: {
        for (final item in character.eldritchInvocations) item.invocationId,
      },
    );
  }

  /// A Dádiva do Pacto escolhida, lida do estado da característica.
  ///
  /// Lê pelo id estável da característica, e não pelo nome: é o mesmo
  /// identificador que `SpecialFeatureResolver.featureId` produz para "Dádiva
  /// do Pacto" no 3º nível de Bruxo.
  static PactBoon? pactBoonOf(Character character) {
    final state = character.featureStateFor(PactBoon.featureId);
    return PactBoon.fromId(state?.choiceOptionId);
  }

  /// O nível na classe Bruxo, ou zero quando não há nenhum.
  static int warlockLevelOf(Character character, List<ClassEntry> classes) {
    return _warlockLine(character, classes)?.level ?? 0;
  }

  /// Quantas invocações o personagem conhece, sem resolver o catálogo.
  static int limitFor(Character character, List<ClassEntry> classes) {
    final line = _warlockLine(character, classes);
    if (line == null) return 0;
    return line.entry.invocationsKnownAt(line.level);
  }

  /// O dano extra e as mudanças de Rajada Mística, já somados.
  static EldritchBlastSummary blastSummaryFor({
    required Character character,
    required ResolvedInvocations invocations,
  }) {
    if (!invocations.isWarlock) return EldritchBlastSummary.none;

    final context = FeatureFormulaContext.fromCharacter(character);

    var damageBonus = 0;
    var range = EldritchBlastSummary.defaultRangeMeters;
    int? push;
    int? pull;
    int? slow;
    final sources = <String>[];

    for (final item in invocations.valid) {
      final blast = item.entry.blast;
      if (blast == null) continue;

      sources.add(item.entry.name);

      final formula = blast.damageBonusFormula;
      if (formula != null) {
        final value = FeatureFormula.valueOf(formula, context);
        if (value != null) damageBonus += value;
      }

      // Alcance substitui, não soma: Lança Mística define 90 m, e duas fontes
      // do mesmo benefício não empilhariam.
      final declaredRange = blast.rangeMeters;
      if (declaredRange != null && declaredRange > range) {
        range = declaredRange;
      }

      if (blast.pushMeters != null) push = blast.pushMeters;
      if (blast.pullMeters != null) pull = blast.pullMeters;
      if (blast.slowMeters != null) slow = blast.slowMeters;
    }

    return EldritchBlastSummary(
      rays: EldritchBlastSummary.raysAt(invocations.warlockLevel),
      rangeMeters: range,
      damageBonus: damageBonus,
      pushMeters: push,
      pullMeters: pull,
      slowMeters: slow,
      sources: List<String>.unmodifiable(sources),
    );
  }

  /// O que as invocações válidas fazem com a arma de pacto, já somado.
  static PactWeaponSummary pactWeaponSummaryFor({
    required Character character,
    required ResolvedInvocations invocations,
  }) {
    final context = FeatureFormulaContext.fromCharacter(character);

    var attacks = 1;
    var attackBonus = 0;
    var damageFlat = 0;
    var damageBonus = 0;
    final damageTypes = <String>[];
    final extraDice = <String>[];
    var focus = false;
    var ranged = false;
    final sources = <String>[];

    for (final item in invocations.valid) {
      final weapon = item.entry.pactWeapon;
      if (weapon == null) continue;

      sources.add(item.entry.name);

      // Ataques não acumulam: vale o maior, como o Ataque Extra.
      final declaredAttacks = weapon.attacks;
      if (declaredAttacks != null && declaredAttacks > attacks) {
        attacks = declaredAttacks;
      }

      attackBonus += weapon.attackBonus ?? 0;
      damageFlat += weapon.damageBonusFlat ?? 0;

      final formula = weapon.damageBonusFormula;
      if (formula != null) {
        final value = FeatureFormula.valueOf(formula, context);
        if (value != null) {
          final minimum = weapon.damageMinimum;
          damageBonus += minimum != null && value < minimum ? minimum : value;
        }
      }

      final type = weapon.damageType;
      if (type != null && !damageTypes.contains(type)) damageTypes.add(type);

      final dice = weapon.extraDamageDice;
      if (dice != null) extraDice.add(dice);

      focus = focus || weapon.spellcastingFocus;
      ranged = ranged || weapon.allowsRanged;
    }

    return PactWeaponSummary(
      attacks: attacks,
      attackBonus: attackBonus,
      damageBonusFlat: damageFlat,
      damageBonus: damageBonus,
      damageTypes: List<String>.unmodifiable(damageTypes),
      extraDamageDice: List<String>.unmodifiable(extraDice),
      isSpellcastingFocus: focus,
      allowsRanged: ranged,
      sources: List<String>.unmodifiable(sources),
    );
  }

  static ResolvedInvocations _withoutWarlockLevels(
    Character character,
    EldritchInvocationCatalog catalog,
  ) {
    if (character.eldritchInvocations.isEmpty) {
      return ResolvedInvocations.empty;
    }

    const block = InvocationBlock(
      kind: InvocationBlockKind.notWarlock,
      message: 'Requer níveis na classe Bruxo.',
    );

    return ResolvedInvocations(
      warlockLevel: 0,
      limit: 0,
      profile: WarlockProfile.none,
      options: [
        for (final item in character.eldritchInvocations)
          ResolvedInvocation(
            entry:
                catalog.byId(item.invocationId) ??
                EldritchInvocationEntry(
                  id: item.invocationId,
                  name: item.invocationId,
                  source: '',
                ),
            availability: InvocationAvailability.invalid,
            blocks: const [block],
            chosenAtLevel: item.chosenAtLevel,
            replacedInvocationId: item.replacedInvocationId,
            replacedAtLevel: item.replacedAtLevel,
          ),
      ],
    );
  }

  /// Nomes normalizados de tudo o que o personagem conhece de magia.
  ///
  /// Entra pelos dois nomes de cada magia, o original e o traduzido, porque o
  /// pré-requisito do livro é escrito em inglês e a ficha do jogador está em
  /// português.
  static Set<String> _knownSpellKeys(
    Character character,
    List<SpellEntry> spells,
  ) {
    if (character.spells.isEmpty || spells.isEmpty) return const {};

    final wanted = <int>{
      for (final spell in character.spells)
        if (spell.isKnown || spell.isAlwaysAvailable || spell.isPrepared)
          spell.spellId,
    };

    if (wanted.isEmpty) return const {};

    final keys = <String>{};
    for (final spell in spells) {
      if (!wanted.contains(spell.id)) continue;

      for (final name in [spell.nameOriginal, spell.namePt]) {
        final key = EldritchInvocationEntry.normalizeName(name);
        if (key.isNotEmpty) keys.add(key);
      }
    }

    return keys;
  }

  /// Se alguma subclasse de Bruxo do personagem declara característica que
  /// amaldiçoa.
  ///
  /// A origem é declarada no asset, pela etiqueta
  /// [EldritchInvocationPrerequisites.curseFeatureTag], e não por uma lista de
  /// ids no código: acrescentar um patrono novo que amaldiçoe passa a ser
  /// editar o asset, não editar o validador.
  static bool _hasCurseFeature(
    Character character,
    List<SubclassEntry> subclasses,
  ) {
    if (subclasses.isEmpty) return false;

    for (final classLevel in character.classLevels) {
      final subclassId = classLevel.subclassId;
      if (subclassId == null || subclassId.isEmpty) continue;

      for (final subclass in subclasses) {
        if (subclass.id != subclassId) continue;
        if (subclass.classId != classLevel.classId) continue;
        if (subclass.tags.contains(
          EldritchInvocationPrerequisites.curseFeatureTag,
        )) {
          return true;
        }
      }
    }

    return false;
  }

  /// A linha de classe que concede invocações, com a entrada do compêndio.
  ///
  /// Procura pela DECLARAÇÃO da progressão, não pelo id `warlock`: é o que faz
  /// uma variante de classe funcionar sem um caso especial, e o que impede o
  /// resolvedor de inventar invocação para quem não tem a tabela.
  static _WarlockLine? _warlockLine(
    Character character,
    List<ClassEntry> classes,
  ) {
    for (final classLevel in character.classLevels) {
      final entry = _progressionFor(classLevel.classId, classes);
      if (entry == null) continue;

      return _WarlockLine(
        classId: classLevel.classId,
        level: classLevel.level,
        entry: entry,
      );
    }

    return null;
  }

  /// A entrada de classe que declara a progressão de invocações.
  ///
  /// Uma variante herda a tabela da classe-base, como herda as subclasses e a
  /// lista de magias.
  static ClassEntry? _progressionFor(String classId, List<ClassEntry> classes) {
    ClassEntry? direct;

    for (final entry in classes) {
      if (entry.id != classId) continue;
      direct = entry;
      break;
    }

    if (direct == null) return null;
    if (direct.grantsEldritchInvocations) return direct;

    final baseId = direct.variantOf;
    if (baseId == null || baseId == classId) return null;

    for (final entry in classes) {
      if (entry.id == baseId && entry.grantsEldritchInvocations) return entry;
    }

    return null;
  }
}

class _WarlockLine {
  const _WarlockLine({
    required this.classId,
    required this.level,
    required this.entry,
  });

  final String classId;
  final int level;
  final ClassEntry entry;
}
