import 'package:dnd_ficha_app/features/compendium/domain/entities/class_feature_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_prerequisite.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/mechanic_table.dart';

/// Como uma mecânica de classe se comporta.
///
/// Uma mecânica pode ter MAIS DE UMA categoria, e é por isso que isto é um
/// conjunto em [ClassMechanicEntry.kinds] e não um campo único: o Cavaleiro
/// Rúnico é lista de opções conhecidas, modo ativável e recurso limitado ao
/// mesmo tempo, e representá-lo como três mecânicas duplicaria a origem e os
/// efeitos — exatamente o que o levantamento proíbe.
enum ClassMechanicKind {
  /// Uma opção escolhida e mantida na progressão: estilo, técnica,
  /// especialização, ambiente, ancestral.
  permanentChoice('permanent_choice', 'Escolha permanente'),

  /// O personagem aprende uma quantidade de opções e ganha mais em níveis
  /// posteriores: manobras, disparos, runas, disciplinas.
  knownList('known_list', 'Lista de opções conhecidas'),

  /// Pode ser ligada e desligada, alterando um estado ou um cálculo enquanto
  /// está ligada.
  activatableMode('activatable_mode', 'Modo ativável'),

  /// Efeito com duração, condição de encerramento ou recuperação própria.
  temporaryState('temporary_state', 'Estado temporário'),

  /// Tem quantidade atual, máxima e recuperação.
  limitedResource('limited_resource', 'Recurso limitado'),

  /// Tabela informativa. NÃO vira escolha: as linhas são consulta.
  lookupTable('lookup_table', 'Tabela de consulta'),

  /// Tabela em que o jogador informa ou rola um resultado.
  rollTable('roll_table', 'Tabela de rolagem'),

  /// Opção escolhida a cada uso, sem se tornar escolha permanente.
  perUseChoice('per_use_choice', 'Escolha por uso'),

  /// Altera automaticamente um cálculo quando as condições são atendidas.
  autoModifier('auto_modifier', 'Modificador automático');

  const ClassMechanicKind(this.id, this.label);

  /// Identificador estável, usado no asset e no que for persistido.
  final String id;

  final String label;

  /// Se a categoria consome vagas de escolha permanente.
  ///
  /// É o que separa "o jogador compra opções desta lista" de "o jogador
  /// consulta ou decide no momento do uso". Tabela e escolha por uso ficam de
  /// fora de propósito: transformá-las em seleção gravada era o erro que o
  /// levantamento pede para não cometer.
  bool get consumesPicks =>
      this == ClassMechanicKind.permanentChoice ||
      this == ClassMechanicKind.knownList;

  static ClassMechanicKind? fromId(String? id) {
    if (id == null) return null;

    final normalized = id.trim().toLowerCase();
    for (final kind in ClassMechanicKind.values) {
      if (kind.id == normalized) return kind;
    }

    // Sinônimos que o levantamento usa nas linhas de "Controle principal".
    switch (normalized) {
      case 'caminho_persistente':
      case 'estado_persistente':
      case 'choice':
        return ClassMechanicKind.permanentChoice;
      case 'lista':
      case 'list':
        return ClassMechanicKind.knownList;
      case 'modo_ativavel':
      case 'mode':
        return ClassMechanicKind.activatableMode;
      case 'estado':
      case 'state':
        return ClassMechanicKind.temporaryState;
      case 'recurso':
      case 'resource':
        return ClassMechanicKind.limitedResource;
      case 'tabela':
      case 'table':
        return ClassMechanicKind.lookupTable;
      case 'tabela_aleatoria':
      case 'roll':
        return ClassMechanicKind.rollTable;
      case 'modo_por_uso':
      case 'per_use':
        return ClassMechanicKind.perUseChoice;
      case 'modificador':
        return ClassMechanicKind.autoModifier;
      default:
        return null;
    }
  }
}

