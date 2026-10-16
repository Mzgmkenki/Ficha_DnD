import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:dnd_ficha_app/features/character/application/providers/feature_providers.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/class_level.dart';
import 'package:dnd_ficha_app/features/character/domain/services/special_feature_resolver.dart';
import 'package:dnd_ficha_app/features/compendium/application/providers/class_providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/class_entry.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/feature_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Características de classe e de subclasse, com origem e nível.
///
/// As duas ficam juntas de propósito: numa multiclasse cada classe tem o
/// próprio arquétipo, e separar em outra seção obrigaria o jogador a cruzar as
/// duas listas na cabeça.
///
/// O conteúdo vem do `SpecialFeatureResolver`, e não de um filtro feito aqui.
/// É o que garante que a ficha, o painel de combate e o gerenciamento de CA
/// falem da mesma lista — e que uma característica concedida num nível futuro
/// não apareça antes da hora.
class ClassFeaturesPanel extends ConsumerWidget {
  const ClassFeaturesPanel({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuresAsync = ref.watch(resolvedFeaturesProvider(character));
    final classesAsync = ref.watch(classEntriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título fica no cabeçalho da seção, na ficha.
            if (character.classLevels.isEmpty)
              const Text('Nenhuma classe cadastrada para este personagem.')
            else
              featuresAsync.when(
                data:
                    (features) => classesAsync.when(
                      data: (classes) => _content(context, features, classes),
                      error:
                          (error, _) =>
                              Text('Erro ao carregar classes: $error'),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                    ),
                error:
                    (error, _) =>
                        Text('Erro ao carregar características: $error'),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    ResolvedFeatures features,
    List<ClassEntry> classes,
  ) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final classLevel in character.classLevels) ...[
          Text(
            '${_className(classes, classLevel.classId)} • '
            'Nível ${classLevel.level}',
            style: text.titleSmall,
          ),
          const SizedBox(height: 8),
          ..._blocksFor(context, features, classLevel),
          _SubclassStatus(
            classLevel: classLevel,
            classEntry: _classById(classes, classLevel.classId),
            hasFeatures: features.features.any(
              (item) =>
                  item.classId == classLevel.classId &&
                  item.origin == FeatureOrigin.subclassFeature,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  List<Widget> _blocksFor(
    BuildContext context,
    ResolvedFeatures features,
    ClassLevel classLevel,
  ) {
    final own = features.forClass(classLevel.classId);

    final fromClass = own
        .where((item) => item.origin == FeatureOrigin.classFeature)
        .toList(growable: false);
    final fromSubclass = own
        .where((item) => item.origin == FeatureOrigin.subclassFeature)
        .toList(growable: false);

    final text = Theme.of(context).textTheme;

    return [
      if (fromClass.isEmpty)
        const Text('Nenhuma característica cadastrada para este nível.')
      else
        for (final feature in fromClass) _FeatureRow(feature: feature),
      if (fromSubclass.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(
          // Subcabeçalho porque a origem muda: o jogador precisa saber o que
          // vem da classe e o que vem do arquétipo que ele escolheu.
          fromSubclass.first.originLabel,
          style: text.titleSmall?.copyWith(color: AppColors.onDarkVariant),
        ),
        const SizedBox(height: 4),
        for (final feature in fromSubclass) _FeatureRow(feature: feature),
      ],
    ];
  }

  static String _className(List<ClassEntry> classes, String id) =>
      _classById(classes, id)?.name ?? id;

  static ClassEntry? _classById(List<ClassEntry> classes, String id) {
    for (final item in classes) {
      if (item.id == id) return item;
    }
    return null;
  }
}

/// Uma característica na ficha: nível, nome, texto e o que ela muda.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});

  final ResolvedFeature feature;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final calculated = feature.calculatedEffects;
    final reference = feature.referenceEffects;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${feature.level}º nível — ${feature.name}',
            style: text.labelLarge,
          ),
          if (feature.hasDescription) ...[
            const SizedBox(height: 2),
            Text(feature.description!, style: text.bodySmall),
          ],

          // Característica superada continua listada, com o motivo. Apagá-la
          // faria parecer que o app perdeu algo que o personagem tem.
          if (feature.isSuperseded)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Não está valendo: você já tem esta característica por outra '
                'classe, e a regra de multiclasse não concede a segunda '
                'versão.',
                style: text.bodySmall?.copyWith(color: AppColors.error),
              ),
            ),

          // O que o app calcula sozinho, dito em uma linha. Serve de prova
          // para o jogador: se a CA mudou, foi por causa desta linha.
          for (final effect in calculated)
            if (_effectLabel(effect) case final label?)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  label,
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onDarkVariant,
                  ),
                ),
              ),

          // O que foi declarado mas o app não arbitra. Aparece como nota para
          // o jogador aplicar em mesa, e não como número inventado.
          for (final effect in reference)
            if (effect.note case final note?)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${effect.label ?? 'Aplicar à mão'}: $note',
                  style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
        ],
      ),
    );
  }

  /// Uma frase curta explicando onde o efeito age. Nulo quando não há o que
  /// dizer que a descrição já não diga.
  static String? _effectLabel(FeatureEffect effect) {
    switch (effect.path) {
      case FeatureEffectPaths.armorClassBase:
        final conditions = effect.conditions.descriptions;
        final suffix = conditions.isEmpty ? '' : ' (${conditions.join(', ')})';
        return 'Fórmula alternativa de CA, no gerenciamento de CA$suffix.';
      case FeatureEffectPaths.armorClassBonus:
        return 'Soma na CA.';
      case FeatureEffectPaths.abilityMaximum:
        return effect.label ?? 'Altera o máximo de atributo.';
      case FeatureEffectPaths.abilityBonus:
        // Diz que já está aplicado, e isso é a informação que falta: o número
        // está no atributo, e sem a frase o jogador somaria de novo à mão.
        final names =
            effect.abilities.isEmpty
                ? null
                : effect.abilities.map((ability) => ability.label).join(' e ');
        final applied =
            names == null
                ? 'Aumento já aplicado nos atributos.'
                : 'Já aplicado em $names.';
        return effect.label == null ? applied : '${effect.label} — $applied';
      default:
        return null;
    }
  }
}

