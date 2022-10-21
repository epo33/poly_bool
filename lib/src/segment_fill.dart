part of "polybool.dart";

class SegmentFill {
  // NOTE: This is kind of asinine, but the original javascript code used (below === null) to determine that the edge had not
  // yet been processed, and treated below as a standard true/false in every other case, necessitating the use of a nullable
  // bool here.
  SegmentFill({this.above = false, bool? below})
      : below = below ?? false,
        belowInitialized = below != null;

  bool above;

  bool below;

  bool belowInitialized;
}
