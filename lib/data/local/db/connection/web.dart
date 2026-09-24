import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Flutter Web：使用 IndexedDB 作为存储后端（drift 内置实现）。
QueryExecutor openConnection(String dbName) => WebDatabase(dbName);
