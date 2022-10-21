part of "polybool.dart";

class RegionBuilder {
  RegionBuilder._points(
    PolyBool polyBool,
    Points points,
    bool inverted,
  )   : _polyBool = polyBool,
        _segments = _segmentsFromPoints(polyBool, points, inverted);

  RegionBuilder._segments(
    PolyBool polyBool,
    _SegmentList segments,
  )   : _polyBool = polyBool,
        _segments = segments;

  factory RegionBuilder._normalized(
    PolyBool polyBool,
    Points points,
    bool inverted,
  ) {
    final paths = _normalizePath(points.toList(), polyBool.epsilon);
    if (paths.isEmpty) return RegionBuilder._points(polyBool, [], inverted);
    var result = RegionBuilder._points(polyBool, paths.first, inverted);
    for (final path in paths) {
      result = result.combine(path, inverted: inverted).union;
    }
    return result;
  }

  Combine combine(Points points, {bool inverted = false}) {
    final others = _segmentsFromPoints(_polyBool, points, inverted);
    final combined = _combine(_segments, others);
    return Combine._(_polyBool, combined);
  }

  RegionPolygon get polygon {
    if (_polygon == null) {
      final chain = _SegmentChainer(_polyBool.epsilon).chain(_segments);
      final paths = <List<Coordinate>>[];
      for (final path in chain) {
        paths.addAll(_normalizePath(path, _polyBool.epsilon));
      }
      _polygon = RegionPolygon._(regions: paths, inverted: _segments.inverted);
    }
    return _polygon!;
  }

  static _SegmentList _segmentsFromPoints(
    PolyBool polyBool,
    Points points,
    bool inverted,
  ) {
    var i = _Intersecter(true, polyBool.epsilon);
    i.addRegion(points.toList());
    var result = i.calculate(inverted: inverted);
    if (inverted) return result.invert();
    return result;
  }

  _CombinedSegmentLists _combine(
    _SegmentList segments1,
    _SegmentList segments2,
  ) {
    final i = _Intersecter(false, _polyBool.epsilon);

    return _CombinedSegmentLists(
      combined: i.calculateXD(
        segments1,
        segments1.inverted,
        segments2,
        segments2.inverted,
      ),
      inverted1: segments1.inverted,
      inverted2: segments2.inverted,
    );
  }

  static List<List<Coordinate>> _normalizePath(
      List<Coordinate> path, Epsilon epsilon) {
    // S'assurer que :
    //   1 - les chemins sont toujours fermés (dernier point = premier point)
    //   2 - ils ne contiennent pas  de boucle (passage au même points plus d'une fois)
    //   3 - ils ne se résument pas à un simple segment (au moins 3 points distincts)
    if (path.isEmpty) return [];
    if (!epsilon.pointsSame(path.last, path.first)) {
      path.add(path.first);
    }
    final result = <List<Coordinate>>[];
    List<Coordinate> loop = [path.first];
    for (final p in path.skip(1)) {
      loop.add(p);
      if (p == loop.first) {
        if (loop.length >= 4) result.add(loop);
        loop = [p];
      }
    }
    return result;
  }

  final PolyBool _polyBool;
  final _SegmentList _segments;
  RegionPolygon? _polygon;
}
