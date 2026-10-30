/// Server endpoints, set with `--dart-define=API_URL=… --dart-define=WS_URL=…`.
/// Defaults reach the docker compose stack from the Android emulator.
abstract final class OnlineConfig {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:18000',
  );
  static const wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://10.0.2.2:18080/ws',
  );
}
