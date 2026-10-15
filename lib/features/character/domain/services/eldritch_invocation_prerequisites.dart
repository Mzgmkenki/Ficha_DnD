import 'package:dnd_ficha_app/features/compendium/domain/entities/eldritch_invocation_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/pact_boon.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/eldritch_invocation_catalog.dart';

/// Que tipo de exigência não foi cumprida.
///
/// O tipo existe separado da mensagem para a interface poder agrupar e testar
/// sem comparar texto: teste que casa string de interface quebra na primeira
/// revisão de redação, e a razão do bloqueio é regra, não copy.
enum InvocationBlockKind {
  /// O personagem não tem nível nenhum na classe Bruxo.
  notWarlock('not_warlock'),

  /// Falta nível NA CLASSE BRUXO.
  warlockLevel('warlock_level'),

  /// Falta a Dádiva do Pacto exigida, ou ela ainda não foi escolhida.
  pactBoon('pact_boon'),

  /// Falta o truque exigido.
  cantrip('cantrip'),

  /// Falta a magia exigida.
  spell('spell'),

  /// Falta a magia Hex ou uma característica de Bruxo que amaldiçoe.
  curseSource('curse_source'),

  /// Falta outra invocação que esta exige.
  requiredInvocation('required_invocation'),

  /// Outra invocação já selecionada impede esta.
  incompatible('incompatible'),

  /// O id selecionado não existe mais no catálogo.
  unknownInvocation('unknown_invocation');

  const InvocationBlockKind(this.id);

  final String id;
}

/// Uma exigência não cumprida, com o motivo pronto para a ficha mostrar.
class InvocationBlock {
  const InvocationBlock({required this.kind, required this.message});

  final InvocationBlockKind kind;

  /// Frase completa, como a tela exibe: `Requer Bruxo de nível 5.`
  final String message;

  @override
  String toString() => message;
}

/// O que o personagem tem, no formato que a regra de invocação consulta.
///
/// Tudo aqui é propriedade ESTRUTURADA, nunca nome visível: nível na classe
/// Bruxo, id da Dádiva do Pacto, nomes normalizados de magia conhecida e ids
/// de invocação já selecionada. Montar este registro é a única parte que
/// precisa conhecer o personagem e o compêndio; a partir daqui a regra é
/// aritmética sobre conjuntos.
class WarlockProfile {
  const WarlockProfile({
    required this.warlockLevel,
    this.pactBoon,
    this.knownSpellKeys = const {},
    this.hasCurseFeature = false,
    this.selectedInvocationIds = const {},
  });

  /// Perfil de quem não tem nível de Bruxo.
  static const WarlockProfile none = WarlockProfile(warlockLevel: 0);

  /// Nível NA CLASSE BRUXO.
  ///
  /// Nunca o nível total do personagem: um Guerreiro 10 / Bruxo 2 tem nível
  /// total 12 e nível de Bruxo 2, e é o 2 que decide o que ele pode escolher.
  final int warlockLevel;

  /// Dádiva do Pacto escolhida, quando já foi escolhida.
  final PactBoon? pactBoon;

  /// Nomes normalizados das magias e truques que o personagem conhece.
  ///
  /// Guarda nome, e não id numérico, porque o pré-requisito do livro é escrito
  /// por nome (`eldritch blast`, `hex`) e porque o id da magia vem do asset de
  /// terceiros — amarrar a regra a ele deixaria o pré-requisito à mercê de uma
  /// renumeração do compêndio. Cada magia entra pelos dois nomes, o original e
  /// o traduzido, para o pré-requisito casar em qualquer um.
  final Set<String> knownSpellKeys;

  /// Se o personagem tem uma característica de Bruxo que amaldiçoa um alvo.
  ///
  /// Em 2014 é a Maldição da Lâmina, de A Lâmina Maldita. Fica como booleano
  /// porque a origem é declarada no asset (etiqueta `maldicao` na subclasse) e
  /// o validador não precisa conhecer subclasse nenhuma.
  final bool hasCurseFeature;

