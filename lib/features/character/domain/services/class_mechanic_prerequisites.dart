import 'package:dnd_ficha_app/core/extensions/int_extensions.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/ability_scores.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_mechanic_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_prerequisite.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/class_mechanic_catalog.dart';

/// Que tipo de exigência não foi cumprida.
///
/// O tipo existe separado da mensagem para a interface poder agrupar e os
/// testes poderem afirmar a regra sem comparar texto de interface: teste que
/// casa string de copy quebra na primeira revisão de redação, e o motivo do
/// bloqueio é regra, não redação.
enum MechanicBlockKind {
  /// O personagem não tem a classe que concede a mecânica.
  missingClass('missing_class'),

  /// O personagem não tem a subclasse exigida.
  missingSubclass('missing_subclass'),

  /// Falta nível NA CLASSE responsável.
  classLevel('class_level'),

  /// Falta uma característica anterior.
  missingFeature('missing_feature'),

  /// Falta valor mínimo de atributo.
  abilityMinimum('ability_minimum'),

  /// Falta a magia ou o truque exigido.
  missingSpell('missing_spell'),

  /// Falta a proficiência exigida.
  missingProficiency('missing_proficiency'),

  /// Falta o equipamento exigido.
  missingEquipment('missing_equipment'),

  /// Falta outra opção escolhida.
  missingOption('missing_option'),

  /// Falta outra opção ATIVA, não apenas escolhida.
  missingActiveOption('missing_active_option'),

  /// Outra opção já escolhida impede esta.
  incompatibleOption('incompatible_option'),

  /// Outra opção ATIVA impede esta ser ativada.
  incompatibleActive('incompatible_active'),

  /// A opção já está escolhida e a mecânica não permite repetir.
  alreadySelected('already_selected'),

  /// A opção já foi escolhida por OUTRA característica da mesma reserva.
  ///
  /// É o caso dos Estilos de Combate: o Campeão ganha um segundo estilo no 10º
  /// nível, mas não pode repetir o que escolheu no 1º — e o mesmo vale entre
  /// classes diferentes em multiclasse.
  alreadyInExclusivePool('already_in_exclusive_pool'),

  /// O limite de escolhas do nível atual já foi usado.
  noFreeSlots('no_free_slots'),

  /// O limite de modos ativos simultâneos já foi alcançado.
  activeLimit('active_limit'),

  /// O id salvo não existe mais no catálogo.
  unknownOption('unknown_option');

  const MechanicBlockKind(this.id);

  final String id;
}

/// Uma exigência não cumprida, com o motivo pronto para a ficha mostrar.
///
/// A frase mora aqui, e não na tela, porque duas telas montariam duas frases
/// diferentes para a mesma regra. A tela de gerenciamento e o painel da ficha
/// leem exatamente este texto.
class MechanicBlock {
  const MechanicBlock({required this.kind, required this.message});

  final MechanicBlockKind kind;

  /// Frase completa, como a ficha exibe: `Requer nível 7 nesta classe.`
  final String message;

  @override
  String toString() => message;
}

/// O que o personagem tem, no formato que as regras de mecânica consultam.
///
/// Tudo aqui é propriedade ESTRUTURADA, nunca nome visível: nível por id de
/// classe, ids de subclasse, nomes normalizados de magia e de característica,
/// chaves de opção. Montar este registro é a única parte que precisa conhecer
/// o personagem e o compêndio; a partir daqui a regra é aritmética sobre
/// conjuntos, e por isso dá para testá-la sem montar uma ficha.
class MechanicProfile {
  const MechanicProfile({
    this.classLevels = const {},
    this.subclassByClass = const {},
    this.abilityScores = neutralScores,
    this.proficiencyBonus = 2,
    this.featureKeys = const {},
    this.knownSpellKeys = const {},
    this.proficiencyKeys = const {},
    this.equipmentKeys = const {},
    this.selectedOptionKeys = const {},
    this.activeOptionKeys = const {},
  });

