import 'package:flutter/cupertino.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/mark/point.dart';
import 'package:graphic/src/graffiti/figure.dart';

import 'function.dart';
import 'util/render_basic_item.dart';

/// The shape for the point mark.
///
/// See also:
///
/// - [PointMark], which this shape is for.
abstract class PointShape extends FunctionShape {
  @override
  List<Figure> renderGroup(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    final rst = <Figure>[];

    for (var item in group) {
      assert(item.shape is PointShape);

      rst.addAll(item.shape.renderItem(item, coord, origin));
    }

    return rst;
  }

  @override
  double get defaultSize => 5;
}

/// The base class of point shapes.
abstract class PointShapeBase extends PointShape {
  /// Creates a point shape base.
  PointShapeBase(this.hollow, this.strokeWidth);

  /// Whether this point shape is hollow.
  final bool hollow;

  /// The stroke width of this point shape when it's hollow.
  final double strokeWidth;

  @override
  bool equalTo(Object other) =>
      other is PointShapeBase &&
      hollow == other.hollow &&
      strokeWidth == other.strokeWidth;

  @override
  List<Figure> renderItem(
    Attributes item,
    CoordConv coord,
    Offset origin,
  ) {
    for (var point in item.position) {
      if (!point.isFinite) {
        return [];
      }
    }

    final rst = <Figure>[];

    final path = this.path(item, coord);
    final size = item.size ?? defaultSize;
    rst.addAll(renderBasicItem(
      path,
      item,
      hollow,
      strokeWidth,
    ));
    if (item.label != null && item.label!.haveText) {
      final point = coord.convert(representPoint(item.position));
      final anchor = Offset(
        point.dx,
        point.dy + (size / 2),
      );
      rst.add(renderLabel(
        item.label!,
        anchor,
        Alignment.topCenter,
      ));
    }

    return rst;
  }

  Path path(Attributes item, CoordConv coord);
}

/// A circle shape.
class CircleShape extends PointShapeBase {
  /// Creates a circle shape.
  CircleShape({
    bool hollow = false,
    double strokeWidth = 1,
  }) : super(hollow, strokeWidth);

  @override
  bool equalTo(Object other) => super.equalTo(other) && other is CircleShape;

  @override
  Path path(Attributes item, CoordConv coord) {
    final point = coord.convert(item.position.last);
    final size = item.size ?? defaultSize;
    return Path()
      ..addOval(Rect.fromCenter(
        center: point,
        width: size,
        height: size,
      ));
  }
}

/// A square shape.
class SquareShape extends PointShapeBase {
  /// Creates a square shape.
  SquareShape({
    bool hollow = false,
    double strokeWidth = 1,
  }) : super(hollow, strokeWidth);

  @override
  bool equalTo(Object other) => super.equalTo(other) && other is SquareShape;

  @override
  Path path(Attributes item, CoordConv coord) {
    final point = coord.convert(item.position.last);
    final size = item.size ?? defaultSize;
    return Path()
      ..addRect(Rect.fromCenter(
        center: point,
        width: size,
        height: size,
      ));
  }
}
