import "package:test/test.dart";

import "../lib/polybool.dart";

const int xMax = 15;
const int yMax = 15;

void main() {
  var polyBool = PolyBool();
  final combine = polyBool
      .region(
        square(0, 0, 10, 10),
      )
      .combine(
        PointBuilder(0, 4).dY(1).dX(1).dY(1).dX(-1).dY(1).dX(5).dY(-3).points,
      );

  print("union\n${combine.union}");
  print("intersection\n${combine.intersect}");
  print("difference\n${combine.difference}");
  print("difference inversée\n${combine.inverseDifference}");
  print("xor\n${combine.xor}");

  final points = square(0, 0, 10, 10);
  test(
    "union d'un polygone avec lui-même",
    () {
      final r1 = polyBool.region(points);
      final r2 = r1.combine(points);
      expect(r2.union, RegionMatcher(r1));
    },
  );
  test(
    "intersection",
    () {
      final r1 = polyBool.region(points);
      final r2 = r1.combine(square(9, 9, 2, 2));
      expect(
        r2.intersect,
        RegionMatcher(polyBool.region(square(9, 9, 1, 1))),
      );
    },
  );
}

Points square(double x, double y, double width, double height) => [
      Coordinate(x, y),
      Coordinate(x, y + height),
      Coordinate(x + width, y + height),
      Coordinate(x + width, y),
    ];

class PointBuilder {
  PointBuilder(double x, double y) {
    points.add(Coordinate(x, y));
  }

  final points = <Coordinate>[];

  PointBuilder dX(double dx) {
    final last = points.last;
    points.add(Coordinate(last.x + dx, last.y));
    return this;
  }

  PointBuilder dY(double dy) {
    final last = points.last;
    points.add(Coordinate(last.x, last.y + dy));
    return this;
  }

  PointBuilder dXY(double dx, double dy) {
    final last = points.last;
    points.add(Coordinate(last.x + dx, last.y + dy));
    return this;
  }

  PointBuilder to(double x, double y) {
    points.add(Coordinate(x, y));
    return this;
  }
}

class RegionMatcher extends Matcher {
  RegionMatcher(this.region);

  final Region region;

  @override
  bool matches(dynamic item, Map matchState) =>
      item is Region && region == item;

  @override
  Description describe(Description description) =>
      StringDescription("RegionPolygon $region");
}
