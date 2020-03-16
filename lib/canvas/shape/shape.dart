import 'dart:ui' show
  Canvas,
  Offset,
  Rect,
  PaintingStyle,
  Path,
  Paint;
import 'dart:math' show min, max;

import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector4;

import '../cfg.dart' show Cfg;
import '../element.dart' show Element, ChangeType;
import '../attrs.dart' show Attrs;
import '../bbox/bbox.dart' show getBBoxMethod;
import '../base.dart' show Ctor;
import '../group.dart' show Group;
import '../util/draw.dart' show refreshElement, getMergedRegion;

abstract class Shape extends Element {
  Shape(Cfg cfg) : super(cfg);

  final Path _path = Path();

  final Paint _paint = Paint();

  Path get path => _path;

  Paint get paint {
    attrs.applyTo(_paint);
    return _paint;
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
  Rect get bbox {
    var bbox = cfg.bbox;
    if (bbox == null) {
      bbox = calculateBBox();
      cfg.bbox = bbox;
    }
    return bbox;
  }

  @override
  Rect get canvasBBox {
    var canvasBBox = cfg.canvasBBox;
    if (canvasBBox == null) {
      canvasBBox = calculateCanvasBBox();
      cfg.canvasBBox = canvasBBox;
    }
    return canvasBBox;
  }

  Rect calculateBBox() {
    final type = cfg.type;
    final lineWidth = hitLineWidth;
    final bboxMethod = getBBoxMethod(type);
    final bbox = bboxMethod(this);
    final halfLineWidth = lineWidth / 2;
    final left = bbox.left - halfLineWidth;
    final top = bbox.top - halfLineWidth;
    final right = bbox.right + halfLineWidth;
    final bottom = bbox.bottom + halfLineWidth;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  void applyMatrix(Matrix4 matrix) {
    super.applyMatrix(matrix);
    this.cfg.canvasBBox = null;
  }

  Rect calculateCanvasBBox() {
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
    return Rect.fromLTRB(left, top, right, bottom);
  }

  void clearCacheBBox() {
    this.cfg.bbox = null;
    this.cfg.canvasBBox = null;
  }

  bool get isClipShape => this.cfg.isClipShape;

  bool isInShape(Offset refPoint) {
    final isStroke = this.isStroke;
    final isFill = this.isFill;
    final lineWidth = this.hitLineWidth;
    return this.isInStrokeOrPath(refPoint, isStroke, isFill, lineWidth);
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
  Map<ShapeType, Ctor<Shape>> get shpeBase => shapeBase;

  @override
  Ctor<Group> get groupBase => (Cfg cfg) => Group(cfg);

  @override
  void onCanvasChange(ChangeType changeType) {
    refreshElement(this, changeType);
  }

  bool get isFill => attrs.style == PaintingStyle.fill || isClipShape;

  bool get isStroke => attrs.style == PaintingStyle.stroke;

  void _applyClip(Canvas canvas, Shape clip) {
    if (clip != null) {
      canvas.save();
      final clipPath = clip.path;
      final clipMatrix = clip.matrix;
      canvas.transform(clipMatrix.storage);
      canvas.clipPath(clipPath);
      canvas.restore();
      clip._afterDraw();
    }
  }

  void draw(Canvas canvas, [Rect region]) {
    final clip = this.clip;
    if (region != null) {
      final bbox = clip != null ? getMergedRegion([this, clip]) : canvasBBox;
      if (!region.overlaps(bbox)) {
        return;
      }
    }
    canvas.save();
    final matrix = this.matrix;
    canvas.transform(matrix.storage);
    _applyClip(canvas, this.clip);
    final paint = this.paint;
    final path = this.path;
    canvas.drawPath(path, paint);
    afterDrawPath(canvas);
    canvas.restore();
    _afterDraw();
  }

  void _afterDraw() {
    this.cfg.cacheCanvasBBox = canvasBBox;
    this.cfg.hasChanged = false;
  }

  void skipDraw() {
    this.cfg.cacheCanvasBBox = null;
    this.cfg.hasChanged = false;
  }

  void afterDrawPath(Canvas canvas) {}

  bool isInStrokeOrPath(Offset refPoint, bool isStroke, bool isFill, double lineWidth);

  double get hitLineWidth {
    if (!isStroke) {
      return 0;
    }
    final attrs = this.attrs;
    return attrs.strokeWidth + attrs.strokeAppendWidth;
  }
}

enum ShapeType {
  circle,
  ellipse,
  image,
  line,
  marker,
  path,
  polygon,
  polyline,
  rect,
  text,
}

// Shape _baseCtor(Cfg cfg) => Shape(cfg);

const shapeBase = {
  // ShapeType.base: _baseCtor,
};