  /// Atributos neutros, usados quando o perfil é montado sem personagem.
  ///
  /// `AbilityScores` não tem construtor vazio de propósito — um personagem
  /// sempre tem os seis valores. O perfil vazio existe só para estado de
  /// carregamento e para teste de regra que não depende de atributo, e aí 10
  /// em tudo é o neutro honesto: modificador zero, sem bônus nem penalidade.
  static const AbilityScores neutralScores = AbilityScores(
    strength: 10,
    dexterity: 10,
    constitution: 10,
    intelligence: 10,
    wisdom: 10,
    charisma: 10,
  );

  static const MechanicProfile empty = MechanicProfile();

  /// Nível em cada classe, por id.
  ///
  /// É o que faz o pré-requisito de nível valer para a CLASSE responsável e
  /// não para o total: um Guerreiro 3 / Bruxo 9 tem nível total 12 e nível de
  /// Guerreiro 3, e é o 3 que decide se a Runa da Colina está liberada.
  final Map<String, int> classLevels;

  /// Subclasse escolhida em cada classe, por id de classe.
  final Map<String, String> subclassByClass;

  final AbilityScores abilityScores;

  final int proficiencyBonus;

  /// Nomes normalizados das características que o personagem tem.
  final Set<String> featureKeys;

  /// Nomes normalizados das magias e truques conhecidos.
  ///
  /// Cada magia entra pelos dois nomes, o original e o traduzido, para o
  /// pré-requisito casar em qualquer um — mesma decisão do validador de
  /// Invocações Místicas.
  final Set<String> knownSpellKeys;

  /// Chaves normalizadas das proficiências: perícias, ferramentas, armaduras.
  final Set<String> proficiencyKeys;

  /// Chaves normalizadas do equipamento que o personagem carrega.
  final Set<String> equipmentKeys;

  /// Opções já escolhidas, na forma `mecanica_id:option_id`.
  final Set<String> selectedOptionKeys;

  /// Opções atualmente ATIVAS, na forma `mecanica_id:option_id`.
  ///
  /// Separado de [selectedOptionKeys] porque conhecer uma opção e estar com
  /// ela ligada são coisas diferentes — a separação que o levantamento pede.
  final Set<String> activeOptionKeys;

  /// Nível na classe [classId], ou zero quando o personagem não a tem.
  int levelIn(String? classId) {
    if (classId == null || classId.isEmpty) return 0;
    return classLevels[classId] ?? 0;
  }

  bool hasClass(String? classId) => levelIn(classId) > 0;

  /// Se o personagem tem a subclasse, em qualquer classe.
  bool hasSubclass(String? subclassId) {
    if (subclassId == null || subclassId.isEmpty) return false;
    return subclassByClass.values.contains(subclassId);
  }

  bool hasFeature(String nameOrId) =>
      featureKeys.contains(ClassMechanicEntry.normalizeName(nameOrId));

  bool knowsSpell(String nameOrId) =>
      knownSpellKeys.contains(ClassMechanicEntry.normalizeName(nameOrId));

  bool hasProficiency(String nameOrId) =>
      proficiencyKeys.contains(ClassMechanicEntry.normalizeName(nameOrId));

  bool hasEquipment(String nameOrId) =>
      equipmentKeys.contains(ClassMechanicEntry.normalizeName(nameOrId));

  bool hasSelected(String key) => selectedOptionKeys.contains(key);

  bool hasActive(String key) => activeOptionKeys.contains(key);