  /// Ids das invocações já selecionadas.
  final Set<String> selectedInvocationIds;

  bool get isWarlock => warlockLevel > 0;

  /// Se o personagem conhece a magia ou o truque, por nome ou por id de
  /// pré-requisito (`eldritch_blast` casa com `Eldritch Blast`).
  bool knows(String nameOrId) {
    final key = EldritchInvocationEntry.normalizeName(nameOrId);
    if (key.isEmpty) return false;
    return knownSpellKeys.contains(key);
  }

  WarlockProfile copyWith({
    int? warlockLevel,
    PactBoon? pactBoon,
    Set<String>? knownSpellKeys,
    bool? hasCurseFeature,
    Set<String>? selectedInvocationIds,
  }) {
    return WarlockProfile(
      warlockLevel: warlockLevel ?? this.warlockLevel,
      pactBoon: pactBoon ?? this.pactBoon,
      knownSpellKeys: knownSpellKeys ?? this.knownSpellKeys,
      hasCurseFeature: hasCurseFeature ?? this.hasCurseFeature,
      selectedInvocationIds:
          selectedInvocationIds ?? this.selectedInvocationIds,
    );
  }
}

/// Decide, num lugar só, se o personagem cumpre os pré-requisitos de uma
/// Invocação Mística.
///
/// É a camada de DOMÍNIO da validação, e é de propósito que ela não saiba nada
/// de interface. A tela de seleção desabilita opção porque este validador
/// disse que está bloqueada, e não o contrário: se a decisão morasse no
/// widget, qualquer outro caminho de escrita — importar ficha, subir de nível,
/// trocar de subclasse, editar à mão — entraria sem validação nenhuma.
///
/// Também é aqui que mora o motivo em texto. A tela não remonta a frase a
/// partir dos campos do pré-requisito, porque duas telas montariam duas
/// frases diferentes para a mesma regra.
class EldritchInvocationPrerequisites {
  const EldritchInvocationPrerequisites._();

  /// Etiqueta que marca, no asset, a subclasse cuja característica amaldiçoa.
  ///
  /// Declarada aqui porque é vocabulário de regra, e lida da subclasse para o
  /// validador não carregar uma lista de ids de subclasse no código.
  static const String curseFeatureTag = 'maldicao';

