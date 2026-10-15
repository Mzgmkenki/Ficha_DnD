import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/skill.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_choices.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_equipment.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/background_personality.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/language_grant.dart';

/// Antecedente (background) do personagem.
///
/// Concede duas proficiências em perícia, idiomas, ferramentas, uma
/// característica narrativa, equipamento e dinheiro inicial, além das tabelas
/// de traços, ideais, vínculos e defeitos.
///
/// Todos os campos acrescentados depois da primeira versão têm valor padrão de
/// propósito: o compêndio é montado à mão em vários testes, e exigir os campos
/// novos quebraria todos eles sem ganho nenhum.
class BackgroundEntry {
  const BackgroundEntry({
    required this.id,
    required this.name,
    required this.skillIds,
    this.description,
    this.languages = 0,
    this.languageGrants = const [],
    this.tools = const [],
    this.featureName,
    this.featureDescription,
    this.startingGold = 0,
    this.source = 'phb',
    this.variantOf,
    this.personality = BackgroundPersonality.none,
    this.startingCurrency = const Currency(),
    this.startingEquipment = const <BackgroundEquipmentItem>[],
    this.equipmentChoices = const <BackgroundEquipmentChoice>[],
    this.skillChoice,
    this.extraChoices = const <BackgroundExtraChoice>[],
    this.featureOptions = const <BackgroundFeatureOption>[],
    this.specialty,
  });

  /// Id reservado para o antecedente montado pelo próprio jogador.
  ///
  /// Não existe no compêndio: as perícias e as características ficam
  /// guardadas no personagem (ver `Character.customBackground`).
  static const String customId = 'custom';

  /// Opção sintética exibida no seletor de antecedentes.
  static const BackgroundEntry customOption = BackgroundEntry(
    id: customId,
    name: 'Antecedente Customizável',
    description: 'Monte o seu próprio antecedente: escolha as perícias e '
        'descreva as características dele.',
    skillIds: [],
    source: 'custom',
  );

  final String id;
  final String name;
  final String? description;

  /// Ids das perícias concedidas (ver [Skill.id]).
  final List<String> skillIds;

  /// Quantidade de idiomas adicionais à escolha do jogador.
  ///
  /// Mantido por compatibilidade: é o campo que o asset sempre teve e o que o
  /// resumo do antecedente exibe. Quando [languageGrants] está vazio, ele é
  /// convertido em vagas de escolha livre — ver `LanguageResolver`.
  final int languages;

  /// O que o antecedente concede em idiomas, em forma estruturada.
  ///
  /// Preenchido quando a concessão não é "N idiomas livres": um antecedente
  /// que dê um idioma fixo, ou restrito a uma lista, declara aqui. Vazio cai
  /// no comportamento de [languages].
  final List<LanguageGrant> languageGrants;

  final List<String> tools;
  final String? featureName;
  final String? featureDescription;

  /// Ouro inicial, mantido do formato antigo do compêndio.
  ///
  /// [startingCurrency] é a forma completa, com as cinco moedas. Este campo
  /// continua existindo porque é o que o dado antigo e os objetos montados em
  /// teste preenchem; use [grantedCurrency] para não ter que escolher entre os
  /// dois na mão.
  final int startingGold;

  final String source;

  /// Id do antecedente-base, quando este é uma variante dele.
  ///
  /// O Espião é variante do Criminoso: muda a narrativa e parte do equipamento,
  /// mas é a mesma estrutura mecânica. Fica registrado para a ficha poder
  /// explicar de onde a variante veio.
  final String? variantOf;

  /// Tabelas de traços, ideais, vínculos e defeitos, já resolvidas.
  ///
  /// Quando o antecedente reaproveita as tabelas de outro, o carregamento
  /// resolve a referência e entrega aqui as tabelas do dono — a tela nunca
  /// precisa saber que houve indireção.
  final BackgroundPersonality personality;

  /// Moedas concedidas pelo antecedente.
  final Currency startingCurrency;

  /// Equipamento concedido automaticamente.
  final List<BackgroundEquipmentItem> startingEquipment;

  /// Escolhas de equipamento previstas, que o jogador resolve por conta.
  final List<BackgroundEquipmentChoice> equipmentChoices;

  /// Perícias que o antecedente deixa escolher, quando existem.
  final BackgroundSkillChoice? skillChoice;

  /// Tabelas auxiliares (tipo de guilda, especialidade, etc.).
  final List<BackgroundExtraChoice> extraChoices;

  /// Características alternativas, quando o antecedente oferece mais de uma.
  final List<BackgroundFeatureOption> featureOptions;

  /// Especialidade fixa, quando a variante já a define (Gladiador).
  final String? specialty;

  /// `true` quando é a opção de antecedente criado pelo jogador.
  bool get isCustom => id == customId;

  /// `true` quando este antecedente é variante de outro.
  bool get isVariant => variantOf != null && variantOf!.trim().isNotEmpty;

  /// Perícias resolvidas para o enum de domínio, ignorando ids inválidos.
  List<Skill> get skills {
    final result = <Skill>[];
    for (final id in skillIds) {
      final skill = Skill.fromId(id);
      if (skill != null) result.add(skill);
    }
    return result;
  }

  /// Moedas que o antecedente realmente concede.
  ///
  /// Usa [startingCurrency] quando preenchida e cai em [startingGold] caso
  /// contrário. A queda existe para o compêndio antigo e para os antecedentes
  /// montados em teste, que só conhecem o ouro.
  Currency get grantedCurrency {
    if (startingCurrency.isNotEmpty) return startingCurrency;
    if (startingGold > 0) return Currency(gold: startingGold);
    return const Currency();
  }

  /// `true` quando há dinheiro a conceder.
  bool get grantsCurrency => grantedCurrency.isNotEmpty;

  /// `true` quando há equipamento a conceder.
  bool get grantsEquipment => startingEquipment.isNotEmpty;
}
