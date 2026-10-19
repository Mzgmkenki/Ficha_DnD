import 'package:dnd_ficha_app/core/utils/pt_collation.dart';

/// As condições de D&D 5e (PHB, Apêndice A).
///
/// Exaustão fica de fora de propósito: ela tem níveis acumulativos em vez de
/// ligado/desligado, e já mora em `Character.exhaustion`. Aqui só entram as
/// condições que o personagem tem ou não tem.
enum Condition {
  frightened('frightened', 'Amedrontado'),
  grappled('grappled', 'Agarrado'),
  stunned('stunned', 'Atordoado'),
  blinded('blinded', 'Cego'),
  prone('prone', 'Caído'),
  charmed('charmed', 'Enfeitiçado'),
  poisoned('poisoned', 'Envenenado'),
  restrained('restrained', 'Impedido'),
  incapacitated('incapacitated', 'Incapacitado'),
  unconscious('unconscious', 'Inconsciente'),
  invisible('invisible', 'Invisível'),
  paralyzed('paralyzed', 'Paralisado'),
  petrified('petrified', 'Petrificado'),
  deafened('deafened', 'Surdo');

  const Condition(this.id, this.label);

  /// Identificador estável, gravado no banco e no arquivo exportado.
  ///
  /// Separado do `name` do enum de propósito: renomear o valor em Dart não
  /// pode invalidar o que já está salvo.
  final String id;

  final String label;

  /// Condições que esta arrasta junto, pelas regras do PHB.
  ///
  /// Não é decoração: quem está paralisado também está incapacitado, e o
  /// jogador precisa ver o "não pode realizar ações nem reações" sem ter que
  /// marcar as duas caixas e sem ter que decorar a regra.
  ///
  /// É um getter com `switch` em vez de campo do construtor porque um valor de
  /// enum não pode referenciar outro valor do mesmo enum na lista de
  /// argumentos const.
  Set<Condition> get implies {
    switch (this) {
      case Condition.paralyzed:
      case Condition.petrified:
      case Condition.stunned:
        return const {Condition.incapacitated};
      case Condition.unconscious:
        return const {Condition.incapacitated, Condition.prone};
      default:
        return const {};
    }
  }

  /// Efeitos da condição, um por linha, para a ficha listar.
  List<String> get effects {
    switch (this) {
      case Condition.blinded:
        return const [
          'Não pode ver e falha em qualquer teste que exija visão.',
          'Ataques contra você têm vantagem; seus ataques têm desvantagem.',
        ];
      case Condition.charmed:
        return const [
          'Não pode atacar quem o enfeitiçou nem escolhê-lo como alvo de '
              'efeito mágico prejudicial.',
          'Quem o enfeitiçou tem vantagem em testes para interagir '
              'socialmente com você.',
        ];
      case Condition.deafened:
        return const [
          'Não pode ouvir e falha em qualquer teste que exija audição.',
        ];
      case Condition.frightened:
        return const [
          'Desvantagem em testes e ataques enquanto a fonte do medo estiver '
              'na sua linha de visão.',
          'Não pode se aproximar voluntariamente da fonte do medo.',
        ];
      case Condition.grappled:
        return const [
          'Deslocamento vira zero e você não recebe bônus de deslocamento.',
          'Acaba se quem agarrou ficar incapacitado ou se algo tirar você do '
              'alcance dele.',
        ];
      case Condition.incapacitated:
        return const ['Não pode realizar ações nem reações.'];
      case Condition.invisible:
        return const [
          'Impossível de ver sem magia ou sentido especial; conta como muito '
              'bem escondido para se esconder.',
          'Ataques contra você têm desvantagem; seus ataques têm vantagem.',
        ];
      case Condition.paralyzed:
        return const [
          'Não pode se mover nem falar.',
          'Falha automaticamente em salvaguardas de Força e de Destreza.',
          'Ataques contra você têm vantagem, e acerto a até 1,5 m é crítico.',
        ];
      case Condition.petrified:
        return const [
          'Virou substância sólida inanimada, com o peso multiplicado por dez '
              'e sem envelhecer.',
          'Não pode se mover nem falar, e não percebe o que acontece em '
              'volta.',
          'Falha automaticamente em salvaguardas de Força e de Destreza.',
          'Ataques contra você têm vantagem.',
          'Resistência a todo dano; imune a veneno e doença, e as que já '
              'agiam ficam suspensas.',
        ];
      case Condition.poisoned:
        return const ['Desvantagem em ataques e em testes de atributo.'];
      case Condition.prone:
        return const [
          'Só consegue se arrastar, a menos que gaste movimento para se '
              'levantar.',
          'Desvantagem em ataques.',
          'Ataques contra você têm vantagem a até 1,5 m e desvantagem de '
              'longe.',
        ];
      case Condition.restrained:
        return const [
          'Deslocamento vira zero e você não recebe bônus de deslocamento.',
          'Ataques contra você têm vantagem; seus ataques têm desvantagem.',
          'Desvantagem em salvaguardas de Destreza.',
        ];
      case Condition.stunned:
        return const [
          'Não pode se mover e fala de forma hesitante.',
          'Falha automaticamente em salvaguardas de Força e de Destreza.',
          'Ataques contra você têm vantagem.',
        ];
      case Condition.unconscious:
        return const [
          'Não pode se mover nem falar, e não percebe o que acontece em '
              'volta.',
          'Derruba o que estava segurando.',
          'Falha automaticamente em salvaguardas de Força e de Destreza.',
          'Ataques contra você têm vantagem, e acerto a até 1,5 m é crítico.',
        ];
    }
  }

