import 'dart:ui' show Offset;

import 'base.dart' show Coord;
import 'coord_cfg.dart' show CoordCfg, CoordType;

class RectCoord extends Coord {
  RectCoord(CoordCfg cfg) : super(cfg);

  @override
  CoordCfg get defaultCfg => CoordCfg(
    type: CoordType.rect,
  )
    ..isRect = true;
  
  @override
  void init(Offset start, Offset end) {
    super.init(start, end);
    cfg.x = [start.dx, end.dx];
    cfg.y = [start.dy, end.dy];
  }

  @override
  Offset convertPointInner(Offset point) {
    final transposed = cfg.transposed;
    final xDim = transposed ? (Offset p) => p.dy : (Offset p) => p.dx;
    final yDim = transposed ? (Offset p) => p.dx : (Offset p) => p.dy;
    final x = cfg.x;
    final y = cfg.y;
    return Offset(
      x.first + (x.last - x.first) * xDim(point),
      y.first + (y.last - y.first) * yDim(point),
    );
  }

  @override
  Offset invertPointInner(Offset point) {
    final transposed = cfg.transposed;
    final x = cfg.x;
    final y = cfg.y;
    return transposed
      ? Offset(
        (point.dy - y.first) / (y.last - y.first),
        (point.dx - x.first) / (x.last - x.first),
      )
      : Offset(
        (point.dx - x.first) / (x.last - x.first),
        (point.dy - y.first) / (y.last - y.first),
      );
  }
}
