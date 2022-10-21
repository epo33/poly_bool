part of "polybool.dart";

typedef _Selector = _SegmentList Function(_CombinedSegmentLists);

class Combine {
  Combine._(PolyBool polyBool, _CombinedSegmentLists combined)
      : _polyBool = polyBool,
        _combined = combined;

  RegionBuilder get union => _operation(_selectUnion);

  RegionBuilder get intersect => _operation(_selectIntersect);

  RegionBuilder get difference => _operation(_selectDifference);

  RegionBuilder get inverseDifference => _operation(_selectDifferenceRev);

  RegionBuilder get xor => _operation(_selectXor);

  // Private part

  RegionBuilder _operation(_Selector selector) {
    return RegionBuilder._segments(_polyBool, selector(_combined));
  }

  static _SegmentList _selectUnion(_CombinedSegmentLists combined) {
    final result = _SegmentSelector.union(combined.combined);
    if (combined.inverted1 || combined.inverted2) return result.invert();
    return result;
  }

  static _SegmentList _selectIntersect(_CombinedSegmentLists combined) {
    final result = _SegmentSelector.intersect(combined.combined);
    if (combined.inverted1 || combined.inverted2) return result.invert();
    return result;
  }

  static _SegmentList _selectDifference(_CombinedSegmentLists combined) {
    final result = _SegmentSelector.difference(combined.combined);
    if (combined.inverted1 && !combined.inverted2) return result.invert();
    return result;
  }

  static _SegmentList _selectDifferenceRev(_CombinedSegmentLists combined) {
    final result = _SegmentSelector.differenceRev(combined.combined);
    if (!combined.inverted1 && combined.inverted2) return result.invert();
    return result;
  }

  static _SegmentList _selectXor(_CombinedSegmentLists combined) {
    final result = _SegmentSelector.xor(combined.combined);
    if (combined.inverted1 != combined.inverted2) return result.invert();
    return result;
  }

  final PolyBool _polyBool;
  final _CombinedSegmentLists _combined;
}