/// O estado da subclasse desta linha de classe.
///
/// Só as mensagens: "abre no Nº nível", "ainda não escolhido" e "saiu do
/// compêndio". As características em si são listadas pelo resolvedor, junto
/// com as da classe, para não existirem duas listas da mesma coisa.
class _SubclassStatus extends ConsumerWidget {
  const _SubclassStatus({
    required this.classLevel,
    required this.classEntry,
    required this.hasFeatures,
  });

  final ClassLevel classLevel;
  final ClassEntry? classEntry;

  /// Se o resolvedor já produziu características desta subclasse.
  final bool hasFeatures;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = classEntry;
    if (entry == null) return const SizedBox.shrink();

    final requiredLevel = entry.subclassLevel;
    if (requiredLevel == null) return const SizedBox.shrink();

    final label = entry.subclassLabelOrDefault;
    final text = Theme.of(context).textTheme;

    if (classLevel.level < requiredLevel) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '$label: abre no $requiredLevelº nível.',
          style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
        ),
      );
    }

    final subclassId = classLevel.subclassId;
    if (subclassId == null || subclassId.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '$label ainda não escolhido. Toque em editar classes para definir.',
          style: text.bodySmall?.copyWith(color: AppColors.error),
        ),
      );
    }

    // Escolhida e com características listadas: nada a avisar.
    if (hasFeatures) return const SizedBox.shrink();

    final subclassAsync = ref.watch(subclassByIdProvider(subclassId));

    return subclassAsync.when(
      data: (subclass) {
        if (subclass == null) {
          // Acontece se o compêndio mudar e o id salvo sair da lista.
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$label "$subclassId" não está mais no compêndio.',
              style: text.bodySmall?.copyWith(color: AppColors.error),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${subclass.name}: nenhuma característica liberada até este nível.',
            style: text.bodySmall?.copyWith(color: AppColors.onDarkVariant),
          ),
        );
      },
      error:
          (error, _) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Erro ao carregar $label: $error'),
          ),
      loading:
          () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
    );
  }
}
