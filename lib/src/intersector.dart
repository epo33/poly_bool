part of "polybool.dart";

class _Intersecter {
  _Intersecter(this.selfIntersection, this.epsilon) {
    eventRoot = _EventLinkedList(epsilon);
    statusRoot = _StatusLinkedList(epsilon);
  }

  final bool selfIntersection;

  final Epsilon epsilon;

  late final _EventLinkedList eventRoot;

  late final _StatusLinkedList statusRoot;

  _Segment segmentNew(Coordinate start, Coordinate end) {
    return _Segment._(
      start: start,
      end: end,
    );
  }

  _Segment segmentCopy(Coordinate start, Coordinate end, _Segment seg) {
    return _Segment._(
      start: start,
      end: end,
      myFill: SegmentFill(above: seg.myFill.above, below: seg.myFill.below),
    );
  }

  void eventAdd(_EventNode ev, Coordinate otherPt) {
    eventRoot.insertBefore(ev, otherPt);
  }

  _EventNode eventAddSegmentStart(_Segment seg, bool primary) {
    var evStart = _EventNode(
      isStart: true,
      pt: seg.start,
      seg: seg,
      primary: primary,
      other: null,
    );
    eventAdd(evStart, seg.end);
    return evStart;
  }

  _EventNode eventAddSegmentEnd(
      _EventNode evStart, _Segment seg, bool primary) {
    var evEnd = _EventNode(
      isStart: false,
      pt: seg.end,
      seg: seg,
      primary: primary,
      other: evStart,
    );
    evStart.other = evEnd;
    eventAdd(evEnd, evStart.pt);
    return evEnd;
  }

  _EventNode eventAddSegment(_Segment seg, bool primary) {
    var evStart = eventAddSegmentStart(seg, primary);
    eventAddSegmentEnd(evStart, seg, primary);
    return evStart;
  }

  void eventUpdateEnd(_EventNode ev, Coordinate end) {
    // slides an end backwards
    //   (start)------------(end)    to:
    //   (start)---(end)
    final other = ev.other!;
    other.remove();
    ev.seg.end = end;
    other.pt = end;
    eventAdd(other, ev.pt);
  }

  _EventNode eventDivide(_EventNode ev, Coordinate pt) {
    var ns = segmentCopy(pt, ev.seg.end, ev.seg);
    eventUpdateEnd(ev, pt);
    return eventAddSegment(ns, ev.primary);
  }

  _SegmentList calculate({bool inverted = false}) {
    if (!selfIntersection) {
      throw Exception(
          "This function is only intended to be called when selfIntersection = true");
    }
    return _calculateInternal(inverted, false);
  }

  _SegmentList calculateXD(
    _SegmentList segments1,
    bool inverted1,
    _SegmentList segments2,
    bool inverted2,
  ) {
    if (selfIntersection) {
      throw Exception(
          "This function is only intended to be called when selfIntersection = false");
    }

    // segmentsX come from the self-intersection API, or this API
    // invertedX is whether we treat that list of segments as an inverted polygon or not
    // returns segments that can be used for further operations
    for (final s in segments1) {
      eventAddSegment(s, true);
    }
    for (final s in segments2) {
      eventAddSegment(s, false);
    }
    return _calculateInternal(inverted1, inverted2);
  }

  void addRegion(Points points) {
    if (!selfIntersection) {
      throw StateError(
        "The addRegion() function is only intended for use when selfIntersection = true",
      );
    }
    if (points.isEmpty) return;
    final region = points.toList();
    // Ensure that the polygon is fully closed (the start point and end point are exactly the same)
    if (!epsilon.pointsSame(region.last, region.first)) {
      region.add(region.first);
    }
    if (region.length < 4) {
      throw ArgumentError("A region must be defined by at least 3 points");
    }

    // regions are a list of points:
    //  [ [0, 0], [100, 0], [50, 100] ]
    // you can add multiple regions before running calculate
    var pt1 = Coordinate(0, 0);
    var pt2 = region.last;
    final segments = <_Segment>[];

    for (var pt in region) {
      pt1 = pt2;
      pt2 = pt;

      var forward = epsilon.pointsCompare(pt1, pt2);
      if (forward == 0) {
        // just skip it
        continue;
      }
      segments
          .add(segmentNew(forward < 0 ? pt1 : pt2, forward < 0 ? pt2 : pt1));
    }
    if (segments.length < 3) return;
    for (final s in segments) {
      eventAddSegment(s, true);
    }
  }

