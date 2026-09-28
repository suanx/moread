import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logging/app_logger.dart';

/// 开发期错误可见化。
///
/// 背景：release 包中 build 抛异常时，Flutter 只会渲染一个**灰色空块**，
/// 既看不到异常类型也看不到堆栈，设备上排查成本极高（本次白屏/灰屏问题即为此）。
/// 因此这里把 ErrorWidget 替换成可读面板：
/// - 直接显示异常类型、message 与堆栈前若干行；
/// - 提供「复制详情」按钮（写入剪贴板，便于反馈）；
/// 通过 [AppDiagnostics.showErrorsOnScreen] 控制开关，正式对外发版时可关闭。
abstract final class AppDiagnostics {
  /// 是否在界面上直接展示异常详情。
  ///
  /// 内测/联调阶段保持 true；对外正式发版改为 false 即可恢复 Flutter 默认表现。
  static const bool showErrorsOnScreen = true;

  /// 安装全局错误展示。需在 runApp 之前调用。
  static void install() {
    if (!showErrorsOnScreen) return;

    final ErrorWidgetBuilder previous = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // 仍保留日志输出，便于 adb / CI 抓取
      AppLogger.e(
        'ErrorWidget',
        details.exceptionAsString(),
        details.exception,
        details.stack,
      );
      if (kDebugMode) return previous(details);
      return ErrorPanel(
        summary: details.exceptionAsString(),
        stack: details.stack?.toString() ?? '',
        library: details.library ?? '',
        context: details.context?.toDescription() ?? '',
      );
    };
  }
}

/// 可读的错误面板：异常摘要 + 堆栈片段 + 复制。
class ErrorPanel extends StatelessWidget {
  const ErrorPanel({
    super.key,
    required this.summary,
    required this.stack,
    this.library = '',
    this.context = '',
  });

  final String summary;
  final String stack;
  final String library;
  final String context;

  @override
  Widget build(BuildContext context) {
    final List<String> stackLines =
        stack.split('\n').where((String l) => l.trim().isNotEmpty).take(12).toList();

    return Material(
      color: const Color(0xFFFDF6F5),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.bug_report_outlined,
                      color: Color(0xFFD93025), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '界面渲染出错了',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD93025),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Clipboard.setData(
                      ClipboardData(text: _fullText),
                    ),
                    child: const Text('复制详情'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _block('异常', summary.isEmpty ? '(空)' : summary),
              if (library.isNotEmpty) _block('来源', library),
              if (context.isNotEmpty) _block('位置', context),
              if (stackLines.isNotEmpty) _block('堆栈', stackLines.join('\n')),
              const SizedBox(height: 12),
              const Text(
                '把这段信息截图反馈即可精确定位；正式发版可关闭该面板。',
                style: TextStyle(fontSize: 11, color: Color(0xFF8A8F9C)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _fullText =>
      '异常：$summary\n来源：$library\n位置：$context\n堆栈：\n$stack';

  Widget _block(String title, String body) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEADCDC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A8F9C),
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              body,
              style: const TextStyle(fontSize: 12, height: 1.5),
            ),
          ],
        ),
      );
}
