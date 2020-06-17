import 'dart:ui';
import 'dart:ui' as ui;

import 'cfg.dart';
import 'attrs.dart';
import 'element.dart';
import 'shape/arc.dart';
import 'shape/circle.dart';
import 'shape/custom.dart';
import 'shape/line.dart';
import 'shape/polygon.dart';
import 'shape/polyline.dart';
import 'shape/rect.dart';
import 'shape/sector.dart';
import 'shape/text.dart';

abstract class Shape extends Element {
  static final creators = {
    'arc': (Cfg cfg) => Arc(cfg),
    'circle': (Cfg cfg) => Circle(cfg),
    'custom': (Cfg cfg) => Custom(cfg),
    'line': (Cfg cfg) => Line(cfg),
    'polygon': (Cfg cfg) => Polygon(cfg),
    'polyline': (Cfg cfg) => Polyline(cfg),
    'rect': (Cfg cfg) => Rect(cfg),
    'sector': (Cfg cfg) => Sector(cfg),
    'text': (Cfg cfg) => Text(cfg),
  };

  Shape(Cfg cfg) : super(cfg);

  final Path _path = Path();

  final Paint _paintObj = Paint();

  Path get path {
    _path.reset();
    createPath(_path);
    return _path;
  }

  Paint get paintObj {
    attrs.applyToPaint(_paintObj);
    return _paintObj;
  }

  PaintingStyle get paintingStyle => attrs.style;

  @override
  Cfg get defaultCfg => Cfg()
    ..zIndex = 0
    ..visible = true
    ..destroyed = false
    ..isShape = true
    ..attrs = Attrs();

  String get type => cfg.type;

  @override
  void drawInner(Canvas canvas, Size size) {
    canvas.drawPath(path, paintObj);
  }

  ui.Rect get bbox {
    var bbox = cfg.bbox;
    if (bbox == null) {
      bbox = calculateBox();
      cfg.bbox = bbox;
    }
    return bbox;
  }

  ui.Rect calculateBox() {
    final bbox = _path.getBounds();
    if (paintingStyle == PaintingStyle.stroke) {
      return bbox.inflate(attrs.strokeWidth / 2);
    }
    return bbox;
  }

  void createPath(Path path) {}
}
