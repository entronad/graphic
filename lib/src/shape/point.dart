import 'package:flutter/cupertino.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/element/circle.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/graffiti/element/rect.dart';
import 'package:graphic/src/mark/point.dart';
import 'package:graphic/src/graffiti/element/element.dart';

import 'function.dart';
import 'util/style.dart';

/// The shape for the point mark.
///
/// See also:
///
/// - [PointMark], which this shape is for.
abstract class PointShape extends FunctionShape {
  PointShape(this.hollow, this.strokeWidth);

  /// Whether this point shape is hollow.
  final bool hollow;

  /// The stroke width of this point shape when it's hollow.
  final double strokeWidth;

  @override
  bool equalTo(Object other) =>
      other is PointShape &&
      hollow == other.hollow &&
      strokeWidth == other.strokeWidth;

  /// Draw each element of this point shape.
  MarkElement drawPoint(Attributes item, CoordConv coord);

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    final rst = <MarkElement>[];

    for (var item in group) {
      assert(item.shape is PointShape);

      var empty = false;
      for (var point in item.position) {
        if (!point.isFinite) {
          empty = true;
          break;
        }
      }
      if (empty) {
        continue;
      }

      rst.add((item.shape as PointShape).drawPoint(item, coord));
    }

    return rst;
  }

  @override
  List<MarkElement> drawGroupLabels(
      List<Attributes> group, CoordConv coord, Offset origin) {
    final rst = <MarkElement>[];

    for (var item in group) {
      assert(item.shape is PointShape);

      var empty = false;
      for (var point in item.position) {
        if (!point.isFinite) {
          empty = true;
          break;
        }
      }
      if (empty) {
        continue;
      }

      final size = item.size ?? defaultSize;
      if (item.label != null && item.label!.haveText) {
        final point = coord.convert(representPoint(item.position));
        final anchor = Offset(
          point.dx,
          point.dy + (size / 2),
        );
        rst.add(LabelElement(
          text: item.label!.text!,
          anchor: anchor,
          defaultAlign: Alignment.topCenter,
          style: item.label!.style,
          tag: item.tag,
        ));
      }
    }

    return rst;
  }

  @override
  double get defaultSize => 5;
}

/// A circle shape.
class CircleShape extends PointShape {
  /// Creates a circle shape.
  CircleShape({
    bool hollow = false,
    double strokeWidth = 1,
  }) : super(hollow, strokeWidth);

  @override
  bool equalTo(Object other) => super.equalTo(other) && other is CircleShape;

  @override
  MarkElement<ElementStyle> drawPoint(Attributes item, CoordConv coord) {
    final point = coord.convert(item.position.last);
    final size = item.size ?? defaultSize;
    return CircleElement(
      center: point,
      radius: size / 2,
      style: getPaintStyle(item, (item.shape as PointShape).hollow,
          (item.shape as PointShape).strokeWidth, null, null),
      tag: item.tag,
    );
  }
}

/// A square shape.
class SquareShape extends PointShape {
  /// Creates a square shape.
  SquareShape({
    bool hollow = false,
    double strokeWidth = 1,
  }) : super(hollow, strokeWidth);

  @override
  bool equalTo(Object other) => super.equalTo(other) && other is SquareShape;

  @override
  MarkElement<ElementStyle> drawPoint(Attributes item, CoordConv coord) {
    final point = coord.convert(item.position.last);
    final size = item.size ?? defaultSize;
    return RectElement(
      rect: Rect.fromCenter(center: point, width: size, height: size),
      style: getPaintStyle(item, (item.shape as PointShape).hollow,
          (item.shape as PointShape).strokeWidth, null, null),
      tag: item.tag,
    );
  }
}
