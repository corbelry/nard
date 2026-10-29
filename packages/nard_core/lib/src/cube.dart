import 'side.dart';

/// The doubling cube (Short Nard). Immutable.
class DoublingCube {
  const DoublingCube({this.value = 1, this.owner});

  /// Current stake multiplier (1, 2, 4, ...).
  final int value;

  /// The side that may redouble; null while the cube is centred.
  final Side? owner;

  static const DoublingCube initial = DoublingCube();

  bool get isCentered => owner == null;

  /// Whether the cube has been turned at least once (Jacoby rule).
  bool get isTurned => value > 1;

  /// Whether [side] has access to the cube.
  bool isAvailableTo(Side side) => owner == null || owner == side;

  /// The cube after [taker] accepts a double.
  DoublingCube doubledTo(Side taker) =>
      DoublingCube(value: value * 2, owner: taker);

  Map<String, Object?> toJson() => {'value': value, 'owner': owner?.name};

  static DoublingCube fromJson(Map<String, Object?> json) => DoublingCube(
    value: json['value']! as int,
    owner:
        json['owner'] == null
            ? null
            : Side.values.byName(json['owner']! as String),
  );

  @override
  bool operator ==(Object other) =>
      other is DoublingCube && other.value == value && other.owner == owner;

  @override
  int get hashCode => Object.hash(value, owner);

  @override
  String toString() => 'Cube($value, ${owner?.name ?? 'centered'})';
}
