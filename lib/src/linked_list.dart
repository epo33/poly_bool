part of "polybool.dart";

class _EventNode {
  _EventNode({
    required this.pt,
    required this.seg,
    this.isStart = false,
    this.primary = false,
    this.other,
  });

  final bool isStart;

  Coordinate pt;

  final _Segment seg;

  final bool primary;

  _EventNode? other;

  _StatusNode? status;

  _EventNode? next;

  _EventNode? prev;

  void remove() {
    prev?.next = next;
    if (next != null) {
      next?.prev = prev;
    }
    prev = null;
    next = null;
  }
}

class _StatusNode {
  _StatusNode({required this.ev});

  final _EventNode ev;

  _StatusNode? next;
  _StatusNode? prev;

  void remove() {
    prev?.next = next;
    if (next != null) {
      next?.prev = prev;
    }
    prev = null;
    next = null;
  }
}

class _StatusLinkedList {
  _StatusLinkedList(this.epsilon);

  final Epsilon epsilon;

  final root = _StatusNode(
    ev: _EventNode(
      pt: Coordinate.zero,
      seg: _Segment.empty(),
    ),
  );

  _StatusNode? get head {
    return root.next;
  }

  bool get isEmpty {
    return root.next == null;
  }

  bool exists(_StatusNode? node) {
    if (node == null || node == root) return false;
    return true;
  }

  _Transition findTransition(_EventNode ev) {
    var prev = root;
    var here = root.next;

    while (here != null) {
      if (findTransitionPredicate(ev, here)) break;
      prev = here;
      here = here.next;
    }

    return _Transition(
      before: prev == root ? null : prev.ev,
      after: here?.ev,
      prev: prev,
      here: here,
    );
  }

  _StatusNode insert(_Transition surrounding, _EventNode ev) {
    var prev = surrounding.prev;
    var here = surrounding.here;
    var node = _StatusNode(ev: ev);
    node.prev = prev;
    node.next = here;
    prev?.next = node;
    if (here != null) {
      here.prev = node;
    }
    return node;
  }

  bool findTransitionPredicate(_EventNode ev, _StatusNode here) {
    var comp = statusCompare(ev, here.ev);
    return comp > 0;
  }

  int statusCompare(_EventNode ev1, _EventNode ev2) {
    var a1 = ev1.seg.start;
    var a2 = ev1.seg.end;
    var b1 = ev2.seg.start;
    var b2 = ev2.seg.end;

    if (epsilon.pointsCollinear(a1, b1, b2)) {
      if (epsilon.pointsCollinear(a2, b1, b2)) {
        return 1;
      }
      return epsilon.pointAboveOrOnLine(a2, b1, b2) ? 1 : -1;
    }
    return epsilon.pointAboveOrOnLine(a1, b1, b2) ? 1 : -1;
  }
}

class _EventLinkedList {
  _EventLinkedList(this.epsilon);

  final Epsilon epsilon;

  _EventNode root = _EventNode(
    pt: Coordinate.zero,
    seg: _Segment.empty(),
  );

  _EventNode? get head {
    return root.next;
  }

  bool get isEmpty {
    return root.next == null;
  }

  void insertBefore(_EventNode node, Coordinate otherPt) {
    var last = root;
    var here = root.next;

    while (here != null) {
      if (insertBeforePredicate(here, node, otherPt)) {
        node.prev = here.prev;
        node.next = here;
        here.prev?.next = node;
        here.prev = node;
        return;
      }
      last = here;
      here = here.next;
    }
    last.next = node;
    node.prev = last;
    node.next = null;
  }

  bool insertBeforePredicate(
      _EventNode here, _EventNode ev, Coordinate otherPt) {
    // should ev be inserted before here?
    var comp = eventCompare(
      ev.isStart,
      ev.pt,
      otherPt,
      here.isStart,
      here.pt,
      here.other!.pt,
    );
    return comp < 0;
  }

  int eventCompare(
    bool p1IsStart,
    Coordinate p1_1,
    Coordinate p1_2,
    bool p2IsStart,
    Coordinate p2_1,
    Coordinate p2_2,
  ) {
    // compare the selected points first
    var comp = epsilon.pointsCompare(p1_1, p2_1);
    if (comp != 0) return comp;

    // the selected points are the same

    if (epsilon.pointsSame(p1_2, p2_2)) {
      return 0;
    } // then the segments are equal

    if (p1IsStart != p2IsStart) {
      return p1IsStart ? 1 : -1;
    } // favor the one that isn't the start

    // otherwise, we'll have to calculate which one is below the other manually
    return epsilon.pointAboveOrOnLine(
            p1_2,
            p2IsStart ? p2_1 : p2_2, // order matters
            p2IsStart ? p2_2 : p2_1)
        ? 1
        : -1;
  }
}
