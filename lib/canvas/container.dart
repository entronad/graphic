import 'dart:ui' show Rect, Offset;

import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector4;

import 'cfg.dart' show Cfg;
import 'element.dart' show Element;
import 'group.dart' show Group;
import 'shape/shape.dart' show Shape;
import 'base.dart' show Ctor, Base;
import 'canvas_controller.dart' show CanvasController;
import 'event/graph_event.dart' show OriginalEvent;

bool isAllowCapture(Base element) =>
  element.cfg.visible && element.cfg.capture;

abstract class Container extends Element {
  Container(Cfg cfg) : super(cfg);

  bool get isCanvasController => false;

  @override
  Rect get bbox {
    final children = this.children.where(
      (child) =>
        child.cfg.visible
        && (
          !child.isGroup
          || (child.isGroup && (child as Group).children.isNotEmpty)
        )
    );
    if (children.isNotEmpty) {
      return children
        .map((element) => bbox)
        .reduce((bbox1, bbox2) => bbox1.expandToInclude(bbox2));
    }
    return Rect.zero;
  }

  @override
  Rect get canvasBBox {
    final children = this.children.where(
      (child) =>
        child.cfg.visible
        && (
          !child.isGroup
          || (child.isGroup && (child as Group).children.isNotEmpty)
        )
    );
    if (children.isNotEmpty) {
      return children
        .map((element) => canvasBBox)
        .reduce((bbox1, bbox2) => bbox1.expandToInclude(bbox2));
    }
    return Rect.zero;
  }

  @override
  Cfg get defaultCfg => super.defaultCfg
    ..children = [];
  
  @override
  void onAttrChange(String name, Object value, Object originValue) {
    super.onAttrChange(name, value, originValue);
    if (name == 'matrix') {
      final totalMatrix = this.totalMatrix;
      _applyChildrenMarix(totalMatrix);
    }
  }

  @override
  void applyMatrix(Matrix4 matrix) {
    final preTotalMatrix = this.totalMatrix;
    super.applyMatrix(matrix);
    final totalMatrix = this.totalMatrix;
    if (totalMatrix == preTotalMatrix) {
      return;
    }
    _applyChildrenMarix(totalMatrix);
  }

  void _applyChildrenMarix(Matrix4 totalMatrix) {
    final children = this.children;
    children.forEach((child) {
      child.applyMatrix(totalMatrix);
    });
  }

  Shape addShape(Cfg cfg) {
    final shapeType = cfg.type;
    final shapeBase = this.shapeBase;
    final shape = shapeBase[shapeType](cfg);
    add(shape);
    return shape;
  }

  Group addGroup([Cfg cfg, Ctor<Group> groupCtor]) {
    Group group;
    if (groupCtor != null) {
      if (cfg != null) {
        group = groupCtor(cfg);
      } else {
        group = groupCtor(Cfg(parent: this));
      }
    } else {
      final tmpCfg = cfg ?? Cfg();
      final tmpGroupCtor = this.groupBase;
      group = tmpGroupCtor(tmpCfg);
    }
    add(group);
    return group;
  }

  CanvasController get canvasController {
    CanvasController canvasController;
    if (isCanvasController) {
      canvasController = this;
    } else {
      canvasController = this.cfg.canvasController;
    }
    return canvasController;
  }

  Shape getShape(Offset point, OriginalEvent ev) {
    if (!isAllowCapture(this)) {
      return null;
    }
    final children = this.children;
    Shape shape;
    if (!isCanvasController) {
      var v = Vector4.array([point.dx, point.dy, 1]);
      v = invertFromMatrix(v);
      final vPoint = Offset(v.x, v.y);
      if (!isClipped(vPoint)) {
        shape = _findShape(children, vPoint, ev);
      }
    } else {
      shape = _findShape(children, point, ev);
    }
    return shape;
  }

  Shape _findShape(List<Element> children, Offset point, OriginalEvent ev) {
    Shape shape;
    for (var i = children.length - 1; i >= 0; i--) {
      final child = children[i];
      if (isAllowCapture(child)) {
        if (child.isGroup) {
          shape = (child as Group).getShape(point, ev);
        } else if ((child as Shape).isHit(point)) {
          shape = child;
        }
      }
      if (shape != null) {
        break;
      }
    }
    return shape;
  }

  void add(Element element) {
    final canvasController = this.canvasController;
    final children = this.children;
    
  }

  void sort();
  List<Element> get children => null;
}
