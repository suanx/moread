import 'package:drift/drift.dart';

/// 未支持平台兜底：明确报错，避免静默失败。
QueryExecutor openConnection(String dbName) =>
    throw UnsupportedError('当前平台未提供数据库实现（connection/unsupported.dart）');
