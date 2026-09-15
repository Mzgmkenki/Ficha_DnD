import 'package:dnd_ficha_app/core/branding/app_logo.dart';
import 'package:dnd_ficha_app/core/routing/app_navigator.dart';
import 'package:dnd_ficha_app/features/character/application/providers/character_providers.dart';
import 'package:dnd_ficha_app/features/character/data/mappers/character_json_codec.dart';
import 'package:dnd_ficha_app/features/character/domain/entities/character.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

/// Exporta e importa fichas como texto JSON.
///
/// Usa a área de transferência em vez de arquivo: funciona em qualquer
/// plataforma sem plugin, e o jogador pode colar o texto onde quiser (nuvem,
/// mensagem, bloco de notas) para levar a ficha a outro aparelho.
class CharacterTransferPage extends ConsumerStatefulWidget {
  const CharacterTransferPage({super.key});

  @override
  ConsumerState<CharacterTransferPage> createState() =>
      _CharacterTransferPageState();
}

class _CharacterTransferPageState
    extends ConsumerState<CharacterTransferPage> {
  final _importController = TextEditingController();

  String? _exportedJson;
  String? _exportedName;
  bool _importing = false;
  bool _exporting = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charactersAsync = ref.watch(charactersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exportar e importar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: AppLogo(height: 64, opacity: 0.85)),
          const SizedBox(height: 16),
          Text(
            'Exportar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Toque no nome para gerar o texto da ficha, ou no ícone de PDF '
            'para gerar a ficha pronta para imprimir e compartilhar.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          charactersAsync.when(
            data: (characters) => _ExportList(
              characters: characters,
              busy: _exporting,
              onExport: _export,
              onExportPdf: _exportPdf,
            ),
            error: (error, _) => Text('Erro ao carregar personagens: $error'),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          if (_exportedJson != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ficha de ${_exportedName ?? ''} pronta',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _exportedJson!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _copyExported,
                        icon: const Icon(Icons.copy_all_outlined),
                        label: const Text('Copiar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Divider(height: 40),
          Text(
            'Importar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Cole o texto de uma ficha exportada. Ela entra como um '
            'personagem novo: nada é sobrescrito.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _importController,
            decoration: const InputDecoration(
              labelText: 'JSON da ficha',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            minLines: 5,
            maxLines: 12,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _importing ? null : _pasteFromClipboard,
                  icon: const Icon(Icons.paste_outlined),
                  label: const Text('Colar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _importing ? null : _import,
                  icon: _importing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                  label: Text(_importing ? 'Importando...' : 'Importar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _export(Character character) async {
    setState(() => _exporting = true);

    try {
      final json = await ref.read(exportCharacterProvider)(character.id);

      if (!mounted) return;
      setState(() {
        _exportedJson = json;
        _exportedName = character.name;
      });
    } catch (error) {
      if (!mounted) return;
      _showMessage('Erro ao exportar: $error');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportPdf(Character character) async {
    setState(() => _exporting = true);

    try {
      final pdf = await ref.read(exportCharacterPdfProvider)(character.id);
      await Printing.sharePdf(bytes: pdf.bytes, filename: pdf.fileName);
    } catch (error, stackTrace) {
      debugPrint('Falha ao exportar o PDF: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      _showMessage('Erro ao gerar o PDF: $error');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _copyExported() async {
    final json = _exportedJson;
    if (json == null) return;

    await Clipboard.setData(ClipboardData(text: json));

    if (!mounted) return;
    _showMessage('Ficha copiada. Cole onde quiser guardar.');
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;

    if (!mounted) return;

    if (text == null || text.trim().isEmpty) {
      _showMessage('A área de transferência está vazia.');
      return;
    }

    _importController.text = text;
  }

  Future<void> _import() async {
    final source = _importController.text.trim();

    if (source.isEmpty) {
      _showMessage('Cole o texto da ficha antes de importar.');
      return;
    }

    setState(() => _importing = true);

    try {
      final imported = await ref.read(importCharacterProvider)(source);

      if (!mounted) return;
      _importController.clear();
      _showMessage('${imported.name} importado.');
      await AppNavigator.toCharacterSheet(
        context,
        characterId: imported.id,
      );
    } on CharacterImportException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Erro ao importar: $error');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ExportList extends StatelessWidget {
  const _ExportList({
    required this.characters,
    required this.busy,
    required this.onExport,
    required this.onExportPdf,
  });

  final List<Character> characters;
  final bool busy;
  final ValueChanged<Character> onExport;
  final ValueChanged<Character> onExportPdf;

  @override
  Widget build(BuildContext context) {
    if (characters.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nenhum personagem para exportar ainda.'),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < characters.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              title: Text(characters[i].name),
              subtitle: Text('Nível ${characters[i].totalLevel}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Exportar em PDF',
                    onPressed: busy ? null : () => onExportPdf(characters[i]),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                  const Icon(Icons.ios_share_outlined),
                ],
              ),
              enabled: !busy,
              onTap: busy ? null : () => onExport(characters[i]),
            ),
          ],
        ],
      ),
    );
  }
}