/// Como o contador de uma mecânica com recurso se comporta.
///
/// A distinção existe porque as duas formas aparecem no levantamento e
/// significam coisas opostas na ficha:
///
/// - [spend] é o caso comum. O máximo é derivado, o personagem começa cheio e
///   o que fica guardado é o GASTO: Dados de Superioridade, usos de runa,
///   Disparo Arcano;
/// - [accumulate] é o contrário. O personagem começa em zero e vai juntando
///   até um teto: os Símbolos dos Mortos do Fantasma, que só existem depois de
///   alguém morrer perto dele.
///
/// Sem a distinção, um Fantasma recém-criado abriria a ficha com o bônus de
/// proficiência em símbolos que ele não tem.
enum ClassMechanicCounter {
  spend('spend'),
  accumulate('accumulate');

  const ClassMechanicCounter(this.id);

  final String id;

  static ClassMechanicCounter? fromId(String? id) {
    if (id == null) return null;

    final normalized = id.trim().toLowerCase();
    for (final item in ClassMechanicCounter.values) {
      if (item.id == normalized) return item;
    }

    switch (normalized) {
      case 'gasto':
        return ClassMechanicCounter.spend;
      case 'acumula':
      case 'acumulado':
        return ClassMechanicCounter.accumulate;
      default:
        return null;
    }
  }
}

/// Quando a substituição de uma opção já escolhida é permitida.
enum MechanicReplacementTrigger {
  /// Ao ganhar qualquer nível na classe responsável.
  levelUp('level_up', 'ao subir de nível nesta classe'),

  /// Só nos níveis que concedem novas escolhas.
  newPick('new_pick', 'ao aprender novas opções'),

  /// Ao terminar um descanso curto ou longo.
  rest('rest', 'ao terminar um descanso curto ou longo'),

  /// Ao terminar um descanso longo.
  longRest('long_rest', 'ao terminar um descanso longo'),

  /// Sempre que a característica é usada.
  anyTime('any_time', 'a qualquer momento');

  const MechanicReplacementTrigger(this.id, this.label);

  final String id;
  final String label;

  static MechanicReplacementTrigger? fromId(String? id) {
    if (id == null) return null;

    final normalized = id.trim().toLowerCase();
    for (final item in MechanicReplacementTrigger.values) {
      if (item.id == normalized) return item;
    }

    switch (normalized) {
      case 'level':
      case 'nivel':
        return MechanicReplacementTrigger.levelUp;
      case 'short_rest':
      case 'descanso':
        return MechanicReplacementTrigger.rest;
      case 'always':
      case 'sempre':
        return MechanicReplacementTrigger.anyTime;
      default:
        return null;
    }
  }
}

/// A regra de substituição de uma mecânica.
///
/// Mecânica SEM esta declaração nunca permite troca, e isso é deliberado: o
/// Ancestral Dracônico é escolhido uma vez e pronto, e deixar a ficha trocá-lo
/// de graça seria inventar uma regra que o livro não dá.
class MechanicReplacement {
  const MechanicReplacement({
    required this.trigger,
    this.perEvent = 1,
    this.note,
  });

  final MechanicReplacementTrigger trigger;

  /// Quantas opções podem ser trocadas de uma vez.
  final int perEvent;

  /// Como a ficha explica a regra.
  final String? note;

  /// Como a interface escreve a permissão.
  String get label {
    final suffix = note == null || note!.trim().isEmpty ? '' : ' ${note!}';
    final count =
        perEvent == 1
            ? 'Pode trocar 1 opção'
            : 'Pode trocar até $perEvent opções';

    return '$count ${trigger.label}.$suffix';
  }

  static MechanicReplacement? tryParse(Object? raw) {
    if (raw == null) return null;

    // `false` desliga explicitamente, e `true` liga com o padrão de subir de
    // nível, que é a regra mais comum do levantamento.
    if (raw is bool) {
      return raw
          ? const MechanicReplacement(
            trigger: MechanicReplacementTrigger.levelUp,
          )
          : null;
    }

    if (raw is! Map) return null;

    final trigger =
        MechanicReplacementTrigger.fromId(raw['trigger']?.toString()) ??
        MechanicReplacementTrigger.levelUp;

    final rawCount = raw['per_event'] ?? raw['count'];
    final perEvent =
        rawCount is int
            ? rawCount
            : rawCount is num
            ? rawCount.toInt()
            : int.tryParse(rawCount?.toString().trim() ?? '') ?? 1;

    final note = raw['note']?.toString().trim();

    return MechanicReplacement(
      trigger: trigger,
      perEvent: perEvent < 1 ? 1 : perEvent,
      note: note == null || note.isEmpty ? null : note,
    );
  }
}

