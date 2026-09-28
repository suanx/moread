import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moread/app.dart';
import 'package:moread/core/di/providers.dart';
import 'package:moread/domain/entities/book.dart';
import 'package:moread/domain/entities/chapter.dart';
import 'package:moread/domain/entities/note.dart';
import 'package:moread/features/ai/ai_center_page.dart';
import 'package:moread/features/bookshelf/bookshelf_page.dart';
import 'package:moread/features/discover/discover_page.dart';
import 'package:moread/features/notes/notes_page.dart';
import 'package:moread/features/tts/tts_library_page.dart';

/// 页面级冒烟测试（Smoke Test）。
///
/// 目的：把「首屏会不会崩」这件事放进 CI。
/// 之前的灰屏故障在设备上只能看到一块灰色空屏，本地又没有 Flutter 环境，
/// 有了这组测试，任何页面级的 build 异常都会在 CI 日志里带完整堆栈暴露出来。
///
/// 注意：这里只覆盖「渲染路径」，因此把数据源 provider 直接 override 成固定值，
/// 不触碰 drift / 文件系统等平台能力（它们在单测环境不可用）。
Book _book(String id, String title, {double progress = 0}) => Book(
      id: id,
      title: title,
      author: '测试作者',
      format: BookFormat.epub,
      source: BookSource.local,
      localPath: '/tmp/$id.epub',
      addedAt: 1735689600000,
      totalChars: 120000,
      progress: progress,
    );

Widget _wrap(List<Override> overrides, Widget child) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('首屏：真实 App（路由 + 主容器 + 发现页）能渲染', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          shelfProvider.overrideWith(
            (Ref ref) => Stream<List<Book>>.value(const <Book>[]),
          ),
        ],
        child: const MoreadApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    // 底部导航与发现页标题都应出现，任一缺失即说明首屏构建异常
    expect(find.text('发现'), findsWidgets);
    expect(find.text('推荐'), findsOneWidget);
  });

  testWidgets('发现页：空书架', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        <Override>[
          shelfProvider.overrideWith(
            (Ref ref) => Stream<List<Book>>.value(const <Book>[]),
          ),
        ],
        const DiscoverPage(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('推荐'), findsOneWidget);
  });

  testWidgets('发现页：有书时渲染继续阅读', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        <Override>[
          shelfProvider.overrideWith(
            (Ref ref) => Stream<List<Book>>.value(<Book>[
              _book('b1', '人间草木', progress: 0.32),
              _book('b2', '山海'),
            ]),
          ),
        ],
        const DiscoverPage(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('继续阅读'), findsOneWidget);
  });

  testWidgets('书架页：编辑模式切换', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        <Override>[
          shelfProvider.overrideWith(
            (Ref ref) => Stream<List<Book>>.value(<Book>[
              _book('b1', '人间草木', progress: 0.5),
              _book('b2', '山海'),
              _book('b3', '长风渡'),
            ]),
          ),
        ],
        const BookshelfPage(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('编辑'), findsOneWidget);

    await tester.tap(find.text('编辑'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('完成'), findsOneWidget);
    expect(find.textContaining('已选'), findsOneWidget);
  });

  testWidgets('听书页：列表渲染', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        <Override>[
          shelfProvider.overrideWith(
            (Ref ref) => Stream<List<Book>>.value(<Book>[
              _book('b1', '人间草木', progress: 0.1),
            ]),
          ),
        ],
        const TtsLibraryPage(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('继续听'), findsWidgets);
  });

  testWidgets('笔记页：分组与筛选', (WidgetTester tester) async {
    final Note note = Note(
      id: 'n1',
      bookId: 'b1',
      chapterId: 'c1',
      chapterTitle: '第一章',
      quote: '这是一段被划线的原文。',
      content: '我的想法',
      createdAt: 1735689600000,
    );
    await tester.pumpWidget(
      _wrap(
        <Override>[
          shelfProvider.overrideWith(
            (Ref ref) => Stream<List<Book>>.value(<Book>[_book('b1', '人间草木')]),
          ),
          allNotesProvider.overrideWith((Ref ref) => Future<List<Note>>.value(<Note>[note])),
        ],
        const NotesPage(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('这是一段被划线的原文'), findsOneWidget);
  });

  testWidgets('AI 中心：能力宫格渲染', (WidgetTester tester) async {
    final Book book = _book('b1', '人间草木');
    await tester.pumpWidget(
      _wrap(
        <Override>[
          bookByIdProvider.overrideWith((Ref ref, String id) => Future<Book?>.value(book)),
          chaptersProvider.overrideWith(
            (Ref ref, String id) => Future<List<Chapter>>.value(<Chapter>[
              Chapter(id: 'c1', bookId: 'b1', index: 0, title: '第一章 初见'),
            ]),
          ),
          chapterTextProvider.overrideWith(
            (Ref ref, ({String bookId, String chapterId}) key) =>
                Future<String>.value('第一章正文内容，用于冒烟测试。'),
          ),
        ],
        const AiCenterPage(bookId: 'b1'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('AI 中心'), findsOneWidget);
    expect(find.text('知识卡片'), findsOneWidget);
  });
}
