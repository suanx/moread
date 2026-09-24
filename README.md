# 墨读 Moread

对标微信阅读的**跨平台电子书阅读器**：一套 Flutter 源码覆盖 iOS / Android / Web / 桌面，
内置 EPUB / TXT / PDF 解析、精美阅读器与基于 Edge-TTS 的 AI 听书。

> 当前版本 **v0.1.0（MVP）**：本地导入 + 阅读器 + Edge-TTS 朗读已完整打通；
> 在线书城、PDF 文本层、iOS 签名发布等见 `docs/PLAN.md` 的后续阶段。

---

## 一、跨端框架选型：为什么是 Flutter

| 维度 | Flutter（选定） | React Native | Kotlin Multiplatform |
| --- | --- | --- | --- |
| 一套源码覆盖范围 | iOS / Android / Web / Windows / macOS / Linux | iOS / Android（Web 需另做） | 仅共享逻辑，UI 仍需两端各写 |
| 阅读器排版能力 | 自绘引擎 + CSS 变量，字号/行距/分页像素级可控 | 依赖 WebView/原生组件，跨端一致性差 | 两端各自实现，一致性最差 |
| PDF 渲染 | `pdfrx` 纯 Dart + Skia，全平台一致 | 需各自接入原生 PDF SDK | 同左 |
| 后台音频生态 | `just_audio` + `just_audio_background`（锁屏/通知栏开箱即用） | 需 react-native-track-player，坑多 | 需各端实现 |
| 长列表/网格流畅度 | 自绘，60/120fps 稳定 | Bridge 通信在大列表下有抖动 | 原生，流畅但要写两遍 |
| 桌面端 | 官方支持（macOS / Windows / Linux） | 无官方支持 | 无 |

**结论**：阅读类应用的核心资产是「排版与交互的高度一致性」+「后台音频」，
Flutter 在这两项上是唯一能一套代码同时做好的方案，因此选定 Flutter。

---

## 二、快速开始

```bash
# 1. 安装依赖
flutter pub get

# 2. 生成代码（Drift 数据库需要；每次修改 lib/data/local/db 后都要重跑）
dart run build_runner build --delete-conflicting-outputs

# 3. 运行
flutter run
```

> ⚠️ 本仓库**不包含** `android/`、`ios/`、`web/` 原生工程目录，
> 它们由 CI 用 `flutter create` 脚手架生成（见 `.github/workflows/`），
> 避免脚手架覆盖 `lib/main.dart`。若要在本地跑原生平台，请执行：
>
> ```bash
> flutter create --project-name moread --org com.moread --platforms=android,ios,web /tmp/scaffold
> cp -r /tmp/scaffold/android /tmp/scaffold/ios /tmp/scaffold/web .
> ```

---

## 三、目录结构

```
lib/
├── main.dart                  # 启动引导 + 全局异常捕获
├── app.dart                   # MaterialApp.router / 主题 / JustAudioBackground 初始化
├── core/                      # 与业务无关的基础设施
│   ├── theme/                 # 设计令牌：色彩 / 间距 / 主题 / 阅读主题
│   ├── error/                 # Failure + Result 统一错误模型
│   ├── logging/               # 日志门面
│   ├── storage/               # 私有目录管理（books/content/covers/tts/temp）
│   ├── utils/                 # 文本、时间工具（章节切分、句段切分、编码探测）
│   ├── router/                # go_router 路由表
│   └── di/                    # Riverpod Provider 汇总
├── domain/                    # 领域层（纯 Dart，不依赖 Flutter）
│   ├── entities/              # Book / Chapter / ChapterContent / Progress / Bookmark / Note …
│   └── repositories/          # 仓储抽象接口
├── data/                      # 数据层
│   ├── local/db/              # Drift（SQLite）表定义 + 连接（native/web 条件导入）
│   ├── mappers/               # 行 ↔ 实体映射
│   └── repositories/          # 仓储实现
├── services/                  # 能力层
│   ├── parser/                # EPUB / TXT / PDF 解析器 + 阅读页 HTML 构建器
│   ├── tts/                   # Edge-TTS 协议 / 合成引擎 / 播放控制器
│   ├── import/                # 导入编排（复制 → 解析）
│   └── permissions/           # 权限申请
└── features/                  # 页面层（按功能垂直拆分）
    ├── shell/ bookshelf/ book_detail/ search/ reader/ library/ stats/ settings/ tts/
```

分层依赖严格单向：`features → domain ← data → services`，`domain` 不反向依赖任何层。

---

## 四、MVP 已实现能力