  _Transition statusFindSurrounding(_EventNode ev) {
    return statusRoot.findTransition(ev);
  }

  _EventNode? checkIntersection(_EventNode ev1, _EventNode ev2) {
    // returns the segment equal to ev1, or false if nothing equal

    final seg1 = ev1.seg;
    final seg2 = ev2.seg;
    final a1 = seg1.start;
    final a2 = seg1.end;
    final b1 = seg2.start;
    final b2 = seg2.end;

    // if (buildLog != null) buildLog.checkIntersection(seg1, seg2);

    final intersect = epsilon.linesIntersect(a1, a2, b1, b2);
    if (intersect == null) {
      // segments are parallel or coincident

      // if points aren't collinear, then the segments are parallel, so no intersections
      if (!epsilon.pointsCollinear(a1, a2, b1)) return null;

      // otherwise, segments are on top of each other somehow (aka coincident)

      if (epsilon.pointsSame(a1, b2) || epsilon.pointsSame(a2, b1)) {
        return null;
      } // segments touch at endpoints... no intersection

      var a1EquB1 = epsilon.pointsSame(a1, b1);
      var a2EquB2 = epsilon.pointsSame(a2, b2);

      if (a1EquB1 && a2EquB2) return ev2; // segments are exactly equal

      var a1Between = !a1EquB1 && epsilon.pointBetween(a1, b1, b2);
      var a2Between = !a2EquB2 && epsilon.pointBetween(a2, b1, b2);

      if (a1EquB1) {
        if (a2Between) {
          //  (a1)---(a2)
          //  (b1)----------(b2)
          eventDivide(ev2, a2);
        } else {
          //  (a1)----------(a2)
          //  (b1)---(b2)
          eventDivide(ev1, b2);
        }
        return ev2;
      } else if (a1Between) {
        if (!a2EquB2) {
          // make a2 equal to b2
          if (a2Between) {
            //         (a1)---(a2)
            //  (b1)-----------------(b2)
            eventDivide(ev2, a2);
          } else {
            //         (a1)----------(a2)
            //  (b1)----------(b2)
            eventDivide(ev1, b2);
          }
        }
        //         (a1)---(a2)
        //  (b1)----------(b2)
        eventDivide(ev2, a1);
      }
    } else {
      // otherwise, lines intersect at i.pt, which may or may not be between the endpoints

      // is A divided between its endpoints? (exclusive)
      if (intersect.alongA == IntersectionPos.inSegment) {
        if (intersect.alongB == IntersectionPos.atStart) {
          eventDivide(ev1, b1);
        } else if (intersect.alongB == IntersectionPos.inSegment) {
          eventDivide(ev1, intersect.pt);
        } else if (intersect.alongB == IntersectionPos.atEnd) {
          eventDivide(ev1, b2);
        }
      }

      // is B divided between its endpoints? (exclusive)
      if (intersect.alongB == IntersectionPos.inSegment) {
        if (intersect.alongA == IntersectionPos.atStart) {
          eventDivide(ev2, a1);
        } else if (intersect.alongA == IntersectionPos.inSegment) {
          eventDivide(ev2, intersect.pt);
        } else if (intersect.alongA == IntersectionPos.atEnd) {
          eventDivide(ev2, a2);
        }
      }
    }
    return null;
  }

  _EventNode? checkBothIntersections(
    _EventNode ev,
    _EventNode? above,
    _EventNode? below,
  ) {
    if (above != null) {
      var eve = checkIntersection(ev, above);
      if (eve != null) return eve;
    }

    if (below != null) {
      return checkIntersection(ev, below);
    }

    return null;
  }

