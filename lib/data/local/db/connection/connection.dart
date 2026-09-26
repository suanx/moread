// 数据库连接入口（条件导出：native → sqlite3；web → IndexedDB）。
// 新增平台支持时，只需新增对应的 `connection_*.dart` 并在此补一条 `if`。
export 'unsupported.dart'
    if (dart.library.io) 'native.dart'
    if (dart.library.html) 'web.dart';