| 模块 | 能力 |
| --- | --- |
| 书架 | 网格展示、封面占位生成、四种排序、下拉刷新、长按删除（含文件清理） |
| 书籍详情 | 封面/元数据/简介/目录预览、收藏、继续阅读 |
| 导入 | 权限申请、EPUB/TXT/PDF 多文件批量导入、逐本结果汇总 |
| 阅读器 | CSS 多列分页 + 滚动双模式、字号/行距/字距/段距/页边距/字体、5 套主题（含护眼/夜间/纯黑）、目录跳转（含搜索）、书签、笔记、进度展示与自动保存 |
| 听书 | Edge-TTS 在线合成、9 种音色、语速/音调/音量、后台播放 + 锁屏控制、定时关闭（渐隐）、断点续播、**文字高亮跟随**、音频分片缓存（离线重听） |
| 统计 | 连续打卡、7 日时长柱状图、读完/在读/笔记数量 |
| 搜索 | 书名/作者过滤 + 书内全文检索；支持粘贴直链下载到本地 |

---

## 五、关键实现说明

### 1. 阅读器分页（EPUB/TXT）

正文统一转成 HTML 后交给 WebView，用 **CSS 多列**做分页：

```
#content { box-sizing:border-box; width:100vw; padding:16px 20px;
           column-width: calc(100vw - 2*20px); column-gap: 40px; }
```

- 每列实际宽 `100vw-2*padX`，列间距 `2*padX` ⇒ 第 k 列左边缘 = `padX + k*100vw`
- 翻页 = `translateX(-k*100vw)`，天然保留左右边距
- 页数 = `round((scrollWidth + padX) / 100vw)`

### 2. 朗读高亮跟随

1. 章节正文按句末标点切成 `<span data-s="起始偏移" data-e="结束偏移">`；
2. 文本按句边界切成 ≤1500 字的分片，逐片调 Edge-TTS；
3. 服务端返回的 `WordBoundary`（100ns tick）换算成毫秒，并在原文中顺序匹配，
   得到**全局字符偏移**；
4. 播放时按 `player.position` 二分查到当前词 → 字符偏移 → `Reader.highlight(offset)`。

### 3. Edge-TTS 协议要点

- `Sec-MS-GEC = upper(sha256("<WindowsFileTime 向下取整到 5 分钟><TrustedClientToken>"))`
- 需要 `Origin: chrome-extension://…` 与浏览器 UA（native 用 `dart:io` WebSocket 自定义 Header；
  Web 端无法设置，故 Web 朗读为「尽力而为」）
- 输出 `audio-24khz-48kbitrate-mono-mp3`（CBR），便于按字节数精确估算时长

> ⚠️ 该接口为微软 Edge 内部接口，仅限自用/学习；商用请替换为 Azure Cognitive Services。

---

## 六、已知限制（后续阶段解决）

1. **TXT 的 GBK/GB18030 编码**：当前为 UTF-8 + latin1 兜底。接入 `charset_converter` 后
   只需替换 `TextUtils.decodeBytes` 的实现即可。
2. **PDF 文本层**：MVP 未抽取文本，因此 PDF 不支持全文检索与逐字高亮（阅读/翻页/目录正常）。
3. **PDF 目录**：当前按固定页数虚拟分章，后续接入 `doc.loadOutline()`。
4. **在线书城**：目前是「粘贴直链下载」，尚未做书城接口与推荐流。
5. **Web 端朗读**：浏览器禁止自定义 Origin/UA，可能合成失败（会给出明确提示）。

---

## 七、CI / 打包

| 工作流 | 触发 | 产物 |
| --- | --- | --- |
| `analyze.yml` | push / PR | `flutter analyze` + `dart format` + `flutter test` |
| `build_android.yml` | push main / tag v* / 手动 | APK（split-per-abi），可选 AAB |
| `build_ios.yml` | push main / tag v* / 手动 | 未签名 IPA（`--no-codesign`） |
| `build_web.yml` | push main | `build/web`，并部署到 GitHub Pages |

所有工作流都会先 `dart run build_runner build` 再编译。

---

## 八、技术栈

状态管理 `flutter_riverpod` · 路由 `go_router` · 数据库 `drift` + sqlite3 ·
网络 `dio` / `web_socket_channel` · 解析 `archive` + `xml` + `html` + `pdfrx` ·
渲染 `flutter_inappwebview` · 音频 `just_audio` + `just_audio_background` + `audio_session` ·
权限 `permission_handler` · 文件选择 `file_picker`

## 九、License

本项目仅供学习与技术验证使用；Edge-TTS 相关调用请遵守微软服务条款。
