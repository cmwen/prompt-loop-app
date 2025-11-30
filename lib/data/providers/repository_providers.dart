import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deliberate_practice_app/data/providers/database_provider.dart';
import 'package:deliberate_practice_app/data/repositories/skill_repository_impl.dart';
import 'package:deliberate_practice_app/data/repositories/task_repository_impl.dart';
import 'package:deliberate_practice_app/data/repositories/practice_repository_impl.dart';
import 'package:deliberate_practice_app/data/repositories/purpose_repository_impl.dart';
import 'package:deliberate_practice_app/data/repositories/settings_repository_impl.dart';
import 'package:deliberate_practice_app/domain/repositories/skill_repository.dart';
import 'package:deliberate_practice_app/domain/repositories/task_repository.dart';
import 'package:deliberate_practice_app/domain/repositories/practice_repository.dart';
import 'package:deliberate_practice_app/domain/repositories/purpose_repository.dart';
import 'package:deliberate_practice_app/domain/repositories/settings_repository.dart';

/// Provider for the skill repository.
final skillRepositoryProvider = FutureProvider<SkillRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return SkillRepositoryImpl(db);
});

/// Provider for the task repository.
final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return TaskRepositoryImpl(db);
});

/// Provider for the practice repository.
final practiceRepositoryProvider = FutureProvider<PracticeRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return PracticeRepositoryImpl(db);
});

/// Provider for the purpose repository.
final purposeRepositoryProvider = FutureProvider<PurposeRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return PurposeRepositoryImpl(db);
});

/// Provider for the settings repository.
final settingsRepositoryProvider = FutureProvider<SettingsRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return SettingsRepositoryImpl(db);
});
