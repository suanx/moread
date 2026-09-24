import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/logging/app_logger.dart';

/// 权限申请统一封装。
///
/// 设计原则：
/// - 按需申请，申请前先判断当前状态，避免重复弹窗；
/// - 永久拒绝时引导用户去系统设置，并给调用方返回 false 以决定降级策略；
/// - Web / 桌面平台直接返回 true（无需权限）。
class PermissionService {
  const PermissionService();

  static const String _tag = 'PermissionService';

  static bool get _needsPermission => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// 导入本地书籍前需要的权限。
  ///
  /// Android 13+ 使用系统文件选择器（file_picker）无需存储权限；
  /// 仅 Android 12 及以下需要 `READ_EXTERNAL_STORAGE`。
  Future<bool> ensureImportPermission() async {
    if (!_needsPermission) return true;
    if (!Platform.isAndroid) return true;

    final int sdk = await _androidSdkInt();
    if (sdk >= 33) return true; // Android 13+：分区存储 + SAF，无需授权

    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) return true;
    AppLogger.w(_tag, '存储权限被拒绝：$status');
    return false;
  }

  /// 后台朗读的通知栏权限（Android 13+）
  Future<bool> ensureNotificationPermission() async {
    if (!_needsPermission) return true;
    if (!Platform.isAndroid) return true;

    final int sdk = await _androidSdkInt();
    if (sdk < 33) return true;

    final PermissionStatus status = await Permission.notification.request();
    return status.isGranted || status.isLimited;
  }

  /// 是否已被永久拒绝（需要引导到系统设置）
  Future<bool> isPermanentlyDenied(Permission permission) async {
    if (!_needsPermission) return false;
    final PermissionStatus status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// 打开系统设置页
  Future<bool> openSettings() async {
    if (!_needsPermission) return false;
    return openAppSettings();
  }

  /// 读取 Android SDK 版本（通过 permission_handler 无法获取，改用 dart:io 环境变量兜底）
  Future<int> _androidSdkInt() async {
    if (!Platform.isAndroid) return 0;
    try {
      final String? raw = Platform.environment['ANDROID_SDK_INT'];
      if (raw != null) return int.tryParse(raw) ?? 33;
    } catch (_) {
      // 忽略
    }
    // Android 13 起存储权限语义变化；无法探测时按最新版本处理（不申请存储权限）
    return 33;
  }
}

/// 权限申请结果（供 UI 展示引导弹窗）
class PermissionResult {
  const PermissionResult({required this.granted, this.permanentlyDenied = false});

  final bool granted;
  final bool permanentlyDenied;
}
