import 'package:flutter/painting.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/graffiti/element/polygon.dart';
import 'package:graphic/src/graffiti/element/rect.dart';
import 'package:graphic/src/graffiti/element/sector.dart';
import 'package:graphic/src/mark/interval.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/guide/axis/radial.dart';
import 'package:graphic/src/util/math.dart';

import 'util/style.dart';
import 'function.dart';

/// The shape for the interval mark.
///
/// See also:
///
/// - [IntervalMark], which this shape is for.
abstract class IntervalShape extends FunctionShape {
  @override
  double get defaultSize => 15;
}

/// A rectangle or sector shape.
///
/// The shape is a rectangle in a rectangle coordinate or a sector in a polar coordinate.
class RectShape extends IntervalShape {
  /// Creates a rectangle shape.
  RectShape({
    this.histogram = false,
    this.labelPosition = 1,
    this.borderRadius,
  });

  /// Whether the shape is a histogram.
  ///
  /// For a histogram, the bar width fills all the band.
  final bool histogram;

  /// The position ratio of the label in the interval.
  /// 
  /// It is a normalized value of `[0, 1]`, which 1 means top and 0 means bottom.
  /// 
  /// Note for pie chart, the label radius position is controlled by PolarCoord.dimFill, labelPosition will not work.
  final double labelPosition;

  /// The border radius of the rectangle or sector.
  ///
  /// For a sector, [Radius.x] is circular, [Radius.y] is radial, top is outer side,
  /// bottom is inner side, left is anticlockwise, right is clockwise.
  final BorderRadius? borderRadius;

  @override
  bool equalTo(Object other) =>
      other is RectShape &&
      histogram == other.histogram &&
      labelPosition == other.labelPosition &&
      borderRadius == other.borderRadius;

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    final rst = <MarkElement>[];

