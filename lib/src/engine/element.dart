import 'dart:ui' show Canvas, Size, Rect;

import 'package:graphic/src/base.dart' show Base;

import 'cfg.dart' show Cfg;
import 'attrs.dart' show Attrs;
import 'shape.dart' show Shape;
import 'container.dart' show Container;
import 'util/matrix.dart' show Matrix, TransAction;
import 'util/vector2.dart' show Vector2;

const clipShape = ['circle', 'sector', 'polygon', 'rect', 'polyline'];

abstract class Element extends Base<Cfg> {
  Element(Cfg cfg) : super(cfg) {
    if (attrs != null) {
      initAttrs(attrs);
    }

    initTransform();
  }

  Attrs get attrs => cfg.attrs;

  @override
  Cfg get defaultCfg => Cfg()
    ..zIndex = 0
    ..visible = true
    ..destroyed = false;

  bool get isGroup => cfg.isGroup;

  bool get isShape => cfg.isShape;

  void initAttrs(Attrs attrs) =>
    attr(defaultAttrs.mix(attrs));

  Attrs get defaultAttrs => Attrs();

  void _setAttr(String name, Object value) {
    attrs[name] = value;
  }

  void afterAttrsSet() {}

  void attr(Attrs attrs) {
    if (cfg.destroyed) {
      return;
    }

    for (var k in attrs.keys) {
      _setAttr(k, attrs[k]);
    }
    afterAttrsSet();
  }

  Shape setClip(Cfg clipCfg) {
    Shape clip;
    if (clipCfg != null) {
      final type = clipCfg.type;
      final creator = Shape.creators[type];
      if (creator != null) {
        clip = creator(Cfg(
          type: clipCfg.type,
          attrs: clipCfg.attrs,
        )..renderer = cfg.renderer);
        clip.cfg.isClip = true;
      }
    }
    attr(Attrs(clip: clip));
    return clip;
  }

  Container get parent => cfg.parent;

  void paint(Canvas canvas, Size size) {
    if (cfg.destroyed) {
      return;
    }
    if (cfg.visible) {
      setCanvas(canvas);
      drawInner(canvas, size);
      restoreCanvas(canvas);
    }
  }

  void setCanvas(Canvas canvas) {
    final clip = attrs.clip;
    canvas.save();
    if (clip != null) {
      clip.resetTransform(canvas);
      canvas.clipPath(clip.path);
    }
    resetTransform(canvas);
  }

  void restoreCanvas(Canvas canvas) {
    canvas.restore();
  }

  void drawInner(Canvas canvas, Size size);

  void show() => cfg.visible = true;

  void hide() => cfg.visible = false;

  bool get visible => cfg.visible;

  void _removeFromParent() {
    final parent = cfg.parent;
    if (parent != null) {
      final children = cfg.children;
      children.remove(this);
    }
  }

  void remove(bool destroy) {
    if (destroy) {
      this.destroy();
    } else {
      _removeFromParent();
    }
  }

  void destroy() {
    final destroyed = cfg.destroyed;

    if (destroyed) {
      return;
    }

    _removeFromParent();

    cfg = Cfg();
    cfg.destroyed = true;
  }

  Rect get bbox;

  initTransform() {
    if (attrs.matrix == null) {
      attrs.matrix = Matrix.identity();
    }
  }

  Matrix get matrix => attrs.matrix;

  set matrix(Matrix value) => attrs.matrix = value;

  void transform(List<TransAction> actions) =>
    matrix.transform(actions);

  void setTransform(List<TransAction> actions) =>
    matrix = Matrix.identity()..transform(actions);
  
  void translate(double x, double y) =>
    matrix.translate(Vector2(x, y));

  void rotate(double rad) =>
    matrix.rotate(rad);

  void scale(double sx, double sy) =>
    matrix.scale(Vector2(sx, sy));
  
  void moveTo(double x, double y) {
    final cx = cfg.x ?? 0.0;
    final cy = cfg.y ?? 0.0;
    translate(x - cx, y - cy);
    cfg.x = x;
    cfg.y = y;
  }

  void apply(Vector2 v) =>
    v.transformMat2d(matrix);

  void resetTransform(Canvas canvas) {
    if (matrix != Matrix.identity()) {
      canvas.transform(matrix.toCanvasMatrix());
    }
  }

  bool get destroyed => cfg.destroyed;
}
