import 'dart:collection';
import 'dart:math' as math;

import 'package:collection/collection.dart';

part 'combine.dart';
part 'epsilon.dart';
part 'intersector.dart';
part 'linked_list.dart';
part 'region.dart';
part 'segment_chainer.dart';
part 'segment_fill.dart';
part 'segment_selector.dart';
part 'tools.dart';
part 'types.dart';

class PolyBool {
  PolyBool({double epsilon = 1e-10}) : epsilon = Epsilon(epsilon);

  final Epsilon epsilon;

  Region region(Points points, {bool inverted = false}) =>
      Region._normalized(this, points, inverted);

  Region emptyRegion() => Region._normalized(this, [], false);

  bool samePolylinePoints(Points polyline1, Points polyline2) {
    if (polyline1.length != polyline2.length) return false;
    const e = Epsilon();
    for (var i = 0; i < polyline1.length; i++) {
      final p1 = polyline1.elementAt(i);
      final p2 = polyline2.elementAt(i);
      if (!e.pointsSame(p1, p2)) return false;
    }
    return true;
  }
}