    if (coord is RectCoordConv) {
      if (histogram) {
        // Histogram shape dosen't allow NaN value.

        // First item.
        Attributes item = group.first;
        List<Offset> position = item.position;
        double bandStart = 0;
        double bandEnd = (group[1].position.first.dx + position.first.dx) / 2;
        rst.add(_drawRectPrimitive(
          item,
          Rect.fromPoints(
            coord.convert(Offset(bandStart, position[1].dy)),
            coord.convert(Offset(bandEnd, position[0].dy)),
          ),
          coord,
        ));
        // Middle items.
        for (var i = 1; i < group.length - 1; i++) {
          item = group[i];
          position = item.position;
          bandStart =
              (group[i].position.first.dx + group[i - 1].position.first.dx) / 2;
          bandEnd =
              (group[i + 1].position.first.dx + group[i].position.first.dx) / 2;
          rst.add(_drawRectPrimitive(
            item,
            Rect.fromPoints(
              coord.convert(Offset(bandStart, position[1].dy)),
              coord.convert(Offset(bandEnd, position[0].dy)),
            ),
            coord,
          ));
        }
        // Last item.
        item = group.last;
        position = item.position;
        bandStart =
            (position.first.dx + group[group.length - 2].position.first.dx) / 2;
        bandEnd = 1;
        rst.add(_drawRectPrimitive(
          item,
          Rect.fromPoints(
            coord.convert(Offset(bandStart, position[1].dy)),
            coord.convert(Offset(bandEnd, position[0].dy)),
          ),
          coord,
        ));
      } else {
        // Bar.

        for (var item in group) {
          bool nan = false;
          for (var point in item.position) {
            if (!point.dy.isFinite) {
              nan = true;
              break;
            }
          }
          if (nan) {
            continue;
          }

          final start = coord.convert(item.position[0]);
          final end = coord.convert(item.position[1]);
          final size = item.size ?? defaultSize;
          Rect rect;
          if (coord.transposed) {
            rect = Rect.fromLTRB(
              start.dx,
              start.dy - size / 2,
              end.dx,
              start.dy + size / 2,
            );
          } else {
            rect = Rect.fromLTRB(
              end.dx - size / 2,
              end.dy,
              end.dx + size / 2,
              start.dy,
            );
          }
          rst.add(_drawRectPrimitive(
            item,
            rect,
            coord,
          ));
        }
      }
    } else if (coord is PolarCoordConv) {
      // All sector interval shapes dosen't allow NaN value.

      if (coord.transposed) {
        if (coord.dimCount == 1) {
          // Pie.

          for (var item in group) {
            final position = item.position;
            rst.add(_drawSectorPrimitive(
              item,
              coord.radiuses.last,
              coord.radiuses.first,
              coord.convertAngle(position[0].dy),
              coord.convertAngle(position[1].dy),
              coord,
            ));
          }
        } else {
          // Race track.

          for (var item in group) {
            final position = item.position;
            final r = coord.convertRadius(position[0].dx);
            final halfSize = (item.size ?? defaultSize) / 2;
            final rstItem = _drawSectorPrimitive(
              item,
              r + halfSize,
              r - halfSize,
              coord.convertAngle(position[0].dy),
              coord.convertAngle(position[1].dy),
              coord,
            );
            rst.add(rstItem);
          }
        }
      } else {
        if (coord.dimCount == 1) {
          // Bull eye.

          for (var item in group) {
            rst.add(_drawSectorPrimitive(
              item,
              coord.convertRadius(item.position[1].dy),
              coord.convertRadius(item.position[0].dy),
              coord.angles.first,
              coord.angles.last,
              coord,
            ));
          }
        } else {
          // Rose.

          // First item.
          Attributes item = group.first;
          List<Offset> position = group.first.position;
          double bandStart = 0;
          double bandEnd = (group[1].position.first.dx + position.first.dx) / 2;
          rst.add(_drawSectorPrimitive(
            item,
            coord.convertRadius(position[1].dy),
            coord.convertRadius(position[0].dy),
            coord.convertAngle(bandStart),
            coord.convertAngle(bandEnd),
            coord,
          ));
          // Middle items.
          for (var i = 1; i < group.length - 1; i++) {
            item = group[i];
            position = item.position;
            bandStart =
                (group[i].position.first.dx + group[i - 1].position.first.dx) /
                    2;
            bandEnd =
                (group[i + 1].position.first.dx + group[i].position.first.dx) /
                    2;
            rst.add(_drawSectorPrimitive(
              item,
              coord.convertRadius(position[1].dy),
              coord.convertRadius(position[0].dy),
              coord.convertAngle(bandStart),
              coord.convertAngle(bandEnd),
              coord,
            ));
          }
          // Last item.
          item = group.last;
          position = item.position;
          bandStart =
              (position.first.dx + group[group.length - 2].position.first.dx) /
                  2;
          bandEnd = 1;
          rst.add(_drawSectorPrimitive(
            item,
            coord.convertRadius(position[1].dy),
            coord.convertRadius(position[0].dy),
            coord.convertAngle(bandStart),
            coord.convertAngle(bandEnd),
            coord,
          ));
        }
      }
    }

