import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/path.dart';

import 'util/render_basic_item.dart';
import 'function.dart';

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
  ) => throw UnimplementedError('Line only paints group.');
}

/// A basic line shape.
class BasicLineShape extends LineShape {
  /// Creates a basic line shape.
  BasicLineShape({
    this.smooth = false,
    this.loop = false,
  });

  /// Whether this line is smooth.
  final bool smooth;

  /// Whether to connect the last point to the first point.
  /// 
  /// This is usefull in the polar coordinate.
  final bool loop;

  @override
  bool equalTo(Object other) =>
    other is BasicLineShape &&
    smooth == other.smooth &&
    loop == other.loop;

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
      } else if (currentSegment.isNotEmpty) {
        segments.add(currentSegment);
        currentSegment = [];
      }
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    if (
      loop &&
      group.first.position.last.dy.isFinite &&
      group.last.position.last.dy.isFinite
    ) {
      // Because line can be broken by NaN, loop cannot use close.
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
      path,
      represent,
      true,
      represent.size ?? defaultSize,
    ));

    for (var item in labels.keys) {
      if (item.label != null) {
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
