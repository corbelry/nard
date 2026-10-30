/// Zobrist hashing that is identical on the Dart VM and on the web.
///
/// Web integers are only exact up to 2^53 and bitwise operators work on
/// 32 bits, so the key is built from two 32-bit XOR lanes and exposed as a
/// 53-bit integer (21 high bits + 32 low bits).
class Zobrist {
  Zobrist._();

  static const int slotsPerSide = 26;
  static const int maxCount = 15;

  static final List<int> _lo = _table(0x2545F491);
  static final List<int> _hi = _table(0x9E3779B9);
  static final int sideLo = _lo.last;
  static final int sideHi = _hi.last;

  static int _index(int side, int slot, int count) =>
      (side * slotsPerSide + slot) * (maxCount + 1) + count;

  static List<int> _table(int seed) {
    var state = seed;
    int next() {
      var x = state;
      x ^= (x << 13) & 0xFFFFFFFF;
      x ^= x >> 17;
      x ^= (x << 5) & 0xFFFFFFFF;
      state = x & 0xFFFFFFFF;
      return state;
    }

    // One extra entry at the end for the side to move.
    return List<int>.generate(
      2 * slotsPerSide * (maxCount + 1) + 1,
      (_) => next(),
      growable: false,
    );
  }

  /// Hash of [counts] (2 * 26 slot counts) with [blackToMove].
  static int hash(List<int> counts, {required bool blackToMove}) {
    var lo = 0;
    var hi = 0;
    for (var i = 0; i < counts.length; i++) {
      final side = i ~/ slotsPerSide;
      final slot = i % slotsPerSide;
      final idx = _index(side, slot, counts[i]);
      lo ^= _lo[idx];
      hi ^= _hi[idx];
    }
    if (blackToMove) {
      lo ^= sideLo;
      hi ^= sideHi;
    }
    return (hi & 0x1FFFFF) * 0x100000000 + (lo & 0xFFFFFFFF);
  }
}
