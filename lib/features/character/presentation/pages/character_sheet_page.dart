import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/core/routing/app_navigator.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/class_mechanic_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/feature_providers.dart';
import 'package:dnd_ficha_app/features/character/application/providers/invocation_providers.dart';
import 'package:dnd_ficha_app/features/character/application/use_cases/character/level_up_character_class.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/services/class_mechanic_resolver.dart';
import 'package:dnd_ficha_app/features/character/domain/services/subclass_choice.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/ability.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/level_up_class_dialog.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/ability_score_block.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/background_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/character_portrait.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/character_spells_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/class_features_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/class_mechanics_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/collapsible_section.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/combat_panel_button.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/combat_summary_card.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/currency_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/death_saves_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/eldritch_invocations_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/feats_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/inventory_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/languages_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/magic_items_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/racial_traits_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/saving_throws_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/sheet_header_action.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/skills_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/spell_slots_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/spellcasting_summary_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/sheet/weapons_panel.dart';
import 'package:dnd_ficha_app/features/character/presentation/widgets/subclass_choice_dialog.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/subclass_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/services/spell_name_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

class CharacterSheetPage extends ConsumerStatefulWidget {
  const CharacterSheetPage({required this.characterId, super.key});

  final String characterId;

  @override
  ConsumerState<CharacterSheetPage> createState() => _CharacterSheetPageState();
}

class _CharacterSheetPageState extends ConsumerState<CharacterSheetPage> {
  bool? _showSpellcasting;

  /// Trava o atalho enquanto a subida grava, para dois toques rápidos não
  /// virarem dois níveis.
  bool _levelingUp = false;

  /// Trava a exportação: gerar o PDF lê o compêndio inteiro e leva um instante.
  bool _exportingPdf = false;

  /// Se a reconciliação dos aumentos de atributo por característica já rodou
  /// nesta sessão da tela.
  ///
  /// Uma vez só: a operação é idempotente e devolve o mesmo personagem quando
  /// não há nada a mudar, mas repeti-la a cada reconstrução gastaria uma
  /// leitura do compêndio por quadro.
  bool _abilityBonusesReconciled = false;

