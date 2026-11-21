import 'dart:math';

import 'package:flutter/material.dart';

/// This traversal policy manage the up and down direction to be totally
/// predictable.
/// Going up or down will always go to the next or previous row. All other
/// traversal policy try to be smart, and in some cases can skip rows when
/// going up or down.
class RowByRowTraversalPolicy extends FocusTraversalPolicy with DirectionalFocusTraversalPolicyMixin {
  final FocusTraversalPolicy _fallbackPolicy = WidgetOrderTraversalPolicy();

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) => descendants;

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    _centers = Expando();
    try {
      List<FocusNode>? nodes = currentNode.nearestScope?.traversalDescendants.toList();
      if (nodes == null) {
        return super.inDirection(currentNode, direction);
      }

      NodeSearcher searcher = NodeSearcher(direction);
      List<CandidateNode> candidates = searcher.findCandidates(nodes, currentNode);
      if (candidates.isEmpty) {
        if (direction == TraversalDirection.left || direction == TraversalDirection.right) {
          return false;
        }
        // WHY: Fallback for off-screen nodes. If geometric search fails (e.g., lower/higher row 
        // is not yet laid out/rendered in viewport), fallback to widget order traversal to untrap focus.
        return _fallbackPolicy.inDirection(currentNode, direction) || super.inDirection(currentNode, direction);
      }
      FocusNode nextNode = searcher.findBestFocusNode(candidates, currentNode);
      nextNode.requestFocus();
      return true;
    } finally {
      _centers = null;
    }
  }
}

class NodeSearcher {
  final TraversalDirection directionToSearch;

  NodeSearcher(this.directionToSearch);

  /// should be called first
  List<CandidateNode> findCandidates(List<FocusNode> nodes, FocusNode from) {
    List<FocusNode> copy = List.from(nodes, growable: true);

    switch (directionToSearch) {
      case TraversalDirection.up:
        copy.removeWhere((element) => element.isBelowOrEquals(from));
        break;
      case TraversalDirection.down:
        copy.removeWhere((element) => element.isAboveOrEquals(from));
        break;
      case TraversalDirection.right:
        copy.removeWhere((element) => element.isLeftToOrEquals(from) || !element.isOnTheSameRow(from));
        break;
      case TraversalDirection.left:
        copy.removeWhere((element) => element.isRightToOrEquals(from) || !element.isOnTheSameRow(from));
        break;
    }
    return toCandidateNodes(copy);
  }

  FocusNode findBestFocusNode(List<CandidateNode> nodes, FocusNode from) {
    List<FocusNode> candidates = toFocusNodes(nodes);

    return candidates.reduce((bestNode, challenger) {
      if (directionToSearch == TraversalDirection.down && challenger.isAbove(bestNode)) {
        return challenger;
      } else if (directionToSearch == TraversalDirection.up && challenger.isBelow(bestNode)) {
        return challenger;
      } else if (directionToSearch == TraversalDirection.left && challenger.isRightTo(bestNode)) {
        return challenger;
      } else if (directionToSearch == TraversalDirection.right && challenger.isLeftTo(bestNode)) {
        return challenger;
      }
      // compute the element which is the closest horizontally
      if (challenger.isOnTheSameRow(bestNode) && challenger.distance(from) < bestNode.distance(from)) {
        return challenger;
      }
      return bestNode;
    });
  }
}

/// An internal object to use the [NodeSearcher] class as expected
class CandidateNode {
  final FocusNode node;

  CandidateNode(this.node);
}

/// Some conversion utilities used internally
List<CandidateNode> toCandidateNodes(List<FocusNode> nodes) => nodes.map((e) => CandidateNode(e)).toList();

List<FocusNode> toFocusNodes(List<CandidateNode> nodes) => nodes.map((e) => e.node).toList();

/// Node centers for the search in progress. [FocusNode.rect] walks the render
/// tree, and one search compares each node many times; nothing moves meanwhile.
Expando<Offset>? _centers;

/// A few extension methods to the [FocusNode] to be able to compare their
/// respective position easily.
extension Geometry on FocusNode {
  Offset get _center => _centers == null ? rect.center : (_centers![this] ??= rect.center);

  /// Vertical tolerance to account for focus card zoom animations (1.1x - 1.15x),
  /// outline borders, and subpixel rendering variance on TV panels.
  static const double rowTolerance = 16.0;

  bool isBelow(FocusNode other) {
    return (_center.dy - other._center.dy) > rowTolerance;
  }

  bool isBelowOrEquals(FocusNode other) {
    return (_center.dy - other._center.dy) >= -rowTolerance;
  }

  bool isRightTo(FocusNode other) {
    return _center.dx.round() > other._center.dx.round();
  }

  bool isRightToOrEquals(FocusNode other) {
    return _center.dx.round() >= other._center.dx.round();
  }

  bool isLeftTo(FocusNode other) {
    return _center.dx.round() < other._center.dx.round();
  }

  bool isLeftToOrEquals(FocusNode other) {
    return _center.dx.round() <= other._center.dx.round();
  }

  bool isAbove(FocusNode other) {
    return (other._center.dy - _center.dy) > rowTolerance;
  }

  bool isAboveOrEquals(FocusNode other) {
    return (other._center.dy - _center.dy) >= -rowTolerance;
  }

  bool isOnTheSameRow(FocusNode other) {
    return (_center.dy - other._center.dy).abs() <= rowTolerance;
  }

  double distance(FocusNode other) {
    return sqrt(pow(_center.dx.round() - other._center.dx.round(), 2) +
        pow(_center.dy.round() - other._center.dy.round(), 2));
  }
}
