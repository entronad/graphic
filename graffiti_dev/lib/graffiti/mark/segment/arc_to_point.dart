import 'dart:ui';
import 'dart:math';

import 'segment.dart';
import 'cubic.dart';

Offset _rotateVector(double x, double y, double angle) => Offset(
  x * cos(angle) - y * sin(angle),
  x * sin(angle) + y * cos(angle),
);

List<double> _arcToCubic(
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

    final k = (largeArc == clockwise ? -1 : 1) * sqrt(((rx2 * ry2 - rx2 * y * y - ry2 * x * x) / (rx2 * y * y + ry2 * x * x)).abs());

    final cx = (k * rx * y) / ry + (x1 + x2) / 2;
    final cy = (k * -ry * x) / rx + (y1 + y2) / 2;
    var f1 = asin(((((y1 - cy) / ry) * 1000000000).toInt()) / 1000000000);
    var f2 = asin(((((y2 - cy) / ry) * 1000000000).toInt()) / 1000000000);

    f1 = x1 < cx ? pi - f1 : f1;
    f2 = x2 < cx ? pi - f2 : f2;
    if (f1 < 0) {
      f1 = pi * 2 + f1;
    }
    if (f2 < 0) {
      f2 = pi * 2 + f2;
    }
    if (clockwise && f1 > f2) {
      f1 -= pi *2;
    }
    if (!clockwise && f2 > f1) {
      f2 -= pi *2;
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
    rst = _arcToCubic(x2, y2, rx, ry, angle, false, clockwise, preX2, preY2, [f2, preF2, cx, cy]);
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
    return m2..addAll(m3)..addAll(m4)..addAll(rst);
  }

  rst = m2..addAll(m3)..addAll(m4)..addAll(rst);
  final newRst = <double>[];
  for (var i = 0, ii = rst.length; i < ii; i += 1) {
    newRst[i] = (i % 2 != 0) ? _rotateVector(rst[i - 1], rst[i], angle).dy : _rotateVector(rst[i], rst[i + 1], angle).dx;
  }
  return newRst;
}

class ArcToPointSegment extends Segment {
  ArcToPointSegment({
    required this.end,
    this.radius = Radius.zero,
    this.rotation = 0,
    this.largeArc = false,
    this.clockwise = true,

    String? tag,
  }) : super(
    tag: tag,
  );

  final Offset end;

  final Radius radius;

  final double rotation;

  final bool largeArc;

  final bool clockwise;
  
  @override
  void drawPath(Path path) =>
    path.arcToPoint(end, radius: radius, rotation: rotation, largeArc: largeArc, clockwise: clockwise);

  @override
  ArcToPointSegment lerpFrom(covariant ArcToPointSegment from, double t) => ArcToPointSegment(
    end: Offset.lerp(from.end, end, t)!,
    radius: Radius.lerp(from.radius, radius, t)!,
    rotation: lerpDouble(from.rotation, rotation, t)!,
    largeArc: largeArc,
    clockwise: clockwise,
    tag: tag,
  );

  @override
  CubicSegment toCubic(Offset start) {
    final rst = _arcToCubic(start.dx, start.dy, radius.x, radius.y, rotation, largeArc, clockwise, end.dx, end.dy, null);
    return CubicSegment(
      control1: Offset(rst[0], rst[1]),
      control2: Offset(rst[2], rst[3]),
      end: end,
      tag: tag,
    );
  }
  
  @override
  ArcToPointSegment sow(Offset position) => ArcToPointSegment(
    end: position,
    rotation: rotation,
    largeArc: largeArc,
    clockwise: clockwise,
    tag: tag,
  );
  
  @override
  Offset getEnd() => end;
}
