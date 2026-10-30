import 'messages.dart';

/// Typed reads from a decoded JSON object (internal to this package).
extension JsonRead on Map<String, Object?> {
  T req<T>(String key) {
    final v = this[key];
    if (v is! T) throw ProtocolException('"$key" must be $T');
    return v;
  }

  T? opt<T>(String key) {
    final v = this[key];
    if (v == null) return null;
    if (v is! T) throw ProtocolException('"$key" must be $T');
    return v as T;
  }

  String str(String key, {int max = 256}) {
    final v = req<String>(key);
    if (v.length > max) throw ProtocolException('"$key" is too long');
    return v;
  }

  Map<String, Object?> obj(String key) => req<Map<String, Object?>>(key);
}

/// The enum value of [values] called [name]; [key] names the field.
T readEnum<T extends Enum>(List<T> values, String name, String key) =>
    values.asNameMap()[name] ??
    (throw ProtocolException('"$key" has unknown value $name'));