  /// Devolve a condição do id, ou nulo se o id não existir.
  ///
  /// Nulo em vez de exceção: um id legado ou digitado errado no arquivo
  /// importado não pode tornar o personagem inacessível.
  static Condition? fromId(String? id) {
    if (id == null) return null;
    for (final condition in Condition.values) {
      if (condition.id == id) return condition;
    }
    return null;
  }

  /// Condições ordenadas pelo rótulo em português, que é a ordem esperada
  /// numa ficha brasileira.
  ///
  /// Ordenado uma vez e reaproveitado: `ActiveEffects` percorre esta lista a
  /// cada resolução de efeito e o PDF a usa para desenhar as caixas.
  static List<Condition> get sortedByLabel => _conditionsByLabel;

  /// Ids separados por vírgula, no formato gravado na coluna do banco.
  ///
  /// Mesma abordagem de `CustomBackground.skillIdsAsCsv`: vocabulário pequeno
  /// e fixo, sempre lido e escrito inteiro, então não vale uma tabela filha.
  /// A ordem do enum mantém o CSV estável entre gravações.
  static String toCsv(Set<Condition> conditions) {
    final ordered = Condition.values.where(conditions.contains);
    return ordered.map((item) => item.id).join(',');
  }

  /// Lê o CSV do banco, descartando em silêncio o que não reconhecer.
  static Set<Condition> parseCsv(String? raw) {
    if (raw == null) return const {};

    final result = <Condition>{};
    for (final part in raw.split(',')) {
      final condition = Condition.fromId(part.trim());
      if (condition != null) result.add(condition);
    }

    return result;
  }

  /// Expande o conjunto com as condições implicadas.
  ///
  /// Marcar Inconsciente passa a valer também como Incapacitado e Caído, sem
  /// gravar nada além do que o jogador escolheu: a expansão é derivada, para
  /// desmarcar Inconsciente não deixar sobras.
  static Set<Condition> expand(Set<Condition> conditions) {
    final result = <Condition>{};

    for (final condition in conditions) {
      result.add(condition);
      result.addAll(condition.implies);
    }

    return result;
  }
}

/// Cache da ordem alfabética das condições.
///
/// A ordem de declaração do enum NÃO é alfabética, e não pode ser: ela é o que
/// mantém estável o CSV gravado por `toCsv`. Por isso a lista de exibição é
/// derivada aqui em vez de reordenar o enum.
final List<Condition> _conditionsByLabel = sortedByDisplayName(
  Condition.values,
  name: (item) => item.label,
  id: (item) => item.id,
);
