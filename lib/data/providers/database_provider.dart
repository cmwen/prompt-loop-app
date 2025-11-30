import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deliberate_practice_app/data/datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

/// Provider for the database instance.
/// This is async because database initialization is async.
final databaseProvider = FutureProvider<Database>((ref) async {
  return DatabaseHelper.database;
});
