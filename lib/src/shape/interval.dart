import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/shape/util/aes_basic_item.dart';
import 'package:graphic/src/util/math.dart';

import 'function.dart';
import 'util/paths.dart';

abstract class IntervalShape extends FunctionShape {
  @override
  double get defaultSize => 15;
}

class RectShape extends IntervalShape {
  RectShape({
    this.histogram = false,
    this.labelPosition = 1,
    this.borderRadius,
  });

  final bool histogram;

  /// Relative label position of [0, 1] in the interval.
  final double labelPosition;

  /// X is circular and y is radial.
  final BorderRadius? borderRadius;

  @override
  bool equalTo(Object other) =>
    other is RectShape &&
    histogram == other.histogram &&
    labelPosition == other.labelPosition &&
    borderRadius == other.borderRadius;

  @override
  void paintGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
    Canvas canvas,
  ) {
    if (coord is RectCoordConv) {
      if (histogram) {
        // histogram

        // Histogram dosen't allow NaN measure value.

        // First item.
        Aes item = group.first;
        List<Offset> position = item.position;
        double bandStart = 0;
        double bandEnd = (group[1].position.first.dx + position.first.dx) / 2;
        _paintRect(
          item,
          Rect.fromPoints(
            coord.convert(Offset(bandStart, position[1].dy)),
            coord.convert(Offset(bandEnd, position[0].dy)),
          ),
          coord.convert(position[0] + (position[1] - position[0]) * labelPosition),
          coord,
          canvas,
        );
        // Middle items.
        for (var i = 1; i < group.length - 1; i++) {
          item = group[i];
          position = item.position;
          bandStart = (group[i].position.first.dx + group[i - 1].position.first.dx) / 2;
          bandEnd = (group[i + 1].position.first.dx + group[i].position.first.dx) / 2;
          _paintRect(
            item,
            Rect.fromPoints(
              coord.convert(Offset(bandStart, position[1].dy)),
              coord.convert(Offset(bandEnd, position[0].dy)),
            ),
            coord.convert(position[0] + (position[1] - position[0]) * labelPosition),
            coord,
            canvas,
          );
        }
        // Last item.
        item = group.last;
        position = item.position;
        bandStart = (position.first.dx + group[group.length - 2].position.first.dx) / 2;
        bandEnd = 1;
        _paintRect(
          item,
          Rect.fromPoints(
            coord.convert(Offset(bandStart, position[1].dy)),
            coord.convert(Offset(bandEnd, position[0].dy)),
          ),
          coord.convert(position[0] + (position[1] - position[0]) * labelPosition),
          coord,
          canvas,
        );
      } else {
        // bar

        for (var item in group) {
          for (var point in item.position) {
            if (!point.dy.isFinite) {
              return;
            }
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
          _paintRect(
            item,
            rect,
            start +  (end - start) * labelPosition,
            coord,
            canvas,
          );
        }
      }
    } else if (coord is PolarCoordConv) {
      // All sector interval shapes dosen't allow NaN measure value.

      if (coord.transposed) {
        if (coord.dim == 1) {
          // pie

          for (var item in group) {
            final position = item.position;
            _paintSector(
              item,
              coord.radiuses.last,
              coord.radiuses.first,
              coord.convertAngle(position[0].dy),
              coord.convertAngle(position[1].dy),
              true,
              coord.convert(Offset(
                labelPosition,
                (position[1].dy + position[0].dy) / 2,
              )),
              coord,
              canvas,
            );
          }
        } else {
          // race track

          for (var item in group) {
            final position = item.position;
            final r = coord.convertRadius(position[0].dx);
            final halfSize = (item.size ?? defaultSize) / 2;
            _paintSector(
              item,
              r - halfSize,
              r + halfSize,
              coord.convertAngle(position[0].dy),
              coord.convertAngle(position[1].dy),
              false,
              coord.convert(Offset(
                labelPosition,
                (position[1].dy - position[0].dy) / 2,
              )),
              coord,
              canvas,
            );
            if (item.label != null) {
              paintLabel(
                item.label!,
                coord.convert(position[0] + (position[1] - position[0]) * labelPosition),
                Alignment.center,
                canvas,
              );
            }
          }
        }
      } else {
        if (coord.dim == 1) {
          // bull eye

          for (var item in group) {
            _paintSector(
              item,
              coord.radiuses.last,
              coord.radiuses.first,
              coord.angles.first,
              coord.angles.last,
              true,
              coord.convert(
                item.position[0] + (item.position[1] - item.position[0]) * labelPosition
              ),
              coord,
              canvas,
            );
          }
        } else {
          // rose

          // First item.
          Aes item = group.first;
          List<Offset> position = group.first.position;
          double bandStart = 0;
          double bandEnd = (group[1].position.first.dx + position.first.dx) / 2;
          _paintSector(
            item,
            coord.convertRadius(position[1].dy),
            coord.convertRadius(position[0].dy),
            coord.convertAngle(bandStart),
            coord.convertAngle(bandEnd),
            true,
            coord.convert(position[0] + (position[1] - position[0]) * labelPosition),
            coord,
            canvas,
          );
          // Middle items.
          for (var i = 1; i < group.length - 1; i++) {
            item = group[i];
            position = item.position;
            bandStart = (group[i].position.first.dx + group[i - 1].position.first.dx) / 2;
            bandEnd = (group[i + 1].position.first.dx + group[i].position.first.dx) / 2;
            _paintSector(
              item,
              coord.convertRadius(position[1].dy),
              coord.convertRadius(position[0].dy),
              coord.convertAngle(bandStart),
              coord.convertAngle(bandEnd),
              true,
              coord.convert(position[0] + (position[1] - position[0]) * labelPosition),
              coord,
              canvas,
            );
          }
          // Last item.
          item = group.last;
          position = item.position;
          bandStart = (position.first.dx + group[group.length - 2].position.first.dx) / 2;
          bandEnd = 1;
          _paintSector(
            item,
            coord.convertRadius(position[1].dy),
            coord.convertRadius(position[0].dy),
            coord.convertAngle(bandStart),
            coord.convertAngle(bandEnd),
            true,
            coord.convert(position[0] + (position[1] - position[0]) * labelPosition),
            coord,
            canvas,
          );
        }
      }
    }
  }

  void _paintRect(
    Aes item,
    Rect rect,
    Offset labelAnchor,
    CoordConv coord,
    Canvas canvas,
  ) {
    assert(item.shape is RectShape);

    final path = Path();
    if (borderRadius != null) {
      path.addRRect(RRect.fromRectAndCorners(
        rect,
        topLeft: borderRadius!.topLeft,
        topRight: borderRadius!.topRight,
        bottomRight: borderRadius!.bottomRight,
        bottomLeft: borderRadius!.bottomLeft,
      ));
    } else {
      path.addRect(rect);
    }
    aesBasicItem(
      path,
      item,
      false,
      0,
      canvas,
    );
    if (item.label != null) {
      paintLabel(
        item.label!,
        labelAnchor,
        labelPosition.equalTo(1)
          ? (coord.transposed ? Alignment.centerRight : Alignment.topCenter)
          : Alignment.center,
        canvas,
      );
    }
  }

  void _paintSector(
    Aes item,
    double r,
    double r0,
    double startAngle,
    double endAngle,
    bool hasLabel,
    Offset labelAnchor,
    PolarCoordConv coord,
    Canvas canvas,
  ) {
    assert(item.shape is RectShape);

    Path path;
    if (borderRadius != null) {
      path = Paths.rsector(
        center: coord.center,
        r: r,
        r0: r0,
        startAngle: startAngle,
        endAngle: endAngle,
        clockwise: true,
        topLeft: borderRadius!.topLeft,
        topRight: borderRadius!.topRight,
        bottomRight: borderRadius!.bottomRight,
        bottomLeft: borderRadius!.bottomLeft,
      );
    } else {
      path = Paths.sector(
        center: coord.center,
        r: r,
        r0: r0,
        startAngle: startAngle,
        endAngle: endAngle,
        clockwise: true,
      );
    }
    aesBasicItem(
      path,
      item,
      false,
      0,
      canvas,
    );
    if (hasLabel && item.label != null) {
      Alignment align;
      if (labelPosition == 1) {
        // According to anchor's quadrant.
        final anchorOffset = labelAnchor - coord.center;
        align = Alignment(
          anchorOffset.dx.equalTo(0)
            ? 0
            : anchorOffset.dx / anchorOffset.dx.abs(),
          anchorOffset.dy.equalTo(0)
            ? 0
            : anchorOffset.dy / anchorOffset.dy.abs(),
        );
      } else {
        align = Alignment.center;
      }
      paintLabel(
        item.label!,
        labelAnchor,
        align,
        canvas,
      );
    }
  }

  @override
  void paintItem(
    Aes item,
    CoordConv coord,
    Offset origin,
    Canvas canvas,
  ) => throw UnimplementedError('Use _paintRect or _paintSector instead.');
}

