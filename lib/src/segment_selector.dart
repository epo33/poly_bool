part of "polybool.dart";
//
// filter a list of segments based on boolean operations
//

class _SegmentSelector {
  static _SegmentList union(_SegmentList segments) {
    return select(segments, _unionSelectTable);
  }

  static _SegmentList difference(_SegmentList segments) {
    return select(segments, _differenceSelectTable);
  }

  static _SegmentList intersect(_SegmentList segments) {
    return select(segments, _intersectSelectTable);
  }

  static _SegmentList differenceRev(_SegmentList segments) {
    return select(segments, _differenceRevSelectTable);
  }

  static _SegmentList xor(_SegmentList segments) {
    return select(segments, _xorSelectTable);
  }

  static select(_SegmentList segments, selection) {
    var result = _SegmentList();

    for (var seg in segments) {
      final otherFill = seg.otherFill;
      var index = (seg.myFill.above ? 8 : 0) +
          (seg.myFill.below ? 4 : 0) +
          ((otherFill != null && otherFill.above) ? 2 : 0) +
          ((otherFill != null && otherFill.below) ? 1 : 0);

      if (selection[index] != 0) {
        result.add(
          _Segment._(
            start: seg.start,
            end: seg.end,
            myFill: SegmentFill(
                above: selection[index] == 1, // 1 if filled above
                below: selection[index] == 2 // 2 if filled below
                ),
            otherFill: null,
          ),
        );

        // copy the segment to the results, while also calculating the fill status

      }
    }

    return result;
  }

  // primary | secondary
  // above1 below1 above2 below2    Keep?               Value
  //    0      0      0      0   =>   no                  0
  //    0      0      0      1   =>   yes filled below    2
  //    0      0      1      0   =>   yes filled above    1
  //    0      0      1      1   =>   no                  0
  //    0      1      0      0   =>   yes filled below    2
  //    0      1      0      1   =>   yes filled below    2
  //    0      1      1      0   =>   no                  0
  //    0      1      1      1   =>   no                  0
  //    1      0      0      0   =>   yes filled above    1
  //    1      0      0      1   =>   no                  0
  //    1      0      1      0   =>   yes filled above    1
  //    1      0      1      1   =>   no                  0
  //    1      1      0      0   =>   no                  0
  //    1      1      0      1   =>   no                  0
  //    1      1      1      0   =>   no                  0
  //    1      1      1      1   =>   no                  0
  static const _unionSelectTable = <int>[
    0,
    2,
    1,
    0,
    2,
    2,
    0,
    0,
    1,
    0,
    1,
    0,
    0,
    0,
    0,
    0
  ];

  // primary & secondary
  // above1 below1 above2 below2    Keep?               Value
  //    0      0      0      0   =>   no                  0
  //    0      0      0      1   =>   no                  0
  //    0      0      1      0   =>   no                  0
  //    0      0      1      1   =>   no                  0
  //    0      1      0      0   =>   no                  0
  //    0      1      0      1   =>   yes filled below    2
  //    0      1      1      0   =>   no                  0
  //    0      1      1      1   =>   yes filled below    2
  //    1      0      0      0   =>   no                  0
  //    1      0      0      1   =>   no                  0
  //    1      0      1      0   =>   yes filled above    1
  //    1      0      1      1   =>   yes filled above    1
  //    1      1      0      0   =>   no                  0
  //    1      1      0      1   =>   yes filled below    2
  //    1      1      1      0   =>   yes filled above    1
  //    1      1      1      1   =>   no                  0
  static const _intersectSelectTable = <int>[
    0,
    0,
    0,
    0,
    0,
    2,
    0,
    2,
    0,
    0,
    1,
    1,
    0,
    2,
    1,
    0
  ];

  // primary - secondary
  // above1 below1 above2 below2    Keep?               Value
  //    0      0      0      0   =>   no                  0
  //    0      0      0      1   =>   no                  0
  //    0      0      1      0   =>   no                  0
  //    0      0      1      1   =>   no                  0
  //    0      1      0      0   =>   yes filled below    2
  //    0      1      0      1   =>   no                  0
  //    0      1      1      0   =>   yes filled below    2
  //    0      1      1      1   =>   no                  0
  //    1      0      0      0   =>   yes filled above    1
  //    1      0      0      1   =>   yes filled above    1
  //    1      0      1      0   =>   no                  0
  //    1      0      1      1   =>   no                  0
  //    1      1      0      0   =>   no                  0
  //    1      1      0      1   =>   yes filled above    1
  //    1      1      1      0   =>   yes filled below    2
  //    1      1      1      1   =>   no                  0
  static const _differenceSelectTable = <int>[
    0,
    0,
    0,
    0,
    2,
    0,
    2,
    0,
    1,
    1,
    0,
    0,
    0,
    1,
    2,
    0
  ];

  // secondary - primary
  // above1 below1 above2 below2    Keep?               Value
  //    0      0      0      0   =>   no                  0
  //    0      0      0      1   =>   yes filled below    2
  //    0      0      1      0   =>   yes filled above    1
  //    0      0      1      1   =>   no                  0
  //    0      1      0      0   =>   no                  0
  //    0      1      0      1   =>   no                  0
  //    0      1      1      0   =>   yes filled above    1
  //    0      1      1      1   =>   yes filled above    1
  //    1      0      0      0   =>   no                  0
  //    1      0      0      1   =>   yes filled below    2
  //    1      0      1      0   =>   no                  0
  //    1      0      1      1   =>   yes filled below    2
  //    1      1      0      0   =>   no                  0
  //    1      1      0      1   =>   no                  0
  //    1      1      1      0   =>   no                  0
  //    1      1      1      1   =>   no                  0
  static const _differenceRevSelectTable = <int>[
    0,
    2,
    1,
    0,
    0,
    0,
    1,
    1,
    0,
    2,
    0,
    2,
    0,
    0,
    0,
    0
  ];

  // primary ^ secondary
  // above1 below1 above2 below2    Keep?               Value
  //    0      0      0      0   =>   no                  0
  //    0      0      0      1   =>   yes filled below    2
  //    0      0      1      0   =>   yes filled above    1
  //    0      0      1      1   =>   no                  0
  //    0      1      0      0   =>   yes filled below    2
  //    0      1      0      1   =>   no                  0
  //    0      1      1      0   =>   no                  0
  //    0      1      1      1   =>   yes filled above    1
  //    1      0      0      0   =>   yes filled above    1
  //    1      0      0      1   =>   no                  0
  //    1      0      1      0   =>   no                  0
  //    1      0      1      1   =>   yes filled below    2
  //    1      1      0      0   =>   no                  0
  //    1      1      0      1   =>   yes filled above    1
  //    1      1      1      0   =>   yes filled below    2
  //    1      1      1      1   =>   no                  0
  static const _xorSelectTable = <int>[
    0,
    2,
    1,
    0,
    2,
    0,
    0,
    1,
    1,
    0,
    0,
    2,
    0,
    1,
    2,
    0
  ];
}
