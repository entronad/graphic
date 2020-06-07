import 'dart:math' show min, max;
import 'dart:ui';

import 'cfg.dart' show Cfg;
import 'container.dart' show Container;
import 'util/vector2.dart' show Vector2;

class Group extends Container {
  Group(Cfg cfg) : super(cfg);

  @override
  Cfg get defaultCfg => Cfg()
    ..zIndex = 0
    ..visible = true
    ..destroyed = false
    ..isGroup = true
    ..children = [];

  @override
  void drawInner(Canvas canvas, Size size) {
    for (var child in children) {
      child.paint(canvas, size);
    }
  }

  @override
  Rect get bbox {
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;
    for (var child in children) {
      if (child.cfg.visible) {
        final bbox = child.bbox;
        if (bbox == null) {
          continue;
        }

        final topLeft = Vector2.fromOffset(bbox.topLeft);
        final bottomLeft = Vector2.fromOffset(bbox.bottomLeft);
        final topRight = Vector2.fromOffset(bbox.topRight);
        final bottomRight = Vector2.fromOffset(bbox.bottomRight);
        final matrix = child.attrs.matrix;

        topLeft.transformMat2d(matrix);
        bottomLeft.transformMat2d(matrix);
        topRight.transformMat2d(matrix);
        bottomRight.transformMat2d(matrix);

        final candidatesX = [topLeft.x, bottomLeft.x, topRight.x, bottomRight.x, minX, maxX];
        final candidatesY = [topLeft.y, bottomLeft.y, topRight.y, bottomRight.y, minY, maxY];

        minX = candidatesX.reduce(min);
        maxX = candidatesX.reduce(max);
        minY = candidatesY.reduce(min);
        maxY = candidatesY.reduce(max);
      }
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  void destroy() {
    if (cfg.destroyed) {
      return;
    }
    clear();
    super.destroy();
  }
}
