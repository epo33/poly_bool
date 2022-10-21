part of "polybool.dart";

class _SegmentChainer {
  _SegmentChainer(this.epsilon);

  final Epsilon epsilon;

  List<List<Coordinate>> chain(_SegmentList segments) {
    final chains = <List<Coordinate>>[];

    final regions = <List<Coordinate>>[];

    for (var seg in segments) {
      var pt1 = seg.start;
      var pt2 = seg.end;

      if (epsilon.pointsSame(pt1, pt2)) {
        print(
            "PolyBool: Warning: Zero-length segment detected; your epsilon is probably too small or too large");
        continue;
      }

      final matches = Matches();

      for (var i = 0; i < chains.length; i++) {
        final chain = chains[i];
        final head = chain.first;
        final tail = chain.last;

        if (epsilon.pointsSame(head, pt1)) {
          if (setMatch(i, true, true, matches)) break;
        } else if (epsilon.pointsSame(head, pt2)) {
          if (setMatch(i, true, false, matches)) break;
        } else if (epsilon.pointsSame(tail, pt1)) {
          if (setMatch(i, false, true, matches)) break;
        } else if (epsilon.pointsSame(tail, pt2)) {
          if (setMatch(i, false, false, matches)) break;
        }
      }

      if (matches.isFirstMatch) {
        // we didn't match anything, so create a new chain
        chains.add([pt1, pt2]);
        continue;
      }

      if (matches.isSecondMatch) {
        // we matched a single chain

        // add the other point to the apporpriate end, and check to see if we've closed the
        // chain into a loop

        var index = matches.first.index;
        // if we matched pt1, then we add pt2, etc
        var pt = matches.first.pt1 ? pt2 : pt1;
        // if we matched at head, then add to the head
        var addToHead = matches.first.head;

        final chain = chains[index];
        var grow = addToHead ? chain.first : chain.last;
        final grow2 = addToHead ? chain[1] : chain[chain.length - 2];
        final oppo = addToHead ? chain.last : chain.first;
        final oppo2 = addToHead ? chain[chain.length - 2] : chain[1];

        if (epsilon.pointsCollinear(grow2, grow, pt)) {
          // grow isn't needed because it's directly between grow2 and pt:
          // grow2 ---grow---> pt
          if (addToHead) {
            chain.removeAt(0);
          } else {
            chain.removeAt(chain.length - 1);
          }
          grow = grow2; // old grow is gone... new grow is what grow2 was
        }

        if (epsilon.pointsSame(oppo, pt)) {
          // we're closing the loop, so remove chain from chains
          chains.removeAt(index);

          if (epsilon.pointsCollinear(oppo2, oppo, grow)) {
            // oppo isn't needed because it's directly between oppo2 and grow:
            // oppo2 ---oppo--->grow
            if (addToHead) {
              chain.removeAt(chain.length - 1);
            } else {
              chain.removeAt(0);
            }
          }
          // we have a closed chain!
          regions.add(chain);
          continue;
        }

        // not closing a loop, so just add it to the apporpriate side
        if (addToHead) {
          //   if (buildLog != null) buildLog.chainAddHead(first_match.index, pt);

          chain.insert(0, pt);
        } else {
          // if (buildLog != null) buildLog.chainAddTail(first_match.index, pt);

          chain.add(pt);
        }

        continue;
      }

      // otherwise, we matched two chains, so we need to combine those chains together

      final F = matches.first.index;
      final S = matches.second.index;

      // reverse the shorter chain, if needed
      final reverseF = chains[F].length < chains[S].length;
      if (matches.first.head) {
        if (matches.second.head) {
          if (reverseF) {
            // <<<< F <<<< --- >>>> S >>>>
            reverseChain(F, chains);
            // >>>> F >>>> --- >>>> S >>>>
            appendChain(F, S, chains);
          } else {
            // <<<< F <<<< --- >>>> S >>>>
            reverseChain(S, chains);
            // <<<< F <<<< --- <<<< S <<<<   logically same as:
            // >>>> S >>>> --- >>>> F >>>>
            appendChain(S, F, chains);
          }
        } else {
          // <<<< F <<<< --- <<<< S <<<<   logically same as:
          // >>>> S >>>> --- >>>> F >>>>
          appendChain(S, F, chains);
        }
      } else {
        if (matches.second.head) {
          // >>>> F >>>> --- >>>> S >>>>
          appendChain(F, S, chains);
        } else {
          if (reverseF) {
            // >>>> F >>>> --- <<<< S <<<<
            reverseChain(F, chains);
            // <<<< F <<<< --- <<<< S <<<<   logically same as:
            // >>>> S >>>> --- >>>> F >>>>
            appendChain(S, F, chains);
          } else {
            // >>>> F >>>> --- <<<< S <<<<
            reverseChain(S, chains);
            // >>>> F >>>> --- >>>> S >>>>
            appendChain(F, S, chains);
          }
        }
      }
    }
    return regions;
  }

  void reverseChain(int index, List<List<Coordinate>> chains) {
    chains[index] = chains[index].reversed.toList();
  }

  bool setMatch(int index, bool matchesHead, bool matchesPt1, Matches matches) {
    // return true if we've matched twice
    matches.next!.index = index;
    matches.next!.head = matchesHead;
    matches.next!.pt1 = matchesPt1;

    if (matches.isFirstMatch) {
      matches.next = matches.second;
      return false;
    }

    matches.next = null;

    return true; // we've matched twice, we're done here
  }

  void appendChain(int index1, int index2, List<List<Coordinate>> chains) {
    // index1 gets index2 appended to it, and index2 is removed
    var chain1 = chains[index1];
    var chain2 = chains[index2];
    var tail = chain1[chain1.length - 1];
    var tail2 = chain1[chain1.length - 2];
    var head = chain2[0];
    var head2 = chain2[1];

    if (epsilon.pointsCollinear(tail2, tail, head)) {
      // tail isn't needed because it's directly between tail2 and head
      // tail2 ---tail---> head
      chain1.removeAt(chain1.length - 1);
      tail = tail2; // old tail is gone... new tail is what tail2 was
    }

    if (epsilon.pointsCollinear(tail, head, head2)) {
      // head isn't needed because it's directly between tail and head2
      // tail ---head---> head2
      chain2.removeAt(0);
    }

    chain1.addAll(chain2);
    chains.removeAt(index2);
  }
}

class Match {
  Match({this.index = 0, this.head = false, this.pt1 = false});

  int index;

  bool head;

  bool pt1;
}

class Matches {
  Matches() {
    next = first;
  }

  final first = Match();
  final second = Match();
  Match? next;

  bool get isFirstMatch => next == first;

  bool get isSecondMatch => !isFirstMatch && next == second;
}