  _SegmentList _calculateInternal(
    bool primaryPolyInverted,
    bool secondaryPolyInverted,
  ) {
    //
    // main event loop
    //
    final segments = _SegmentList();

    while (!eventRoot.isEmpty) {
      var ev = eventRoot.head!;
      if (ev.isStart) {
        var surrounding = statusFindSurrounding(ev);
        var above = surrounding.before;
        var below = surrounding.after;
        var eve = checkBothIntersections(ev, above, below);
        if (eve != null) {
          // ev and eve are equal
          // we'll keep eve and throw away ev
          // merge ev.seg's fill information into eve.seg
          if (selfIntersection) {
            var toggle = false; // are we a toggling edge?
            if (ev.seg.myFill.belowInitialized) {
              toggle = ev.seg.myFill.above != ev.seg.myFill.below;
            } else {
              toggle = true;
            }

            // merge two segments that belong to the same polygon
            // think of this as sandwiching two segments together, where `eve.seg` is
            // the bottom -- this will cause the above fill flag to toggle
            if (toggle) {
              eve.seg.myFill.above = !eve.seg.myFill.above;
            }
          } else {
            // merge two segments that belong to different polygons
            // each segment has distinct knowledge, so no special logic is needed
            // note that this can only happen once per segment in this phase, because we
            // are guaranteed that all self-intersections are gone
            eve.seg.otherFill = ev.seg.myFill;
          }

          ev.other?.remove();
          ev.remove();
        }

        if (eventRoot.head != ev) {
          // something was inserted before us in the event queue, so loop back around and
          // process it before continuing
          continue;
        }

        // calculate fill flags
        if (selfIntersection) {
          bool toggle = false; // are we a toggling edge?

          // if we are a new segment...
          if (ev.seg.myFill.belowInitialized) {
            toggle = ev.seg.myFill.above != ev.seg.myFill.below;
          } else {
            toggle = true;
          } // calculate toggle

          // next, calculate whether we are filled below us
          if (below == null) {
            // if nothing is below us...
            // we are filled below us if the polygon is inverted
            ev.seg.myFill.below = primaryPolyInverted;
            ev.seg.myFill.belowInitialized = true;
          } else {
            // otherwise, we know the answer -- it's the same if whatever is below
            // us is filled above it
            ev.seg.myFill.below = below.seg.myFill.above;
            ev.seg.myFill.belowInitialized = true;
          }

          // since now we know if we're filled below us, we can calculate whether
          // we're filled above us by applying toggle to whatever is below us
          final fill = ev.seg.myFill;
          if (toggle) {
            fill.above = fill.belowInitialized ? !fill.below : fill.above;
          } else {
            fill.above = fill.belowInitialized ? fill.below : fill.above;
          }
        } else {
          // now we fill in any missing transition information, since we are all-knowing
          // at this point

          final otherFill = ev.seg.otherFill;
          if (otherFill == null) {
            // if we don't have other information, then we need to figure out if we're
            // inside the other polygon
            var inside = false;
            if (below == null) {
              // if nothing is below us, then we're inside if the other polygon is
              // inverted
              inside = ev.primary ? secondaryPolyInverted : primaryPolyInverted;
            } else {
              // otherwise, something is below us
              // so copy the below segment's other polygon's above
              if (ev.primary == below.primary) {
                inside = below.seg.otherFill!.above;
              } else {
                inside = below.seg.myFill.above;
              }
            }
            ev.seg.otherFill = SegmentFill(above: inside, below: inside);
          }
        }

        // insert the status and remember it for later removal
        ev.other!.status = statusRoot.insert(surrounding, ev);
      } else {
        final st = ev.status;
        if (st == null) {
          throw Exception(
              "PolyBool: Zero-length segment detected; your epsilon is probably too small or too large");
        }

        // removing the status will create two new adjacent edges, so we'll need to check
        // for those
        if (statusRoot.exists(st.prev) && statusRoot.exists(st.next)) {
          checkIntersection(st.prev!.ev, st.next!.ev);
        }
        // remove the status
        st.remove();

        // if we've reached this point, we've calculated everything there is to know, so
        // save the segment for reporting
        if (!ev.primary) {
          // make sure `seg.myFill` actually points to the primary polygon though
          final s = ev.seg.myFill;
          ev.seg.myFill = ev.seg.otherFill!;
          ev.seg.otherFill = s;
        }
        segments.add(ev.seg);
      }
      // remove the event and continue
      eventRoot.head!.remove();
    }

    return segments;
  }
}
