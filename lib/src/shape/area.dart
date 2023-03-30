import 'package:flutter/painting.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/element/path.dart';
import 'package:graphic/src/graffiti/element/segment/close.dart';
import 'package:graphic/src/graffiti/element/segment/cubic.dart';
import 'package:graphic/src/graffiti/element/segment/line.dart';
import 'package:graphic/src/graffiti/element/segment/move.dart';
import 'package:graphic/src/graffiti/element/segment/segment.dart';
import 'package:graphic/src/mark/area.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/util/path.dart';

import 'util/style.dart';
import 'function.dart';
import 'line.dart';

/// The shape for the area mark.
///
/// See also:
///
/// - [AreaMark], which this shape is for.
abstract class AreaShape extends FunctionShape {
  @override
  double get defaultSize => throw UnimplementedError('Area needs no size.');
}

/// A basic area shape.
class BasicAreaShape extends AreaShape {
  /// Creates a basic area shape.
  BasicAreaShape({
    this.smooth = false,
    this.loop = false,
  });

  /// Whether the surface lines of this area are smooth.
  final bool smooth;

  /// Whether to connect the last point to the first point.
  ///
  /// It is usefull in the polar coordinate.
  final bool loop;

  @override
  bool equalTo(Object other) =>
      other is BasicAreaShape && smooth == other.smooth && loop == other.loop;

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    assert(!(coord is PolarCoordConv && coord.transposed));

    final contours = <List<List<Offset>>>[];

    var currentContour = <List<Offset>>[];
    for (var item in group) {
      assert(item.shape is BasicAreaShape);

      final position = item.position;
      if (position[0].dy.isFinite && position[1].dy.isFinite) {
        final start = coord.convert(position[0]);
        final end = coord.convert(position[1]);
        currentContour.add([start, end]);
      } else if (currentContour.isNotEmpty) {
        contours.add(currentContour);
        currentContour = [];
      }
    }
    if (currentContour.isNotEmpty) {
      contours.add(currentContour);
    }

    if (loop &&
        group.first.position[0].dy.isFinite &&
        group.first.position[1].dy.isFinite &&
        group.last.position[0].dy.isFinite &&
        group.last.position[1].dy.isFinite) {
      // Because lines may be broken by NaN, don't loop by Path.close.
      contours.last.add(contours.first.first);
    }

    final primitives = <MarkElement>[];

    final style = getPaintStyle(group.first, false, 0, coord.region);

    for (var contour in contours) {
      final starts = <Offset>[];
      final ends = <Offset>[];
      for (var points in contour) {
        starts.add(points[0]);
        ends.add(points[1]);
      }

      final segments = <Segment>[];
      segments.add(MoveSegment(end: ends.first));
      if (smooth) {
        final controlsList = getCubicControls(ends, false, true);
        for (var c in controlsList) {
          segments.add(CubicSegment(control1: c[0], control2: c[1], end: c[2]));
        }
      } else {
        for (var point in ends) {
          segments.add(LineSegment(end: point));
        }
      }
      segments.add(LineSegment(end: starts.last));
      final reversedStarts = starts.reversed.toList();
      if (smooth) {
        final controlsList = getCubicControls(reversedStarts, false, true);
        for (var c in controlsList) {
          segments.add(CubicSegment(control1: c[0], control2: c[1], end: c[2]));
        }
      } else {
        for (var point in reversedStarts) {
          segments.add(LineSegment(end: point));
        }
      }
      segments.add(CloseSegment());

      primitives.add(PathElement(segments: segments, style: style));
    }

    return primitives;
  }

  @override
  List<MarkElement> drawGroupLabels(
          List<Attributes> group, CoordConv coord, Offset origin) =>
      drawLineLabels(group, coord, origin);
}
