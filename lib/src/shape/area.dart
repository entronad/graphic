import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/area.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/path.dart';

import 'util/render_basic_item.dart';
import 'function.dart';

/// The shape for the area element.
///
/// See also:
///
/// - [AreaElement], which this shape is for.
abstract class AreaShape extends FunctionShape {
  @override
  double get defaultSize => throw UnimplementedError('Area needs no size.');

  @override
  List<Figure> renderItem(
    Aes item,
    CoordConv coord,
    Offset origin,
  ) =>
      throw UnimplementedError('Area only paints group.');
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
  List<Figure> renderGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
  ) {
    assert(!(coord is PolarCoordConv && coord.transposed));

    final segments = <List<List<Offset>>>[];
    final labels = <Aes, Offset>{};

    var currentSegment = <List<Offset>>[];
    for (var item in group) {
      assert(item.shape is BasicAreaShape);

      final position = item.position;
      if (position[0].dy.isFinite && position[1].dy.isFinite) {
        final start = coord.convert(position[0]);
        final end = coord.convert(position[1]);
        currentSegment.add([start, end]);
        labels[item] = end;
      } else if (currentSegment.isNotEmpty) {
        segments.add(currentSegment);
        currentSegment = [];
      }
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    if (loop &&
        group.first.position[0].dy.isFinite &&
        group.first.position[1].dy.isFinite &&
        group.last.position[0].dy.isFinite &&
        group.last.position[1].dy.isFinite) {
      // Because lines may be broken by NaN, don't loop by Path.close.
      segments.last.add(segments.first.first);
    }

    final path = Path();
    for (var segment in segments) {
      final starts = <Offset>[];
      final ends = <Offset>[];
      for (var points in segment) {
        starts.add(points[0]);
        ends.add(points[1]);
      }

      // Because area is a whole closed subpath, don't use Paths.polyline, which
      // contains Path.moveTo.
      path.moveTo(ends.first.dx, ends.first.dy);
      if (smooth) {
        final segments = getBezierSegments(
          ends,
          false,
          true,
        );
        for (var s in segments) {
          path.cubicTo(s.cp1.dx, s.cp1.dy, s.cp2.dx, s.cp2.dy, s.p.dx, s.p.dy);
        }
      } else {
        for (var point in ends) {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.lineTo(starts.last.dx, starts.last.dy);
      final reversedStarts = starts.reversed.toList();
      if (smooth) {
        final segments = getBezierSegments(
          reversedStarts,
          false,
          true,
        );
        for (var s in segments) {
          path.cubicTo(s.cp1.dx, s.cp1.dy, s.cp2.dx, s.cp2.dy, s.p.dx, s.p.dy);
        }
      } else {
        for (var point in reversedStarts) {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
    }

    final rst = <Figure>[];

    final represent = group.first;
    rst.addAll(renderBasicItem(
      path,
      represent,
      false,
      0,
      coord.region,
    ));

    for (var item in labels.keys) {
      if (item.label != null && item.label!.haveText) {
        rst.add(renderLabel(
          item.label!,
          labels[item]!,
          coord.transposed ? Alignment.centerRight : Alignment.topCenter,
        ));
      }
    }

    return rst;
  }
}
