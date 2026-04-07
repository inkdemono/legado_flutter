import 'package:sqflite/sqflite.dart';

import '../../../utils/app_log.dart';
import 'migration.dart';

class MigrationRunner {
  MigrationRunner._();

  static Future<void> run(
    Database db,
    List<Migration> migrations,
    int fromVersion,
    int toVersion,
  ) async {
    final migrationMap = {
      for (final migration in migrations) migration.version: migration,
    };

    for (var version = fromVersion + 1; version <= toVersion; version++) {
      final migration = migrationMap[version];
      if (migration == null) {
        continue;
      }

      await db.transaction((txn) async {
        await migration.execute(txn);
      });
      AppLog.instance.put('数据库迁移 v$version 完成');
    }
  }
}
