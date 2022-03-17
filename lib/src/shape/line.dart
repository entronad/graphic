import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/line.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/collection.dart';
import 'package:graphic/src/util/path.dart';

import 'function.dart';
import 'util/render_basic_item.dart';

/// The shape for the line element.
///
/// See also:
///
/// - [LineElement], which this shape is for.
abstract class LineShape extends FunctionShape {
  @override
  double get defaultSize => 2;

  @override
  List<Figure> renderItem(
    Aes item,
    CoordConv coord,
    Offset origin,
  ) =>
      throw UnimplementedError('Line only paints group.');
}

/// A basic line shape.
class BasicLineShape extends LineShape {
  /// Creates a basic line shape.
  BasicLineShape({
    this.smooth = false,
    this.loop = false,
    this.dash,
  });

  /// Whether this line is smooth.
  final bool smooth;

  /// Whether to connect the last point to the first point.
  ///
  /// It is usefull in the polar coordinate.
  final bool loop;

  /// The circular array of dash offsets and lengths.
  ///
  /// For example, the array `[5, 10]` would result in dashes 5 pixels long
  /// followed by blank spaces 10 pixels long.  The array `[5, 10, 5]` would
  /// result in a 5 pixel dash, a 10 pixel gap, a 5 pixel dash, a 5 pixel gap,
  /// a 10 pixel dash, etc.
  final List<double>? dash;

  @override
  bool equalTo(Object other) =>
      other is BasicLineShape &&
      smooth == other.smooth &&
      loop == other.loop &&
      deepCollectionEquals(dash, other.dash);

  @override
  List<Figure> renderGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
  ) {
    final segments = <List<Offset>>[];
    final labels = <Aes, Offset>{};

    var currentSegment = <Offset>[];
    for (var item in group) {
      assert(item.shape is BasicLineShape);

      if (item.position.last.dy.isFinite) {
        final point = coord.convert(item.position.last);
        currentSegment.add(point);
        labels[item] = point;
      }
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    if (loop &&
        group.first.position.last.dy.isFinite &&
        group.last.position.last.dy.isFinite) {
      // Because lines may be broken by NaN, don't loop by Path.close.
      segments.last.add(segments.first.first);
    }

    final path = Path();
    for (var segment in segments) {
      Paths.polyline(
        points: segment,
        smooth: smooth,
        path: path,
      );
    }

    final rst = <Figure>[];

    final represent = group.first;
    rst.addAll(renderBasicItem(
      dash == null ? path : Paths.dashLine(source: path, dashArray: dash!),
      represent,
      true,
      represent.size ?? defaultSize,
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