  @override
  void initState() {
    super.initState();

    // Depois do primeiro quadro, para não gravar durante a construção.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reconcileFeatureAbilityBonuses();
    });
  }

  /// Dá ao personagem já salvo os aumentos de atributo que as características
  /// dele concedem.
  ///
  /// É o que cobre o Bárbaro de 20º nível criado antes do Campeão Primal ser
  /// automatizado: a migração do banco não pode decidir quem recebe, porque
  /// isso exige ler o compêndio e resolver as características pelo nível da
  /// classe. Aqui pode.
  ///
  /// Best-effort de propósito: falhar não impede a ficha de abrir, e a próxima
  /// abertura tenta de novo.
  Future<void> _reconcileFeatureAbilityBonuses() async {
    if (_abilityBonusesReconciled) return;
    _abilityBonusesReconciled = true;

    try {
      final changed = await ref.read(reconcileFeatureAbilityBonusesProvider)(
        widget.characterId,
      );

      // Avisa porque os atributos mudaram sem o jogador ter tocado em nada.
      if (changed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Os aumentos de atributo das suas características de classe '
              'foram aplicados.',
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Falha ao reconciliar aumentos de atributo: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Seções recolhíveis: id da seção → aberta.
  ///
  /// Vive só na sessão, e é decisão consciente. O projeto não tem preferências
  /// locais (não há `shared_preferences` no pubspec), e o único armazenamento é
  /// o banco do personagem — criar tabela e migração para lembrar um booleano
  /// de interface não se paga. Ausente conta como fechada, que é o estado
  /// inicial pedido.
  final Map<String, bool> _openSections = {};

  bool _isOpen(String id) => _openSections[id] ?? false;

  void _setOpen(String id, bool value) {
    setState(() => _openSections[id] = value);
  }

  // Os resumos de Condições e de Recursos moravam aqui. Foram para
  // `CombatPanelSummary`, que alimenta ao mesmo tempo o botão do Painel de
  // combate e os indicadores das abas — duas contas separadas divergiriam.

  /// Resumo do Inventário: quantos itens e quantos estão equipados.
  ///
  /// O peso total não entra: o app não tem tabela de pesos, então a soma só
  /// cobriria os itens em que o jogador digitou o peso à mão e daria a
  /// impressão errada de ser o total carregado.
  String _inventorySummary(Character character) {
    final items = character.inventory;
    if (items.isEmpty) return 'Nenhum item registrado';

    final count = items.length;
    final equipped = items.where((item) => item.equipped).length;
    final label = '$count ${count == 1 ? 'item' : 'itens'}';

    return equipped == 0
        ? label
        : '$label · $equipped equipado'
            '${equipped == 1 ? '' : 's'}';
  }

  /// Resumo de Testes contra a morte: o estado alcançado ou a contagem.
  String _deathSavesSummary(Character character) {
    final saves = character.deathSaves;

    if (saves.isDead) return 'Três falhas: morto';
    if (saves.isStable) return 'Três sucessos: estável';
    if (saves.isNotEmpty) return saves.describe();

    return character.hitPoints.current <= 0
        ? 'A 0 PV: role no começo do turno'
        : 'Nenhum teste registrado';
  }

  /// Indicador do cabeçalho, para o estado não ficar escondido na seção fechada.
  String? _deathSavesBadge(Character character) {
    final saves = character.deathSaves;

    if (saves.isDead) return 'Morto';
    if (saves.isStable) return 'Estável';
    if (character.hitPoints.current <= 0 || saves.isNotEmpty) {
      return 'Morrendo';
    }

    return null;
  }

  /// Resumo de Características raciais: raça e quantas características tem.
  ///
  /// Lê o compêndio de raças, que é um arquivo pequeno e já fica em cache do
  /// Riverpod. Enquanto não chega, o resumo fica vazio em vez de mostrar
  /// "carregando": a seção fechada não precisa de indicador de progresso.
  String? _racialSummary(Character character) {
    final speciesId = character.speciesId;
    if (speciesId == null || speciesId.isEmpty) return 'Nenhuma raça definida';

    final race = ref.watch(raceByIdProvider(speciesId)).value;
    if (race == null) return null;

    final traits = race.traits.length;

    return [
      race.name,
      if (traits == 1)
        '1 característica'
      else if (traits > 1)
        '$traits características',
    ].join(' • ');
  }

  /// Resumo de Características de classe: classe e nível de cada uma.
  ///
  /// Usa a lista de classes que a página já carregou, então não custa leitura
  /// nova. Contar as características exigiria o compêndio de características
  /// por nível, e classe com nível é o que o jogador procura de todo jeito.
  String _classSummary(Character character, List<ClassEntry> classes) {
    if (character.classLevels.isEmpty) return 'Nenhuma classe';

    return character.classLevels
        .map((classLevel) {
          final match = classes.where((item) => item.id == classLevel.classId);
          final name = match.isEmpty ? classLevel.classId : match.first.name;

          return '$name Nv. ${classLevel.level}';
        })
        .join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final characterAsync = ref.watch(characterByIdProvider(widget.characterId));
    final classesAsync = ref.watch(classEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha do personagem'),
        actions: [
          IconButton(
            tooltip: 'Exportar em PDF',
            onPressed: _exportingPdf ? null : _exportPdf,
            icon:
                _exportingPdf
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: characterAsync.when(
        data: (character) {
          if (character == null) {
            return const Center(child: Text('Personagem não encontrado.'));
          }

          return classesAsync.when(
            data: (classes) {
              final isCaster = _isCaster(character, classes);
              _showSpellcasting ??= isCaster;

              return ListView(
                padding: context.scrollContentPadding(),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CharacterPortrait(
                        characterId: character.id,
                        portraitPath: character.portraitPath,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              character.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nível ${character.totalLevel} • Proficiência +${character.proficiencyBonus}',
                            ),
                            // Só aparece quando há alinhamento: uma linha
                            // dizendo "Não definido" em toda ficha antiga seria
                            // ruído no lugar mais nobre da tela.
                            if (character.alignment case final alignment?) ...[
                              const SizedBox(height: 4),
                              Text(
                                alignment.label,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            if (character.playerName != null &&
                                character.playerName!.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Jogador: ${character.playerName}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openIdentityEditor(character),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar identidade',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _SectionHeader(
                    title: 'Classes',
                    actionLabel: 'Editar nível',
                    actionIcon: Icons.upgrade,
                    onPressed:
                        () => AppNavigator.toEditClassLevels(
                          context,
                          character: character,
                        ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SheetHeaderAction(
                      label: _levelingUp ? 'Subindo...' : 'Subir de nível',
                      icon: Icons.arrow_circle_up_outlined,
                      // No teto o botão fica visível mas apagado: some da tela
                      // seria pior, o jogador ia procurar por ele.
                      onPressed:
                          (_levelingUp ||
                                  character.totalLevel >= maxCharacterLevel)
                              ? null
                              : () => _levelUp(character, classes),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        character.classLevels.map((classLevel) {
                          final className = _classNameForId(
                            classes,
                            classLevel.classId,
                          );
                          return Chip(
                            label: Text('$className Nv. ${classLevel.level}'),
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Combate',
                    actionLabel: 'Editar HP',
                    actionIcon: Icons.favorite_border,
                    onPressed:
                        () => AppNavigator.toEditHitPoints(
                          context,
                          character: character,
                        ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SheetHeaderAction(
                      label: 'Calcular CA',
                      icon: Icons.shield_outlined,
                      onPressed:
                          () => AppNavigator.toEditArmorClass(
                            context,
                            character: character,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CombatSummaryCard(character: character),

                  // Logo abaixo do resumo de combate: Ações, Condições e
                  // Recursos saíram daqui para uma tela própria, e este é o
                  // ponto em que o jogador procura por elas.
                  const SizedBox(height: 12),
                  CombatPanelButton(
                    character: character,
                    onPressed:
                        () => AppNavigator.toCombatPanel(
                          context,
                          characterId: character.id,
                        ),
                  ),

                  const SizedBox(height: 16),
                  CollapsibleSection(
                    id: 'weapons',
                    title: 'Armas',
                    summary:
                        character.weapons.isEmpty
                            ? 'Nenhuma arma cadastrada'
                            : '${character.weapons.length} '
                                '${character.weapons.length == 1 ? 'arma' : 'armas'}',
                    isExpanded: _isOpen('weapons'),
                    onExpansionChanged: (value) => _setOpen('weapons', value),
                    child: WeaponsPanel(
                      character: character,
                      onManage:
                          () => AppNavigator.toManageWeapons(
                            context,
                            characterId: character.id,
                          ),
                    ),
                  ),

                  // "Ações em combate", "Condições" e "Recursos e descanso"
                  // saíram daqui: viraram as abas do Painel de combate, aberto
                  // pelo botão acima. Os widgets são os mesmos, não há cópia.
                  const SizedBox(height: 16),
                  CollapsibleSection(
                    id: 'death_saves',
                    title: 'Testes contra a morte',
                    summary: _deathSavesSummary(character),
                    // A 0 PV o indicador não deixa a seção passar despercebida:
                    // é justamente quando ela precisa ser aberta a cada turno.
                    badge: _deathSavesBadge(character),
                    isExpanded: _isOpen('death_saves'),
                    onExpansionChanged:
                        (value) => _setOpen('death_saves', value),
                    child: DeathSavesPanel(character: character),
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Atributos',
                    actionLabel: 'Editar',
                    actionIcon: Icons.tune,
                    onPressed:
                        () => AppNavigator.toEditAbilityScores(
                          context,
                          character: character,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final ability in Ability.values)
                        AbilityScoreBlock(
                          ability: ability,
                          value: character.abilityScores.valueFor(ability),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Proficiências',
                    actionLabel: 'Editar',
                    actionIcon: Icons.verified_outlined,
                    onPressed:
                        () => AppNavigator.toEditProficiencies(
                          context,
                          character: character,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SavingThrowsPanel(character: character),

                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Perícias'),
                  const SizedBox(height: 8),
                  SkillsPanel(character: character),

                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Slots de magia'),
                  const SizedBox(height: 8),
                  SpellSlotsPanel(
                    classLevels: character.classLevels,
                    characterId: character.id,
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Conjuração',
                    actionLabel:
                        _showSpellcasting == true ? 'Ocultar' : 'Mostrar',
                    actionIcon:
                        _showSpellcasting == true
                            ? Icons.expand_less
                            : Icons.expand_more,
                    onPressed: () {
                      setState(() {
                        _showSpellcasting = !(_showSpellcasting ?? false);
                      });
                    },
                  ),
                  if (_showSpellcasting == true) ...[
                    const SizedBox(height: 8),
                    SpellcastingSummaryPanel(
                      character: character,
                      classes: classes,
                    ),
                  ],

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Magias do personagem',
                    actionLabel: 'Gerenciar',
                    actionIcon: Icons.auto_fix_high,
                    onPressed:
                        () => AppNavigator.toManageSpells(
                          context,
                          characterId: character.id,
                        ),
                  ),
                  const SizedBox(height: 8),
                  CharacterSpellsPanel(character: character),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Itens mágicos',
                    actionLabel: 'Gerenciar',
                    actionIcon: Icons.backpack_outlined,
                    onPressed:
                        () => AppNavigator.toManageMagicItems(
                          context,
                          characterId: character.id,
                        ),
                  ),
                  const SizedBox(height: 8),
                  MagicItemsPanel(character: character),

                  const SizedBox(height: 16),
                  CollapsibleSection(
                    id: 'inventory',
                    title: 'Inventário',
                    summary: _inventorySummary(character),
                    isExpanded: _isOpen('inventory'),
                    onExpansionChanged: (value) => _setOpen('inventory', value),
                    child: InventoryPanel(character: character),
                  ),

                  // As moedas ficam logo depois do inventário de propósito: em
                  // mesa comprar e vender é uma coisa só, e o dinheiro inicial
                  // do antecedente entra junto com o equipamento dele.
                  const SizedBox(height: 16),
                  CurrencyPanel(character: character),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Antecedente',
                    actionLabel: 'Editar',
                    actionIcon: Icons.history_edu,
                    onPressed: () => _openIdentityEditor(character),
                  ),
                  const SizedBox(height: 8),
                  BackgroundPanel(
                    backgroundId: character.backgroundId,
                    customBackground: character.customBackground,
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Idiomas',
                    actionLabel: 'Editar',
                    actionIcon: Icons.translate,
                    onPressed:
                        () => AppNavigator.toEditLanguages(
                          context,
                          character: character,
                        ),
                  ),
                  const SizedBox(height: 8),
                  LanguagesPanel(character: character),

                  // Só aparece para quem tem a característica: o filtro é o
                  // limite de invocações do nível de Bruxo, mais a seleção já
                  // gravada. Guerreiro nenhum vê esta seção, e um Bruxo de 1º
                  // nível também não — ele só alcança as invocações no 2º.
                  _EldritchInvocationsSection(character: character),

                  const SizedBox(height: 16),
                  CollapsibleSection(
                    id: 'racial_traits',
                    title: 'Características raciais',
                    summary: _racialSummary(character),
                    isExpanded: _isOpen('racial_traits'),
                    onExpansionChanged:
                        (value) => _setOpen('racial_traits', value),
                    child: RacialTraitsPanel(speciesId: character.speciesId),
                  ),

                  const SizedBox(height: 16),
                  CollapsibleSection(
                    id: 'class_features',
                    title: 'Características de classe',
                    summary: _classSummary(character, classes),
                    isExpanded: _isOpen('class_features'),
                    onExpansionChanged:
                        (value) => _setOpen('class_features', value),
                    child: ClassFeaturesPanel(character: character),
                  ),

                  // Seção própria, logo depois das características: os
                  // recursos de classe são o que o jogador OPERA (escolhe,
                  // liga, gasta), enquanto a seção acima é o que ele LÊ.
                  // Misturar as duas obrigaria a rolar a lista inteira de
                  // características para achar o interruptor da Forma
                  // Estelar.
                  _ClassMechanicsSection(character: character),

                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Talentos'),
                  const SizedBox(height: 8),
                  FeatsPanel(character: character),

                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Anotações',
                    actionLabel: 'Editar',
                    actionIcon: Icons.edit_note,
                    onPressed: () => _openIdentityEditor(character),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        character.notes.isEmpty
                            ? 'Sem anotações ainda.'
                            : character.notes,
                      ),
                    ),
                  ),
                ],
              );
            },
            error: (error, stackTrace) {
              return Center(child: Text('Erro ao carregar classes: $error'));
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, stackTrace) => Center(child: Text('Erro: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _openIdentityEditor(Character character) {
    return AppNavigator.toEditIdentity(context, character: character);
  }

  /// Gera o PDF e entrega ao sistema.
  ///
  /// Usa a folha de compartilhamento em vez de gravar num diretório: o jogador
  /// escolhe onde o arquivo vai parar (nuvem, mensagem, impressora) e o app não
  /// precisa de permissão de escrita nem de um caminho que ele nunca acha.
  Future<void> _exportPdf() async {
    setState(() {
      _exportingPdf = true;
    });

    try {
      final pdf = await ref.read(exportCharacterPdfProvider)(
        widget.characterId,
      );

      await Printing.sharePdf(bytes: pdf.bytes, filename: pdf.fileName);
    } catch (error, stackTrace) {
      debugPrint('Falha ao exportar o PDF: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao gerar o PDF: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _exportingPdf = false;
        });
      }
    }
  }

  /// Atalho de subida de nível.
  ///
  /// Com uma classe só sobe direto. No multiclasse pergunta qual classe recebe
  /// o nível, porque adivinhar erraria justamente no caso em que a escolha
  /// importa.
  Future<void> _levelUp(Character character, List<ClassEntry> classes) async {
    final String? classId;

    if (character.classLevels.length == 1) {
      classId = character.classLevels.single.classId;
    } else {
      classId = await showLevelUpClassDialog(
        context: context,
        totalLevel: character.totalLevel,
        options: character.classLevels
            .map(
              (item) => LevelUpClassOption(
                classId: item.classId,
                className: _classNameForId(classes, item.classId),
                level: item.level,
              ),
            )
            .toList(growable: false),
      );
    }

    if (classId == null) return;
    if (!mounted) return;

    setState(() {
      _levelingUp = true;
    });

    try {
      final subclasses = await ref.read(subclassEntriesProvider.future);
      final spellIndex = await ref.read(spellNameIndexProvider.future);

      final outcome = await ref.read(levelUpCharacterClassProvider)(
        characterId: widget.characterId,
        classId: classId,
        classes: classes,
        subclasses: subclasses,
        spellIndex: spellIndex,
        // Chegar ao 20º nível de Bárbaro soma +4 em Força e Constituição na
        // mesma gravação, e por isso o PV do nível já entra com a Constituição
        // nova.
        abilityBonuses: await ref.read(
          featureAbilityBonusResolverProvider.future,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_levelUpMessage(outcome))));

      // A escolha da subclasse vem depois do aviso, e não em vez dele: o
      // jogador precisa ver que o nível entrou mesmo que feche o diálogo.
      if (outcome.needsSubclassChoice) {
        await _promptSubclass(
          classId: outcome.classId,
          className: outcome.className,
          label: outcome.pendingSubclassLabel!,
          level: outcome.newLevel,
          subclasses: subclasses,
          spellIndex: spellIndex,
        );
      }

      // Invocação depois da subclasse, e nesta ordem de propósito: metade do
      // catálogo depende do patrono, então perguntar a invocação primeiro
      // ofereceria uma lista mais pobre do que a real.
      if (outcome.needsInvocationChoice && mounted) {
        await _promptInvocations(outcome.pendingInvocations);
      }

      // As escolhas de classe vêm por último, e isso importa: subir de nível
      // pode liberar a subclasse, e a subclasse é que traz as mecânicas. Numa
      // ordem invertida, o Guerreiro que acabou de virar Mestre de Batalha não
      // veria as manobras na mesma subida.
      if (mounted) await _promptClassMechanics();
    } catch (error, stackTrace) {
      debugPrint('Falha ao subir de nível: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao subir de nível: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _levelingUp = false;
        });
      }
    }
  }

  /// Oferece a seleção de Invocações Místicas quando a subida abriu vaga.
  ///
  /// Pergunta antes de abrir a tela em vez de empurrar o jogador para dentro
  /// dela: ele acabou de subir de nível e pode querer resolver outra coisa
  /// primeiro. Recusar não perde nada — a vaga continua em aberto, a ficha
  /// mostra quantas são, e a seção de Invocações Místicas leva para a mesma
  /// tela.
  Future<void> _promptInvocations(int pending) async {
    if (!mounted) return;

    final open = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Invocações Místicas'),
          content: Text(
            pending == 1
                ? 'Você pode escolher 1 nova Invocação Mística.'
                : 'Você pode escolher $pending novas Invocações Místicas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Depois'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Escolher agora'),
            ),
          ],
        );
      },
    );

    if (open != true || !mounted) return;

    await AppNavigator.toManageEldritchInvocations(
      context,
      characterId: widget.characterId,
    );
  }

  /// Oferece as escolhas de classe que o novo nível abriu.
  ///
  /// A etapa só aparece quando há pendência: o requisito é explícito em não
  /// apresentar etapa vazia, e um Campeão que subiu para o 4º nível não tem o
  /// que escolher.
  ///
  /// A lista é agrupada por característica responsável, com a quantidade que
  /// falta em cada uma, para o jogador saber o tamanho da decisão antes de
  /// abrir a tela. Recusar não perde nada: a pendência continua marcada na
  /// seção "Recursos de classe".
  Future<void> _promptClassMechanics({int attempt = 0}) async {
    final character = ref.read(characterByIdProvider(widget.characterId)).value;
    if (character == null || !mounted) return;

    final List<ResolvedClassMechanic> pending;
    try {
      pending = await ref.read(pendingClassMechanicsProvider(character).future);
    } catch (error) {
      // Best-effort, como a sincronização de magias: falha de leitura de asset
      // não pode impedir o nível de entrar. A ficha continua mostrando a
      // pendência quando o compêndio voltar a carregar.
      debugPrint('Falha ao resolver escolhas de classe: $error');
      return;
    }

    if (pending.isEmpty || !mounted) return;

    // Escolha declarada obrigatória não aceita "Depois": o 3º nível do
    // Guerreiro Totêmico não existe sem um espírito, e deixar passar produziria
    // uma subclasse pela metade. As outras continuam adiáveis.
    final required = pending
        .where((item) => item.blocksCompletion)
        .toList(growable: false);
    final isRequired = required.isNotEmpty;
    final offered = isRequired ? required : pending;

    final chosen = await showDialog<ResolvedClassMechanic>(
      context: context,
      barrierDismissible: !isRequired,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isRequired ? 'Escolha obrigatória' : 'Escolhas de classe',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRequired
                    ? 'Estas características precisam ser resolvidas agora:'
                    : 'Estas características estão com escolha em aberto:',
              ),
              const SizedBox(height: 8),
              for (final mechanic in offered)
                ListTile(
                  key: ValueKey('level-up-mechanic-${mechanic.id}'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(mechanic.name),
                  subtitle: Text(
                    '${mechanic.originLabel} • '
                    '${mechanic.freeSlots == 1 ? '1 escolha' : '${mechanic.freeSlots} escolhas'}'
                    ' em aberto',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(dialogContext).pop(mechanic),
                ),
            ],
          ),
          actions: [
            if (isRequired)
              FilledButton(
                key: const ValueKey('required-mechanic-resolve'),
                onPressed: () => Navigator.of(dialogContext).pop(offered.first),
                child: const Text('Escolher agora'),
              )
            else
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Depois'),
              ),
          ],
        );
      },
    );

    if (chosen == null || !mounted) return;

    await AppNavigator.toManageClassMechanic(
      context,
      characterId: widget.characterId,
      mechanicId: chosen.id,
    );

    // Obrigatória que voltou sem ser resolvida é oferecida de novo. O limite de
    // repetições evita laço infinito se o jogador insistir em sair, e a
    // pendência continua marcada em vermelho na ficha de qualquer forma.
    if (isRequired && mounted && attempt < 3) {
      await _promptClassMechanics(attempt: attempt + 1);
    }
  }

  /// Abre a escolha de subclasse e grava o que o jogador decidir.
  ///
  /// Sair sem escolher não é erro: a decisão continua em aberto e volta a ser
  /// oferecida na próxima subida e na tela de classes.
  Future<void> _promptSubclass({
    required String classId,
    required String className,
    required String label,
    required int level,
    required List<SubclassEntry> subclasses,
    required SpellNameIndex spellIndex,
  }) async {
    final options = subclasses
        .where((item) => item.classId == classId)
        .toList(growable: false);

    final chosen = await showSubclassChoiceDialog(
      context: context,
      choice: PendingSubclassChoice(
        classId: classId,
        className: className,
        label: label,
        level: level,
      ),
      options: options,
    );

    if (chosen == null || !mounted) return;

    try {
      final syncError = await ref.read(chooseSubclassProvider)(
        characterId: widget.characterId,
        classId: classId,
        subclassId: chosen,
        subclasses: subclasses,
        spellIndex: spellIndex,
      );

      if (!mounted) return;

      var name = chosen;
      for (final option in options) {
        if (option.id == chosen) {
          name = option.name;
          break;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            syncError == null
                ? '$name escolhida para $className.'
                : '$name escolhida, mas as magias da subclasse não entraram; '
                    'use o gerenciador de magias.',
          ),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Falha ao escolher a subclasse: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao escolher a subclasse: $error')),
      );
    }
  }

  String _levelUpMessage(LevelUpOutcome outcome) {
    final parts = <String>[
      '${outcome.className} agora está no nível ${outcome.newLevel} '
          '(total ${outcome.totalLevel}).',
    ];

    // A subclasse não entra aqui: quando fica em aberto, a ficha abre o
    // diálogo de escolha em seguida, e repetir no aviso seria redundante.

    if (outcome.grantsFeat) {
      // A escolha em si é feita na seção Talentos, que é o único lugar que a
      // registra. Dizer onde evita o jogador sair procurando, e evita um
      // segundo fluxo de escolha que poderia divergir daquele.
      parts.add(
        'Este nível dá Incremento no Valor de Atributo ou talento: '
        'escolha na seção Talentos.',
      );
    }

    if (outcome.spellSyncError != null) {
      parts.add(
        'As magias da subclasse não entraram; use o gerenciador de magias.',
      );
    }

    return parts.join(' ');
  }

  /// Usa o compêndio como fonte da verdade.
  ///
  /// Antes havia também uma lista de ids fixa aqui, que ignorava
  /// `ClassEntry.isSpellcaster`: classe nova ou homebrew marcada como
  /// conjuradora no compêndio não aparecia como tal na ficha.
  bool _isCaster(Character character, List<ClassEntry> classes) {
    for (final classLevel in character.classLevels) {
      for (final entry in classes) {
        if (entry.id == classLevel.classId && entry.isSpellcaster) {
          return true;
        }
      }
    }

    return false;
  }

  String _classNameForId(List<ClassEntry> classes, String classId) {
    for (final item in classes) {
      if (item.id == classId) {
        return item.name;
      }
    }
    return classId;
  }
}

/// A seção recolhível de Invocações Místicas, quando o personagem tem a
/// característica.
///
/// Fica num widget próprio porque a decisão de MOSTRAR depende do resolvedor,
/// que é assíncrono: embutir o `when` no meio do `ListView` da ficha faria a
/// lista inteira reconstruir a cada estado de carregamento.
///
/// Enquanto carrega não mostra nada. É o comportamento certo aqui: um
/// esqueleto de seção que some em quem não é Bruxo pisca na ficha de todo
/// mundo.
class _EldritchInvocationsSection extends ConsumerStatefulWidget {
  const _EldritchInvocationsSection({required this.character});

  final Character character;

  @override
  ConsumerState<_EldritchInvocationsSection> createState() =>
      _EldritchInvocationsSectionState();
}

class _EldritchInvocationsSectionState
    extends ConsumerState<_EldritchInvocationsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final resolved =
        ref.watch(resolvedInvocationsProvider(widget.character)).value;

    if (resolved == null) return const SizedBox.shrink();

    // Tem a característica (limite > 0) ou tem seleção gravada. O segundo caso
    // cobre quem perdeu nível de Bruxo: a escolha continua visível, marcada
    // como inválida, em vez de desaparecer.
    final shouldShow = resolved.limit > 0 || resolved.selected.isNotEmpty;
    if (!shouldShow) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 16),
        CollapsibleSection(
          id: 'eldritch_invocations',
          title: 'Invocações Místicas',
          summary: resolved.countLabel,
          badge: switch (resolved) {
            final it when it.hasInvalid => 'invocação inválida',
            final it when it.overLimit > 0 => 'acima do limite',
            final it when it.hasPendingSlots =>
              it.freeSlots == 1
                  ? '1 vaga em aberto'
                  : '${it.freeSlots} vagas em aberto',
            _ => null,
          },
          isExpanded: _expanded,
          onExpansionChanged: (value) => setState(() => _expanded = value),
          child: EldritchInvocationsPanel(character: widget.character),
        ),
      ],
    );
  }
}

