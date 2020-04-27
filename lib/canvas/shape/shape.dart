import 'dart:ui' show
  Canvas,
  Offset,
  PaintingStyle,
  Paint,
  Size;
import 'dart:math' show min, max;
import 'dart:ui' as ui show Path, Rect;

import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector4;

import '../cfg.dart' show Cfg;
import '../element.dart' show Element, ChangeType;
import '../attrs.dart' show Attrs;
import '../base.dart' show Ctor;
import '../group.dart' show Group;
import '../util/paint.dart' show refreshElement, applyClip;
import 'circle.dart' show Circle;
import 'Line.dart' show Line;
import 'marker.dart' show Marker;
import 'oval.dart' show Oval;
import 'path.dart' show Path;
import 'polygon.dart' show Polygon;
import 'polyline.dart' show Polyline;
import 'rect.dart' show Rect;

abstract class Shape extends Element {
  Shape(Cfg cfg) : super(cfg);

  final ui.Path _path = ui.Path();

  final Paint _paintObj = Paint();

  ui.Path get path {
    _path.reset();
    createPath(_path);
    return _path;
  }

  Paint get paintObj {
    attrs.applyTo(_paintObj);
    return _paintObj;
  }

  // AbstractShape

  bool _isInBBox(Offset refPoint) {
    final bbox = this.bbox;
    return bbox.contains(refPoint);
  }

  @override
  void afterAttrsChange(Attrs targetAttrs) {
    super.afterAttrsChange(targetAttrs);
    clearCacheBBox();
  }

  @override
  ui.Rect get bbox {
    var bbox = cfg.bbox;
    if (bbox == null) {
      bbox = calculateBBox();
      cfg.bbox = bbox;
    }
    return bbox;
  }

  @override
  ui.Rect get canvasBBox {
    var canvasBBox = cfg.canvasBBox;
    if (canvasBBox == null) {
      canvasBBox = calculateCanvasBBox();
      cfg.canvasBBox = canvasBBox;
    }
    return canvasBBox;
  }

  ui.Rect calculateBBox() {
    final bbox = _path.getBounds();
    final lineWidth = hitLineWidth;
    final halfLineWidth = lineWidth / 2;
    return bbox.inflate(halfLineWidth);
  }

  @override
  void applyMatrix(Matrix4 matrix) {
    super.applyMatrix(matrix);
    this.cfg.canvasBBox = null;
  }

  ui.Rect calculateCanvasBBox() {
    final bbox = this.bbox;
    final totalMatrix = this.totalMatrix;
    var left = bbox.left;
    var top = bbox.top;
    var right = bbox.right;
    var bottom = bbox.bottom;
    if (totalMatrix != null) {
      final topLeftVector = totalMatrix.transformed(Vector4.array([left, top]));
      final topRightVector = totalMatrix.transformed(Vector4.array([right, top]));
      final bottomLeft = totalMatrix.transformed(Vector4.array([left, bottom]));
      final bottomRight = totalMatrix.transformed(Vector4.array([right, bottom]));
      left = [topLeftVector[0], topRightVector[0], bottomLeft[0], bottomRight[0]].reduce(min);
      right = [topLeftVector[0], topRightVector[0], bottomLeft[0], bottomRight[0]].reduce(max);
      top = [topLeftVector[1], topRightVector[1], bottomLeft[1], bottomRight[1]].reduce(min);
      bottom = [topLeftVector[1], topRightVector[1], bottomLeft[1], bottomRight[1]].reduce(max);
    }
    return ui.Rect.fromLTRB(left, top, right, bottom);
  }

  void clearCacheBBox() {
    this.cfg.bbox = null;
    this.cfg.canvasBBox = null;
  }

  bool get isClipShape => this.cfg.isClipShape;

  bool isInShape(Offset refPoint) {
    final paintingStyle = this.paintingStyle;
    final lineWidth = this.hitLineWidth;
    return this.isInStrokeOrPath(refPoint, paintingStyle, lineWidth);
  }

  bool get isOnlyHitBBox => false;

  bool isHit(Offset point) {
    var vec = Vector4.array([point.dx, point.dy, 1]);
    vec = invertFromMatrix(vec);
    final refPoint = Offset(vec.x, vec.y);
    final inBBox = _isInBBox(refPoint);
    if (isOnlyHitBBox) {
      return inBBox;
    }
    if (inBBox && !isClipped(refPoint)) {
      return isInShape(refPoint);
    }
    return false;
  }

  // ShapeBase

  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..strokeWidth = 1
    ..strokeAppendWidth = 0;
  
  @override
  Map<ShapeType, Ctor<Shape>> get shapeBase => ShapeBase;

  @override
  Ctor<Group> get groupBase => (Cfg cfg) => Group(cfg);

  @override
  void onRendererChange(ChangeType changeType) {
    refreshElement(this, changeType);
  }

  PaintingStyle get paintingStyle => attrs.style;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final matrix = this.matrix;
    canvas.transform(matrix.storage);
    applyClip(canvas, this.clip);
    final paint = this.paintObj;
    final path = this.path;
    canvas.drawPath(path, paint);
    afterDrawPath(canvas);
    canvas.restore();
    afterDraw();
  }

  void afterDraw() {
    this.cfg.cacheCanvasBBox = canvasBBox;
    this.cfg.hasChanged = false;
  }

  @override
  void skipDraw() {
    this.cfg.cacheCanvasBBox = null;
    this.cfg.hasChanged = false;
  }

  void createPath(ui.Path path);

  void afterDrawPath(Canvas canvas) {}

  bool isInStrokeOrPath(Offset refPoint, PaintingStyle style, double lineWidth) => false;

  double get hitLineWidth {
    if (!(paintingStyle == PaintingStyle.stroke)) {
      return 0;
    }
    final attrs = this.attrs;
    return attrs.strokeWidth + attrs.strokeAppendWidth;
  }

  double get totalLength {
    throw UnimplementedError('${this.runtimeType} has no totalLength getter.');
  }

  Offset getPoint(double ratio) {
    throw UnimplementedError('${this.runtimeType} has no getPoint method.');
  }
}

enum ShapeType {
  circle,
  oval,
  image,
  line,
  marker,
  path,
  polygon,
  polyline,
  rect,
  text,
}

Shape _circleCtor(Cfg cfg) => Circle(cfg);

Shape _lineCtor(Cfg cfg) => Line(cfg);

Shape _markerCtor(Cfg cfg) => Marker(cfg);

Shape _ovalCtor(Cfg cfg) => Oval(cfg);

Shape _pathCtor(Cfg cfg) => Path(cfg);

Shape _polygonCtor(Cfg cfg) => Polygon(cfg);

Shape _polylineCtor(Cfg cfg) => Polyline(cfg);

Shape _rectCtor(Cfg cfg) => Rect(cfg);

const ShapeBase = {
  ShapeType.circle: _circleCtor,
  ShapeType.line: _lineCtor,
  ShapeType.marker: _markerCtor,
  ShapeType.oval: _ovalCtor,
  ShapeType.path: _pathCtor,
  ShapeType.polygon: _polygonCtor,
  ShapeType.polyline: _polylineCtor,
  ShapeType.rect: _rectCtor,
};
