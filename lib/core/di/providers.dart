import 'package:dnd_ficha_app/core/database/app_database.dart';
import 'package:dnd_ficha_app/core/routing/app_router.dart';
import 'package:dnd_ficha_app/core/utils/dice_roller.dart';
import 'package:dnd_ficha_app/features/character/data/repositories/character_repository_impl.dart';
import 'package:dnd_ficha_app/features/character/domain/repositories/character_repository.dart';
import 'package:dnd_ficha_app/features/compendium/data/repositories/compendium_repository_impl.dart';
import 'package:dnd_ficha_app/features/compendium/data/sources/srd_asset_source.dart';
import 'package:dnd_ficha_app/features/compendium/domain/repositories/compendium_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRouterProvider = Provider<AppRouter>((ref) => AppRouter());

/// Rolador de dados do app. Fica num provider para os testes poderem trocar
/// o `Random` por uma sequência fixa.
final diceRollerProvider = Provider<DiceRoller>((ref) => DiceRoller());

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return CharacterRepositoryImpl(database);
});

final srdAssetSourceProvider = Provider<SrdAssetSource>((ref) {
  return SrdAssetSource();
});

final compendiumRepositoryProvider = Provider<CompendiumRepository>((ref) {
  final source = ref.watch(srdAssetSourceProvider);
  return CompendiumRepositoryImpl(source);
});