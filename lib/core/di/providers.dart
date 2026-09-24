import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/db/app_database.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../data/repositories/reading_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/tts_repository_impl.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reader_settings.dart';
import '../../domain/entities/reading_session.dart';
import '../../domain/entities/tts_settings.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/reading_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/tts_repository.dart';
import '../../services/import/book_importer.dart';
import '../../services/parser/book_parser.dart';
import '../../services/parser/epub_parser.dart';
import '../../services/parser/parser_registry.dart';
import '../../services/parser/pdf_parser.dart';
import '../../services/parser/txt_parser.dart';
import '../../services/permissions/permission_service.dart';
import '../../services/tts/edge_tts_engine.dart';
import '../../services/tts/tts_playback_controller.dart';
import '../storage/app_paths.dart';

// ===========================================================================
// 基础设施
// ===========================================================================

final Provider<Future<SharedPreferences>> prefsProvider =
    Provider<Future<SharedPreferences>>(
  (Ref ref) => SharedPreferences.getInstance(),
);

final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final Provider<AppPaths> appPathsProvider = Provider<AppPaths>(
  (Ref ref) => AppPaths.instance,
);

final Provider<PermissionService> permissionServiceProvider =
    Provider<PermissionService>((Ref ref) => const PermissionService());

// ===========================================================================
// 解析器 / 导入
// ===========================================================================

final Provider<ParserRegistry> parserRegistryProvider =
    Provider<ParserRegistry>(
  (Ref ref) => ParserRegistry(
    <BookParser>[
      const EpubParser(),
      const TxtParser(),
      const PdfParser(),
    ],
  ),
);

final Provider<BookImporter> bookImporterProvider = Provider<BookImporter>(
  (Ref ref) => BookImporter(
    registry: ref.watch(parserRegistryProvider),
    paths: ref.watch(appPathsProvider),
  ),
);

// ===========================================================================
// 仓储
// ===========================================================================

final Provider<BookRepository> bookRepositoryProvider =
    Provider<BookRepository>(
  (Ref ref) => BookRepositoryImpl(
    db: ref.watch(databaseProvider),
    importer: ref.watch(bookImporterProvider),
    paths: ref.watch(appPathsProvider),
  ),
);

final Provider<ReadingRepository> readingRepositoryProvider =
    Provider<ReadingRepository>(
  (Ref ref) => ReadingRepositoryImpl(db: ref.watch(databaseProvider)),
);

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
  (Ref ref) => SettingsRepositoryImpl(ref.watch(prefsProvider)),
);

// ===========================================================================
// 朗读（Edge-TTS）
// ===========================================================================

final Provider<EdgeTtsEngine> edgeTtsEngineProvider = Provider<EdgeTtsEngine>(
  (Ref ref) => EdgeTtsEngine(),
);

final ChangeNotifierProvider<TtsPlaybackController> ttsControllerProvider =
    ChangeNotifierProvider<TtsPlaybackController>(
  (Ref ref) {
    final TtsPlaybackController c = TtsPlaybackController(
      engine: ref.watch(edgeTtsEngineProvider),
      prefs: ref.watch(prefsProvider),
    );
    ref.onDispose(c.dispose);
    return c;
  },
);

final Provider<TtsRepository> ttsRepositoryProvider = Provider<TtsRepository>(
  (Ref ref) => TtsRepositoryImpl(
    prefs: ref.watch(prefsProvider),
    controller: ref.watch(ttsControllerProvider),
  ),
);

// ===========================================================================
// 偏好设置
// ===========================================================================

/// 阅读排版偏好
final NotifierProvider<ReaderSettingsNotifier, ReaderSettings>
    readerSettingsProvider =
    NotifierProvider<ReaderSettingsNotifier, ReaderSettings>(
  ReaderSettingsNotifier.new,
);

class ReaderSettingsNotifier extends Notifier<ReaderSettings> {
  @override
  ReaderSettings build() {
    _load();
    return const ReaderSettings();
  }

  Future<void> _load() async {
    final ReaderSettings s =
        await ref.read(settingsRepositoryProvider).getReaderSettings();
    state = s;
  }

  Future<void> update(ReaderSettings s) async {
    state = s;
    await ref.read(settingsRepositoryProvider).saveReaderSettings(s);
  }
}

/// 朗读偏好
final NotifierProvider<TtsSettingsNotifier, TtsSettings> ttsSettingsProvider =
    NotifierProvider<TtsSettingsNotifier, TtsSettings>(
  TtsSettingsNotifier.new,
);

class TtsSettingsNotifier extends Notifier<TtsSettings> {
  @override
  TtsSettings build() {
    _load();
    return const TtsSettings();
  }

  Future<void> _load() async {
    state = await ref.read(ttsRepositoryProvider).getSettings();
  }

  Future<void> update(TtsSettings s) async {
    state = s;
    await ref.read(ttsRepositoryProvider).saveSettings(s);
  }
}

// ===========================================================================
// 书架 / 统计
// ===========================================================================

final StreamProvider<List<Book>> shelfProvider = StreamProvider<List<Book>>(
  (Ref ref) => ref.watch(bookRepositoryProvider).watchShelf(),
);

final FutureProvider<ReadingStats> statsProvider =
    FutureProvider<ReadingStats>(
  (Ref ref) => ref.watch(readingRepositoryProvider).getStats(days: 7),
);