/// A seção de recursos de classe, que só aparece para quem tem algum.
///
/// Mesmo critério das Invocações Místicas: sem mecânica alcançada a seção não
/// é mostrada, em vez de ocupar espaço com um cartão vazio. O resumo e o aviso
/// do cabeçalho vêm do resolvedor, então a seção fechada já diz se há escolha
/// pendente.
class _ClassMechanicsSection extends ConsumerStatefulWidget {
  const _ClassMechanicsSection({required this.character});

  final Character character;

  @override
  ConsumerState<_ClassMechanicsSection> createState() =>
      _ClassMechanicsSectionState();
}

class _ClassMechanicsSectionState
    extends ConsumerState<_ClassMechanicsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final resolved =
        ref.watch(resolvedClassMechanicsProvider(widget.character)).value;

    if (resolved == null) return const SizedBox.shrink();

    final visible = resolved.visible;
    if (visible.isEmpty) return const SizedBox.shrink();

    final pending = resolved.pendingPickCount;

    return Column(
      children: [
        const SizedBox(height: 16),
        CollapsibleSection(
          id: 'class_mechanics',
          title: 'Recursos de classe',
          summary: _summary(resolved),
          badge: switch (resolved) {
            final it when it.needsReview => 'revisar',
            _ when pending > 0 =>
              pending == 1
                  ? '1 escolha pendente'
                  : '$pending escolhas pendentes',
            _ => null,
          },
          isExpanded: _expanded,
          onExpansionChanged: (value) => setState(() => _expanded = value),
          child: ClassMechanicsPanel(character: widget.character),
        ),
      ],
    );
  }

  /// Uma linha com a contagem e os modos ligados, para a seção fechada já
  /// dizer o essencial.
  String _summary(ResolvedClassMechanics resolved) {
    final count = resolved.visible.length;
    final active = resolved.activeModes;

    final parts = <String>[
      count == 1 ? '1 recurso' : '$count recursos',
      if (active.isNotEmpty)
        'ativo: ${active.map((item) => item.name).join(', ')}',
    ];

    return parts.join(' • ');
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onPressed,
  });

  final String title;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final hasAction =
        actionLabel != null && actionIcon != null && onPressed != null;

    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (hasAction) ...[
          // A fonte decorativa é larga: sem esta folga o rótulo encosta no
          // título quando o nome da seção é comprido.
          const SizedBox(width: 8),
          SheetHeaderAction(
            label: actionLabel!,
            icon: actionIcon!,
            onPressed: onPressed!,
          ),
        ],
      ],
    );
  }
}
