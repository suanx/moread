import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// iOS / Android / macOS / Windows / Linux：使用原生 sqlite3。
///
/// - `applyWorkaroundToOpenSqlite3OnOldAndroidVersions()` 解决 Android 旧版本
///   无法直接打开 sqlite3 动态库的问题；
/// - `LazyDatabase` 把真正的打开动作延迟到首次查询，且不会阻塞启动；
/// - `NativeDatabase.createInBackground` 让所有 SQL 跑在独立 isolate。
QueryExecutor openConnection(String dbName) {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // 统一放应用文档目录：path_provider 未导出 getDatabasesPath()，
    // 且文档目录在 iOS 上会被 iCloud 备份，符合用户预期
    final Directory dir = await getApplicationDocumentsDirectory();
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final File file = File(p.join(dir.path, '$dbName.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
