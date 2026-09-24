/// 阅读/听书会话记录，用于阅读统计（时长曲线、连续打卡）。
///
/// 一次进入阅读器 = 一条 session；退出或切后台时结算 [durationSeconds]。
class ReadingSession {
  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.startedAt,
    required this.mode,
    this.endedAt,
    this.durationSeconds = 0,
    this.charsRead = 0,
  });

  final String id;
  final String bookId;
  final int startedAt;
  final int? endedAt;

  /// 累计有效时长（秒）
  final int durationSeconds;

  /// 本次阅读字数增量
  final int charsRead;

  /// read = 阅读；listen = 听书
  final ReadingMode mode;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'bookId': bookId,
        'startedAt': startedAt,
        'endedAt': endedAt,
        'durationSeconds': durationSeconds,
        'charsRead': charsRead,
        'mode': mode.name,
      };

  factory ReadingSession.fromMap(Map<String, dynamic> m) => ReadingSession(
        id: m['id'] as String,
        bookId: m['bookId'] as String,
        startedAt: m['startedAt'] as int? ?? 0,
        endedAt: m['endedAt'] as int?,
        durationSeconds: m['durationSeconds'] as int? ?? 0,
        charsRead: m['charsRead'] as int? ?? 0,
        mode: ReadingMode.values.firstWhere(
          (ReadingMode e) => e.name == m['mode'],
          orElse: () => ReadingMode.read,
        ),
      );

  ReadingSession copyWith({int? endedAt, int? durationSeconds, int? charsRead}) =>
      ReadingSession(
        id: id,
        bookId: bookId,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        charsRead: charsRead ?? this.charsRead,
        mode: mode,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ReadingSession && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

enum ReadingMode { read, listen }

/// 阅读统计聚合结果（首页「我的」页展示）。
class ReadingStats {
  const ReadingStats({
    this.totalReadSeconds = 0,
    this.totalListenSeconds = 0,
    this.daysInARow = 0,
    this.booksFinished = 0,
    this.booksReading = 0,
    this.noteCount = 0,
    this.bookmarkCount = 0,
    this.dailySeconds = const <int, int>{},
  });

  final int totalReadSeconds;
  final int totalListenSeconds;
  final int daysInARow;
  final int booksFinished;
  final int booksReading;
  final int noteCount;
  final int bookmarkCount;

  /// key = 距今天的天数偏移（0=今天，1=昨天...），value = 当日秒数
  final Map<int, int> dailySeconds;
}
