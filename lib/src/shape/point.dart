import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';

import 'util/aes_basic_item.dart';
import 'function.dart';

abstract class PointShape extends FunctionShape {
  @override
  List<Figure> drawGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
  ) {
    final rst = <Figure>[];

    for (var item in group) {
      assert(item.shape is PointShape);

      rst.addAll(item.shape.drawItem(item, coord, origin));
    }

    return rst;
  }

  @override
  double get defaultSize => 5;
}

abstract class PointShapeBase extends PointShape {
  PointShapeBase(this.hollow, this.strokeWidth);

  final bool hollow;

  final double strokeWidth;

  @override
  bool equalTo(Object other) =>
    other is PointShapeBase &&
    hollow == other.hollow &&
    strokeWidth == other.strokeWidth;

  @override
  List<Figure> drawItem(
    Aes item,
    CoordConv coord,
    Offset origin,
  ) {
    for (var point in item.position) {
      if (!point.dy.isFinite) {
        continue;
      }
    }

    final rst = <Figure>[];

    final path = this.path(item, coord);
    final size = item.size ?? defaultSize;
    rst.addAll(drawBasicItem(
      path,
      item,
      hollow,
      strokeWidth,
    ));
    if (item.label != null) {
      final point = coord.convert(representPoint(item.position));
      final anchor = Offset(
        point.dx,
        point.dy + (size / 2),
      );
      rst.add(drawLabel(
        item.label!,
        anchor,
        Alignment.topCenter,
      ));
    }

    return rst;
  }

  Path path(Aes item, CoordConv coord);
}

class CircleShape extends PointShapeBase {
  CircleShape({
    bool hollow = false,
    double strokeWidth = 1,
  }) : super(hollow, strokeWidth);

  @override
  bool equalTo(Object other) =>
    super.equalTo(other) &&
    other is CircleShape;

  @override
  Path path(Aes item, CoordConv coord) {
    final point = coord.convert(item.position.last);
    final size = item.size ?? defaultSize;
    return Path()..addOval(Rect.fromCenter(
      center: point,
      width: size,
      height: size,
    ));
  }
}

class SquareShape extends PointShapeBase {
  SquareShape({
    bool hollow = false,
    double strokeWidth = 1,
  }) : super(hollow, strokeWidth);

  @override
  bool equalTo(Object other) =>
    super.equalTo(other) &&
    other is SquareShape;

  @override
  Path path(Aes item, CoordConv coord) {
    final point = coord.convert(item.position.last);
    final size = item.size ?? defaultSize;
    return Path()..addRect(Rect.fromCenter(
      center: point,
      width: size,
      height: size,
    ));
  }
}
