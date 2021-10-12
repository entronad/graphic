import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/path.dart';

import 'util/draw_basic_item.dart';
import 'function.dart';

abstract class LineShape extends FunctionShape {
  @override
  double get defaultSize => 2;

  @override
  List<Figure> drawItem(
    Aes item,
    CoordConv coord,
    Offset origin,
  ) => throw UnimplementedError('Line only paints group.');
}

class BasicLineShape extends LineShape {
  BasicLineShape({
    this.smooth = false,
    this.loop = false,
  });

  final bool smooth;

  final bool loop;

  @override
  bool equalTo(Object other) =>
    other is BasicLineShape &&
    smooth == other.smooth &&
    loop == other.loop;

  @override
  List<Figure> drawGroup(
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
    rst.addAll(drawBasicItem(
      path,
      represent,
      true,
      represent.size ?? defaultSize,
    ));

    for (var item in labels.keys) {
      if (item.label != null) {
        rst.add(drawLabel(
          item.label!,
          labels[item]!,
          coord.transposed ? Alignment.centerRight : Alignment.topCenter,
        ));
      }
    }

    return rst;
  }
}
