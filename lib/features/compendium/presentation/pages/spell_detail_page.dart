import 'package:dnd_ficha_app/core/extensions/context_extensions.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:flutter/material.dart';

class SpellDetailPage extends StatelessWidget {
  const SpellDetailPage({
    required this.spell,
    super.key,
  });

  final SpellEntry spell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(spell.namePt),
      ),
      body: ListView(
        padding: context.scrollContentPadding(),
        children: [
          Text(
            spell.namePt,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          if (spell.nameOriginal.isNotEmpty)
            Text(
              spell.nameOriginal,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(_levelLabel(spell.level))),
              Chip(label: Text(spell.school)),
              if (spell.ritual) const Chip(label: Text('Ritual')),
              if (spell.concentration) const Chip(label: Text('Concentração')),
              if (spell.isSrd) const Chip(label: Text('SRD')),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Conjuração',
            children: [
              _InfoRow(label: 'Tempo', value: spell.castingTime),
              _InfoRow(label: 'Alcance', value: spell.range),
              _InfoRow(label: 'Componentes', value: spell.components),
              _InfoRow(label: 'Duração', value: spell.duration),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Classes',
            children: [
              Text(
                spell.classes.isEmpty
                    ? 'Nenhuma classe cadastrada.'
                    : spell.classes.join(', '),
              ),
            ],
          ),
          if (spell.subclasses.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Subclasses',
              children: [
                Text(spell.subclasses.join(', ')),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Descrição',
            children: [
              Text(spell.description),
            ],
          ),
          if (spell.upcast != null && spell.upcast!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Em círculos superiores',
              children: [
                Text(spell.upcast!),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Fonte',
            children: [
              _InfoRow(label: 'Livro', value: spell.source),
              _InfoRow(label: 'Página', value: spell.page),
            ],
          ),
        ],
      ),
    );
  }

  String _levelLabel(int level) {
    if (level == 0) return 'Truque';
    return '$levelº círculo';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}