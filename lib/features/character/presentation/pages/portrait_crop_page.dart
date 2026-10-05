import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:dnd_ficha_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Editor 4:3 usado por todos os fluxos de retrato.
///
/// O arquivo salvo já sai no enquadramento final; ficha, lista e PDF não
/// precisam guardar coordenadas de recorte nem reinterpretar gestos depois.
class PortraitCropPage extends StatefulWidget {
  const PortraitCropPage({required this.imageBytes, super.key});

  static const double aspectRatio = 4 / 3;

  final Uint8List imageBytes;

  static Future<Uint8List?> open(
    BuildContext context, {
    required Uint8List imageBytes,
  }) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(
        builder: (_) => PortraitCropPage(imageBytes: imageBytes),
      ),
    );
  }

  @override
  State<PortraitCropPage> createState() => _PortraitCropPageState();
}

class _PortraitCropPageState extends State<PortraitCropPage> {
  final CropController _controller = CropController();

  bool _ready = false;
  bool _cropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enquadrar imagem'),
        leading: IconButton(
          tooltip: 'Cancelar recorte',
          onPressed: _cropping ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Text(
                'Arraste para escolher a área e use dois dedos para ampliar ou reduzir.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Crop(
                    image: widget.imageBytes,
                    controller: _controller,
                    aspectRatio: PortraitCropPage.aspectRatio,
                    initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                      size: 0.9,
                      aspectRatio: PortraitCropPage.aspectRatio,
                    ),
                    interactive: true,
                    fixCropRect: true,
                    radius: 10,
                    baseColor: AppColors.background,
                    maskColor: Colors.black.withValues(alpha: 0.72),
                    progressIndicator: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    onStatusChanged: (status) {
                      if (!mounted) return;
                      final ready = status == CropStatus.ready;
                      if (_ready != ready ||
                          _cropping != (status == CropStatus.cropping)) {
                        setState(() {
                          _ready = ready;
                          _cropping = status == CropStatus.cropping;
                        });
                      }
                    },
                    onCropped: _onCropped,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cropping ? null : _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Redefinir'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          _ready && !_cropping
                              ? () => _controller.crop()
                              : null,
                      icon:
                          _cropping
                              ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.check),
                      label: Text(_cropping ? 'Processando' : 'Confirmar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reset() {
    _controller.image = widget.imageBytes;
  }

  Future<void> _onCropped(CropResult result) async {
    if (!mounted) return;

    switch (result) {
      case CropFailure():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível gerar o recorte.')),
        );
      case CropSuccess(:final croppedImage):
        final accepted = await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Text('Prévia da imagem'),
                content: AspectRatio(
                  aspectRatio: PortraitCropPage.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(croppedImage, fit: BoxFit.cover),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Voltar ao recorte'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Usar imagem'),
                  ),
                ],
              ),
        );

        if (accepted == true && mounted) {
          Navigator.of(context).pop(croppedImage);
        }
    }
  }
}
