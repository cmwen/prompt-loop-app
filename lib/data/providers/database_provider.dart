import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_loop_app/data/datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

/// Provider for the database helper singleton.
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

/// Provider for the database instance.
/// This is async because database initialization is async.
final databaseProvider = FutureProvider<Database>((ref) async {
  final helper = ref.watch(databaseHelperProvider);
  return helper.database;
});