  MechanicProfile copyWith({
    Map<String, int>? classLevels,
    Map<String, String>? subclassByClass,
    AbilityScores? abilityScores,
    int? proficiencyBonus,
    Set<String>? featureKeys,
    Set<String>? knownSpellKeys,
    Set<String>? proficiencyKeys,
    Set<String>? equipmentKeys,
    Set<String>? selectedOptionKeys,
    Set<String>? activeOptionKeys,
  }) {
    return MechanicProfile(
      classLevels: classLevels ?? this.classLevels,
      subclassByClass: subclassByClass ?? this.subclassByClass,
      abilityScores: abilityScores ?? this.abilityScores,
      proficiencyBonus: proficiencyBonus ?? this.proficiencyBonus,
      featureKeys: featureKeys ?? this.featureKeys,
      knownSpellKeys: knownSpellKeys ?? this.knownSpellKeys,
      proficiencyKeys: proficiencyKeys ?? this.proficiencyKeys,
      equipmentKeys: equipmentKeys ?? this.equipmentKeys,
      selectedOptionKeys: selectedOptionKeys ?? this.selectedOptionKeys,
      activeOptionKeys: activeOptionKeys ?? this.activeOptionKeys,
    );
  }
}

/// Decide, num lugar só, se o personagem cumpre os pré-requisitos de uma
/// mecânica de classe ou de uma opção dentro dela.
///
/// É a camada de DOMÍNIO da validação, e é de propósito que ela não saiba nada
/// de interface. A tela de seleção desabilita a opção porque este validador
/// disse que está bloqueada, e não o contrário: se a decisão morasse no
/// widget, qualquer outro caminho de escrita — importar ficha, subir de nível,
/// trocar de subclasse, migrar personagem antigo — entraria sem validação
/// nenhuma.
class ClassMechanicPrerequisites {
  const ClassMechanicPrerequisites._();

  /// Chave de uma opção dentro de uma mecânica.
  ///
  /// Pública porque o perfil, o resolvedor e o serviço de seleção precisam
  /// montá-la igual — duas montagens diferentes é o mesmo que nenhuma.
  static String optionKey(String mechanicId, String optionId) =>
      '$mechanicId:$optionId';

  /// Normaliza uma referência de opção para a chave completa.
  ///
  /// Aceita `option_id` (dentro de [withinMechanicId]) e
  /// `mecanica_id:option_id` (em outra mecânica), que é o que o asset escreve.
  static String resolveKey(
    String reference, {
    required String withinMechanicId,
  }) {
    final text = reference.trim();
    if (text.contains(':')) return text;
    return optionKey(withinMechanicId, text);
  }

