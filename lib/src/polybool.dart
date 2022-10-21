import 'dart:math' as math;

import 'package:collection/collection.dart';

part 'builder.dart';
part 'combine.dart';
part 'epsilon.dart';
part 'intersector.dart';
part 'linked_list.dart';
part 'segment_chainer.dart';
part 'segment_fill.dart';
part 'segment_selector.dart';
part 'tools.dart';
part 'types.dart';

class PolyBool {
  PolyBool({double epsilon = 1e-10}) : epsilon = Epsilon(epsilon);

  final Epsilon epsilon;

  RegionBuilder region(Points points, {bool inverted = false}) =>
      RegionBuilder._normalized(this, points, inverted);
}
