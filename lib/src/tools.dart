part of "polybool.dart";

class _Transition {
  _Transition({
    this.before,
    this.after,
    this.prev,
    this.here,
  });

  _EventNode? before;
  _EventNode? after;
  _StatusNode? prev;
  _StatusNode? here;
}

class _SegmentList extends DelegatingList<_Segment> {
  _SegmentList({this.inverted = false}) : super([]);

  final bool inverted;

  _SegmentList invert() => _SegmentList(inverted: !inverted)..addAll(this);

  @override
  bool operator ==(Object other) =>
      other is _SegmentList && IterableEquality().equals(other, this);

  @override
  int get hashCode => super.hashCode;
}

class _CombinedSegmentLists {
  _CombinedSegmentLists({
    required this.combined,
    this.inverted1 = false,
    this.inverted2 = false,
  });

  _SegmentList combined;

  bool inverted1;

  bool inverted2;
}

class _Segment {
  _Segment(Coordinate start, Coordinate end) : this._(start: start, end: end);

  _Segment._({
    required this.start,
    required this.end,
    SegmentFill? myFill,
    this.otherFill,
  }) {
    this.myFill = myFill ?? SegmentFill();
  }

  _Segment.empty()
      : this._(
          start: Coordinate.zero,
          end: Coordinate.zero,
        );

  Coordinate start;

  Coordinate end;

  late SegmentFill myFill;

  SegmentFill? otherFill;

  @override
  String toString() => "[$start, $end]";
}
