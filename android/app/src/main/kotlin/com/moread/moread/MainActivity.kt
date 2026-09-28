package com.moread.moread

import com.ryanheise.audioservice.AudioServiceActivity

/// 继承 AudioServiceActivity（其本身是 FlutterActivity 的子类）：
/// audio_service 要求宿主 Activity 提供可共享的 FlutterEngine，
/// 普通FlutterActivity 在后台服务唤起引擎时可能判定为 wrongEngine。
class MainActivity : AudioServiceActivity()
