import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';

import 'util/aes_basic_item.dart';
import 'function.dart';

abstract class PointShape extends FunctionShape {
  @override
  void paintGroup(
    List<Aes> group,
    CoordConv coord,
    Canvas canvas,
  ) {
    for (var item in group) {
      item.shape.paintItem(item, coord, canvas);
    }
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
  void paintItem(
    Aes item,
    CoordConv coord,
    Canvas canvas,
  ) {
    for (var point in item.position) {
      if (!point.dy.isFinite) {
        return;
      }
    }

    final path = this.path(item, coord);
    final size = item.size ?? defaultSize;
    aesBasicItem(
      path,
      item,
      hollow,
      strokeWidth,
      canvas,
    );
    if (item.label != null) {
      final point = coord.convert(item.position.first);
      final anchor = Offset(
        point.dx,
        point.dy + (size / 2),
      );
      paintLabel(
        item.label!,
        anchor,
        Alignment.bottomCenter,
        canvas,
      );
    }
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
    final point = coord.convert(item.position.first);
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
    final point = coord.convert(item.position.first);
    final size = item.size ?? defaultSize;
    return Path()..addRect(Rect.fromCenter(
      center: point,
      width: size,
      height: size,
    ));
  }
}
