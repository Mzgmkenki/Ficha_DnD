import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';

/// A Armadura Natural que uma raça concede, em forma estruturada.
///
/// Por que existe como campo no nível da raça, e não como um item de
/// `RaceEntry.traits`: os traços raciais são texto puro, e dar estrutura a um
/// deles obrigaria a mudar o formato dos outros trezentos. É o mesmo caminho
/// já adotado por `RaceEntry.initiative`, pelo mesmo motivo — e é por isso que
/// a prosa do traço continua em `traits`, intacta, para o resumo da raça e o
/// PDF seguirem mostrando a frase do livro.
///
/// O que estava quebrado antes disto: a Armadura Natural existia SÓ na prosa.
/// `ArmorClassOptions` descobre fórmulas varrendo efeitos com caminho
/// `ac.base`, e texto nunca entra nessa varredura. O resultado era um Tartaruga
/// Bárbaro vendo apenas "10 + Destreza" e a Defesa sem Armadura, sem a CA 17 da
/// carapaça em lugar nenhum.
class RaceNaturalArmor {
  const RaceNaturalArmor({required this.effect, this.forbidsArmor = false});

  /// O efeito de CA-base: a fórmula, as condições e o rótulo exibido.
  ///
  /// Reusa [FeatureEffect] de propósito, e não um formato próprio: é o mesmo
  /// bloco que classe e subclasse declaram, já com parser e testes. Assim a
  /// Armadura Natural entra no sistema de CA como mais uma fórmula alternativa,
  /// sem nenhum caminho especial — e portanto já participa da escolha manual,
  /// da comparação pela maior CA e da persistência da preferência.
  final FeatureEffect effect;

  /// Se a raça NÃO PODE usar armadura vestida.
  ///
  /// Verdadeiro só na Tartaruga, cuja regra é explícita: "Não pode usar
  /// armadura, mas pode usar escudo". É um eixo diferente das condições do
  /// efeito, que descrevem o que a fórmula EXIGE da armadura vestida; aqui a
  /// questão é a armadura não poder valer de jeito nenhum.
  ///
  /// Separado também para não virar regra de outras raças: Povo-Lagarto,
  /// Thri-kreen e Loxodon vestem armadura normalmente, e para elas a Armadura
  /// Natural é só uma alternativa que pode ou não ser melhor.
  final bool forbidsArmor;

  /// Lê o bloco `natural_armor` do asset.
  ///
  /// Aceita as duas formas, para o asset poder declarar o caso simples sem
  /// cerimônia:
  ///
  /// - o mapa do efeito direto;
  /// - um envelope `{ "effect": {...}, "forbids_armor": true }`.
  ///
  /// Devolve nulo quando o bloco não existe ou não traz um efeito legível, que
  /// é o caso da esmagadora maioria das raças. Nulo é o estado normal, não
  /// erro: raça sem Armadura Natural simplesmente não oferece a fórmula.
  static RaceNaturalArmor? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final envelope = raw['effect'];
    final effect = FeatureEffect.tryParse(envelope ?? raw);
    if (effect == null) return null;

    // Só `ac.base` entra. Um bônus avulso declarado aqui por engano seria
    // somado como se fosse fórmula base, e é exatamente o erro que o
    // levantamento de CA proíbe: duas bases nunca se somam.
    if (effect.path != FeatureEffectPaths.armorClassBase) return null;

    // `forbids_armor` é lido do mapa de fora nas duas formas: no envelope ele
    // é irmão de `effect`, e na forma direta é irmão dos campos do efeito.
    return RaceNaturalArmor(
      effect: effect,
      forbidsArmor: raw['forbids_armor'] == true,
    );
  }
}