    return rst;
  }

  @override
  List<MarkElement> drawGroupLabels(
      List<Attributes> group, CoordConv coord, Offset origin) {
    final rst = <MarkElement>[];

    if (coord is RectCoordConv) {
      // Bar and histogram.

      for (var item in group) {
        bool nan = false;
        for (var point in item.position) {
          if (!point.dy.isFinite) {
            nan = true;
            break;
          }
        }
        if (!nan && item.label != null) {
          final start = coord.convert(item.position[0]);
          final end = coord.convert(item.position[1]);
          rst.add(_drawRectLabel(
            item,
            start + (end - start) * (item.shape as RectShape).labelPosition,
            coord,
          ));
        }
      }
    } else if (coord is PolarCoordConv) {
      // All sector interval shapes dosen't allow NaN value.

      if (coord.transposed) {
        if (coord.dimCount == 1) {
          // Pie.

          for (var item in group) {
            if (item.label != null) {
              final position = item.position;
              rst.add(_drawSectorLabel(
                item,
                coord.convert(Offset(
                  (item.shape as RectShape).labelPosition,
                  (position[1].dy + position[0].dy) / 2,
                )),
                coord,
              ));
            }
          }
        } else {
          // Race track.

          for (var item in group) {
            if (item.label != null && item.label!.haveText) {
              final position = item.position;
              final labelAnchor = coord.convert(position[0] +
                  (position[1] - position[0]) *
                      (item.shape as RectShape).labelPosition);
              final anchorOffset = labelAnchor - coord.center;
              rst.add(LabelElement(
                text: item.label!.text!,
                anchor: labelAnchor,
                defaultAlign: radialLabelAlign(anchorOffset) * -1,
                style: item.label!.style,
                tag: item.tag,
              ));
            }
          }
        }
      } else {
        // Bull eye and rose.

        for (var item in group) {
          if (item.label != null) {
            rst.add(_drawSectorLabel(
                item,
                coord.convert(item.position[0] +
                    (item.position[1] - item.position[0]) *
                        (item.shape as RectShape).labelPosition),
                coord));
          }
        }
      }
    }

    return rst;
  }

  /// Renders a rectangle interval item.
  ///
  /// The first is basic and last is label.
  MarkElement _drawRectPrimitive(
    Attributes item,
    Rect rect,
    CoordConv coord,
  ) {
    assert(item.shape is RectShape);

    final style = getPaintStyle(item, false, 0, coord.region, null);

    return RectElement(
        rect: rect,
        borderRadius: (item.shape as RectShape).borderRadius,
        style: style,
        tag: item.tag);
  }

  MarkElement _drawRectLabel(
    Attributes item,
    Offset labelAnchor,
    CoordConv coord,
  ) {
    assert(item.shape is RectShape);

    return LabelElement(
        text: item.label!.text!,
        anchor: labelAnchor,
        defaultAlign: (item.shape as RectShape).labelPosition.equalTo(1)
            ? (coord.transposed ? Alignment.centerRight : Alignment.topCenter)
            : Alignment.center,
        style: item.label!.style,
        tag: item.tag);
  }

  /// Renders a sector interval item.
  ///
  /// The first is basic and last is label.
  MarkElement _drawSectorPrimitive(
    Attributes item,
    double r,
    double r0,
    double startAngle,
    double endAngle,
    PolarCoordConv coord,
  ) {
    assert(item.shape is RectShape);

    final style = getPaintStyle(item, false, 0, coord.region, null);

    return SectorElement(
      center: coord.center,
      endRadius: r,
      startRadius: r0,
      startAngle: startAngle,
      endAngle: endAngle,
      borderRadius: (item.shape as RectShape).borderRadius,
      style: style,
      tag: item.tag,
    );
  }

  MarkElement _drawSectorLabel(
    Attributes item,
    Offset labelAnchor,
    PolarCoordConv coord,
  ) {
    assert(item.shape is RectShape);

    Alignment defaultAlign;
    if ((item.shape as RectShape).labelPosition == 1) {
      // Calculate default alignment according to anchor's quadrant.
      final anchorOffset = labelAnchor - coord.center;
      defaultAlign = Alignment(
        anchorOffset.dx.equalTo(0)
            ? 0
            : anchorOffset.dx / anchorOffset.dx.abs(),
        anchorOffset.dy.equalTo(0)
            ? 0
            : anchorOffset.dy / anchorOffset.dy.abs(),
      );
    } else {
      defaultAlign = Alignment.center;
    }

    return LabelElement(
      text: item.label!.text!,
      anchor: labelAnchor,
      defaultAlign: defaultAlign,
      style: item.label!.style,
      tag: item.tag,
    );
  }
}