class FunnelShape extends IntervalShape {
  FunnelShape({
    this.labelPosition = 0.5,
    this.pyramid = false,
  });

  /// Relative label position of [0, 1] in the interval.
  final double labelPosition;

  /// Funnel means the width is decreasing and the last bar close to zero.
  /// Pyramid is reversed.
  final bool pyramid;

  @override
  bool equalTo(Object other) =>
    other is FunnelShape &&
    labelPosition == other.labelPosition &&
    pyramid == other.pyramid;

  @override
  void paintGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
    Canvas canvas,
  ) {
    assert(coord is RectCoordConv);

    // First item.
    Aes item = group.first;
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
    _paintSlope(
      item,
      corners,
      coord.convert(position[0] + (position[1] - position[0]) * labelPosition),
      coord,
      canvas,
    );
    // Middle items.
    for (var i = 1; i < group.length - 1; i++) {
      item = group[i];
      position = item.position;
      bandStart = (group[i].position.first.dx + group[i - 1].position.first.dx) / 2;
      bandEnd = (group[i + 1].position.first.dx + group[i].position.first.dx) / 2;
      corners = [
        coord.convert(Offset(bandStart, position[1].dy)),
        coord.convert(Offset(bandEnd, group[i + 1].position[1].dy)),
        coord.convert(Offset(bandEnd, group[i + 1].position[0].dy)),
        coord.convert(Offset(bandStart, position[0].dy)),
      ];
      _paintSlope(
        item,
        corners,
        coord.convert(position[0] + (position[1] - position[0]) * labelPosition),
        coord,
        canvas,
      );
    }
    // Last item.
    item = group.last;
    position = item.position;
    bandStart = (position.first.dx + group[group.length - 2].position.first.dx) / 2;
    bandEnd = 1;
    final closeStart = pyramid ? origin.dy : position[0].dy;
    final closeEnd = pyramid ? origin.dy : position[1].dy;
    corners = [
      coord.convert(Offset(bandStart, position[1].dy)),
      coord.convert(Offset(bandEnd, closeEnd)),
      coord.convert(Offset(bandEnd, closeStart)),
      coord.convert(Offset(bandStart, position[0].dy)),
    ];
    _paintSlope(
      item,
      corners,
      coord.convert(position[0] + (position[1] - position[0]) * labelPosition),
      coord,
      canvas,
    );
  }

  void _paintSlope(
    Aes item,
    List<Offset> corners,
    Offset labelAnchor,
    CoordConv coord,
    Canvas canvas,
  ) {
    assert(item.shape is FunnelShape);

    final path = Path();
    path.addPolygon(corners, true);
    aesBasicItem(
      path,
      item,
      false,
      0,
      canvas,
    );
    if (item.label != null) {
      paintLabel(
        item.label!,
        labelAnchor,
        labelPosition.equalTo(1)
          ? (coord.transposed ? Alignment.centerRight : Alignment.topCenter)
          : labelPosition.equalTo(0)
            ? (coord.transposed ? Alignment.centerLeft : Alignment.bottomCenter)
            : Alignment.center,
        canvas,
      );
    }
  }

  @override
  void paintItem(
    Aes item,
    CoordConv coord,
    Offset origin,
    Canvas canvas,
  ) => throw UnimplementedError('Use _paintSlope instead.');
}
