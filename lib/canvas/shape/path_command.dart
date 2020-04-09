import 'dart:ui';

import '../math/quadratic.dart' as quadratic;
import '../math/cubic.dart' as cubic;
import '../util/in_stroke/line.dart' show inLine;
import '../math/line.dart' as line;

abstract class PathCommand {
  void applyTo(Path path);
}

abstract class AbsolutePathCommand extends PathCommand {
  List<Offset> get points;

  AbsolutePathCommand lerp(AbsolutePathCommand target, double t);

  bool inStroke(Offset prePoint, double lineWidth, Offset refPoint);

  double getLength(Offset prePoint);

  Offset getPoint(Offset prePoint, double ratio);
}

abstract class RelativePathCommand extends PathCommand {
  AbsolutePathCommand toAbsolute(Offset prePoint);
}

class Close extends AbsolutePathCommand {
  @override
  void applyTo(Path path) {
    path.close();
  }

  @override
  List<Offset> get points => <Offset>[];

  @override
  Close lerp(AbsolutePathCommand target, double t) {
    assert(target is Close);
    return Close();
  }

  // The following methods results depend on start point,
  // so they return null to to remind for extra handling.

  @override
  double getLength(Offset prePoint) => null;

  @override
  Offset getPoint(Offset prePoint, double ratio) => null;

  @override
  bool inStroke(Offset prePoint, double lineWidth, Offset refPoint) => null;
}

class ArcToPoint extends AbsolutePathCommand {
  ArcToPoint(
    this.arcEnd,
    {this.radius = Radius.zero,
    this.rotation = 0.0,
    this.largeArc = false,
    this.clockwise = true,});
  
  final Offset arcEnd;

  final Radius radius;

  final double rotation;

  final bool largeArc;

  final bool clockwise;