/// A funnel or pyramid shape.
///
/// Note that the shape will not sort the mark items. Sort the input data if
/// you want the intervals monotone.
class FunnelShape extends IntervalShape {
  /// Creates a funnel shape.
  FunnelShape({
    this.labelPosition = 0.5,
    this.pyramid = false,
  });

  /// The position ratio of the label in the interval.
  final double labelPosition;

  /// Whether this shape is a pyramid.
  ///
  /// A pyramid will decrease the value of last item to zero, while a funnel keeps
  /// unchanged.
  final bool pyramid;

  @override
  bool equalTo(Object other) =>
      other is FunnelShape &&
      labelPosition == other.labelPosition &&
      pyramid == other.pyramid;

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    assert(coord is RectCoordConv);

    final rst = <MarkElement>[];

    // First item.
    Attributes item = group.first;
    List<Offset> position = item.position;
    double bandStart = 0;
    double bandEnd = (group[1].position.first.dx + position.first.dx) / 2;
    // [topLeft, topRight, bottomRight, bottomLeft]
    List<Offset> corners = [
      coord.convert(Offset(bandStart, position[1].dy)),
      coord.convert(Offset(bandEnd, group[1].position[1].dy)),
      coord.convert(Offset(bandEnd, group[1].position[0].dy)),
      coord.convert(Offset(bandStart, position[0].dy)),
    ];
    rst.add(PolygonElement(
        points: corners,
        style: getPaintStyle(item, false, 0, coord.region, null),
        tag: item.tag));
    // Middle items.
    for (var i = 1; i < group.length - 1; i++) {
      item = group[i];
      position = item.position;
      bandStart =
          (group[i].position.first.dx + group[i - 1].position.first.dx) / 2;
      bandEnd =
          (group[i + 1].position.first.dx + group[i].position.first.dx) / 2;
      corners = [
        coord.convert(Offset(bandStart, position[1].dy)),
        coord.convert(Offset(bandEnd, group[i + 1].position[1].dy)),
        coord.convert(Offset(bandEnd, group[i + 1].position[0].dy)),
        coord.convert(Offset(bandStart, position[0].dy)),
      ];
      rst.add(PolygonElement(
          points: corners,
          style: getPaintStyle(item, false, 0, coord.region, null),
          tag: item.tag));
    }
    // Last item.
    item = group.last;
    position = item.position;
    bandStart =
        (position.first.dx + group[group.length - 2].position.first.dx) / 2;
    bandEnd = 1;
    final closeStart = pyramid ? origin.dy : position[0].dy;
    final closeEnd = pyramid ? origin.dy : position[1].dy;
    corners = [
      coord.convert(Offset(bandStart, position[1].dy)),
      coord.convert(Offset(bandEnd, closeEnd)),
      coord.convert(Offset(bandEnd, closeStart)),
      coord.convert(Offset(bandStart, position[0].dy)),
    ];
    rst.add(PolygonElement(
        points: corners,
        style: getPaintStyle(item, false, 0, coord.region, null),
        tag: item.tag));

    return rst;
  }

  @override
  List<MarkElement> drawGroupLabels(
      List<Attributes> group, CoordConv coord, Offset origin) {
    assert(coord is RectCoordConv);

    final rst = <MarkElement>[];

    for (var item in group) {
      if (item.label != null) {
        final labelAnchor = coord.convert(item.position[0] +
            (item.position[1] - item.position[0]) *
                (item.shape as FunnelShape).labelPosition);
        rst.add(LabelElement(
          text: item.label!.text!,
          anchor: labelAnchor,
          defaultAlign: (item.shape as FunnelShape).labelPosition.equalTo(1)
              ? (coord.transposed ? Alignment.centerRight : Alignment.topCenter)
              : (item.shape as FunnelShape).labelPosition.equalTo(0)
                  ? (coord.transposed
                      ? Alignment.centerLeft
                      : Alignment.bottomCenter)
                  : Alignment.center,
          style: item.label!.style,
          tag: item.tag,
        ));
      }
    }

    return rst;
  }
}
