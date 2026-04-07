import 'package:sqflite/sqflite.dart';

abstract class Migration {
  int get version;

  Future<void> execute(DatabaseExecutor db);
}

class CallbackMigration implements Migration {
  const CallbackMigration({
    required this.version,
    required this.callback,
  });

  @override
  final int version;

  final Future<void> Function(DatabaseExecutor db) callback;

  @override
  Future<void> execute(DatabaseExecutor db) => callback(db);
}
