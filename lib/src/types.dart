part of "polybool.dart";

mixin CoordinateMixin {
  double get x;

  double get y;

  @override
  String toString() => "($x, $y)";

  @override
  bool operator ==(Object other) =>
      other is Coordinate && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

class Coordinate with CoordinateMixin {
  static const zero = Coordinate(0, 0);

  const Coordinate(this.x, this.y);

  @override
  final double x;

  @override
  final double y;
}

typedef Points = Iterable<Coordinate>;

enum IntersectionPos {
  /// intersection point is before segment's first point
  beforeStart,

  /// intersection point is directly on segment's first point
  atStart,

  /// intersection point is between segment's first and second points (exclusive)
  inSegment,

  /// intersection point is directly on segment's second point
  atEnd,

  /// intersection point is after segment's second point
  afterEnd,
}

class Intersection {
  Intersection({
    required this.pt,
    required this.alongA,
    required this.alongB,
  });

  final Coordinate pt;

  final IntersectionPos alongA;

  final IntersectionPos alongB;
}

class _RegionPolygon {
  _RegionPolygon._({
    required this.regions,
    this.inverted = false,
  }) : assert(!regions.any((r) => r.length < 3));

  final Iterable<Points> regions;

  final bool inverted;

  bool get empty => regions.isEmpty;

  _RegionPolygon invert() =>
      _RegionPolygon._(regions: regions, inverted: !inverted);

  @override
  String toString() => [
        if (inverted) "-",
        "[\n",
        for (final r in regions) "  $r\n",
        "]",
      ].join();

  Points operator [](int index) => regions.elementAt(index);

  @override
  bool operator ==(Object other) {
    if (other is! _RegionPolygon ||
        other.inverted != inverted ||
        other.regions.length != regions.length) {
      return false;
    }
    for (var i = 0; i < regions.length; i++) {
      if (!IterableEquality().equals(
        other.regions.elementAt(i),
        regions.elementAt(i),
      )) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
      inverted,
      regions
          .map((r) => r.fold<int>(0, (p, c) => p + c.hashCode))
          .fold<int>(0, (p, r) => p + r));
}
