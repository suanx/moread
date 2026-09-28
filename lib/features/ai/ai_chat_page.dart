import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/ai/ai_models.dart';
import '../../services/ai/ai_service.dart';
import 'widgets/ai_chapter_scope.dart';

/// AI 问答：就当前章节内容提问，回答附带原文引用。
///
/// 交互说明：进入页面可携带 [initialQuestion]（来自 AI 中心的「直接提问」），
/// 会自动发起一次提问。
class AiChatPage extends ConsumerWidget {
  const AiChatPage({super.key, required this.bookId, this.initialQuestion});

  final String bookId;
  final String? initialQuestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AiChapterScope(
      bookId: bookId,
      title: 'AI 问答',
      builder: (BuildContext context, AiChapterContext ctx) => _ChatView(
        key: ValueKey<String>(ctx.chapter.id),
        ctx: ctx,
        initialQuestion: initialQuestion,
      ),
    );
  }
}

class _ChatView extends ConsumerStatefulWidget {
  const _ChatView({super.key, required this.ctx, this.initialQuestion});

  final AiChapterContext ctx;
  final String? initialQuestion;

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<AiMessage> _messages = <AiMessage>[];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final String? q = widget.initialQuestion;
    if (q != null && q.trim().isNotEmpty) {
      // 首帧后再发送，保证列表已挂载
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(q));
    } else {
      _messages.add(
        AiMessage(
          role: AiMessage.roleAssistant,
          text: '我在读《${widget.ctx.book.title}》的「${widget.ctx.chapter.title}」。'
              '可以直接问我这一章的人物、情节或写法。',
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String raw) async {
    final String q = raw.trim();
    if (q.isEmpty || _sending) return;

    setState(() {
      _messages.add(AiMessage(role: AiMessage.roleUser, text: q));
      _messages.add(
        const AiMessage(
          role: AiMessage.roleAssistant,
          text: '',
          pending: true,
        ),
      );
      _sending = true;
    });
    _ctrl.clear();
    _scrollToEnd();

    try {
      final AiAnswer answer = await ref.read(aiServiceProvider).ask(
            bookTitle: widget.ctx.book.title,
            question: q,
            text: widget.ctx.text,
          );
      if (!mounted) return;
      setState(() {
        _messages[_messages.length - 1] = AiMessage(
          role: AiMessage.roleAssistant,
          text: answer.text,
          references: answer.references,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages[_messages.length - 1] = AiMessage(
          role: AiMessage.roleAssistant,
          text: '生成失败：$e',
        );
      });
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _messages.length,
            itemBuilder: (BuildContext context, int i) =>
                _bubble(_messages[i]),
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    decoration: const InputDecoration(
                      hintText: '就这一章提问…',
                      isDense: true,
                    ),
                    onSubmitted: _send,
                  ),
                ),
                IconButton(
                  onPressed: _sending ? null : () => _send(_ctrl.text),
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  color: AppColors.brand,
                  tooltip: '发送',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubble(AiMessage m) {
    final bool isUser = m.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isUser) ...<Widget>[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.brand : AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppSpacing.radiusMd),
                  topRight: const Radius.circular(AppSpacing.radiusMd),
                  bottomLeft: Radius.circular(
                    isUser ? AppSpacing.radiusMd : AppSpacing.xs,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? AppSpacing.xs : AppSpacing.radiusMd,
                  ),
                ),
              ),
              child: m.pending
                  ? const _TypingIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          m.text,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isUser
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (m.references.isNotEmpty) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  '原文引用',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brand,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                for (final String r in m.references)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      '· $r',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        height: 1.45,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 生成中的三点跳动动画（无第三方依赖）
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext context, Widget? child) {
        final int active = (_ctrl.value * 3).floor() % 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < 3; i++)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i == active
                      ? AppColors.brand
                      : AppColors.textTertiary.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        );
      },
    );
  }
}
