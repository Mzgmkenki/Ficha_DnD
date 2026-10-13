import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SrdAssetSource {
  /// Lê o asset e decodifica como UTF-8 na própria isolate.
  ///
  /// NÃO use `rootBundle.loadString` aqui. A partir de 50 KB ele manda a
  /// decodificação para um isolate pelo `compute`, e esse isolate não é
  /// atendido sob `flutter test`: o `await` nunca volta e a suíte trava sem
  /// erro nenhum. `races.json`, `subclasses.json` e os arquivos de magia já
  /// passam desse tamanho, e `backgrounds.json` passou quando os antecedentes
  /// completos entraram.
  ///
  /// Decodificar aqui é equivalente para o app: cada arquivo é lido uma única
  /// vez e o resultado fica em cache nos providers, e decodificar 100 KB custa
  /// cerca de um milissegundo.
  Future<String> _loadUtf8(String path) async {
    final data = await rootBundle.load(path);

    return utf8.decode(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  Future<List<Map<String, dynamic>>> loadJsonList(String path) async {
    try {
      final raw = await _loadUtf8(path);
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        throw Exception('O conteúdo de $path não é uma lista JSON.');
      }

      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar asset JSON: $path');
      debugPrint('$e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loadRawJson(String path) async {
    try {
      final raw = await _loadUtf8(path);
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        throw Exception('O conteúdo de $path não é um objeto JSON.');
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar asset JSON bruto: $path');
      debugPrint('$e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}