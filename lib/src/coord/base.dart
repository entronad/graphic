import 'dart:ui' show Offset, Rect;

import 'package:graphic/src/engine/util/matrix.dart' show Matrix;
import 'package:graphic/src/engine/util/vector2.dart' show Vector2;

import 'coord_cfg.dart' show CoordCfg;

final defaultMatrix = Matrix.identity();

abstract class Coord {
  Coord(CoordCfg cfg) {
    this.cfg = defaultCfg.mix(cfg);
    
    Offset start;
    Offset end;
    if (cfg.plot != null) {
      start = cfg.plot.bottomLeft;
      end = cfg.plot.topRight;
      cfg.start = start;
      cfg.end = end;
    } else {
      start = cfg.start;
      end = cfg.end;
    }
    this.init(start, end);
  }

  CoordCfg cfg;

  CoordCfg get defaultCfg;

  void _scale(List<double> scale) {
    final matrix = cfg.matrix;
    final centerV = Vector2.fromOffset(cfg.center);
    final scaleV = Vector2.array(scale);
    matrix.translate(centerV);
    matrix.scale(scaleV);
    matrix.translate(-centerV);
  }

  void init(Offset start, Offset end) {
    cfg.matrix = defaultMatrix.clone();
    cfg.center = Offset(
      ((end.dx - start.dx) / 2) + start.dx,
      (end.dy - start.dy) / 2 + start.dy
    );
    if (cfg.scale != null) {
      _scale(cfg.scale);
    }
  }

  Offset convertPoint(Offset point) {
    final convertedPoint = convertPointInner(point);
    final vector = Vector2.fromOffset(convertedPoint);
    vector.transformMat2d(cfg.matrix);

    return Offset(vector.x, vector.y);
  }

  Offset invertPoint(Offset point) =>
    invertPointInner(point);

  Offset convertPointInner(Offset point);

  Offset invertPointInner(Offset point);

  void reset(Rect plot) {
    cfg.plot = plot;
    cfg.start = plot.bottomLeft;
    cfg.end = plot.topRight;
    init(plot.bottomLeft, plot.topRight);
  }
}