  /// Tudo o que falta para a mecânica estar disponível.
  ///
  /// Lista vazia significa disponível. A ordem vai do pré-requisito mais
  /// estrutural para o mais circunstancial, porque é nessa ordem que o jogador
  /// consegue agir: classe antes de nível, nível antes de atributo.
  static List<MechanicBlock> evaluateMechanic({
    required ClassMechanicEntry entry,
    required MechanicProfile profile,
    ClassMechanicCatalog? catalog,
  }) {
    final blocks = <MechanicBlock>[];

    final classLevel = profile.levelIn(entry.classId);

    if (classLevel <= 0) {
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.missingClass,
          message: 'Requer níveis na classe que concede esta característica.',
        ),
      );
      // Sem a classe, repetir cada exigência seria ruído: o jogador não cumpre
      // nada porque não tem a classe, e essa é a frase útil.
      return List<MechanicBlock>.unmodifiable(blocks);
    }

    final subclassId = entry.subclassId;
    if (subclassId != null &&
        subclassId.isNotEmpty &&
        profile.subclassByClass[entry.classId] != subclassId) {
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.missingSubclass,
          message: 'Requer a subclasse que concede esta característica.',
        ),
      );
    }

    if (classLevel < entry.level) {
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.classLevel,
          message: 'Requer nível ${entry.level} nesta classe.',
        ),
      );
    }

    blocks.addAll(
      _evaluatePrerequisite(
        pre: entry.prerequisites,
        profile: profile,
        ownerClassId: entry.classId,
        mechanicId: entry.id,
        catalog: catalog,
      ),
    );

    return blocks.isEmpty ? const [] : List<MechanicBlock>.unmodifiable(blocks);
  }

  /// Tudo o que falta para o personagem poder escolher [option].
  ///
  /// NÃO inclui as exigências da mecânica: elas são avaliadas uma vez em
  /// [evaluateMechanic], e repeti-las em cada opção enche a tela com a mesma
  /// frase 23 vezes.
  static List<MechanicBlock> evaluateOption({
    required ClassMechanicEntry entry,
    required MechanicOption option,
    required MechanicProfile profile,
    ClassMechanicCatalog? catalog,
  }) {
    final blocks = <MechanicBlock>[];

    final classLevel = profile.levelIn(entry.classId);
    final pre = option.prerequisites;

    final requiredLevel = pre.classLevel;
    if (requiredLevel != null && classLevel < requiredLevel) {
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.classLevel,
          message: 'Requer nível $requiredLevel nesta classe.',
        ),
      );
    }

    blocks.addAll(
      _evaluatePrerequisite(
        pre: pre,
        profile: profile,
        ownerClassId: entry.classId,
        mechanicId: entry.id,
        catalog: catalog,
        skipClassLevel: true,
      ),
    );

    // Incompatibilidade entre opções da mesma mecânica. A própria opção nunca
    // se conta: senão uma opção que lista todas as irmãs se bloquearia sozinha
    // depois de escolhida.
    final selfKey = optionKey(entry.id, option.id);

    for (final reference in option.incompatibleWith) {
      final key = resolveKey(reference, withinMechanicId: entry.id);
      if (key == selfKey) continue;
      if (!profile.hasSelected(key)) continue;

      final label =
          catalog?.optionLabel(reference, withinMechanicId: entry.id) ??
          reference;

      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.incompatibleOption,
          message: 'Incompatível com a opção selecionada $label.',
        ),
      );
    }

    return blocks.isEmpty ? const [] : List<MechanicBlock>.unmodifiable(blocks);
  }

  /// Se o personagem cumpre tudo para escolher [option].
  static bool isOptionAvailable({
    required ClassMechanicEntry entry,
    required MechanicOption option,
    required MechanicProfile profile,
    ClassMechanicCatalog? catalog,
  }) {
    return evaluateOption(
      entry: entry,
      option: option,
      profile: profile,
      catalog: catalog,
    ).isEmpty;
  }

  /// Tudo o que impede [option] de ser ATIVADA agora.
  ///
  /// Existe separado da disponibilidade porque ligar um modo é outra pergunta:
  /// a opção pode estar escolhida e válida, e ainda assim não poder ser ligada
  /// porque outro modo incompatível está ativo ou porque o limite de modos
  /// simultâneos foi alcançado.
  static List<MechanicBlock> evaluateActivation({
    required ClassMechanicEntry entry,
    required MechanicOption option,
    required MechanicProfile profile,
    required int activeCount,
    ClassMechanicCatalog? catalog,
  }) {
    final blocks = <MechanicBlock>[
      ...evaluateOption(
        entry: entry,
        option: option,
        profile: profile,
        catalog: catalog,
      ),
    ];

    final selfKey = optionKey(entry.id, option.id);
    final classLevel = profile.levelIn(entry.classId);

    // Modos incompatíveis ATIVOS. O conflito é informado, e a transição é
    // responsabilidade de quem ativa — ver `ClassMechanicSelection.activate`.
    for (final reference in option.incompatibleWith) {
      final key = resolveKey(reference, withinMechanicId: entry.id);
      if (key == selfKey) continue;
      if (!profile.hasActive(key)) continue;

      final label =
          catalog?.optionLabel(reference, withinMechanicId: entry.id) ??
          reference;

      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.incompatibleActive,
          message: '$label está ativa e é incompatível com esta opção.',
        ),
      );
    }

    final limit = entry.maxActiveAt(classLevel);
    if (limit != null && limit > 0 && activeCount >= limit) {
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.activeLimit,
          message:
              limit == 1
                  ? 'Só uma opção desta característica pode ficar ativa por vez.'
                  : 'No máximo $limit opções desta característica podem ficar '
                      'ativas por vez.',
        ),
      );
    }

    return blocks.isEmpty ? const [] : List<MechanicBlock>.unmodifiable(blocks);
  }

  /// As exigências comuns a mecânica e opção.
  ///
  /// Compartilhado de propósito: a lista de tipos de exigência é a mesma, e
  /// duplicá-la abriria espaço para uma delas ser corrigida e a outra não.
  static List<MechanicBlock> _evaluatePrerequisite({
    required MechanicPrerequisite pre,
    required MechanicProfile profile,
    required String ownerClassId,
    required String mechanicId,
    ClassMechanicCatalog? catalog,
    bool skipClassLevel = false,
  }) {
    if (pre.isEmpty) return const [];

    final blocks = <MechanicBlock>[];

    final requiredClass = pre.classId;
    if (requiredClass != null && !profile.hasClass(requiredClass)) {
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.missingClass,
          message: 'Requer níveis na classe $requiredClass.',
        ),
      );
    }

    final requiredSubclass = pre.subclassId;
    if (requiredSubclass != null && !profile.hasSubclass(requiredSubclass)) {
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.missingSubclass,
          message: 'Requer a subclasse $requiredSubclass.',
        ),
      );
    }

    if (!skipClassLevel) {
      final requiredLevel = pre.classLevel;
      if (requiredLevel != null &&
          profile.levelIn(requiredClass ?? ownerClassId) < requiredLevel) {
        blocks.add(
          MechanicBlock(
            kind: MechanicBlockKind.classLevel,
            message: 'Requer nível $requiredLevel nesta classe.',
          ),
        );
      }
    }

    for (final feature in pre.features) {
      if (profile.hasFeature(feature)) continue;
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.missingFeature,
          message: 'Requer a característica $feature.',
        ),
      );
    }

    for (final entry in pre.abilityMinimums.entries) {
      final value = profile.abilityScores.valueFor(entry.key);
      if (value >= entry.value) continue;
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.abilityMinimum,
          message: 'Requer ${entry.key.label} ${entry.value} ou mais.',
        ),
      );
    }

    for (final spell in pre.spells) {
      if (profile.knowsSpell(spell)) continue;
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.missingSpell,
          message: 'Requer a magia $spell.',
        ),
      );
    }

    for (final proficiency in pre.proficiencies) {
      if (profile.hasProficiency(proficiency)) continue;
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.missingProficiency,
          message: 'Requer proficiência em $proficiency.',
        ),
      );
    }

    for (final item in pre.equipment) {
      if (profile.hasEquipment(item)) continue;
      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.missingEquipment,
          message: 'Requer $item.',
        ),
      );
    }

    for (final reference in pre.options) {
      final key = resolveKey(reference, withinMechanicId: mechanicId);
      if (profile.hasSelected(key)) continue;

      final label =
          catalog?.optionLabel(reference, withinMechanicId: mechanicId) ??
          reference;

      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.missingOption,
          message: 'Requer a opção $label.',
        ),
      );
    }

    for (final reference in pre.activeOptions) {
      final key = resolveKey(reference, withinMechanicId: mechanicId);
      if (profile.hasActive(key)) continue;

      final label =
          catalog?.optionLabel(reference, withinMechanicId: mechanicId) ??
          reference;

      blocks.add(
        MechanicBlock(
          kind: MechanicBlockKind.missingActiveOption,
          message: 'Requer $label ativa.',
        ),
      );
    }

    // `note` NÃO gera bloqueio de propósito: é exigência que depende da mesa,
    // e transformá-la em impedimento seria decidir no lugar do Mestre. Ela
    // aparece na ficha como texto, por `ResolvedClassMechanic`.

    return blocks;
  }

  /// Modificador de um atributo no perfil, para quem precisa montar uma
  /// fórmula sem o `Character` inteiro.
  static int modifierOf(MechanicProfile profile, Ability ability) =>
      profile.abilityScores.valueFor(ability).abilityModifier;
}
