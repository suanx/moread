/// Edge-TTS 朗读偏好。
class TtsSettings {
  const TtsSettings({
    this.voice = 'zh-CN-XiaoxiaoNeural',
    this.ratePercent = 0,
    this.pitchHz = 0,
    this.volumePercent = 0,
    this.autoNextChapter = true,
    this.sleepTimerMinutes = 0,
    this.highlightFollow = true,
    this.playInBackground = true,
  });

  /// Edge-TTS 音色短名，如 zh-CN-YunxiNeural
  final String voice;

  /// 语速调节百分比（-100 ~ 100）
  final int ratePercent;

  /// 音调调节 Hz（-100 ~ 100）
  final int pitchHz;

  /// 音量调节百分比（-100 ~ 100）
  final int volumePercent;

  /// 本章读完自动播放下一章
  final bool autoNextChapter;

  /// 定时关闭（分钟），0 表示不开启
  final int sleepTimerMinutes;

  /// 朗读时文字高亮跟随
  final bool highlightFollow;

  /// 允许后台播放（锁屏 / 通知栏控制）
  final bool playInBackground;

  TtsSettings copyWith({
    String? voice,
    int? ratePercent,
    int? pitchHz,
    int? volumePercent,
    bool? autoNextChapter,
    int? sleepTimerMinutes,
    bool? highlightFollow,
    bool? playInBackground,
  }) =>
      TtsSettings(
        voice: voice ?? this.voice,
        ratePercent: ratePercent ?? this.ratePercent,
        pitchHz: pitchHz ?? this.pitchHz,
        volumePercent: volumePercent ?? this.volumePercent,
        autoNextChapter: autoNextChapter ?? this.autoNextChapter,
        sleepTimerMinutes: sleepTimerMinutes ?? this.sleepTimerMinutes,
        highlightFollow: highlightFollow ?? this.highlightFollow,
        playInBackground: playInBackground ?? this.playInBackground,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'voice': voice,
        'ratePercent': ratePercent,
        'pitchHz': pitchHz,
        'volumePercent': volumePercent,
        'autoNextChapter': autoNextChapter,
        'sleepTimerMinutes': sleepTimerMinutes,
        'highlightFollow': highlightFollow,
        'playInBackground': playInBackground,
      };

  factory TtsSettings.fromMap(Map<String, dynamic> m) => TtsSettings(
        voice: m['voice'] as String? ?? 'zh-CN-XiaoxiaoNeural',
        ratePercent: m['ratePercent'] as int? ?? 0,
        pitchHz: m['pitchHz'] as int? ?? 0,
        volumePercent: m['volumePercent'] as int? ?? 0,
        autoNextChapter: m['autoNextChapter'] as bool? ?? true,
        sleepTimerMinutes: m['sleepTimerMinutes'] as int? ?? 0,
        highlightFollow: m['highlightFollow'] as bool? ?? true,
        playInBackground: m['playInBackground'] as bool? ?? true,
      );
}

/// Edge-TTS 音色（MVP 内置常用中文/英文音色，完整列表可在运行时扩展）。
class TtsVoice {
  const TtsVoice({
    required this.shortName,
    required this.displayName,
    required this.locale,
    required this.gender,
    this.tags = const <String>[],
  });

  final String shortName;
  final String displayName;
  final String locale;
  final String gender;
  final List<String> tags;

  bool get isChinese => locale.toLowerCase().startsWith('zh');

  /// 内置音色表（覆盖男女声与常见方言，满足 MVP 需求）
  static const List<TtsVoice> builtIn = <TtsVoice>[
    TtsVoice(
      shortName: 'zh-CN-XiaoxiaoNeural',
      displayName: '晓晓 · 女声（温柔）',
      locale: 'zh-CN',
      gender: 'Female',
      tags: <String>['通用', '推荐'],
    ),
    TtsVoice(
      shortName: 'zh-CN-YunxiNeural',
      displayName: '云希 · 男声（清朗）',
      locale: 'zh-CN',
      gender: 'Male',
      tags: <String>['通用', '推荐'],
    ),
    TtsVoice(
      shortName: 'zh-CN-YunyangNeural',
      displayName: '云扬 · 男声（播音）',
      locale: 'zh-CN',
      gender: 'Male',
      tags: <String>['新闻', '有声书'],
    ),
    TtsVoice(
      shortName: 'zh-CN-XiaoyiNeural',
      displayName: '晓伊 · 女声（活泼）',
      locale: 'zh-CN',
      gender: 'Female',
      tags: <String>['小说'],
    ),
    TtsVoice(
      shortName: 'zh-CN-liaoning-XiaobeiNeural',
      displayName: '晓北 · 东北话',
      locale: 'zh-CN-liaoning',
      gender: 'Female',
      tags: <String>['方言'],
    ),
    TtsVoice(
      shortName: 'zh-HK-WanLungNeural',
      displayName: '雲龍 · 粤语',
      locale: 'zh-HK',
      gender: 'Male',
      tags: <String>['方言'],
    ),
    TtsVoice(
      shortName: 'zh-TW-HsiaoChenNeural',
      displayName: '曉臻 · 台湾腔',
      locale: 'zh-TW',
      gender: 'Female',
      tags: <String>['方言'],
    ),
    TtsVoice(
      shortName: 'en-US-JennyNeural',
      displayName: 'Jenny · English',
      locale: 'en-US',
      gender: 'Female',
      tags: <String>['英文'],
    ),
    TtsVoice(
      shortName: 'en-US-GuyNeural',
      displayName: 'Guy · English',
      locale: 'en-US',
      gender: 'Male',
      tags: <String>['英文'],
    ),
  ];
}
