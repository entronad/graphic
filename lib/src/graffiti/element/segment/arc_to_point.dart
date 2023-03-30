import 'dart:ui';
import 'dart:math';

import 'segment.dart';
import 'cubic.dart';
import 'line.dart';

/// Rotates a vector.
Offset _rotateVector(double x, double y, double angle) => Offset(
      x * cos(angle) - y * sin(angle),
      x * sin(angle) + y * cos(angle),
    );

/// Converts an arc to cubic control points.
List<double> _arcToCubicControls(
  double x1,
  double y1,
  double rx,
  double ry,
  double angle,
  bool largeArc,
  bool clockwise,
  double x2,
  double y2,
  List<double>? recursive,
) {
  const d120 = (pi * 120) / 180;

  var rst = <double>[];
  late Offset xy;
  late double f1;
  late double f2;
  late double cx;
  late double cy;

  if (recursive == null) {
    xy = _rotateVector(x1, y1, -angle);
    x1 = xy.dx;
    y1 = xy.dy;
    xy = _rotateVector(x2, y2, -angle);
    x2 = xy.dx;
    y2 = xy.dy;

    final x = (x1 - x2) / 2;
    final y = (y1 - y2) / 2;
    var h = (x * x) / (rx * rx) + (y * y) / (ry * ry);
    if (h > 1) {
      h = sqrt(h);
      rx *= h;
      ry *= h;
    }
    final rx2 = rx * rx;
    final ry2 = ry * ry;

    final k = (largeArc == clockwise ? -1 : 1) *
        sqrt(((rx2 * ry2 - rx2 * y * y - ry2 * x * x) /
                (rx2 * y * y + ry2 * x * x))
            .abs());

    cx = (k * rx * y) / ry + (x1 + x2) / 2;
    cy = (k * -ry * x) / rx + (y1 + y2) / 2;
    f1 = asin(((((y1 - cy) / ry) * 1000000000).toInt()) / 1000000000);
    f2 = asin(((((y2 - cy) / ry) * 1000000000).toInt()) / 1000000000);

    f1 = x1 < cx ? pi - f1 : f1;
    f2 = x2 < cx ? pi - f2 : f2;
    if (f1 < 0) {
      f1 = pi * 2 + f1;
    }
    if (f2 < 0) {
      f2 = pi * 2 + f2;
    }
    if (clockwise && f1 > f2) {
      f1 -= pi * 2;
    }
    if (!clockwise && f2 > f1) {
      f2 -= pi * 2;
    }
  } else {
    f1 = recursive[0];
    f2 = recursive[1];
    cx = recursive[2];
    cy = recursive[3];
  }
  var df = f2 - f1;
  if (df.abs() > d120) {
    final preF2 = f2;
    final preX2 = x2;
    final preY2 = y2;
    f2 = f1 + d120 * (clockwise && f2 > f1 ? 1 : -1);
    x2 = cx + rx * cos(f2);
    y2 = cy + rx * sin(f2);
    rst = _arcToCubicControls(x2, y2, rx, ry, angle, false, clockwise, preX2,
        preY2, [f2, preF2, cx, cy]);
  }
  final c1 = cos(f1);
  final s1 = sin(f1);
  final c2 = cos(f2);
  final s2 = sin(f2);
  final t = tan(df / 4);
  final hx = (4 / 3) * rx * t;
  final hy = (4 / 3) * ry * t;
  final m1 = [x1, y1];
  final m2 = [x1 + hx * s1, y1 - hy * c1];
  final m3 = [x2 + hx * s2, y2 - hy * c2];
  final m4 = [x2, y2];
  m2[0] = 2 * m1[0] - m2[0];
  m2[1] = 2 * m1[1] - m2[1];
  if (recursive != null) {
    return [...m2, ...m3, ...m4, ...rst];
  }

  rst = [...m2, ...m3, ...m4, ...rst];
  final newRst = <double>[];
  for (var i = 0, ii = rst.length; i < ii; i += 1) {
    newRst.add((i % 2 != 0)
        ? _rotateVector(rst[i - 1], rst[i], angle).dy
        : _rotateVector(rst[i], rst[i + 1], angle).dx);
  }
  return newRst;
}

/// An arc-to-point segment like [Path.arcToPoint].
class ArcToPointSegment extends Segment {
  /// Creates an arc-to-point segment
  ArcToPointSegment({
    required this.end,
    required this.radius,
    required this.rotation,
    required this.largeArc,
    required this.clockwise,
    String? tag,
  }) : super(
          tag: tag,
        );

  /// The end point of this arc.
  final Offset end;

  /// The radius of this arc.
  final Radius radius;

  /// The rotation of this arc.
  final double rotation;

  /// Whether this arc is a large arc.
  final bool largeArc;

  /// Whether this arc is clockwise.
  final bool clockwise;

  @override
  void drawPath(Path path) => path.arcToPoint(end,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise);

  @override
  ArcToPointSegment lerpFrom(covariant ArcToPointSegment from, double t) =>
      ArcToPointSegment(
        end: Offset.lerp(from.end, end, t)!,
        radius: Radius.lerp(from.radius, radius, t)!,
        rotation: lerpDouble(from.rotation, rotation, t)!,
        largeArc: largeArc,
        clockwise: clockwise,
        tag: tag,
      );

  @override
  CubicSegment toCubic(Offset start) {
    late final List<Offset> controlsRst;

    if (radius.x == 0 || radius.y == 0) {
      controlsRst = lineToCubicControls(start, end);
    } else {
      final xyRst = _arcToCubicControls(start.dx, start.dy, radius.x, radius.y,
          rotation, largeArc, clockwise, end.dx, end.dy, null);
      controlsRst = [
        Offset(xyRst[0], xyRst[1]),
        Offset(xyRst[2], xyRst[3]),
      ];
    }

    return CubicSegment(
      control1: controlsRst.first,
      control2: controlsRst.last,
      end: end,
      tag: tag,
    );
  }

  @override
  ArcToPointSegment sow(Offset position) => ArcToPointSegment(
        end: position,
        radius: radius,
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise,
        tag: tag,
      );

  @override
  Offset getEnd() => end;

  @override
  bool operator ==(Object other) =>
      other is ArcToPointSegment &&
      super == other &&
      end == other.end &&
      radius == other.radius &&
      rotation == other.rotation &&
      largeArc == other.largeArc &&
      clockwise == other.clockwise;
}
