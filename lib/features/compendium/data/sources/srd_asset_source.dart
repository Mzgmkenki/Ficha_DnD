import 'dart:convert';

import 'package:flutter/services.dart';

class SrdAssetSource {
  Future<List<Map<String, dynamic>>> loadJsonList(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        throw Exception('O conteúdo de $path não é uma lista JSON.');
      }

      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e, stackTrace) {
      print('Erro ao carregar asset JSON: $path');
      print(e);
      print(stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loadRawJson(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        throw Exception('O conteúdo de $path não é um objeto JSON.');
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e, stackTrace) {
      print('Erro ao carregar asset JSON bruto: $path');
      print(e);
      print(stackTrace);
      rethrow;
    }
  }
}