# 墨读 Moread · 架构设计

## 1. 分层与依赖方向

```
┌─────────────────────────────────────────────────────┐
│ features/   页面与交互（Widget / ConsumerStateful）   │
│   shell / bookshelf / book_detail / search / reader  │
│   library / stats / settings / tts                   │
└───────────────▲──────────────▲──────────────────────┘
                │              │
        ┌───────┴──────┐  ┌────┴──────────────────────┐
        │ domain/      │  │ core/  theme router di     │
        │  entities    │  │  error logging storage     │
        │  repositories│  └────────────────────────────┘
        └───────▲──────┘
                │ 实现（依赖倒置：domain 定义接口）
        ┌───────┴──────────────────────────────────────┐
        │ data/        Drift DB + 文件系统 + Dio        │
        │ services/    解析器 / TTS / 导入 / 权限        │
        └──────────────────────────────────────────────┘
```

- `domain` 是纯 Dart，不 import 任何 Flutter / 三方包（除 `core` 工具），
  因此可独立单测、可无痛替换实现；
- `data/services` 只依赖 `domain` 的接口与实体，绝不反向依赖 `features`；
- `features` 只通过 Riverpod Provider 拿到仓储/服务，不直接操作数据库或文件。

## 2. 数据模型

### 2.1 关系图

```
Book 1 ── n Chapter
Book 1 ── 1 ReadingProgress
Book 1 ── n Bookmark
Book 1 ── n Note
Book 1 ── n ReadingSession
Download(在线下载任务) ── n:1 Book
```

### 2.2 表结构（Drift）

| 表 | 主键 | 关键字段 |
| --- | --- | --- |
| `books` | `id` | title, author, format, source, localPath, contentDir, coverPath, totalChars, totalPages, progress, favorite |
| `chapters` | `id` | bookId(FK), idx, title, href, contentPath, startChar, endChar, pageStart, pageEnd, level |
| `reading_progresses` | `bookId`(FK) | chapterId, chapterIndex, chapterRatio, bookRatio, position, page |
| `bookmarks` | `id` | bookId(FK), chapterId, position, chapterRatio, excerpt |
| `notes` | `id` | bookId(FK), chapterId, quote, content, startPos, endPos, color |
| `reading_sessions` | `id` | bookId(FK), startedAt, endedAt, durationSeconds, charsRead, mode(read/listen) |
| `downloads` | `id` | bookId, url, savePath, totalBytes, receivedBytes, status |

### 2.3 文件布局

```
<ApplicationSupport>/
├── books/<bookId>.<ext>        导入的原始文件（复制，非引用）
├── content/<bookId>/           EPUB 解包目录 / TXT 的 book.txt
├── covers/<bookId>.<ext>       封面
├── tts/<bookId>/<chapterId>/   合成出的 MP3 分片 + meta.json（含词边界）
└── temp/                       临时文件，AppPaths.clearTemp() 清理
```

## 3. 核心流程

### 3.1 本地导入

```
FilePicker(多选)
  → PermissionService.ensureImportPermission()
  → BookImporter.import(path)
      ├── 复制到 books/<uuid>.<ext>
      └── ParserRegistry.parserFor(ext).parse(request)
            ├── EpubParser：container.xml → OPF → spine → 解包 → 目录(nav/ncx) → 章节
            ├── TxtParser ：解码 → 章节正则切分 → 写 book.txt → 记录字符区间
            └── PdfParser ：pdfrx 打开 → 页数 → 虚拟分章
  → BookRepository.saveBook(book, chapters)（事务替换章节）
```

### 3.2 打开章节

```
ReaderController.load()
  → BookRepository.getById / getChapters / getProgress
  → BookRepository.loadChapterContent(bookId, chapter)
      ├── EPUB：读 XHTML → 抽 body → 图片转 data URI → ContentHtmlBuilder
      └── TXT ：按 [startChar, endChar) 截取 → 段落化 → ContentHtmlBuilder
  → ContentHtmlBuilder：遍历文本节点按句切分并包裹 <span data-s data-e>
  → ReaderView(WebView) 加载；onLoadStop 后 applySettings + layout + 恢复进度
```

### 3.3 朗读（Edge-TTS）

```
TtsPlayerSheet 打开
  → PermissionService.ensureNotificationPermission()
  → TtsPlaybackController.prepare(...)
      ├── TextUtils.splitForSpeech(text) → List<TtsChunk>（≤1500 字/片）
      ├── 命中缓存（meta.json 签名一致）则复用；否则逐片 synthesize()
      │     EdgeTtsEngine：WebSocket → speech.config → ssml → 收集音频 + WordBoundary
      └── 写 MP3 + meta.json，构建 ConcatenatingAudioSource
  → play() → positionStream → _updateHighlight → highlightChar
  → ReaderPage 监听 highlightChar → ReaderBridge.highlight(char) → WebView 高亮
  → 播放完成 + autoNextChapter → onNextChapter() → 重新 prepare
```

### 3.4 进度计算

全书进度按**字数加权**而非章节数平均：

```
bookRatio = (已读完章节字数 + 当前章节字数 × chapterRatio) / 总字数
```

EPUB 章节未统计字数时退化为 `(chapterIndex + chapterRatio) / 章节数`。

## 4. 关键设计决策

| 决策 | 原因 |
| --- | --- |
| EPUB 图片内联为 data URI | WebView 对 `file://` 跨目录访问限制严格，内联保证离线可用 |
| 不加载 EPUB 自带 CSS | 保证跨书排版一致（微信阅读同样做法） |
| 正文按句包裹 span 并记录字符偏移 | 一份偏移体系同时支撑高亮、划线、搜索、书签 |
| TTS 分片合成 + 落盘缓存 | 长章节不可能一次性合成；缓存后可离线重听、秒开续播 |
| 时长按 48kbps CBR 估算 | 避免为拿时长额外 `load()` 每个分片 |
| 进度写库做 2s 防抖 | 避免翻页高频写库 |
| 阅读会话在 controller dispose 时结算 | 保证切后台/退出都能记录时长 |

## 5. 扩展点

| 想加的东西 | 改哪里 |
| --- | --- |
| 新格式（mobi / docx） | 实现 `BookParser` + 注册到 `ParserRegistry` |
| GBK 编码 | 替换 `TextUtils.decodeBytes` 实现 |
| Azure TTS | 新增 `TtsEngine` 实现并替换 `edgeTtsEngineProvider` |
| 在线书城 | 新增 `data/sources/online/catalog_api.dart` + `SearchPage` 接入 |
| PDF 文本层 | `BookRepositoryImpl.loadChapterText` 的 PDF 分支 |
| 同步/备份 | 新增 `SyncService`，复用 `EntityMapper` 做本地↔远端转换 |
