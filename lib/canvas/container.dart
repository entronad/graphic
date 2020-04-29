import 'dart:ui' show Rect, Offset;

import 'package:flutter/widgets.dart' show UniqueKey;
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector4;

import 'cfg.dart' show Cfg;
import 'element.dart' show Element, ChangeType;
import 'group.dart' show Group;
import 'shape/shape.dart' show Shape;
import 'base.dart' show Ctor, Base;
import 'renderer.dart' show Renderer;
import 'event/graph_event.dart' show OriginalEvent;
import './animate/timeline.dart' show Timeline;

void _afterAdd(Element element) {
  if (element.isGroup) {
    if ((element as Group).isEntityGroup || element.cfg.children.isNotEmpty) {
      element.onRendererChange(ChangeType.add);
    }
  } else {
    element.onRendererChange(ChangeType.add);
  }
}

void _setRenderer(Element element, Renderer renderer) {
  element.cfg.renderer = renderer;
  if (element.isGroup) {
    final children = element.cfg.children;
    if (children.isNotEmpty) {
      for (var child in children) {
        _setRenderer(child, renderer);
      }
    }
  }
}

void _setTimeline(Element element, Timeline timeline) {
  element.cfg.timeline = timeline;
  if (element.isGroup) {
    final children = element.cfg.children;
    if (children.isNotEmpty) {
      for (var child in children) {
        _setTimeline(child, timeline);
      }
    }
  }
}

void _removeChild(Container container, Element element, [bool destroy = true]) {
  if (destroy) {
    element.destroy();
  } else {
    element.cfg.parent = null;
    element.cfg.renderer = null;
  }
  container.children.remove(element);
}

bool _isAllowCapture(Base element) =>
  element.cfg.visible && element.cfg.capture;

abstract class Container extends Element {
  Container(Cfg cfg) : super(cfg);

  bool get isRenderer => false;

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
        .map((element) => element.canvasBBox)
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
    for (var child in children) {
      child.applyMatrix(totalMatrix);
    }
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

  Renderer get renderer {
    Renderer renderer;
    if (isRenderer) {
      renderer = this;
    } else {
      renderer = this.cfg.renderer;
    }
    return renderer;
  }

  Shape getShape(Offset point, OriginalEvent ev) {
    if (!_isAllowCapture(this)) {
      return null;
    }
    final children = this.children;
    Shape shape;
    if (!isRenderer) {
      var v = Vector4.array([point.dx, point.dy, 1, 0]);
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
      if (_isAllowCapture(child)) {
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
    final renderer = this.renderer;
    final children = this.children;
    final timeline = cfg.timeline;
    final preParent = element.parent;
    if (preParent != null) {
      _removeChild(preParent, element, false);
    }
    element.cfg.parent = this;
    if (renderer != null) {
      _setRenderer(element, renderer);
    }
    if (timeline != null) {
      _setTimeline(element, timeline);
    }
    children.add(element);
    _afterAdd(element);
    _applyElementMatrix(element);
  }

  void _applyElementMatrix(Element element) {
    final totalMatrix = this.totalMatrix;
    if (totalMatrix != null) {
      element.applyMatrix(totalMatrix);
    }
  }

  List<Element> get children => cfg.children;

  void sort() {
    final children = this.children;
    for (var i = 0; i < children.length; i++) {
      children[i].index = i;
    }
    children.sort((child1, child2) {
      final diffZ = child1.cfg.zIndex - child2.cfg.zIndex;
      return diffZ == 0 ? child1.index - child2.index : diffZ;
    });
    onRendererChange(ChangeType.sort);
  }
  
  void clear() {
    cfg.clearing = true;
    if (destroyed) {
      return;
    }
    final children = this.children;
    for (var i = children.length - 1; i >= 0; i--) {
      children[i].destroy();
    }
    cfg.children = [];
    onRendererChange(ChangeType.clear);
    cfg.clearing = false;
  }

  void destroy() {
    if (cfg.destroyed) {
      return;
    }
    clear();
    super.destroy();
  }

  Element get first => children.first;

  Element get last => children.last;

  Element getChildByIndex(int index)
    => children[index];

  int get count => children.length;

  bool contain(Element element)
    => children.contains(element);

  void removeChild(Element element, [bool destroy = true]) {
    if (children.contains(element)) {
      element.remove(destroy);
    }
  }

  List<Element> findAll(bool Function(Element) fn) {
    final rst = <Element>[];
    final children = this.children;
    for (var element in children) {
      if (fn(element)) {
        rst.add(element);
      }
      if (element.isGroup) {
        rst.addAll((element as Group).findAll(fn));
      }
    }
    return rst;
  }

  Element find(bool Function(Element) fn) {
    Element rst;
    final children = this.children;
    for (var element in children) {
      if (fn(element)) {
        rst = element;
      } else if (element.isGroup) {
        rst = (element as Group).find(fn);
      }
    }
    return rst;
  }

  Element findById(UniqueKey id) =>
    find((element) => element.cfg.id == id);

  List<Element> findAllByName(String name) =>
    findAll((element) => element.cfg.name == name);
}
