import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OS permission state for push notifications.
enum PushStatus {
  /// No push plugin in this build (the default, ADR-041).
  unsupported,

  /// Not asked yet: the 16.3 pre-prompt may be shown.
  notDetermined,
  granted,
  denied,
}

/// A push the player tapped: `type` and the JSON `data` of the inbox row
/// (FCM data payload, see `SendPushNotification` in the API).
class PushOpen {
  const PushOpen({required this.id, required this.type, this.data = ''});

  final int id;
  final String type;
  final String data;
}

/// The seam for the platform push plugin (ADR-041). The app ships the
/// no-op [NoopPushRegistrar]; a Firebase Messaging implementation can be
/// dropped in by overriding [pushRegistrarProvider] in `main.dart`.
abstract interface class PushRegistrar {
  Future<PushStatus> status();

  /// Shows the OS dialog (iOS / Android 13+); call only after 16.3.
  Future<PushStatus> requestPermission();

  /// The current FCM token, or null without permission / plugin.
  Future<String?> token();

  /// A rotated token (register it again).
  Stream<String> get tokenRefresh;

  /// Pushes the player opened the app from.
  Stream<PushOpen> get opened;

  /// `android` or `ios`.
  String get platform;
}

/// No push plugin: never asks, never has a token. The inbox still works
/// by polling.
class NoopPushRegistrar implements PushRegistrar {
  const NoopPushRegistrar();

  @override
  Future<PushStatus> status() async => PushStatus.unsupported;

  @override
  Future<PushStatus> requestPermission() async => PushStatus.unsupported;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRefresh => const Stream.empty();

  @override
  Stream<PushOpen> get opened => const Stream.empty();

  @override
  String get platform => Platform.isIOS ? 'ios' : 'android';
}

final pushRegistrarProvider = Provider<PushRegistrar>(
  (_) => const NoopPushRegistrar(),
);
