# 墨读 Moread · 分阶段开发计划

## 阶段 0：工程骨架（已完成）

- [x] Flutter 工程、`pubspec.yaml`、设计令牌（色彩/间距/圆角/字号）
- [x] 分层骨架：`core / domain / data / services / features`
- [x] Drift 数据库 + native/web 条件导入连接
- [x] 统一错误模型（Failure/Result）与日志门面
- [x] go_router 路由 + 底部三 Tab 容器

## 阶段 1：MVP —— 本地导入 + 阅读器（已完成）

- [x] EPUB 解析（container.xml / OPF / spine / nav / ncx / 封面）
- [x] TXT 解析（编码探测 + 章节正则 + 超长章二次切分）
- [x] PDF 解析（页数 + 虚拟分章）与 `pdfrx` 原生渲染
- [x] `ContentHtmlBuilder`：统一排版 HTML + 句段 span + JS 分页桥接
- [x] 阅读器 UI：翻页/滚动、字号、行距、字距、段距、页边距、字体
- [x] 5 套主题（白天/护眼/纸张/夜间/纯黑）+ 跟随系统深色
- [x] 目录跳转（含目录搜索）、书签、笔记、进度展示与自动保存
- [x] 书架（网格/排序/删除）、书籍详情、导入页、统计页、发现页、设置页

## 阶段 2：MVP —— Edge-TTS 听书（已完成）

- [x] Edge-TTS 协议：`Sec-MS-GEC`、speech.config、SSML、帧解析
- [x] 分片合成 + MP3 落盘缓存 + 签名校验（换音色自动重合成）
- [x] `just_audio` 串联播放 + `just_audio_background` 后台/锁屏控制
- [x] 音色（9 种）/ 语速 / 音调 / 音量
- [x] 定时关闭（最后 10 秒渐隐）、断点续播、自动下一章
- [x] 文字高亮跟随（WordBoundary → 字符偏移 → WebView 高亮）

## 阶段 3：打磨阅读体验（2 周）

- [ ] 仿真翻页动画（`page` 模式接入手势拖拽 + 阴影）
- [ ] 长按选择 → 划线 / 写想法（当前已具备数据层，缺手势与选区菜单）
- [ ] 笔记列表页（跨书聚合、导出 Markdown）
- [ ] TXT 编码：接入 `charset_converter` 支持 GBK / GB18030 / Big5
- [ ] PDF：接入 `doc.loadOutline()` 真实目录、文本层抽取（PDF 全文检索 + 高亮）
- [ ] 阅读页独立亮度调节 + 常亮开关
- [ ] 音量键翻页

## 阶段 4：在线与同步（3 周）

- [ ] 在线书城接口（分类 / 榜单 / 详情 / 搜索）
- [ ] 下载队列：断点续传（`downloads` 表已就绪）、失败重试、后台下载
- [ ] 云端同步：进度 / 书签 / 笔记（账号体系）
- [ ] EPUB CSS 白名单：保留必要的原书排版（诗歌、代码、表格）

## 阶段 5：多端与商业化（2 周）

- [ ] 桌面端（macOS / Windows / Linux）适配：窗口尺寸、快捷键、菜单栏
- [ ] Web 端：阅读器改用 iframe + postMessage 渲染（规避 inappwebview 不支持 Web）
- [ ] iOS 签名与 TestFlight 分发；Android 签名与 Google Play 上架
- [ ] 性能：大部头 EPUB 导入耗时优化（isolate 化）
- [ ] 无障碍：TalkBack / VoiceOver 标签

---

## 每个阶段的验收标准

| 阶段 | 验收 |
| --- | --- |
| 1 | 导入一本 500 页 EPUB ≤ 3s；翻页无白屏；进度保存后冷启动可恢复 |
| 2 | 连续朗读 30 分钟不中断；杀掉 App 再进入可续播；高亮误差 < 1 句 |
| 3 | 划线笔记可跨章聚合导出；GBK TXT 无乱码；PDF 可全文检索 |
| 4 | 断网重连后下载继续；换设备登录进度一致 |
| 5 | 桌面端窗口缩放排版不破版；iOS/Android 均可通过商店审核 |

## 风险与应对

| 风险 | 应对 |
| --- | --- |
| Edge-TTS 接口变更/封禁 | 抽象 `TtsEngine` 接口，可一键切 Azure TTS 或本地 VITS |
| `flutter_inappwebview` / `pdfrx` 版本 API 漂移 | 已封装在 `ReaderView` / `PdfParser` 单点，替换成本低 |
| 大 EPUB（>50MB）解包内存峰值 | 后续改为 isolate + 流式写出 |
| WebView 分页在极端 DPI 下页数误差 | JS 内已做 `Math.round` 兜底，后续可用 Range 精算 |