  @override
  void applyTo(Path path) {
    path.arcToPoint(
      arcEnd,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  @override
  List<Offset> get points => [arcEnd];

  @override
  ArcToPoint lerp(AbsolutePathCommand target, double t) {
    final _target = target as ArcToPoint;
    return ArcToPoint(
      Offset.lerp(arcEnd, _target.arcEnd, t),
      radius: _target.radius,
      rotation: _target.rotation,
      largeArc: _target.largeArc,
      clockwise: _target.clockwise,
    );
  }

  @override
  double getLength(Offset prePoint) {
    final path = Path()
      ..moveTo(prePoint.dx, prePoint.dy)
      ..arcToPoint(
        arcEnd,
        radius: radius,
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise,
      );
    final metric = path.computeMetrics().first;

    return metric.length;
  }

  @override
  Offset getPoint(Offset prePoint, double ratio) {
    final path = Path()
      ..moveTo(prePoint.dx, prePoint.dy)
      ..arcToPoint(
        arcEnd,
        radius: radius,
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise,
      );
    final metric = path.computeMetrics().first;

    final distance = ratio * metric.length;
    final point = metric.getTangentForOffset(distance).position;
    return point;
  }

  @override
  bool inStroke(Offset prePoint, double lineWidth, Offset refPoint) {
    final r = lineWidth / 2;
    final dx0 = arcEnd.dx - prePoint.dx;
    final dy0 = arcEnd.dy - prePoint.dy;
    var k = r / (dx0 * dx0 + dy0 * dy0);
    // The sign of k represents "is clockwise".
    k *= clockwise ? 1 : -1;
    // Define "clockwise offset" has a positive dx and a negtive dy.
    final dx = k * dy0;
    final dy = -k * dx0;
    final offset = Offset(dx, dy);
    // Define inner as clockwise and outer is anticlockwise.
    final innerPre = prePoint + offset;
    final outerPre = prePoint - offset;
    final innerEnd = arcEnd + offset;
    final outerEnd = arcEnd - offset;
    // Inner has a smaller radius.
    final dr = Radius.circular(r);
    final innerRadius = radius - dr;
    final outerRadius = radius + dr;
    final path = Path()
      ..moveTo(innerPre.dx, innerPre.dy)
      ..arcToPoint(
        innerEnd,
        radius: innerRadius,  
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise,
      )
      ..lineTo(outerEnd.dx, outerEnd.dy)
      ..moveTo(innerPre.dx, innerPre.dy)
      ..lineTo(outerPre.dx, outerPre.dy)
      ..arcToPoint(
        outerEnd,
        radius: outerRadius,
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise,
      );

    return path.contains(refPoint);
  }
}

class CubicTo extends AbsolutePathCommand {
  CubicTo(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);

  final double x1;

  final double y1;

  final double x2;

  final double y2;

  final double x3;

  final double y3;

  @override
  void applyTo(Path path) {
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  List<Offset> get points => [Offset(x1, y1), Offset(x2, y2), Offset(x3, y3)];

  @override
  CubicTo lerp(AbsolutePathCommand target, double t) {
    final _target = target as CubicTo;
    return CubicTo(
      lerpDouble(x1, _target.x1, t),
      lerpDouble(y1, _target.y1, t),
      lerpDouble(x2, _target.x2, t),
      lerpDouble(y2, _target.y2, t),
      lerpDouble(x3, _target.x3, t),
      lerpDouble(y3, _target.y3, t),
    );
  }

  @override
  double getLength(Offset prePoint) =>
    cubic.length(prePoint.dx, prePoint.dy, x1, y1, x2, y2, x3, y3);

  @override
  Offset getPoint(Offset prePoint, double ratio) =>
    cubic.pointAt(prePoint.dx, prePoint.dy, x1, y1, x2, y2, x3, y3, ratio);

  @override
  bool inStroke(Offset prePoint, double lineWidth, Offset refPoint) {
    final halfLineWidth = lineWidth / 2;
    return cubic.pointDistance(prePoint.dx, prePoint.dy, x1, y1, x2, y2, x3, y3, refPoint.dx, refPoint.dy) <= halfLineWidth;
  }
}

class LineTo extends AbsolutePathCommand {
  LineTo(this.x, this.y);

  final double x;

  final double y;

  @override
  void applyTo(Path path) {
    path.lineTo(x, y);
  }

  @override
  List<Offset> get points => [Offset(x, y)];

  @override
  LineTo lerp(AbsolutePathCommand target, double t) {
    final _target = target as LineTo;
    return LineTo(
      lerpDouble(x, _target.x, t),
      lerpDouble(y, _target.y, t),
    );
  }

  @override
  double getLength(Offset prePoint) => line.length(prePoint.dx, prePoint.dy, x, y);

  @override
  Offset getPoint(Offset prePoint, double ratio) => Offset.lerp(prePoint, Offset(x, y), ratio);

  @override
  bool inStroke(Offset prePoint, double lineWidth, Offset refPoint) =>
    inLine(prePoint.dx, prePoint.dy, x, y, lineWidth, refPoint.dx, refPoint.dy);
}

class MoveTo extends AbsolutePathCommand {
  MoveTo(this.x, this.y);

  final double x;

  final double y;

  @override
  void applyTo(Path path) {
    path.moveTo(x, y);
  }

  @override
  List<Offset> get points => [Offset(x, y)];

  @override
  MoveTo lerp(AbsolutePathCommand target, double t) {
    final _target = target as MoveTo;
    return MoveTo(
      lerpDouble(x, _target.x, t),
      lerpDouble(y, _target.y, t),
    );
  }

  @override
  double getLength(Offset prePoint) => 0;

  @override
  Offset getPoint(Offset prePoint, double ratio) => null;

  @override
  bool inStroke(Offset prePoint, double lineWidth, Offset refPoint) => false;
}

class QuadraticBezierTo extends AbsolutePathCommand {
  QuadraticBezierTo(this.x1, this.y1, this.x2, this.y2);

  final double x1;

  final double y1;

  final double x2;

  final double y2;

  @override
  void applyTo(Path path) {
    path.quadraticBezierTo(x1, y1, x2, y2);
  }

  @override
  List<Offset> get points => [Offset(x1, y1), Offset(x2, y2)];

  @override
  QuadraticBezierTo lerp(AbsolutePathCommand target, double t) {
    final _target = target as QuadraticBezierTo;
    return QuadraticBezierTo(
      lerpDouble(x1, _target.x1, t),
      lerpDouble(y1, _target.y1, t),
      lerpDouble(x2, _target.x2, t),
      lerpDouble(y2, _target.y2, t),
    );
  }

  @override
  double getLength(Offset prePoint) =>
    quadratic.length(prePoint.dx, prePoint.dy, x1, y1, x2, y2);

  @override
  Offset getPoint(Offset prePoint, double ratio) =>
    quadratic.pointAt(prePoint.dx, prePoint.dy, x1, y1, x2, y2, ratio);

  @override
  bool inStroke(Offset prePoint, double lineWidth, Offset refPoint) {
    final halfLineWidth = lineWidth / 2;
    return quadratic.pointDistance(prePoint.dx, prePoint.dy, x1, y1, x2, y2, refPoint.dx, refPoint.dy) <= halfLineWidth;
  }
}

class RelativeArcToPoint extends RelativePathCommand {
  RelativeArcToPoint(
    this.arcEnd,
    {this.radius = Radius.zero,
    this.rotation = 0.0,
    this.largeArc = false,
    this.clockwise = true,});
  
  final Offset arcEnd;

  final Radius radius;

  final double rotation;

  final bool largeArc;

  final bool clockwise;

  @override
  void applyTo(Path path) {
    path.relativeArcToPoint(
      arcEnd,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  @override
  ArcToPoint toAbsolute(Offset prePoint) => ArcToPoint(
    prePoint + arcEnd,
    radius: radius,
    rotation: rotation,
    largeArc: largeArc,
    clockwise: clockwise,
  );
}

class RelativeCubicTo extends RelativePathCommand {
  RelativeCubicTo(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);

  final double x1;

  final double y1;

  final double x2;

  final double y2;

  final double x3;

  final double y3;

  @override
  void applyTo(Path path) {
    path.relativeCubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  CubicTo toAbsolute(Offset prePoint) {
    final x0 = prePoint.dx;
    final y0 = prePoint.dy;
    return CubicTo(
      x0 + x1,
      y0 + y1,
      x0 + x2,
      y0 + y2,
      x0 + x3,
      y0 + y3,
    );
  }
}

class RelativeLineTo extends RelativePathCommand {
  RelativeLineTo(this.x, this.y);

  final double x;

  final double y;

  @override
  void applyTo(Path path) {
    path.relativeLineTo(x, y);
  }

  @override
  LineTo toAbsolute(Offset prePoint) {
    final x0 = prePoint.dx;
    final y0 = prePoint.dy;
    return LineTo(
      x0 + x,
      y0 + y,
    );
  }
}

class RelativeMoveTo extends RelativePathCommand {
  RelativeMoveTo(this.x, this.y);

  final double x;

  final double y;

  @override
  void applyTo(Path path) {
    path.relativeMoveTo(x, y);
  }

  @override
  MoveTo toAbsolute(Offset prePoint) {
    final x0 = prePoint.dx;
    final y0 = prePoint.dy;
    return MoveTo(
      x0 + x,
      y0 + y,
    );
  }
}

class RelativeQuadraticBezierTo extends RelativePathCommand {
  RelativeQuadraticBezierTo(this.x1, this.y1, this.x2, this.y2);

  final double x1;

  final double y1;

  final double x2;

  final double y2;

  @override
  void applyTo(Path path) {
    path.relativeQuadraticBezierTo(x1, y1, x2, y2);
  }

  @override
  QuadraticBezierTo toAbsolute(Offset prePoint) {
    final x0 = prePoint.dx;
    final y0 = prePoint.dy;
    return QuadraticBezierTo(
      x0 + x1,
      y0 + y1,
      x0 + x2,
      y0 + y2,
    );
  }
}
