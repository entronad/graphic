import 'dart:ui' show Canvas, Size;

import 'container.dart' show Container;
import 'cfg.dart' show Cfg;
import 'base.dart' show Ctor;
import 'element.dart' show ChangeType;
import './util/paint.dart' show refreshElement, applyClip, paintChildren;
import './shape/shape.dart' show ShapeType, Shape, ShapeBase;

class Group extends Container {
  Group(Cfg cfg) : super(cfg);

  @override
  bool get isGroup => true;

  bool get isEntityGroup => false;

  @override
  Group clone() {
    final clone = Group(cfg.clone());
    final children = this.children;
    for (var child in children) {
      clone.add(child.clone());
    }
    return clone;
  }

  @override
  void onRendererChange(ChangeType changeType) {
    refreshElement(this, changeType);
  }

  @override
  Map<ShapeType, Ctor<Shape>> get shapeBase => ShapeBase;

  @override
  Ctor<Group> get groupBase => (Cfg cfg) => Group(cfg);

  @override
  void paint(Canvas canvas, Size size) {
    final children = this.children;
    if (children.isNotEmpty) {
      canvas.save();
      final matrix = this.matrix;
      canvas.transform(matrix.storage);
      applyClip(canvas, this.clip);
      paintChildren(canvas, children, size);
      canvas.restore();
    }
    cfg.cacheCanvasBBox = canvasBBox;
    cfg.hasChanged = false;
  }

  @override
  void skipPaint() {
    cfg.cacheCanvasBBox = null;
    cfg.hasChanged = false;
  }
}
