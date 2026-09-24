import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import 'reader_controller.dart';

/// 阅读页控制器：按 bookId 隔离，离开页面自动释放并结束阅读会话。
final readerControllerProvider =
    ChangeNotifierProvider.autoDispose.family<ReaderController, String>(
  (ref, bookId) => ReaderController(
    bookId: bookId,
    bookRepository: ref.watch(bookRepositoryProvider),
    readingRepository: ref.watch(readingRepositoryProvider),
  ),
);