/// Quantas opções a mecânica permite a partir de um nível de classe.
///
/// O valor é o TOTAL acumulado, não o incremento: o Mestre de Batalha conhece
/// 3 manobras no 3º nível e 5 no 7º, e é esse 5 que fica declarado. Guardar o
/// incremento obrigaria somar a tabela inteira a cada leitura e tornaria um
/// nível faltando um erro silencioso de contagem.
class MechanicProgressionStep {
  const MechanicProgressionStep({
    required this.level,
    this.picks,
    this.uses,
    this.optionUses,
    this.maxActive,
    this.note,
  });

  /// Nível NA CLASSE responsável.
  final int level;

  /// Total de opções permitidas a partir deste nível.
  ///
  /// Nulo quando o passo só muda outra coisa: o 10º nível do Mestre de Batalha
  /// troca o dado de superioridade sem conceder manobra nova.
  final int? picks;

  /// Total de usos do recurso a partir deste nível, quando a progressão muda
  /// os usos em vez das escolhas.
  final int? uses;

  /// Usos de CADA opção a partir deste nível.
  ///
  /// Diferente de [uses], que é o recurso compartilhado da mecânica: as runas
  /// do Cavaleiro Rúnico têm um uso cada até o 14º nível e dois a partir do
  /// 15º, e isso não é um pote comum. Sem este campo, metade dos níveis
  /// mostraria contador errado.
  final int? optionUses;

  /// Quantos modos podem ficar ativos ao mesmo tempo a partir deste nível.
  ///
  /// Existe porque o limite de modos ativos muda com o nível em casos reais:
  /// o Artilheiro mantém um Canhão Místico até o 14º e dois a partir do 15º.
  /// Sem isso, o limite teria que ser um número fixo e um dos dois estados
  /// ficaria errado.
  final int? maxActive;

  /// O que mais muda neste nível, em texto: `Dados de superioridade viram
  /// d10`.
  final String? note;

