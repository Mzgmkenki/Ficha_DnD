import 'package:dnd_ficha_app/core/di/providers.dart';
import 'package:dnd_ficha_app/features/compendium/domain/entities/spell_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final spellEntriesProvider = FutureProvider<List<SpellEntry>>((ref) async {
  final repository = ref.watch(compendiumRepositoryProvider);
  return repository.loadSpells();
});