  /// Tudo o que falta para o personagem poder escolher [invocation].
  ///
  /// Lista vazia significa disponível. A ordem é estável e vai do pré-requisito
  /// mais estrutural para o mais circunstancial, porque é nessa ordem que o
  /// jogador consegue agir: nível antes de pacto, pacto antes de magia.
  static List<InvocationBlock> evaluate({
    required EldritchInvocationEntry invocation,
    required WarlockProfile profile,
    EldritchInvocationCatalog? catalog,
  }) {
    final blocks = <InvocationBlock>[];
    final pre = invocation.prerequisites;

    if (!profile.isWarlock) {
      blocks.add(
        const InvocationBlock(
          kind: InvocationBlockKind.notWarlock,
          message: 'Requer níveis na classe Bruxo.',
        ),
      );
      // Sem nível de Bruxo nenhum, repetir cada exigência seria ruído: o
      // jogador não cumpre nada porque não é Bruxo, e essa é a frase útil.
      return List<InvocationBlock>.unmodifiable(blocks);
    }

    final requiredLevel = pre.warlockLevel;
    if (requiredLevel != null && profile.warlockLevel < requiredLevel) {
      blocks.add(
        InvocationBlock(
          kind: InvocationBlockKind.warlockLevel,
          message: 'Requer Bruxo de nível $requiredLevel.',
        ),
      );
    }

    final requiredBoon = pre.pactBoon;
    if (requiredBoon != null && profile.pactBoon != requiredBoon) {
      blocks.add(
        InvocationBlock(
          kind: InvocationBlockKind.pactBoon,
          message: 'Requer ${requiredBoon.label}.',
        ),
      );
    }

    final requiredCantrip = pre.cantrip;
    if (requiredCantrip != null && !profile.knows(requiredCantrip)) {
      blocks.add(
        InvocationBlock(
          kind: InvocationBlockKind.cantrip,
          message: 'Requer o truque ${_cantripLabel(requiredCantrip)}.',
        ),
      );
    }

    // Hex OU característica que amaldiçoa: é uma alternativa, e por isso não
    // dá para expressá-la como dois pré-requisitos separados.
    if (pre.requiresCurseSource) {
      final hasHex = profile.knows(pre.spell ?? 'hex');
      if (!hasHex && !profile.hasCurseFeature) {
        blocks.add(
          const InvocationBlock(
            kind: InvocationBlockKind.curseSource,
            message:
                'Requer a magia Hex ou uma característica de Bruxo que '
                'amaldiçoe um alvo.',
          ),
        );
      }
    } else {
      final requiredSpell = pre.spell;
      if (requiredSpell != null && !profile.knows(requiredSpell)) {
        blocks.add(
          InvocationBlock(
            kind: InvocationBlockKind.spell,
            message: 'Requer a magia ${_titleCase(requiredSpell)}.',
          ),
        );
      }
    }

    for (final requiredId in pre.invocations) {
      if (profile.selectedInvocationIds.contains(requiredId)) continue;

      blocks.add(
        InvocationBlock(
          kind: InvocationBlockKind.requiredInvocation,
          message:
              'Requer a invocação ${_invocationLabel(requiredId, catalog)}.',
        ),
      );
    }

    for (final forbiddenId in pre.incompatibleWith) {
      if (!profile.selectedInvocationIds.contains(forbiddenId)) continue;

      blocks.add(
        const InvocationBlock(
          kind: InvocationBlockKind.incompatible,
          message: 'Incompatível com uma invocação já selecionada.',
        ),
      );
      // Uma linha basta: o jogador precisa saber que há conflito, e listar
      // cada par incompatível encheria o cartão sem acrescentar decisão.
      break;
    }

    return blocks.isEmpty
        ? const []
        : List<InvocationBlock>.unmodifiable(blocks);
  }

  /// Se o personagem cumpre todos os pré-requisitos de [invocation].
  static bool isMetBy({
    required EldritchInvocationEntry invocation,
    required WarlockProfile profile,
    EldritchInvocationCatalog? catalog,
  }) {
    return evaluate(
      invocation: invocation,
      profile: profile,
      catalog: catalog,
    ).isEmpty;
  }

  /// Nome da invocação exigida, pelo catálogo, com o id como último recurso.
  ///
  /// Mostrar o id cru é ruim, mas é melhor que esconder a exigência: catálogo
  /// não carregado é falha de leitura de asset, não motivo para a tela mentir
  /// que a invocação está disponível.
  static String _invocationLabel(
    String id,
    EldritchInvocationCatalog? catalog,
  ) {
    return catalog?.byId(id)?.name ?? id;
  }

  /// `eldritch_blast` vira `Rajada Mística`, que é como a ficha chama.
  ///
  /// O mapa tem uma entrada só porque, em 2014, Rajada Mística é o único
  /// truque que aparece como pré-requisito de invocação. O resto cai no título
  /// montado a partir do id, em vez de ficar sem rótulo.
  static String _cantripLabel(String id) {
    const labels = <String, String>{'eldritch_blast': 'Rajada Mística'};

    return labels[EldritchInvocationEntry.normalizeName(id).replaceAll(
          ' ',
          '_',
        )] ??
        _titleCase(id);
  }

  static String _titleCase(String value) {
    final words = EldritchInvocationEntry.normalizeName(value).split(' ');

    return [
      for (final word in words)
        if (word.isNotEmpty)
          '${word[0].toUpperCase()}${word.substring(1)}'
        else
          word,
    ].join(' ');
  }
}