  static MechanicProgressionStep? tryParse(Object? raw) {
    if (raw is! Map) return null;

    int? number(String key) {
      final value = raw[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    final level = number('level');
    if (level == null) return null;

    final note = raw['note']?.toString().trim();

    return MechanicProgressionStep(
      level: level,
      picks: number('picks') ?? number('known'),
      uses: number('uses'),
      optionUses: number('option_uses'),
      maxActive: number('max_active'),
      note: note == null || note.isEmpty ? null : note,
    );
  }
}

/// Uma opção dentro de uma mecânica: uma manobra, uma runa, um totem, um
/// elixir, uma disciplina.
///
/// Tem identificador próprio, pré-requisito próprio e efeito próprio, como o
/// levantamento pede. Reaproveita [FeatureAction] e [FeatureEffect] em vez de
/// um vocabulário paralelo: é o que faz uma opção com usos limitados aparecer
/// no painel de Recursos e descanso, e uma opção que soma na CA entrar no
/// gerenciamento de CA, sem nenhum código novo nessas telas.
class MechanicOption {
  const MechanicOption({
    required this.id,
    required this.name,
    required this.description,
    this.nameOriginal,
    this.summary,
    this.prerequisites = MechanicPrerequisite.none,
    this.incompatibleWith = const [],
    this.effects = const [],
    this.action,
    this.isMode = false,
    this.isGranted = false,
    this.duration,
    this.endsOn,
    this.table,
    this.tags = const [],
  });

  /// Identificador estável, único dentro da mecânica.
  ///
  /// É o que fica persistido. Nunca o nome traduzido: corrigir "Aparar" para
  /// "Parar o Golpe" no compêndio não pode fazer o personagem perder a
  /// manobra.
  final String id;

  final String name;

  /// Nome no livro em inglês, para busca.
  final String? nameOriginal;

  /// Uma linha para a lista fechada.
  final String? summary;

  final String description;

  final MechanicPrerequisite prerequisites;

  /// Opções que esta não pode acompanhar, pelo id.
  ///
  /// Serve para dois casos distintos: escolha mutuamente exclusiva e modo que
  /// não pode ficar ligado junto com outro. Quem distingue é a categoria da
  /// mecânica, não um segundo campo.
  final List<String> incompatibleWith;

  /// O que a opção muda na ficha, no formato normalizado do compêndio.
  final List<FeatureEffect> effects;

  /// O que a opção custa na economia do turno, e os usos dela.
  final FeatureAction? action;

  /// Se esta opção, individualmente, pode ser ligada e desligada.
  ///
  /// Separado da categoria da mecânica porque as duas coisas são diferentes:
  /// o Cavaleiro Rúnico CONHECE seis runas (lista) e INVOCA uma por vez
  /// (modo), e as runas que só têm passivo não ligam nada.
  final bool isMode;

  /// Se a opção é CONCEDIDA, em vez de escolhida.
  ///
  /// Conta como conhecida e NÃO gasta vaga. É o que representa a Sintonia
  /// Elemental do Caminho dos Quatro Elementos, que o Monge conhece de graça
  /// além das disciplinas que escolhe: tratá-la como opção comum faria a
  /// contagem dizer "1 de 1" quando o personagem tem duas.
  final bool isGranted;

  /// Duração enquanto ligada: `1 minuto`, `10 minutos`.
  final String? duration;

  /// Condição de encerramento, em texto.
  final String? endsOn;

  /// Tabela própria da opção, quando ela tem uma.
  final MechanicTable? table;

  final List<String> tags;

  /// Nomes pelos quais a opção pode ser encontrada na busca.
  List<String> get searchableNames => [
    name,
    if (nameOriginal case final original?) original,
    id,
  ];

  /// Se a opção declara usos próprios.
  bool get hasLimitedUses => action?.hasLimitedUses ?? false;

  /// Efeitos que o motor transforma em número.
  List<FeatureEffect> get calculatedEffects =>
      effects.where((item) => item.isCalculated).toList(growable: false);

  /// Efeitos declarados que o app não arbitra, para a ficha mostrar a regra.
  List<FeatureEffect> get referenceEffects =>
      effects.where((item) => !item.isCalculated).toList(growable: false);

  static MechanicOption? tryParse(Object? raw, {required int index}) {
    if (raw is! Map) return null;

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    final name = text('name') ?? text('label');
    if (name == null) return null;

    final id = text('id') ?? ClassMechanicEntry.slug(name);
    if (id.isEmpty) return null;

    return MechanicOption(
      id: id,
      name: name,
      nameOriginal: text('name_original'),
      summary: text('summary'),
      description: text('description') ?? '',
      prerequisites: MechanicPrerequisite.tryParse(raw['prerequisites']),
      incompatibleWith: MechanicPrerequisite.parseStringList(
        raw['incompatible_with'],
      ),
      effects: FeatureEffect.parseList(raw['effects']),
      action: FeatureAction.tryParse(raw['action']),
      isMode: raw['mode'] == true || raw['is_mode'] == true,
      isGranted: raw['granted'] == true,
      duration: text('duration'),
      endsOn: text('ends_on'),
      table: MechanicTable.tryParse(raw['table'], fallbackId: '$id.table'),
      tags: MechanicPrerequisite.parseStringList(raw['tags']),
    );
  }
}

/// Uma mecânica interna de classe ou subclasse, declarada por dado.
///
/// É o registro único de que o levantamento fala: identificador estável,
/// origem, nível de aquisição, categorias, progressão, opções, pré-requisitos,
/// substituição, ativação, duração, usos, efeitos, tabela e onde mostrar.
///
/// Duas coisas que esta entidade deliberadamente NÃO faz:
///
/// - não copia o texto da característica. [featureName] aponta para a
///   característica do compêndio que concede a mecânica, e é ela que continua
///   dona da descrição. É o que evita a mesma regra escrita em dois arquivos
///   divergindo com o tempo;
/// - não resolve nada. Nível alcançado, limite, vaga livre, bloqueio e modo
///   ativo são responsabilidade de `ClassMechanicResolver`, que lê isto contra
///   um personagem.
class ClassMechanicEntry {
  const ClassMechanicEntry({
    required this.id,
    required this.name,
    required this.classId,
    required this.level,
    required this.source,
    this.subclassId,
    this.featureName,
    this.summary,
    this.description,
    this.edition = defaultEdition,
    this.kinds = const {},
    this.progression = const [],
    this.options = const [],
    this.prerequisites = MechanicPrerequisite.none,
    this.replacement,
    this.allowDuplicateOptions = false,
    this.maxActiveOptions,
    this.action,
    this.usesMinimum,
    this.counter = ClassMechanicCounter.spend,
    this.activation,
    this.duration,
    this.recovery,
    this.table,
    this.effects = const [],
    this.display = FeatureDisplaySlot.features,
    this.tags = const [],
    this.note,
  });

  /// Edição que o app adota. O levantamento é 2014/legacy, e misturar com 2024
  /// é o que o requisito proíbe explicitamente.
  static const String defaultEdition = '2014';

  /// Identificador estável, único no compêndio.
  ///
  /// Convenção: `<id da subclasse ou classe>.<slug da mecânica>`, como
  /// `fighter_battle_master.maneuvers`. Fica declarado no asset em vez de
  /// montado, para uma renomeação de mecânica não invalidar ficha salva.
  final String id;

  final String name;

  /// Classe responsável. É o nível NESTA classe que decide tudo.
  final String classId;

  /// Subclasse que concede, quando a mecânica vem de uma.
  final String? subclassId;

  /// Nível na classe em que a mecânica é obtida.
  final int level;

  /// Nome da característica do compêndio que concede a mecânica.
  ///
  /// É o vínculo que impede duplicação: a ficha mostra a mecânica ANINHADA na
  /// característica, e a descrição continua vindo de um lugar só.
  final String? featureName;

  /// Uma linha para o cabeçalho fechado.
  final String? summary;

  /// Texto próprio da mecânica, quando ela precisa de um além do da
  /// característica.
  final String? description;

  final String edition;

  final String source;

  final Set<ClassMechanicKind> kinds;

  final List<MechanicProgressionStep> progression;

  final List<MechanicOption> options;

  final MechanicPrerequisite prerequisites;

  /// Regra de substituição. Nulo é "não permite trocar".
  final MechanicReplacement? replacement;

  /// Se a mesma opção pode ser escolhida mais de uma vez.
  ///
  /// Falso no caso comum. Verdadeiro cobre o Guerreiro Totêmico, que pode
  /// escolher o mesmo animal em níveis diferentes.
  final bool allowDuplicateOptions;

  /// Quantos modos podem estar ativos ao mesmo tempo.
  ///
  /// Nulo é "sem limite declarado". Um é o caso mais comum: a Forma Estelar
  /// tem uma constelação ativa, o Armeiro tem um modelo de armadura.
  final int? maxActiveOptions;

  /// Usos e custo da mecânica como um todo, quando o recurso é compartilhado.
  ///
  /// É assim que os Dados de Superioridade entram: eles não pertencem a uma
  /// manobra, pertencem à mecânica, e cada manobra gasta um.
  final FeatureAction? action;

  /// Piso dos usos quando [FeatureAction.usesFormula] depende de atributo.
  ///
  /// O livro escreve "igual ao seu modificador de Inteligência (mínimo 1)" em
  /// várias características, e sem este piso um Artífice com Inteligência 10
  /// ficaria com zero usos — número errado na ficha, não "sem recurso".
  final int? usesMinimum;

  /// Se o contador conta gasto ou acumulação. Ver [ClassMechanicCounter].
  final ClassMechanicCounter counter;

  /// Como ativar, em texto: `ação bônus`, `ao entrar em Fúria`.
  final String? activation;

  /// Duração do estado, em texto.
  final String? duration;

  /// Como recupera, em texto, quando não dá para expressar em
  /// [FeatureAction.recharge].
  final String? recovery;

  /// Tabela da mecânica, quando ela tem uma.
  final MechanicTable? table;

  /// Efeitos que a mecânica aplica independentemente da opção escolhida.
  final List<FeatureEffect> effects;

  /// Onde a ficha mostra a mecânica.
  final FeatureDisplaySlot display;

  final List<String> tags;

  /// Observação de regra que o app não arbitra.
  final String? note;

  /// Id da fonte: a subclasse quando há uma, senão a classe.
  String get originId => subclassId ?? classId;

  /// Se a mecânica pede escolhas permanentes do jogador.
  bool get hasPicks => kinds.any((kind) => kind.consumesPicks);

  bool get hasModes =>
      kinds.contains(ClassMechanicKind.activatableMode) ||
      options.any((option) => option.isMode);

  bool get hasTable => table != null || options.any((o) => o.table != null);

  bool get isRollTable => kinds.contains(ClassMechanicKind.rollTable);

  bool get isLookupTable => kinds.contains(ClassMechanicKind.lookupTable);

  /// Se a mecânica declara usos próprios.
  bool get hasLimitedUses => action?.hasLimitedUses ?? false;

  bool get canReplace => replacement != null;

  /// Como a ficha escreve as categorias: `Lista de opções conhecidas, Modo
  /// ativável`.
  String get kindsLabel {
    if (kinds.isEmpty) return '';
    // Ordena pela ordem de declaração do enum, para a frase não mudar de
    // ordem entre leituras.
    final sorted = ClassMechanicKind.values
        .where(kinds.contains)
        .map((kind) => kind.label)
        .toList(growable: false);
    return sorted.join(', ');
  }

  MechanicOption? optionById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  /// Opções concedidas de graça, que contam como conhecidas sem gastar vaga.
  List<MechanicOption> get grantedOptions =>
      options.where((option) => option.isGranted).toList(growable: false);

  /// Opções que o jogador escolhe, gastando vaga.
  List<MechanicOption> get selectableOptions =>
      options.where((option) => !option.isGranted).toList(growable: false);

  /// Total de opções permitidas com [classLevel] níveis na classe.
  ///
  /// Zero antes do nível de aquisição, e o último passo alcançado depois dele.
  /// Mecânica sem progressão declarada devolve zero: ela não concede escolha
  /// nenhuma, e inventar uma vaga faria a ficha cobrar decisão inexistente.
  int picksAt(int classLevel) {
    if (classLevel < level) return 0;

    var total = 0;
    for (final step in progression) {
      if (step.level > classLevel) continue;
      final picks = step.picks;
      if (picks != null) total = picks;
    }

    return total;
  }

  /// Quantas opções NOVAS este nível concede.
  ///
  /// Serve para a ficha dizer "Novas escolhas disponíveis: 1" em vez de só
  /// mostrar o total — e para a regra de substituição saber se o nível atual é
  /// um nível de aprendizado.
  int newPicksAt(int classLevel) {
    final current = picksAt(classLevel);
    if (current <= 0) return 0;

    final previous = classLevel <= 1 ? 0 : picksAt(classLevel - 1);
    final gained = current - previous;
    return gained < 0 ? 0 : gained;
  }

  /// Total de usos declarado na progressão para [classLevel], se houver.
  ///
  /// Separado de [FeatureAction.uses] porque a progressão de uso é por nível:
  /// o Mestre de Batalha tem 4 dados no 3º, 5 no 7º e 6 no 15º, e isso não
  /// cabe num número fixo.
  int? usesAt(int classLevel) {
    if (classLevel < level) return null;

    int? total;
    for (final step in progression) {
      if (step.level > classLevel) continue;
      final uses = step.uses;
      if (uses != null) total = uses;
    }

    return total;
  }

  /// Usos de cada opção em [classLevel], quando a progressão os declara.
  ///
  /// Nulo é "a opção manda": cada opção usa os próprios [FeatureAction.uses].
  int? optionUsesAt(int classLevel) {
    if (classLevel < level) return null;

    int? total;
    for (final step in progression) {
      if (step.level > classLevel) continue;
      final value = step.optionUses;
      if (value != null) total = value;
    }

    return total;
  }

  /// Quantos modos podem ficar ativos ao mesmo tempo em [classLevel].
  ///
  /// A progressão tem prioridade sobre [maxActiveOptions], que é o valor base
  /// declarado na mecânica. Nulo é "sem limite declarado".
  int? maxActiveAt(int classLevel) {
    var total = maxActiveOptions;

    for (final step in progression) {
      if (step.level > classLevel) continue;
      final value = step.maxActive;
      if (value != null) total = value;
    }

    return total;
  }

  /// A observação de progressão que vale em [classLevel].
  ///
  /// É o que mostra "Dados de superioridade: d10" sem a ficha conhecer o
  /// Mestre de Batalha.
  String? progressionNoteAt(int classLevel) {
    String? note;
    for (final step in progression) {
      if (step.level > classLevel) continue;
      if (step.note != null) note = step.note;
    }
    return note;
  }

  /// Se a substituição é permitida com [classLevel] níveis na classe.
  ///
  /// [freeEdit] é o modo explícito de edição livre da ficha, em que o jogador
  /// corrige uma decisão fora do momento da regra. Ele não cria permissão onde
  /// não existe: mecânica sem [replacement] continua sem troca.
  bool canReplaceAt(int classLevel, {bool freeEdit = false}) {
    final rule = replacement;
    if (rule == null) return false;
    if (freeEdit) return true;

    return switch (rule.trigger) {
      MechanicReplacementTrigger.anyTime => true,
      MechanicReplacementTrigger.rest => true,
      MechanicReplacementTrigger.longRest => true,
      MechanicReplacementTrigger.levelUp => classLevel >= level,
      MechanicReplacementTrigger.newPick => newPicksAt(classLevel) > 0,
    };
  }

  /// Id da característica usado para guardar usos e estado ativo.
  ///
  /// Reaproveita o mesmo armazenamento das características de classe e das
  /// Invocações Místicas, em vez de um segundo contador: é o que faz o painel
  /// de Recursos e descanso e o próprio descanso funcionarem sem saber que
  /// mecânica de subclasse existe.
  ///
  /// Formato irmão de `SpecialFeatureResolver.featureId` e de
  /// `EldritchInvocationEntry.featureId`, com prefixo próprio para as três
  /// chaves nunca colidirem.
  String featureIdFor([String? optionId]) => mechanicFeatureId(id, optionId);

  /// Monta a chave de estado de uma mecânica ou de uma opção dela.
  static String mechanicFeatureId(String mechanicId, [String? optionId]) {
    if (optionId == null || optionId.isEmpty) return 'mechanic.$mechanicId';
    return 'mechanic.$mechanicId.$optionId';
  }

  /// Normaliza texto para busca e comparação de nome.
  ///
  /// Mesma normalização de `EldritchInvocationEntry.normalizeName`, repetida
  /// aqui para esta entidade não depender do catálogo de invocações. O
  /// sublinhado entra na lista porque os ids do asset usam
  /// `combat_superiority` e o compêndio guarda `Superioridade em Combate`.
  static String normalizeName(String value) {
    final lower = value.trim().toLowerCase();

    final withoutAccents = lower
        .replaceAll(RegExp('[áàâãä]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[íìîï]'), 'i')
        .replaceAll(RegExp('[óòôõö]'), 'o')
        .replaceAll(RegExp('[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n');

    return withoutAccents
        .replaceAll(RegExp(r"[_'’\.,\-/]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Normaliza um nome para caber num identificador.
  static String slug(String value) {
    return normalizeName(
      value,
    ).replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// Lê uma entrada do asset.
  ///
  /// Tolerante como o resto do compêndio: entrada sem id, sem classe ou sem
  /// nível é descartada em vez de derrubar a leitura das outras. Com 45
  /// subclasses no arquivo, uma linha errada não pode apagar o resto.
  static ClassMechanicEntry? tryParse(Object? raw) {
    if (raw is! Map) return null;

    String? text(String key) {
      final value = raw[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    int? number(String key) {
      final value = raw[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    final id = text('id');
    final name = text('name');
    final classId = text('class_id');
    final level = number('level');

    if (id == null || name == null || classId == null || level == null) {
      return null;
    }

    final kinds = <ClassMechanicKind>{};
    for (final item in MechanicPrerequisite.parseStringList(raw['kinds'])) {
      final kind = ClassMechanicKind.fromId(item);
      if (kind != null) kinds.add(kind);
    }

    final progression = <MechanicProgressionStep>[];
    final rawProgression = raw['progression'];
    if (rawProgression is List) {
      for (final item in rawProgression) {
        final step = MechanicProgressionStep.tryParse(item);
        if (step != null) progression.add(step);
      }
    }
    progression.sort((a, b) => a.level.compareTo(b.level));

    final options = <MechanicOption>[];
    final seenOptionIds = <String>{};
    final rawOptions = raw['options'];
    if (rawOptions is List) {
      for (var index = 0; index < rawOptions.length; index++) {
        final option = MechanicOption.tryParse(rawOptions[index], index: index);
        if (option == null) continue;
        // Id repetido no asset é defeito de dado: a primeira ocorrência vence,
        // porque deixar as duas faria a lista mostrar a opção duas vezes e
        // gastar duas vagas.
        if (!seenOptionIds.add(option.id)) continue;
        options.add(option);
      }
    }

    // Progressão não declarada numa mecânica que PEDE escolha: assume que o
    // nível de aquisição concede uma. É o caso das escolhas permanentes
    // simples (ambiente do Arauto da Tempestade, ancestral dracônico), e
    // declarar `[{level: X, picks: 1}]` em cada uma delas seria ruído.
    //
    // A condição é a categoria, não a existência de opções: modo ativável e
    // escolha por uso TAMBÉM têm opções, e inventar uma vaga para elas faria a
    // ficha cobrar uma decisão permanente que a regra não pede.
    final needsDefaultPicks =
        progression.isEmpty &&
        options.isNotEmpty &&
        kinds.any((kind) => kind.consumesPicks);

    final effectiveProgression =
        needsDefaultPicks
            ? <MechanicProgressionStep>[
              MechanicProgressionStep(level: level, picks: 1),
            ]
            : progression;

    return ClassMechanicEntry(
      id: id,
      name: name,
      classId: classId,
      subclassId: text('subclass_id'),
      level: level,
      featureName: text('feature'),
      summary: text('summary'),
      description: text('description'),
      edition: text('edition') ?? defaultEdition,
      source: text('source') ?? '',
      kinds: Set<ClassMechanicKind>.unmodifiable(kinds),
      progression: List<MechanicProgressionStep>.unmodifiable(
        effectiveProgression,
      ),
      options: List<MechanicOption>.unmodifiable(options),
      prerequisites: MechanicPrerequisite.tryParse(raw['prerequisites']),
      replacement: MechanicReplacement.tryParse(raw['replacement']),
      allowDuplicateOptions: raw['allow_duplicates'] == true,
      maxActiveOptions: number('max_active'),
      action: FeatureAction.tryParse(raw['action']),
      usesMinimum: number('uses_minimum'),
      counter:
          ClassMechanicCounter.fromId(raw['counter']?.toString()) ??
          ClassMechanicCounter.spend,
      activation: text('activation'),
      duration: text('duration'),
      recovery: text('recovery'),
      table: MechanicTable.tryParse(raw['table'], fallbackId: '$id.table'),
      effects: FeatureEffect.parseList(raw['effects']),
      display:
          FeatureDisplaySlot.fromId(raw['display']?.toString()) ??
          FeatureDisplaySlot.features,
      tags: MechanicPrerequisite.parseStringList(raw['tags']),
      note: text('note'),
    );
  }
}
