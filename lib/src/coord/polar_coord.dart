import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/engine/util/matrix.dart';
import 'package:graphic/src/engine/util/vector2.dart';

import 'base.dart';

class PolarCoord extends Coord {
  PolarCoord(CoordCfg cfg) : super(cfg);

  @override
  CoordCfg get defaultCfg => CoordCfg(
    type: CoordType.polar,
    startAngle: -pi / 2,
    endAngle: pi * 3 / 2,
    innerRadius: 0,
  )
    ..isPolar = true;
  
  @override
  void init(Offset start, Offset end) {
    super.init(start, end);
    final innerRadius = cfg.innerRadius;
    final width = (end.dx - start.dx).abs();
    final height = (end.dy - start.dy).abs();

    var maxRadius;
    var center;
    if (cfg.startAngle == -pi && cfg.endAngle == 0) {
      maxRadius = min(width / 2, height);
      center = Offset(
        (start.dx + end.dx) / 2,
        start.dy.toDouble(),  // ensure double for Vector2
      );
    } else {
      maxRadius = min(width, height) / 2;
      center = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );
    }

    final radius = cfg.radius;
    if (radius != null && radius > 0 && radius <= 1) {
      maxRadius = maxRadius * radius;
    }

    cfg.x = [
      cfg.startAngle,
      cfg.endAngle,
    ];

    cfg.y = [
      maxRadius * innerRadius,
      maxRadius,
    ];

    cfg.center = center;

    cfg.circleRadius = maxRadius;
  }

  @override
  Offset convertPointInner(Offset point) {
    final center = cfg.center;
    final transposed = cfg.transposed;
    final xDim = transposed ? (Offset p) => p.dy : (Offset p) => p.dx;
    final yDim = transposed ? (Offset p) => p.dx : (Offset p) => p.dy;
    final x = cfg.x;
    final y = cfg.y;

    final angle = x.first + (x.last - x.first) * xDim(point);
    final radius = y.first + (y.last - y.first) * yDim(point);

    return Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );
  }

  @override
  Offset invertPointInner(Offset point) {
    final center = cfg.center;
    final transposed = cfg.transposed;
    final x = cfg.x;
    final y = cfg.y;

    final m = Matrix(1, 0, 0, 1, 0, 0);
    m.rotate(x.first);

    var startV = Vector2(1, 0);
    startV.transformMat2d(m);
    startV = Vector2(startV.x, startV.y);

    final pointV = Vector2(point.dx - center.dx, point.dy - center.dy);
    if (pointV.zero()) {
      return Offset(0, 0);
    }

    var theta = startV.angleTo(pointV, x.last < x.first);
    if ((theta - pi * 2).abs() < 0.001) {
      theta = 0;
    }
    final l = pointV.length;
    var percentX = theta / (x.last - x.first);
    percentX = x.last - x.first > 0 ? percentX : -percentX;
    final percentY = (l - y.first) / (y.last - y.first);
    return transposed
      ? Offset(
        percentY,
        percentX,
      )
      : Offset(
        percentX,
        percentY,
      );
  }
}
